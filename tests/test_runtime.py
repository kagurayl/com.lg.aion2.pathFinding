import unittest
from pathlib import Path
from tempfile import TemporaryDirectory


class RuntimeRegistryTests(unittest.TestCase):
    def test_load_map_directory_uses_navmesh_filename_as_map_name(self):
        from pathfinding.runtime import load_map_directory

        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "lf1.navmesh").write_bytes(b"test")
            (root / "ignored.txt").write_text("ignored", encoding="utf-8")
            loaded_paths = []

            def loader(path):
                loaded_paths.append(Path(path))
                return f"navigator:{Path(path).stem}"

            maps = load_map_directory(root, loader=loader)

        self.assertEqual(maps, {"lf1": "navigator:lf1"})
        self.assertEqual([path.name for path in loaded_paths], ["lf1.navmesh"])


if __name__ == "__main__":
    unittest.main()
