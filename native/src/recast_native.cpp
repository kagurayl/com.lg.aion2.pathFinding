#include <pybind11/pybind11.h>
#include <pybind11/numpy.h>
#include <pybind11/stl.h>
#include <pybind11/stl/filesystem.h>

#include "DetourAlloc.h"
#include "DetourCommon.h"
#include "DetourNavMesh.h"
#include "DetourNavMeshBuilder.h"
#include "DetourNavMeshQuery.h"
#include "PartitionedMesh.h"
#include "Recast.h"

#include <algorithm>
#include <array>
#include <atomic>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <exception>
#include <filesystem>
#include <memory>
#include <stdexcept>
#include <string>
#include <thread>
#include <vector>

namespace py = pybind11;

namespace {
constexpr int NAVMESHSET_MAGIC = 'M' << 24 | 'S' << 16 | 'E' << 8 | 'T';
constexpr int NAVMESHSET_VERSION = 1;
constexpr unsigned short WALK_FLAG = 1;

struct NavMeshSetHeader {
    int magic;
    int version;
    int numTiles;
    dtNavMeshParams params;
};

struct NavMeshTileHeader {
    dtTileRef tileRef;
    int dataSize;
};

struct RecastDeleter {
    void operator()(rcHeightfield* p) const { rcFreeHeightField(p); }
    void operator()(rcCompactHeightfield* p) const { rcFreeCompactHeightfield(p); }
    void operator()(rcContourSet* p) const { rcFreeContourSet(p); }
    void operator()(rcPolyMesh* p) const { rcFreePolyMesh(p); }
    void operator()(rcPolyMeshDetail* p) const { rcFreePolyMeshDetail(p); }
};

struct NavMeshDeleter {
    void operator()(dtNavMesh* p) const { dtFreeNavMesh(p); }
};

struct NavQueryDeleter {
    void operator()(dtNavMeshQuery* p) const { dtFreeNavMeshQuery(p); }
};

using NavPtr = std::unique_ptr<dtNavMesh, NavMeshDeleter>;
using QueryPtr = std::unique_ptr<dtNavMeshQuery, NavQueryDeleter>;

template <typename T>
void require_status(dtStatus status, const T& message) {
    if (dtStatusFailed(status)) {
        throw std::runtime_error(message);
    }
}

int next_power_of_two(int value) {
    int result = 1;
    while (result < value) {
        if (result > (1 << 29)) {
            throw std::invalid_argument("mesh is too large");
        }
        result <<= 1;
    }
    return result;
}

int integer_log2(int value) {
    int result = 0;
    while (value > 1) {
        value >>= 1;
        ++result;
    }
    return result;
}

class NavMesh {
public:
    explicit NavMesh(NavPtr mesh) : mesh_(std::move(mesh)), query_(dtAllocNavMeshQuery()) {
        if (!mesh_ || !query_) {
            throw std::runtime_error("could not allocate Detour objects");
        }
        require_status(query_->init(mesh_.get(), 16384), "could not initialize path query");
    }

