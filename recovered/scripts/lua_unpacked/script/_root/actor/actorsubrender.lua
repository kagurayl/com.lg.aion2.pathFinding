
subrenderhairmode =
{
	hair = 1,
 	helmet = 2,
	skinhelmet = 3,
	hairhelmet = 4,
	hairskinhelmet = 5,
}

local subrenderbindbone =
{
	[csvitemtype.weapon_mace] = {battle = "rhand_bone", idle = "lwaist_bone", weapon2idle = "rback_bone", shieldidle = "lwaist_bone"},
	[csvitemtype.weapon_dagger] = {battle = "rhand_bone", idle = "lwaist_bone", weapon2idle = "rback_bone", shieldidle = "lwaist_bone"},
	[csvitemtype.weapon_sword1] = {battle = "rhand_bone", idle = "lwaist_bone", weapon2idle = "rback_bone", shieldidle = "lwaist_bone"},

	[csvitemtype.weapon_tool2] = {battle = "rhand_bone", idle = "lback_bone"},
	[csvitemtype.weapon_sword2] = {battle = "rhand_bone", idle = "lback_bone"},
	[csvitemtype.weapon_polearm] = {battle = "rhand_bone", idle = "rhip_bone"},
	[csvitemtype.weapon_staff] = {battle = "rhand_bone", idle = "rhip_bone"},
   	[csvitemtype.weapon_bow] = {battle = "lhand_bone", idle = "lback_bone"},
	[csvitemtype.weapon_book] = {battle = "lhand_bone", idle = "lhand_bone"},
	[csvitemtype.weapon_orb] = {battle = "rhand_bone", idle = "rhand_bone"},
}
local subrenderbindbone2 =
{
	[csvitemtype.weapon_mace] = {battle = "lhand_bone", idle = "rwaist_bone", weapon2idle = "lback_bone"},
	[csvitemtype.weapon_dagger] = {battle = "lhand_bone", idle = "rwaist_bone", weapon2idle = "lback_bone"},
	[csvitemtype.weapon_sword1] = {battle = "lhand_bone", idle = "rwaist_bone", weapon2idle = "lback_bone"},
	[csvitemtype.weapon_shield] = {battle = "shield_bone", idle = "back_bone"},
}

function _actorclass:destroysubactor()
	if self.hairactor ~= nil then
		self.hairactor:destroyactor()
		self.hairactor = nil
	end
	if self.helmetactor ~= nil then
		self.helmetactor:destroyactor()
		self.helmetactor = nil
	end
	if self.skinhelmetactor ~= nil then
		self.skinhelmetactor:destroyactor()
		self.skinhelmetactor = nil
	end
	if self.necklaceactor ~= nil then
		self.necklaceactor:destroyactor()
		self.necklaceactor = nil
	end
	if self.earring1actor ~= nil then
		self.earring1actor:destroyactor()
		self.earring1actor = nil
	end
	if self.earring2actor ~= nil then
		self.earring2actor:destroyactor()
		self.earring2actor = nil
	end
	if self.weaponactor1 ~= nil then
		self.weaponactor1:destroyactor()
		self.weaponactor1 = nil
	end
	if self.weaponactor2 ~= nil then
		self.weaponactor2:destroyactor()
		self.weaponactor2 = nil
	end
	if self.wingactor ~= nil then
		self.wingactor:destroyactor()
		self.wingactor = nil
	end
	if self.emblemactor ~= nil then
		self.emblemactor:destroyactor()
		self.emblemactor = nil
	end
	self:unloadpetasset()
end

