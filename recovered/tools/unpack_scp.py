#!/usr/bin/env python
"""Extract the game's LZ4-packed SCP library archive."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
import struct
from dataclasses import dataclass
from pathlib import Path, PurePosixPath

import lz4.block


@dataclass(frozen=True)
class Entry:
    offset: int
    size: int
    name: str


def read_u32(data: bytes, offset: int) -> tuple[int, int]:
    if offset + 4 > len(data):
        raise ValueError(f"truncated uint32 at 0x{offset:x}")
    return struct.unpack_from("<I", data, offset)[0], offset + 4


def read_c_string(data: bytes, offset: int) -> tuple[str, int]:
    try:
        end = data.index(0, offset)
    except ValueError as exc:
        raise ValueError(f"unterminated entry name at 0x{offset:x}") from exc
    return data[offset:end].decode("utf-8"), end + 1


def decompress_scp(path: Path) -> bytes:
    packed = path.read_bytes()
    if len(packed) < 5:
        raise ValueError("SCP file is too small")

    unpacked_size = struct.unpack_from("<I", packed, 0)[0]
    if not 0 < unpacked_size <= 2 * 1024 * 1024 * 1024:
        raise ValueError(f"invalid unpacked size: {unpacked_size}")

    unpacked = lz4.block.decompress(
        packed[4:],
        uncompressed_size=unpacked_size,
    )
    if len(unpacked) != unpacked_size:
        raise ValueError(
            f"LZ4 size mismatch: expected {unpacked_size}, got {len(unpacked)}"
        )
    return unpacked


def parse_library(data: bytes) -> list[Entry]:
    count, cursor = read_u32(data, 0)
    if not 0 < count <= 1_000_000:
        raise ValueError(f"invalid entry count: {count}")

    entries: list[Entry] = []
    seen: set[str] = set()
    for index in range(count):
        file_offset, cursor = read_u32(data, cursor)
        file_size, cursor = read_u32(data, cursor)
        name, cursor = read_c_string(data, cursor)

        path = PurePosixPath(name)
        if path.is_absolute() or ".." in path.parts or not path.parts:
            raise ValueError(f"unsafe path at entry {index}: {name!r}")
        if name in seen:
            raise ValueError(f"duplicate path at entry {index}: {name!r}")
        if file_offset + file_size > len(data):
            raise ValueError(
                f"entry {index} exceeds archive: {name!r} "
                f"offset={file_offset} size={file_size}"
            )

        seen.add(name)
        entries.append(Entry(file_offset, file_size, name))

    return entries


def extract(source: Path, output: Path, force: bool) -> list[dict[str, object]]:
    data = decompress_scp(source)
    entries = parse_library(data)

    if output.exists() and any(output.iterdir()):
        if not force:
            raise FileExistsError(
                f"output directory is not empty: {output} (use --force to replace it)"
            )
        shutil.rmtree(output)
    output.mkdir(parents=True, exist_ok=True)

    manifest: list[dict[str, object]] = []
    output_root = output.resolve()
    for entry in entries:
        relative = Path(*PurePosixPath(entry.name).parts)
        destination = (output / relative).resolve()
        if output_root not in destination.parents:
            raise ValueError(f"entry escaped output directory: {entry.name!r}")

        content = data[entry.offset : entry.offset + entry.size]
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
        manifest.append(
            {
                "path": entry.name,
                "offset": entry.offset,
                "size": entry.size,
                "sha256": hashlib.sha256(content).hexdigest(),
            }
        )

    return manifest


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="library.scp path")
    parser.add_argument("output", type=Path, help="extraction directory")
    parser.add_argument("--force", action="store_true", help="replace a non-empty output directory")
    parser.add_argument("--manifest", type=Path, help="optional JSON manifest path")
    args = parser.parse_args()

    manifest = extract(args.source, args.output, args.force)
    if args.manifest:
        args.manifest.parent.mkdir(parents=True, exist_ok=True)
        args.manifest.write_text(
            json.dumps(manifest, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    total_size = sum(int(item["size"]) for item in manifest)
    print(f"Extracted {len(manifest)} files ({total_size} bytes) to {args.output.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
