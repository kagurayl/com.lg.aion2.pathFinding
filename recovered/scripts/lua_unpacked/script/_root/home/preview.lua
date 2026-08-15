
m_uipreview = uipanel_createhandle("home/preview", uilayer.bottom, uiflag.scale)

function preview_onopen()
	m_uipreview:setwidgetdelegate("button_exit", preview_delegate_exit)
end

function preview_delegate_exit()
    if m_me ~= nil then
		m_me:clearpreview()
	end
	minichat_showpreview = false
	home_main_updatepreview()
end
