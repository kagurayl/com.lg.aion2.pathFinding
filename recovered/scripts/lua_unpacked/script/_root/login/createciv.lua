
function login_createciv_onopen()
	m_uilogin_createciv:setwidgetdelegate("button_prev", login_createciv_delegate_prev)
	m_uilogin_createciv:setwidgetdelegate("button_next", login_createciv_delegate_next)
	m_uilogin_createciv:setwidgetdelegate("image_civ1bg", login_createciv_delegate_civ1)
	m_uilogin_createciv:setwidgetdelegate("image_civ2bg", login_createciv_delegate_civ2)
	login_createciv_updateciv()
end

function login_createciv_updateciv()
	local image_civ1 = m_uilogin_createciv:getwidget("image_civ1")
	image_civ1:setavailablecolor(m_login_create_civ == playerciv.light)

	local text_name1 = m_uilogin_createciv:getwidget("text_name1")
	text_name1:setavailablecolor(m_login_create_civ == playerciv.light)

	local text_desc1 = m_uilogin_createciv:getwidget("text_desc1")
	text_desc1:setavailablecolor(m_login_create_civ == playerciv.light)

	local image_civ2 = m_uilogin_createciv:getwidget("image_civ2")
	image_civ2:setavailablecolor(m_login_create_civ == playerciv.dark)

	local text_name2 = m_uilogin_createciv:getwidget("text_name2")
	text_name2:setavailablecolor(m_login_create_civ == playerciv.dark)

	local text_desc2 = m_uilogin_createciv:getwidget("text_desc2")
	text_desc2:setavailablecolor(m_login_create_civ == playerciv.dark)
end

function login_createciv_delegate_civ1(sender, event)
	if event.name == "mousedown" then
		m_login_create_civ = playerciv.light
		login_createciv_updateciv()
	end
end

function login_createciv_delegate_civ2(sender, event)
	if event.name == "mousedown" then
		m_login_create_civ = playerciv.dark
		login_createciv_updateciv()
	end
end

function login_createciv_delegate_prev()
	m_uilogin_createciv:close()
	m_uilogin_confirm:open()
	login_setloginscene()
end

function login_createciv_delegate_next()
	m_login_create_career = playercareer.warrior
	m_uilogin_createciv:close()
	m_uilogin_createcareer:open()
end
