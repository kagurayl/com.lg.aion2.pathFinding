
local tutorialtips_timedisplay = 5
local tutorialtips_timehide = 2

local m_uitutorialtips = uipanel_createhandle("root/tutorialtips", uilayer.tutorial, 0)

function tutorialtips_onopen()
    event_register(eventtype.update, tutorialtips_update, m_uitutorialtips)
end

function tutorialtips_open(id)
    if tutorial_getfinish(id) then
        return
    end
    local config_tutorial = c_config_getmetaid(configid.tutorialtips, id)
    if config_tutorial == nil then
        return
    end
    m_uitutorialtips:open()
    local text_desc = m_uitutorialtips:getwidget("text_desc")
    text_desc:settext(config_tutorial.desc)
    text_desc:setopacity(1.0)
    m_uitutorialtips.timestart = time_game
    local msg = {messageid="CS_Tutorial"}
    msg.id = id
    c_send(msg)
end

function tutorialtips_update()
    local time = time_game - m_uitutorialtips.timestart
    if time < tutorialtips_timedisplay then
        return
    end
    time = time - tutorialtips_timedisplay
    if time < tutorialtips_timehide then
        local t = time / tutorialtips_timehide
        local text_desc = m_uitutorialtips:getwidget("text_desc")
        text_desc:setopacity(1.0 - t)
        return
    end
    m_uitutorialtips:close()
end
