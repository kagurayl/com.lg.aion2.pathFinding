import unittest
from pathlib import Path
from tempfile import TemporaryDirectory

import numpy as np


class BuildCliTests(unittest.TestCase):
    def test_build_from_geometry_passes_arrays_and_saves_navmesh(self):
        from pathfinding.build_navmesh import build_from_geometry

        calls = {}

        class FakeMesh:
            tile_count = 7

            def save(self, path):
                Path(path).write_bytes(b"navmesh")

        class FakeNavMesh:
            @staticmethod
            def build(vertices, triangles, **settings):
                calls["vertices"] = np.asarray(vertices)
                calls["triangles"] = np.asarray(triangles)
                calls["settings"] = settings
                return FakeMesh()

        with TemporaryDirectory() as directory:
            root = Path(directory)
            geometry = root / "geometry.npz"
            output = root / "lf1.navmesh"
            np.savez(
                geometry,
                vertices=np.asarray([[0, 0, 0], [1, 0, 0], [0, 0, 1]], np.float32),
                triangles=np.asarray([[0, 2, 1]], np.int32),
            )
            result = build_from_geometry(
                geometry,
                output,
                navmesh_class=FakeNavMesh,
                settings={"cell_size": 0.5, "tile_size": 128},
            )
            self.assertEqual(result, {"tiles": 7, "output": str(output)})
            self.assertEqual(output.read_bytes(), b"navmesh")

        self.assertEqual(calls["vertices"].shape, (3, 3))
        self.assertEqual(calls["triangles"].shape, (1, 3))
        self.assertEqual(calls["settings"]["tile_size"], 128)


if __name__ == "__main__":
    unittest.main()
