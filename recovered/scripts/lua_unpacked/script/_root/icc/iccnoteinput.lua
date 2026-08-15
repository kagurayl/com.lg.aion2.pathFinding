
m_uiicc_noteinput = uipanel_createhandle("icc/icc_noteinput", uilayer.top, uiflag.escapeclose)

function icc_noteinput_open()
    m_uiicc_main:setwidgetvisible("tab_noteinput", true)
    m_uiicc_main:setwidgetdelegate("tab_noteinput/button_ok", icc_noteinput_delegate_ok)
    m_uiicc_main:setwidgetdelegate("tab_noteinput/image_bg/button_close", icc_noteinput_delegate_close)
end

function icc_noteinput_delegate_ok()
    local edit_input = m_uiicc_main:getwidget("tab_noteinput/edit_input")
    local msg = {messageid="CS_IccNote"}
    msg.note = edit_input:gettext()
    c_send(msg)
    m_uiicc_main:setwidgetvisible("tab_noteinput", false)
end

function icc_noteinput_delegate_close()
    m_uiicc_main:setwidgetvisible("tab_noteinput", false)
end
