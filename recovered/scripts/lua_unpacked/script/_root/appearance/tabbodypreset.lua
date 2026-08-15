
local m_appearancebodypreset_morphinst = "appearance/inst_preset"

local function appearancebodypreset_apply()
	appearancepreview_setbodysize(m_appearance_faceselect[MorphSelect.bodysize])
	appearancepreview_applybody()
	appearancebody_updateui()
end

local function appearancebodypreset_loadpreset(config_preset)
	local bodymorph = string.splitnumber(config_preset.bodydetail, ",")
	for i=1,BodyMorphCount do
		m_appearance_bodymorph[i] = bodymorph[i]
	end
	m_appearance_faceselect[MorphSelect.bodysize] = config_preset.scale
end

function appearancebodypreset_onopen()
	local presetarraybody = csvrenderpreset_getloginbodypreset(m_uiappearance_civ, m_uiappearance_sex)
	local list_bodypreset = m_uiappearance:getwidget("tab_left/tab_bodypreset/list_bodypreset")
	list_bodypreset:init(uilistflag.vertical)
	list_bodypreset:setclickdelegate(appearancebodypreset_bodypreset)
	for i=1,#presetarraybody do
		local preset = presetarraybody[i]
		local line = list_bodypreset:add(m_appearancebodypreset_morphinst, i, preset)
		local text_name = line:getwidget("text_name")
		if m_uiappearance_sex == playersex.male then
			text_name:settext("LOGIN_CREATEPLAYER_BODYPRESET_MALE_" .. i)
		else
			text_name:settext("LOGIN_CREATEPLAYER_BODYPRESET_FEMALE_" .. i)
		end
	end
	appearancebodypreset_apply()
end

function appearancebodypreset_resetpreset()
	local presetarraybody = csvrenderpreset_getloginbodypreset(m_uiappearance_civ, m_uiappearance_sex)
	appearancebodypreset_loadpreset(presetarraybody[1])
end

function appearancebodypreset_bodypreset(line, event, config_preset)
	appearancebodypreset_loadpreset(config_preset)
	appearancebodypreset_apply()
end
