
local m_resetpassword_httprequest = nil

function login_resetpassword_onopen()
	m_uilogin_resetpassword:setwidgetdelegate("button_resetpassword", login_resetpassword_delegate_resetpassword)
	m_uilogin_resetpassword:setwidgetdelegate("edit_account", login_resetpassword_delegate_account)
	m_uilogin_resetpassword:setwidgetdelegate("edit_password", login_resetpassword_delegate_password)
	m_uilogin_resetpassword:setwidgetdelegate("edit_password2", login_resetpassword_delegate_password2)
	m_uilogin_resetpassword:setwidgetdelegate("image_bg/button_close", login_resetpassword_delegate_close)
	login_resetpassword_updateui()
end

local function login_resetpassword_settextcolor(text, warning, hide)
	if warning then
		text:setcolor(1, 0, 0, 1)
	else
		text:setcolor(0.65, 0.718, 0.718, 1)
	end
end
function login_resetpassword_updateui()
	local edit_account = m_uilogin_resetpassword:getwidget("edit_account")
	local username = edit_account:gettext()

	local edit_password = m_uilogin_resetpassword:getwidget("edit_password")
	local password = edit_password:gettext()

	local edit_password2 = m_uilogin_resetpassword:getwidget("edit_password2")
	local password2 = edit_password2:gettext()

	local text_passwordlength = m_uilogin_resetpassword:getwidget("text_passwordlength")
	login_resetpassword_settextcolor(text_passwordlength, #password > 0 and (#password < 6 or #password > 64))

	local text_passworddiff = m_uilogin_resetpassword:getwidget("text_passworddiff")
	text_passworddiff:setvisiblenothit(password ~= password2)
end

function login_resetpassword_delegate_resetpassword()
	local edit_account = m_uilogin_resetpassword:getwidget("edit_account")
	local username = edit_account:gettext()
	if #username == 0 then
		return
	end

	local edit_password = m_uilogin_resetpassword:getwidget("edit_password")
	local password = edit_password:gettext()
	if #password == 0 then
		return
	end

	local edit_password2 = m_uilogin_resetpassword:getwidget("edit_password2")
	local password2 = edit_password:gettext()
	if password ~= password2 then
		return
	end

	local edit_securitycode = m_uilogin_resetpassword:getwidget("edit_securitycode")
	local securitycode = edit_securitycode:gettext()

	local register = {}
	register.username = username
	register.password = password
	register.securitycode = securitycode
	local registerjson = c_config_table2json(register)
	local registerurl = login_getloginserverip() .. "/resetpassword.php"
	http_request(registerurl, registerjson, login_resetpassword_delegate_httpresponse, nil)
end

function login_resetpassword_delegate_account()
	login_resetpassword_updateui()
end

function login_resetpassword_delegate_password()
	login_resetpassword_updateui()
end

function login_resetpassword_delegate_password2()
	login_resetpassword_updateui()
end

function login_resetpassword_delegate_confirm()
    m_uilogin_resetpassword:close()
end

function login_resetpassword_delegate_httpresponse(msg, userdata)
    local json = c_config_json2table(msg)
    if json == nil then
		debuglog("invalid http response")
		messagebox_ok("GAMESERVER_FAILED_RETRY")
        return
    end
	if json.command == "success" then
		login_inputaccount_setregister(json.username, json.password)
		messagebox_ok("LOGIN_RESETPASSWORD_SUCCESS", nil, login_resetpassword_delegate_confirm)
	else
		messagebox_ok(json.message)
	end
end

function login_resetpassword_delegate_close()
	m_uilogin_resetpassword:close()
end
