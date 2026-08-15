
function login_confirm_onopen()
	m_uilogin_confirm:setwidgetdelegate("button_selectserver", login_confirm_delegate_selectserver)
	m_uilogin_confirm:setwidgetdelegate("button_confirm", login_confirm_delegate_confirm)
	m_uilogin_confirm:setwidgetdelegate("button_note", login_confirm_delegate_note)

	local version = c_system_cmdline("version")
	local text_version = m_uilogin_confirm:getwidget("text_version")
	text_version:settext("LOGIN_CONFIRM_VERSION", version)

	local server = m_login_selectserver or m_login_prevserver

	local descstateimage = login_getserverstateimage(server.state)
	local image_state = m_uilogin_confirm:getwidget("image_state")
	image_state:setsprite(descstateimage)
	
	local text_servername = m_uilogin_confirm:getwidget("text_servername")
	local servername = server.name
	text_servername:settext(servername)
end

function login_confirm_delegate_selectserver(sender)
	m_uilogin_confirm:close()
	m_uilogin_selectserver:open()
	gameserver_stop()
end

function login_confirm_delegate_confirm()
	local server = m_login_selectserver or m_login_prevserver
	gameserver_request(m_login_account.accountid, m_login_account.uuid, server.serverid, server.ipv4, server.ipv6, server.port)
end

function login_confirm_delegate_note()
	notice_show()
end
