
function _actorclass:loadskeleton(skeletonid)
	local config_skeleton = c_config_getmetaid(configid.render_skeleton, skeletonid)
	if config_skeleton == nil then
		return
	end
	self.actordata.animroot = config_skeleton.animroot
	self.actordata.meshroot = config_skeleton.meshroot
	self.actordata.meshname = config_skeleton.filename
	self.actordata.assetskeleton = true
	self:loadanimalias(config_skeleton.meshroot .. "/" .. config_skeleton.filename, config_skeleton.filename)
	local skeletonpath = string.format("%s/%s.cgf.prefab", self.actordata.meshroot, self.actordata.meshname)
	self:loadbprender(skeletonpath)
	return config_skeleton
end

function _actorclass:loadskeletonanimalias(skeletonid)
	self.actordata.assetskeleton = true
	local config_skeleton = c_config_getmetaid(configid.render_skeleton, skeletonid)
	if config_skeleton ~= nil then
		self:loadanimalias(config_skeleton.meshroot .. "/" .. config_skeleton.filename, config_skeleton.filename)
	end
end

function _actorclass:getprefabpath(filename)
	if filename == nil then
		return
	end
	return string.format("%s/%s%s.cgf.prefab", self.actordata.meshroot, self.actordata.meshname, filename)
end

function _actorclass:getprefabpathwithoutcgfname(filename)
	if filename == nil then
		return
	end
	return string.format("%s/%s%s", self.actordata.meshroot, self.actordata.meshname, filename)
end

function _actorclass:loadanimalias(meshfile, meshname)
	if self.aliaseverytime ~= nil then
		aliasmanager_destory(self.aliaseverytime)
		self.aliaseverytime = nil
	end
	if meshfile ~= nil then
		self.actordata.animalias = csvanimalias_load(meshfile, meshname)
		self.actordata.skillbone = csvskillbone_getskeleton(meshname)
		local animmarker = csvanimmarker_load(meshname)
		local aliaseverytime = animmarker["everytime"]
		if aliaseverytime ~= nil then
			self.aliaseverytime = aliasmanager_create(aliaseverytime, actorrenderflag.loopanim, nil, 1.0, 0.0)
		elseif #self.actordata.animalias.markerarray == 0 then
			local count = 0
			local defaultmarker = nil
			for key, val in pairs(animmarker) do
				count = count + 1
				defaultmarker = val
				if count > 1 then
					break
				end
			end
			if defaultmarker ~= nil and count == 1 then
				self.aliaseverytime = aliasmanager_create(defaultmarker, actorrenderflag.loopanim, nil, 1.0, 0.0)
			end
		end
	else
		self.actordata.animalias = nil
		self.actordata.skillbone = nil
	end
end

function _actorclass:preadditive()
	if self.actordata.renderadditive ~= nil then
		for i=1,#self.actordata.renderadditive do
			self.actordata.renderadditive[i].render = false
		end
	end
end

