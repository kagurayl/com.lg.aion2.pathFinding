
actorgametype =
{
	player = 0,
    npc = 1,
    staticnpc = 2,
    harvest = 3,
}

function _actorclass:getscale()
	local scale = 1.0
	if self:isplayer() then
		scale = self.attr.bodysize
		if self.actionmain.buffdeform ~= nil then
			local config_deformnpc = csvnpc_getfromid(self.actionmain.buffdeform)
			if config_deformnpc ~= nil then
				scale = scale * config_deformnpc.scale
			end
		end
	elseif self:isdynamicnpc() or self:isstaticnpc() then
		scale = self.config_npc.scale
	end
	return scale
end

function _actorclass:initattr(initbuff)
	self.buff = {}
	if initbuff ~= nil then
		for i=1,#initbuff do
			local addbuff = initbuff[i]
			local config_buff = csvskillbuff_getfromid(addbuff.buffid)
			if config_buff ~= nil then
				local buff = {}
				buff.skillid = addbuff.skillid
				buff.skilllevel = addbuff.skilllevel
				buff.buffid = addbuff.buffid
				buff.buffinstid = addbuff.buffinstid
				buff.config_skill = csvskill_getfromid(buff.skillid)
				buff.config_buff = config_buff
				buff.timestart = 0
				buff.timelength = addbuff.length
				buff.timeout = time_game + addbuff.remain
				buff.vfxcreated = false
				buff.attacker = self.actorid
				playerbuff_initview(buff)
				self.buff[#self.buff + 1] = buff
			end
		end
	end

	self.attrdisplay.hp = math.max(0.0, self.attr.hp)
	self.attrdisplay.hpanim = self.attrdisplay.hp
	self.attrdisplay.hpscroll = self.attrdisplay.hp
	self.attrdisplay.hpmax = self.attr.hpmax
	if self:isplayer() then
		self.attrdisplay.mp = math.max(0.0, self.attr.mp)
		self.attrdisplay.dp = math.max(0.0, self.attr.dp)
		self.attrdisplay.mpanim = self.attrdisplay.mp
		self.attrdisplay.dpanim = self.attrdisplay.dp
		self.attrdisplay.mpscroll = self.attrdisplay.mp
		self.attrdisplay.dpscroll = self.attrdisplay.dp
		self.attrdisplay.mpmax = self.attr.mpmax
		self.attrdisplay.dpmax = self.attr.dpmax
	end
	self.actordata.assetvisible = self:getactorvisible()
	self:setreloadasset(true)
	self:updatestaticmesh()
	self:updateicon()
	local scale = self:getscale()
	self:settransform(self.attr.posx, self.attr.posy, self.attr.posz, 0.0, self.attr.rot, 0.0, scale, scale, scale)
	self:updatebuffopacity()
	if not scene_isloading() then
		self:createplayeractor()
		self:updateasset()
	end
	self:updatebuff()
end

function _actorclass:setpoint(type, val)
	local diff = 0.0	
	val = math.max(0.0, val)
	if pointtype_ishp(type) then
		diff = self.attr.hp - val
		self.attr.hp = val
	elseif pointtype_ismp(type) then
		diff = self.attr.mp - val
		self.attr.mp = val
	elseif pointtype_isdp(type) then
		diff = self.attr.dp - val
		self.attr.dp = val
	elseif pointtype_isfp(type) then
		diff = self.attr.fp - val
		self.attr.fp = val
	end
	return diff
end

function _actorclass:setcostpoint(hp, mp, dp)
	if self:isme() then
		if hp ~= self.attr.hp then
			self.attr.hp = hp
		end
		if mp ~= self.attr.mp then
			self.attr.mp = mp
		end
		if dp ~= self.attr.dp then
			self.attr.dp = dp
		end
	else
		self.attr.hp = hp
		if self:isplayer() then
			self.attr.mp = mp
		end
	end
end

local function actorclass_getdecanim(animval, prev, current)
	if animval == nil then
		if prev <= current then
			return current
		end
		animval = {}
		animval.starttime = time_game
		animval.startval = prev
		animval.endval = current
	end

	local pausetime = 0.5
	local animtime = 1.0
	local time = time_game - animval.starttime
	if time < pausetime then
		if current < animval.endval then
			animval.starttime = time_game
			animval.endval = current
		end
		if current < animval.startval then
			return animval.startval, animval
		else
			return current
		end
	end

	if current < animval.endval then
		time = (time - pausetime) / animtime
		if time < 1.0 then
			animval.startval = math.lerp(animval.startval, animval.endval, time)
		else
			animval.startval = animval.endval
		end
		animval.starttime = time_game - pausetime
		animval.endval = current
		time = time_game - animval.starttime
	end

	time = (time - pausetime) / animtime
	if time < 1.0 then
		local val = math.lerp(animval.startval, animval.endval, time)
		if val > current then
			return val, animval
		end
	end
	return current
end
local function actorclass_getscroll(animval, prev, current)
	if animval == nil then
		if prev == current then
			return current
		end
		animval = {}
		animval.starttime = time_game
		animval.startval = prev
		animval.endval = current
	end
	local animtime = 0.5
	local val = current
	local time = (time_game - animval.starttime) / animtime
	if time < 1.0 then
		val = math.lerp(animval.startval, animval.endval, time)
	end

	if current ~= animval.endval then
		animval.starttime = time_game
		animval.startval = val
		animval.endval = current
		time = 0.0
	end

	if time < 1.0 then
		return val, animval
	else
		return val
	end
end
function _actorclass:updateattr()
	if self:isharvest() then
		return
	end
	local hp = self.attr.hp
	local mp = self.attr.mp
	local dp = self.attr.dp
	for i=1,#self.battleprehitpoint do
		local prehit = self.battleprehitpoint[i]
		if pointtype_ishp(prehit.action) then
			hp = hp + prehit.valdelay
		elseif pointtype_ismp(prehit.action) then
			mp = mp + prehit.valdelay
		elseif pointtype_isdp(prehit.action) then
			dp = dp + prehit.valdelay
		end
	end
	local hpanim, hpanimval = actorclass_getdecanim(self.attrdisplay.hpanimval, self.attrdisplay.hp, hp)
	local hpscroll, hpscrollval = actorclass_getscroll(self.attrdisplay.hpscrollval, self.attrdisplay.hp, hp)
	self.attrdisplay.hpanim = math.max(0.0, hpanim)
	self.attrdisplay.hpanimval = hpanimval
	self.attrdisplay.hpscroll = math.max(0.0, hpscroll)
	self.attrdisplay.hpscrollval = hpscrollval
	self.attrdisplay.hp = math.max(0.0, hp)
	self.attrdisplay.hpmax = self.attr.hpmax

	if self:isplayer() then
		local mpanim, mpanimval = actorclass_getdecanim(self.attrdisplay.mpanimval, self.attrdisplay.mp, mp)
		local mpscroll, mpscrollval = actorclass_getscroll(self.attrdisplay.mpscrollval, self.attrdisplay.mp, mp)
		self.attrdisplay.mpanim = math.max(0.0, mpanim)
		self.attrdisplay.mpanimval = mpanimval
		self.attrdisplay.mpscroll = math.max(0.0, mpscroll)
		self.attrdisplay.mpscrollval = mpscrollval
		self.attrdisplay.mp = math.max(0.0, mp)
		self.attrdisplay.mpmax = self.attr.mpmax

		local dpanim, dpanimval = actorclass_getdecanim(self.attrdisplay.dpanimval, self.attrdisplay.dp, dp)
		local dpscroll, dpscrollval = actorclass_getscroll(self.attrdisplay.dpscrollval, self.attrdisplay.dp, dp)
		self.attrdisplay.dpanim = math.max(0.0, dpanim)
		self.attrdisplay.dpanimval = dpanimval
		self.attrdisplay.dpscroll = math.max(0.0, dpscroll)
		self.attrdisplay.dpscrollval = dpscrollval
		self.attrdisplay.dp = math.max(0.0, dp)
		self.attrdisplay.dpmax = self.attr.dpmax
	end
	self:updatenamewidget()
	self:updatechatwidget()
	self:updatestaticmesh()
end

function _actorclass:updatestaticmesh()
	if self:isstaticnpc() and csvnpc_getscript(self.config_npc, "abyssdoor") then
		local hp = self.attr.hp / self.attr.hpmax
		local staticmesh = 1
		if hp > 0.66 then
			staticmesh = 1
		elseif hp > 0.33 then
			staticmesh = 2
		else
			staticmesh = 3
		end
		if self.actorstaticmesh ~= staticmesh then
			self.actorstaticmesh = staticmesh
			entitymanager_setactorvisible(self.config_npcstatic.staticid, self.actorstaticmesh)
		end
	end
end

function _actorclass:updateharvesticon()
	local tracelevel = minimap_gettraceharvest()
	local traceskill = 0
	if tracelevel > 10000 then
		traceskill = skill_gather_od
		tracelevel = tracelevel - 10000
	else
		traceskill = skill_gather_land
	end
	self.actordata.labelimage = nil
	self.actordata.labellayer = nil
	self.actordata.labelsize = nil
	self.actordata.labelcolor_r = nil
	self.actordata.labelcolor_g = nil
	self.actordata.labelcolor_b = nil
	if self.config_npc.skillid == traceskill and self.config_npc.skilllevel <= tracelevel then
		local skill = playerskill_getcraftingskill(traceskill)
		if skill ~= nil then
			if skill.level >= self.config_npc.skilllevel then
				self.actordata.labelimage = csvlabelimage.npc_harvestenable
			else
				self.actordata.labelimage = csvlabelimage.npc_harvestdisable
			end
			self.actordata.labellayer = minimapiconlayer.npcnormal
		end
	end
end

function _actorclass:updateicon()
	self.actordata.labelimage = nil
	self.actordata.labellayer = nil
	self.actordata.labelsize = nil
	self.actordata.labelcolor_r = nil
	self.actordata.labelcolor_g = nil
	self.actordata.labelcolor_b = nil
	if self:isnpc() then
		if self:isharvest() then
			return
		end
		if self.config_npc.hidenpc > 0 then
			return
		end
		local questicon = playerattr_questnpcicon[self.config_npc.id]
		if questicon ~= nil then
			self.actordata.labelimage = questicon
			self.actordata.labellayer = minimapiconlayer.npcquest
            return
        end
		local csvnpclabelimage = csvnpc_getlabelimage(self.config_npc)
		if csvnpclabelimage ~= nil then
            self.actordata.labelimage = csvnpclabelimage
			self.actordata.labellayer = minimapiconlayer.npclabel
            return
        end
		if csvnpctribe_isaggressive(self.config_npc) then
			self.actordata.labelimage = csvlabelimage.map_actoricon
			self.actordata.labellayer = minimapiconlayer.npcenemy
			self.actordata.labelsize = 12
			self.actordata.labelcolor_r = 1.0
			self.actordata.labelcolor_g = 0.0
			self.actordata.labelcolor_b = 0.0
		else
			self.actordata.labelimage = csvlabelimage.map_actoricon
			self.actordata.labelsize = 12
			if csvnpctribe_isfriendly(self.config_npc) then
				self.actordata.labellayer = minimapiconlayer.npcfriend
				self.actordata.labelcolor_r = 0.0
				self.actordata.labelcolor_g = 1.0
				self.actordata.labelcolor_b = 0.0
			else
				self.actordata.labellayer = minimapiconlayer.npcnormal
				self.actordata.labelcolor_r = 1.0
				self.actordata.labelcolor_g = 1.0
				self.actordata.labelcolor_b = 1.0
			end
		end
	elseif self:isplayer() then
		if self.actorid ~= m_me.actorid and self:isenemy() then
			self.actordata.labelimage = csvlabelimage.map_actoricon
			self.actordata.labellayer = minimapiconlayer.playerenemy
			self.actordata.labelsize = 16
			self.actordata.labelcolor_r = 1.0
			self.actordata.labelcolor_g = 0.0
			self.actordata.labelcolor_b = 0.0
        end
	end
end

function _actorclass:loadboundbox()
	if self:isplayer() then
		local config_skeleton = c_config_getmetaid(configid.render_skeleton, csvrender_getskeletonid(self.attr.civ, self.attr.sex))
		if config_skeleton ~= nil then
			if self:isme() then
				c_actor_setcct(m_me.id, maskcctexclude, 45, 0.3, 0.2, config_skeleton.pickwidth / 2, 1.5)
			else
				local scale = self:getscale()
				local width = config_skeleton.pickwidth * scale
				local height = config_skeleton.pickheight * scale
				if self:isdead() then
					local size = math.max(width, height)
					self:setboundbox(0, 0.1, 0, size, 0.1, size)
				else
					self:setboundbox(0, height / 2.0, 0, width, height, width)
				end
			end
			self.actordata.nameheight = config_skeleton.nameheight
			self.actordata.cameraheight = config_skeleton.cameraheight
			if self.actionmain.buffdeform ~= nil then
				local config_deformnpc = csvnpc_getfromid(self.actionmain.buffdeform)
				if config_deformnpc ~= nil then
					local cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(config_deformnpc.bound, self.attr.bodysize * config_deformnpc.scale)
					self.actordata.nameheight = nameheight
				end
			end
		end
	elseif self:isdynamicnpc() then
		if self.config_npc.hidenpc == 0 then
			local cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(self.config_npc.bound, self.config_npc.scale)
			self.actordata.nameheight = nameheight
			if self.actionmain.buffdeform ~= nil then
				local config_deformnpc = csvnpc_getfromid(self.actionmain.buffdeform)
				if config_deformnpc ~= nil then
					cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(config_deformnpc.bound, self.config_npc.scale)
					self.actordata.nameheight = nameheight
				end
			end
			if self.actorid ~= playerattr_info.spiritid then
				if sx > 0 or sy > 0 or sz > 0 then
					if self:isdead() then
						cy = cy - self.config_npc.altitude
						local size = math.max(sy, math.max(sx, sz))
						self:setboundbox(0, 0.5, 0, size, 1.0, size)
					else
						self:setboundbox(cx, cy, cz, sx, sy, sz)
					end
				end
			end
		end
	elseif self:isstaticnpc() then
		local cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(self.config_npcstatic.bound, 1.0)
		self:setboundboxsize(cx, cy, cz, sx, sy, sz)
		self.actordata.nameheight = nameheight
	elseif self:isharvest() then
		local cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(self.config_npc.bound, 1.0)
		self.actordata.nameheight = nameheight
		if sx > 0 or sy > 0 or sz > 0 then
			self:setboundbox(cx, cy, cz, sx, sy, sz)
		end
	end
	self:updateallplateposition()
end

function _actorclass:loadequiprender(render, civ, sex)
	local skinrender = bit.band(self.actorflag, actorrenderflag.noskin) == 0
	local hair = nil
	local helmet = nil
	local necklace = nil
	local earring1 = nil
	local earring2 = nil
	local isbattle = self:getbattle()
	for key, val in pairs(render) do
		if csvrender_partisskin(key) then
			if skinrender then
				if key == renderslot.torso then
					self:loadskin(key, isbattle, val, render[renderslot.torsobattle])
				elseif key == renderslot.pants then
					self:loadskin(key, isbattle, val, render[renderslot.pantsbattle])
				elseif key == renderslot.shoulder then
					self:loadskin(key, isbattle, val, render[renderslot.shoulderbattle])
				elseif key == renderslot.glove then
					self:loadskin(key, isbattle, val, render[renderslot.glovebattle])
				elseif key == renderslot.shoes then
					self:loadskin(key, isbattle, val, render[renderslot.shoesbattle])
				else
					self:loadskin(key, isbattle, val, nil)
				end
				self:checkadditive(self:getprefabpathwithoutcgfname(val))
			end
		elseif key == renderslot.hair then
			hair = val
		elseif key == renderslot.helmet then
			if self:isme() then
				if gamesetting_getnumber("RENDERHELMET") > 0 then
					helmet = val
				end
			elseif self:isplayer() then
				if self.attr.renderhelmet > 0 then
					helmet = val
				end
			else
				helmet = val
			end
		elseif key == renderslot.necklace then
			necklace = val			
		elseif key == renderslot.earring1 then
			earring1 = val
		elseif key == renderslot.earring2 then
			earring2 = val
		end
	end
	if skinrender then
		for i=renderslot.torso, renderslot.face do
			if render[i] == nil then
				self:loadskin(i, false, nil, nil)
			end
		end
	end
	local hairmode = nil
	if helmet ~= nil then
		hairmode = subrenderhairmode.helmet
		local isvfx = false
		local config_helmet = c_config_getmetacol(configid.equip_helmet, "mesh", helmet)
		if config_helmet ~= nil then
			local type = 0
			if sex == playersex.male then
				if civ == playerciv.light then
					type = config_helmet.lm
				else
					type = config_helmet.dm
				end
			else
				if civ == playerciv.light then
					type = config_helmet.lf
				else
					type = config_helmet.df
				end
			end
			if type == 1 then
				hairmode = subrenderhairmode.skinhelmet
			elseif type == 2 then
				hairmode = subrenderhairmode.hairhelmet
			elseif type == 3 then
				hairmode = subrenderhairmode.hairskinhelmet
			elseif type == 4 then
				hairmode = subrenderhairmode.hairhelmet
				isvfx = true
			end
		end
		if hairmode == subrenderhairmode.skinhelmet or hairmode == subrenderhairmode.hairskinhelmet then
			self:loadskinhelmet(helmet, render[renderslot.helmetbattle])
		else
			self:loadhelmet(helmet, render[renderslot.helmetbattle], isvfx)
		end
	elseif hair ~= nil then
		hairmode = subrenderhairmode.hair
	end
	if hair ~= nil and hairmode ~= subrenderhairmode.helmet and hairmode ~= subrenderhairmode.skinhelmet then
		self:loadhair(hair)
	end
	self:loadnecklace(necklace)
	self:loadearring1(earring1)
	self:loadearring2(earring2)
	self:sethairmode(hairmode)
	self:loadweapon1(render[renderslot.weapon1], render[renderslot.weaponbattle1], render[renderslot.weaponnormalfx1], render[renderslot.weaponbattlefx1], render[renderslot.weapontype1], self.attr.godstonemain)
	self:loadweapon2(render[renderslot.weapon2], render[renderslot.weaponbattle2], render[renderslot.weaponnormalfx2], render[renderslot.weaponbattlefx2], render[renderslot.weapontype2], self.attr.godstonesub)
	self:loadwing(render[renderslot.wing])
	self:updatesubbind()
end

function _actorclass:loademblemrender(civ, sex, logo)
	local meshfilename = nil
	local logofiletitle = nil
	local logofilename = nil
	if civ == playerciv.light then
        if sex == playersex.male then
            meshfilename = "objects/pc/lm/mesh/lm001_emblem.cgf.prefab"
        else
            meshfilename = "objects/pc/lf/mesh/lf001_emblem.cgf.prefab"
        end
		logofiletitle = string.format("predef_l_%d", logo)
		logofilename = string.format("textures/icclogo/predef_l_%d.png", logo)
    else
        if sex == playersex.male then
            meshfilename = "objects/pc/dm/mesh/dm001_emblem.cgf.prefab"
        else
            meshfilename = "objects/pc/df/mesh/df001_emblem.cgf.prefab"
        end
		logofiletitle = string.format("predef_d_%d", logo)
		logofilename = string.format("textures/icclogo/predef_d_%d.png", logo)
    end
	self:loademblem(meshfilename, logofiletitle, logofilename)
end

function _actorclass:clearemblemrender()
	self:loademblem(nil, nil, nil)
end

function _actorclass:loadmeshsubrender()
	local render = csvrender_getdefaultrender()
	local color = {}
	csvrender_getequipview(self.attr.sex, render, color, self.attr.equipview, self.attr.equipdye, true)
	self:loadweapon1(render[renderslot.weapon1], nil, nil, nil, render[renderslot.weapontype1], 0)
	self:loadweapon2(render[renderslot.weapon2], nil, nil, nil, render[renderslot.weapontype2], 0)
	self:loadwing(render[renderslot.wing])
	self:updatesubbind()
end

function _actorclass:loadnpcasset(config_npc, meshsubrender)
	local mesh = nil
	local equip = nil
	local appear = nil
	local preset = nil
	if config_npc.uitype == csvnpcuitype.none or config_npc.uitype == csvnpcuitype.hidden_monster then
		return
	end
	local configmesh = config_npc.mesh
	if configmesh == "0" then
		return
	end
	local render = string.split(configmesh, ";")
	for i=1, #render do
		local subrender = string.split(render[i], ":")
		if subrender[1] == "mesh" then
			mesh = subrender[2]
		elseif subrender[1] == "equip" then
			equip = string.splitnumber(subrender[2], ",")
		elseif subrender[1] == "appear" then
			appear = string.split(subrender[2], ",")
		elseif subrender[1] == "preset" then
			preset = subrender[2]
		end
	end
	if mesh ~= nil then
		if string.startwith(mesh, "monster/pc_polymorph") then
			if self.attr.sex == playersex.male then
				mesh = mesh .. "m"
			else
				mesh = mesh .. "f"
			end
		end
		self:setflag(actorrenderflag.noskin, 0)
		self:loadbprender(string.format("objects/%s.cgf.prefab", mesh))
		self:checkadditive(string.format("objects/%s", mesh))
		if meshsubrender then
			self.actordata.assetskeleton = true
			self:loadskeletonanimalias(csvrender_getskeletonid(self.attr.civ, self.attr.sex))
		else
			local index = string.reversefind(mesh, "/")
			if index ~= nil then
				self:loadanimalias("objects/" .. mesh, string.sub(mesh, index + 1))
			else
				self:loadanimalias(nil, nil)
			end
		end
		if equip ~= nil then
			local equiprender = {}
			csvrender_getequipview(playersex.male, equiprender, nil, equip, nil, false)
			if self:getfly() then
				equiprender[renderslot.wing] = RenderDefault_Wing
			end
			self:loadequiprender(equiprender, self.attr.civ, self.attr.sex)
		else
			if meshsubrender then
				self:sethairmode(nil)
				self:loadmeshsubrender()
			else
				self:destroysubactor()
			end
		end
	elseif appear ~= nil then
		self:setflag(0, actorrenderflag.noskin)
		self:loadskeleton(string.tointeger(appear[1]))
		if self:isplayer() then
			self:addmixtransform()
		end
		if equip ~= nil then
			local equiprender = csvrender_getdefaultrender()
			csvrender_getequipview(playersex.male, equiprender, nil, equip, nil, false)
			if self:getfly() then
				equiprender[renderslot.wing] = RenderDefault_Wing
			end
			self:loadequiprender(equiprender, string.tointeger(appear[5]), string.tointeger(appear[6]))
		elseif meshsubrender then
			self:loadmeshsubrender()
		else
			self:destroysubactor()
		end
	end
	if equip ~= nil then
		self:loadequipaudiomat(equip, nil, config_npc.matdamage, config_npc.matfoot)
	else
		self.attr.matdamage = config_npc.matdamage
	end
end

function _actorclass:loadequipaudiomat(equipview, weapondefault, damagedefault, footdefault)
	local config_weapon = csvitem_getfromid(equipview[equipslot.weapon1])
	if config_weapon ~= nil then
		self.attr.matweapon = config_weapon.mataudio
	else
		self.attr.matweapon = weapondefault
	end
	self.attr.config_weapon = config_weapon
	self.attr.config_weapon2 = csvitem_getfromid(equipview[equipslot.weapon2])

	local config_torso = csvitem_getfromid(equipview[equipslot.torso])
	if config_torso ~= nil then
		self.attr.matdamage = config_torso.mataudio
	else
		self.attr.matdamage = damagedefault
	end
	local config_shoes = csvitem_getfromid(equipview[equipslot.shoes])
	if config_shoes ~= nil then
		self.attr.matfoot = config_shoes.mataudio
	else
		self.attr.matfoot = footdefault
	end
end

function _actorclass:setpreview(config_item, dyeid)
	if config_item.sex ~= 0 and config_item.sex ~= self.attr.sex then
        chat_addsystemalert("STR_MSG_PREVIEW_INVALID_GENDER")
		return false
    end
	if not minichat_showpreview then
		minichat_showpreview = true
		home_main_updatepreview()
	end
	local slot = csvitem_getequipslot(config_item)
	if slot == nil then
		return false
	end
	if self.preview == nil then
		self.preview = {}
	end
	for i=1,#self.preview do
		local previewslot = csvitem_getequipslot(self.preview[i].config_item)
		if previewslot == slot then
			table.remove(self.preview, i)
			break
		end
	end
	local data = {}
	data.config_item = config_item
	data.dye = nil
	if dyeid ~= nil then
		local config_dye = csvitem_getfromid(dyeid)
		if config_dye ~= nil then
			data.dye = csvitem_getdyecolorfromconfig(config_dye)
		end
	end
	self.preview[#self.preview + 1] = data
	self:setreloadasset(false)
	return true
end

function _actorclass:clearpreview()
	self.preview = nil
	self:setreloadasset(false)
end

function _actorclass:applypreview()
	if self.preview == nil then
		return self.attr.equipview, self.attr.equipdye
	end
	local equipview = table.clonearray(self.attr.equipview)
	local equipdye = table.clonearray(self.attr.equipdye)
	for i=1,#self.preview do
		local config_item = self.preview[i].config_item
		local slot = csvitem_getequipslot(config_item)
		equipview[slot] = config_item.id
		equipdye[slot] = self.preview[i].dye
	end
	return equipview, equipdye
end

function _actorclass:loadasset()
	self.actordata.assetloaded = true
	self.actordata.assetskeleton = false
	self.actordata.opacity = nil
	if scene_isloading() then
		debugerror("loadasset on scene loading")
	end
	if self:isdynamicnpc() and self.config_npc.hidenpc > 0 then
		return
	end
	self:preadditive()
	self.actordata.battleskin = nil
	self.actordata.battleskincolor = nil
	if self.actionmain.buffdeform ~= nil then
		if self:isplayer() then
			self:clearemblemrender()
		end
		local config_deformnpc = csvnpc_getfromid(self.actionmain.buffdeform)
		if config_deformnpc ~= nil then
			self:loadnpcasset(config_deformnpc, self.actionmain.buffdeformweapon)
			local scale = self:getscale()
			self:setscale(scale, scale, scale)
		end
	elseif self:isplayer() then
		self:setflag(0, actorrenderflag.noskin)
		self:loadskeleton(csvrender_getskeletonid(self.attr.civ, self.attr.sex))
		local scale = self:getscale()
		self:setscale(scale, scale, scale)
		local render = csvrender_getdefaultrender()
		local color = {}
		local equipview, equipdye = self:applypreview()
		csvrender_getequipview(self.attr.sex, render, color, equipview, equipdye, true)
		render[renderslot.hair] = csvrender_gethairrender(self.attr.civ, self.attr.sex, self.attr.hair)
		self:loadequiprender(render, self.attr.civ, self.attr.sex)
		local renderemblem = false
		if self:isme() then
			renderemblem = playerattr_icc ~= nil and gamesetting_getnumber("RENDEREMBLEM") > 0
		elseif self:isplayer() then
			renderemblem = self.attr.renderemblem > 0 and self.attr.iccname ~= nil and string.len(self.attr.iccname) > 0
		end
		if renderemblem then
			self:loademblemrender(self.attr.civ, self.attr.sex, self.attr.icclogo)
		else
			self:clearemblemrender()
		end
		local face = morph_getround(self.attr.face, self.attr.civ, self.attr.sex, MorphLimitFace)
		local feat1 = morph_getround(self.attr.feat1, self.attr.civ, self.attr.sex, MorphLimitFeat1)
		local feat2 = morph_getround(self.attr.feat2, self.attr.civ, self.attr.sex, MorphLimitFeat2)
		local bump = morph_getround(self.attr.bump, self.attr.civ, self.attr.sex, MorphLimitBump)
		local expression = morph_getround(self.attr.expression, self.attr.civ, self.attr.sex, MorphLimitExpression)
		if face > 1 then
			self:loadface(face)
		end
		if feat1 > 0 then
			self:loadfeat1(feat1)
		end
		if feat2 > 0 then
			self:loadfeat2(feat2)
		end
		if bump > 0 then
			self:loadbump(bump)
		end
		if expression > 0 then
			self:setfacemorphexpression(expression)
		end
		self:setskincolor(self.attr.skincolor, self.attr.haircolor, self.attr.lipcolor, color[renderslot.torso]
				, color[renderslot.pants], color[renderslot.shoulder], color[renderslot.glove], color[renderslot.shoes])
		if self.actordata.battleskin ~= nil then
			self.actordata.battleskincolor = {}
			self.actordata.battleskincolor.skincolor = self.attr.skincolor
			self.actordata.battleskincolor.haircolor = self.attr.haircolor
			self.actordata.battleskincolor.lipcolor = self.attr.lipcolor
			self.actordata.battleskincolor.torso = color[renderslot.torso]
			self.actordata.battleskincolor.pants = color[renderslot.pants]
			self.actordata.battleskincolor.shoulder = color[renderslot.shoulder]
			self.actordata.battleskincolor.glove = color[renderslot.glove]
			self.actordata.battleskincolor.shoes = color[renderslot.shoes]
		end
		if color[renderslot.helmet] ~= nil then
			self:sethelmetcolor(self.attr.skincolor, self.attr.haircolor, color[renderslot.helmet])
		end
		local eye_r, eye_g, eye_b = HexRGB(self.attr.eyecolor)
		self:seteyecolor(eye_r, eye_g, eye_b)
		for i=1, #self.attr.facemorph do
			self:setfacemorphindex(i, self.attr.facemorph[i])
		end
		self:setbodymorph(self.attr.bodymorph, self.attr.faceshape)
		self:applyfacemorph()
		self:loadequipaudiomat(self.attr.equipview, nil, nil, nil)
		self:loadpetasset()
		self:addmixtransform()
	elseif self:isdynamicnpc() then
		self:loadnpcasset(self.config_npc, false)
		self:loaddropvfx()
		self:updatequestvfx()
	elseif self:isharvest() then
		local filename = string.format("objects/gathersource/%s/%s.cgf.prefab", self.config_npc.category, self.config_npc.mesh)
		self:loadbprender(filename)
		-- if self.actordata.vfxmesh == nil and self.config_npc.meshfx ~= "0" then
		-- 	self.actordata.vfxmesh = self:createvfx(self.config_npc.meshfx, vfx_bind_ground, false)
		-- end
	end
	self:applyadditive()
	if not self:isharvest() then
		self:updatenameuilayout()
		actionmanager_reload(self)
	end
end

function _actorclass:setreloadasset(fadeable)
	self.actordata.assetloaded = false
	self.actordata.fadeable = fadeable and not self:isme()
end

function _actorclass:updateasset()
	if self.id == nil or scene_isloading() then
		return
	end
	local assetloadrange = 80.0
	if self.actordata.assetvisible and not self.actordata.assetloaded then
		local load = true
		if m_me ~= nil then
			local st = self.transform
			local mt = m_me.transform
			if vector3_distance_sq(st.px, st.py, st.pz, mt.px, mt.py, mt.pz) > assetloadrange * assetloadrange then
				load = false
			end
		end
		if load then
			if not self:isme() and self.actordata.fadeable then
				self.actordata.fadestart = time_game
			else
				self.actordata.fadestart = nil
			end
			self:loadasset()
		end
	end
	if self.actordata.updatehairrender ~= nil and not self:loading() then
		local loading = false
		if self.actordata.updatehairrender == subrenderhairmode.hair
		or self.actordata.updatehairrender == subrenderhairmode.hairhelmet
		or self.actordata.updatehairrender == subrenderhairmode.hairskinhelmet then
			loading = self.hairactor ~= nil and self.hairactor:loading()
		end
		if not loading then
			if self.actordata.updatehairrender == subrenderhairmode.helmet
			or self.actordata.updatehairrender == subrenderhairmode.hairhelmet then
				loading = self.helmetactor ~= nil and self.helmetactor:loading()
			end
			if not loading then
				if self.actordata.updatehairrender == subrenderhairmode.skinhelmet
				or self.actordata.updatehairrender == subrenderhairmode.hairskinhelmet then
					loading = self.skinhelmetactor ~= nil and self.skinhelmetactor:loading()
				end
			end
		end
		if not loading then
			local removehair = self.actordata.updatehairrender == subrenderhairmode.helmet
							or self.actordata.updatehairrender == subrenderhairmode.skinhelmet
			local removehelmet = self.actordata.updatehairrender == subrenderhairmode.hair
							or self.actordata.updatehairrender == subrenderhairmode.skinhelmet
							or self.actordata.updatehairrender == subrenderhairmode.hairskinhelmet
			local removeskinhelmet = self.actordata.updatehairrender == subrenderhairmode.hair
							or self.actordata.updatehairrender == subrenderhairmode.helmet
							or self.actordata.updatehairrender == subrenderhairmode.hairhelmet
			if removehair then
				if self.hairactor ~= nil then
					self.hairactor:destroyactor()
					self.hairactor = nil
				end
			end
			if removehelmet then
				if self.helmetactor ~= nil then
					self.helmetactor:destroyactor()
					self.helmetactor = nil
				end
			end
			if removeskinhelmet then
				if self.skinhelmetactor ~= nil then
					self.skinhelmetactor:destroyactor()
					self.skinhelmetactor = nil
				end
			end
			self.actordata.updatehairrender = nil
		end
	end
	local targetopacity = nil
	if self.timeselectable ~= nil then
		targetopacity = self.timeselectable - time_game
		if targetopacity > 0.0 then
			targetopacity = (targetopacity - math.floor(targetopacity))
			if targetopacity > 0.5 then
				targetopacity = 0.99
			else
				targetopacity = 0.5
			end
		else
			self.timeselectable = nil
			targetopacity = 0.99
		end
		if self.actionmain.buffopacity ~= nil then
			targetopacity = targetopacity * self.actionmain.buffopacity
		end
	elseif self.actordata.fadestart ~= nil then
		targetopacity = math.max(0.01, time_game - self.actordata.fadestart)
		local opacitymax = 1.0
		if self.actionmain.buffopacity ~= nil then
			opacitymax = self.actionmain.buffopacity
		end
		if targetopacity > opacitymax then
			targetopacity = opacitymax
			self.actordata.fadestart = nil
		end
	elseif self.actionmain.buffopacity ~= nil then
		targetopacity = self.actionmain.buffopacity
	end
	if targetopacity ~= nil then
		local opacitycurrent = targetopacity
		if self.actordata.opacity ~= nil then
			opacitycurrent = self.actordata.opacity
		end
		local opacitydelta = time_frame
		local opacity = opacitycurrent
		if targetopacity > opacitycurrent then
			opacity = math.min(opacitycurrent + opacitydelta, targetopacity)
		elseif targetopacity < opacitycurrent then
			opacity = math.max(opacitycurrent - opacitydelta, targetopacity)
		end
		if self.actordata.assetloaded then
			if self.actordata.opacity ~= nil then
				if self.actordata.opacity ~= opacity then
					if opacity < 1.0 then
						self.actordata.opacity = opacity
					else
						self.actordata.opacity = nil
					end
					self:updateopacity(opacity)
				end
			elseif opacity < 1.0 then
				self.actordata.opacity = opacity
				self:updateopacity(self.actordata.opacity)
			end
		end
	else
		if self.actordata.opacity ~= nil and self.actordata.assetloaded then
			self.actordata.opacity = nil
			self:updateopacity(1.0)
		end
		if self.namewidget == nil then
			self:createnameplate()
		end
	end
end

function _actorclass:getactorvisible()
	local visible = true
	if not self:isme() and not self:isstaticnpc() and not self:isharvest() then
		if self:isteam() or self:israid() then
			visible = gamesetting_getnumber("TEAMACTOR") > 0
		elseif self:isenemy() then
			if self:isplayer() then
				visible = gamesetting_getnumber("ENEMYPLAYERACTOR") > 0
			else
				visible = gamesetting_getnumber("ENEMYNPCACTOR") > 0
			end
		else
			if self:isplayer() then
				visible = gamesetting_getnumber("SIPIDPLAYERACTOR") > 0
			else
				visible = gamesetting_getnumber("SIPIDNPCACTOR") > 0
			end
		end
	end
	return visible
end

function _actorclass:updateactorvisible()
	local visible = self:getactorvisible()
	if self.actordata.assetvisible ~= visible then
		self.actordata.assetvisible = visible
		if not visible and self.actordata.assetloaded then
			self:setreloadasset(true)
			self:clearanimmesh()
			self:destroysubactor()
			self:destroyadditive()
			self:loadbprender(nil)
		end
	end
end

function _actorclass:updateopacity(opacity)
	if self.actordata.assetloaded then
		self:setopacity(opacity)
		self:updatesubopacity(opacity)
	end
	if self.petactor ~= nil then
		self.petactor:setopacity(opacity)
	end
	if opacity > 0 then
		if self.namewidget == nil then
			self:createnameplate()
		end
	else
		if self.namewidget ~= nil then
			self:destroynameplate()
		end
	end
end

function _actorclass:updatdisappear()
	local opacity = self.actordata.timedisappear - time_game
	if opacity > 1.0 then
		return true
	end
	if opacity > 0.0 then
		if self.actionmain.buffopacity ~= nil then
			opacity = math.min(opacity, self.actionmain.buffopacity)
		end
		self:updateopacity(opacity)
		return true
	end
	return false
end

function _actorclass:applybuff(buff)
	self.buff[#self.buff + 1] = buff
end

function _actorclass:updatebuffopacity()
	local buffopacity = nil
	if self.buff ~= nil and #self.buff > 0 then
		for i=1, #self.buff do
			local buff = self.buff[i]
			if buff.config_buff.hidelevel ~= 0 then
				buffopacity = 1.0 - (time_game - buff.timestart)
				if self:isme() or self:isteam() or self:israid() or self:ismyspirit() then
					buffopacity = math.max(0.5, buffopacity)					
				elseif m_me.actionmain.searchlevel ~= nil and m_me.actionmain.searchlevel >= buff.config_buff.hidelevel then
					buffopacity = math.max(0.5, buffopacity)
				else
					buffopacity = math.max(0, buffopacity)
				end
			end
		end
	end
	self.actionmain.buffopacity = buffopacity
end

function _actorclass:updatebuff()
	self.actionmain.config_buffaction = nil
	self.actionmain.buffmoveable = true
	self.actionmain.buffhasdebuff = false
	self.actionmain.buffhidelevel = 0
	self.actionmain.buffopenaerial = nil
	local vehicle = self.actionmain.buffvehicle ~= nil
	if self:isme() then
		self.actionmain.buffnoskill = nil
		self.actionmain.buffvehicle = nil
	end
	local buffdeform = nil
	local buffdeformweapon = nil
	local buffopacity = nil
	self.actionmain.searchlevel = nil
	for delayindex=#self.battleprebuff,1,-1 do
		local buff = self.battleprebuff[delayindex]
		if buff.timestart <= time_game then
			self:applybuff(buff)
			if buff.itemid == 0 then
				battletext_addbuff(self, buff)
			end
			table.remove(self.battleprebuff, delayindex)
		end
	end
	if self.buff ~= nil and #self.buff > 0 then
		for i=1, #self.buff do
			local buff = self.buff[i]
			if buff.config_buff.moveable == 0 then
				self.actionmain.buffmoveable = false
			end
			if buff.config_buff.type == battlebufftype.debuff then
				self.actionmain.buffhasdebuff = true
			end
			if buff.config_buff.buffaction ~= 0 then
				if buff.config_buff.buffaction == buffactiontype.immobilize then
					self.actionmain.buffmoveable = false
				end
				if self.actionmain.config_buffaction == nil then
					self.actionmain.config_buffaction = buff.config_buff
					self.actionmain.buffactiontimemout = buff.timeout
				end
			end
			self:createbuffvfx(buff)
			if buff.config_buff.deform ~= 0 and buffdeform == nil then
				buffdeform = buff.config_buff.deform
				buffdeformweapon = false
				if csvskillbuff_getscript(buff.config_buff, "shape") ~= nil and csvskillbuff_getscript(buff.config_buff, "noskill") == nil then
					buffdeformweapon = true
				end
			end
			if buff.config_buff.searchlevel ~= 0 then
				if self.actionmain.searchlevel == nil then
					self.actionmain.searchlevel = buff.config_buff.searchlevel
				else
					self.actionmain.searchlevel = math.max(self.actionmain.searchlevel, buff.config_buff.searchlevel)
				end
			end
			if buff.config_buff.hidelevel ~= 0 then
				self.actionmain.buffhidelevel = math.max(self.actionmain.buffhidelevel, buff.config_buff.hidelevel)
				buffopacity = 1.0 - (time_game - buff.timestart)
				if self:isme() or self:isteam() or self:israid() or self:ismyspirit() then
					buffopacity = math.max(0.5, buffopacity)					
				elseif m_me.actionmain.searchlevel ~= nil and m_me.actionmain.searchlevel >= buff.config_buff.hidelevel then
					buffopacity = math.max(0.5, buffopacity)
				else
					buffopacity = math.max(0, buffopacity)
					if m_selectactorid == self.actorid then
						actormanager_selectactor(nil)
					end
				end
			end

			if buff.config_buff.openaerial > 0 then
				self.actionmain.buffopenaerial = buff.config_buff
			end
			if self:isme() then
				if buff.config_buff.noskill > 0 then
					self.actionmain.buffnoskill = buff.config_buff
				end
				if buff.config_buff.vehicle > 0 then
					self.actionmain.buffvehicle = buff.config_buff
				end
			end
		end
	end
	if self:isme() then
		if (vehicle and self.actionmain.buffvehicle == nil)
		or (not vehicle and self.actionmain.buffvehicle ~= nil) then
			skillbar_updateui()
		end
	end
	if self.actionmain.buffdeform ~= buffdeform then
		self.actionmain.buffdeform = buffdeform
		self.actionmain.buffdeformweapon = buffdeformweapon
		self:loadboundbox()
		if self.actordata.assetloaded and not scene_isloading() then
			self:loadasset()
		end
		self:updateweaponvisible()
	end
	if self.actionmain.config_buffaction ~= nil and self.actionmain.config_buffaction.buffaction == buffactiontype.stance then
        self:setbattle(1, true)
	elseif self.battle.battlestatetimeout ~= nil and self.battle.battlestatetimeout < time_game then
		self.battle.battlestatetimeout = nil
		self:setbattle(0, true)
	end
	if self.battle.battlestatebindtime ~= nil and self.battle.battlestatebindtime < time_game then
		self.battle.battlestatebindtime = nil
		self:updatebattlemesh(self:getbattle())
		self:updatesubbind()
	end
	self.actionmain.buffopacity = buffopacity
end

function _actorclass:createbuffvfx(buff)
	if not buff.vfxcreated then
		buff.vfxcreated = true
		if buff.config_buff.render ~= "0" and buff.config_buff.buffaction ~= buffactiontype.stance then
			buff.fxc = self:createskillfxc(buff.config_buff.render, bit.bor(vfxflag.followposscale, vfxflag.hidewithbuff))
		end
	end
end

function _actorclass:removebuffvfx(buff)
	if buff.fxc ~= nil then
		buff.fxc:setfade()
		buff.fxc = nil
	end
end

function _actorclass:getbufftypename(typename)
	for buffindex=1, #self.buff do
		local buff = self.buff[buffindex]
		if csvskillbuff_getscript(buff.config_buff, typename) ~= nil then
			return buff
		end
	end
	return nil
end

function _actorclass:getbufffromid(buffid)
	for buffindex=1, #self.buff do
		local buff = self.buff[buffindex]
		if buff.config_buff.id == buffid then
			return buff
		end
	end
	return nil
end
