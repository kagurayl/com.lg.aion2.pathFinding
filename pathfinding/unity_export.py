"""Export Unity collider geometry while preserving Unity world XYZ coordinates.

The NPZ format contains ``vertices`` (float32 Nx3), ``triangles`` (uint32 Mx3),
and ``triangle_sources`` (uint8 M; 1 terrain, 2 mesh, 3 box). A JSON sidecar
records provenance, bounds, counts, skips, and per-collider errors.
"""

from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import time
from typing import Any

import numpy as np

SOURCE_TERRAIN = 1
SOURCE_MESH = 2
SOURCE_BOX = 3


def _xyz(value) -> np.ndarray:
    if hasattr(value, "x"):
        return np.array((value.x, value.y, value.z), dtype=np.float64)
    return np.asarray(value, dtype=np.float64)


def _object_key(value) -> tuple[str, int] | int | None:
    reader = getattr(value, "object_reader", None)
    if reader is not None:
        return (reader.assets_file.name, reader.path_id)
    return getattr(value, "path_id", None)


def local_matrix(transform) -> np.ndarray:
    """Return Unity's column-vector TRS matrix for a serialized Transform."""
    position = _xyz(transform.m_LocalPosition)
    scale = _xyz(transform.m_LocalScale)
    rotation = transform.m_LocalRotation
    x, y, z, w = (rotation.x, rotation.y, rotation.z, rotation.w)
    length = np.sqrt(x * x + y * y + z * z + w * w)
    if length:
        x, y, z, w = x / length, y / length, z / length, w / length
    matrix = np.array(
        [
            [1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w), position[0]],
            [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w), position[1]],
            [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y), position[2]],
            [0, 0, 0, 1],
        ],
        dtype=np.float64,
    )
    matrix[:3, :3] *= scale  # R @ diag(scale)
    return matrix


def world_matrix(transform, cache: dict | None = None) -> np.ndarray:
    """Compose a Transform's complete parent hierarchy into a world matrix."""
    cache = {} if cache is None else cache
    key = _object_key(transform)
    if key is not None and key in cache:
        return cache[key]
    matrix = local_matrix(transform)
    father = transform.m_Father
    if getattr(father, "m_PathID", getattr(father, "path_id", 0)):
        matrix = world_matrix(father.read(), cache) @ matrix
    if key is not None:
        cache[key] = matrix
    return matrix


def transform_points(points, matrix) -> np.ndarray:
    """Apply a 4x4 world matrix to Nx3 points."""
    points = np.asarray(points, dtype=np.float64)
    homogeneous = np.column_stack((points, np.ones(len(points), dtype=np.float64)))
    return (np.asarray(matrix) @ homogeneous.T).T[:, :3]


def _preserve_winding(triangles: np.ndarray, matrix: np.ndarray) -> np.ndarray:
    if np.linalg.det(np.asarray(matrix)[:3, :3]) < 0:
        triangles = triangles.copy()
        triangles[:, [1, 2]] = triangles[:, [2, 1]]
    return triangles


def box_geometry(center, size, matrix) -> tuple[np.ndarray, np.ndarray]:
    """Triangulate a Unity BoxCollider and transform it to world space."""
    center = _xyz(center)
    half = _xyz(size) * 0.5
    signs = np.array(
        [
            [-1, -1, -1], [1, -1, -1], [1, 1, -1], [-1, 1, -1],
            [-1, -1, 1], [1, -1, 1], [1, 1, 1], [-1, 1, 1],
        ],
        dtype=np.float64,
    )
    vertices = transform_points(center + signs * half, matrix)
    triangles = np.array(
        [
            [0, 2, 1], [0, 3, 2], [4, 5, 6], [4, 6, 7],
            [0, 1, 5], [0, 5, 4], [3, 7, 6], [3, 6, 2],
            [0, 4, 7], [0, 7, 3], [1, 2, 6], [1, 6, 5],
        ],
        dtype=np.uint32,
    )
    return vertices, _preserve_winding(triangles, matrix)


