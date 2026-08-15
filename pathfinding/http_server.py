from __future__ import annotations

import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Mapping, Protocol, Sequence


class Navigator(Protocol):
    def find_path(
        self, start: Sequence[float], target: Sequence[float]
    ) -> Sequence[Sequence[float]]: ...


def _point(value: object, field: str) -> tuple[float, float, float]:
    try:
        if isinstance(value, dict):
            result = float(value["x"]), float(value["y"]), float(value["z"])
        elif isinstance(value, (list, tuple)) and len(value) == 3:
            result = float(value[0]), float(value[1]), float(value[2])
        else:
            raise TypeError
        return result
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(
            f"{field} must be [x,y,z] or an object containing numeric x, y and z"
        ) from exc


def _handler(navigators: Mapping[str, Navigator]):
    class Handler(BaseHTTPRequestHandler):
        server_version = "AionPathFinding/0.1"

        def log_message(self, format: str, *args: object) -> None:
            return

        def _send(self, status: int, body: object) -> None:
            payload = json.dumps(body, ensure_ascii=False, separators=(",", ":")).encode(
                "utf-8"
            )
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Content-Length", str(len(payload)))
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(payload)

        def do_OPTIONS(self) -> None:
            self.send_response(204)
            self.send_header("Access-Control-Allow-Origin", "*")
            self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            self.send_header("Access-Control-Allow-Headers", "Content-Type")
            self.send_header("Access-Control-Max-Age", "86400")
            self.end_headers()

        def do_GET(self) -> None:
            if self.path == "/health":
                self._send(200, {"status": "ok", "maps": sorted(navigators)})
            else:
                self._send(404, {"success": False, "error": "not found"})

        def do_POST(self) -> None:
            if self.path != "/path":
                self._send(404, {"success": False, "error": "not found"})
                return
            try:
                length = int(self.headers.get("Content-Length", "0"))
                if length <= 0 or length > 1_048_576:
                    raise ValueError("invalid request size")
                request = json.loads(self.rfile.read(length))
                map_name = str(request["map"])
                navigator = navigators.get(map_name)
                if navigator is None:
                    self._send(
                        404,
                        {"success": False, "error": f"map not loaded: {map_name}"},
                    )
                    return
                start = _point(request.get("start"), "start")
                target = _point(request.get("target"), "target")
                points = navigator.find_path(start, target)
                waypoints = [
                    {"x": float(p[0]), "y": float(p[1]), "z": float(p[2])}
                    for p in points
                ]
                path = [[point["x"], point["y"], point["z"]] for point in waypoints]
                self._send(
                    200,
                    {
                        "success": bool(waypoints),
                        "map": map_name,
                        "start": list(start),
                        "target": list(target),
                        "path": path,
                        "waypoints": waypoints,
                    },
                )
            except (KeyError, TypeError, ValueError, json.JSONDecodeError) as exc:
                self._send(400, {"success": False, "error": str(exc)})
            except Exception as exc:
                self._send(500, {"success": False, "error": str(exc)})

    return Handler


def create_server(
    host: str, port: int, navigators: Mapping[str, Navigator]
) -> ThreadingHTTPServer:
    return ThreadingHTTPServer((host, port), _handler(navigators))
