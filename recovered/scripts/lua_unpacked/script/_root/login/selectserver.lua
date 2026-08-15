
local m_viewregion = nil
local m_selectserver_inst = {region = "login/inst_region", server = "login/inst_server", playerserver = "login/inst_playerserver"}
local m_selectserver_httprequest = nil

local function selectserver_enterserver(id)
	for i=1,#m_login_serverlist do
		local server = m_login_serverlist[i]
		if server.serverid == id then
			m_login_selectserver = server
			login_selectserver_delegate_close()
			break
		end
	end
end

local function selectserver_setserver()
	local list_server = m_uilogin_selectserver:getwidget("list_server")
	list_server:setasyncdelegate(selectserver_delegate_setserver)
	list_server:clear()
	local prevserver = nil
	for i=1,#m_login_serverlist do
		local server = m_login_serverlist[i]
		if (m_viewregion > 0 and server.region == m_viewregion) or (m_viewregion == 0 and server.state == serverstate.nice) then
			if prevserver ~= nil then
				list_server:add(m_selectserver_inst.server, list_server:getcount(), {server1 = prevserver, server2 = server})
				prevserver = nil
			else
				prevserver = server
			end
		end
	end
	if prevserver ~= nil then
		list_server:add(m_selectserver_inst.server, list_server:getcount(), {server1 = prevserver})
		prevserver = nil
	end
end

local function selectserver_delegate_setserverinfo(line, index, server)
	local server_root = line:getwidget("inst_server_" .. index)
	if server == nil then
		server_root:setvisible(false)
		return
	end
	server_root:setvisible(true)

	local text_nice = server_root:getwidget("text_nice")
	if server.state == serverstate.nice then
		text_nice:settext("LOGIN_SERVER_NICE")
	else
		text_nice:setvisible(false)
	end

	local image_state = server_root:getwidget("image_state")
	local descstateimage = login_getserverstateimage(server.state)
	image_state:setsprite(descstateimage)

	local text_servername = server_root:getwidget("text_servername")
	text_servername:settext(server.name)

	local button_server = server_root:getwidget("button_server")
	button_server:setdelegate(login_selectserver_delegate_server)
	button_server.serverid = server.serverid
end
function selectserver_delegate_setserver(sender, line, server)
	selectserver_delegate_setserverinfo(line, 1, server.server1)
    selectserver_delegate_setserverinfo(line, 2, server.server2)
end

local function selectserver_setplayerlist()
	local list_server = m_uilogin_selectserver:getwidget("list_server")
	list_server:setasyncdelegate(selectserver_delegate_setplayerlist)
	list_server:clear()
	local prevplayer = nil
	for i=1,#m_login_playerlist do
		local player = m_login_playerlist[i]
		if prevplayer ~= nil then
			list_server:add(m_selectserver_inst.playerserver, list_server:getcount(), {player1 = prevplayer, player2 = player})
			prevplayer = nil
		else
			prevplayer = player
		end
	end
	if prevplayer ~= nil then
		list_server:add(m_selectserver_inst.playerserver, list_server:getcount(), {player1 = prevplayer, player2 = nil})
	end
end

local function selectserver_delegate_setplayerserverinfo(line, index, player)
	local server_root = line:getwidget("inst_playerserver_" .. index)
	if player == nil then
		server_root:setvisible(false)
		return
	end
	server_root:setvisible(true)

	local mini = c_config_json2table(player.mini)
	local text_prev = server_root:getwidget("text_prev")
	text_prev:setvisible(m_login_prevserver ~= nil and m_login_prevserver.serverid == mini.serverid)

	local text_playername = server_root:getwidget("text_playername")
	text_playername:settext(player.playername)

	local text_level = server_root:getwidget("text_level")
	text_level:settext("LOGIN_SERVER_PLAYERLEVEL", mini.level)
	
	for j=1,#m_login_serverlist do
		local server = m_login_serverlist[j]
		if server.serverid == mini.serverid then
			local descstateimage = login_getserverstateimage(server.state)
			local image_state = server_root:getwidget("image_state")
			image_state:setsprite(descstateimage)

			local text_playerservername = server_root:getwidget("text_playerservername")
			text_playerservername:settext(server.name)
	
			local button_playerserver = server_root:getwidget("button_playerserver")
			button_playerserver:setdelegate(login_selectserver_delegate_playerserver)
			button_playerserver.serverid = server.serverid
			break
		end
	end
end
function selectserver_delegate_setplayerlist(sender, line, player)
	selectserver_delegate_setplayerserverinfo(line, 1, player.player1)
    selectserver_delegate_setplayerserverinfo(line, 2, player.player2)
