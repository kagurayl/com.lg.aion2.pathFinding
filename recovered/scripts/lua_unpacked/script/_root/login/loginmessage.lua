function login_onerrorback()
	m_uilogin_confirm:close()
	m_uilogin_selectserver:close()
	m_uilogin_createciv:close()
	m_uilogin_createcareer:close()
	appearance_close()
	m_uilogin_inputaccount:open()
	if loading_getlevelname() ~= m_login_scenename_input then
		scene_clear()
		loading_loadlevel(0, m_login_scenename_input, "login", false, worldchanged_logininput)
	else
		worldchanged_logininput()
	end
end

function login_onplayerempty(msg)
	m_uiappearance_inputname = msg.name
	login_closeallui()
	m_uilogin_createciv:open()
end

function login_setloginscene()
	local designverticalfov = 60.0
    local designaspect = 16.0 / 9.0
    local vrad = designverticalfov * MATH_DEG2RAD
    local designhorizontalfov = 2.0 * math.atan(math.tan(vrad / 2.0) * designaspect)

	local screenwidth, screenheight = c_system_screensize()
	local currentaspect = screenwidth / screenheight
	local verticalfov = 2.0 * math.atan(math.tan(designhorizontalfov / 2.0) / currentaspect)
	verticalfov = verticalfov * MATH_RAD2DEG

	maincamera_moveto("Camera_Login_01", 0.0, verticalfov)
	audiomanager_playmusic("sounds/music/login_bgm-main.ogg", 0.0, audioflag.loop)
end

function worldchanged_logininput()
	login_setloginscene()
	m_uilogin_inputaccount:open()

	c_scene_setenv("envcolor", 0x695948, 0.0)
	c_scene_setenv("suncolor", 0x93a5d5, 0.0)
	c_scene_setenv("sunangle", "152,73", 0.0)
	c_scene_setenv("ambient", 0xeaeaea, 0.0)
end
