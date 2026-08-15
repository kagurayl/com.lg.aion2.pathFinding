
local zonetextstate = 
{
    fadein = 0,
    display = 1,
    fadeout = 2,
}

local ZONELOGO_FADEIN_TIME = 1
local ZONELOGO_DISPLAY_TIME = 2
local ZONELOGO_FADEOUT_TIME = 1

local m_zone_ui = uipanel_createhandle("prompt/zone", uilayer.top, 0)
local m_zone_state = 0
local m_zone_starttime = 0

function zone_create(zonename, zonenote)
    m_zone_ui:open()
    local text_name = m_zone_ui:getwidget("text_name")
    text_name:settextraw(zonename)

    m_zone_starttime = time_game
    m_zone_state = zonetextstate.fadein
    zone_update()
end

function zone_onopen()
    event_register(eventtype.update, zone_update, m_zone_ui)
end

function zone_update()    
    local costtime = time_game - m_zone_starttime
    if m_zone_state == zonetextstate.fadein then
        costtime = costtime / ZONELOGO_FADEIN_TIME
        if costtime > 1 then
            costtime = 1
            m_zone_state = zonetextstate.display
            m_zone_starttime = time_game
        end
        local text_name = m_zone_ui:getwidget("text_name")
        text_name:setopacity(costtime)
    elseif m_zone_state == zonetextstate.display then
        if costtime > ZONELOGO_DISPLAY_TIME then
            m_zone_state = zonetextstate.fadeout
            m_zone_starttime = time_game
        end
    elseif m_zone_state == zonetextstate.fadeout then
        costtime = costtime / ZONELOGO_FADEOUT_TIME
        if costtime < 1 then
            local text_name = m_zone_ui:getwidget("text_name")
            text_name:setopacity(1.0 - costtime)
        else
            m_zone_ui:close()
        end
    end
end
