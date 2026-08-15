
local m_uiskill_presetsetting = uipanel_createhandle("skill/skill_presetsetting", uilayer.top, bit.bor(uiflag.escapeclose), AudioOpenUI, AudioCloseUI)

function presetsetting_open(uuid, type)
    m_uiskill_presetsetting:open()
    m_uiskill_presetsetting.checkbox_type1 = m_uiskill_presetsetting:getwidget("checkbox_type1")
    m_uiskill_presetsetting.checkbox_type2 = m_uiskill_presetsetting:getwidget("checkbox_type2")
    m_uiskill_presetsetting.checkbox_type3 = m_uiskill_presetsetting:getwidget("checkbox_type3")
    m_uiskill_presetsetting.checkbox_type1:setdelegate(presetsetting_delegate_type1)
    m_uiskill_presetsetting.checkbox_type2:setdelegate(presetsetting_delegate_type2)
    m_uiskill_presetsetting.checkbox_type3:setdelegate(presetsetting_delegate_type3)
    m_uiskill_presetsetting:setwidgetdelegate("image_bgcover", presetsetting_delegate_close)
    m_uiskill_presetsetting:setwidgetdelegate("image_bg/button_close", presetsetting_delegate_close)
    m_uiskill_presetsetting.presetuuid = uuid
    m_uiskill_presetsetting.presettype = type
    m_uiskill_presetsetting.checkbox_type1:setcheck(type == csvskillpresettype.qte)
    m_uiskill_presetsetting.checkbox_type2:setcheck(type == csvskillpresettype.sequence)
    m_uiskill_presetsetting.checkbox_type3:setcheck(type == csvskillpresettype.auto)
end

local function presetsetting_sendtype(type)
    m_uiskill_presetsetting.checkbox_type1:setcheck(type == csvskillpresettype.qte)
    m_uiskill_presetsetting.checkbox_type2:setcheck(type == csvskillpresettype.sequence)
    m_uiskill_presetsetting.checkbox_type3:setcheck(type == csvskillpresettype.auto)
    local msg = {messageid="CS_SkillPresetSetType"}
    msg.uuid = m_uiskill_presetsetting.presetuuid
    msg.type = type
    c_send(msg)
end

function presetsetting_delegate_type1(sender, event)
    presetsetting_sendtype(csvskillpresettype.qte)
end

function presetsetting_delegate_type2(sender, event)
    presetsetting_sendtype(csvskillpresettype.sequence)
end

function presetsetting_delegate_type3(sender, event)
    presetsetting_sendtype(csvskillpresettype.auto)
end

function presetsetting_delegate_close(sender, event)
    m_uiskill_presetsetting:close()
end
