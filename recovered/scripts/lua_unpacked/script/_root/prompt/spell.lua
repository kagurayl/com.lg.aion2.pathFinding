
spellcolor =
{
    normal = 1,
    red = 2,
}

spellstate =
{
    normal = 1,
    cancel = 2,
	complete = 3,
}

local m_uispell_ui = uipanel_createhandle("prompt/spell", uilayer.top, uiflag.scale)
local m_uispell_hidetime = 0.5

function spell_create(name, color, timestart, timelength, data)
	if timelength == 0 then
		spell_close()
		return
	end
	m_uispell_ui:open()
	m_uispell_ui:setvisible(true)
	m_uispell_ui:setopacity(1.0)

	local lineindex = 1
	if gamesetting_getnumber("ACTIONLINE2") > 0 then
		lineindex = 2
	end
	if gamesetting_getnumber("ACTIONLINE3") > 0 then
		lineindex = 3
	end
	if gamesetting_getnumber("ACTIONLINE4") > 0 then
		lineindex = 4
	end

	m_uispell_ui:setwidgetvisiblenothit("spell_1", lineindex == 1)
	m_uispell_ui:setwidgetvisiblenothit("spell_2", lineindex == 2)
	m_uispell_ui:setwidgetvisiblenothit("spell_3", lineindex == 3)
	m_uispell_ui:setwidgetvisiblenothit("spell_4", lineindex == 4)
	m_uispell_ui.lineheader = "spell_" .. lineindex .. "/"

	m_uispell_ui:setwidgetvisiblenothit(m_uispell_ui.lineheader .. "progress_normal", color == spellcolor.normal)
	m_uispell_ui:setwidgetvisiblenothit(m_uispell_ui.lineheader .. "progress_red", color == spellcolor.red)
	m_uispell_ui.timestart = timestart
	m_uispell_ui.timelength = timelength
	m_uispell_ui.data = data
	if color == spellcolor.normal then
		m_uispell_ui.progress = m_uispell_ui:getwidget(m_uispell_ui.lineheader .. "progress_normal")
	elseif color == spellcolor.red then
		m_uispell_ui.progress = m_uispell_ui:getwidget(m_uispell_ui.lineheader .. "progress_red")
	end
	local text_name = m_uispell_ui:getwidget(m_uispell_ui.lineheader .. "text_name")
	text_name:settext(name)
	m_uispell_ui.state = spellstate.normal
end

function spell_onopen()
	event_register(eventtype.update, spell_update, m_uispell_ui)
end

function spell_close()
	m_uispell_ui:setvisible(false)
end

function spell_getdata()
	return m_uispell_ui.data
end

function spell_setstate(state)
	if m_uispell_ui:null() then
		return
	end
	m_uispell_ui.state = state
	m_uispell_ui.statestarttime = time_game
	if state == spellstate.cancel then
		local text_name = m_uispell_ui:getwidget(m_uispell_ui.lineheader .. "text_name")
		text_name:settext("HOME_SPELL_CANCEL")
	end
end

function spell_update()
	if m_uispell_ui.state == nil then
		return
	end
	if m_uispell_ui.state == spellstate.normal then
		local percent = (time_game - m_uispell_ui.timestart) / m_uispell_ui.timelength
		if percent > 1.5 then
			spell_setstate(spellstate.complete)
		end
		m_uispell_ui.progress:setpercent(math.clamp(percent, 0.0, 1.0))
	elseif m_uispell_ui.state == spellstate.cancel then
		local opacity = 1.0 - (time_game - m_uispell_ui.statestarttime) / m_uispell_hidetime
		if opacity > 0.0 then
			m_uispell_ui:setopacity(opacity)
		else
			m_uispell_ui.state = nil
			spell_close()
		end
	elseif m_uispell_ui.state == spellstate.complete then
		local opacity = 1.0 - (time_game - m_uispell_ui.statestarttime) / m_uispell_hidetime
		if opacity > 0.0 then
			m_uispell_ui:setopacity(opacity)
		else
			m_uispell_ui.state = nil
			spell_close()
		end
	end
end
