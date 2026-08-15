
local m_preset_haircolor_lm = {0xffffff,0xdc6d6d,0xfcd58c,0x98c385,0x8fb9c3,0x745631,0x68a0db,0x2d3664,0xd78c50,0xdf7f73}
local m_preset_haircolor_lf = {0xffffff,0xdc6d6d,0xfcd58c,0x98c385,0x7dd1d5,0x745631,0x68a0db,0x3c456a,0xd78c50,0x7e67cc}
local m_preset_haircolor_dm = {0xffffff,0xdc6d6d,0xfcd58c,0x98c385,0x8fb9c3,0x745631,0x68a0db,0x2d3664,0xd78c50,0xdf7f73}
local m_preset_haircolor_df = {0xffffff,0xdc6d6d,0xfcd58c,0x98c385,0x8fb9c3,0x745631,0x68a0db,0x2d3664,0xd78c50,0xdf7f73}
local m_preset_eyecolor_lm = {0x8c7769,0x7a6150,0x454545,0x4051a8,0xc7c7c7,0x62a3bd,0x607e4b,0xc25252,0xaaca6c,0xa98ed0}
local m_preset_eyecolor_lf = {0x8c7769,0x7a6150,0x454545,0x4051a8,0xc7c7c7,0x62a3bd,0x607e4b,0xc25252,0xaaca6c,0xa98ed0}
local m_preset_eyecolor_dm = {0x8c7769,0x7a6150,0x454545,0x4051a8,0xc7c7c7,0x62a3bd,0x607e4b,0xc25252,0xaaca6c,0xa98ed0}
local m_preset_eyecolor_df = {0x8c7769,0x7a6150,0x454545,0x4051a8,0xc7c7c7,0x62a3bd,0x607e4b,0xc25252,0xaaca6c,0xa98ed0}
local m_preset_lipcolor_lm = {0xffdfd2,0xd1a99b,0xfbc5cb,0xe4a3a9,0xffa6d9,0xea928e,0xaba9ea,0xc380a9,0xe390ac,0x866458}
local m_preset_lipcolor_lf = {0xffdfd2,0xd1a99b,0xfbc5cb,0xe4a3a9,0xffa6d9,0xea928e,0xaba9ea,0xc380a9,0xe390ac,0x866458}
local m_preset_lipcolor_dm = {0xe5e5ff,0xa8a8f7,0x857cb2,0xc4a8c8,0xdcb598,0xafcece,0x8c7694,0xb2b2c1,0xbe84ac,0x6b5252}
local m_preset_lipcolor_df = {0xe5e5ff,0xa8a8f7,0x857cb2,0xc4a8c8,0xdcb598,0xafcece,0x8c7694,0xb2b2c1,0xbe84ac,0x6b5252}
local m_preset_skincolor_lm = {0xf0dcd7,0xfedad1,0xeec6c1,0xdeb3b0,0xfad0bd,0xe2a893,0xe6af8c,0xbf8a75,0x9f7672,0xa47b61}
local m_preset_skincolor_lf = {0xf0dcd7,0xfedad1,0xeec6c1,0xdeb3b0,0xfad0bd,0xe2a893,0xe6af8c,0xbf8a75,0x9f7672,0xa47b61}
local m_preset_skincolor_dm = {0xd2d7f4,0xafabcd,0xa6adc9,0xbfd7f0,0xd0b9e4,0xe8bed9,0xccc1f8,0x959eb8,0x7d6d8b,0x8e83a7}
local m_preset_skincolor_df = {0xd2d7f4,0xafabcd,0xa6adc9,0xbfd7f0,0xd0b9e4,0xe8bed9,0xccc1f8,0x959eb8,0x7d6d8b,0x8e83a7}

local m_faceslider_morph = {}
local m_faceslider_shape = nil

local m_tabface_image_hair = nil
local m_tabface_image_eye = nil
local m_tabface_image_lip = nil
local m_tabface_image_skin = nil

