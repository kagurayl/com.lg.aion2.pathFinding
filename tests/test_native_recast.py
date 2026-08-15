import math

import numpy as np
import pytest

import recast_native


def obstacle_ring_mesh():
    """A 12x12 walkable floor with a 4x4 square hole in its centre."""
    vertices = [
        (-6.0, 0.0, -6.0),
        (6.0, 0.0, -6.0),
        (6.0, 0.0, 6.0),
        (-6.0, 0.0, 6.0),
        (-2.0, 0.0, -2.0),
        (2.0, 0.0, -2.0),
        (2.0, 0.0, 2.0),
        (-2.0, 0.0, 2.0),
    ]
    # Clockwise when viewed from above, which gives Recast an upward normal.
    triangles = [
        (0, 5, 1), (0, 4, 5),
        (1, 6, 2), (1, 5, 6),
        (2, 7, 3), (2, 6, 7),
        (3, 4, 0), (3, 7, 4),
    ]
    return vertices, triangles


def test_build_accepts_contiguous_numpy_arrays():
    vertices, triangles = obstacle_ring_mesh()
    navmesh = recast_native.NavMesh.build(
        np.asarray(vertices, dtype=np.float32),
        np.asarray(triangles, dtype=np.int32),
        cell_size=0.25,
        cell_height=0.2,
        agent_height=1.8,
        agent_radius=0.35,
        agent_max_climb=0.4,
        agent_max_slope=45.0,
        tile_size=16,
    )
    assert navmesh.tile_count >= 4
    projected = navmesh.sample_position((-5.0, 3.0, 0.0))
    assert projected == pytest.approx((-5.0, 0.2, 0.0), abs=0.3)



def test_tiled_build_save_load_and_path_around_obstacle(tmp_path):
    vertices, triangles = obstacle_ring_mesh()
    navmesh = recast_native.NavMesh.build(
        vertices,
        triangles,
        cell_size=0.25,
        cell_height=0.2,
        agent_height=1.8,
        agent_radius=0.35,
        agent_max_climb=0.4,
        agent_max_slope=45.0,
        tile_size=16,
    )

    assert navmesh.tile_count >= 4
    path = navmesh.find_path((-5.0, 0.0, 0.0), (5.0, 0.0, 0.0))
    assert navmesh.line_of_sight((-5.0, 0.0, 0.0), (5.0, 0.0, 0.0)) is False
    assert all(navmesh.line_of_sight(a, b) for a, b in zip(path, path[1:]))
    assert len(path) >= 3
    assert math.dist(path[0], (-5.0, 0.0, 0.0)) < 0.6
    assert math.dist(path[-1], (5.0, 0.0, 0.0)) < 0.6
    assert any(abs(point[2]) > 2.0 for point in path[1:-1])

    output = tmp_path / "obstacle.navmesh"
    navmesh.save(output)
    assert output.stat().st_size > 0

    loaded = recast_native.NavMesh.load(output)
    assert loaded.tile_count == navmesh.tile_count
    loaded_path = loaded.find_path((-5.0, 0.0, 0.0), (5.0, 0.0, 0.0))
    assert len(loaded_path) == len(path)
    for loaded_point, original_point in zip(loaded_path, path):
        assert loaded_point == pytest.approx(original_point, abs=1e-5)



def test_disconnected_polygons_report_no_complete_path():
    vertices = [
        (-6, 0, -2), (-2, 0, -2), (-2, 0, 2), (-6, 0, 2),
        (2, 0, -2), (6, 0, -2), (6, 0, 2), (2, 0, 2),
    ]
    triangles = [(0, 2, 1), (0, 3, 2), (4, 6, 5), (4, 7, 6)]
    navmesh = recast_native.NavMesh.build(
        vertices, triangles, cell_size=0.25, cell_height=0.2,
        agent_height=1.8, agent_radius=0.35, agent_max_climb=0.4,
        agent_max_slope=45.0, tile_size=16,
    )
    with pytest.raises(RuntimeError, match="no complete path"):
        navmesh.find_path((-5, 0, 0), (5, 0, 0))
