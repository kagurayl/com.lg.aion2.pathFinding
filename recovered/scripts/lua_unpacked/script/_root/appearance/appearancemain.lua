

local m_appearance_rotate = 0.0
local m_appearance_button_scaleup = nil
local m_appearance_button_scaledown = nil

function appearance_onopen()
	if m_uiappearance_civ == playerciv.light then
		maincamera_moveto("Camera_Custom_Light", 0.0)
	else
		maincamera_moveto("Camera_Custom_Dark", 0.0)
	end
	m_uiappearance.tableft = uitabcreate(m_uiappearance)
	if m_uiappearance.typecreate then
		m_uiappearance.tableft:add("tab_left/button_name", "tab_left/tab_name", appearance_delegate_name)
	else
		m_uiappearance:setwidgetvisible("tab_left/button_name", false)
		m_uiappearance:setwidgetvisible("tab_left/tab_name", false)
	end
	m_uiappearance.tableft:add("tab_left/button_facepreset", "tab_left/tab_facepreset", appearance_delegate_facepreset)
	m_uiappearance.tableft:add("tab_left/button_bodypreset", "tab_left/tab_bodypreset", appearance_delegate_bodypreset)
	m_uiappearance.tableft:add("tab_left/button_voice", nil, appearance_delegate_voice)
	m_uiappearance.tableft:settab(1)
	m_uiappearance:setwidgetvisible("tab_face", not m_uiappearance.typecreate)
	m_uiappearance:setwidgetvisible("tab_body", false)
	m_uiappearance:setwidgetvisible("tab_voice", false)
	m_uiappearance:setwidgetvisible("image_morphbg", false)

	m_uiappearance:setwidgetdelegate("button_scaleup", appearance_delegate_scaleup)
	m_uiappearance:setwidgetdelegate("button_scaledown", appearance_delegate_scaledown)
	m_uiappearance:setwidgetdelegate("image_rotate", appearance_mouserotate)
	m_uiappearance:setwidgetdelegate("button_rotateleft", appearance_delegate_rotateleft)
	m_uiappearance:setwidgetdelegate("button_rotateright", appearance_delegate_rotateright)
	m_uiappearance:setwidgetdelegate("button_create", appearancename_delegate_create)
	m_uiappearance:setwidgetdelegate("button_back", appearance_delegate_back)

	local button_create = m_uiappearance:getwidget("button_create")
	local button_back = m_uiappearance:getwidget("button_back")
	if m_uiappearance.typecreate then
		button_create:settext("LOGIN_CREATEPLAYER_CREATE")
		button_back:settext("LOGIN_CREATECIV_PREVSTEP")
	else
		button_create:settext("UI_OK")
		button_back:settext("UI_CANCEL")
	end
	m_appearance_button_scaleup = m_uiappearance:getwidget("button_scaleup")
	m_appearance_button_scaledown = m_uiappearance:getwidget("button_scaledown")
	m_appearance_button_scaleup:setenable(true)
	m_appearance_button_scaledown:setenable(false)

	appearanceface_onopen()
	appearancebody_onopen()
	appearancename_onopen()
	appearancepreview_create()
	appearancefacepreset_onopen()
	appearancebodypreset_onopen()
	appearancevoice_onopen()

	event_register(eventtype.update, login_createplayer_update, m_uiappearance)
	audiomanager_playmusic("sounds/music/login_bgm-light.ogg", 0.0, audioflag.loop)
end

function appearance_onclose()
	colorpicker_close()
	appearancepreview_destroy()
end

function appearance_delegate_name()
	m_uiappearance:setwidgetvisible("tab_face", false)
	m_uiappearance:setwidgetvisible("tab_body", false)
	m_uiappearance:setwidgetvisible("tab_voice", false)
	m_uiappearance:setwidgetvisible("image_morphbg", false)
end

function appearance_delegate_facepreset()
	m_uiappearance:setwidgetvisible("tab_face", true)
	m_uiappearance:setwidgetvisible("tab_body", false)
	m_uiappearance:setwidgetvisible("tab_voice", false)
	m_uiappearance:setwidgetvisible("image_morphbg", true)
end

function appearance_delegate_bodypreset()
	m_uiappearance:setwidgetvisible("tab_face", false)
	m_uiappearance:setwidgetvisible("tab_body", true)
	m_uiappearance:setwidgetvisible("tab_voice", false)
	m_uiappearance:setwidgetvisible("image_morphbg", true)
end

