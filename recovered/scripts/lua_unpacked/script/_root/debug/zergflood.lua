
local zergfloodstate = 
{
    none = 0,
    login = 1,
    connect = 2,
    verify = 3,
    entered = 4,
}

local m_zergflood_serverid = nil
local m_zergflood_server = nil
local m_zergflood_session = nil

function zergflood_inputaccount_httpresponse(msg, userdata)
    local session = m_zergflood_session[userdata]
    local json = c_config_json2table(msg)
    if json == nil then
        session.state = zergfloodstate.none
		debugerror("zergflood invalid inputaccount httpresponse")
        return
    end
	if json.command ~= "success" then
        session.state = zergfloodstate.none
		debugerror("zergflood invalid inputaccount command")
        return
	end
    session.account = json.account
end

function zergflood_serverlist_httpresponse(msg, userdata)
    local json = c_config_json2table(msg)
    if json == nil then
		debugerror("zergflood invalid serverlist httpresponse")
        return
    end
    for i=1,#json.server do
		local server = json.server[i]
		if server.serverid == m_zergflood_serverid then
            m_zergflood_server = server
            break
		end
	end
    if m_zergflood_server == nil then
		debugerror("zergflood failed find serverid:" .. m_zergflood_serverid)
        return
    end
end

function zergflood_create(serverid, count)
    m_zergflood_serverid = serverid
    m_zergflood_session = {}
    for i=1,count do
        local session = {}
        session.index = i
        session.floodindex = i - 1
        session.state = zergfloodstate.none
        m_zergflood_session[i] = session
    end
    local requesturl = login_getloginserverip() .. "/serverlist.php"
	http_request(requesturl, nil, zergflood_serverlist_httpresponse, nil)

    c_flooddestroy()
    c_floodcreate(count)
    event_register(eventtype.update, zergflood_update)
end

function zergflood_message_command(str, sessionindex)
    local json = c_config_json2table(str)
    if json ~= nil then
        if json.command == "verify" then
            local session = m_zergflood_session[sessionindex + 1]
            local md5 = c_math_md5(json.rand .. session.account.uuid)
            c_floodverify(session.floodindex, m_zergflood_serverid, session.account.accountid, c_system_cmdline("version"), md5)
        end
    end
end

local function zergflood_update_none(session)
    if m_zergflood_server ~= nil then
        local register = {}
        register.username = "zergflood_" .. session.index
        register.password = "111111"
        local registerjson = c_config_table2json(register)
        local registerurl = login_getloginserverip() .. "/register.php"
        http_request(registerurl, registerjson, nil, nil)

        local verify = {}
        verify.username = "zergflood_" .. session.index
        verify.password = "111111"
        local verifyjson = c_config_table2json(verify)
        local verifyurl = login_getloginserverip() .. "/login.php"
        session.httprequest = http_request(verifyurl, verifyjson, zergflood_inputaccount_httpresponse, session.index)
        session.state = zergfloodstate.login
        session.account = nil
    end
end

local function zergflood_update_login(session)
    if session.account ~= nil then
        session.state = zergfloodstate.connect
        c_flooddisconnect(session.floodindex)
    end
end

local function zergflood_update_game(session)
    local state = c_floodstate(session.floodindex)
    if state == networkstate.none or state == networkstate.connectfailed or state == networkstate.disconnected then
        local serverip = string.format("%s:%d", m_zergflood_server.ipv4, m_zergflood_server.port)
        c_flooddisconnect(session.floodindex)
        c_floodconnect(session.floodindex, serverip)
        session.state = zergfloodstate.connect
        return
    end
    if session.state == zergfloodstate.connect then
        if state == networkstate.connected then
            session.state = zergfloodstate.verify
        end
    end
end

function zergflood_update()
    for i=1,#m_zergflood_session do
        local session = m_zergflood_session[i]
        if session.state == zergfloodstate.none then
            zergflood_update_none(session)
        elseif session.state == zergfloodstate.login then
            zergflood_update_login(session)
        else
            zergflood_update_game(session)
        end
    end
end

function zergflood_SC_PlayerEmpty(msg, index)
	local req = {messageid="CS_CreatePlayer"}
	req.name = msg.name
	req.civ = playerciv.light
	req.sex = playersex.male
	req.career = playercareer.warrior
	c_floodsend(index, req)
end

function zergflood_SC_Alert(msg, index)
    local str = c_textformat("SERVER_" .. msg.id)
    debugerror(string.format("%s(%d)", str, index))
end
