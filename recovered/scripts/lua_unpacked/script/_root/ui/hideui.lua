
local m_uihideui = uipanel_createhandle("root/hideui", uilayer.message, uiflag.hidemodevisible)

function hideui_show()
    m_uihideui:open()
    m_uihideui:setwidgetdelegate("button_showui", hideui_delegate_showui)
    m_uihideui.timestart = time_game
    event_register(eventtype.update, hideui_update, m_uihideui)
end

function hideui_update()
    local time = 1.0 - (time_game - m_uihideui.timestart) / 3.0
    time = math.clamp(time, 0.0, 1.0)
    local text_tips = m_uihideui:getwidget("text_tips")
    text_tips:setcolor(1,1,1,time)
end

function hideui_delegate_showui()
    uimanager_sethideui(false)
    m_uihideui:close()
end