function _actorclass:updatesubbind()
	local battle = self:getbattle()
	if self.battle.battlestatebindtime ~= nil then
		battle = not battle
	end
	local idlebone = bit.band(self.actorflag, actorrenderflag.noskin) == 0
	if self.weaponactor1 ~= nil then
		local weaponbind = subrenderbindbone[self.weaponactor1.weapontype]
		local bonename = "rhand_bone"
		if battle or not self.actordata.assetskeleton then
			bonename = weaponbind.battle
		elseif self.weaponactor2 ~= nil then
			if self.weaponactor2.weapontype == csvitemtype.weapon_shield then
				bonename = weaponbind.shieldidle
			else
				bonename = weaponbind.weapon2idle
			end
		else
			bonename = weaponbind.idle
		end
		self.weaponactor1:bindactor(self, bonename, -1, -1)
	end
	if self.weaponactor2 ~= nil then
		local bonename = "lhand_bone"
		local weaponbind = subrenderbindbone2[self.weaponactor2.weapontype]
		if battle or not self.actordata.assetskeleton then
			bonename = weaponbind.battle
		elseif self.weaponactor1 ~= nil then
			if weaponbind.weapon2idle ~= nil then
				bonename = weaponbind.weapon2idle
			else
				bonename = weaponbind.idle
			end
		else
			bonename = weaponbind.idle
		end
		self.weaponactor2:bindactor(self, bonename, -1, -1)
	end
end

function _actorclass:createhairactor()
	if self.hairactor ~= nil then
		self.hairactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.hairactor:createactor(bit.bor(actorrenderflag.mergeparent, actorrenderflag.bindinverse), string.format("hair_%d", self.id))	
	end
end

function _actorclass:createhelmetactor()
	if self.helmetactor ~= nil then
		self.helmetactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.helmetactor:createactor(0, string.format("helmet_%d", self.id))	
	end
end

function _actorclass:createskinhelmetactor()
	if self.skinhelmetactor ~= nil then
		self.skinhelmetactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.skinhelmetactor:createactor(bit.bor(actorrenderflag.mergeparent, actorrenderflag.bindinverse), string.format("skinhelmet_%d", self.id))	
	end
end

function _actorclass:createnecklaceactor()
	if self.necklaceactor ~= nil then
		self.necklaceactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.necklaceactor:createactor(0, string.format("necklace_%d", self.id))	
	end
end

function _actorclass:createearring1actor()
	if self.earring1actor ~= nil then
		self.earring1actor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.earring1actor:createactor(0, string.format("earring1_%d", self.id))	
	end
end

function _actorclass:createearring2actor()
	if self.earring2actor ~= nil then
		self.earring2actor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.earring2actor:createactor(0, string.format("earring2_%d", self.id))	
	end
end

function _actorclass:createweaponactor1()
	if self.weaponactor1 ~= nil then
		self.weaponactor1:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.weaponactor1:createactor(0, string.format("weapon1_%d", self.id))	
	end
end

function _actorclass:createweaponactor2()
	if self.weaponactor2 ~= nil then
		self.weaponactor2:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.weaponactor2:createactor(0, string.format("weapon2_%d", self.id))	
	end
end

function _actorclass:createwingactor()
	if self.wingactor ~= nil then
		self.wingactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.wingactor:createactor(0, string.format("wing_%d", self.id))	
	end
end

function _actorclass:createemblemactor()
	if self.emblemactor ~= nil then
		self.emblemactor:settransform(0, 0, 0, 0, 0, 0, 1, 1, 1)
		self.emblemactor:createactor(actorrenderflag.bindinverse, string.format("emblem_%d", self.id))	
	end
end

function _actorclass:createpetactor()
	if self.petactor ~= nil then
		local trans = self.transform
		local py = trans.py
		local pickx, picky, pickz = c_scene_pickscene(maskcollider, trans.px, trans.py + 1, trans.pz, 0, -1, 0, 5, false)
		if pickx ~= nil then
			py = picky
		end
		self.petactor:settransform(trans.px, py, trans.pz, trans.rx, trans.ry, trans.rz, trans.sx, trans.sy, trans.sz)
		self.petactor:createactor(0, string.format("pet_%d", self.id))	
		if self:isme() then
			m_mepetid = self.petactor.id
		end
	end
end

