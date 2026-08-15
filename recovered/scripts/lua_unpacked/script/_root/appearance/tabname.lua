
function appearancename_onopen()
	m_uiappearance:setwidgetdelegate("tab_left/tab_name/button_random", appearancename_delegate_random)
	m_uiappearance:setwidgetdelegate("tab_left/tab_name/button_legal", appearancename_delegate_legal)

	local edit_name = m_uiappearance:getwidget("tab_left/tab_name/edit_name")
	edit_name:settext(m_uiappearance_inputname)

	local text_civ = m_uiappearance:getwidget("tab_left/tab_name/text_civ")
	text_civ:settext(getplayercivtext(m_uiappearance_civ))

	local text_career = m_uiappearance:getwidget("tab_left/tab_name/text_career")
	text_career:settext(playercareertext[m_uiappearance_career])
end

function appearancename_getname()
	local edit_name = m_uiappearance:getwidget("tab_left/tab_name/edit_name")
	return edit_name:gettext()
end

function appearancename_delegate_legal()
	local msg = {messageid="CS_LegalName"}
	msg.name = appearancename_getname()
	c_send(msg)
end

function appearancename_delegate_random()
	local msg = {messageid="CS_RandomName"}
	c_send(msg)
end
