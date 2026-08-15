
function _actorclass:getvfxbindname(bindname)
	if bindname == vfx_bind_ground or bindname == vfx_bind_foot then
		return nil, self.transform.px, self.transform.py, self.transform.pz
	elseif bindname == vfx_bind_top then
		return nil, self.transform.px, self.transform.py + self.actordata.nameheight * self.transform.sy, self.transform.pz
	elseif bindname == vfx_bind_weaponfront then
		bindname = "fx_trail_front"
	elseif bindname == vfx_bind_weaponend then
		bindname = "fx_trail_end"
	end
	local fixbind, fixname = string.endwith2(bindname, "_fix")
	if fixbind then
		if fixname == "uphead" then
			fixname = "fx_h01"
		end
		local px,py,pz,rx,ry,rz,sx,sy,sz,success = self:getsubtransform(fixname, true)
		if not success then
			py = py + (self.actordata.nameheight * self.transform.sy) / 2
		end
		return fixname, px, py, pz
	end
	fixbind, fixname = string.endwith2(bindname, "_pos")
	if fixbind then
		local px,py,pz,rx,ry,rz,sx,sy,sz,success = self:getsubtransform(fixname, true)
		if not success then
			py = py + (self.actordata.nameheight * self.transform.sy) / 2
		end
		return fixname, px, py, pz
	end
	local px,py,pz,rx,ry,rz,sx,sy,sz,success = self:getsubtransform(bindname, true)
	if not success and self.actordata.nameheight ~= nil then
		py = py + (self.actordata.nameheight * self.transform.sy) / 2
	end
	return bindname,px,py,pz
end

function _actorclass:createvfxalways(path, bind, free)
	local vfx = vfxmanager_createvfx(path)
	if bind ~= nil then
		vfx:setbind(self, bind, vfxflag.bindposition)
	else
		vfx:setposition(self.attr.posx, self.attr.posy, self.attr.posz)
	end
	if free then
		vfx:setfree()
	end
	return vfx
end

function _actorclass:createvfx(path, bind, free)
	if not self.actordata.assetvisible or scene_isloading() then
		return
	end
	local vfx = vfxmanager_createvfx(path)
	if bind ~= nil then
		vfx:setbind(self, bind, vfxflag.bindposition)
	else
		vfx:setposition(self.attr.posx, self.attr.posy, self.attr.posz)
	end
	if free then
		vfx:setfree()
	end
	return vfx
end

function _actorclass:createskillfxc(fxlambda, flag, attackerid, targetid)
	if not self.actordata.assetvisible or scene_isloading() then
		return
	end
	if fxlambda == "0" then
		return
	end
	local fxname = csvconfig_getsubvalue(fxlambda, 1, configsubtype.str)
	local fxbind = csvconfig_getsubvalue(fxlambda, 2, configsubtype.str)
	if fxbind == "0" then
		fxbind = nil
	end
	if flag ~= nil and bit.band(flag, vfxflag.hidewithbuff) ~= 0 and self.actionmain.buffopacity ~= nil and self.actionmain.buffopacity <= 0.0 then
		return
	end
	return vfxmanager_createfxc(fxname, self, fxbind, flag or 0, attackerid or 0, targetid or 0)
end

function _actorclass:createcastvfx(fxlambda, instid)
	if not self.actordata.assetvisible or scene_isloading() then
		return
	end
	if fxlambda == "0" then
		return
	end
	local inst = self:getattackerinst(instid)
	if inst == nil then
		return
	end
	local flag = bit.bor(vfxflag.followposscale, bit.bor(vfxflag.hidewithbuff, vfxflag.free), vfxflag.linktarget)
	self:createskillfxc(fxlambda, flag, self.actorid, inst.maintarget)
end