function _actorclass:loadhair(filename)
	if self.hairactor == nil then
		self.hairactor = _actorclass.new()
		self.hairactor.renderlayer = self.renderlayer
		self.hairactor.slotinparent = renderslot.hair
		self:createhairactor()
	end
	self.hairactor:loadbprender(self:getprefabpath(filename))
	self.hairactor:bindactor(self, "bip01 head", renderslot.face, renderslot.hair)
end

function _actorclass:loadhelmet(filename, battlefilename, isvfx)
	if self.helmetactor == nil then
		self.helmetactor = _actorclass.new()
		self.helmetactor.renderlayer = self.renderlayer
		self:createhelmetactor()
	end
	local path = nil
	if isvfx then
		path = string.format("effects/prt/%s.prefab", filename)
	elseif battlefilename ~= nil and self:getbattle() then
		path = self:getprefabpath(battlefilename)
	else
		path = self:getprefabpath(filename)
	end
	if battlefilename ~= nil then
		self.helmetactor.helmetfilename = filename
		self.helmetactor.helmetbattlefilename = battlefilename
	else
		self.helmetactor.helmetfilename = nil
		self.helmetactor.helmetbattlefilename = nil
	end
	self.helmetactor:loadbprender(path)
	self.helmetactor:bindactor(self, "bip01 head", -1, -1)
end

function _actorclass:loadskinhelmet(filename, battlefilename)
	if self.skinhelmetactor == nil then
		self.skinhelmetactor = _actorclass.new()
		self.skinhelmetactor.renderlayer = self.renderlayer
		self.skinhelmetactor.slotinparent = renderslot.hair
		self:createskinhelmetactor()
	end
	local path = nil
	if battlefilename ~= nil and self:getbattle() then
		path = self:getprefabpath(battlefilename)
	else
		path = self:getprefabpath(filename)
	end
	if battlefilename ~= nil then
		self.skinhelmetactor.helmetfilename = filename
		self.skinhelmetactor.helmetbattlefilename = battlefilename
	else
		self.skinhelmetactor.helmetfilename = nil
		self.skinhelmetactor.helmetbattlefilename = nil
	end
	self.skinhelmetactor:loadbprender(path)
	self.skinhelmetactor:bindactor(self, "bip01 head", renderslot.face, renderslot.hair)
end

function _actorclass:sethelmetcolor(skincolor, haircolor, helmetcolor)
	local skin_r, skin_g, skin_b = HexRGB(skincolor)
	local hair_r, hair_g, hair_b = HexRGB(haircolor)
	local helmet_r, helmet_g, helmet_b = HexRGB(helmetcolor)
	if self.helmetactor ~= nil then
		self.helmetactor:setmaterialcolor3x3(1, "_CustomColor", skin_r, skin_g, skin_b, hair_r, hair_g, hair_b, helmet_r, helmet_g, helmet_b)
	end
end

function _actorclass:loadnecklace(filename)
	if filename ~= nil then
		if self.necklaceactor == nil then
			self.necklaceactor = _actorclass.new()
			self.necklaceactor.renderlayer = self.renderlayer
			self:createnecklaceactor()
		end
		local path = string.format("effects/prt/%s.prefab", filename)
		self.necklaceactor:loadbprender(path)
		self.necklaceactor:bindactor(self, "neck_bone", -1, -1)
	else
		if self.necklaceactor ~= nil then
			self.necklaceactor:destroyactor()
			self.necklaceactor = nil
		end
	end
end

function _actorclass:loadearring1(filename)
	if filename ~= nil then
		if self.earring1actor == nil then
			self.earring1actor = _actorclass.new()
			self.earring1actor.renderlayer = self.renderlayer
			self:createearring1actor()
		end
		self.earring1actor:loadbprender(self:getprefabpath(filename))
		self.earring1actor:bindactor(self, "lear_bone", -1, -1)
	else
		if self.earring1actor ~= nil then
			self.earring1actor:destroyactor()
			self.earring1actor = nil
		end
	end
end

