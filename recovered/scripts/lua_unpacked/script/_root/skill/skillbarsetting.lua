
m_uiskill_setting = uipanel_createhandle("skill/skill_setting", uilayer.cover, uiflag.escapeclose)

function skill_setting_onopen()
    m_uiskill_setting.skillbarslot = {}
	for i=1,skill_skillbarslotmax do
		local slotname = string.format("slot_%d", i)
		local slot = {}
        slot.slotroot = m_uiskill_setting:getwidget(slotname)
        slot.image_icon = m_uiskill_setting:getwidget(string.format("%s/image_icon", slotname))
        slot.text_count = m_uiskill_setting:getwidget(string.format("%s/text_count", slotname))
        slot.image_select = m_uiskill_setting:getwidget(string.format("%s/image_select", slotname))
        slot.image_select:setvisible(false)
        slot.image_remove = m_uiskill_setting:getwidget(string.format("%s/image_remove", slotname))
        slot.image_remove:setvisible(false)
        slot.slotroot:setdelegate(skill_setting_delegate_skillbar)
		slot.slotroot.slotindex = i
		m_uiskill_setting.skillbarslot[i] = slot
	end
    
    m_uiskill_setting.actionbarslot = {}
    for i=1,skill_actionbarslotmax do
        local slot = {}
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local slotname = string.format("line_%d/slot_%d", lineindex, slotindex)
        slot.slotroot = m_uiskill_setting:getwidget(slotname)
        slot.image_icon = m_uiskill_setting:getwidget(string.format("%s/image_icon", slotname))
        slot.text_count = m_uiskill_setting:getwidget(string.format("%s/text_count", slotname))
        slot.image_select = m_uiskill_setting:getwidget(string.format("%s/image_select", slotname))
        slot.image_select:setvisible(false)
        slot.image_remove = m_uiskill_setting:getwidget(string.format("%s/image_remove", slotname))
        slot.image_remove:setvisible(false)
        slot.slotroot:setdelegate(skill_setting_delegate_actionbar)
		slot.slotroot.slotindex = i
		m_uiskill_setting.actionbarslot[i] = slot
	end

    if m_uiskill_setting.page == nil then
        m_uiskill_setting.page = gamesetting_getnumber("SHORTCUTPAGE")
    end
    local text_page = m_uiskill_setting:getwidget("text_page")
	text_page:settext(m_uiskill_setting.page)

    m_uiskill_setting:setwidgetdelegate("button_pageprev", skill_setting_delegate_pageprev)
    m_uiskill_setting:setwidgetdelegate("button_pagenext", skill_setting_delegate_pagenext)
    m_uiskill_setting:setwidgetdelegate("image_bg", skill_setting_delegate_close)

	skill_setting_updateui()
end

function skill_setting_opensetting(slottype, skillid, uuid)
    m_uiskill_setting:open()
    m_uiskill_setting.dragtype = slottype
    m_uiskill_setting.dragid = skillid
    m_uiskill_setting.draguuid = uuid

    local text_tips1 = m_uiskill_setting:getwidget("text_tips1")
    if slottype == csvskillslottype.skill then
        local config_skill = csvskill_getfromid(skillid)
        if config_skill ~= nil then
            text_tips1:settext("SKILL_SETTING_TIPSSELECT", config_skill.name)
        end
    elseif slottype == csvskillslottype.preset then
        local preset = playerskillpreset_getpreset(uuid)
        if preset ~= nil then
            text_tips1:settext("SKILL_SETTING_TIPSSELECT", c_textformat("SKILL_SHORTCUT_PRESETDESC", preset.name))
        end
    elseif slottype == csvskillslottype.social then
        local config_social = csvskillsocial_getfromid(skillid)
        if config_social ~= nil then
            text_tips1:settext("SKILL_SETTING_TIPSSELECT", config_social.name)
        end
    elseif slottype == csvskillslottype.item then
        local config_item = csvitem_getfromid(skillid)
        if config_item ~= nil then                    
            text_tips1:settext("SKILL_SETTING_TIPSSELECT", config_item.name)
        end
    elseif slottype == csvskillslottype.crafting then
        local config_crafting = csvskill_getfromid(skillid)
        if config_crafting ~= nil then
            text_tips1:settext("SKILL_SETTING_TIPSSELECT", config_crafting.name)
        end
    end
end

function skill_setting_updateui()
    if m_uiskill_setting:null() then
        return
    end
    for i=1, #m_uiskill_setting.skillbarslot do
        local slot = m_uiskill_setting.skillbarslot[i]
        skill_tabshortcut_updateslot(slot, playerskill_getskillbarslot(m_uiskill_setting.page, i), false, false)
    end

    for i=1, #m_uiskill_setting.actionbarslot do
        local slot = m_uiskill_setting.actionbarslot[i]
        skill_tabshortcut_updateslot(slot, playerskill_getactionbarslot(i), false, false)
    end
end

function skill_setting_setpage(page)
	local text_page = m_uiskill_setting:getwidget("text_page")
	text_page:settext(m_uiskill_setting.page)
    skill_setting_updateui()
end

function skill_setting_delegate_pageprev()
    if m_uiskill_setting.page > 1 then
        m_uiskill_setting.page = m_uiskill_setting.page - 1
        skill_setting_setpage()
    end
end

function skill_setting_delegate_pagenext()
    if m_uiskill_setting.page < skill_skillbarpagemax then
        m_uiskill_setting.page = m_uiskill_setting.page + 1
		skill_setting_setpage()
    end
end

local function skill_setting_setcomplete()
    m_uiskill_setting.dragtype = nil
    local text_tips1 = m_uiskill_setting:getwidget("text_tips1")
    text_tips1:setvisible(false)
end

function skill_setting_delegate_skillbar(sender, event)
    if event.name == "mousedown" then
        if m_uiskill_setting.dragtype ~= nil then
            local msg = {messageid="CS_SkillBarSlot"}
            msg.page = m_uiskill_setting.page - 1
            msg.slot = sender.slotindex - 1
            msg.type = m_uiskill_setting.dragtype
            msg.skillid = m_uiskill_setting.dragid
            msg.uuid = m_uiskill_setting.draguuid
            c_send(msg)
            skill_setting_setcomplete()
        end
    end
end

function skill_setting_delegate_actionbar(sender, event)
    if event.name == "mousedown" then
        if m_uiskill_setting.dragtype ~= nil then
            local msg = {messageid="CS_ActionBarSlot"}
            msg.slot = sender.slotindex - 1
            msg.type = m_uiskill_setting.dragtype
            msg.skillid = m_uiskill_setting.dragid
            msg.uuid = m_uiskill_setting.draguuid
            c_send(msg)
            skill_setting_setcomplete()
        end
    end
end

function skill_setting_delegate_close()
    m_uiskill_setting:close()
end
