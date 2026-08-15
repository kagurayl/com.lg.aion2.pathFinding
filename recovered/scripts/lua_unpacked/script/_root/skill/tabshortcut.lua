local tabshortcuttype =
{
	skillbar = 1,
 	actionbar = 2,
}

local m_tabshortcut_page = 1
local m_tabshortcut_skillbarslot = nil
local m_tabshortcut_actionbarslot = nil
local m_tabshortcut_selectslot = nil
local m_tabshortcut_selectslotpage = nil
local m_tabshortcut_preselecttime = 0
local m_tabshortcut_editing = false

function skill_tabshortcut_init()
    m_tabshortcut_page = gamesetting_getnumber("SHORTCUTPAGE")
    m_tabshortcut_skillbarslot = {}
    m_tabshortcut_actionbarslot = {}
    m_tabshortcut_selectslot = nil
    m_tabshortcut_preselecttime = 0
    m_tabshortcut_editing = false
    m_uiskill_main:setwidgetdelegate("tab_shortcut/image_editcover", skill_tabshortcut_delegate_editcover)
    m_uiskill_main:setwidgetdelegate("tab_shortcut/button_pageprev", skill_tabshortcut_delegate_pageprev)
    m_uiskill_main:setwidgetdelegate("tab_shortcut/button_pagenext", skill_tabshortcut_delegate_pagenext)

    for i=1,skill_skillbarslotmax do
		local slotname = string.format("tab_shortcut/slot_%d", i)
		local slot = {}
        slot.slottype = tabshortcuttype.skillbar
		slot.slotindex = i
        slot.slotroot = m_uiskill_main:getwidget(slotname)
        slot.image_icon = m_uiskill_main:getwidget(string.format("%s/image_icon", slotname))
        slot.text_count = m_uiskill_main:getwidget(string.format("%s/text_count", slotname))
        slot.image_select = m_uiskill_main:getwidget(string.format("%s/image_select", slotname))
        slot.image_select:setvisible(false)
        slot.image_remove = m_uiskill_main:getwidget(string.format("%s/image_remove", slotname))
        slot.image_remove:setvisible(false)
        slot.slotroot:setdelegate(skill_tabshortcut_delegate_skillbar)
        slot.slotroot.slot = slot
		m_tabshortcut_skillbarslot[i] = slot
	end

    for i=1,skill_actionbarslotmax do
        local slot = {}
        slot.slottype = tabshortcuttype.actionbar
		slot.slotindex = i
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local slotname = string.format("tab_shortcut/line_%d/slot_%d", lineindex, slotindex)
        slot.slotroot = m_uiskill_main:getwidget(slotname)
        slot.image_icon = m_uiskill_main:getwidget(string.format("%s/image_icon", slotname))
        slot.text_count = m_uiskill_main:getwidget(string.format("%s/text_count", slotname))
        slot.image_select = m_uiskill_main:getwidget(string.format("%s/image_select", slotname))
        slot.image_select:setvisible(false)
        slot.image_remove = m_uiskill_main:getwidget(string.format("%s/image_remove", slotname))
        slot.image_remove:setvisible(false)
        slot.slotroot:setdelegate(skill_tabshortcut_delegate_actionbar)
        slot.slotroot.slot = slot
		m_tabshortcut_actionbarslot[i] = slot
	end

    skill_tabshortcut_updateui()
    event_register(eventtype.update, skill_tabshortcut_update, m_uiskill_main)
end

function skill_tabshortcut_getslot(slottype, slotpage, slotindex)
    if slottype == tabshortcuttype.skillbar then
        return playerskill_getskillbarslot(slotpage, slotindex)
    elseif slottype == tabshortcuttype.actionbar then
        return playerskill_getactionbarslot(slotindex)
    end
    return nil
end