    static std::unique_ptr<NavMesh> build(
        const std::vector<std::array<float, 3>>& input_vertices,
        const std::vector<std::array<int, 3>>& input_triangles,
        float cell_size,
        float cell_height,
        float agent_height,
        float agent_radius,
        float agent_max_climb,
        float agent_max_slope,
        int tile_size) {
        if (input_vertices.size() < 3 || input_triangles.empty()) {
            throw std::invalid_argument("vertices and triangles must not be empty");
        }
        if (cell_size <= 0 || cell_height <= 0 || agent_height <= 0 || agent_radius < 0 ||
            agent_max_climb < 0 || tile_size <= 0) {
            throw std::invalid_argument("invalid build settings");
        }

        std::vector<float> vertices;
        vertices.reserve(input_vertices.size() * 3);
        for (const auto& vertex : input_vertices) {
            vertices.insert(vertices.end(), vertex.begin(), vertex.end());
        }
        std::vector<int> triangles;
        triangles.reserve(input_triangles.size() * 3);
        for (const auto& triangle : input_triangles) {
            for (int index : triangle) {
                if (index < 0 || static_cast<size_t>(index) >= input_vertices.size()) {
                    throw std::invalid_argument("triangle index is outside the vertex array");
                }
                triangles.push_back(index);
            }
        }

        float bounds_min[3];
        float bounds_max[3];
        rcCalcBounds(vertices.data(), static_cast<int>(input_vertices.size()), bounds_min, bounds_max);
        // Give flat input geometry vertical volume for rasterization and nearest-poly queries.
        if (bounds_max[1] - bounds_min[1] < cell_height) {
            bounds_min[1] -= cell_height * 2.0f;
            bounds_max[1] += agent_height + cell_height * 2.0f;
        }

        int grid_width = 0;
        int grid_height = 0;
        rcCalcGridSize(bounds_min, bounds_max, cell_size, &grid_width, &grid_height);
        const int tile_width = (grid_width + tile_size - 1) / tile_size;
        const int tile_height = (grid_height + tile_size - 1) / tile_size;
        const int required_tiles = tile_width * tile_height;
        const int max_tiles = next_power_of_two(std::max(required_tiles, 1));
        const int tile_bits = integer_log2(max_tiles);
        if (tile_bits > 14) {
            throw std::invalid_argument("mesh needs more than Detour's maximum tile count");
        }

        dtNavMeshParams nav_params{};
        rcVcopy(nav_params.orig, bounds_min);
        nav_params.tileWidth = tile_size * cell_size;
        nav_params.tileHeight = tile_size * cell_size;
        nav_params.maxTiles = max_tiles;
        nav_params.maxPolys = 1 << (22 - tile_bits);

        NavPtr mesh(dtAllocNavMesh());
        if (!mesh) {
            throw std::runtime_error("could not allocate navmesh");
        }
        require_status(mesh->init(&nav_params), "could not initialize tiled navmesh");

        PartitionedMesh partitioned;
        partitioned.PartitionMesh(vertices.data(), triangles.data(),
                                  static_cast<int>(input_triangles.size()), 256);
        struct TileBuildResult {
            unsigned char* data = nullptr;
            int size = 0;
            std::exception_ptr error;
        };
        std::vector<TileBuildResult> tile_results(static_cast<size_t>(required_tiles));
        std::atomic<int> next_tile{0};
        const unsigned int detected_workers = std::max(1u, std::thread::hardware_concurrency());
        const int worker_count = std::min(required_tiles, static_cast<int>(std::min(8u, detected_workers)));
        std::vector<std::thread> workers;
        workers.reserve(static_cast<size_t>(worker_count));
        for (int worker = 0; worker < worker_count; ++worker) {
            workers.emplace_back([&]() {
                while (true) {
                    const int index = next_tile.fetch_add(1);
                    if (index >= required_tiles) {
                        return;
                    }
                    const int x = index % tile_width;
                    const int y = index / tile_width;
                    try {
                        rcContext context;
                        auto tile_data = build_tile(
                            context, partitioned, vertices,
                            static_cast<int>(input_vertices.size()), x, y,
                            bounds_min, bounds_max, cell_size, cell_height,
                            agent_height, agent_radius, agent_max_climb,
                            agent_max_slope, tile_size);
                        tile_results[static_cast<size_t>(index)].data = tile_data.first;
                        tile_results[static_cast<size_t>(index)].size = tile_data.second;
                    } catch (...) {
                        tile_results[static_cast<size_t>(index)].error = std::current_exception();
                    }
                }
            });
        }
        for (auto& worker : workers) {
            worker.join();
        }
        for (const auto& result : tile_results) {
            if (result.error) {
                for (const auto& allocated : tile_results) {
                    if (allocated.data) {
                        dtFree(allocated.data);
                    }
                }
                std::rethrow_exception(result.error);
            }
        }

        int built_tiles = 0;
        for (auto& tile_data : tile_results) {
            if (!tile_data.data) {
                continue;
            }
            dtTileRef tile_ref = 0;
            const dtStatus status = mesh->addTile(tile_data.data, tile_data.size,
                                                  DT_TILE_FREE_DATA, 0, &tile_ref);
            if (dtStatusFailed(status)) {
                dtFree(tile_data.data);
                tile_data.data = nullptr;
                for (auto& remaining : tile_results) {
                    if (remaining.data) {
                        dtFree(remaining.data);
                        remaining.data = nullptr;
                    }
                }
                throw std::runtime_error("could not add generated tile to navmesh");
            }
            tile_data.data = nullptr;  // Ownership transferred to dtNavMesh.
            ++built_tiles;
        }
        if (built_tiles == 0) {
            throw std::runtime_error("build produced no walkable navmesh tiles");
        }
        return std::unique_ptr<NavMesh>(new NavMesh(std::move(mesh)));
    }

