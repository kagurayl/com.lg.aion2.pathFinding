#!/usr/bin/env python
"""Minimal client for the game's length-prefixed Lua debug protocol."""

from __future__ import annotations

import argparse
import json
import socket
import struct
import time


def send_request(sock: socket.socket, seq: int, command: str, arguments: dict) -> None:
    message = json.dumps(
        {"seq": seq, "type": "request", "command": command, "arguments": arguments},
        separators=(",", ":"),
    ).encode("utf-8") + b"\0"
    sock.sendall(struct.pack("<I", len(message)) + message)


def receive_message(sock: socket.socket) -> dict:
    header = sock.recv(4)
    if len(header) != 4:
        raise EOFError("debugger connection closed")
    size = struct.unpack("<I", header)[0]
    chunks = bytearray()
    while len(chunks) < size:
        chunk = sock.recv(size - len(chunks))
        if not chunk:
            raise EOFError("debugger connection closed mid-message")
        chunks.extend(chunk)
    return json.loads(bytes(chunks).rstrip(b"\0"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=10001)
    parser.add_argument("--listen", type=float, default=3.0)
    args = parser.parse_args()

    with socket.create_connection((args.host, args.port), timeout=3) as sock:
        sock.settimeout(0.5)
        send_request(sock, 1, "attach", {})
        send_request(sock, 2, "configurationDone", {})
        deadline = time.monotonic() + args.listen
        while time.monotonic() < deadline:
            try:
                print(json.dumps(receive_message(sock), ensure_ascii=False))
            except TimeoutError:
                continue
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
