
include("input/inputmouse")
include("input/inputtouch")
include("input/inputkey")
include("input/inputmove")
include("input/maincamera")

KeyName_LeftMouseButton = "Mouse0"
KeyName_RightMouseButton = "Mouse1"
KeyName_LeftControl = "LeftCtrl"
KeyName_RightControl = "RightCtrl"
KeyName_LeftAlt = "LeftAlt"
KeyName_RightAlt = "RightAlt"
KeyName_LeftShift = "LeftShift"
KeyName_RightShift = "RightShift"

local m_input_keystate = {}
local m_input_keyconvert = {}

function input_init()
    m_input_keyconvert["Digit1"] = "1"
    m_input_keyconvert["Digit2"] = "2"
    m_input_keyconvert["Digit3"] = "3"
    m_input_keyconvert["Digit4"] = "4"
    m_input_keyconvert["Digit5"] = "5"
    m_input_keyconvert["Digit6"] = "6"
    m_input_keyconvert["Digit7"] = "7"
    m_input_keyconvert["Digit8"] = "8"
    m_input_keyconvert["Digit9"] = "9"
    m_input_keyconvert["Digit0"] = "0"
    m_input_keyconvert["Comma"] = ","
    m_input_keyconvert["Backquote"] = "`"
    m_input_keyconvert["Minus"] = "-"
    m_input_keyconvert["Equals"] = "="
    m_input_keyconvert["Semicolon"] = ";"
    m_input_keyconvert["Quote"] = "'"
    m_input_keyconvert["Period"] = "."
    m_input_keyconvert["Slash"] = "/"
    m_input_keyconvert["Backslash"] = "\\"
    m_input_keyconvert["LeftArrow"] = "←"
    m_input_keyconvert["RightArrow"] = "→"
    m_input_keyconvert["UpArrow"] = "↑"
    m_input_keyconvert["DownArrow"] = "↓"
end

function input_getkeydown(keyname)
    local keystate = m_input_keystate[keyname]
    return keystate ~= nil and keystate.press
end

function input_getctrldown()
    return input_getkeydown(KeyName_LeftControl) or input_getkeydown(KeyName_RightControl)
end

function input_getaltdown()
    return input_getkeydown(KeyName_LeftAlt) or input_getkeydown(KeyName_RightAlt)
end

function input_getshiftdown()
    return input_getkeydown(KeyName_LeftShift) or input_getkeydown(KeyName_RightShift)
end

function input_getcombinekey(keyname)
    local combinekey = ""
    if input_getctrldown() then
        combinekey = combinekey .. "C+"
    end
    if input_getaltdown() then
        combinekey = combinekey .. "A+"
    end
    if input_getshiftdown() then
        combinekey = combinekey .. "S+"
    end
    return combinekey .. keyname
end

function input_update()
    inputmouse_update()
    inputtouch_update()
    inputmove_update()
end

function input_reset()
    inputmouse_reset()
end

function inputdevice_keydown(keyname)
    --debugerror(keyname)
    if not game_focus then
        return
    end
    local keyconvert = m_input_keyconvert[keyname]
    if keyconvert ~= nil then
        keyname = keyconvert
    end
    local keystate = m_input_keystate[keyname]
    if keystate == nil then
        keystate = {}
        keystate.name = keyname
        keystate.press = false
        keystate.modifier = keyname == KeyName_LeftControl or keyname == KeyName_RightControl or keyname == KeyName_LeftAlt or keyname == KeyName_RightAlt or keyname == KeyName_LeftShift or keyname == KeyName_RightShift
        m_input_keystate[keyname] = keystate
    end
    if keystate.press then
        return
    end
    keystate.press = true
    if keyname == KeyName_LeftControl or keyname == KeyName_RightControl
    or keyname == KeyName_LeftAlt or keyname == KeyName_RightAlt
    or keyname == KeyName_LeftShift or keyname == KeyName_RightShift then
        return
    end
    inputkey_onkey(input_getcombinekey(keyname))
end

function inputdevice_keyup(keyname)
    local keyconvert = m_input_keyconvert[keyname]
    if keyconvert ~= nil then
        keyname = keyconvert
    end
    local keystate = m_input_keystate[keyname]
    if keystate ~= nil and keystate.press then
        keystate.press = false
        if keyname == KeyName_LeftControl or keyname == KeyName_RightControl
        or keyname == KeyName_LeftAlt or keyname == KeyName_RightAlt
        or keyname == KeyName_LeftShift or keyname == KeyName_RightShift then
            return
        end
        inputkey_onkeyup(input_getcombinekey(keyname))
    end
end

function inputdevice_keyclear()
    m_input_keystate = {}
end
