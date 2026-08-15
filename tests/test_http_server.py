import json
import threading
import unittest
from urllib.error import HTTPError
from urllib.request import Request, urlopen


class FakeNavigator:
    def find_path(self, start, target):
        return [list(start), [5.0, 1.0, 5.0], list(target)]


class HttpServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        from pathfinding.http_server import create_server

        cls.server = create_server("127.0.0.1", 0, {"lf1": FakeNavigator()})
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = f"http://127.0.0.1:{cls.server.server_address[1]}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=5)

    def post(self, path, body):
        request = Request(
            self.url + path,
            data=json.dumps(body).encode("utf-8"),
            headers={"Content-Type": "application/json"},
            method="POST",
        )
        with urlopen(request, timeout=5) as response:
            return response.status, json.loads(response.read())

    def test_path_endpoint_returns_world_xyz_waypoints(self):
        status, body = self.post(
            "/path",
            {
                "map": "lf1",
                "start": {"x": 1, "y": 2, "z": 3},
                "target": {"x": 8, "y": 2, "z": 9},
            },
        )
        self.assertEqual(status, 200)
        self.assertTrue(body["success"])
        self.assertEqual(body["map"], "lf1")
        self.assertEqual(body["waypoints"][1], {"x": 5.0, "y": 1.0, "z": 5.0})

    def test_unknown_map_returns_404(self):
        with self.assertRaises(HTTPError) as error:
            self.post(
                "/path",
                {
                    "map": "missing",
                    "start": {"x": 1, "y": 2, "z": 3},
                    "target": {"x": 8, "y": 2, "z": 9},
                },
            )
        self.assertEqual(error.exception.code, 404)

    def test_health_lists_loaded_maps(self):
        with urlopen(self.url + "/health", timeout=5) as response:
            body = json.loads(response.read())
            self.assertEqual(response.headers["Access-Control-Allow-Origin"], "*")
        self.assertEqual(body, {"status": "ok", "maps": ["lf1"]})

    def test_cors_preflight_allows_browser_post(self):
        request = Request(self.url + "/path", method="OPTIONS")
        with urlopen(request, timeout=5) as response:
            self.assertEqual(response.status, 204)
            self.assertIn("POST", response.headers["Access-Control-Allow-Methods"])
            self.assertEqual(response.headers["Access-Control-Allow-Origin"], "*")


if __name__ == "__main__":
    unittest.main()
