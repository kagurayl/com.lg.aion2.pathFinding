
local alert_message_count = 4
local m_uimessagealert = uipanel_createhandle("root/messagealert", uilayer.message, 0)

function messagealert_onopen()
    m_uimessagealert.alertcenter = {}
    m_uimessagealert.alertcenter.text = m_uimessagealert:getwidget("text_center")
    m_uimessagealert.alertcenter.bg = m_uimessagealert:getwidget("image_center")
    m_uimessagealert.alertcenter.text:setvisible(false)
    m_uimessagealert.alertcenter.bg:setvisible(false)

    m_uimessagealert.alertfollow = {}
    m_uimessagealert.alertfollow.text = m_uimessagealert:getwidget("text_follow")
    m_uimessagealert.alertfollow.text:setvisible(false)

    m_uimessagealert.alertgm = {}
    m_uimessagealert.alertgm.text = m_uimessagealert:getwidget("text_gmmessage")
    m_uimessagealert.alertgm.bg = m_uimessagealert:getwidget("image_gmmessage")
    m_uimessagealert.alertgm.text:setvisible(false)
    m_uimessagealert.alertgm.bg:setvisible(false)
    m_uimessagealert.alertgm.hidetime = 0

    m_uimessagealert.alerthowl = {}
    m_uimessagealert.alerthowl.text = m_uimessagealert:getwidget("text_howl")
    m_uimessagealert.alerthowl.bg = m_uimessagealert:getwidget("image_howl")
    m_uimessagealert.alerthowl.text:setvisible(false)
    m_uimessagealert.alerthowl.bg:setvisible(false)
    m_uimessagealert.alerthowl.hidetime = 0

    m_uimessagealert.alertquest = {}
    m_uimessagealert.alertquest.text = m_uimessagealert:getwidget("text_quest")
    m_uimessagealert.alertquest.bg = m_uimessagealert:getwidget("image_quest")
    m_uimessagealert.alertquest.text:setvisible(false)
    m_uimessagealert.alertquest.bg:setvisible(false)
    m_uimessagealert.alertquest.hidetime = 0

    m_uimessagealert.alertsystem = {}
    for i=1,alert_message_count do
        local alertsystem = {}
        alertsystem.text = m_uimessagealert:getwidget("text_system_" .. i)
        alertsystem.text:setvisible(false)
        alertsystem.hidetime = 0
        m_uimessagealert.alertsystem[i] = alertsystem
    end
    event_register(eventtype.update, messagealert_update, m_uimessagealert)
end

local function messagealert_setsize(uicontainer)
    local renderwidth, renderheight = uicontainer.text:getrendersize()
    uicontainer.bg:setsize(renderwidth + 100, renderheight + 24)
end

function messagealert_showcenter(message)
    message = message or ""
    m_uimessagealert:open()
    m_uimessagealert.alertcenter.text:setvisiblenothit(true)
    m_uimessagealert.alertcenter.bg:setvisiblenothit(true)
    m_uimessagealert.alertcenter.text:setrichtext(message)
end

function messagealert_showfollow(name)
    m_uimessagealert:open()
    m_uimessagealert.alertfollow.text:setvisiblenothit(true)
    m_uimessagealert.alertfollow.text:settext(c_textformat("PLAYER_STATE_FOLLOW", name))
    m_uimessagealert.alertfollow.visible = true
end

function messagealert_showgmmessage(message)
    if message == nil or #message == 0 then
        return
    end
    m_uimessagealert:open()
    m_uimessagealert.alertgm.text:setvisiblenothit(true)
    m_uimessagealert.alertgm.bg:setvisiblenothit(true)
    m_uimessagealert.alertgm.text:setrichtext(message)
    m_uimessagealert.alertgm.hidetime = time_game + 10
    messagealert_setsize(m_uimessagealert.alertgm)
end

function messagealert_showhowl(chat)
    local channelcolor = csvchat_getchannelcolor(chat.type)
    local r, g, b = HexRGB(channelcolor)
    local channeltext = c_textformat("CHAT_FORMAT_" .. chat.type, chat.sendername, chat.text)
    m_uimessagealert:open()
    m_uimessagealert.alerthowl.text:setvisiblenothit(true)
    m_uimessagealert.alerthowl.bg:setvisiblenothit(true)
    m_uimessagealert.alerthowl.text:settext(channeltext)
    m_uimessagealert.alerthowl.text:setcolor(r, g, b, 1.0)
    m_uimessagealert.alerthowl.hidetime = time_game + 10
    messagealert_setsize(m_uimessagealert.alerthowl)
