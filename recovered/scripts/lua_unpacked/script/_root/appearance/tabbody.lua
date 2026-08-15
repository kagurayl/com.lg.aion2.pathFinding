
local m_bodyslider_morph = {}
local m_bodyslider_bodysize = nil

local function appearancebody_loadslider(index, tab, name)
	local slider = m_uiappearance:getwidget(string.format("tab_body/tab_body%d/%s", tab, name))
	slider:setdelegate(appearancebody_delegate_morphslider)
	slider:setminmax(-1.0, 1.0)
	slider.morphindex = index
	m_bodyslider_morph[index] = slider
end

function appearancebody_onopen()
	m_uiappearance.tabbody = uitabcreate(m_uiappearance)
	for i=1,5 do
		m_uiappearance.tabbody:add("tab_body/button_tab" .. i, "tab_body/tab_body" .. i)
	end
	m_uiappearance.tabbody:settab(1)
	
	appearancebody_loadslider(1, 1, "slider_headsize")

	appearancebody_loadslider(2, 2, "slider_necksize")
	appearancebody_loadslider(3, 2, "slider_necklength")
	appearancebody_loadslider(4, 2, "slider_shoulder")
	appearancebody_loadslider(5, 2, "slider_shoulderwidth")

	appearancebody_loadslider(6, 3, "slider_torsolength")
	appearancebody_loadslider(7, 3, "slider_chest")
	appearancebody_loadslider(8, 3, "slider_bust")
	appearancebody_loadslider(9, 3, "slider_waist")
	appearancebody_loadslider(10, 3, "slider_hip")

	appearancebody_loadslider(11, 4, "slider_upperarmsize")
	appearancebody_loadslider(12, 4, "slider_lowerarmsize")
	appearancebody_loadslider(13, 4, "slider_armlength")
	appearancebody_loadslider(14, 4, "slider_handlength")
	appearancebody_loadslider(15, 4, "slider_handsize")

	appearancebody_loadslider(16, 5, "slider_thighsize")
	appearancebody_loadslider(17, 5, "slider_calfsize")
	appearancebody_loadslider(18, 5, "slider_leglength")
	appearancebody_loadslider(19, 5, "slider_footsize")

	m_bodyslider_bodysize = m_uiappearance:getwidget("tab_body/tab_body1/slider_bodysize")
	m_bodyslider_bodysize:setdelegate(appearancebody_delegate_bodysize)
	m_bodyslider_bodysize:setminmax(-1.0, 1.0)
end

function appearancebody_updateui()
	for i=1,#m_bodyslider_morph do
		local slider = morph_valtoslider(m_appearance_bodymorph[i], MorphBodyRange[i])
		m_bodyslider_morph[i]:setslider(slider)
	end
	local bodysizeslider = m_appearance_faceselect[MorphSelect.bodysize]
	if bodysizeslider < 1.0 then
        bodysizeslider = -1.0 + (bodysizeslider - MorphBodySizeRange[1]) / (1.0 - MorphBodySizeRange[1])
    elseif bodysizeslider > 1.0 then
        bodysizeslider = (bodysizeslider - 1.0) / (MorphBodySizeRange[2] - 1.0)
	else
		bodysizeslider = 0.0
    end
	m_bodyslider_bodysize:setslider(math.clamp(bodysizeslider, -1.0, 1.0))
end

function appearancebody_delegate_morphslider(sender)
	local slider = sender:getvalue()
	m_appearance_bodymorph[sender.morphindex] = morph_slidertoval(slider, MorphBodyRange[sender.morphindex])
	appearancepreview_applybody()
end

function appearancebody_delegate_bodysize(sender)
	local slider = sender:getvalue()
	if slider < 0 then
        slider = math.lerp(1.0, MorphBodySizeRange[1], -slider)
    elseif slider > 0 then
        slider = math.lerp(1.0, MorphBodySizeRange[2], slider)
    end
	appearancepreview_setbodysize(slider)
end

function appearancebody_delegate_reset()
	for i=1,BodyMorphCount do
		m_appearance_bodymorph[i] = 0.0
	end
	appearancepreview_applybody()
	appearancepreview_setbodysize(1.0)
	appearancebody_updateui()
end
