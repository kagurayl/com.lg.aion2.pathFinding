
matching_type = 
{
	arena50solo = 1,
	arena50free = 2,
	arena55solo = 3,
	arena55free = 4,
	dredgion50solo = 5,
	dredgion50random = 6,
	dredgion50team = 7,
	dredgion55solo = 8,
	dredgion55random = 9,
	dredgion55team = 10,
}

local m_uimatching = uipanel_createhandle("prompt/matching", uilayer.top, uiflag.scale)

local function matching_settitle(type)
	local text_title = m_uimatching:getwidget("image_bg/text_title")
	if type == matching_type.arena50solo or type == matching_type.arena55solo then
		text_title:settext("MATCHING_ARENA_SOLO_TITLE")
	elseif type == matching_type.arena50free or type == matching_type.arena55free then
		text_title:settext("MATCHING_ARENA_FREE_TITLE")
	elseif type == matching_type.dredgion50random or type == matching_type.dredgion55random then
		text_title:settext("MATCHING_DREDGION_RANDOM_TITLE")
	elseif type == matching_type.dredgion50team or type == matching_type.dredgion55team then
		text_title:settext("MATCHING_DREDGION_TEAM_TITLE")
	end
end

function matching_set(type)
	m_uimatching.matching = type
	m_uimatching.timestart = time_game
	m_uimatching.entertime = 0
end

function matching_setenter(type, time)
	m_uimatching.matching = 0
	m_uimatching:open()
	matching_settitle(type)
	m_uimatching.timestart = 0
	m_uimatching.entertime = time_game + time
	matching_update()
end

function matching_open()
	if m_uimatching.matching ~= 0 then
		m_uimatching:open()
	end
end

function matching_isvisible()
	return m_uimatching:alive()
end

function matching_matching()
	return m_uimatching.matching ~= nil and m_uimatching.matching ~= 0
end

function matching_onopen()
	m_uimatching:setwidgetdelegate("button_abort", matching_delegate_abort)
	m_uimatching:setwidgetdelegate("button_enter", matching_delegate_enter)
	m_uimatching:setwidgetdelegate("button_cancel", matching_delegate_cancel)
	m_uimatching:setwidgetdelegate("image_bg/button_close", matching_delegate_close)
	event_register(eventtype.update, matching_update, m_uimatching)
	matching_update()
end

function matching_update()
	local waiting = m_uimatching.entertime == 0
	m_uimatching:setwidgetvisible("button_abort", waiting)
	m_uimatching:setwidgetvisible("button_enter", not waiting)
	m_uimatching:setwidgetvisible("button_cancel", not waiting)
	local text_message = m_uimatching:getwidget("text_message")
	if waiting then
		local timetext = c_textformat("MATCHING_WAITTIME", timerdesc_getafter(time_game - m_uimatching.timestart))
		text_message:settext(timetext)
	else
		local entertime = m_uimatching.entertime - time_game
		if entertime > 0 then
			local timetext = c_textformat("MATCHING_SUCCESS", timerdesc_getafter(entertime))
			text_message:settext(timetext)
		else
			matching_close()
		end
	end
end

function matching_close()
	m_uimatching.matching = 0
	m_uimatching.timestart = 0
	m_uimatching.entertime = 0
	m_uimatching:close()
	actionbar_updatenotify()
end

function matching_delegate_abort_confirm(ok, data)
    if ok then
		local msg = {messageid="CS_MatchAbort"}
		c_send(msg)
    end
end
function matching_delegate_abort()
	messagebox_confirm("MATCHING_ABORT_CONFIRM", matching_delegate_abort_confirm)
end

function matching_delegate_enter()
	local msg = {messageid="CS_MatchEnter"}
	c_send(msg)
end

function matching_delegate_cancel_confirm(ok, data)
    if ok then
		local msg = {messageid="CS_MatchCancel"}
		c_send(msg)
    end
end
function matching_delegate_cancel()
	messagebox_confirm("MATCHING_CANCEL_CONFIRM", matching_delegate_cancel_confirm)
end

function matching_delegate_close()
	m_uimatching:close()
	actionbar_updatenotify()
end