function appearance_delegate_voice()
	m_uiappearance:setwidgetvisible("tab_face", false)
	m_uiappearance:setwidgetvisible("tab_body", false)
	m_uiappearance:setwidgetvisible("tab_voice", true)
	m_uiappearance:setwidgetvisible("image_morphbg", true)
end

function login_createplayer_update()
	if m_appearance_rotate ~= 0.0 then
		appearancepreview_rotate(m_appearance_rotate)
	end
end

function appearance_delegate_rotateleft(sender, event)
    if event.name == "mousedown" then
		m_appearance_rotate = 1.0
    elseif event.name == "mouseup" then
		m_appearance_rotate = 0.0
    end
end

function appearance_delegate_rotateright(sender, event)
    if event.name == "mousedown" then
		m_appearance_rotate = -1.0
    elseif event.name == "mouseup" then
		m_appearance_rotate = 0.0
    end
end

function login_createplayer_updatecameraposition()
	if m_appearance_button_scaledown:getenable() then
		local dummyname = math.ternary(m_uiappearance_civ == playerciv.light, "Camera_Custom_Zoomin_Light", "Camera_Custom_Zoomin_Dark")
		local px, py, pz, pitch, yaw, roll, fov = c_camera_getcamera(dummyname)
		local headposition = appearancepreview_getforcusposition()
		maincamera_movetoposition(px, headposition, pz, pitch, yaw, roll, fov, 0.0)
	end
end

function appearance_delegate_scaleup()
	local dummyname = math.ternary(m_uiappearance_civ == playerciv.light, "Camera_Custom_Zoomin_Light", "Camera_Custom_Zoomin_Dark")
	local px, py, pz, pitch, yaw, roll, fov = c_camera_getcamera(dummyname)
	local headposition = appearancepreview_getforcusposition()
	maincamera_movetoposition(px, headposition, pz, pitch, yaw, roll, fov, 0.5)
	m_appearance_button_scaleup:setenable(false)
	m_appearance_button_scaledown:setenable(true)
end

function appearance_delegate_scaledown()
	if m_uiappearance_civ == playerciv.light then
		maincamera_moveto("Camera_Custom_Light", 0.5)
	else
		maincamera_moveto("Camera_Custom_Dark", 0.5)
	end
	m_appearance_button_scaleup:setenable(true)
	m_appearance_button_scaledown:setenable(false)
end

function appearance_delegate_back()
	if m_uiappearance.typecreate then
		m_uiappearance_inputname = appearancename_getname()
		m_uiappearance:close()
		m_uilogin_createcareer:open()
		audiomanager_playmusic("sounds/music/login_bgm-main.ogg", 0.0, audioflag.loop)
	else
		local msg = {messageid="CS_PlayerResetSkinCancel"}
		c_send(msg)
	end
end

function appearancename_delegate_create()
	if m_uiappearance.typecreate then
		local name = appearancename_getname()
		if name == nil or string.len(name) < 1 then
			messagealert_addalert("LOGIN_CREATEPLAYER_INPUTTIPS")
			return
		end
		local msg = {messageid="CS_CreatePlayer"}
		msg.name = name
		msg.civ = m_uiappearance_civ
		msg.sex = m_uiappearance_sex
		msg.voice = m_uiappearance_voice
		msg.career = m_uiappearance_career
		msg.skin = {}
		appearance_tomessage(msg.skin)
		c_send(msg)
	else
		local item = nil
		if m_uiappearance_sex == playerattr_info.sex then
			item = playeritem_getfrombagscript("resetroleskin")
		else
			item = playeritem_getfrombagscript("resetrolesex")
		end
    	if item ~= nil then
			local msg = {messageid="CS_PlayerResetSkinFinish"}
			msg.itemuuid = item.uuid
			msg.sex = m_uiappearance_sex
			msg.voice = m_uiappearance_voice
			msg.skin = {}
			appearance_tomessage(msg.skin)
			c_send(msg)
		else
			local msg = {messageid="CS_PlayerResetSkinCancel"}
			c_send(msg)
		end
	end
end

function appearance_mouserotate(sender, event)
	if event.name == "dragstart" then
		sender.dragstart = event.mousex
    elseif event.name == "drag" then
		local delta = event.mousex - sender.dragstart
		sender.dragstart = event.mousex
		appearancepreview_rotate(-delta * 0.2)
	elseif event.name == "mousewheel" then
		if event.wheely > 0 then
			appearance_delegate_scaleup()
		elseif event.wheely < 0 then
			appearance_delegate_scaledown()
		end
    end
end
