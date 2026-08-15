from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Mapping

import numpy as np


DEFAULT_SETTINGS = {
    "cell_size": 0.5,
    "cell_height": 0.2,
    "agent_height": 1.8,
    "agent_radius": 0.45,
    "agent_max_climb": 0.6,
    "agent_max_slope": 45.0,
    "tile_size": 128,
}


def build_from_geometry(
    geometry_path: str | Path,
    output_path: str | Path,
    *,
    navmesh_class=None,
    settings: Mapping[str, float | int] | None = None,
) -> dict[str, object]:
    if navmesh_class is None:
        try:
            from . import recast_native
        except ImportError:
            import recast_native

        navmesh_class = recast_native.NavMesh
    values = dict(DEFAULT_SETTINGS)
    if settings:
        values.update(settings)
    with np.load(geometry_path, allow_pickle=False) as geometry:
        vertices = np.ascontiguousarray(geometry["vertices"], dtype=np.float32)
        triangles = np.ascontiguousarray(geometry["triangles"], dtype=np.int32)
    if vertices.ndim != 2 or vertices.shape[1] != 3:
        raise ValueError("vertices must have shape (N, 3)")
    if triangles.ndim != 2 or triangles.shape[1] != 3:
        raise ValueError("triangles must have shape (N, 3)")
    navmesh = navmesh_class.build(vertices, triangles, **values)
    output = Path(output_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    navmesh.save(str(output))
    return {"tiles": int(navmesh.tile_count), "output": str(output)}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Build a tiled Detour navmesh")
    parser.add_argument("geometry", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--cell-size", type=float, default=DEFAULT_SETTINGS["cell_size"])
    parser.add_argument("--cell-height", type=float, default=DEFAULT_SETTINGS["cell_height"])
    parser.add_argument("--agent-height", type=float, default=DEFAULT_SETTINGS["agent_height"])
    parser.add_argument("--agent-radius", type=float, default=DEFAULT_SETTINGS["agent_radius"])
    parser.add_argument("--agent-max-climb", type=float, default=DEFAULT_SETTINGS["agent_max_climb"])
    parser.add_argument("--agent-max-slope", type=float, default=DEFAULT_SETTINGS["agent_max_slope"])
    parser.add_argument("--tile-size", type=int, default=DEFAULT_SETTINGS["tile_size"])
    return parser


def main() -> None:
    args = build_parser().parse_args()
    result = build_from_geometry(
        args.geometry,
        args.output,
        settings={
            "cell_size": args.cell_size,
            "cell_height": args.cell_height,
            "agent_height": args.agent_height,
            "agent_radius": args.agent_radius,
            "agent_max_climb": args.agent_max_climb,
            "agent_max_slope": args.agent_max_slope,
            "tile_size": args.tile_size,
        },
    )
    print(json.dumps(result, ensure_ascii=False))


if __name__ == "__main__":
    main()
