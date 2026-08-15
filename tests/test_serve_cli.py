import unittest


class ServeCliTests(unittest.TestCase):
    def test_parser_defaults_to_localhost_and_maps_directory(self):
        from pathfinding.serve import build_parser

        args = build_parser().parse_args([])
        self.assertEqual(args.host, "127.0.0.1")
        self.assertEqual(args.port, 18766)
        self.assertEqual(str(args.maps), "maps")


if __name__ == "__main__":
    unittest.main()
