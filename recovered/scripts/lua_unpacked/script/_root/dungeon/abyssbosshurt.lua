
local m_abyss_bosshurt = uipanel_createhandle("dungeon/abyss_bosshurt", uilayer.score, bit.bor(uiflag.scale, uiflag.holdonclear))

function abyss_bosshurt_settext(msg)
    m_abyss_bosshurt:open()
    m_abyss_bosshurt.closetime = time_game + 5.0

    local text_light = m_abyss_bosshurt:getwidget("text_light")
    text_light:settext(string.format("%s:%d", c_textformat("UI_CIVNAME_ELF"), math.tointegerfloor(msg.light)))

    local text_dark = m_abyss_bosshurt:getwidget("text_dark")
    text_dark:settext(string.format("%s:%d", c_textformat("UI_CIVNAME_DARK"), math.tointegerfloor(msg.dark)))

    local text_dragon = m_abyss_bosshurt:getwidget("text_dragon")
    text_dragon:settext(string.format("%s:%d", c_textformat("UI_CIVNAME_DRAGON"), math.tointegerfloor(msg.dragon)))

    event_register(eventtype.update, abyss_bosshurt_update, m_abyss_bosshurt)
end

function abyss_bosshurt_update()
    if m_abyss_bosshurt.closetime < time_game then
        m_abyss_bosshurt:close()
    end
end
