
local m_appearance_previewactor = nil
local m_appearance_previewrotate = 0.0
local m_appearance_render =
{
	{itemsetid = 17, idleanim = "nidle_warrior_custom_001"},
	{itemsetid = 16, idleanim = "nidle_scout_custom_001"},
	{itemsetid = 15, idleanim = "nidle_mage_custom_001"},
	{itemsetid = 14, idleanim = "nidle_cleric_custom_001"},
}

function appearancepreview_create()
	m_appearance_previewrotate = 90.0
	appearancepreview_destroy()
	local dummyname
	if m_uiappearance_civ == playerciv.light then
		dummyname = "Position_Custom_Light"
	else
		dummyname = "Position_Custom_Dark"
	end
	local success,px,py,pz,rx,ry,rz,sx,sy,sz = c_scene_dummy(dummyname)
	m_appearance_previewactor = _actorclass.new()
	m_appearance_previewactor:initactor(RenderLayerDefault)
	m_appearance_previewactor:settransform(px, py, pz, 0, m_appearance_previewrotate, 0, sx, sy, sz)
	m_appearance_previewactor:createactor(0, string.format("createplayer_%d_%d", m_uiappearance_career, m_uiappearance_sex))
	m_appearance_previewactor.attr = {}
	m_appearance_previewactor.attr.civ = m_uiappearance_civ
	m_appearance_previewactor.attr.sex = m_uiappearance_sex
	m_appearance_previewactor.attr.voice = m_uiappearance_voice
	m_appearance_previewactor.attr.career = m_uiappearance_career
	m_appearance_previewactor:loadskeleton(csvrender_getskeletonid(m_uiappearance_civ, m_uiappearance_sex))
	m_appearance_previewactor:loadskin(renderslot.face, false, RenderDefault_Face, nil)
	local config_itemset = csvitemset_getfromid(m_appearance_render[m_uiappearance_career].itemsetid)
	if config_itemset ~= nil then
		local itemsetitem = string.splitinterger(config_itemset.item, ",")
		for i=1, #config_itemset.item do
			local config_item = csvitem_getfromid(itemsetitem[i])
			if config_item ~= nil then
				local part, file = csvrender_getitemrender(config_item)
				if part ~= nil and csvrender_partisskin(part) and part ~= renderslot.face then
					m_appearance_previewactor:loadskin(part, false, file, nil)
				end
			end
		end
	end
	m_appearance_previewactor:playanim(m_appearance_render[m_uiappearance_career].idleanim)
end

function appearancepreview_destroy()
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:destroyactor()
		m_appearance_previewactor = nil
	end
end

function appearancepreview_applyfacemorph()
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:applyfacemorph()
	end
end

function appearancepreview_applybody()
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:setbodymorph(m_appearance_bodymorph, m_appearance_faceselect[MorphSelect.faceshape])
	end
end

function appearancepreview_setbodysize(val)
	m_appearance_faceselect[MorphSelect.bodysize] = math.clamp(val, MorphBodySizeRange[1], MorphBodySizeRange[2])
	if m_appearance_previewactor ~= nil then
		local scale = m_appearance_faceselect[MorphSelect.bodysize]
		m_appearance_previewactor:setscale(scale, scale, scale)
	end
	login_createplayer_updatecameraposition()
end

function appearancepreview_sethair(val)
	m_appearance_faceselect[MorphSelect.hair] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitHair)
	if m_appearance_previewactor ~= nil then
		local hair = m_appearance_faceselect[MorphSelect.hair]
		m_appearance_previewactor:loadhair(csvrender_gethairrender(m_uiappearance_civ, m_uiappearance_sex, hair))
		m_appearance_previewactor:sethairmode(subrenderhairmode.hair)
	end
end

function appearancepreview_setfaceskin(val)
	m_appearance_faceselect[MorphSelect.face] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitFace)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:loadface(m_appearance_faceselect[MorphSelect.face])
	end
end

function appearancepreview_setfacefeat1(val)
	m_appearance_faceselect[MorphSelect.feat1] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitFeat1)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:loadfeat1(m_appearance_faceselect[MorphSelect.feat1])
	end
end

function appearancepreview_setfacefeat2(val)
	m_appearance_faceselect[MorphSelect.feat2] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitFeat2)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:loadfeat2(m_appearance_faceselect[MorphSelect.feat2])
	end
end

function appearancepreview_setfacebump(val)
	m_appearance_faceselect[MorphSelect.bump] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitBump)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:loadbump(m_appearance_faceselect[MorphSelect.bump])
	end
end

function appearancepreview_setfaceexpression(val)
	m_appearance_faceselect[MorphSelect.expression] = morph_getround(val, m_uiappearance_civ, m_uiappearance_sex, MorphLimitExpression)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:setfacemorphexpression(m_appearance_faceselect[MorphSelect.expression])
	end
end

function appearancepreview_setfaceshape(val)
	m_appearance_faceselect[MorphSelect.faceshape] = val
end

function appearancepreview_setfacemorph(type, val)
	m_appearance_facemorph[type] = val
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:setfacemorphindex(type, val)
	end
end

function appearancepreview_updateactorcolor()
	if m_appearance_previewactor ~= nil then
		local skin_r, skin_g, skin_b = HexRGB(m_appearance_faceselect[MorphSelect.skincolor])
		local hair_r, hair_g, hair_b = HexRGB(m_appearance_faceselect[MorphSelect.haircolor])
		local lip_r, lip_g, lip_b = HexRGB(m_appearance_faceselect[MorphSelect.lipcolor])
		for i=renderslot.torso, renderslot.hair do
			if i ~= renderslot.face then
				m_appearance_previewactor:setmaterialcolor3x3(i, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, 1.0, 1.0, 1.0)
			end
		end
		m_appearance_previewactor:setmaterialcolor3x3(renderslot.face, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, lip_r, lip_g, lip_b)
	end
end

function appearancepreview_setskincolor(r, g, b)
	m_appearance_faceselect[MorphSelect.skincolor] = ToHex(r, g, b)
end

function appearancepreview_sethaircolor(r,g,b)
	m_appearance_faceselect[MorphSelect.haircolor] = ToHex(r, g, b)
end

function appearancepreview_setlipcolor(r, g, b)
	m_appearance_faceselect[MorphSelect.lipcolor] = ToHex(r, g, b)
end

function appearancepreview_seteyecolor(r,g,b)
	m_appearance_faceselect[MorphSelect.eyecolor] = ToHex(r, g, b)
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:seteyecolor(r, g, b)
	end
end

function appearancepreview_rotate(rot)
	m_appearance_previewrotate = m_appearance_previewrotate + rot
	if m_appearance_previewactor ~= nil then
		m_appearance_previewactor:setrotation(0, m_appearance_previewrotate, 0.0)
	end
end

function appearancepreview_getforcusposition()
	if m_appearance_previewactor ~= nil then
		local px,py,pz,rx,ry,rz,sx,sy,sz = m_appearance_previewactor:getsubtransform("bip01 head", true)
		return py
	end
	return 0.0
end
