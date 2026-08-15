import json
import math
import threading
from urllib.request import Request, urlopen

import recast_native

from pathfinding.http_server import create_server
from pathfinding.runtime import RecastNavigator


def _ring_geometry():
    vertices = [
        (-6.0, 0.0, -6.0), (6.0, 0.0, -6.0),
        (6.0, 0.0, 6.0), (-6.0, 0.0, 6.0),
        (-2.0, 0.0, -2.0), (2.0, 0.0, -2.0),
        (2.0, 0.0, 2.0), (-2.0, 0.0, 2.0),
    ]
    triangles = [
        (0, 5, 1), (0, 4, 5), (1, 6, 2), (1, 5, 6),
        (2, 7, 3), (2, 6, 7), (3, 4, 0), (3, 7, 4),
    ]
    return vertices, triangles


def test_real_http_request_returns_detour_around_static_obstacle():
    vertices, triangles = _ring_geometry()
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
    server = create_server("127.0.0.1", 0, {"fixture": RecastNavigator(navmesh)})
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    try:
        body = json.dumps(
            {"map": "fixture", "start": [-5.0, 0.0, 0.0], "target": [5.0, 0.0, 0.0]}
        ).encode("utf-8")
        request = Request(
            f"http://127.0.0.1:{server.server_port}/path",
            data=body,
            method="POST",
            headers={"Content-Type": "application/json"},
        )
        with urlopen(request, timeout=5) as response:
            payload = json.load(response)
    finally:
        server.shutdown()
        thread.join(timeout=5)
        server.server_close()

    path = payload["path"]
    assert payload["success"] is True
    assert len(path) >= 3
    assert any(abs(point[2]) > 2.0 for point in path[1:-1])
    assert math.dist(path[0], [-5.0, 0.0, 0.0]) < 0.6
    assert math.dist(path[-1], [5.0, 0.0, 0.0]) < 0.6
