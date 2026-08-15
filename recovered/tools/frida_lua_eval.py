#!/usr/bin/env python
"""Evaluate a Lua chunk on the game's root VM from its update thread."""

from __future__ import annotations

import argparse
import json
import threading

import frida


JS_TEMPLATE = r"""
'use strict';
const module = Process.getModuleByName('libgamedll.so');
const updateAddress = module.getExportByName('gamelib_update');
const getRootVm = new NativeFunction(module.getExportByName('script_getrootvm'), 'pointer', []);
const loadBuffer = new NativeFunction(module.getExportByName('luaL_loadbuffer'), 'int', ['pointer', 'pointer', 'ulong', 'pointer']);
const pcall = new NativeFunction(module.getExportByName('lua_pcall'), 'int', ['pointer', 'int', 'int', 'int']);
const toString = new NativeFunction(module.getExportByName('lua_tolstring'), 'pointer', ['pointer', 'int', 'pointer']);
const setTop = new NativeFunction(module.getExportByName('lua_settop'), 'void', ['pointer', 'int']);
const sourceText = __SOURCE_JSON__;
const source = Memory.allocUtf8String(sourceText);
const chunkName = Memory.allocUtf8String('@hermes_live_probe');
let completed = false;

function luaError(L, stage, code) {
    const value = toString(L, -1, ptr(0));
    const message = value.isNull() ? '<no Lua error string>' : value.readUtf8String();
    setTop(L, -2);
    send({type: 'error', stage: stage, code: code, message: message});
}

const listener = Interceptor.attach(updateAddress, {
    onEnter() {
        if (completed) return;
        completed = true;
        try {
            const vm = getRootVm();
            if (vm.isNull()) {
                send({type: 'error', stage: 'rootvm', message: 'root VM is null'});
                return;
            }
            const L = vm.readPointer();
            if (L.isNull()) {
                send({type: 'error', stage: 'lua_state', message: 'lua_State is null'});
                return;
            }
            let status = loadBuffer(L, source, sourceText.length, chunkName);
            if (status !== 0) {
                luaError(L, 'load', status);
                return;
            }
            status = pcall(L, 0, 1, 0);
            if (status !== 0) {
                luaError(L, 'pcall', status);
                return;
            }
            const resultPointer = toString(L, -1, ptr(0));
            const result = resultPointer.isNull() ? null : resultPointer.readUtf8String();
            setTop(L, -2);
            send({type: 'result', value: result});
        } catch (error) {
            send({type: 'error', stage: 'native', message: String(error), stack: error.stack});
        } finally {
            listener.detach();
        }
    }
});
"""


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pid", type=int, required=True)
    parser.add_argument("--code", required=True, help="Lua chunk; return a string result")
    parser.add_argument("--timeout", type=float, default=10.0)
    args = parser.parse_args()

    device = frida.get_usb_device(timeout=5)
    session = device.attach(args.pid)
    done = threading.Event()
    outcome: dict[str, object] = {}

    def on_message(message, data):
        nonlocal outcome
        if message.get("type") == "send":
            outcome = message.get("payload", {})
        else:
            outcome = {"type": "frida-error", "message": message}
        done.set()

    source = JS_TEMPLATE.replace("__SOURCE_JSON__", json.dumps(args.code))
    script = session.create_script(source)
    script.on("message", on_message)
    script.load()
    if not done.wait(args.timeout):
        outcome = {"type": "timeout", "message": "game update hook did not fire"}
    script.unload()
    session.detach()
    print(json.dumps(outcome, ensure_ascii=False))
    return 0 if outcome.get("type") == "result" else 1


if __name__ == "__main__":
    raise SystemExit(main())
