
local zonefog_timeview = 4

local m_uizonefog = uipanel_createhandle("prompt/zonefog", uilayer.top, 0)

function zonefog_create(zonename)
    m_uizonefog:open()

    local title, note = csvmap_splitzonename(zonename)
    local text_name = m_uizonefog:getwidget("text_name")
    text_name:settextraw(c_textformat("ZONEFOG_TIPSNAME", title))

    m_uizonefog.timestart = time_game
end

function zonefog_onopen()
    event_register(eventtype.update, zonefog_update, m_uizonefog)
end

function zonefog_update()    
    if m_uizonefog.timestart + zonefog_timeview < time_game then
        m_uizonefog:close()
    end
end
