#!/usr/bin/env python
"""Rebuild an SCP library archive from an extracted directory and manifest."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path, PurePosixPath

import lz4.block


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    names = [item["path"] for item in manifest]
    encoded_names = [name.encode("utf-8") for name in names]
    contents: list[bytes] = []
    for name in names:
        path = args.source.joinpath(*PurePosixPath(name).parts)
        contents.append(path.read_bytes())

    header_size = 4 + sum(8 + len(name) + 1 for name in encoded_names)
    cursor = header_size
    header = bytearray(struct.pack("<I", len(names)))
    for name, content in zip(encoded_names, contents):
        header.extend(struct.pack("<II", cursor, len(content)))
        header.extend(name)
        header.append(0)
        cursor += len(content)

    unpacked = bytes(header) + b"".join(contents)
    packed = struct.pack("<I", len(unpacked)) + lz4.block.compress(
        unpacked,
        mode="high_compression",
        compression=12,
        store_size=False,
    )
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(packed)
    print(f"Packed {len(contents)} files: {len(unpacked)} -> {len(packed)} bytes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