local function appearanceface_loadslider(index, tab)
	local slider = m_uiappearance:getwidget(string.format("tab_face/tab_face%d/slider_morph_%d", tab, index))
	slider:setdelegate(appearanceface_delegate_morphslider)
	slider:setminmax(-1.0, 1.0)
	slider.morphindex = index
	m_faceslider_morph[index] = slider
end

local function appearanceface_getcolorpreset(lm, lf, dm, df)
	if m_uiappearance_civ == playerciv.light then
        if m_uiappearance_sex == playersex.male then
            return lm
        else
            return lf
        end
    else
        if m_uiappearance_sex == playersex.male then
            return dm
        else
            return df
        end
    end
end

function appearanceface_onopen()
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_hair/button_leftarrow", appearanceface_delegate_hairprev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_hair/button_rightarrow", appearanceface_delegate_hairnext)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_face/button_leftarrow", appearanceface_delegate_faceprev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_face/button_rightarrow", appearanceface_delegate_facenext)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_feat1/button_leftarrow", appearanceface_delegate_feat1prev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_feat1/button_rightarrow", appearanceface_delegate_feat1next)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_feat2/button_leftarrow", appearanceface_delegate_feat2prev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_feat2/button_rightarrow", appearanceface_delegate_feat2next)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_bump/button_leftarrow", appearanceface_delegate_bumpprev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_bump/button_rightarrow", appearanceface_delegate_bumpnext)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_expression/button_leftarrow", appearanceface_delegate_expressionprev)
	m_uiappearance:setwidgetdelegate("tab_face/tab_face1/select_expression/button_rightarrow", appearanceface_delegate_expressionnext)

	m_tabface_image_hair = m_uiappearance:getwidget("tab_face/tab_face2/image_haircolor")
	m_tabface_image_eye = m_uiappearance:getwidget("tab_face/tab_face2/image_eyecolor")
	m_tabface_image_lip = m_uiappearance:getwidget("tab_face/tab_face2/image_lipcolor")
	m_tabface_image_skin = m_uiappearance:getwidget("tab_face/tab_face2/image_skincolor")
	m_tabface_image_hair:setdelegate(appearanceface_delegate_haircolor)
	m_tabface_image_eye:setdelegate(appearanceface_delegate_eyecolor)
	m_tabface_image_lip:setdelegate(appearanceface_delegate_lipcolor)
	m_tabface_image_skin:setdelegate(appearanceface_delegate_skincolor)

	m_uiappearance.tabface = uitabcreate(m_uiappearance)
	for i=1,8 do
		m_uiappearance.tabface:add("tab_face/button_tab" .. i, "tab_face/tab_face" .. i)
	end
	m_uiappearance.tabface:settab(1)

	appearanceface_loadslider(1, 3)
	appearanceface_loadslider(2, 3)
	appearanceface_loadslider(3, 3)
	appearanceface_loadslider(4, 5)
	appearanceface_loadslider(5, 5)
	appearanceface_loadslider(6, 5)
	appearanceface_loadslider(7, 5)
	appearanceface_loadslider(8, 5)
	appearanceface_loadslider(9, 5)
	appearanceface_loadslider(10, 4)
	appearanceface_loadslider(11, 4)
	appearanceface_loadslider(12, 4)
	appearanceface_loadslider(13, 6)
	appearanceface_loadslider(14, 6)
	appearanceface_loadslider(15, 6)
	appearanceface_loadslider(16, 6)
	appearanceface_loadslider(17, 3)
	appearanceface_loadslider(18, 7)
	appearanceface_loadslider(19, 7)
	appearanceface_loadslider(20, 7)
	appearanceface_loadslider(21, 7)
	appearanceface_loadslider(22, 7)
	appearanceface_loadslider(23, 8)
	appearanceface_loadslider(24, 8)
	appearanceface_loadslider(25, 8)

	m_faceslider_shape = m_uiappearance:getwidget("tab_face/tab_face3/slider_faceshape")
	m_faceslider_shape:setdelegate(appearanceface_delegate_faceshape)
	m_faceslider_shape:setminmax(-1.0, 1.0)