function _actorclass:loadearring2(filename)
	if filename ~= nil then
		if self.earring2actor == nil then
			self.earring2actor = _actorclass.new()
			self.earring2actor.renderlayer = self.renderlayer
			self:createearring2actor()
		end
		self.earring2actor:loadbprender(self:getprefabpath(filename))
		self.earring2actor:bindactor(self, "rear_bone", -1, -1)
	else
		if self.earring2actor ~= nil then
			self.earring2actor:destroyactor()
			self.earring2actor = nil
		end
	end
end

function _actorclass:sethairmode(mode)
	self.actordata.updatehairrender = mode
	if mode == nil then
		if self.hairactor ~= nil then
			self.hairactor:destroyactor()
			self.hairactor = nil
		end
		if self.helmetactor ~= nil then
			self.helmetactor:destroyactor()
			self.helmetactor = nil
		end
		if self.skinhelmetactor ~= nil then
			self.skinhelmetactor:destroyactor()
			self.skinhelmetactor = nil
		end
	end
end

function _actorclass:loadweaponmesh(isbattle)
	local pathname = nil
	local fullname = nil
	local shortname = nil
	if isbattle and self.weaponbattlefilename ~= nil then
		pathname, fullname, shortname = csvrender_getitemviewpath(self.weaponbattlefilename)
	else
		pathname, fullname, shortname = csvrender_getitemviewpath(self.weaponfilename)
	end
	self:loadbprender(pathname)
	self:loadanimalias(fullname, shortname)

	local removevfx = true
	local godstone = self.weapongodstone
	if godstone ~= nil and godstone > 0 then
		local config_item = csvitem_getfromid(godstone)
		if config_item ~= nil then
			local lambda = csvitem_getscript(config_item, "godstone")
			if lambda ~= nil then
				local vfx = lambda.variable[4].str
				if vfx ~= nil and vfx ~= "0" then
					if self.actordata.godstonevfx ~= nil and self.actordata.godstonevfx.file ~= vfx then
						self.actordata.godstonevfx:setfade()
						self.actordata.godstonevfx = nil
					end
					if self.actordata.godstonevfx == nil then
						self.actordata.godstonevfx = self:createvfxalways(vfx, "fx_enhance_0", false)
					end
					removevfx = false
				end
			end
		end
	end
	if removevfx and self.actordata.godstonevfx ~= nil then
		self.actordata.godstonevfx:setfade()
		self.actordata.godstonevfx = nil
	end
end

function _actorclass:loadweaponbattlefx(isbattle)
	if isbattle then
		if self.actordata.weaponnormalvfx ~= nil then
			self.actordata.weaponnormalvfx:setfade()
			self.actordata.weaponnormalvfx = nil
		end
		if self.weaponbattlefxfilename ~= nil then
			if self.actordata.weaponbattlevfx ~= nil and self.actordata.weaponbattlevfx.file ~= self.weaponbattlefxfilename then
				self.actordata.weaponbattlevfx:setfade()
				self.actordata.weaponbattlevfx = nil
			end
			if self.actordata.weaponbattlevfx == nil then
				self.actordata.weaponbattlevfx = self:createvfxalways(self.weaponbattlefxfilename, "fx_effect_0", false)
			end
		end
	else
		if self.actordata.weaponbattlevfx ~= nil then
			self.actordata.weaponbattlevfx:setfade()
			self.actordata.weaponbattlevfx = nil
		end
		if self.weaponnormalfxfilename ~= nil then
			if self.actordata.weaponnormalvfx ~= nil and self.actordata.weaponnormalvfx.file ~= self.weaponbattlefxfilename then
				self.actordata.weaponnormalvfx:setfade()
				self.actordata.weaponnormalvfx = nil
			end
			if self.actordata.weaponnormalvfx == nil then
				self.actordata.weaponnormalvfx = self:createvfxalways(self.weaponnormalfxfilename, "fx_effect_0", false)
			end
		end
	end
end

