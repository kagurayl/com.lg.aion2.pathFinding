
function login_request_onopen(title, text, cancel, delegate)
	m_uilogin_request:setwidgetdelegate("button_cancel", delegate)
	local text_title = m_uilogin_request:getwidget("text_title")
	text_title:settext(title)

	local text_message = m_uilogin_request:getwidget("text_message")
	text_message:settext(text)

	local button_cancel = m_uilogin_request:getwidget("button_cancel")
	button_cancel:settext(cancel)
end
