
local m_uilogin_queue = uipanel_createhandle("login/queue", uilayer.normal, 0)

function queue_onopen()
	m_uilogin_queue:setwidgetdelegate("button_cancel", queue_delegate_cancel)
end

function queue_delegate_cancel()
	gameserver_stop()
	m_uilogin_queue:close()
end

function queue_close()
	m_uilogin_queue:close()
end

function SC_Queue(msg)
	messagealert_closecenter()
	m_uilogin_queue:open()
	local text_queue = m_uilogin_queue:getwidget("text_queue")
	text_queue:settext("LOGIN_QUEUETEXT", tostring(msg.index + 1))
end
