
include("appearance/appearancemain")
include("appearance/tabface")
include("appearance/tabbody")
include("appearance/tabname")
include("appearance/tabvoice")
include("appearance/tabfacepreset")
include("appearance/tabbodypreset")
include("appearance/preview")

m_uiappearance = uipanel_createhandle("appearance/appearance", uilayer.normal, 0)
m_uiappearance_inputname = nil
m_uiappearance_career = nil
m_uiappearance_civ = nil
m_uiappearance_sex = nil
m_uiappearance_voice = nil
m_appearance_faceselect = nil
m_appearance_facemorph = nil
m_appearance_bodymorph = nil

function appearance_create()
	m_uiappearance:open()
end

function appearance_setdata(career, civ, sex, voice, typecreate)
	m_uiappearance_career = career
	m_uiappearance_civ = civ
	m_uiappearance_sex = sex
	m_uiappearance_voice = voice
	m_uiappearance.typecreate = typecreate
	if typecreate or m_appearance_faceselect == nil then
		m_appearance_faceselect = {}
		m_appearance_facemorph = {}
		m_appearance_bodymorph = {}
		appearancefacepreset_resetpreset()
		appearancebodypreset_resetpreset()
	end
end

function appearance_close()
	m_uiappearance:close()
end

function appearance_onrandomname(msg)
	if msg.name ~= nil and string.len(msg.name) > 1 then
		m_uiappearance_inputname = msg.name
		if m_uiappearance:alive() then
			local edit_input = m_uiappearance:getwidget("tab_left/tab_name/edit_name")
			edit_input:settext(m_uiappearance_inputname)
		end
	else
		messagealert_addalert("LOGIN_CREATEPLAYER_FAILEDRAND")
	end
end

function appearance_tomessage(msg)
	msg.hair = m_appearance_faceselect[MorphSelect.hair]
	msg.face = m_appearance_faceselect[MorphSelect.face]
	msg.feat1 = m_appearance_faceselect[MorphSelect.feat1]
	msg.feat2 = m_appearance_faceselect[MorphSelect.feat2]
	msg.bump = m_appearance_faceselect[MorphSelect.bump]
	msg.expression = m_appearance_faceselect[MorphSelect.expression]
	msg.faceshape = m_appearance_faceselect[MorphSelect.faceshape]
	msg.haircolor = m_appearance_faceselect[MorphSelect.haircolor]
	msg.eyecolor = m_appearance_faceselect[MorphSelect.eyecolor]
	msg.lipcolor = m_appearance_faceselect[MorphSelect.lipcolor]
	msg.skincolor = m_appearance_faceselect[MorphSelect.skincolor]
	msg.bodysize = m_appearance_faceselect[MorphSelect.bodysize]
	msg.facemorph = m_appearance_facemorph
	msg.bodymorph = m_appearance_bodymorph
end
