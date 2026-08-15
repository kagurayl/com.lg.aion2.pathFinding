
local m_chatreceiver_inst = {channel = "chat/inst_receiver"}
local m_uichat_receiver = uipanel_createhandle("chat/chatreceiver", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright))

function chatreceiver_open()
    m_uichat_receiver:open()
end

function chatreceiver_onopen()
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_reciever:setasyncdelegate(chatreceiver_delegate_list)
    list_reciever:setclickdelegate(chatreceiver_delegate_receiver)

    m_uichat_receiver:setwidgetdelegate("image_bg/button_close", chatreceiver_delegate_close)
    m_uichat_receiver:setwidgetdelegate("button_channel", chatreceiver_delegate_channel)
    m_uichat_receiver:setwidgetdelegate("button_whisper", chatreceiver_delegate_whisper)
    m_uichat_receiver:setwidgetdelegate("button_team", chatreceiver_delegate_team)
    m_uichat_receiver:setwidgetdelegate("button_pal", chatreceiver_delegate_pal)
    m_uichat_receiver:setwidgetdelegate("button_icc", chatreceiver_delegate_icc)
    chatreceiver_delegate_channel(nil, nil)
end

local function chatreceiver_addchannel(list_reciever, displayname, channeltype, whisperid, whispername)
    local data = {}
    data.displayname = displayname
    data.channeltype = channeltype
    data.whisperid = whisperid
    data.whispername = whispername
    list_reciever:add(m_chatreceiver_inst.channel, list_reciever:getcount(), data)
end

local function chatreceiver_settype(buttonname)
    m_uichat_receiver:setwidgetenable("button_channel", buttonname ~= "button_channel")
    m_uichat_receiver:setwidgetenable("button_whisper", buttonname ~= "button_whisper")
    m_uichat_receiver:setwidgetenable("button_team", buttonname ~= "button_team")
    m_uichat_receiver:setwidgetenable("button_pal", buttonname ~= "button_pal")
    m_uichat_receiver:setwidgetenable("button_icc", buttonname ~= "button_icc")
end

function chatreceiver_delegate_channel(sender, event)
    chatreceiver_settype("button_channel")
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:clear()

    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_1"), chatchanneltype.chataoi)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_2"), chatchanneltype.chatmap)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_3"), chatchanneltype.chatteam)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_4"), chatchanneltype.chatraid)
    --chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_5"), chatchanneltype.chatflock)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_6"), chatchanneltype.chaticc)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_7"), chatchanneltype.chatcareer)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_8"), chatchanneltype.chatworld)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_9"), chatchanneltype.chatdeal)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_10"), chatchanneltype.chatrecruit)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_11"), chatchanneltype.chatrumor)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_12"), chatchanneltype.chathowlciv)
    chatreceiver_addchannel(list_reciever, c_textformat("CHAT_CHANNELINPUT_13"), chatchanneltype.chathowlall)
end

function chatreceiver_delegate_whisper(sender, event)
    chatreceiver_settype("button_whisper")
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:clear()

    local chatlist = chat_getchatlist()
    local whisperid = {}
    for i=1,#chatlist do
        local chat = chatlist[i]
        if chat.type == chatchanneltype.chatrecvwhisper then
            if whisperid[chat.senderid] == nil then
                chatreceiver_addchannel(list_reciever, chat.sendername, chatchanneltype.chatsendwhisper, chat.senderid, chat.sendername)
                whisperid[chat.senderid] = chat.senderid
            end
        elseif chat.type == chatchanneltype.chatsendwhisper then
            if whisperid[chat.whisperid] == nil then
                chatreceiver_addchannel(list_reciever, chat.whispername, chatchanneltype.chatsendwhisper, chat.whisperid, chat.whispername)
                whisperid[chat.whisperid] = chat.whisperid
            end
        end
    end
end

function chatreceiver_delegate_team(sender, event)
    chatreceiver_settype("button_team")
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:clear()

    if playerattr_team ~= nil then
        for i=1, #playerattr_team.mate do
            local mate = playerattr_team.mate[i]
            chatreceiver_addchannel(list_reciever, mate.name, chatchanneltype.chatsendwhisper, mate.playerid, mate.name)
        end
    end
end

function chatreceiver_delegate_pal(sender, event)
    chatreceiver_settype("button_pal")
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:clear()

    for i=1,#playerattr_pal do
        local pal = playerattr_pal[i]
        chatreceiver_addchannel(list_reciever, pal.name, chatchanneltype.chatsendwhisper, pal.playerid, pal.name)
    end
end

function chatreceiver_delegate_icc(sender, event)
    chatreceiver_settype("button_icc")
    local list_reciever = m_uichat_receiver:getwidget("list_reciever")
    list_reciever:clear()

    if playerattr_icc ~= nil then
        for i=1,#playerattr_icc.member do
            local member = playerattr_icc.member[i]
            if member.name ~= playerattr_info.name then
                chatreceiver_addchannel(list_reciever, member.name, chatchanneltype.chatsendwhisper, member.playerid, member.name)
            end
        end
    end
end

function chatreceiver_delegate_list(sender, line, data)
    local text_name = line:getwidget("text_name")
    text_name:settext(data.displayname)
    local color = csvchat_getchannelcolor(data.channeltype)
    local r, g, b = HexRGB(color)
    text_name:setcolor(r, g, b, 1.0)
end

function chatreceiver_delegate_receiver(line, event, data)
    m_uichat_chatbox:open()
    chatinput_setchannel(data.channeltype, data.whisperid, data.whispername)
end

function chatreceiver_delegate_close(sender, event)
    m_uichat_receiver:close()
end
