
include("home/playerbuff")
include("home/playerinfo")
include("home/minichat")
include("home/minimap")
include("home/minimapadditive")
include("home/selection")
include("home/selectionmenu")
include("home/homemenu")
include("home/joystick")
include("home/skillslot")
include("home/skillbar")
include("home/actionbar")
include("home/preview")

minichat_showpreview = false

function home_main_updatepreview()
	if minichat_showpreview then
		m_uipreview:open()
		m_uiactionbar:setvisible(false)
	else
		m_uipreview:close()
		m_uiactionbar:setvisible(true)
	end
end

function home_main_create()
	if playerattr_info.mapid == mapid_resetskin then
		appearance_setdata(playercareerbase(playerattr_info.career), playerattr_info.civ, playerattr_info.sex, playerattr_info.voice, false)
		if m_uiappearance:null() then
			uimanager_clear()
			appearance_create()
		end
	elseif playerattr_info.mapid == mapid_resetsex then
		local sex = math.ternary(playerattr_info.sex == playersex.male, playersex.female, playersex.male)
		appearance_setdata(playercareerbase(playerattr_info.career), playerattr_info.civ, sex, playerattr_info.voice, false)
		if m_uiappearance:null() then
			uimanager_clear()
			appearance_create()
		end
	elseif m_uiplayerinfo:null() then
		uimanager_clear()
		m_uiplayerinfo:open()
		m_uijoystick:open()
		m_uiskillbar:open()
		m_uiminimap:open()
		m_uiminichat:open()
		m_uiactionbar:open()
		selection_create()
		sidebar_open()
		home_main_updatepreview()

		local at = m_me.transform
		local dist = gamesetting_getnumber("CAMERADIST")
		local distmin = 1
		local distmax = 20
		local pitch = gamesetting_getnumber("CAMERAPITCH")
		local yaw = gamesetting_getnumber("CAMERAYAW")
		local roll = 0
		local pitchmin = -89
		local pitchmax = 89
		local wheeltime = 0.5
		maincamera_setlookat(at.px, at.py + m_me.actordata.cameraheight, at.pz, dist, distmin, distmax, pitch, yaw, roll, pitchmin, pitchmax, wheeltime)
		maincamera_setstate(camerastate.lookat)
		inputmove_reset()
	end
end

function home_main_clear()
	minichat_showpreview = false
end
