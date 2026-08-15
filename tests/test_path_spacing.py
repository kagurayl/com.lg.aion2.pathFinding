import math

from pathfinding.runtime import densify_path


def test_densify_path_limits_world_xyz_segment_length():
    path = densify_path([[0, 0, 0], [5, 0, 0], [5, 0, 1]], spacing=2.0)

    assert path[0] == [0.0, 0.0, 0.0]
    assert path[-1] == [5.0, 0.0, 1.0]
    assert all(math.dist(a, b) <= 2.000001 for a, b in zip(path, path[1:]))
    assert path == [[0, 0, 0], [2, 0, 0], [4, 0, 0], [5, 0, 0], [5, 0, 1]]