function _actorclass:updatebattleskin(isbattle, part)
	local data = self.actordata.battleskin[part]
	if data == nil then
		return
	end
	if isbattle then
		c_actor_loadskin(self.id, part - 1, self:getprefabpath(data.battle))
	else
		c_actor_loadskin(self.id, part - 1, self:getprefabpath(data.normal))
	end
	if self.actordata.battleskincolor ~= nil then
		local color = self.actordata.battleskincolor
		self:setskincolor(color.skincolor, color.haircolor, color.lipcolor, color.torso, color.pants, color.shoulder, color.glove, color.shoes)
	end
end
function _actorclass:updatebattlemesh(isbattle)
	if self.actordata.battleskin ~= nil then
		self:updatebattleskin(isbattle, renderslot.torso)
		self:updatebattleskin(isbattle, renderslot.pants)
		self:updatebattleskin(isbattle, renderslot.shoulder)
		self:updatebattleskin(isbattle, renderslot.glove)
		self:updatebattleskin(isbattle, renderslot.shoes)
	end
	if self.weaponactor1 ~= nil then
		if self.weaponactor1.weaponbattlefilename ~= nil then
			self.weaponactor1:loadweaponmesh(isbattle)
		end
		self.weaponactor1:loadweaponbattlefx(isbattle)
	end
	if self.weaponactor2 ~= nil then
		if self.weaponactor2.weaponbattlefilename ~= nil then
			self.weaponactor2:loadweaponmesh(isbattle)
		end
		self.weaponactor2:loadweaponbattlefx(isbattle)
	end
	if self.helmetactor ~= nil and self.helmetactor.helmetbattlefilename ~= nil then
		local path = nil
		if isbattle then
			path = self:getprefabpath(self.helmetactor.helmetbattlefilename)
		else
			path = self:getprefabpath(self.helmetactor.helmetfilename)
		end
		self.helmetactor:loadbprender(path)
		self.helmetactor:bindactor(self, "bip01 head", -1, -1)
	end
	if self.skinhelmetactor ~= nil and self.skinhelmetactor.helmetbattlefilename ~= nil then
		local path = nil
		if isbattle then
			path = self:getprefabpath(self.skinhelmetactor.helmetbattlefilename)
		else
			path = self:getprefabpath(self.skinhelmetactor.helmetfilename)
		end
		self.skinhelmetactor:loadbprender(path)
		self.skinhelmetactor:bindactor(self, "bip01 head", renderslot.face, renderslot.hair)
	end
end
function _actorclass:loadweapon1(filename, filenamebattle, fxnormal, fxbattle, weapontype, godstone)
	if filename ~= nil then
		if self.weaponactor1 == nil then
			self.weaponactor1 = _actorclass.new()
			self.weaponactor1.renderlayer = self.renderlayer
			self.weaponactor1.actordata = {}
			self:createweaponactor1()
		end
		local isbattle = self:getbattle()
		self.weaponactor1.weaponfilename = filename
		self.weaponactor1.weaponbattlefilename = filenamebattle
		self.weaponactor1.weaponnormalfxfilename = fxnormal
		self.weaponactor1.weaponbattlefxfilename = fxbattle
		self.weaponactor1.weapontype = weapontype
		self.weaponactor1.weapongodstone = godstone
		self.weaponactor1.actordata.subanimname = nil
		self.weaponactor1.actordata.subanimnameadditive = nil
		self.weaponactor1:loadweaponmesh(isbattle)
		self.weaponactor1:loadweaponbattlefx(isbattle)
		actionmanager_reload(self)
	else
		if self.weaponactor1 ~= nil then
			self.weaponactor1:destroyactor()
			self.weaponactor1 = nil
		end	
	end
end

