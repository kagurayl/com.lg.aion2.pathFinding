
local m_chat_inst = {channel = "chat/inst_channel", chat = "chat/inst_chat"}
m_uichat_chatbox = uipanel_createhandle("chat/chatbox", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft))

function chatbox_onopen()
    m_uichat_chatbox:setwidgetdelegate("text_channel", chatbox_delegate_selectchannel)
    m_uichat_chatbox:setwidgetdelegate("edit_input", chatbox_delegate_input)
    m_uichat_chatbox:setwidgetdelegate("button_send", chatbox_delegate_send)
    m_uichat_chatbox:setwidgetdelegate("button_setting", chatbox_delegate_setting)
    m_uichat_chatbox:setwidgetdelegate("button_close", chatbox_delegate_close)

    m_uichat_chatbox.list_chat = m_uichat_chatbox:getwidget("list_chat")
    m_uichat_chatbox.list_chat:init(bit.bor(uilistflag.vertical, uilistflag.async))
    m_uichat_chatbox.list_chat:setasyncdelegate(chatbox_delegate_setlist)
    m_uichat_chatbox.text_sizecalc = m_uichat_chatbox:getwidget("text_sizecalc")

    local list_channel = m_uichat_chatbox:getwidget("list_channel")
    list_channel:init(uilistflag.vertical)
    if m_uichat_chatbox.channelselect == nil then
        m_uichat_chatbox.channelselect = 1
    end
    chatbox_updateui()
    chatinput_updateui()
end

function chatbox_updateui()
    if m_uichat_chatbox:null() then
        return
    end
    local list_channel = m_uichat_chatbox:getwidget("list_channel")
    list_channel:clear()
    local namesetting = gamesetting_gettable("CHATSETTING_NAME")
    for i=1,#namesetting do
        local name = csvchat_getchannelname(i)
        if name ~= nil then
            local line = list_channel:add(m_chat_inst.channel, i, i)
            local button_channel = line:getwidget("button_channel")
            button_channel.channel = i
            button_channel:settext(name)
            button_channel:setdelegate(chatbox_delegate_channel)
        end
    end
    chatbox_setchannel(m_uichat_chatbox.channelselect)
end

function chatbox_addchat(chat, removehistroyid)
    if m_uichat_chatbox:alive() then
        if csvchat_getchannelvisible(m_uichat_chatbox.channelselect, chat.type) and not playerpal_inblacklist(chat.senderid) then
            local isbottom = m_uichat_chatbox.list_chat:isscrollbottom()
            if removehistroyid ~= 0 then
                for i=1,m_uichat_chatbox.list_chat:getcount() do
                    local line = m_uichat_chatbox.list_chat:getlinefromindex(i)
                    local data = line:getdata()
                    if data.histroyid == removehistroyid then
                        m_uichat_chatbox.list_chat:remove(i)
                        break
                    end
                end
            end
            if chat.presetchatbox == nil then
                chat.presetchatbox = m_uichat_chatbox.text_sizecalc:presetchat(chat)
            end
            local line = m_uichat_chatbox.list_chat:add(m_chat_inst.chat, string.format("%d", chat.histroyid), chat)
            line:setsize(chat.presetchatbox.viewheight)
            m_uichat_chatbox.list_chat:updatecontentsize()
            if isbottom then
                m_uichat_chatbox.list_chat:setscrollbottom(0.2)
            end
        end
    end
end

function chatbox_batchaddchat(chatarray)
    if m_uichat_chatbox:alive() then
        for i=1,#chatarray do
            local chat = chatarray[i]
            if csvchat_getchannelvisible(m_uichat_chatbox.channelselect, chat.type) and not playerpal_inblacklist(chat.senderid) then
                if chat.presetchatbox == nil then
                    chat.presetchatbox = m_uichat_chatbox.text_sizecalc:presetchat(chat)
                end
                local line = m_uichat_chatbox.list_chat:add(m_chat_inst.chat, string.format("%d", m_uichat_chatbox.list_chat:getcount()), chat)
                line:setsize(chat.presetchatbox.viewheight)
            end
        end
        m_uichat_chatbox.list_chat:updatecontentsize()
        m_uichat_chatbox.list_chat:setscrollbottom(0.2)
    end
end

function chatbox_setchannel(channel)
    m_uichat_chatbox.channelselect = channel
    local list_channel = m_uichat_chatbox:getwidget("list_channel")
    for i=1,list_channel:getcount() do
        local line = list_channel:getlinefromindex(i)
        local button_channel = line:getwidget("button_channel")
        button_channel:setenable(button_channel.channel ~= channel)
    end

    local list_chat = m_uichat_chatbox:getwidget("list_chat")
    list_chat:clear()

    local chatlist = chat_getchatlist()
    chatbox_batchaddchat(chatlist)
end

function chatbox_delegate_channel(sender)
    chatbox_setchannel(sender.channel)
end

function chatbox_delegate_selectchannel(sender)
    chatreceiver_open()
end

function chatbox_delegate_chat(sender, event)
    if event.name == "click" and event.linkid ~= nil then
        local image_bg = m_uichat_chatbox:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        richtext_onclick(event, sender.tagarray, x + w, tipsflag.vright)
    end
end

function chatbox_delegate_input(sender, event)
    if event.name == "submit" then
        if system_ispc() then
            chatinput_submit()
        else
            chatinput_updaterichtext(sender:gettext())
        end
    elseif event.name == "textchanged" then
        chatinput_updaterichtext(sender:gettext())
    end
end

function chatbox_delegate_send()
    chatinput_submit()
end

function chatbox_delegate_setting()
    chatsetting_open()
end

function chatbox_delegate_close()
    m_uichat_chatbox:close()
end

function chatbox_delegate_setlist(sender, line, chat)
    local text_chat = line:getwidget("text_chat")
    text_chat:setdelegate(chatbox_delegate_chat)
    text_chat:setchat(chat.presetchatbox)
end
