
local m_inputaccount_savefile = "playerconfig/account.txt"
local m_inputaccount_httprequest = nil

function login_inputaccount_onopen()
	m_uilogin_inputaccount:setwidgetdelegate("button_register", login_inputaccount_delegate_register)
	m_uilogin_inputaccount:setwidgetdelegate("button_resetpassword", login_inputaccount_delegate_resetpassword)
	m_uilogin_inputaccount:setwidgetdelegate("button_login", login_inputaccount_delegate_login)
	m_uilogin_inputaccount:setwidgetdelegate("button_setting", login_inputaccount_delegate_setting)
	local saveaccount = c_config_loadtable(m_inputaccount_savefile)
	if saveaccount ~= nil then
		local username = saveaccount["username"]
		if username ~= nil then
			local edit_account = m_uilogin_inputaccount:getwidget("edit_account")
			edit_account:settextraw(username)
		end
	
		local password = saveaccount["password"]
		if password ~= nil then
			local edit_password = m_uilogin_inputaccount:getwidget("edit_password")
			edit_password:settextraw(password)
		end
	end
end

function login_inputaccount_setregister(username, password)
	if m_uilogin_inputaccount:alive() then
		local edit_account = m_uilogin_inputaccount:getwidget("edit_account")
		edit_account:settextraw(username)

		local edit_password = m_uilogin_inputaccount:getwidget("edit_password")
		edit_password:settextraw("")
	end
end

function login_inputaccount_delegate_register()
	m_uilogin_register:open()
end

function login_inputaccount_delegate_resetpassword()
	m_uilogin_resetpassword:open()
end

function login_inputaccount_delegate_login()
	local edit_account = m_uilogin_inputaccount:getwidget("edit_account")
	local username = edit_account:gettext()
	if username == nil or string.len(username) < 1 then
		return
	end

	local edit_password = m_uilogin_inputaccount:getwidget("edit_password")
	local password = edit_password:gettext()
	if password == nil or string.len(password) < 1 then
		return
	end

	local saveaccount = {}
	saveaccount["username"] = username
	saveaccount["password"] = password
	c_config_savetable(m_inputaccount_savefile, saveaccount)
	c_system_setcrashreport("account", username)

	local verify = {}
	verify.username = username
	verify.password = password
	local verifyjson = c_config_table2json(verify)
	local verifyurl = login_getloginserverip() .. "/login.php"
	m_inputaccount_httprequest = http_request(verifyurl, verifyjson, login_inputaccount_delegate_httpresponse, nil)
	m_uilogin_request:open("LOGIN_VERIFY_TITLE", "LOGIN_VERIFY_TIPS", "LOGIN_VERIFY_CANCEL", login_inputaccount_delegate_requestcancel)
end

function login_inputaccount_delegate_requestcancel()
	m_uilogin_request:close()
	http_cancel(m_inputaccount_httprequest)
end

function login_inputaccount_delegate_httpresponse(msg, userdata)
	m_uilogin_request:close()
    local json = c_config_json2table(msg)
    if json == nil then
		debuglog("invalid http response")
		messagebox_ok("LOGIN_VERIFY_RETRY")
        return
    end
	if json.command ~= "success" then
		messagebox_ok(json.message)
        return
	end

	m_login_account = json.account
	m_login_prevserver = json.server
	m_login_playerlist = json.player
	notice_setnotelist(json.note)

	m_login_serverlist = nil
	m_login_selectserver = nil
	m_uilogin_inputaccount:close()
	if m_login_prevserver ~= nil then
		m_uilogin_confirm:open()
	else
		m_uilogin_selectserver:open()
	end
end

function login_inputaccount_delegate_setting()
    m_uisetting_settinglocal:open()
end
