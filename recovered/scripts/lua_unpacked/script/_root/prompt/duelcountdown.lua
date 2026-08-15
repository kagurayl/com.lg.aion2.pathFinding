
local m_uiduelcountdown = uipanel_createhandle("prompt/duelcountdown", uilayer.top, 0)

function duelcountdown_settime(time)
	m_uiduelcountdown:open()
	m_uiduelcountdown.timestart = time_game
	m_uiduelcountdown.timelength = time
	m_uiduelcountdown.countdown = true
end

function duelcountdown_settext(text, timelength)
	m_uiduelcountdown:open()
	m_uiduelcountdown.timestart = time_game
	m_uiduelcountdown.timelength = timelength
	m_uiduelcountdown.countdown = false
	local text_countdown = m_uiduelcountdown:getwidget("text_countdown")
	text_countdown:settext(text)
end

function duelcountdown_onopen()
	event_register(eventtype.update, duelcountdown_update, m_uiduelcountdown)
end

function duelcountdown_update()
	local time = math.ceil(m_uiduelcountdown.timelength - (time_game - m_uiduelcountdown.timestart))
	if time <= 0 then
		m_uiduelcountdown:close()
		return
	end
	if m_uiduelcountdown.countdown then
		local text_countdown = m_uiduelcountdown:getwidget("text_countdown")
		text_countdown:settext(time)
	end
end
