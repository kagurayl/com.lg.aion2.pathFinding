
local m_chatinput_logmax = 10
local m_chatinput_loglist = {}
local m_chatinput_type = chatchanneltype.chataoi
local m_chatinput_whisperid = 0
local m_chatinput_whispername = nil

function chatinput_setchannel(channeltype, whisperid, whispername)
    m_chatinput_type = channeltype
    m_chatinput_whisperid = whisperid
    m_chatinput_whispername = whispername or ""
    chatinput_updateui()
end

function chatinput_updateui()
    if m_uichat_chatbox:null() then
        return
    end
    local text_channel = m_uichat_chatbox:getwidget("text_channel")
    local edit_input = m_uichat_chatbox:getwidget("edit_input")
    if m_chatinput_type == nil then
        edit_input:setenable(false)
        text_channel:setcolor(0.8, 0.0, 0.0, 1.0)
        text_channel:settext("CHAT_SEND_DISABLE")
        return
    end
    if m_chatinput_type == chatchanneltype.chatsendwhisper and (m_chatinput_whisperid == nil or string.len(m_chatinput_whisperid) == 0) then
        edit_input:setenable(false)
        text_channel:setcolor(0.8, 0.0, 0.0, 1.0)
        text_channel:settext("CHAT_SEND_INVALIDWHISPER")
        return
    end

    local channelsetting = csvchat_getchannelcolor(m_chatinput_type)
    local r, g, b = HexRGB(channelsetting)
    text_channel:setcolor(r, g, b, 1.0)
    edit_input:setenable(true)
    if m_chatinput_type == chatchanneltype.chatsendwhisper then
        text_channel:settext("CHAT_SEND_WHISPER", m_chatinput_whispername)
    else
        local config_item = nil
        local itemcount = 0
        if m_chatinput_type == chatchanneltype.chathowlciv then
            config_item = csvitem_getfromid(itemid_howlciv)
            itemcount = playeritem_getcount(itemid_howlciv)
        elseif m_chatinput_type == chatchanneltype.chathowlall then
            config_item = csvitem_getfromid(itemid_howlall)
            itemcount = playeritem_getcount(itemid_howlall)
        end
        local channelname = c_textformat("CHAT_CHANNELTYPE_" .. m_chatinput_type)
        if config_item ~= nil then
            text_channel:settext("CHAT_SEND_CHANNELCOSTITEM", channelname, config_item.name, itemcount)
        else
            text_channel:settext("CHAT_SEND_CHANNEL", channelname)
        end
    end
end

function chatinput_updaterichtext(text)
    local equip = {}
    table.mergearray(equip, playerattr_bag)
    table.mergearray(equip, playerattr_equip1)
    table.mergearray(equip, playerattr_equip2)
    table.mergearray(equip, playerattr_stall)
    local viewtext, tagarray = richtext_parse(text, equip, richtextflag.removeunstable)
    local text_view = m_uichat_chatbox:getwidget("edit_input/Text Area/TextView")
    text_view:settext(viewtext)
end

function chatinput_addtext(addtext)
    m_uichat_chatbox:open()
    local edit_input = m_uichat_chatbox:getwidget("edit_input")
    local text = edit_input:gettext() .. addtext
    edit_input:settext(text)
    edit_input:setlocation(-1, -1)
    chatinput_updaterichtext(text)
end

function chatinput_submit()
    if m_chatinput_type == nil then
        return
    end
    local edit_input = m_uichat_chatbox:getwidget("edit_input")
    local text = edit_input:gettext()
    edit_input:settext("")
    local text_view = m_uichat_chatbox:getwidget("edit_input/Text Area/TextView")
    text_view:settext("")
    local log = {}
    log.chatchanneltype = m_chatinput_type
    log.chatwhisper = m_chatinput_whisperid
    log.chattext = text
    table.insert(m_chatinput_loglist, 1, log)
    while #m_chatinput_loglist > m_chatinput_logmax do
        table.remove(m_chatinput_loglist, #m_chatinput_loglist)
    end
    if debuginput_getenable ~= nil and debuginput_getenable() and string.startwith(text, "@hermes") and debuglocalcommand(text) then
        return
    end
    local msg = {messageid = "CS_Chat"}
    msg.type = m_chatinput_type
    msg.whisperid = m_chatinput_whisperid
    msg.text = text
    msg.equip = {}
    local equip = {}
    table.mergearray(equip, playerattr_bag)
    table.mergearray(equip, playerattr_equip1)
    table.mergearray(equip, playerattr_equip2)
    table.mergearray(equip, playerattr_stall)
    local viewtext, tagarray = richtext_parse(text, equip, richtextflag.removeunstable)
    if tagarray ~= nil then
        for i=1,#tagarray do
            if tagarray[i].type == richtexttag.equip and tagarray[i].equip ~= nil then
                msg.equip[#msg.equip + 1] = tagarray[i].equip.uuid
            end
        end
    end
    c_send(msg)
    
    if debuginput_getenable ~= nil and debuginput_getenable() then
        debuglocalcommand(text)
    end
end