function _actorclass:clearvfx()
	if self.battleammo ~= nil then
		for castindex=#self.battleammo,1,-1 do
			local ammo = self.battleammo[castindex]
			if ammo.vfx ~= nil then
				ammo.vfx:setfade()
				ammo.vfx = nil
			end
		end
		self.battleammo = nil
	end
	if self.buff ~= nil then
		for i=1,#self.buff do
			self:removebuffvfx(self.buff[i])
		end
	end
	if self.aliaseverytime ~= nil then
		aliasmanager_destory(self.aliaseverytime)
		self.aliaseverytime = nil
	end
	if self.actordata ~= nil then
		if self.actordata.vfxmesh ~= nil then
			self.actordata.vfxmesh:setfade()
			self.actordata.vfxmesh = nil
		end
		if self.actordata.godstonevfx ~= nil then
			self.actordata.godstonevfx:setfade()
			self.actordata.godstonevfx = nil
		end
		if self.actordata.weaponnormalvfx ~= nil then
			self.actordata.weaponnormalvfx:setfade()
			self.actordata.weaponnormalvfx = nil
		end
		if self.actordata.weaponbattlevfx ~= nil then
			self.actordata.weaponbattlevfx:setfade()
			self.actordata.weaponbattlevfx = nil
		end
		if self.actordata.vfxdrop ~= nil then
			self.actordata.vfxdrop:setfade()
			self.actordata.vfxdrop = nil
		end
		if self.actordata.vfxquest ~= nil then
			self.actordata.vfxquest:setfade()
			self.actordata.vfxquest = nil
		end
		if self.actordata.vfxspell ~= nil then
			self.actordata.vfxspell:setfade()
			self.actordata.vfxspell = nil
		end
	end
end

function _actorclass:updatevfx()
	for castindex=#self.battleammo,1,-1 do
		local ammo = self.battleammo[castindex]
		if ammo.timestart <= time_game then
			local remove = true
			if ammo.timestart + ammo.timelength > time_game then
				local target = actormanager_getfromactorid(ammo.targetid)
				if target ~= nil then
					remove = false
					if ammo.vfx == nil then
						ammo.vfx = self:createskillfxc(ammo.fxammo)
						ammo.type = csvconfig_getsubvalue(ammo.fxammo, 3, configsubtype.int)
					end
					if ammo.vfx ~= nil then
						local t = (time_game - ammo.timestart) / ammo.timelength
						local target_x, target_y, target_z = target:gethitpoint()
						ammo.vfx:setammo(self, target_x, target_y, target_z, t, ammo.type)
					end
				end
			end
			if remove then
				if ammo.vfx ~= nil then
					ammo.vfx:setfade()
					ammo.vfx = nil	
				end
				table.remove(self.battleammo, castindex)
			end
		end
	end
	for delayindex=#self.battleprehitpoint,1,-1 do
		local battleprehitpoint = self.battleprehitpoint[delayindex]
		if battleprehitpoint.timehit <= time_game then
			if self:overlayable(battleprehitpoint.attackerid, battleprehitpoint.action) then
				overlay_addpoint(self, battleprehitpoint.action, battleprehitpoint.accuracy, battleprehitpoint.valoverlay)
			end
			if battleprehitpoint.action == lambdapointtype.hpdec then
				actionmanager_setdamageaction(self, battleprehitpoint.accuracy)
			end
			if battleprehitpoint.hitevent then
				self:playhitaudio(battleprehitpoint.attackerid, battleprehitpoint.accuracy)
			end
			table.remove(self.battleprehitpoint, delayindex)
		end
	end
	for prehitindex=#self.battleprehitvfx,1,-1 do
		local prehit = self.battleprehitvfx[prehitindex]
		if prehit.timeprehit <= time_game then
			self:createskillfxc(prehit.config_skill.fxprehit, bit.bor(vfxflag.free, vfxflag.spawnposition, vfxflag.vampiric), prehit.attackerid, self.actorid)
			table.remove(self.battleprehitvfx, prehitindex)
		end
	end
	for hitindex=#self.battlehitvfx,1,-1 do
		local hit = self.battlehitvfx[hitindex]
		if hit.timehit <= time_game then
			local attacker = actormanager_getfromactorid(hit.attacker)
			self:createhitvfx(attacker, hit.config_skill, hit.accuracy, hit.battery, 0.0)
			table.remove(self.battlehitvfx, hitindex)
		end
	end
	if self.actordata.vfxquest ~= nil then
		local worldx = self.transform.px
		local worldy = self.transform.py + self.actordata.nameheight * self.transform.sy + 0.2
		local worldz = self.transform.pz
		local screenx, screeny, screenz = c_scene_worldtoscreen(worldx, worldy, worldz)
		local fixx, fixy, fixz = c_scene_screentoworld(screenx, screeny + 100, screenz)
		self.actordata.vfxquest:setposition(fixx, fixy, fixz)
	end