function _actorclass:loadweapon2(filename, filenamebattle, fxnormal, fxbattle, weapontype, godstone)
	if filename ~= nil then
		if self.weaponactor2 == nil then
			self.weaponactor2 = _actorclass.new()
			self.weaponactor2.renderlayer = self.renderlayer
			self.weaponactor2.actordata = {}
			self:createweaponactor2()
		end
		local isbattle = self:getbattle()
		self.weaponactor2.weaponfilename = filename
		self.weaponactor2.weaponbattlefilename = filenamebattle
		self.weaponactor2.weaponnormalfxfilename = fxnormal
		self.weaponactor2.weaponbattlefxfilename = fxbattle
		self.weaponactor2.weapontype = weapontype
		self.weaponactor2.weapongodstone = godstone
		self.weaponactor2.actordata.subanimname = nil
		self.weaponactor2.actordata.subanimnameadditive = nil
		self.weaponactor2:loadweaponmesh(isbattle)
		self.weaponactor2:loadweaponbattlefx(isbattle)
	else
		if self.weaponactor2 ~= nil then
			self.weaponactor2:destroyactor()
			self.weaponactor2 = nil
		end	
	end
end

function _actorclass:loadwing(filename)
	if filename ~= nil then
		if self.wingactor == nil then
			self.wingactor = _actorclass.new()
			self.wingactor.renderlayer = self.renderlayer
			self.wingactor.actordata = {}
			self:createwingactor()
		end
		self.wingactor.weapontype = weapontype
		self.wingactor.actordata.subanimname = nil
		self.wingactor.actordata.subanimnameadditive = nil
		local pathname, fullname, shortname = csvrender_getwingpath(self.attr.civ,self.attr.sex, filename)
		self.wingactor:loadbprender(pathname)
		self.wingactor:loadanimalias(fullname, shortname)
		self.wingactor:bindactor(self, "wing_bone", -1, -1)
	else
		if self.wingactor ~= nil then
			self.wingactor:destroyactor()
			self.wingactor = nil
		end	
	end
end

function _actorclass:loademblem(meshfile, texturetitle, texturefile)
	if meshfile ~= nil then
		if self.emblemactor == nil then
			self.emblemactor = _actorclass.new()
			self.emblemactor.renderlayer = self.renderlayer
			self:createemblemactor()
		end
		self.emblemactor:loadbprender(meshfile)
		self.emblemactor:bindactor(self, "wing_bone", -1, -1)
		self.emblemactor:setsubmaterialtexture(1, 2, actormaterialflag.loadsync, "_MainTex", texturefile, texturetitle)
	else
		if self.emblemactor ~= nil then
			self.emblemactor:destroyactor()
			self.emblemactor = nil
		end
	end
end

function _actorclass:loadpet(layer, filename)
	if self.petactor == nil then
		self.petactor = _actorclass.new()
		self.petactor.renderlayer = layer
		self.petactor.actordata = {}
		self:createpetactor()
	end
	self.petactor:loadbprender(string.format("objects/%s.cgf.prefab", filename))
	local index = string.reversefind(filename, "/")
	if index ~= nil then
		self.petactor:loadanimalias("objects/" .. filename, string.sub(filename, index + 1))
	else
		self.petactor:loadanimalias(nil, nil)
	end
end

function _actorclass:setsubvisible(subactor, visible)
	if subactor ~= nil then
		subactor:setactorvisible(visible)
	end
end

function _actorclass:setsubopacity(subactor, opacity)
	if subactor ~= nil then
		subactor:setopacity(opacity)
	end
end

function _actorclass:updatesubopacity(opacity)
	self:setsubopacity(self.hairactor, opacity)
	self:setsubopacity(self.helmetactor, opacity)
	self:setsubopacity(self.skinhelmetactor, opacity)
	self:setsubopacity(self.weaponactor1, opacity)
	self:setsubopacity(self.weaponactor2, opacity)
	self:setsubopacity(self.wingactor, opacity)

	self:setsubvisible(self.necklaceactor, opacity >= 1.0)
	self:setsubvisible(self.earring1actor, opacity >= 1.0)
	self:setsubvisible(self.earring2actor, opacity >= 1.0)
end

