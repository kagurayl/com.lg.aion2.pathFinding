from types import SimpleNamespace

import numpy as np

from pathfinding.unity_export import (
    box_geometry,
    deduplicate_geometry,
    terrain_geometry,
    transform_points,
    world_matrix,
    write_geometry,
)


class Pointer:
    def __init__(self, value=None, path_id=0):
        self.value = value
        self.m_PathID = path_id

    def read(self):
        return self.value


def vector3(x, y, z):
    return SimpleNamespace(x=x, y=y, z=z)


def quaternion(x, y, z, w):
    return SimpleNamespace(x=x, y=y, z=z, w=w)


def transform(position, rotation, scale, parent=None, path_id=1):
    value = SimpleNamespace(
        m_LocalPosition=vector3(*position),
        m_LocalRotation=quaternion(*rotation),
        m_LocalScale=vector3(*scale),
        m_Father=Pointer(parent, getattr(parent, "path_id", 0)),
        path_id=path_id,
    )
    return value


def test_world_matrix_applies_parent_trs_in_unity_xyz():
    # Parent rotates +90 degrees around Y, then translates. Child translates and scales.
    root = transform((10, 0, 0), (0, 2**-0.5, 0, 2**-0.5), (2, 2, 2), path_id=10)
    child = transform((1, 0, 0), (0, 0, 0, 1), (1, 2, 1), parent=root, path_id=11)

    points = transform_points(np.array([[0, 0, 0], [1, 1, 0]], dtype=np.float64), world_matrix(child))

    np.testing.assert_allclose(points, [[10, 0, -2], [10, 4, -4]], atol=1e-6)


def test_box_geometry_uses_center_size_and_world_transform():
    matrix = np.eye(4)
    matrix[:3, 3] = (10, 20, 30)

    vertices, triangles = box_geometry(center=(1, 2, 3), size=(2, 4, 6), matrix=matrix)

    assert vertices.shape == (8, 3)
    assert triangles.shape == (12, 3)
    np.testing.assert_allclose(vertices.min(axis=0), [10, 20, 30])
    np.testing.assert_allclose(vertices.max(axis=0), [12, 24, 36])
    assert triangles.min() == 0
    assert triangles.max() == 7


def test_terrain_geometry_decodes_heights_and_omits_holes():
    # Unity 2022 serializes this terrain's heights as signed-15-bit fractions.
    heights = np.array(
        [0, 16384, 32767, 0, 0, 0, 32767, 16384, 0], dtype=np.uint16
    )
    holes = np.array([255, 0, 255, 255], dtype=np.uint8)

    vertices, triangles = terrain_geometry(
        heights=heights,
        resolution=3,
        scale=(2, 100, 3),
        matrix=np.eye(4),
        holes=holes,
    )

    assert vertices.shape == (9, 3)
    assert triangles.shape == (6, 3)  # Three solid cells, two triangles each.
    np.testing.assert_allclose(vertices[2], [4, 100, 0], atol=1e-3)
    assert not np.any(np.all(np.isin(triangles, [1, 2, 4, 5]), axis=1))


def test_deduplicate_geometry_reindexes_near_equal_vertices():
    vertices = np.array([[0, 0, 0], [1, 0, 0], [0.0000001, 0, 0]], dtype=float)
    triangles = np.array([[0, 1, 2]], dtype=np.uint32)

    unique, reindexed = deduplicate_geometry(vertices, triangles, tolerance=1e-5)

    assert unique.shape == (2, 3)
    np.testing.assert_array_equal(reindexed, [[0, 1, 0]])


def test_write_geometry_creates_typed_npz_and_json_metadata(tmp_path):
    output = tmp_path / "collision.npz"
    vertices = np.array([[1, 2, 3], [4, 5, 6]], dtype=float)
    triangles = np.array([[0, 1, 0]], dtype=int)
    sources = np.array([2], dtype=np.uint8)

    metadata_path = write_geometry(output, vertices, triangles, sources, {"map": "test"})

    with np.load(output) as archive:
        assert archive["vertices"].dtype == np.float32
        assert archive["triangles"].dtype == np.uint32
        np.testing.assert_array_equal(archive["triangle_sources"], sources)
    import json
    with open(metadata_path, encoding="utf-8") as stream:
        metadata = json.load(stream)
    assert metadata["map"] == "test"
    assert metadata["vertex_count"] == 2
    assert metadata["triangle_count"] == 1