end

function appearanceface_updateui()
	local text_hair = m_uiappearance:getwidget("tab_face/tab_face1/select_hair/text_select")
	text_hair:settext("LOGIN_CREATEPLAYER_HAIRID", m_appearance_faceselect[MorphSelect.hair])

	local text_face = m_uiappearance:getwidget("tab_face/tab_face1/select_face/text_select")
	text_face:settext("LOGIN_CREATEPLAYER_FACEID", m_appearance_faceselect[MorphSelect.face])

	local text_feat1 = m_uiappearance:getwidget("tab_face/tab_face1/select_feat1/text_select")
	if m_appearance_faceselect[MorphSelect.feat1] == 0 then
		text_feat1:settext("LOGIN_CREATEPLAYER_DECALNONE")
	else
		text_feat1:settext("LOGIN_CREATEPLAYER_FEAT1ID", m_appearance_faceselect[MorphSelect.feat1])
	end

	local text_feat2 = m_uiappearance:getwidget("tab_face/tab_face1/select_feat2/text_select")
	if m_appearance_faceselect[MorphSelect.feat2] == 0 then
		text_feat2:settext("LOGIN_CREATEPLAYER_DECALNONE")
	else
		text_feat2:settext("LOGIN_CREATEPLAYER_FEAT2ID", m_appearance_faceselect[MorphSelect.feat2])
	end

	local text_bump = m_uiappearance:getwidget("tab_face/tab_face1/select_bump/text_select")
	if m_appearance_faceselect[MorphSelect.bump] == 0 then
		text_bump:settext("LOGIN_CREATEPLAYER_DECALNONE")
	else
		text_bump:settext("LOGIN_CREATEPLAYER_BUMPID", m_appearance_faceselect[MorphSelect.bump])
	end

	local text_expression = m_uiappearance:getwidget("tab_face/tab_face1/select_expression/text_select")
	if m_appearance_faceselect[MorphSelect.expression] == 0 then
		text_expression:settext("LOGIN_CREATEPLAYER_DECALNONE")
	else
		text_expression:settext("LOGIN_CREATEPLAYER_FACEEXPRESSIONID", m_appearance_faceselect[MorphSelect.expression])
	end

	for i=1,#m_faceslider_morph do
		local slider = morph_valtoslider(m_appearance_facemorph[i], MorphFaceRange)
		m_faceslider_morph[i]:setslider(slider)
	end

	local shapeslider = morph_valtoslider(m_appearance_faceselect[MorphSelect.faceshape], MorphFaceShapeRange)
	m_faceslider_shape:setslider(shapeslider)

	m_tabface_image_hair:setrgb(HexRGB(m_appearance_faceselect[MorphSelect.haircolor]))
	m_tabface_image_eye:setrgb(HexRGB(m_appearance_faceselect[MorphSelect.eyecolor]))
	m_tabface_image_lip:setrgb(HexRGB(m_appearance_faceselect[MorphSelect.lipcolor]))
	m_tabface_image_skin:setrgb(HexRGB(m_appearance_faceselect[MorphSelect.skincolor]))
end

