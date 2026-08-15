
local m_tabvoice_maxcount = 4

function appearancevoice_onopen()
	m_uiappearance:setwidgetdelegate("tab_voice/checkbox_type1", appearancevoice_delegate_type1)
	m_uiappearance:setwidgetdelegate("tab_voice/checkbox_type2", appearancevoice_delegate_type2)
	m_uiappearance:setwidgetdelegate("tab_voice/checkbox_type3", appearancevoice_delegate_type3)
	m_uiappearance:setwidgetdelegate("tab_voice/checkbox_type4", appearancevoice_delegate_type4)
	m_uiappearance:setwidgetdelegate("tab_voice/button_preview", appearancevoice_delegate_preview)
	for i=1,m_tabvoice_maxcount do
		local text_type = m_uiappearance:getwidget("tab_voice/checkbox_type" .. i .. "/text_label")
		if m_uiappearance_sex == playersex.male then
			text_type:settext("LOGIN_CREATEPLAYER_VOICE_MALE_" .. i)
		else
			text_type:settext("LOGIN_CREATEPLAYER_VOICE_FEMALE_" .. i)
		end
	end
	appearancevoice_updateui()
end

function appearancevoice_updateui()
	for i=1,m_tabvoice_maxcount do
		local checkbox_type = m_uiappearance:getwidget("tab_voice/checkbox_type" .. i)
		checkbox_type:setcheck(i == (m_uiappearance_voice + 1))
	end
end

function appearancevoice_delegate_type1()
	m_uiappearance_voice = 0
	appearancevoice_updateui()
end

function appearancevoice_delegate_type2()
	m_uiappearance_voice = 1
	appearancevoice_updateui()
end

function appearancevoice_delegate_type3()
	m_uiappearance_voice = 2
	appearancevoice_updateui()
end

function appearancevoice_delegate_type4()
	m_uiappearance_voice = 3
	appearancevoice_updateui()
end

function appearancevoice_delegate_preview()
    local sex = math.ternary(m_uiappearance_sex == playersex.male, "m", "f")
    local civ = math.ternary(m_uiappearance_civ == playerciv.light, "l", "d")
	local voicetype = audiomanager_getvoicetype(m_uiappearance_voice)
	local name = "b_attack_fire_b"
	local filepath = string.format("sounds/voice/cast/vcast_%s%s%s_%s.ogg", sex, civ, voicetype, name)
	audiomanager_playaudio2d(filepath, audiochanneltype.voice, 0)
end