function skill_tabshortcut_update()
    if m_tabshortcut_preselecttime > 0 and time_game - m_tabshortcut_preselecttime > 0.5 then
        m_tabshortcut_preselecttime = 0
        if m_tabshortcut_selectslot ~= nil then
            local slot = skill_tabshortcut_getslot(m_tabshortcut_selectslot.slottype, m_tabshortcut_page, m_tabshortcut_selectslot.slotindex)
            if slot ~= nil then
                m_tabshortcut_editing = true
                skill_tabshortcut_updateui()
            end
        end
    end
end

function skill_tabshortcut_updateui()
    if not m_uiskill_main:alive() then
        return
    end

    skill_main_setdesctext("tab_shortcut", "", "")

    local text_tipsedit = m_uiskill_main:getwidget("tab_shortcut/text_tipsedit")
    if m_tabshortcut_editing then
        text_tipsedit:settext("SKILL_SHORTCUT_TIPSEDITING")
        text_tipsedit:setcolor(0,1,0,1)
    else
        text_tipsedit:settext("SKILL_SHORTCUT_TIPSEDIT")
        text_tipsedit:setcolor(0.77,0.77,0.77,1)
    end

    local text_page = m_uiskill_main:getwidget("tab_shortcut/text_page")
    text_page:settext(m_tabshortcut_page)

    if m_tabshortcut_selectslot ~= nil then
        local slot = skill_tabshortcut_getslot(m_tabshortcut_selectslot.slottype, m_tabshortcut_page, m_tabshortcut_selectslot.slotindex)
        if slot ~= nil then
            if slot.type == csvskillslottype.skill then
                skill_main_setskilldesc("tab_shortcut", csvskill_getfromid(slot.skillid), true)
            elseif slot.type == csvskillslottype.preset then
                skill_main_setpresetdesc("tab_shortcut", playerskillpreset_getpreset(slot.uuid))
            elseif slot.type == csvskillslottype.social then
                skill_main_setsocialdesc("tab_shortcut", csvskillsocial_getfromid(slot.skillid))
            elseif slot.type == csvskillslottype.item then
                skill_main_setitemdesc("tab_shortcut", csvitem_getfromid(slot.skillid))
            elseif slot.type == csvskillslottype.crafting then
                skill_main_setskilldesc("tab_shortcut", csvskill_getfromid(slot.skillid))
            end
        else
            skill_main_setdesctext("tab_shortcut", "", "")
        end
    else
        skill_main_setdesctext("tab_shortcut", "", "")
    end

    for i=1,#m_tabshortcut_skillbarslot do
        local slot = m_tabshortcut_skillbarslot[i]
        local select = m_tabshortcut_selectslot ~= nil and m_tabshortcut_selectslot.slottype == tabshortcuttype.skillbar and m_tabshortcut_selectslot.slotindex == i and m_tabshortcut_page == m_tabshortcut_selectslotpage
        local editing = select and m_tabshortcut_editing and m_tabshortcut_page == m_tabshortcut_selectslotpage
        skill_tabshortcut_updateslot(slot, playerskill_getskillbarslot(m_tabshortcut_page, i), select, editing)
    end

    for i=1,#m_tabshortcut_actionbarslot do
        local slot = m_tabshortcut_actionbarslot[i]
        local select = m_tabshortcut_selectslot ~= nil and m_tabshortcut_selectslot.slottype == tabshortcuttype.actionbar and m_tabshortcut_selectslot.slotindex == i
        local editing = select and m_tabshortcut_editing
        skill_tabshortcut_updateslot(slot, playerskill_getactionbarslot(i), select, editing)
    end
end