    static std::unique_ptr<NavMesh> build_arrays(
        py::array_t<float, py::array::c_style | py::array::forcecast> vertex_array,
        py::array_t<int, py::array::c_style | py::array::forcecast> triangle_array,
        float cell_size, float cell_height, float agent_height, float agent_radius,
        float agent_max_climb, float agent_max_slope, int tile_size) {
        if (vertex_array.ndim() != 2 || vertex_array.shape(1) != 3 ||
            triangle_array.ndim() != 2 || triangle_array.shape(1) != 3) {
            throw std::invalid_argument("vertices and triangles must have shape (N, 3)");
        }
        const auto vertex_count = static_cast<size_t>(vertex_array.shape(0));
        const auto triangle_count = static_cast<size_t>(triangle_array.shape(0));
        std::vector<std::array<float, 3>> vertices(vertex_count);
        std::vector<std::array<int, 3>> triangles(triangle_count);
        if (vertex_count) {
            std::memcpy(vertices.data(), vertex_array.data(), vertex_count * 3 * sizeof(float));
        }
        if (triangle_count) {
            std::memcpy(triangles.data(), triangle_array.data(), triangle_count * 3 * sizeof(int));
        }
        std::unique_ptr<NavMesh> result;
        {
            py::gil_scoped_release release;
            result = build(vertices, triangles, cell_size, cell_height, agent_height, agent_radius,
                           agent_max_climb, agent_max_slope, tile_size);
        }
        return result;
    }

    static std::unique_ptr<NavMesh> load(const std::filesystem::path& path) {
        FILE* raw = std::fopen(path.string().c_str(), "rb");
        if (!raw) {
            throw std::runtime_error("could not open navmesh file for reading: " + path.string());
        }
        std::unique_ptr<FILE, decltype(&std::fclose)> file(raw, &std::fclose);
        NavMeshSetHeader header{};
        if (std::fread(&header, sizeof(header), 1, file.get()) != 1 ||
            header.magic != NAVMESHSET_MAGIC || header.version != NAVMESHSET_VERSION ||
            header.numTiles < 0) {
            throw std::runtime_error("invalid navmesh set header");
        }

        NavPtr mesh(dtAllocNavMesh());
        if (!mesh) {
            throw std::runtime_error("could not allocate navmesh");
        }
        require_status(mesh->init(&header.params), "could not initialize loaded navmesh");
        for (int i = 0; i < header.numTiles; ++i) {
            NavMeshTileHeader tile_header{};
            if (std::fread(&tile_header, sizeof(tile_header), 1, file.get()) != 1 ||
                tile_header.tileRef == 0 || tile_header.dataSize <= 0) {
                throw std::runtime_error("invalid navmesh tile header");
            }
            auto* data = static_cast<unsigned char*>(dtAlloc(tile_header.dataSize, DT_ALLOC_PERM));
            if (!data) {
                throw std::runtime_error("could not allocate navmesh tile data");
            }
            if (std::fread(data, static_cast<size_t>(tile_header.dataSize), 1, file.get()) != 1) {
                dtFree(data);
                throw std::runtime_error("truncated navmesh tile data");
            }
            const dtStatus status = mesh->addTile(data, tile_header.dataSize, DT_TILE_FREE_DATA,
                                                  tile_header.tileRef, nullptr);
            if (dtStatusFailed(status)) {
                dtFree(data);
                throw std::runtime_error("could not add loaded navmesh tile");
            }
        }
        return std::unique_ptr<NavMesh>(new NavMesh(std::move(mesh)));
    }

    void save(const std::filesystem::path& path) const {
        FILE* raw = std::fopen(path.string().c_str(), "wb");
        if (!raw) {
            throw std::runtime_error("could not open navmesh file for writing: " + path.string());
        }
        std::unique_ptr<FILE, decltype(&std::fclose)> file(raw, &std::fclose);
        NavMeshSetHeader header{};
        header.magic = NAVMESHSET_MAGIC;
        header.version = NAVMESHSET_VERSION;
        std::memcpy(&header.params, mesh_->getParams(), sizeof(dtNavMeshParams));
        for (int i = 0; i < mesh_->getMaxTiles(); ++i) {
            const dtMeshTile* tile = static_cast<const dtNavMesh*>(mesh_.get())->getTile(i);
            if (tile && tile->header && tile->dataSize > 0) {
                ++header.numTiles;
            }
        }
        if (std::fwrite(&header, sizeof(header), 1, file.get()) != 1) {
            throw std::runtime_error("could not write navmesh set header");
        }
        for (int i = 0; i < mesh_->getMaxTiles(); ++i) {
            const dtMeshTile* tile = static_cast<const dtNavMesh*>(mesh_.get())->getTile(i);
            if (!tile || !tile->header || tile->dataSize <= 0) {
                continue;
            }
            const NavMeshTileHeader tile_header{mesh_->getTileRef(tile), tile->dataSize};
            if (std::fwrite(&tile_header, sizeof(tile_header), 1, file.get()) != 1 ||
                std::fwrite(tile->data, static_cast<size_t>(tile->dataSize), 1, file.get()) != 1) {
                throw std::runtime_error("could not write navmesh tile");
            }
        }
    }

