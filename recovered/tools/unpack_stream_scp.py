#!/usr/bin/env python
"""Extract the game's LZ4-packed SCP stream archive."""
from __future__ import annotations
import argparse, hashlib, json, shutil, struct
from pathlib import Path, PurePosixPath
import lz4.block


def extract(source: Path, output: Path, force: bool):
    packed = source.read_bytes()
    size = struct.unpack_from("<I", packed)[0]
    data = lz4.block.decompress(packed[4:], uncompressed_size=size)
    count = struct.unpack_from("<I", data)[0]
    cursor = 4
    entries = []
    for index in range(count):
        offset, length, tag = struct.unpack_from("<III", data, cursor)
        cursor += 12
        end = data.index(0, cursor)
        name = data[cursor:end].decode("utf-8")
        cursor = end + 1
        if offset + length > len(data):
            raise ValueError(f"entry {index} exceeds archive: {name}")
        path = PurePosixPath(name)
        if path.is_absolute() or ".." in path.parts:
            raise ValueError(f"unsafe path: {name}")
        entries.append((offset, length, tag, name))
    if output.exists() and force:
        shutil.rmtree(output)
    output.mkdir(parents=True, exist_ok=True)
    manifest = []
    for offset, length, tag, name in entries:
        content = data[offset:offset+length]
        destination = output.joinpath(*PurePosixPath(name).parts)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
        manifest.append({"path": name, "offset": offset, "size": length, "tag": tag,
                         "sha256": hashlib.sha256(content).hexdigest()})
    return manifest


def main():
    p = argparse.ArgumentParser()
    p.add_argument("source", type=Path)
    p.add_argument("output", type=Path)
    p.add_argument("--force", action="store_true")
    p.add_argument("--manifest", type=Path)
    a = p.parse_args()
    m = extract(a.source, a.output, a.force)
    if a.manifest:
        a.manifest.write_text(json.dumps(m, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Extracted {len(m)} files ({sum(x['size'] for x in m)} bytes) to {a.output.resolve()}")

if __name__ == "__main__":
    main()
