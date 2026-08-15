
local m_uimail_recv_inst = {mail = "mail/inst_mail"}

function mail_recv_onopen()
    m_uimail_main:setwidgetdelegate("tab_recv/button_selectall", mail_recv_delegate_selectall)
    m_uimail_main:setwidgetdelegate("tab_recv/button_getall", mail_recv_delegate_getall)
    m_uimail_main:setwidgetdelegate("tab_recv/button_delete", mail_recv_delegate_delete)
    local list_recv = m_uimail_main:getwidget("tab_recv/list_recv")
    list_recv:init(uilistflag.vertical)
    list_recv:setclickdelegate(mail_recv_delegate_list)
end

local function mail_recv_geticon(mail)
    if mail.type == mailtype.player then
        local id = 1
        if mail.hascoin > 0 and mail.hasitem > 0 then
            id = 4
        elseif mail.hascoin > 0 then
            id = 2
        elseif mail.hasitem > 0 then
            id = 3
        end
        if mail.readstate == 0 then
            return string.format("sp1/mail%d_normal", id)
        else
            return string.format("sp1/mail%d_read", id)
        end
    else
        if mail.readstate == 0 then
            return "sp1/mail9_normal"
        end
        if mail.hascoin == 0 and mail.hasitem == 0 then
            return "sp1/mail9_empty"
        else
            return "sp1/mail9_read"
        end
    end
end

function mail_recv_updateui()
    if m_uimail_tab ~= mailtab.recv then
        m_uimail_main:setwidgetvisible("tab_recv", false)
        return
    end
    m_uimail_main:setwidgetvisible("tab_recv", true)

    local list_recv = m_uimail_main:getwidget("tab_recv/list_recv")
    list_recv:savestate()
    list_recv:clear()
    for i=1,#playerattr_mail do
        local mail = playerattr_mail[i]
        local line = list_recv:add(m_uimail_recv_inst.mail, mail.mailid, mail.mailid)

        local image_icon = line:getwidget("image_icon")
        image_icon:setsprite(mail_recv_geticon(mail))

        local text_sender = line:getwidget("text_sender")
        local text_title = line:getwidget("text_title")
        if mail.type == mailtype.player then
            text_sender:settextrawscale(mail.sender)
            text_title:settextrawscale(mail.title)
        else
            text_sender:settextscale(mail.sender)
            text_title:settextscale(mail.title)
        end
    end
    list_recv:restorestate()

    local text_count = m_uimail_main:getwidget("tab_recv/text_count")
    text_count:settext(string.format("%d/100", #playerattr_mail))
end

function mail_recv_delegate_list(line, event, data)
    m_uimail_openid = data or 0
    mail_read_updateui()
end

function mail_recv_delegate_selectall()
    local list_recv = m_uimail_main:getwidget("tab_recv/list_recv")
    list_recv:selectall()
end

function mail_recv_delegate_getall()
    local list_recv = m_uimail_main:getwidget("tab_recv/list_recv")
    local selectdata = list_recv:getselectarray()
    if selectdata ~= nil and #selectdata > 0 then
        local msg = {messageid="CS_MailGet"}
        msg.actorid = m_uimail_main.npcactorid
        msg.mailid = selectdata
        c_send(msg)
    end
end

function mail_recv_delegate_delete()
    local list_recv = m_uimail_main:getwidget("tab_recv/list_recv")
    local selectdata = list_recv:getselectarray()
    if selectdata ~= nil and #selectdata > 0 then
        local msg = {messageid="CS_MailDelete"}
        msg.mailid = selectdata
        c_send(msg)
    end
end