def terrain_geometry(heights, resolution, scale, matrix, holes=None, step: int = 1):
    """Triangulate a Unity TerrainData heightmap, excluding hole cells."""
    if step < 1 or (resolution - 1) % step:
        raise ValueError("step must be a positive divisor of resolution - 1")
    heights = np.asarray(heights, dtype=np.float64).reshape(resolution, resolution)
    scale = _xyz(scale)
    samples = np.arange(0, resolution, step, dtype=np.int64)
    rows, columns = np.meshgrid(samples, samples, indexing="ij")
    local = np.column_stack(
        (
            columns.ravel() * scale[0],
            heights[rows, columns].ravel() * (scale[1] / 32767.0),
            rows.ravel() * scale[2],
        )
    )
    vertices = transform_points(local, matrix)

    width = len(samples)
    cell_rows, cell_columns = np.meshgrid(
        np.arange(width - 1, dtype=np.uint32),
        np.arange(width - 1, dtype=np.uint32),
        indexing="ij",
    )
    a = (cell_rows * width + cell_columns).ravel()
    b, c, d = a + 1, a + width, a + width + 1
    triangles = np.column_stack((a, d, b, a, c, d)).reshape(-1, 3)
    if holes is not None:
        solid = np.asarray(holes, dtype=np.uint8).reshape(resolution - 1, resolution - 1) != 0
        if step > 1:
            solid = solid.reshape(width - 1, step, width - 1, step).all(axis=(1, 3))
        triangles = triangles[np.repeat(solid.ravel(), 2)]
    triangles = triangles.astype(np.uint32, copy=False)
    return vertices, _preserve_winding(triangles, matrix)


def deduplicate_geometry(vertices, triangles, tolerance: float = 1e-5):
    """Merge near-equal vertices and reindex triangles deterministically."""
    if tolerance <= 0:
        raise ValueError("tolerance must be positive")
    vertices = np.asarray(vertices)
    triangles = np.asarray(triangles)
    if not len(vertices):
        return vertices.astype(np.float32), triangles.astype(np.uint32)
    quantized = np.rint(vertices / tolerance).astype(np.int64)
    _, first, inverse = np.unique(quantized, axis=0, return_index=True, return_inverse=True)
    order = np.argsort(first)
    remap = np.empty(len(order), dtype=np.uint32)
    remap[order] = np.arange(len(order), dtype=np.uint32)
    return vertices[first[order]].astype(np.float32), remap[inverse][triangles].astype(np.uint32)


def write_geometry(output, vertices, triangles, triangle_sources, metadata: dict[str, Any]) -> Path:
    """Write compressed typed arrays and a readable JSON sidecar."""
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    vertices = np.asarray(vertices, dtype=np.float32)
    triangles = np.asarray(triangles, dtype=np.uint32)
    triangle_sources = np.asarray(triangle_sources, dtype=np.uint8)
    if len(triangles) != len(triangle_sources):
        raise ValueError("triangle_sources must contain one value per triangle")
    np.savez_compressed(
        output,
        vertices=vertices,
        triangles=triangles,
        triangle_sources=triangle_sources,
    )
    metadata = dict(metadata)
    metadata.update(
        {
            "format": "unity-collision-npz-v1",
            "coordinate_system": "Unity world XYZ (Y up, left-handed)",
            "vertex_count": int(len(vertices)),
            "triangle_count": int(len(triangles)),
            "bounds_min": vertices.min(axis=0).tolist() if len(vertices) else None,
            "bounds_max": vertices.max(axis=0).tolist() if len(vertices) else None,
            "arrays": {
                "vertices": "float32[N,3]",
                "triangles": "uint32[M,3]",
                "triangle_sources": "uint8[M] (1=terrain, 2=mesh, 3=box)",
            },
        }
    )
    metadata_path = output.with_suffix(".json")
    with metadata_path.open("w", encoding="utf-8") as stream:
        json.dump(metadata, stream, indent=2, sort_keys=True)
        stream.write("\n")
    return metadata_path


def _find_transform(component) -> Any:
    game_object = component.m_GameObject.read()
    for item in game_object.m_Component:
        reader = item.component.deref()
        if reader.type.name == "Transform":
            return reader.read()
    raise ValueError(f"GameObject {game_object.m_Name!r} has no Transform")


