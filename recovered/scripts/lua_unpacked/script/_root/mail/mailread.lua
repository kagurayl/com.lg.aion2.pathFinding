
function mail_read_onopen()
    m_uimail_main:setwidgetdelegate("tab_read/button_reply", mail_read_delegate_reply)
    m_uimail_main:setwidgetdelegate("tab_read/button_get", mail_read_delegate_get)
end

function mail_read_updateui()
    if m_uimail_tab ~= mailtab.recv then
        m_uimail_main:setwidgetvisible("tab_read", false)
        m_uimail_main:setwidgetvisible("tab_recv/text_none", false)
        return
    end
    local mail = nil
    for i=1,#playerattr_mail do
        if playerattr_mail[i].mailid == m_uimail_openid then
            mail = playerattr_mail[i]
            break
        end
    end
    if mail ~= nil then
        if mail.text == nil then
            local msg = {messageid="CS_MailRead"}
            msg.mailid = m_uimail_openid
            c_send(msg)
            mail = nil
        end
    end
    m_uimail_main:setwidgetvisible("tab_read", mail ~= nil)
    m_uimail_main:setwidgetvisible("tab_recv/text_none", mail == nil)
    if mail == nil then
        return
    end

    local text_sender = m_uimail_main:getwidget("tab_read/text_sender")
    text_sender:settext(mail.sender)

    local text_mailtitle = m_uimail_main:getwidget("tab_read/text_mailtitle")
    text_mailtitle:settext(mail.title)
   
    local text_content = m_uimail_main:getwidget("tab_read/text_content")
    local mailtext = mail.text
    if mail.type == mailtype.abyss then
        local subtext = string.split(mail.text, ",")
        local textkey = nil
        if subtext[2] == "1" then
            textkey = "MAIL_ABYSS_OCCUPY_BODY"
        else
            textkey = "MAIL_ABYSS_DEFENDER_BODY"
        end
        local config_castle = c_config_getmetaid(configid.abyss_castle, string.tointeger(subtext[1]))
        if config_castle ~= nil then
            mailtext = c_textformat(textkey, config_castle.name)
        end
    end
    text_content:settext(mailtext)
    
    local text_date = m_uimail_main:getwidget("tab_read/text_date")
    text_date:settext(mail.date)
    
    local text_coin = m_uimail_main:getwidget("tab_read/text_coin")
    text_coin:settext(mail.coin)
    
    local text_cash = m_uimail_main:getwidget("tab_read/text_cash")
    text_cash:settext(mail.cash)

    local config_item = nil
    if mail.item ~= nil then
        config_item = csvitem_getfromid(mail.item.itemid)
    end
    local itemvisible = config_item ~= nil
    m_uimail_main:setwidgetvisible("tab_read/image_icon", itemvisible)
    m_uimail_main:setwidgetvisible("tab_read/text_itemcount", itemvisible)
    m_uimail_main:setwidgetvisible("tab_read/text_itemname", itemvisible)
    if itemvisible then
        local image_icon = m_uimail_main:getwidget("tab_read/image_icon")
        local text_count = m_uimail_main:getwidget("tab_read/text_itemcount")
        local text_name = m_uimail_main:getwidget("tab_read/text_itemname")
        image_icon:seticon(config_item.icon)
        text_count:settext(mail.item.count)
        local colorname = csvitem_getcolorname(config_item)
        text_name:settext(colorname .. " x" .. mail.item.count)
    end
end

function mail_read_delegate_reply()
    m_uimail_openid = 0
    m_uimail_main:setwidgetvisible("tab_read", false)
end

function mail_read_delegate_get()
    local msg = {messageid="CS_MailGet"}
    msg.actorid = m_uimail_main.npcactorid
    msg.mailid = {}
    msg.mailid[1] = m_uimail_openid
    c_send(msg)
end
