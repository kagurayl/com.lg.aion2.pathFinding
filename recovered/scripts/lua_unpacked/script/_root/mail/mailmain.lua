
local m_uimail_main_inst = {mail = "mail/inst_mail"}

function mail_main_onopen()
    m_uimail_main:setwidgetdelegate("image_bg/button_close", mail_main_delegate_close)
    m_uimail_main:setwidgetdelegate("button_recv", mail_main_delegate_recv)
    m_uimail_main:setwidgetdelegate("button_send", mail_main_delegate_send)
    m_uimail_tab = mailtab.recv
    mail_read_onopen()
    mail_recv_onopen()
    mail_send_onopen()
    mail_main_updateui()
end

function mail_main_updateui()
    if m_uimail_main:null() then
        return
    end
    m_uimail_main:setwidgetenable("button_recv", m_uimail_tab ~= mailtab.recv)
    m_uimail_main:setwidgetenable("button_send", m_uimail_tab ~= mailtab.send)

    mail_recv_updateui()
    mail_read_updateui()
    mail_send_updateui()
end

function mail_main_delegate_recv()
    m_uimail_tab = mailtab.recv
    mail_main_updateui()
end

function mail_main_delegate_send()
    m_uimail_tab = mailtab.send
    mail_main_updateui()
end

function mail_main_delegate_close()
    m_uimail_main:close()
end