def _file_sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def inventory_scene(scene_path) -> dict[str, Any]:
    """Load a Unity scene bundle and return collider/object inventory without meshing."""
    import UnityPy

    started = time.perf_counter()
    scene_path = Path(scene_path)
    environment = UnityPy.load(str(scene_path))
    object_counts = Counter(obj.type.name for obj in environment.objects)
    collider_state: dict[str, Counter] = {
        name: Counter() for name in ("TerrainCollider", "MeshCollider", "BoxCollider")
    }
    errors: list[dict[str, Any]] = []
    for obj in environment.objects:
        if obj.type.name not in collider_state:
            continue
        state = collider_state[obj.type.name]
        state["total"] += 1
        try:
            collider = obj.read()
            state["enabled" if getattr(collider, "m_Enabled", True) else "disabled"] += 1
            state["trigger" if getattr(collider, "m_IsTrigger", False) else "non_trigger"] += 1
            pointer = getattr(collider, "m_Mesh", None) or getattr(collider, "m_TerrainData", None)
            if pointer is not None:
                state["asset_present" if bool(pointer) else "asset_null"] += 1
        except Exception as exc:
            state["errors"] += 1
            errors.append({"type": obj.type.name, "path_id": obj.path_id, "error": repr(exc)})
    return {
        "source": str(scene_path.resolve()),
        "source_size": scene_path.stat().st_size,
        "object_counts": dict(sorted(object_counts.items())),
        "colliders": {key: dict(value) for key, value in collider_state.items()},
        "errors": errors,
        "inventory_seconds": time.perf_counter() - started,
    }


