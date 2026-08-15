from __future__ import annotations

from pathlib import Path
import math
import threading
from typing import Callable, Sequence


def densify_path(
    points: Sequence[Sequence[float]], spacing: float = 1.8
) -> list[list[float]]:
    if spacing <= 0:
        raise ValueError("spacing must be positive")
    if not points:
        return []
    result = [[float(value) for value in points[0]]]
    for endpoint_value in points[1:]:
        start = result[-1]
        endpoint = [float(value) for value in endpoint_value]
        distance = math.dist(start, endpoint)
        offset = spacing
        while offset < distance:
            ratio = offset / distance
            result.append(
                [start[axis] + (endpoint[axis] - start[axis]) * ratio for axis in range(3)]
            )
            offset += spacing
        if endpoint != result[-1]:
            result.append(endpoint)
    return result


class RecastNavigator:
    def __init__(self, navmesh: object):
        self._navmesh = navmesh
        self._query_lock = threading.Lock()

    @classmethod
    def load(cls, path: str | Path) -> "RecastNavigator":
        try:
            from . import recast_native
        except ImportError:
            import recast_native

        return cls(recast_native.NavMesh.load(str(path)))

    def find_path(
        self, start: Sequence[float], target: Sequence[float]
    ) -> list[list[float]]:
        # dtNavMesh is immutable here, but one dtNavMeshQuery instance owns scratch state.
        with self._query_lock:
            points = self._navmesh.find_path(tuple(start), tuple(target))
            dense = densify_path(points)
            return [
                [float(value) for value in self._navmesh.sample_position(tuple(point))]
                for point in dense
            ]


def load_map_directory(
    directory: str | Path,
    loader: Callable[[str | Path], object] = RecastNavigator.load,
) -> dict[str, object]:
    root = Path(directory)
    if not root.is_dir():
        raise FileNotFoundError(f"map directory does not exist: {root}")
    return {path.stem: loader(path) for path in sorted(root.glob("*.navmesh"))}