    std::array<float, 3> sample_position(const std::array<float, 3>& point) const {
        dtQueryFilter filter;
        filter.setIncludeFlags(WALK_FLAG);
        filter.setExcludeFlags(0);
        const float extents[3] = {2.0f, 4.0f, 2.0f};
        dtPolyRef reference = 0;
        std::array<float, 3> nearest{};
        require_status(query_->findNearestPoly(point.data(), extents, &filter, &reference,
                                               nearest.data()),
                       "nearest-poly query failed");
        if (!reference) {
            throw std::runtime_error("point is not near a walkable polygon");
        }
        return nearest;
    }

    bool line_of_sight(const std::array<float, 3>& start,
                       const std::array<float, 3>& end) const {
        dtQueryFilter filter;
        filter.setIncludeFlags(WALK_FLAG);
        filter.setExcludeFlags(0);
        const float extents[3] = {2.0f, 4.0f, 2.0f};
        dtPolyRef start_ref = 0;
        dtPolyRef end_ref = 0;
        float nearest_start[3]{};
        float nearest_end[3]{};
        require_status(query_->findNearestPoly(start.data(), extents, &filter, &start_ref,
                                               nearest_start),
                       "nearest-poly query failed for line start");
        require_status(query_->findNearestPoly(end.data(), extents, &filter, &end_ref,
                                               nearest_end),
                       "nearest-poly query failed for line end");
        if (!start_ref || !end_ref) {
            return false;
        }
        const auto cast_clear = [&](dtPolyRef reference, const float* from, const float* to) {
            float hit_t = 0.0f;
            float hit_normal[3]{};
            std::array<dtPolyRef, 512> visited{};
            int visited_count = 0;
            require_status(query_->raycast(reference, from, to, &filter, &hit_t, hit_normal,
                                           visited.data(), &visited_count,
                                           static_cast<int>(visited.size())),
                           "line-of-sight raycast failed");
            return hit_t >= 0.9999f;
        };
        return cast_clear(start_ref, nearest_start, nearest_end) ||
               cast_clear(end_ref, nearest_end, nearest_start);
    }

    std::vector<std::array<float, 3>> find_path(const std::array<float, 3>& start,
                                                 const std::array<float, 3>& end) const {
        dtQueryFilter filter;
        filter.setIncludeFlags(WALK_FLAG);
        filter.setExcludeFlags(0);
        const float extents[3] = {2.0f, 4.0f, 2.0f};
        dtPolyRef start_ref = 0;
        dtPolyRef end_ref = 0;
        float nearest_start[3]{};
        float nearest_end[3]{};
        require_status(query_->findNearestPoly(start.data(), extents, &filter, &start_ref, nearest_start),
                       "nearest-poly query failed for path start");
        require_status(query_->findNearestPoly(end.data(), extents, &filter, &end_ref, nearest_end),
                       "nearest-poly query failed for path end");
        if (!start_ref || !end_ref) {
            throw std::runtime_error("path endpoint is not near a walkable polygon");
        }

        std::array<dtPolyRef, 16384> corridor{};
        int corridor_count = 0;
        require_status(query_->findPath(start_ref, end_ref, nearest_start, nearest_end, &filter,
                                        corridor.data(), &corridor_count,
                                        static_cast<int>(corridor.size())),
                       "Detour could not find a polygon path");
        if (corridor_count == 0) {
            throw std::runtime_error("no path connects the requested points");
        }

        if (corridor[corridor_count - 1] != end_ref) {
            throw std::runtime_error("no complete path connects the requested points");
        }
        float straight_end[3];
        dtVcopy(straight_end, nearest_end);
        std::array<float, 16384 * 3> points{};
        std::array<unsigned char, 16384> flags{};
        std::array<dtPolyRef, 16384> refs{};
        int point_count = 0;
        require_status(query_->findStraightPath(nearest_start, straight_end, corridor.data(),
                                                corridor_count, points.data(), flags.data(), refs.data(),
                                                &point_count, 16384, 0),
                       "Detour could not create a straight path");
        std::vector<std::array<float, 3>> result;
        result.reserve(point_count);
        for (int i = 0; i < point_count; ++i) {
            result.push_back({points[i * 3], points[i * 3 + 1], points[i * 3 + 2]});
        }
        return result;
    }