function appearanceface_delegate_hairprev(sender)
	appearancepreview_sethair(m_appearance_faceselect[MorphSelect.hair] - 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_hairnext(sender)
	appearancepreview_sethair(m_appearance_faceselect[MorphSelect.hair] + 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_faceprev(sender)
	appearancepreview_setfaceskin(m_appearance_faceselect[MorphSelect.face] - 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_facenext(sender)
	appearancepreview_setfaceskin(m_appearance_faceselect[MorphSelect.face] + 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_feat1prev(sender)
	appearancepreview_setfacefeat1(m_appearance_faceselect[MorphSelect.feat1] - 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_feat1next(sender)
	appearancepreview_setfacefeat1(m_appearance_faceselect[MorphSelect.feat1] + 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_feat2prev(sender)
	appearancepreview_setfacefeat2(m_appearance_faceselect[MorphSelect.feat2] - 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_feat2next(sender)
	appearancepreview_setfacefeat2(m_appearance_faceselect[MorphSelect.feat2] + 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_bumpprev(sender)
	appearancepreview_setfacebump(m_appearance_faceselect[MorphSelect.bump] - 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_bumpnext(sender)
	appearancepreview_setfacebump(m_appearance_faceselect[MorphSelect.bump] + 1)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_expressionprev(sender)
	appearancepreview_setfaceexpression(m_appearance_faceselect[MorphSelect.expression] - 1)
	appearancepreview_updateactorcolor()
	appearancepreview_applyfacemorph()
	appearanceface_updateui()
end

function appearanceface_delegate_expressionnext(sender)
	appearancepreview_setfaceexpression(m_appearance_faceselect[MorphSelect.expression] + 1)
	appearancepreview_updateactorcolor()
	appearancepreview_applyfacemorph()
	appearanceface_updateui()
end

function appearanceface_delegate_morphslider(sender)
	local val = morph_slidertoval(sender:getvalue(), MorphFaceRange)
	appearancepreview_setfacemorph(sender.morphindex, val)
	appearancepreview_updateactorcolor()
	appearancepreview_applyfacemorph()
end

function appearanceface_delegate_faceshape(sender)
	local val = morph_slidertoval(sender:getvalue(), MorphFaceShapeRange)
	appearancepreview_setfaceshape(val)
	appearancepreview_updateactorcolor()
	appearancepreview_applybody()
end

function appearanceface_delegate_haircolor(sender)
	local preset = appearanceface_getcolorpreset(m_preset_haircolor_lm, m_preset_haircolor_lf, m_preset_haircolor_dm, m_preset_haircolor_df)
	colorpicker_create(m_appearance_faceselect[MorphSelect.haircolor], preset, appearanceface_delegate_haircolorpick, nil)
end

function appearanceface_delegate_haircolorpick(r, g, b, data)
	appearancepreview_sethaircolor(r, g, b)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_eyecolor(sender)
	local preset = appearanceface_getcolorpreset(m_preset_eyecolor_lm, m_preset_eyecolor_lf, m_preset_eyecolor_dm, m_preset_eyecolor_df)
	colorpicker_create(m_appearance_faceselect[MorphSelect.eyecolor], preset, appearanceface_delegate_eyecolorpick, nil)
end

function appearanceface_delegate_eyecolorpick(r, g, b, data)
	appearancepreview_seteyecolor(r, g, b)
	appearanceface_updateui()
end

function appearanceface_delegate_lipcolor(sender)
	local preset = appearanceface_getcolorpreset(m_preset_lipcolor_lm, m_preset_lipcolor_lf, m_preset_lipcolor_dm, m_preset_lipcolor_df)
	colorpicker_create(m_appearance_faceselect[MorphSelect.lipcolor], preset, appearanceface_delegate_lipcolorpick, nil)
end

function appearanceface_delegate_lipcolorpick(r, g, b, data)
	appearancepreview_setlipcolor(r, g, b)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_skincolor(sender)
	local preset = appearanceface_getcolorpreset(m_preset_skincolor_lm, m_preset_skincolor_lf, m_preset_skincolor_dm, m_preset_skincolor_df)
	colorpicker_create(m_appearance_faceselect[MorphSelect.skincolor], preset, appearanceface_delegate_skincolorpick, nil)
end

function appearanceface_delegate_skincolorpick(r, g, b, data)
	appearancepreview_setskincolor(r, g, b)
	appearancepreview_updateactorcolor()
	appearanceface_updateui()
end

function appearanceface_delegate_reset()
	for i=1,#m_faceslider_morph do
		appearancepreview_setfacemorph(i, 0)
	end
	appearancepreview_updateactorcolor()
	appearancepreview_applyfacemorph()
	appearanceface_updateui()
end
