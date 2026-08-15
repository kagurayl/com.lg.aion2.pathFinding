
include("login/loginmessage")
include("login/register")
include("login/resetpassword")
include("login/inputaccount")
include("login/notice")
include("login/queue")
include("login/confirm")
include("login/request")
include("login/selectserver")
include("login/createciv")
include("login/createcareer")

m_login_scenename_input = "login2"

m_login_create_civ = playerciv.light
m_login_create_career = 0
m_login_create_sex = playersex.male

m_login_account = nil
m_login_prevserver = nil
m_login_playerlist = nil
m_login_regionlist = nil
m_login_serverlist = nil
m_login_selectserver = nil
m_uilogin_register = uipanel_createhandle("login/login_register", uilayer.bottomtop, 0)
m_uilogin_resetpassword = uipanel_createhandle("login/login_resetpassword", uilayer.bottomtop, 0)
m_uilogin_inputaccount = uipanel_createhandle("login/login_inputaccount", uilayer.bottom, 0)
m_uilogin_request = uipanel_createhandle("login/login_request", uilayer.top, 0)
m_uilogin_confirm = uipanel_createhandle("login/login_confirm", uilayer.normal, 0)
m_uilogin_selectserver = uipanel_createhandle("login/login_selectserver", uilayer.normal, 0)
m_uilogin_createciv = uipanel_createhandle("login/login_createciv", uilayer.normal, 0)
m_uilogin_createcareer = uipanel_createhandle("login/login_createcareer", uilayer.normal, 0)

serverstate =
{
	down = 0,
	nice = 1,
	idle = 2,
	busy = 3,
	full = 4
}

function login_create()
	scene_clear()
	loading_loadlevel(0, m_login_scenename_input, "login", false, worldchanged_logininput)
end

function login_closeallui()
	m_uilogin_inputaccount:close()
	m_uilogin_confirm:close()
	m_uilogin_selectserver:close()
	m_uilogin_createciv:close()
	m_uilogin_createcareer:close()
	appearance_close()
end

function login_getserverstateimage(state)
	local stateimage = "login/down"
	if state == serverstate.nice then
		stateimage = "login/idle"
	elseif state == serverstate.idle then
		stateimage = "login/idle"
	elseif state == serverstate.busy then
		stateimage = "login/busy"
	elseif state == serverstate.full then
		stateimage = "login/full"
	end
	return stateimage
end

function login_getloginserverip()
	if system_isreview() then
		return c_system_cmdline("server_review") 
	else
		return c_system_cmdline("server_online") 
	end
end
