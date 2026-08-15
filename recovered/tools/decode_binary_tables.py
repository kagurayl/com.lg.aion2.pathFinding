#!/usr/bin/env python
"""Convert recovered proprietary binary tables into readable UTF-8 TSV files."""
from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path
import struct

import lz4.block


def _read_7bit_string(data: bytes, offset: int) -> tuple[str, int]:
    length = 0
    shift = 0
    while True:
        value = data[offset]
        offset += 1
        length |= (value & 0x7F) << shift
        if not value & 0x80:
            break
        shift += 7
        if shift > 28:
            raise ValueError("invalid 7-bit string length")
    end = offset + length
    return data[offset:end].decode("utf-8"), end


def _decompress_sized_lz4(path: Path) -> bytes:
    packed = path.read_bytes()
    size = struct.unpack_from("<I", packed)[0]
    decoded = lz4.block.decompress(packed[4:], uncompressed_size=size)
    if len(decoded) != size:
        raise ValueError(f"LZ4 size mismatch for {path}: {len(decoded)} != {size}")
    return decoded


def parse_filelist(data: bytes) -> list[tuple[str, int, int, int]]:
    count = struct.unpack_from("<I", data)[0]
    offset = 4
    rows = []
    for _ in range(count):
        end = data.index(0, offset)
        name = data[offset:end].decode("utf-8")
        offset = end + 1
        xxh64, download_flag, size = struct.unpack_from("<Qii", data, offset)
        offset += 16
        rows.append((name, xxh64, download_flag, size))
    if offset != len(data):
        raise ValueError(f"filelist has {len(data) - offset} trailing bytes")
    return rows


def write_filelist(source: Path, destination: Path, compressed: bool) -> dict[str, int]:
    data = _decompress_sized_lz4(source) if compressed else source.read_bytes()
    rows = parse_filelist(data)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream, dialect="excel-tab", lineterminator="\n")
        writer.writerow(("path", "xxh64", "download_flag", "size_bytes"))
        for name, xxh64, flag, size in rows:
            writer.writerow((name, f"{xxh64:016x}", flag, size))
    return {"records": len(rows), "decoded_bytes": len(data)}


def write_dependencies(source: Path, destination: Path) -> dict[str, int]:
    data = _decompress_sized_lz4(source)
    count = struct.unpack_from("<I", data)[0]
    offset = 4
    rows: list[tuple[str, list[str]]] = []
    for _ in range(count):
        name, offset = _read_7bit_string(data, offset)
        dependency_count = struct.unpack_from("<I", data, offset)[0]
        offset += 4
        dependencies = []
        for _ in range(dependency_count):
            dependency, offset = _read_7bit_string(data, offset)
            dependencies.append(dependency)
        rows.append((name, dependencies))
    if offset != len(data):
        raise ValueError(f"dependencies table has {len(data) - offset} trailing bytes")

    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream, dialect="excel-tab", lineterminator="\n")
        writer.writerow(("asset_path", "dependency_path"))
        for name, dependencies in rows:
            if dependencies:
                for dependency in dependencies:
                    writer.writerow((name, dependency))
            else:
                writer.writerow((name, ""))
    return {
        "assets": len(rows),
        "assets_with_dependencies": sum(bool(dependencies) for _, dependencies in rows),
        "dependency_edges": sum(len(dependencies) for _, dependencies in rows),
        "decoded_bytes": len(data),
    }


def write_csvstring(source: Path, destination: Path) -> dict[str, int]:
    data = source.read_bytes()
    count = struct.unpack_from("<I", data)[0]
    offsets = struct.unpack_from(f"<{count}I", data, 4)
    blob = data[4 + 4 * count :]
    rows = []
    for index, offset in enumerate(offsets):
        end = blob.index(0, offset)
        rows.append((index, blob[offset:end].decode("utf-8")))
    temporary = destination.with_suffix(destination.suffix + ".plain.tmp")
    with temporary.open("w", encoding="utf-8", newline="") as stream:
        writer = csv.writer(stream, dialect="excel-tab", lineterminator="\n")
        writer.writerow(("index", "value"))
        writer.writerows(rows)
    temporary.replace(destination)
    return {"strings": len(rows), "decoded_bytes": len(blob)}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="recovered directory")
    args = parser.parse_args()
    root = args.root.resolve()
    manifests = root / "analysis" / "manifests"
    report = {
        "format": "recovered-plaintext-tables-v1",
        "localfilelist": write_filelist(
            manifests / "localfilelist.bin", manifests / "localfilelist.tsv", False
        ),
        "filelist": write_filelist(
            manifests / "filelist.zip", manifests / "filelist.tsv", True
        ),
        "dependencies": write_dependencies(
            manifests / "dependencies.bin", manifests / "dependencies.tsv"
        ),
        "csvstring": write_csvstring(
            root / "scripts" / "lua_unpacked" / "config" / "csvstring.txt",
            root / "scripts" / "lua_unpacked" / "config" / "csvstring.txt",
        ),
    }
    output = root / "analysis" / "reports" / "binary_tables_plaintext_report.json"
    output.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
