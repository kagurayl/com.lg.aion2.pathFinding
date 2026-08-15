
local m_appearancefacepreset_morphinst = "appearance/inst_preset"

local function appearancefacepreset_apply()
	appearancepreview_sethair(m_appearance_faceselect[MorphSelect.hair])
	appearancepreview_setfaceskin(m_appearance_faceselect[MorphSelect.face])
	appearancepreview_setfacefeat1(m_appearance_faceselect[MorphSelect.feat1])
	appearancepreview_setfacefeat2(m_appearance_faceselect[MorphSelect.feat2])
	appearancepreview_setfacebump(m_appearance_faceselect[MorphSelect.bump] or 0)
	appearancepreview_setfaceexpression(m_appearance_faceselect[MorphSelect.expression] or 0)
	appearancepreview_setfaceshape(m_appearance_faceselect[MorphSelect.faceshape])
	appearancepreview_sethaircolor(HexRGB(m_appearance_faceselect[MorphSelect.haircolor], 16))
	appearancepreview_seteyecolor(HexRGB(m_appearance_faceselect[MorphSelect.eyecolor], 16))
	appearancepreview_setlipcolor(HexRGB(m_appearance_faceselect[MorphSelect.lipcolor], 16))
	appearancepreview_setskincolor(HexRGB(m_appearance_faceselect[MorphSelect.skincolor], 16))
	for i=1,FaceMorphCount do
		appearancepreview_setfacemorph(i, m_appearance_facemorph[i])
	end
	appearancepreview_applyfacemorph()
	appearancepreview_applybody()
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

local function appearancefacepreset_loadpreset(config_preset)
	local facemorph = string.splitnumber(config_preset.facedetail, ",")
	m_appearance_faceselect[MorphSelect.hair] = config_preset.hair
	m_appearance_faceselect[MorphSelect.face] = config_preset.face
	m_appearance_faceselect[MorphSelect.feat1] = config_preset.feat1
	m_appearance_faceselect[MorphSelect.feat2] = config_preset.feat2
	m_appearance_faceselect[MorphSelect.bump] = 0
	m_appearance_faceselect[MorphSelect.expression] = 0
	m_appearance_faceselect[MorphSelect.faceshape] = facemorph[FaceMorphCount + 1]
	m_appearance_faceselect[MorphSelect.haircolor] = config_preset.haircolor
	m_appearance_faceselect[MorphSelect.eyecolor] = config_preset.eyecolor
	m_appearance_faceselect[MorphSelect.lipcolor] = config_preset.lipcolor
	m_appearance_faceselect[MorphSelect.skincolor] = config_preset.skincolor
	for i=1,FaceMorphCount do
		m_appearance_facemorph[i] = facemorph[i]
	end
end

function appearancefacepreset_onopen()
	local presetarrayface = csvrenderpreset_getloginfacepreset(m_uiappearance_civ, m_uiappearance_sex)
	local list_facepreset = m_uiappearance:getwidget("tab_left/tab_facepreset/list_facepreset")
	list_facepreset:init(uilistflag.vertical)
	list_facepreset:setclickdelegate(appearancefacepreset_facepreset)
	for i=1,#presetarrayface do
		local preset = presetarrayface[i]
		local line = list_facepreset:add(m_appearancefacepreset_morphinst, i, preset)
		local text_name = line:getwidget("text_name")
		text_name:settext("LOGIN_CREATEPLAYER_FACEPRESET", i)
	end
	appearancefacepreset_apply()
end

function appearancefacepreset_resetpreset()
	local presetarrayface = csvrenderpreset_getloginfacepreset(m_uiappearance_civ, m_uiappearance_sex)
	appearancefacepreset_loadpreset(presetarrayface[1])
end

function appearancefacepreset_facepreset(line, event, config_preset)
	appearancefacepreset_loadpreset(config_preset)
	appearancefacepreset_apply()
end
