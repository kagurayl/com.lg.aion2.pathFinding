
m_uiicc_logo = uipanel_createhandle("icc/icc_logo", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))
local m_icclogo_inst = {logo = "icc/inst_logo"}

function icc_logo_onopen()
    m_uiicc_logo:setwidgetdelegate("image_bg/button_close", icc_logo_delegate_close)
    m_uiicc_logo.selectlogo = playerattr_info.icclogo
    local button_ok = m_uiicc_logo:getwidget("button_ok")
    button_ok:setenable(false)
    button_ok:setdelegate(icc_logo_delegate_ok)
    icc_logo_updateui()

    local list_logo = m_uiicc_logo:getwidget("list_logo")
    list_logo:init(uilistflag.vertical)

    local line = nil
    local iconindex = 0
    for i=0,49 do
        if line == nil then
            line = list_logo:add(m_icclogo_inst.logo)
            iconindex = 0
        end
        iconindex = iconindex + 1
        local image_logo = line:getwidget("image_logo_" .. iconindex)
        if image_logo == nil then
            line = list_logo:add(m_icclogo_inst.logo)
            iconindex = 1
            image_logo = line:getwidget("image_logo_1")
        end
        image_logo:setvisible(true)
        image_logo:setraw(icc_getlogofile(i))
        image_logo:setdelegate(icc_logo_delegate_logo)
        image_logo.iconindex = i
    end
    while true do
        iconindex = iconindex + 1
        local image_logo = line:getwidget("image_logo_" .. iconindex)
        if image_logo == nil then
            break
        end
        image_logo:setvisible(false)
    end
end

function icc_logo_updateui()
    if m_uiicc_logo:null() then
        return
    end
    if playerattr_icc == nil then
        m_uiicc_logo:close()
        return
    end
    local image_current = m_uiicc_logo:getwidget("image_current")
    image_current:setraw(icc_getlogofile(playerattr_info.icclogo))

    local image_select = m_uiicc_logo:getwidget("image_select")
    image_select:setraw(icc_getlogofile(m_uiicc_logo.selectlogo))

    local button_ok = m_uiicc_logo:getwidget("button_ok")
    button_ok:setenable(playerattr_info.icclogo ~= m_uiicc_logo.selectlogo)
end

function icc_logo_delegate_ok()
    local msg = {messageid="CS_IccSetLogo"}
    msg.logo = m_uiicc_logo.selectlogo
    msg.npcactorid = m_uiicc_logo.npcatorid
    c_send(msg)
end

function icc_logo_delegate_logo(sender, event)
    m_uiicc_logo.selectlogo = sender.iconindex
    icc_logo_updateui()
end

function icc_logo_delegate_close()
    m_uiicc_logo:close()
end
