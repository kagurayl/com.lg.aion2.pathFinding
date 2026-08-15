
m_uiskillbar = uipanel_createhandle("home/skillbar", uilayer.bottom, uiflag.scale)

function skillbar_onopen()
    m_uiskillbar.slot = {}
	for i=1,skill_skillbarslotmax do
		local slotname = string.format("slot_%d", i)
        local markername = string.format("marker_%d", i)
        local keyname = string.format("KEY_SKILL_%d", i)
		m_uiskillbar.slot[i] = skillslot_createslot(m_uiskillbar, slotname, markername, keyname)
	end
    
    local text_page = m_uiskillbar:getwidget("text_page")
	text_page:settext(gamesetting_getnumber("SHORTCUTPAGE"))

    m_uiskillbar:setwidgetdelegate("button_tabselect", skillbar_delegate_tabselect)
    m_uiskillbar:setwidgetdelegate("button_pageprev", skillbar_delegate_pageprev)
    m_uiskillbar:setwidgetdelegate("button_pagenext", skillbar_delegate_pagenext)
    m_uiskillbar:setwidgetdelegate("button_jump", skillbar_delegate_jump)

	skillbar_updateui()
	event_register(eventtype.update, skillbar_update, m_uiskillbar)
    event_register(eventtype.item, skillbar_updateui, m_uiskillbar)
end

function skillbar_updateui()
    if m_uiskillbar:null() then
        return
    end
    local hideemptyskillbar = gamesetting_getnumber("HIDEEMPTYSKILLBAR") > 0
    if playerattr_isvehicle() then
        local lambda = csvskillbuff_getscript(m_me.actionmain.buffvehicle, "vehicle")
        if lambda ~= nil then
            for i=1,lambda.variablecount do
                local slot = m_uiskillbar.slot[i]
                local attr = {type = csvskillslottype.skill, skillid = lambda.variable[i].integer}
                skillslot_updateslot(slot, attr, hideemptyskillbar)
            end
            for i=lambda.variablecount + 1,#m_uiskillbar.slot do
                local slot = m_uiskillbar.slot[i]
                skillslot_updateslot(slot, nil, hideemptyskillbar)
            end
            return
        end
    end

    local page = gamesetting_getnumber("SHORTCUTPAGE")
    for i=1,#playerattr_skillslot do
        local attr = playerattr_skillslot[i]
        if attr.page == page and attr.slot > 0 and attr.slot <= #m_uiskillbar.slot then
            m_uiskillbar.slot[attr.slot].attr = attr
        end
    end
    for i=1, #m_uiskillbar.slot do
        local slot = m_uiskillbar.slot[i]
        local attr = slot.attr
        slot.attr = nil
        skillslot_updateslot(slot, attr, hideemptyskillbar)
    end
end

function skillbar_keydown(keyname)
    if m_uiskillbar:alive() then
        for i=1, #m_uiskillbar.slot do
            local slot = m_uiskillbar.slot[i]
            if slot.keyname == keyname then
                skillslot_executeslot(slot)
            end
        end
    end
end

function skillbar_update()
	for i=1, #m_uiskillbar.slot do
		skillslot_updatecd(m_uiskillbar.slot[i])
	end
end

function skillbar_setpage(page)
	local text_page = m_uiskillbar:getwidget("text_page")
	text_page:settext(page)
	gamesetting_modify("SHORTCUTPAGE", page)
    skillbar_updateui()
end

function skillbar_delegate_tabselect()
    systemskill_tabselect(nil)
end

function skillbar_delegate_pageprev()
    local page = gamesetting_getnumber("SHORTCUTPAGE")
    if page > 1 then
        skillbar_setpage(page - 1)
    end
end

function skillbar_delegate_pagenext()
    local page = gamesetting_getnumber("SHORTCUTPAGE")
    if page < skill_skillbarpagemax then
		skillbar_setpage(page + 1)
    end
end

function skillbar_delegate_jump()
    inputkey_jump()
end