function skill_tabshortcut_updateslot(slot, slotskill, select, editing)
    slot.image_icon:setvisible(slotskill ~= nil)
    slot.text_count:setvisible(slotskill ~= nil)
    slot.image_select:setvisiblenothit(select and not editing)
    slot.image_remove:setvisiblenothit(editing)
    if editing then
        slot.image_icon:setcolor(0.5,0.5,0.5,1.0)
    else
        slot.image_icon:setcolor(1,1,1,1)
    end
    if slotskill == nil then
        return
    end
    if slotskill.type == csvskillslottype.skill then
        local config_skill = csvskill_getfromid(slotskill.skillid)
        if config_skill ~= nil then
            local config_toplevel = playerskill_gettoplevelavailable(config_skill)
            if config_toplevel ~= nil then
                config_skill = config_toplevel
            end
            slot.image_icon:seticon(config_skill.icon)
            slot.text_count:settext("")
        end
    elseif slotskill.type == csvskillslottype.preset then
        local preset = playerskillpreset_getpreset(slotskill.uuid)
        if preset ~= nil then
            slot.image_icon:seticon(playerskillpreset_geticon(preset.icon))
            slot.text_count:settext("")
        end
    elseif slotskill.type == csvskillslottype.social then
        local config_social = csvskillsocial_getfromid(slotskill.skillid)
        if config_social ~= nil then
            slot.image_icon:seticon(config_social.icon)
            slot.text_count:settext("")
        end
    elseif slotskill.type == csvskillslottype.item then
        local config_item = csvitem_getfromid(slotskill.skillid)
        if config_item ~= nil then                    
            local itemcount = 0
            if csvitem_isequip(config_item) then
                if playeritem_getfromuuid(slotskill.uuid) ~= nil then
                    itemcount = 1
                end
            else
                itemcount = playeritem_getcount(config_item.id)
            end
            slot.image_icon:seticon(config_item.icon)
            slot.text_count:settext(itemcount)
        end
    elseif slotskill.type == csvskillslottype.crafting then
        local config_crafting = csvskill_getfromid(slotskill.skillid)
        if config_crafting ~= nil then
            slot.image_icon:seticon(config_crafting.icon)
            local craftingskilllevel = playerskill_getcraftingskilllevel(slotskill.skillid)
            if craftingskilllevel ~= nil then
                slot.text_count:settext(craftingskilllevel)
            end
        end
    end
end

function skill_tabshortcut_delegate_editcover(sender, event)
    if m_tabshortcut_editing then
        m_tabshortcut_editing = false
        skill_tabshortcut_updateui()
    end
end

function skill_tabshortcut_delegate_pageprev(sender, event)
    if m_tabshortcut_page > 1 then
        m_tabshortcut_page = m_tabshortcut_page - 1
        skill_tabshortcut_updateui()
    end
end

function skill_tabshortcut_delegate_pagenext(sender, event)
    if m_tabshortcut_page < skill_skillbarpagemax then
        m_tabshortcut_page = m_tabshortcut_page + 1
        skill_tabshortcut_updateui()
    end
end

function skill_tabshortcut_delegate_delete_confirm(ok, data)
    if ok then
        if data.slottype == tabshortcuttype.skillbar then
            local msg = {messageid="CS_SkillBarSlotRemove"}
            msg.page = data.page - 1
            msg.slot = data.slotindex - 1
            c_send(msg)
        else
            local msg = {messageid="CS_ActionBarSlotRemove"}
            msg.slot = data.slotindex - 1
            c_send(msg)
        end
    end
end
local function skill_tabshortcut_sendswitch(src, srcpage, dst, dstpage)
    local slotsrc = skill_tabshortcut_getslot(src.slottype, srcpage, src.slotindex)
    if slotsrc == nil then
        return
    end
    if dst.slottype == tabshortcuttype.skillbar then
        local msg = {messageid="CS_SkillBarSlot"}
        msg.page = dstpage - 1
        msg.slot = dst.slotindex - 1
        msg.type = slotsrc.type
        msg.skillid = slotsrc.skillid
        msg.uuid = slotsrc.uuid
        c_send(msg)
    else
        local msg = {messageid="CS_ActionBarSlot"}
        msg.slot = dst.slotindex - 1
        msg.type = slotsrc.type
        msg.skillid = slotsrc.skillid
        msg.uuid = slotsrc.uuid
        c_send(msg)
    end
