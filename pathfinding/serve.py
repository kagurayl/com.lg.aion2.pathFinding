from __future__ import annotations

import argparse
from pathlib import Path

from .http_server import create_server
from .runtime import load_map_directory


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Aion Detour HTTP path service")
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", default=18766, type=int)
    parser.add_argument("--maps", default=Path("maps"), type=Path)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    navigators = load_map_directory(args.maps)
    if not navigators:
        raise SystemExit(f"no .navmesh files found in {args.maps}")
    server = create_server(args.host, args.port, navigators)
    print(
        f"Aion path service listening on http://{args.host}:{args.port}; "
        f"maps={','.join(sorted(navigators))}",
        flush=True,
    )
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
