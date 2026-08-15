
local m_uibugreport = uipanel_createhandle("mail/bugreport", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function bugreport_open()
    if m_uibugreport:alive() then
        return
    end
    m_uibugreport:open()
    m_uibugreport:setwidgetdelegate("image_bg/button_close", bugreport_delegate_close)
    m_uibugreport:setwidgetdelegate("button_ok", bugreport_delegate_ok)
    if m_uibugreport.savetext ~= nil then
        local edit_input = m_uibugreport:getwidget("edit_input")
        edit_input:settext(m_uibugreport.savetext)
    end
end

function bugreport_clear()
    m_uibugreport.savetext = nil
end

function bugreport_delegate_ok()
    local edit_input = m_uibugreport:getwidget("edit_input")
    local text = edit_input:gettext()
    if text == nil or #text == 0 then
        m_uibugreport:close()
        return
    end
    m_uibugreport.savetext = text
    m_uibugreport:close()
    local msg = {messageid="CS_BugReport"}
	msg.text = text
    c_send(msg)
end

function bugreport_delegate_close()
    local edit_input = m_uibugreport:getwidget("edit_input")
    local text = edit_input:gettext()
    if text ~= nil and #text > 0 then
        m_uibugreport.savetext = text
    else
        m_uibugreport.savetext = nil
    end
    m_uibugreport:close()
end