    int tile_count() const {
        int result = 0;
        for (int i = 0; i < mesh_->getMaxTiles(); ++i) {
            const dtMeshTile* tile = static_cast<const dtNavMesh*>(mesh_.get())->getTile(i);
            if (tile && tile->header && tile->dataSize > 0) {
                ++result;
            }
        }
        return result;
    }

private:
    static std::pair<unsigned char*, int> build_tile(
        rcContext& context, const PartitionedMesh& partitioned, const std::vector<float>& vertices,
        int vertex_count, int tile_x, int tile_y, const float* bounds_min, const float* bounds_max,
        float cell_size, float cell_height, float agent_height, float agent_radius,
        float agent_max_climb, float agent_max_slope, int tile_size) {
        rcConfig config{};
        config.cs = cell_size;
        config.ch = cell_height;
        config.walkableSlopeAngle = agent_max_slope;
        config.walkableHeight = static_cast<int>(std::ceil(agent_height / cell_height));
        config.walkableClimb = static_cast<int>(std::floor(agent_max_climb / cell_height));
        config.walkableRadius = static_cast<int>(std::ceil(agent_radius / cell_size));
        config.maxEdgeLen = tile_size;
        config.maxSimplificationError = 1.3f;
        config.minRegionArea = 0;
        config.mergeRegionArea = 0;
        config.maxVertsPerPoly = 6;
        config.tileSize = tile_size;
        config.borderSize = config.walkableRadius + 3;
        config.width = config.tileSize + config.borderSize * 2;
        config.height = config.tileSize + config.borderSize * 2;
        config.detailSampleDist = cell_size * 6.0f;
        config.detailSampleMaxError = cell_height;

        const float tile_world_size = tile_size * cell_size;
        config.bmin[0] = bounds_min[0] + tile_x * tile_world_size;
        config.bmin[1] = bounds_min[1];
        config.bmin[2] = bounds_min[2] + tile_y * tile_world_size;
        config.bmax[0] = bounds_min[0] + (tile_x + 1) * tile_world_size;
        config.bmax[1] = bounds_max[1];
        config.bmax[2] = bounds_min[2] + (tile_y + 1) * tile_world_size;
        config.bmin[0] -= config.borderSize * config.cs;
        config.bmin[2] -= config.borderSize * config.cs;
        config.bmax[0] += config.borderSize * config.cs;
        config.bmax[2] += config.borderSize * config.cs;

        float rect_min[2] = {config.bmin[0], config.bmin[2]};
        float rect_max[2] = {config.bmax[0], config.bmax[2]};
        std::vector<int> nodes;
        partitioned.GetNodesOverlappingRect(rect_min, rect_max, nodes);
        if (nodes.empty()) {
            return {nullptr, 0};
        }

        std::unique_ptr<rcHeightfield, RecastDeleter> heightfield(rcAllocHeightfield());
        if (!heightfield || !rcCreateHeightfield(&context, *heightfield, config.width, config.height,
                                                  config.bmin, config.bmax, config.cs, config.ch)) {
            throw std::runtime_error("could not create Recast heightfield");
        }
        std::vector<unsigned char> areas(static_cast<size_t>(std::max(partitioned.maxTrisPerChunk, 1)));
        for (int node_index : nodes) {
            const auto& node = partitioned.nodes[node_index];
            const int* node_triangles = partitioned.tris.data() + node.triIndex * 3;
            std::fill(areas.begin(), areas.begin() + node.numTris, 0);
            rcMarkWalkableTriangles(&context, config.walkableSlopeAngle, vertices.data(), vertex_count,
                                    node_triangles, node.numTris, areas.data());
            if (!rcRasterizeTriangles(&context, vertices.data(), vertex_count, node_triangles,
                                      areas.data(), node.numTris, *heightfield, config.walkableClimb)) {
                throw std::runtime_error("could not rasterize tile triangles");
            }
        }

        rcFilterLowHangingWalkableObstacles(&context, config.walkableClimb, *heightfield);
        rcFilterLedgeSpans(&context, config.walkableHeight, config.walkableClimb, *heightfield);
        rcFilterWalkableLowHeightSpans(&context, config.walkableHeight, *heightfield);

        std::unique_ptr<rcCompactHeightfield, RecastDeleter> compact(rcAllocCompactHeightfield());
        if (!compact || !rcBuildCompactHeightfield(&context, config.walkableHeight, config.walkableClimb,
                                                    *heightfield, *compact)) {
            throw std::runtime_error("could not build compact heightfield");
        }
        heightfield.reset();
        if (!rcErodeWalkableArea(&context, config.walkableRadius, *compact) ||
            !rcBuildRegionsMonotone(&context, *compact, config.borderSize,
                                    config.minRegionArea, config.mergeRegionArea)) {
            throw std::runtime_error("could not build tile regions");
        }

        std::unique_ptr<rcContourSet, RecastDeleter> contours(rcAllocContourSet());
        if (!contours || !rcBuildContours(&context, *compact, config.maxSimplificationError,
                                           config.maxEdgeLen, *contours)) {
            throw std::runtime_error("could not build tile contours");
        }
        if (contours->nconts == 0) {
            return {nullptr, 0};
        }
        std::unique_ptr<rcPolyMesh, RecastDeleter> poly_mesh(rcAllocPolyMesh());
        if (!poly_mesh || !rcBuildPolyMesh(&context, *contours, config.maxVertsPerPoly, *poly_mesh)) {
            throw std::runtime_error("could not build tile polygon mesh");
        }
        std::unique_ptr<rcPolyMeshDetail, RecastDeleter> detail(rcAllocPolyMeshDetail());
        if (!detail || !rcBuildPolyMeshDetail(&context, *poly_mesh, *compact,
                                               config.detailSampleDist, config.detailSampleMaxError,
                                               *detail)) {
            throw std::runtime_error("could not build tile detail mesh");
        }
        for (int i = 0; i < poly_mesh->npolys; ++i) {
            if (poly_mesh->areas[i] == RC_WALKABLE_AREA) {
                poly_mesh->areas[i] = 0;
            }
            poly_mesh->flags[i] = WALK_FLAG;
        }

        dtNavMeshCreateParams params{};
        params.verts = poly_mesh->verts;
        params.vertCount = poly_mesh->nverts;
        params.polys = poly_mesh->polys;
        params.polyAreas = poly_mesh->areas;
        params.polyFlags = poly_mesh->flags;
        params.polyCount = poly_mesh->npolys;
        params.nvp = poly_mesh->nvp;
        params.detailMeshes = detail->meshes;
        params.detailVerts = detail->verts;
        params.detailVertsCount = detail->nverts;
        params.detailTris = detail->tris;
        params.detailTriCount = detail->ntris;
        params.walkableHeight = agent_height;
        params.walkableRadius = agent_radius;
        params.walkableClimb = agent_max_climb;
        params.tileX = tile_x;
        params.tileY = tile_y;
        params.tileLayer = 0;
        rcVcopy(params.bmin, poly_mesh->bmin);
        rcVcopy(params.bmax, poly_mesh->bmax);
        params.cs = config.cs;
        params.ch = config.ch;
        params.buildBvTree = true;

        unsigned char* data = nullptr;
        int data_size = 0;
        if (!dtCreateNavMeshData(&params, &data, &data_size)) {
            throw std::runtime_error("could not create Detour tile data");
        }
        return {data, data_size};
    }

    NavPtr mesh_;
    QueryPtr query_;
};
}  // namespace

PYBIND11_MODULE(recast_native, module) {
    module.doc() = "Tiled Recast/Detour navmesh build, persistence, and path queries";
    py::class_<NavMesh>(module, "NavMesh")
        .def_static("build", &NavMesh::build_arrays,
                    py::arg("vertices"), py::arg("triangles"),
                    py::arg("cell_size") = 0.3f,
                    py::arg("cell_height") = 0.2f,
                    py::arg("agent_height") = 2.0f,
                    py::arg("agent_radius") = 0.6f,
                    py::arg("agent_max_climb") = 0.9f,
                    py::arg("agent_max_slope") = 45.0f,
                    py::arg("tile_size") = 48)
        .def_static("load", &NavMesh::load, py::arg("path"))
        .def("save", &NavMesh::save, py::arg("path"))
        .def("sample_position", &NavMesh::sample_position, py::arg("point"))
        .def("line_of_sight", &NavMesh::line_of_sight, py::arg("start"), py::arg("end"))
        .def("find_path", &NavMesh::find_path, py::arg("start"), py::arg("end"))
        .def_property_readonly("tile_count", &NavMesh::tile_count);
}