end

local function selectserver_enterregion()
	if m_viewregion >= 0 then
		selectserver_setserver()
	else
		selectserver_setplayerlist()
	end

	local list_region = m_uilogin_selectserver:getwidget("list_region")
	local linecount = list_region:getcount()
	for i=1, linecount do
		local line = list_region:getlinefromindex(i)
		line:setwidgetvisible("image_select", line:getdata() == m_viewregion)
	end
end

local function selectserver_setregion()
	local list_region = m_uilogin_selectserver:getwidget("list_region")
	list_region:clear()
	m_viewregion = 0
	for i=#m_login_regionlist,1, -1 do
		local region = m_login_regionlist[i]
		if region.regionid ~= 0 then
			m_viewregion = region.regionid
			break
		end
	end
	for i=1,#m_login_serverlist do
		local server = m_login_serverlist[i]
		if server.state == serverstate.nice then
			m_viewregion = 0
			break
		end
	end

	if m_login_playerlist ~= nil and #m_login_playerlist > 0 then
		m_viewregion = -1
		local line = list_region:add(m_selectserver_inst.region, i, -1)
		local text_region = line:getwidget("text_region")
		text_region:settext("LOGIN_SERVER_REGION_MINE")

		local button_region = line:getwidget("button_region")
		button_region:setdelegate(login_selectserver_delegate_region)
		button_region.regionid = -1
	end	

	for i=1,#m_login_serverlist do
		local server = m_login_serverlist[i]
		if server.state == serverstate.nice then
			local line = list_region:add(m_selectserver_inst.region, i, 0)
			local text_region = line:getwidget("text_region")
			text_region:settext("LOGIN_SERVER_REGION_NICE")

			local button_region = line:getwidget("button_region")
			button_region:setdelegate(login_selectserver_delegate_region)
			button_region.regionid = 0
			break
		end
	end
		
	for i=#m_login_regionlist,1, -1 do
		local region = m_login_regionlist[i]
		if region.regionid ~= 0 then
			local line = list_region:add(m_selectserver_inst.region, i, region.regionid)
			local text_region = line:getwidget("text_region")
			text_region:settext(region.name)

			local button_region = line:getwidget("button_region")
			button_region:setdelegate(login_selectserver_delegate_region)
			button_region.regionid = region.regionid
		end
	end
	selectserver_enterregion()
end

function login_selectserver_onopen()
	local list_region = m_uilogin_selectserver:getwidget("list_region")
	list_region:init(uilistflag.vertical)

	local list_server = m_uilogin_selectserver:getwidget("list_server")
	list_server:init(bit.bor(uilistflag.vertical, uilistflag.async))
	list_server:setasyncdelegate(selectserver_delegate_setserver)

	m_uilogin_selectserver:setwidgetdelegate("button_close", login_selectserver_delegate_close)
	m_viewregion = -1
	if m_login_serverlist == nil then
		local requesturl = login_getloginserverip() .. "/serverlist.php"
		m_selectserver_httprequest = http_request(requesturl, nil, login_selectserver_delegate_httpresponse, nil)
		m_uilogin_request:open("LOGIN_SERVERLIST_TITLE", "LOGIN_SERVERLIST_TIPS", "LOGIN_SERVERLIST_CANCEL", login_selectserver_delegate_requestcancel)
	else
		selectserver_setregion()
	end
end

function login_selectserver_delegate_requestcancel()
	http_cancel(m_selectserver_httprequest)
	m_uilogin_request:close()
	m_uilogin_selectserver:close()
	if m_login_prevserver ~= nil then
		m_uilogin_confirm:open()
	else
		m_uilogin_inputaccount:open()
	end
end

function login_selectserver_delegate_httpresponse(msg, userdata)
	m_uilogin_request:close()
    local json = c_config_json2table(msg)
    if json == nil then
		debugerror("invalid http response")
        return
    end
	m_login_regionlist = json.region
	m_login_serverlist = json.server
	selectserver_setregion()
end

function login_selectserver_delegate_region(sender)
	m_viewregion = sender.regionid
	selectserver_enterregion()
end

function login_selectserver_delegate_server(sender)
	selectserver_enterserver(sender.serverid)
end

function login_selectserver_delegate_playerserver(sender)
	selectserver_enterserver(sender.serverid)
end

function login_selectserver_delegate_close()
	if m_login_selectserver ~= nil or m_login_prevserver ~= nil then
		m_uilogin_selectserver:close()
		m_uilogin_confirm:open()
	end
end