function _actorclass:checkadditive(filename)
	local renderarray = c_config_getmetaarray(configid.render_additive, "mesh", filename)
	if renderarray ~= nil then
		if self.actordata.renderadditive == nil then
			self.actordata.renderadditive = {}
		end
		for renderindex=1,#renderarray do
			local config_renderadditive = renderarray[renderindex]
			for i=1,#self.actordata.renderadditive do
				if self.actordata.renderadditive[i].filename == config_renderadditive.mesh then
					self.actordata.renderadditive[i].render = true
 					config_renderadditive = nil
					break
				end
			end
			if config_renderadditive ~= nil then
				local render = {}
				render.render = true
				render.filename = config_renderadditive.additive
				render.bind = config_renderadditive.bind
				self.actordata.renderadditive[#self.actordata.renderadditive + 1] = render
			end
		end
	end
end

function _actorclass:applyadditive()
	if self.actordata.renderadditive ~= nil then
		for i=#self.actordata.renderadditive,1,-1 do
			local renderadditive = self.actordata.renderadditive[i]
			if renderadditive.render then
				if renderadditive.actor == nil then
					renderadditive.actor = _actorclass.new()
					renderadditive.actor.renderlayer = self.renderlayer
					renderadditive.actor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
					renderadditive.actor:createactor(actorrenderflag.bindinverse, string.format("additive_%d", self.id))
					renderadditive.actor:loadbprender(renderadditive.filename .. ".cgf.prefab")
					renderadditive.actor:bindactor(self, renderadditive.bind, -1, -1)
				end
			elseif renderadditive.actor ~= nil then
				renderadditive.actor:destroyactor()
				table.remove(self.actordata.renderadditive, i)
			end
		end
	end
end

function _actorclass:destroyadditive()
	if self.actordata ~= nil and self.actordata.renderadditive ~= nil then
		for i=1,#self.actordata.renderadditive do
			local renderadditive = self.actordata.renderadditive[i]
			if renderadditive.actor ~= nil then
				renderadditive.actor:destroyactor()
			end
		end
		self.actordata.renderadditive = nil
	end
end

function _actorclass:loadbprender(filename)
	c_actor_loadbp(self.id, filename)
end

function _actorclass:loading()
	return c_actor_loading(self.id)
end

function _actorclass:setskincolor(skincolor, haircolor, lipcolor, torsocolor, pantscolor, shouldercolor, glovecolor, shoescolor)
	local skin_r, skin_g, skin_b = HexRGB(skincolor)
	local hair_r, hair_g, hair_b = HexRGB(haircolor)
	local lip_r, lip_g, lip_b = HexRGB(lipcolor)
	local torso_r, torso_g, torso_b = HexRGBDefault(torsocolor)
	local pants_r, pants_g, pants_b = HexRGBDefault(pantscolor)
	local shoulder_r, shoulder_g, shoulder_b = HexRGBDefault(shouldercolor)
	local glove_r, glove_g, glove_b = HexRGBDefault(glovecolor)
	local shoes_r, shoes_g, shoes_b = HexRGBDefault(shoescolor)
	self:setmaterialcolor3x3(renderslot.torso, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, torso_r, torso_g, torso_b)
	self:setmaterialcolor3x3(renderslot.pants, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, pants_r, pants_g, pants_b)
	self:setmaterialcolor3x3(renderslot.shoulder, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, shoulder_r, shoulder_g, shoulder_b)
	self:setmaterialcolor3x3(renderslot.glove, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, glove_r, glove_g, glove_b)
	self:setmaterialcolor3x3(renderslot.shoes, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, shoes_r, shoes_g, shoes_b)
	self:setmaterialcolor3x3(renderslot.hair, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, 1.0, 1.0, 1.0)
	self:setmaterialcolor3x3(renderslot.face, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, lip_r, lip_g, lip_b)
end

function _actorclass:loadskin(part, isbattle, filename, battlefilename)
	if battlefilename ~= nil then
		if self.actordata.battleskin == nil then
			self.actordata.battleskin = {}
		end
		self.actordata.battleskin[part] = {normal = filename, battle = battlefilename}
	elseif self.actordata.battleskin ~= nil then
		self.actordata.battleskin[part] = nil
	end
	if battlefilename ~= nil and isbattle then
		c_actor_loadskin(self.id, part - 1, self:getprefabpath(battlefilename))
	else
		c_actor_loadskin(self.id, part - 1, self:getprefabpath(filename))
	end
end

function _actorclass:loadface(faceid)
	if faceid > 1 then
		local texturepath, civsexname = csvrender_getfacetexturepath(self.attr.civ, self.attr.sex)
		local texturetitle = string.format("%s001_head_d%02d", civsexname, faceid - 1)
		texturepath = string.format("%s/%s.png", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_MainTex", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_IRRADTex", texturepath, texturetitle .. "_illum")
		self:setmaterialtexture(renderslot.face, "_MaskTex", texturepath, texturetitle .. "_mask")
		self:setmaterialtexture(renderslot.face, "_ReflTex", texturepath, texturetitle .. "_sp")
	else
		self:setmaterialtexture(renderslot.face, "_MainTex", nil)
		self:setmaterialtexture(renderslot.face, "_IRRADTex", nil)
		self:setmaterialtexture(renderslot.face, "_MaskTex", nil)
		self:setmaterialtexture(renderslot.face, "_ReflTex", nil)
	end
end

function _actorclass:loadfeat1(feat1id)
	if feat1id > 0 then
		local texturepath, civsexname = csvrender_getfacetexturepath(self.attr.civ, self.attr.sex)
		local texturetitle = string.format("%s_feature_%03d", civsexname, feat1id)
		texturepath = string.format("%s/%s.png", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_Feat1MainTex", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_Feat1IRRADTex", texturepath, texturetitle .. "_illum")
		self:setmaterialtexture(renderslot.face, "_Feat1ReflTex", texturepath, texturetitle .. "_sp")
		self:setmaterialkeyword(renderslot.face, "_FEAT1_ON", true)
	else
		self:setmaterialkeyword(renderslot.face, "_FEAT1_ON", false)
		self:setmaterialtexture(renderslot.face, "_Feat1MainTex", nil)
		self:setmaterialtexture(renderslot.face, "_Feat1IRRADTex", nil)
		self:setmaterialtexture(renderslot.face, "_Feat1ReflTex", nil)
	end
end

function _actorclass:loadfeat2(feat2id)
	if feat2id > 0 then
		local texturepath, civsexname = csvrender_getfacetexturepath(self.attr.civ, self.attr.sex)
		local texturetitle = string.format("%s_tattoo_%03d", civsexname, feat2id)
		texturepath = string.format("%s/%s.png", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_Feat2MainTex", texturepath, texturetitle)
		self:setmaterialtexture(renderslot.face, "_Feat2IRRADTex", texturepath, texturetitle .. "_illum")
		self:setmaterialtexture(renderslot.face, "_Feat2ReflTex", texturepath, texturetitle .. "_sp")
		self:setmaterialkeyword(renderslot.face, "_FEAT2_ON", true)
	else
		self:setmaterialkeyword(renderslot.face, "_FEAT2_ON", false)
		self:setmaterialtexture(renderslot.face, "_Feat2MainTex", nil)
		self:setmaterialtexture(renderslot.face, "_Feat2IRRADTex", nil)
		self:setmaterialtexture(renderslot.face, "_Feat2ReflTex", nil)
	end
end

function _actorclass:loadbump(bumpid)
	if bumpid > 0 then
		local texturepath, civsexname = csvrender_getfacetexturepath(self.attr.civ, self.attr.sex)
		texturepath = string.format("%s/%s001_head_d%02d_ddn.png", texturepath, civsexname, bumpid)
		self:setmaterialtexture(renderslot.face, "_NormalTex", texturepath)
	else
		self:setmaterialtexture(renderslot.face, "_NormalTex", nil)
	end
end

function _actorclass:setopacity(opacity)
	local slot = 0
	if self.slotinparent ~= nil then
		slot = self.slotinparent
	end
	if opacity < 1.0 then
		if opacity <= 0 and not self:isme() then
			self:setactorvisible(false)
		elseif not self:isvisible() then
			self:setactorvisible(true)
		end
		self:setmaterialkeyword(slot, "_DITHERFADE_ON", true)
		self:setmaterialfloat(slot, "_CutDither", opacity)
	else
		self:setactorvisible(true)
		self:setmaterialkeyword(slot, "_DITHERFADE_ON", false)
	end
end

function _actorclass:setmaterialkeyword(part, keyword, enable)
	local flt = math.ternary(enable, 1.0, -1.0)
	c_actor_setmaterialvector(self.id, part - 1, keyword, rendermaterialparam.keyword, flt, flt, flt, flt)
end

function _actorclass:setmaterialfloat(part, parmname, flt)
	c_actor_setmaterialvector(self.id, part - 1, parmname, rendermaterialparam.float, flt, flt, flt, flt)
end

function _actorclass:setmaterialvector(part, parmname, x, y, z, w)
	c_actor_setmaterialvector(self.id, part - 1, parmname, rendermaterialparam.vector, x, y, z, w)
end

function _actorclass:setmaterialcolor(part, parmname, x, y, z, w)
	c_actor_setmaterialvector(self.id, part - 1, parmname, rendermaterialparam.color, x, y, z, w)
end

function _actorclass:setmaterialcolor3x3(part, parmname, r1, g1, b1, r2, g2, b2, r3, g3, b3)
	c_actor_setmaterialcolor3x3(self.id, part - 1, parmname, r1, g1, b1, r2, g2, b2, r3, g3, b3)
end

function _actorclass:setmaterialtexture(part, parmname, filename, texturename)
	c_actor_setmaterialtexture(self.id, part - 1, 0, 0, parmname, filename, texturename)
end

function _actorclass:setsubmaterialtexture(part, mat, flag, parmname, filename, texturename)
	c_actor_setmaterialtexture(self.id, part - 1, mat - 1, flag, parmname, filename, texturename)
end

function _actorclass:seteyecolor(r, g, b)
	self:setmaterialcolor(renderslot.face, "_EyeColor", r, g, b, 1.0)
end

function _actorclass:setfacemorphindex(index, val)
	if val < 0.0 then
		val = val / MorphFaceRange[1]
	elseif val > 0.0 then
		val = val / MorphFaceRange[2]
	end
	val = math.clamp(val, -1.0, 1.0)
    local func = _G["facemorph_set_" .. index]
    if func ~= nil then
        func(self, val)
    end
end

function _actorclass:setfacemorph(name, val)
	c_actor_setmorph(self.id, renderslot.face - 1, name, val)
end

function _actorclass:setfacemorph2(lowname, highname, val)
	if val < 0 then
		c_actor_setmorph(self.id, renderslot.face - 1, lowname, -val)
		c_actor_setmorph(self.id, renderslot.face - 1, highname, 0)
	else
		c_actor_setmorph(self.id, renderslot.face - 1, lowname, 0)
		c_actor_setmorph(self.id, renderslot.face - 1, highname, val)
	end
end

function _actorclass:setfacemorphexpression(val)
	for i=1, 6 do
		self:setfacemorph("facetype_expression_" .. i, math.ternary(val == i, 1.0, 0.0))
	end
end

function _actorclass:applyfacemorph()
	c_actor_applymorph(self.id)
end

function _actorclass:clearfacemorph()
	c_actor_clearmorph(self.id)
end

function _actorclass:setbodymorph(bodyval, faceshape)
	local listapply = {}
	for i=1, #BodyMorph do
		bodymorph_apply(listapply, BodyMorph[i], bodyval[i], MorphBodyRange[i])
    end
	bodymorph_apply(listapply, FaceShapeMorph, faceshape, MorphFaceShapeRange)
	for key, val in pairs(listapply) do
		c_actor_setavatar(self.id, val.name, val.px or 1.0, val.pz or 1.0, val.py or 1.0, val.sx or 1.0, val.sz or 1.0, val.sy or 1.0)
	end
    c_actor_applyavatar(self.id, "bip01 l toe0")
end

function _actorclass:clearbodymorph()
	c_actor_clearavatar(self.id)
	if self.hairactor ~= nil then
		self.hairactor:clearbodymorph()
	end
end

function _actorclass:loadanim(animname)
	if self.actordata.animalias ~= nil then
		local alias = self.actordata.animalias.anim[animname]
		if alias ~= nil then
			c_scene_loadasset(alias.file)
		end
	end
end

function _actorclass:unloadanim(animname)
	if self.actordata.animalias ~= nil then
		local alias = self.actordata.animalias.anim[animname]
		if alias ~= nil then
			c_scene_unloadasset(alias.file)
		end
	end
end

function _actorclass:playanim(animname, flag, speed, blendin, timestart, audiotype)
	if self:isstaticnpc() then
		entitymanager_playentityanim(self.config_npcstatic.staticid, animname, 0)
		return
	end
	if flag == nil then
		flag = 0
	end
	local additive = bit.band(flag, actorrenderflag.additive) > 0
	self.actordata.animaliasrand = nil
	local animaliasrand = nil
	if self.actordata.animalias == nil then
		self:setsubanim(animname, speed, additive, timestart)
		return
	end
	if not additive and bit.band(flag, actorrenderflag.randanim) ~= 0 and self.actordata.animalias.rand ~= nil then
		local randanim = self.actordata.animalias.rand[animname]
		if randanim ~= nil then
			if bit.band(flag, actorrenderflag.loopanim) ~= 0 then
				animaliasrand = randanim
			else
				local randindex = self:getrandanim(randanim)
				if randindex ~= 1 then
					animname = string.format("%s_%03d", randanim.name, randindex)
				end
			end
		end
	end
	self:setsubanim(animname, speed, additive, timestart)
	local alias = self.actordata.animalias.anim[animname]
	if alias ~= nil then
		speed = speed or 1.0
		blendin = blendin or animblendin
		timestart = timestart or 0.0
		if self:isme() then
			flag = bit.bor(flag, actorrenderflag.syncanim)
		end	
		c_actor_playanim(self.id, alias.file, flag, speed, blendin, timestart)
		self:clearanimmesh()
		self.aliasplayer = aliasmanager_create(alias.marker, flag, audiotype, speed, timestart)
		if animaliasrand ~= nil then
			self.actordata.animaliasrand = animaliasrand
			self.actordata.animaliasrandspeed = speed
			self.actordata.animaliasrandflag = flag
			self.actordata.animaliasrandaudiotype = audiotype
			self.actordata.animaliasrandindex = 1
			self.actordata.animaliasranddelta = alias.length
			self.actordata.animaliasrandtime = time_game + alias.length
		end
		return alias
	elseif flag ~= nil and bit.band(flag, actorrenderflag.stopinvalidanim) ~= 0 then
		self:stopanim(flag, 0)
	end
end

function _actorclass:getrandanim(randanim)
	local randrate = math.random()
	for i=1,#randanim.prob do
		if randrate <= randanim.prob[i] then
			return i
		else
			randrate = randrate - randanim.prob[i]
		end
	end
	return 1
end

function _actorclass:playrandanim()
	local animaliasrandindex = 1
	if self.actordata.animaliasrandindex == 1 then
		animaliasrandindex = self:getrandanim(self.actordata.animaliasrand)
		if animaliasrandindex == 1 then
			self.actordata.animaliasrandtime = time_game + self.actordata.animaliasranddelta
			return
		end
	end
	self.actordata.animaliasrandindex = animaliasrandindex
	local animname = string.format("%s_%03d", self.actordata.animaliasrand.name, animaliasrandindex)
	local alias = self.actordata.animalias.anim[animname]
	if alias ~= nil then
		c_actor_playanim(self.id, alias.file, self.actordata.animaliasrandflag, self.actordata.animaliasrandspeed, animblendin, 0.0)
		self:clearanimmesh()
		self.aliasplayer = aliasmanager_create(alias.marker, self.actordata.animaliasrandflag, self.actordata.animaliasrandaudiotype, self.actordata.animaliasrandspeed, 0.0)
		self.actordata.animaliasranddelta = alias.length
		if animaliasrandindex == 1 then
			self.actordata.animaliasrandtime = time_game + alias.length
		else
			self.actordata.animaliasrandtime = time_game + alias.length - animblendin
		end
	else
		self.actordata.animaliasrand = nil
	end
end

function _actorclass:playanimlist(anim, flag, speed, blendin, timestart, audiotype)
	if anim ~= nil then
		local animname = self:getanimlistname(anim)
		local alias = self:playanim(animname, flag, speed, blendin, timestart, audiotype)
		return alias
	end
end

function _actorclass:playadditiveanim(animname, flag, speed, blendin, timestart, audiotype)
    if self:isplayer() then
        flag = bit.bor(flag, actorrenderflag.resetanim, actorrenderflag.additive)
        self.actionadditive.mixed = actionmanager_mixadditive(self)
        if self.actionadditive.mixed then
            flag = bit.bor(flag, actorrenderflag.mixanim)
        else
            flag = bit.bor(flag, actorrenderflag.mixclear)
        end
    else
        flag = bit.bor(flag, actorrenderflag.resetanim, actorrenderflag.additive)
        flag = bit.bor(flag, actorrenderflag.mixclear)
    end
	return self:playanim(animname, flag, speed, blendin, timestart, audiotype)
end

function _actorclass:updateadditiveanim()
	if self:isplayer() then
		if self.actionadditive.mixed ~= actionmanager_mixadditive(self) then
			if self.actionadditive.mixed then
				self.actionadditive.mixed = false
				self:setanimmix(bit.bor(actorrenderflag.mixclear, actorrenderflag.additive))
			else
				self.actionadditive.mixed = true
				self:setanimmix(bit.bor(actorrenderflag.mixanim, actorrenderflag.additive))
			end
		end
	end
end

function _actorclass:stopanim(flag, blendout)
	c_actor_stopanim(self.id, flag, blendout)
	self:clearanimmesh()
end

function _actorclass:addmixtransform()
	c_actor_addmixtransform(self.id, actorrenderflag.mixrecursive, "bip01 spine1")
end

function _actorclass:setanimmix(flag)
	c_actor_mixanim(self.id, flag)
end

function _actorclass:setanimspeed(speed, additivespeed)
	c_actor_setanimspeed(self.id, speed, additivespeed)
end

function _actorclass:bindactor(actor, bindname, bindskin, bindslotinparent)
	c_actor_bindbp(self.id, actor.id, bindname, bindskin - 1, bindslotinparent - 1, 0, 0, 0)
end

function _actorclass:sethighlight(highlight)
	c_actor_sethighlight(state.id, highlight)
end

function _actorclass:getanimalias(animname)
	if self.actordata.animalias ~= nil then
		return self.actordata.animalias.anim[animname]
	end
end

function _actorclass:getanimlistname(anim)
	if anim == nil or anim.anim == nil then
		debugerror("failed getanimlistname")
		return "nidle_001"
	end
	local flag = nil
	local animname = nil
	local index = nil
	local type = nil
	if self:getbattle() then
		animname = anim.battleanim
		flag = anim.battleflag or 0
		index = anim.battleindex
        type = anim.battletype
    else
		animname = anim.anim
		flag = anim.flag or 0
		index = anim.index
        type = anim.type
    end
	local career = nil
    local weapon = nil
    if bit.band(flag, actoranimpart.career) > 0 then
        career = actoranimcareer[self.attr.career]
    end
    if bit.band(flag, actoranimpart.weapon) > 0 then
        weapon = self:getweaponname()
    end
    return animlist_getanim(animname, flag, career, weapon, type, index or 1)
end

function _actorclass:getweaponname()
	local weaponname = nil
	if self.weaponactor1 ~= nil and self.weaponactor1.weapontype ~= nil then
		local weaponvisible = true
		if self.actionmain.buffdeform ~= nil then
			weaponvisible = self.actionmain.buffdeformweapon
		end
		if weaponvisible then
			if self.weaponactor2 ~= nil
			and self.weaponactor2.weapontype ~= nil
			and self.weaponactor2.weapontype ~= csvitemtype.weapon_shield then
				weaponname = "2weapon"
			else
				weaponname = actoranimweapon[self.weaponactor1.weapontype]
			end
		end
	end
	if weaponname == nil then
		weaponname = "noweapon"
	end
	return weaponname
end

function _actorclass:getskillanimname(type, config_skill)
	if config_skill == nil or config_skill.anim == "0" then
		return
	end
	local skillanim = csvconfig_getsubvalue(config_skill.anim, 1, configsubtype.str)
    local skillanimspeed = csvconfig_getsubvalue(config_skill.anim, 2, configsubtype.flt)
    local speed = 1.0
    if skillanimspeed ~= nil and skillanimspeed ~= 0 then
        speed = 100.0 / skillanimspeed
    end
		
    local flag = bit.bor(actoranimpart.weapon, actoranimpart.type)
	local name = nil
	if self:isplayer() and self.attr.movetype == playermovestate.fly then
		if type == csvskillanimtype.fire then
			name = "xfire"
		else
			name = "xcast"
		end
	else
		if type == csvskillanimtype.fire then
			name = "cfire"
		else
			name = "ccast"
		end
	end
    return animlist_getanim(name, flag, nil, self:getweaponname(), skillanim, 1), speed
end

function _actorclass:clearanimmesh()
	if self.aliasplayer ~= nil then
		aliasmanager_destory(self.aliasplayer)
		self.aliasplayer = nil
	end
end

function _actorclass:updateanim()
	if self.actordata.animaliasrand ~= nil and self.actordata.animaliasrandtime < time_game then
		self:playrandanim()
	end
	if self.aliasplayer ~= nil then
		aliasmanager_update(self.aliasplayer, self, nil)
	end
	if self.aliaseverytime ~= nil then
		aliasmanager_update(self.aliaseverytime, self, nil)
	end
end
