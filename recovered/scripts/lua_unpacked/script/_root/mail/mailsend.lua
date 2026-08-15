
local m_uimail_receiver_inst = {receiver = "mail/inst_receiver"}
local m_uimail_send_name = nil
local m_uimail_send_itemuuid = 0
local m_uimail_send_itemcount = 0


function mail_send_onopen()
    m_uimail_main:setwidgetdelegate("tab_send/button_submit", mail_send_delegate_submit)
    m_uimail_main:setwidgetdelegate("tab_send/edit_coin", mail_send_delegate_coin)
    m_uimail_main:setwidgetdelegate("tab_send/image_selectitem", mail_send_delegate_selectitem)

    local list_reciever = m_uimail_main:getwidget("tab_receiver/list_reciever")
    list_reciever:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_reciever:setasyncdelegate(mail_send_delegate_list)
    list_reciever:setclickdelegate(mail_send_delegate_receiver)

    local text_receiver = m_uimail_main:getwidget("tab_send/text_receiver")
    text_receiver:settext("MAIL_SEND_INVALIDRECEIVER")

    local image_icon = m_uimail_main:getwidget("tab_send/image_icon")
    image_icon:setvisible(false)

    local text_itemcount = m_uimail_main:getwidget("tab_send/text_itemcount")
    text_itemcount:setvisible(false)

    local text_itemname = m_uimail_main:getwidget("tab_send/text_itemname")
    text_itemname:setvisible(false)

    local edit_coin = m_uimail_main:getwidget("tab_send/edit_coin")
    edit_coin:settext("0")

    m_uimail_send_name = nil
    m_uimail_send_itemuuid = 0
    m_uimail_send_itemcount = 0
    mail_send_updatecost()
end

function mail_send_updatecost()
    local edit_coin = m_uimail_main:getwidget("tab_send/edit_coin")
    local coin = string.tointeger(edit_coin:gettext())
    if coin == nil or coin < 0 then
        coin = 0
    end
    local coincost = 10 + math.floor(coin / 100)
    local item = playeritem_getfromuuid(m_uimail_send_itemuuid)
    if item ~= nil then
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            coincost = coincost + math.floor((config_item.price * m_uimail_send_itemcount) / 50)
        end
    end
    local text_cost = m_uimail_main:getwidget("tab_send/text_cost")
    text_cost:settext(coincost)
end

function mail_send_updateui()
    if m_uimail_tab ~= mailtab.send then
        m_uimail_main:setwidgetvisible("tab_send", false)
        m_uimail_main:setwidgetvisible("tab_receiver", false)
        return
    end
    m_uimail_main:setwidgetvisible("tab_send", true)
    m_uimail_main:setwidgetvisible("tab_receiver", true)

    local list_reciever = m_uimail_main:getwidget("tab_receiver/list_reciever")
    list_reciever:savestate()
    list_reciever:clear()
    for i=1,#playerattr_pal do
        local pal = playerattr_pal[i]
        list_reciever:add(m_uimail_receiver_inst.receiver, "pal_" .. pal.name, {type = "MAIL_SEND_RECEIVERPAL", name = pal.name})
    end
    if playerattr_icc ~= nil then
        for i=1,#playerattr_icc.member do
            local member = playerattr_icc.member[i]
            if member.name ~= playerattr_info.name then
                list_reciever:add(m_uimail_receiver_inst.receiver, "icc_" .. member.name, {type = "MAIL_SEND_RECEIVERICC", name = member.name})
            end
        end
    end
    if playerattr_team ~= nil then
        for i=1, #playerattr_team.mate do
            local mate = playerattr_team.mate[i]
            list_reciever:add(m_uimail_receiver_inst.receiver, "team_" .. mate.name, {type = "MAIL_SEND_RECEIVERTEAM", name = mate.name})
        end
    end
    list_reciever:restorestate()
end

function mail_send_delegate_list(sender, line, data)
    local text_type = line:getwidget("text_type")
    text_type:settext(data.type)
    
    local text_name = line:getwidget("text_name")
    text_name:settext(data.name)
end

function mail_send_delegate_receiver(line, event, data)
    local text_receiver = m_uimail_main:getwidget("tab_send/text_receiver")
    text_receiver:settext(data.name)
    m_uimail_send_name = data.name
end

function mail_send_delegate_coin()
    mail_send_updatecost()
end

function mail_send_delegate_selectitemcomplete(item, count)
    if m_uimail_main:null() then
        return
    end
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local image_icon = m_uimail_main:getwidget("tab_send/image_icon")
    image_icon:setvisiblenothit(true)
    image_icon:seticon(config_item.icon)

    local text_itemcount = m_uimail_main:getwidget("tab_send/text_itemcount")
    text_itemcount:setvisiblenothit(true)
    text_itemcount:settext(count)

    local text_itemname = m_uimail_main:getwidget("tab_send/text_itemname")
    text_itemname:setvisiblenothit(true)
    text_itemname:settext(config_item.name)
    m_uimail_send_itemuuid = item.uuid
    m_uimail_send_itemcount = count
    mail_send_updatecost()
end
function mail_send_delegate_filteritem(item)
    return playeritem_getitemdeal(item)
end
function mail_send_delegate_selectitem()
    selectitem_show("MAIL_SEND_SELECTITEM", "MAIL_SEND_SELECTITEMCOUNT", selectitemcount.count, selectitemflag.bag, mail_send_delegate_filteritem, mail_send_delegate_selectitemcomplete)
end

function mail_send_delegate_submit()
    local edit_mailtitle = m_uimail_main:getwidget("tab_send/edit_mailtitle")
    local edit_content = m_uimail_main:getwidget("tab_send/edit_content")
    local edit_coin = m_uimail_main:getwidget("tab_send/edit_coin")
    if m_uimail_send_name == nil or string.len(m_uimail_send_name) == 0 then
        chat_addsystemalert("MAIL_SEND_INVALIDRECEIVER")
        return
    end
    local coin = string.tointeger(edit_coin:gettext())
    if coin == nil or coin < 0 then
        coin = 0
    end
    local msg = {messageid="CS_MailSend"}
    msg.receivername = m_uimail_send_name
    msg.title = edit_mailtitle:gettext()
	msg.text = edit_content:gettext()
	msg.coin = coin
    msg.itemuuid = m_uimail_send_itemuuid
    msg.itemcount = m_uimail_send_itemcount
    c_send(msg)
    m_uimail_main:close()
end
