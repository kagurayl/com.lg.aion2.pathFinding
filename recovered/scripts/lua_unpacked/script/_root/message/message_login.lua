
local function login_clearall()
	clearall()
end

function SC_RandomName(msg)
	appearance_onrandomname(msg)
end

function SC_LegalName(msg)
	if msg.name ~= nil then
		messagealert_closecenter()
		if msg.legal == 0 then
			messagealert_addalert(c_textformat("LOGIN_CREATEPLAYER_VALID", msg.name))
		elseif msg.legal == 1 then
			messagealert_addalert(c_textformat("LOGIN_CREATEPLAYER_REPETITION", msg.name))
		elseif msg.legal == 2 then
			messagealert_addalert(c_textformat("LOGIN_CREATEPLAYER_INVALIDNAME", msg.name))
		end
	end
end

function SC_ServerFull(msg)
	messagebox_ok("LOGINSTATE_SERVER_PLAYERFULL")
end

function SC_PlayerEmpty(msg)
	gameserver_onenter()
	login_clearall()
	messagealert_closecenter()
	login_onplayerempty(msg)
end

function SC_LoadingPlayer(msg)
	gameserver_onenter()
	login_clearall()
	messagealert_showcenter("LOGINSTATE_SERVER_LOADINGPLAYER")
	queue_close()
end

function SC_CreatingPlayer(msg)
	messagealert_showcenter("LOGINSTATE_SERVER_LOADINGPLAYER")
end

function SC_Reconnecting(msg)
	scene_setloading()
	login_clearall()
end

function SC_Entering(msg)
	scene_setloading()
	login_clearall()
end

function SC_EnterGame(msg)
	gameserver_onenter()
	scene_setmap(playerattr_info.mapid)
	overlay_create()
end
