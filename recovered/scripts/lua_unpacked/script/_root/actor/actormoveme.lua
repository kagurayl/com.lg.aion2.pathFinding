
function _actorclass:movesendsync(force)
	if self.move.inputsync_px == nil then
		self.move.inputsync_px = playerattr_info.posx
		self.move.inputsync_py = playerattr_info.posy
		self.move.inputsync_pz = playerattr_info.posz
		self.move.inputsync_rot = playerattr_info.rot
		self.move.inputsync_time = 0
		self.move.inputsync_floor = false
		self.move.inputsync_movetype = playermovestate.move
		self.move.inputsync_moving = false
		return
	end
	if self.actordata.sequencetimestart ~= nil
	or self.attr.movewindpathid ~= nil
	or self.move.sync_recvmovedesttime ~= nil
	or self.move.adjustflytimestart ~= nil
	or self.actionmain.spelltype == playerspellstate.spellcrafting
	or not self:movable()
	or scene_isloading() then
		return
	end
	local sendpos = false
	local sendrot = false
	local moving = self:ismoving()
	if force or moving ~= self.move.inputsync_moving or self.transform.onfloor ~= self.move.inputsync_floor or self.attr.movetype ~= self.move.inputsync_movetype then
		sendpos = true
	else
		local dist = vector3_distance(self.move.inputsync_px, self.move.inputsync_py, self.move.inputsync_pz, playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
		if dist > self:getplayermovespeed() / 5.0 then
			sendpos = true
		elseif self.move.inputsync_time - time_game > 1 and dist > 0.01 then
			sendpos = true
		elseif math.abs(self.move.inputsync_rot - playerattr_info.rot) > 1 then
			if moving then
				sendpos = true
			else
				sendrot = true
			end
		end
	end
	if sendpos then
		local elevator = scene_getelevatorzone()
		local falling = not self.transform.onfloor and self.attr.movetype == playermovestate.move
		local moveflag = 0
		if falling then			
			moveflag = playermoveflag.falling
		end
		if self.move.inputmove_outerui then
			moveflag = bit.bor(moveflag, playermoveflag.glidedown)
		end
		if moving then
			if self.move.inputdirection ~= movedirection.forward or self.attr.movetype == playermovestate.fly or elevator ~= 0 then
				local msg = {messageid="CS_MoveEx"}
				msg.posx = playerattr_info.posx
				msg.posy = playerattr_info.posy
				msg.posz = playerattr_info.posz
				msg.rot = playerattr_info.rot
				msg.direction = self.move.inputdirection
				msg.movex = self.move.inputmove_x
				msg.movey = self.move.inputmove_y
				msg.movez = self.move.inputmove_z
				msg.time = time_game
				msg.elevator = elevator
				msg.flag = moveflag
				c_send(msg)
			else
				local msg = {messageid="CS_Move"}
				msg.posx = playerattr_info.posx
				msg.posy = playerattr_info.posy
				msg.posz = playerattr_info.posz
				msg.rot = playerattr_info.rot
				msg.time = time_game
				msg.flag = moveflag
				c_send(msg)
			end
		elseif falling then
			local msg = {messageid="CS_Falling"}
			msg.posx = playerattr_info.posx
			msg.posy = playerattr_info.posy
			msg.posz = playerattr_info.posz
			msg.rot = playerattr_info.rot
			msg.movex = self.actionmain.jumpdirx or 0
			msg.movez = self.actionmain.jumpdirz or 0
			msg.velocity = self.move.velocity
			msg.elevator = elevator
			c_send(msg)
		else
			local msg = {messageid="CS_SetPosition"}
			msg.posx = playerattr_info.posx
			msg.posy = playerattr_info.posy
			msg.posz = playerattr_info.posz
			msg.rot = playerattr_info.rot
			msg.elevator = elevator
			c_send(msg)
		end
		self.move.inputsync_px = playerattr_info.posx
		self.move.inputsync_py = playerattr_info.posy
		self.move.inputsync_pz = playerattr_info.posz
		self.move.inputsync_rot = playerattr_info.rot
		self.move.inputsync_time = time_game
		self.move.inputsync_floor = self.transform.onfloor
		self.move.inputsync_moving = moving
	else
		if sendrot then
			local msg = {messageid="CS_Rotate"}
			msg.rot = playerattr_info.rot
			c_send(msg)	
			self.move.inputsync_rot = playerattr_info.rot
		end
	end
end

function _actorclass:movemeauto(destx, desty, destz, disttotarget)
	if scene_isloading() then
		return false
	end
	if not self:movable() then
		return false
	end
	local dist = vector3_distance(destx, desty, destz, self.transform.px, self.transform.py, self.transform.pz)
	if dist < disttotarget then
		return true
	end
	local framevelocity = self.move.framevelocity
	self.move.framevelocity = 0.0
	local movex = destx - self.transform.px
	local movey = desty - self.transform.py
	local movez = destz - self.transform.pz
	local dir = self.attr.rot
	if self:getfly() then
		local maxmove = vector3_length(movex, movey, movez)
		movex, movey, movez = vector3_normalize(movex, movey, movez)
		dir = vector2_angle3d(movex, movez)
		local movelength = time_frame * self.attr.flyspeed
		movelength = math.min(movelength, maxmove)	
		movex = movex * movelength
		movey = movey * movelength
		movez = movez * movelength
	else
		local maxmove = vector2_length(movex, movez)
		movex, movez = vector2_normalize(movex, movez)
		dir = vector2_angle3d(movex, movez)
		local movelength = time_frame * self.attr.movespeed
		movelength = math.min(movelength, maxmove)	
		movex = movex * movelength
		movez = movez * movelength
		movey = framevelocity
	end
	if movex ~= 0.0 or movey ~= 0.0 or movez ~= 0.0 then
		self:setrotation(0.0, dir, 0.0)
		self:movedirect(movex, movey, movez, true)
		dist = vector3_distance(destx, desty, destz, self.transform.px, self.transform.py, self.transform.pz)
     	return dist < disttotarget
	else
		return true
	end
end

function _actorclass:movememove()
	if not self:isme() or scene_isloading() then
		return
	end
	if self:moveplayerupdatemovedest() then
		return
	end
	if self.move.inputrot == 0.0 and self.move.inputmove_x == 0.0 and self.move.inputmove_y == 0.0 and self.move.inputmove_z == 0.0 then
		return
	end
	if not self:movable() then
		return
	end
	if self.move.inputrot ~= 0.0 then
		self:setrotation(0.0, self.move.inputrot, 0.0)
	end
	local movex = 0.0
	local movez = 0.0
	if self.move.inputmove_x ~= 0.0 or self.move.inputmove_z ~= 0.0 then
		local inputx, inputz = vector2_normalize(self.move.inputmove_x, self.move.inputmove_z)
		local movedist = time_frame * self.attr.movespeed
		movex = inputx * movedist
		movez = inputz * movedist
	end
	local movey = self.move.framevelocity
	self.move.framevelocity = 0.0
	if movex ~= 0.0 or movey ~= 0.0 or movez ~= 0.0 then
		self:movedirect(movex, movey, movez, true)
	end
end

function _actorclass:movemejump()
	if not self:isme() or scene_isloading() then
		return
	end
	if self:moveplayerupdatemovedest() then
		return
	end
	local movex = self.actionmain.jumpdirx or 0
	local movez = self.actionmain.jumpdirz or 0
	if movex == 0 and movez == 0 then
		movex = self.move.inputmove_x / 5
        movez = self.move.inputmove_z / 5
	end
    movex = movex * self.attr.movespeed * time_frame
    movez = movez * self.attr.movespeed * time_frame
    local movey = self.move.framevelocity
	self.move.framevelocity = 0.0
    self:movedirect(movex, movey, movez, false)
end

function _actorclass:movemeglide()
	if not self:isme() or scene_isloading() then
		return
	end
	if self:moveplayerupdatemovedest() then
		return
	end
	if self.move.inputrot ~= nil and self.move.inputrot ~= 0.0 then
		local rotdist = math.distdegree(playerattr_info.rot, self.move.inputrot)
		local rotspeed = 30.0 * time_frame
		local t = rotspeed / math.abs(rotdist)
		local rot = playerattr_info.rot
		if t < 1.0 then
			rot = math.lerpdegree(playerattr_info.rot, self.move.inputrot, t)
		end
	    self:setrotation(0.0, rot, 0.0)
	end
	local movey = self.move.framevelocity
	self.move.framevelocity = 0.0
	local glidespeed = self:getglidespeed()
	if self:moveiswindboxing() then
		self:movedirect(0.0, movey, 0.0, false)
	elseif self:moveisglidedown() then
		local movex, movez = self:getdirection2d()
		movex = movex * time_frame * glidespeed
		movez = movez * time_frame * glidespeed
		self:movedirect(movex, movey, movez, false)
	elseif self.move.airflowtime ~= nil then
		local movex, movez = self:getdirection2d()
		movex, movey, movez = self:movegetairflow(movex, movey, movez)
		movex = movex * time_frame * glidespeed
		movez = movez * time_frame * glidespeed
		self:movedirect(movex, movey, movez, false)
	else
		local movex, movez = self:getdirection2d()
		movex = movex * time_frame * glidespeed
		movez = movez * time_frame * glidespeed
		self:movedirect(movex, movey, movez, false)
	end

	if self.transform.onfloor then
		self.attr.movetype = playermovestate.move
		self.actionmain.glidestate = nil
		local msg = {messageid="CS_SwitchGlide"}
		msg.glide = 0
		c_send(msg)
	else
		local config_windpath, windpathpoint = csvmapwindpath_getsegment()
		if config_windpath ~= nil then
			local sync = true
			if self.actionmain.windpathidsync ~= nil and self.actionmain.windpathidsync == config_windpath.id then
				if time_game - self.actionmain.windpathidsynctime < 1 then
					sync = false
				end
			end
			if self.attr.movewindleavetime ~= nil and time_game - self.attr.movewindleavetime < 5 and self.attr.movewindleaveid == config_windpath.id then
				sync = false
			end
			if sync and windpathpoint < #config_windpath.position - 20 then
				local msg = {messageid="CS_EnterWindPath"}
				msg.id = config_windpath.id
				msg.pointindex = windpathpoint
				c_send(msg)
				self.actionmain.windpathidsync = config_windpath.id
				self.actionmain.windpathidsynctime = time_game
			end
		else
			self.actionmain.windpathidsync = nil
		end
	end
end

function _actorclass:movemefly()
	if not self:isme() or scene_isloading() then
		return
	end
	self.move.framevelocity = 0.0
	if self.move.adjustflytimestart ~= nil or self:moveplayerupdatemovedest() then
		return
	end
	if self.move.inputrot == 0.0 and self.move.inputmove_x == 0.0 and self.move.inputmove_y == 0.0 and self.move.inputmove_z == 0.0 then
		return
	end
	if not self:movable() then
		return
	end
	local inputx, inputy, inputz = vector3_normalize(self.move.inputmove_x, self.move.inputmove_y, self.move.inputmove_z)
	local movex = inputx * time_frame * self.attr.flyspeed
	local movey = inputy * time_frame * self.attr.flyspeed
	local movez = inputz * time_frame * self.attr.flyspeed
	local rx,ry,rz = vector3_fromtovector(0, 0, -1, inputx, inputy, inputz)
	if self.move.inputrot ~= 0.0 then
		ry = self.move.inputrot
	else
		ry = self.transform.ry
	end
	self:setrotation(rx, ry, 0.0)
	if movex ~= 0.0 or movey ~= 0.0 or movez ~= 0.0 then
		self:movedirect(movex, movey, movez, true)
	end
end

function _actorclass:movemegravity()
	if scene_isloading() or self:isdead() or not self:isme() then
		return
	end
	if self.move.adjustflytimestart ~= nil then
		local t = (time_game - m_me.move.adjustflytimestart) / 0.5
		if t >= 1.0 then
			t = 1.0
			self.move.adjustflytimestart = nil
		end
		local posx = math.lerp(m_me.move.adjustflyposxstart, m_me.move.adjustflyposx, t)
		local posy = math.lerp(m_me.move.adjustflyposystart, m_me.move.adjustflyposy, t)
		local posz = math.lerp(m_me.move.adjustflyposzstart, m_me.move.adjustflyposz, t)
		local rot = math.lerp(m_me.move.adjustflyrotstart, m_me.move.adjustflyrot, t)
		local movex = posx - playerattr_info.posx
		local movey = posy - playerattr_info.posy
		local movez = posz - playerattr_info.posz
		self:setrotation(0.0, rot, 0.0)
		if movex ~= 0.0 or movey ~= 0.0 or movez ~= 0.0 then
			self:movedirect(movex, movey, movez, true)
		end
	end
	if self.move.framevelocity ~= 0.0 then
		if self:moveplayerupdatemovedest() then
			return
		end
		local movey = self.move.framevelocity
		if movey ~= 0.0 then
			self:movedirect(0.0, movey, 0.0, true)
		end
	end
end