function _actorclass:updateweaponvisible()
	local weaponvisible = true
	if self.actionmain.buffdeform ~= nil then
		weaponvisible = self.actionmain.buffdeformweapon
	end
	if self.actionmain.spelltype ~= nil then
		if self.actionmain.spelltype == playerspellstate.spellskill
		or self.actionmain.spelltype == playerspellstate.spellcast then
			if self.actionmain.config_skill ~= nil and self.actionmain.config_skill.hideweapon > 0 then
				weaponvisible = false
			end
		end
	end
	self:setsubvisible(self.weaponactor1, weaponvisible)
	self:setsubvisible(self.weaponactor2, weaponvisible)
end

function _actorclass:setsubactoranim(subactor, anim, speed, timestart, additive)
	if subactor ~= nil then
		local playanim = false
		if additive then
			playanim = subactor.actordata.subanimnameadditive ~= anim
		else
			playanim = subactor.actordata.subanimname ~= anim
		end
		if playanim then
			local alias = subactor:playanim(anim, actorrenderflag.resetanim, speed, nil, timestart)	
			if alias ~= nil then
				if additive then
					subactor.actordata.subanimnameadditive = anim
					subactor.actordata.subanimtimeadditive = time_game + alias.length
				else
					subactor.actordata.subanimname = anim
				end
			end
		end
	end
end

function _actorclass:setsubanim(anim, speed, additive, timestart)
	self:setsubactoranim(self.weaponactor1, anim, speed, timestart, additive)
	self:setsubactoranim(self.weaponactor2, anim, speed, timestart, additive)
	self:setsubactoranim(self.wingactor, anim, speed, timestart, additive)
	if self.wingactor ~= nil then
		self.actordata.winganimvisible = false
	end
end

function _actorclass:setsubattackanim(anim, speed)
	if self.weaponactor1 ~= nil then
		if self.weaponactor1.weapontype == csvitemtype.weapon_mace
		or self.weaponactor1.weapontype == csvitemtype.weapon_dagger
		or self.weaponactor1.weapontype == csvitemtype.weapon_sword1
		or self.weaponactor1.weapontype == csvitemtype.weapon_sword2
		or self.weaponactor1.weapontype == csvitemtype.weapon_polearm
		or self.weaponactor1.weapontype == csvitemtype.weapon_staff then
			local civstr = csvrender_getcivstr(self.attr.civ, self.attr.sex)
			local weaponanim = string.format("%s_%s", civstr, anim)
			self:setsubactoranim(self.weaponactor1, weaponanim, speed, 0.0, true)
		end
	end
end

function _actorclass:updatesubactoranim(subactor, battle)
	if subactor ~= nil then
		local playidleanim = false
		if subactor.actordata.subanimnameadditive ~= nil then
			if subactor.actordata.subanimtimeadditive < time_game then
				playidleanim = true
				subactor.actordata.subanimnameadditive = nil
			end
		elseif subactor.actordata.battle ~= battle then
			playidleanim = true
		end
		if playidleanim then
			local animname = subactor.actordata.subanimname
			if animname == nil then
				if self.attr.movetype == playermovestate.fly then
					animname = self:getanimlistname(animlist.subfidle)
				else
					animname = self:getanimlistname(animlist.subnidle)
				end
			end
			subactor:playanim(animname, actorrenderflag.resetanim)
			subactor.actordata.battle = battle
			subactor.actordata.subanimname = nil
		end
	end
end

function _actorclass:updatesubanim()
	if self.actordata.sequencetimestart ~= nil then
		self:setsubvisible(self.wingactor, self.actordata.sequencewingvisible)
		return
	end
	if self.attr.movewindpathid ~= nil then
		self:setsubvisible(self.wingactor, true)
		return
	end
	local wingvisible = true
	if self:isplayer() then
		wingvisible = self.actordata.wingactionvisible or self.actordata.winganimvisible
	end
	self:setsubvisible(self.wingactor, wingvisible)

	local battle = self:getbattle()
	self:updatesubactoranim(self.weaponactor1, battle)
	self:updatesubactoranim(self.weaponactor2, battle)
	self:updatesubactoranim(self.wingactor, battle)
end