def export_scene(
    scene_path,
    output,
    *,
    include_triggers: bool = False,
    terrain_step: int = 1,
    max_colliders: int | None = None,
    dedupe_tolerance: float = 1e-5,
) -> dict[str, Any]:
    """Extract enabled collider geometry from a Unity scene bundle into NPZ."""
    import UnityPy
    from UnityPy.helpers.MeshHelper import MeshHandler

    started = time.perf_counter()
    scene_path, output = Path(scene_path), Path(output)
    environment = UnityPy.load(str(scene_path))
    object_counts = Counter(obj.type.name for obj in environment.objects)
    transform_cache: dict[Any, np.ndarray] = {}
    mesh_cache: dict[Any, tuple[np.ndarray, np.ndarray]] = {}
    vertices_parts: list[np.ndarray] = []
    triangle_parts: list[np.ndarray] = []
    source_parts: list[np.ndarray] = []
    exported = Counter()
    skipped = Counter()
    errors: list[dict[str, Any]] = []
    accepted = 0
    vertex_offset = 0

    def append_geometry(vertices, triangles, source: int) -> None:
        nonlocal vertex_offset
        vertices = np.asarray(vertices, dtype=np.float32)
        triangles = np.asarray(triangles, dtype=np.uint32)
        if not len(vertices) or not len(triangles):
            raise ValueError("collider produced empty geometry")
        vertices_parts.append(vertices)
        triangle_parts.append(triangles + vertex_offset)
        source_parts.append(np.full(len(triangles), source, dtype=np.uint8))
        vertex_offset += len(vertices)

    for obj in environment.objects:
        collider_type = obj.type.name
        if collider_type not in ("TerrainCollider", "MeshCollider", "BoxCollider"):
            continue
        if max_colliders is not None and accepted >= max_colliders:
            skipped["max_colliders"] += 1
            continue
        try:
            collider = obj.read()
            if not getattr(collider, "m_Enabled", True):
                skipped[f"{collider_type}:disabled"] += 1
                continue
            if getattr(collider, "m_IsTrigger", False) and not include_triggers:
                skipped[f"{collider_type}:trigger"] += 1
                continue
            transform = _find_transform(collider)
            matrix = world_matrix(transform, transform_cache)

            if collider_type == "BoxCollider":
                vertices, triangles = box_geometry(collider.m_Center, collider.m_Size, matrix)
                append_geometry(vertices, triangles, SOURCE_BOX)
            elif collider_type == "TerrainCollider":
                if not collider.m_TerrainData:
                    raise ValueError("null TerrainData pointer")
                terrain = collider.m_TerrainData.read()
                heightmap = terrain.m_Heightmap
                vertices, triangles = terrain_geometry(
                    heightmap.m_Heights,
                    heightmap.m_Resolution,
                    heightmap.m_Scale,
                    matrix,
                    heightmap.m_Holes,
                    terrain_step,
                )
                append_geometry(vertices, triangles, SOURCE_TERRAIN)
            else:
                if not collider.m_Mesh:
                    raise ValueError("null shared mesh pointer")
                mesh_reader = collider.m_Mesh.deref()
                key = (mesh_reader.assets_file.name, mesh_reader.path_id)
                if key not in mesh_cache:
                    mesh = mesh_reader.read()
                    handler = MeshHandler(mesh)
                    handler.process()
                    if not handler.m_Vertices:
                        raise ValueError(f"mesh {mesh.m_Name!r} has no decoded vertices")
                    submeshes = handler.get_triangles()
                    triangles = np.asarray(
                        [triangle for group in submeshes for triangle in group], dtype=np.uint32
                    )
                    local_vertices, triangles = deduplicate_geometry(
                        handler.m_Vertices, triangles, dedupe_tolerance
                    )
                    mesh_cache[key] = local_vertices, triangles
                local_vertices, triangles = mesh_cache[key]
                vertices = transform_points(local_vertices, matrix)
                append_geometry(vertices, _preserve_winding(triangles, matrix), SOURCE_MESH)
            exported[collider_type] += 1
            accepted += 1
        except Exception as exc:
            errors.append(
                {
                    "type": collider_type,
                    "path_id": obj.path_id,
                    "assets_file": obj.assets_file.name,
                    "error": f"{type(exc).__name__}: {exc}",
                }
            )
            skipped[f"{collider_type}:error"] += 1

    vertices = np.concatenate(vertices_parts) if vertices_parts else np.empty((0, 3), np.float32)
    triangles = np.concatenate(triangle_parts) if triangle_parts else np.empty((0, 3), np.uint32)
    sources = np.concatenate(source_parts) if source_parts else np.empty((0,), np.uint8)
    metadata = {
        "source": str(scene_path.resolve()),
        "source_size": scene_path.stat().st_size,
        "source_sha256": _file_sha256(scene_path),
        "object_counts": dict(sorted(object_counts.items())),
        "exported_colliders": dict(exported),
        "skipped_colliders": dict(skipped),
        "unique_mesh_assets": len(mesh_cache),
        "deduplication": f"per-mesh quantized at {dedupe_tolerance:g}; indexed terrain/boxes retained",
        "include_triggers": include_triggers,
        "terrain_step": terrain_step,
        "max_colliders": max_colliders,
        "errors": errors,
        "geometry_seconds": time.perf_counter() - started,
    }
    metadata_path = write_geometry(output, vertices, triangles, sources, metadata)
    metadata.update(
        {
            "output": str(output.resolve()),
            "metadata": str(metadata_path.resolve()),
            "vertex_count": int(len(vertices)),
            "triangle_count": int(len(triangles)),
            "total_seconds": time.perf_counter() - started,
        }
    )
    return metadata


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("scene", type=Path)
    parser.add_argument("output", nargs="?", type=Path)
    parser.add_argument("--inventory", action="store_true", help="count objects/colliders only")
    parser.add_argument("--include-triggers", action="store_true")
    parser.add_argument("--terrain-step", type=int, default=1)
    parser.add_argument("--max-colliders", type=int)
    parser.add_argument("--dedupe-tolerance", type=float, default=1e-5)
    args = parser.parse_args(argv)
    if args.inventory:
        result = inventory_scene(args.scene)
    else:
        if args.output is None:
            parser.error("output is required unless --inventory is used")
        result = export_scene(
            args.scene,
            args.output,
            include_triggers=args.include_triggers,
            terrain_step=args.terrain_step,
            max_colliders=args.max_colliders,
            dedupe_tolerance=args.dedupe_tolerance,
        )
    print(json.dumps(result, indent=2, sort_keys=True))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
