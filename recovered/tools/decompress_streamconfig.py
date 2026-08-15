#!/usr/bin/env python
"""Decode every per-file LZ4 block extracted from config.scp into UTF-8 text."""
from __future__ import annotations

import argparse
from collections import Counter
from hashlib import sha256
import json
import os
from pathlib import Path
import shutil
import tempfile
import xml.etree.ElementTree as ET

import lz4.block


def _manifest(path: Path) -> list[dict[str, object]]:
    return json.loads(path.read_text(encoding="utf-8"))


def _plain_text(data: bytes, suffix: str) -> bytes | None:
    candidate = data.rstrip(b"\x00")
    try:
        text = candidate.decode("utf-8")
    except UnicodeDecodeError:
        return None
    if suffix == ".html":
        if not text.lstrip().startswith("<?xml"):
            return None
        ET.fromstring(text)
    elif "\x00" in text:
        return None
    return candidate


def _decode(data: bytes, unpacked_size: int, suffix: str, path: Path) -> tuple[bytes, str]:
    plain = _plain_text(data, suffix)
    if plain is not None:
        return plain, "already_plain"
    decoded = lz4.block.decompress(data, uncompressed_size=unpacked_size).rstrip(b"\x00")
    plain = _plain_text(decoded, suffix)
    if plain is None:
        raise ValueError(f"decoded file is not valid UTF-8 {suffix}: {path}")
    return plain, "decoded"


def decode_all(root: Path, manifest_path: Path, report: Path | None = None) -> dict[str, object]:
    root = root.resolve()
    entries = _manifest(manifest_path)
    stage = Path(tempfile.mkdtemp(prefix="streamconfig-plain-", dir=root.parent))
    records: list[dict[str, object]] = []
    try:
        for item in entries:
            relative = str(item["path"])
            source = root.joinpath(*Path(relative).parts)
            if not source.is_file():
                raise FileNotFoundError(source)
            original = source.read_bytes()
            decoded, state = _decode(original, int(item["tag"]), source.suffix.lower(), source)
            destination = stage.joinpath(*Path(relative).parts)
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(decoded)
            records.append(
                {
                    "path": relative,
                    "extension": source.suffix.lower(),
                    "state": state,
                    "input_size": len(original),
                    "output_size": len(decoded),
                    "sha256": sha256(decoded).hexdigest(),
                }
            )

        # Do not touch the source tree until every entry has decoded and validated.
        for item in records:
            relative = str(item["path"])
            os.replace(
                stage.joinpath(*Path(relative).parts),
                root.joinpath(*Path(relative).parts),
            )
    finally:
        shutil.rmtree(stage, ignore_errors=True)

    states = Counter(str(item["state"]) for item in records)
    extensions = Counter(str(item["extension"]) for item in records)
    result: dict[str, object] = {
        "format": "plain-streamconfig-v1",
        "root": root.name,
        "file_count": len(records),
        "decoded_count": states["decoded"],
        "already_plain_count": states["already_plain"],
        "input_bytes": sum(int(item["input_size"]) for item in records),
        "output_bytes": sum(int(item["output_size"]) for item in records),
        "extensions": dict(sorted(extensions.items())),
        "files": records,
    }
    if report is not None:
        report.parent.mkdir(parents=True, exist_ok=True)
        report.write_text(json.dumps(result, ensure_ascii=False, indent=2), encoding="utf-8")
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path, help="config_unpacked root")
    parser.add_argument("manifest", type=Path, help="original config archive manifest JSON")
    parser.add_argument("--report", type=Path, help="write a conversion report")
    args = parser.parse_args()
    result = decode_all(args.root, args.manifest, args.report)
    print(
        f"Validated {result['file_count']} files; decoded {result['decoded_count']}; "
        f"already plain {result['already_plain_count']}; "
        f"{result['input_bytes']} -> {result['output_bytes']} bytes; "
        f"extensions={result['extensions']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
