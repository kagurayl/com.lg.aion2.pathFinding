
m_uiicc_create = uipanel_createhandle("icc/icc_create", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))

function icc_create_onopen()
    m_uiicc_create:setwidgetdelegate("button_ok", icc_create_delegate_ok)
    m_uiicc_create:setwidgetdelegate("image_bg/button_close", icc_create_delegate_close)
    local text_cost = m_uiicc_create:getwidget("text_cost")
    text_cost:settext("ICC_CREATE_COST", icc_create_cost)
end

function icc_create_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccCreate"}
        msg.name = data
        msg.npcactorid = m_uiicc_create.npcatorid
        c_send(msg)
        m_uiicc_create:close()
    end
end

function icc_create_delegate_ok()
    local edit_input = m_uiicc_create:getwidget("edit_input")
    local name = edit_input:gettext()
    if name ~= nil and string.len(name) > 0 then
        local confirmtext = c_textformat("ICC_CREATE_CONFIRM", name)
        messagebox_confirm(confirmtext, icc_create_confirm, name)
    end
end

function icc_create_delegate_close()
    m_uiicc_create:close()
end