end

function messagealert_addalert(message)
    if message == nil then
        return
    end
    m_uimessagealert:open()

    local alerthidetime = 2.0
    if m_uimessagealert.alertsystem[1].hidetime > 0 and m_uimessagealert.alertsystem[1].message == message then
        m_uimessagealert.alertsystem[1].hidetime = time_game + alerthidetime
        return
    end

    for i=#m_uimessagealert.alertsystem - 1,1,-1 do
        local movesrc = m_uimessagealert.alertsystem[i]
        if movesrc.hidetime > 0 then
            local movedst = m_uimessagealert.alertsystem[i + 1]
            movedst.message = movesrc.message
            movedst.hidetime = movesrc.hidetime
            movedst.text:setvisiblenothit(true)
            movedst.text:settext(movedst.message)
        end
    end

    local alertsystem = m_uimessagealert.alertsystem[1]
    alertsystem.message = message
    alertsystem.text:setvisiblenothit(true)
    alertsystem.text:settext(message)
    alertsystem.hidetime = time_game + alerthidetime
end

function messagealert_addquest(message)
    if message == nil then
        return
    end
    m_uimessagealert:open()

    local viewtext, tagarray = richtext_parse(message, nil, richtextflag.removecolor)
    m_uimessagealert.alertquest.text:settext(viewtext)
    m_uimessagealert.alertquest.text:setvisiblenothit(true)
    m_uimessagealert.alertquest.bg:setvisiblenothit(true)
    m_uimessagealert.alertquest.hidetime = time_game + 2
    messagealert_setsize(m_uimessagealert.alertquest)
end

function messagealert_closecenter()
    if m_uimessagealert:alive() then
        m_uimessagealert.alertcenter.text:setvisible(false)
        m_uimessagealert.alertcenter.bg:setvisible(false)
    end
end

function messagealert_clear()
    if m_uimessagealert:alive() then
        m_uimessagealert.alertcenter.text:setvisible(false)
        m_uimessagealert.alertcenter.bg:setvisible(false)
        m_uimessagealert.alertgm.text:setvisible(false)
        m_uimessagealert.alertgm.bg:setvisible(false)
        m_uimessagealert.alerthowl.text:setvisible(false)
        m_uimessagealert.alerthowl.bg:setvisible(false)
        for i=1,alert_message_count do
            m_uimessagealert.alertsystem[i].text:setvisible(false)
            m_uimessagealert.alertsystem[i].bg:setvisible(false)
        end
    end
end

function messagealert_update()
    for i=1,#m_uimessagealert.alertsystem do
        local alertsystem = m_uimessagealert.alertsystem[i]
        if alertsystem.hidetime > 0 and alertsystem.hidetime < time_game then
            alertsystem.hidetime = 0
            alertsystem.text:setvisible(false)
        end
    end
    if m_uimessagealert.alertgm.hidetime > 0 and m_uimessagealert.alertgm.hidetime < time_game then
        m_uimessagealert.alertgm.hidetime = 0
        m_uimessagealert.alertgm.text:setvisible(false)
        m_uimessagealert.alertgm.bg:setvisible(false)
    end
    if m_uimessagealert.alerthowl.hidetime > 0 and m_uimessagealert.alerthowl.hidetime < time_game then
        m_uimessagealert.alerthowl.hidetime = 0
        m_uimessagealert.alerthowl.text:setvisible(false)
        m_uimessagealert.alerthowl.bg:setvisible(false)
    end
    if m_uimessagealert.alertquest.hidetime > 0 and m_uimessagealert.alertquest.hidetime < time_game then
        m_uimessagealert.alertquest.hidetime = 0
        m_uimessagealert.alertquest.text:setvisible(false)
        m_uimessagealert.alertquest.bg:setvisible(false)
    end
    if m_uimessagealert.alertfollow.visible and not playerapproach_isfollow() then
        m_uimessagealert.alertfollow.visible = false
        m_uimessagealert.alertfollow.text:setvisible(false)
    end
end
