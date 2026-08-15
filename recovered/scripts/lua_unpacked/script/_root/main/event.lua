
eventtype =
{
    update = 0x1,
    update2 = 0x2,
    lateupdate = 0x4,
    lostfocus = 0x8,
    receivefocus = 0x10,
    reconnect = 0x20,
    item = 0x40,
    money = 0x80,
    playerinfo = 0x100,
}

local m_event_register = {}
local m_event_updateremove = false

function event_register(eventtype, func, handleui, arg)
    for i=1,#m_event_register do
        local evt = m_event_register[i]
        if evt.type == eventtype and evt.func == func and evt.arg == arg then
            evt.active = true
            return
        end
    end
    local register = {}
    register.type = eventtype
    register.func = func
    register.arg = arg
    register.active = true
    if handleui ~= nil then
        register.handleuiname = handleui:getname()
    end
    m_event_register[#m_event_register + 1] = register
end

function event_deregister(eventtype, func, arg)
    for i=1,#m_event_register do
        local evt = m_event_register[i]
        if evt.type == eventtype and evt.func == func and evt.arg == arg then
            evt.active = false
            m_event_updateremove = true
            break
        end
    end
end

function event_onpanelclose(name)
    for i=#m_event_register, 1, -1 do
        local register = m_event_register[i]
        if register.handleuiname ~= nil and register.handleuiname == name then
            register.active = false
            m_event_updateremove = true
        end
    end
end

function event_active(eventtype, ...)
    local response = false
    for i=1,#m_event_register do
        local register = m_event_register[i]
        if register.active and bit.band(register.type, eventtype) > 0 then
            register.func(register.arg, ...)
            response = true
        end
    end
    if m_event_updateremove then
        for i=#m_event_register, 1, -1 do
            if not m_event_register[i].active then
                table.remove(m_event_register, i)
            end
        end
        m_event_updateremove = false
    end
    return response
end

function event_active_me(actor, eventtype, ...)
    if actor:isme() then
        event_active(eventtype, ...)
    end
end
