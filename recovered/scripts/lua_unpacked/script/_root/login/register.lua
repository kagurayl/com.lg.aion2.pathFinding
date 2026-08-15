
local m_register_httprequest = nil

function login_register_onopen()
	m_uilogin_register:setwidgetdelegate("button_register", login_register_delegate_register)
	m_uilogin_register:setwidgetdelegate("edit_account", login_register_delegate_account)
	m_uilogin_register:setwidgetdelegate("edit_password", login_register_delegate_password)
	m_uilogin_register:setwidgetdelegate("edit_password2", login_register_delegate_password2)
	m_uilogin_register:setwidgetdelegate("image_bg/button_close", login_register_delegate_close)
	login_register_updateui()
end

local function login_register_settextcolor(text, warning, hide)
	if warning then
		text:setcolor(1, 0, 0, 1)
	else
		text:setcolor(0.65, 0.718, 0.718, 1)
	end
end
function login_register_updateui()
	local edit_account = m_uilogin_register:getwidget("edit_account")
	local username = edit_account:gettext()

	local edit_password = m_uilogin_register:getwidget("edit_password")
	local password = edit_password:gettext()

	local edit_password2 = m_uilogin_register:getwidget("edit_password2")
	local password2 = edit_password2:gettext()

	local edit_securitycode = m_uilogin_register:getwidget("edit_securitycode")
	local securitycode = edit_securitycode:gettext()

	local text_accountlength = m_uilogin_register:getwidget("text_accountlength")
	login_register_settextcolor(text_accountlength, #username > 0 and (#username < 4 or #username > 32))

	local text_accountchar = m_uilogin_register:getwidget("text_accountchar")
	login_register_settextcolor(text_accountchar, #username > 0 and username:match("^[a-zA-Z0-9_]+$") == nil)

	local text_passwordlength = m_uilogin_register:getwidget("text_passwordlength")
	local passwordlength = #password > 0 and (#password < 6 or #password > 64)
	local securitycodelength = #securitycode > 0 and (#securitycode < 6 or #securitycode > 64)
	login_register_settextcolor(text_passwordlength, passwordlength and securitycodelength)

	local text_passworddiff = m_uilogin_register:getwidget("text_passworddiff")
	text_passworddiff:setvisiblenothit(password ~= password2)
end

function login_register_delegate_register()
	local edit_account = m_uilogin_register:getwidget("edit_account")
	local username = edit_account:gettext()
	if #username == 0 then
		return
	end

	local edit_password = m_uilogin_register:getwidget("edit_password")
	local password = edit_password:gettext()
	if #password == 0 then
		return
	end

	local edit_password2 = m_uilogin_register:getwidget("edit_password2")
	local password2 = edit_password:gettext()
	if password ~= password2 then
		return
	end

	local edit_securitycode = m_uilogin_register:getwidget("edit_securitycode")
	local securitycode = edit_securitycode:gettext()
	if #securitycode == 0 then
		return
	end

	local edit_referralcode = m_uilogin_register:getwidget("edit_referralcode")
	local referralcode = edit_referralcode:gettext()

	local register = {}
	register.username = username
	register.password = password
	register.securitycode = securitycode
	register.referralcode = referralcode
	local registerjson = c_config_table2json(register)
	local registerurl = login_getloginserverip() .. "/register.php"
	http_request(registerurl, registerjson, login_register_delegate_httpresponse, nil)
end

function login_register_delegate_account()
	login_register_updateui()
end

function login_register_delegate_password()
	login_register_updateui()
end

function login_register_delegate_password2()
	login_register_updateui()
end

function login_register_delegate_confirm()
    m_uilogin_register:close()
end

function login_register_delegate_httpresponse(msg, userdata)
    local json = c_config_json2table(msg)
    if json == nil then
		debuglog("invalid http response")
		messagebox_ok("LOGIN_REGISTER_RETRY")
        return
    end
	if json.command == "success" then
		login_inputaccount_setregister(json.username, json.password)
		messagebox_ok("LOGIN_REGISTER_SUCCESS", nil, login_register_delegate_confirm)
	else
		messagebox_ok(json.message)
	end
end

function login_register_delegate_close()
	m_uilogin_register:close()
end