end

function _actorclass:createdelaypoint(attackerid, timehit, action, accuracy, overlay, delay, hitevent)
	if timehit <= time_game then
		if self:overlayable(attackerid, action) then
			overlay_addpoint(self, action, accuracy, overlay)
		end
		if action == lambdapointtype.hpdec then
			actionmanager_setdamageaction(self, accuracy)
		end
		if hitevent then
			self:playhitaudio(attackerid, accuracy)
		end
		return
	end
	local prehit = {}
	prehit.timehit = timehit
	prehit.action = action
	prehit.accuracy = accuracy
	prehit.valoverlay = overlay
	prehit.valdelay = delay
	prehit.attackerid = attackerid
	prehit.hitevent = hitevent
	self.battleprehitpoint[#self.battleprehitpoint + 1] = prehit	
end

function _actorclass:createprehitvfx(attackerid, config_skill, timeprehit)
	if config_skill.fxprehit ~= "0" then
		local prehit = {}
		prehit.attackerid = attackerid
		prehit.config_skill = config_skill
		prehit.timeprehit = timeprehit
		self.battleprehitvfx[#self.battleprehitvfx + 1] = prehit
	end
end

function _actorclass:createhitvfx(attacker, config_skill, accuracy, battery, timehit)
	if not self.actordata.assetvisible or scene_isloading() then
		return
	end
	if accuracy == lambdaaccuracytype.dodge or accuracy == lambdaaccuracytype.resist then
		return
	end
	if timehit > time_game then
		local hit = {}
		hit.attacker = 0
		hit.config_skill = config_skill
		hit.weapontype = nil
		hit.accuracy = accuracy
		hit.battery = battery
		hit.timehit = timehit
		if attacker ~= nil then
			hit.attacker = attacker.actorid
		end
		self.battlehitvfx[#self.battlehitvfx + 1] = hit
		return
	end
	if accuracy == lambdaaccuracytype.shield then
		if attacker ~= nil then
			local px1,py1,pz1 = attacker.transform.px,attacker.transform.py,attacker.transform.pz
			local px2,py2,pz2 = self:gethitpoint()
			local dx,dz = vector2_normalize(px1 - px2, pz1 - pz2)
			local rot = vector2_angle3d(dx, dz)
			local vfx = vfxmanager_createvfx(EffectHitShield)
			vfx:setposition(px2, py2, pz2)
			vfx:setrotation(0, rot, 0)
			vfx:setfree()
		end
	elseif accuracy == lambdaaccuracytype.protect then
		if attacker ~= nil then
			local px1,py1,pz1 = attacker.transform.px,attacker.transform.py,attacker.transform.pz
			local px2,py2,pz2 = self:gethitpoint()
			local dx,dz = vector2_normalize(px1 - px2, pz1 - pz2)
			local rot = vector2_angle3d(dx, dz)
			local vfx = vfxmanager_createvfx(EffectHitProtect)
			vfx:setposition(px2, py2, pz2)
			vfx:setrotation(0, rot, 0)
			vfx:setfree()
		end
	else
		if config_skill ~= nil then
			if config_skill.fxhit ~= "0" then
				local attackerid = 0
				if attacker ~= nil then
					attackerid = attacker.actorid
				end
				self:createskillfxc(config_skill.fxhit, bit.bor(vfxflag.free, vfxflag.spawnposition, vfxflag.vampiric), attackerid, self.actorid)
			end
		elseif attacker ~= nil then
			local fxc = nil
			if attacker.weaponactor1 ~= nil then
				local weapontype = attacker.weaponactor1.weapontype
				if weapontype == csvitemtype.weapon_book or weapontype == csvitemtype.weapon_orb then
					fxc = EffectHitMagic
				elseif weapontype == csvitemtype.weapon_bow then
					fxc = EffectHitBow
				elseif accuracy == lambdaaccuracytype.crit then
					fxc = EffectHitCritical
				elseif battery > 0 then
					fxc = EffectHitBattery
				else
					fxc = EffectHitBlunt
				end
			-- elseif attacker:isnpc() and attacker.config_npc.attackfx ~= "0" then
			-- 	fxc = attacker.config_npc.attackfx
			else
				if accuracy == lambdaaccuracytype.crit then
					fxc = EffectHitCritical
				else
					fxc = EffectHitBluntORI
				end
			end
			if fxc ~= nil then
				self:createskillfxc(fxc, bit.bor(vfxflag.free, vfxflag.spawnposition), attacker.actorid, self.actorid)
			end
		end
	end
end

function _actorclass:updatequestvfx()
	if not self:isdynamicnpc() and not self:isstaticnpc() then
		return
	end
	local config_npc = self.config_npc
	local filename = nil
	local scale = 1.0
	local submitlist = csvquest_getnpcsubmitlist(config_npc.id)
	if submitlist ~= nil then
		for questindex=1,#playerattr_quest do
			local quest = playerattr_quest[questindex]
			if playerquest_submitable(quest, config_npc, submitlist) then
				if quest.config_quest.type == questtype.main then
					filename = EffectQuestYellowSubmit
					scale = 1.2
					break
				elseif quest.config_quest.type ~= questtype.crafting then
					filename = EffectQuestBlueSubmit
				end
			end
		end
	end
	if filename == nil then
		for questindex=1,#playerattr_quest do
			local quest = playerattr_quest[questindex]
			if playerquest_talkable(quest, config_npc, false) then
				if quest.config_quest.type == questtype.main then
					filename = EffectQuestYellowTalk
					scale = 1.2
					break
				elseif quest.config_quest.type ~= questtype.crafting then
					filename = EffectQuestBlueTalk
				end
			end
		end
		if filename == nil then
			local questlist = csvquest_getnpcquestlist(config_npc.id)
			if questlist ~= nil then
				for i=1,#questlist do
					local config_acceptquest = questlist[i]
					if playerquest_visible(config_acceptquest) then
						if playerquest_acceptable(config_acceptquest) then
							if config_acceptquest.type == questtype.main then
								filename = EffectQuestYellowAccept
								scale = 1.2
								break
							elseif config_acceptquest.type ~= questtype.crafting then
								filename = EffectQuestBlueAccept
							end
						end
					end
				end
			end
		end
	end
	if self.actordata.vfxquest ~= nil then
		if self.actordata.vfxquest.file ~= filename then
			self.actordata.vfxquest:destroy()
			self.actordata.vfxquest = nil
		else
			filename = nil
		end
	end
	if filename ~= nil then
		self.actordata.vfxquest = self:createvfx(filename, nil, false)
		if self.actordata.vfxquest ~= nil then
			self.actordata.vfxquest:setscale(scale, scale, scale)
		end
	end
end

function _actorclass:loaddropvfx()
	if self:isdead() and self.actordata.vfxdrop == nil then
		local loadvfx = false
		if self.attr.dropstate == npcdropstate.owner then
			loadvfx = playerattr_info.actorid == self.attr.dropowner[1]
		elseif self.attr.dropstate == npcdropstate.team then
			loadvfx = table.containvalue(self.attr.dropowner, playerattr_info.actorid)
		elseif self.attr.dropstate == npcdropstate.share then
			loadvfx = true
		end
		if loadvfx then
			self.actordata.vfxdrop = self:createvfx(EffectNPCDrop, vfx_bind_ground, false)
		end
	end
end

function _actorclass:addattackerinst(inst)
    for i=#self.battleinst,1,-1 do
        local removeinst = self.battleinst[i]
        if removeinst.timestart + 10.0 < time_game then
            table.remove(self.battleinst, i)
        end
    end
    self.battleinst[#self.battleinst + 1] = inst
end

function _actorclass:getattackerinst(instid)
	for i=1,#self.battleinst do
		if self.battleinst[i].instid == instid then
			return self.battleinst[i]
		end
	end
end