end
local function skill_tabshortcut_sendswitchdelete(slot, page)
    local slotdata = skill_tabshortcut_getslot(slot.slottype, page, slot.slotindex)
    if slotdata == nil then
        return
    end
    if slot.slottype == tabshortcuttype.skillbar then
        local msg = {messageid="CS_SkillBarSlotRemove"}
        msg.page = slotdata.page - 1
        msg.slot = slotdata.slot - 1
        c_send(msg)
    else
        local msg = {messageid="CS_ActionBarSlotRemove"}
        msg.slot = slotdata.slot - 1
        c_send(msg)
    end
end
local function skill_tabshortcut_switchremove(slot)
    if m_tabshortcut_selectslot == nil then
        return
    end
    local sameslot = false
    if m_tabshortcut_selectslot.slottype == tabshortcuttype.skillbar then
        sameslot = m_tabshortcut_selectslot.slottype == slot.slottype and m_tabshortcut_selectslot.slotindex == slot.slotindex and m_tabshortcut_page == m_tabshortcut_selectslotpage
    else
        sameslot = m_tabshortcut_selectslot.slottype == slot.slottype and m_tabshortcut_selectslot.slotindex == slot.slotindex
    end
    if sameslot then
        local data = {}
        data.slottype = m_tabshortcut_selectslot.slottype
        data.slotindex = m_tabshortcut_selectslot.slotindex
        data.page = m_tabshortcut_page
        messagebox_confirm("SKILL_SHORTCUT_TIPSDELETE", skill_tabshortcut_delegate_delete_confirm, data, nil, nil, "")
    else
        skill_tabshortcut_sendswitchdelete(m_tabshortcut_selectslot, m_tabshortcut_selectslotpage)
        skill_tabshortcut_sendswitchdelete(slot, m_tabshortcut_page)
        skill_tabshortcut_sendswitch(m_tabshortcut_selectslot, m_tabshortcut_selectslotpage, slot, m_tabshortcut_page)
        skill_tabshortcut_sendswitch(slot, m_tabshortcut_page, m_tabshortcut_selectslot, m_tabshortcut_selectslotpage)
    end
    m_tabshortcut_selectslot = nil
    m_tabshortcut_editing = false
    skill_tabshortcut_updateui()
end

function skill_tabshortcut_delegate_skillbar(sender, event)
    if m_tabshortcut_editing then
        if event.name == "mousedown" then
            m_tabshortcut_preselecttime = time_game
        elseif event.name == "mouseup" then
            if m_tabshortcut_preselecttime > 1.0 and time_game - m_tabshortcut_preselecttime < 1.0 then
                m_tabshortcut_preselecttime = 0
                skill_tabshortcut_switchremove(sender.slot)
            end
        end
    else
        if event.name == "mousedown" then
            m_tabshortcut_preselecttime = time_game
            m_tabshortcut_selectslot = sender.slot
            m_tabshortcut_selectslotpage = m_tabshortcut_page
            skill_tabshortcut_updateui()
        elseif event.name == "mouseup" then
            m_tabshortcut_preselecttime = 0
        end
    end
end

function skill_tabshortcut_delegate_actionbar(sender, event)
    if m_tabshortcut_editing then
        if event.name == "mousedown" then
            m_tabshortcut_preselecttime = time_game
        elseif event.name == "mouseup" then
            if m_tabshortcut_preselecttime > 1.0 and time_game - m_tabshortcut_preselecttime < 1.0 then
                m_tabshortcut_preselecttime = 0
                skill_tabshortcut_switchremove(sender.slot)
            end
        end
    else
        if event.name == "mousedown" then
            m_tabshortcut_preselecttime = time_game
            m_tabshortcut_selectslot = sender.slot
            m_tabshortcut_selectslotpage = m_tabshortcut_page
            skill_tabshortcut_updateui()
        elseif event.name == "mouseup" then
            m_tabshortcut_preselecttime = 0
        end
    end
end
