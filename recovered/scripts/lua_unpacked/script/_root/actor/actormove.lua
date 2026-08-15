
local m_actormove_gravity = 18
local m_actormove_airflowgravity = 5
local m_actormove_playerartwalk = 2
local m_actormove_playerartrun = 8

function _actorclass:getmoveanimspeed()
	local animspeed = 1.0
	if self:isplayer() then
		if self.attr.movetype ~= playermovestate.fly and self.attr.movetype ~= playermovestate.glide then
			if self.attr.moverun > 0 then
				animspeed = self.attr.movespeed / m_actormove_playerartrun
			else
				animspeed = self.attr.movespeed / m_actormove_playerartwalk
			end
			animspeed = animspeed / self.attr.bodysize
		end
	elseif self:isdynamicnpc() then
		if self.move.sync_npcmovespeed ~= nil and self.move.sync_npcmovespeed > 0 then
			if self.attr.npcstate == npcsyncstate.movewalk then
				local walkspeed = csvconfig_getsubvalue(self.config_npc.speed, 1, configsubtype.flt)
				if walkspeed > 0 then
					animspeed = self.move.sync_npcmovespeed / walkspeed
				end
			else
				local runspeed = csvconfig_getsubvalue(self.config_npc.speed, 2, configsubtype.flt)
				if runspeed > 0 then
					animspeed = self.move.sync_npcmovespeed / runspeed
				end
			end
		end
	end
	return animspeed
end

function _actorclass:stopmove()
	if self:isplayer() then
		self:moveplayerclearmovequeue()
		self.move.sync_recvmovedesttime = nil
	elseif self:isdynamicnpc() then
		self.move.sync_npcmovespeed = nil
	end
end

function _actorclass:moveiswindboxing()
	if self.move.windboxmax ~= nil then
		if self.move.windboxmax <= self.attr.posy then
			self.move.windboxmax = nil
		end
	end
	return self.move.windboxmax ~= nil
end

function _actorclass:moveisglidedown()
	if self:isme() then
		return self.move.inputmove_outerui
	elseif self:isplayer() then
		if self.move.sync ~= nil and #self.move.sync > 0 then
			local sync = self.move.sync[1]
			if bit.band(sync.flag, playermoveflag.glidedown) ~= 0 then
				return true
			end
		end
	end
	return false
end


function _actorclass:moveupdatevelocity()
	if self.move.velocity == nil then
		self.move.velocity = 0.0
	end
	if self.actordata.sequencetimestart ~= nil or self.attr.movewindpathid ~= nil then
		self.move.velocity = 0.0
		self.move.framevelocity = 0.0
		return
	end
	if self.attr.movetype == playermovestate.fly then
		self.move.velocity = 0.0
		self.move.framevelocity = 0.0
		return
	end
	if self.attr.movetype == playermovestate.glide then
		if self:moveiswindboxing() then
			self.move.velocity = 0.0
			self.move.framevelocity = 5.0 * time_frame
			return
		end
		if self:moveisglidedown() then
			self.move.framevelocity = -6.0 * time_frame
			return
		end
		if self.move.velocity > 0.0 then
			self.move.velocity = self.move.velocity - m_actormove_airflowgravity * time_frame
			if self.move.velocity < 0.0 then
				self.move.velocity = 0.0
				self.move.airflowtime = time_game
			end
			self.move.framevelocity = self.move.velocity * time_frame
			return
		end
		self.move.velocity = 0.0
		self.move.framevelocity = -4.0 * time_frame
		return
	end
	if self.actionmain.buffopenaerial ~= nil then
		self.move.velocity = 0.0
		self.move.framevelocity = 0.0
		return
	end
	if self.transform.onfloor and self.move.velocity <= 0.0 then
		self.move.velocity = 0.0
		self.move.framevelocity = -m_actormove_gravity * time_frame
		return
	end
	self.move.velocity = self.move.velocity - m_actormove_gravity * time_frame
	if self.move.velocity < -100.0 then
		self.move.velocity = -100.0
	end
	self.move.framevelocity = self.move.velocity * time_frame
end

function _actorclass:movegetairflow(movex, movey, movez)
	if movey > 0.0 then
		return 0.0, movey, 0.0
	end
	if self.move.airflowtime ~= nil then
		local t = time_game - self.move.airflowtime
		if t < 1.0 then
			movex = math.lerp(0.0, movex, t)
			movez = math.lerp(0.0, movez, t)
			return movex, movey, movez
		end
		self.move.airflowtime = nil
	end
	return movex, movey, movez
end

function _actorclass:movesetjump(movex, movez)
	self.move.velocity = 8
	self.actionmain.jumptime = time_game
	self.actionmain.jumpdirx = movex
    self.actionmain.jumpdirz = movez
end

function _actorclass:ismovinginput()
	if self:isme() then
		return self.move.inputmove_x ~= 0.0 or self.move.inputmove_y ~= 0.0 or self.move.inputmove_z ~= 0.0
	end
	return false
end

function _actorclass:ismoving()
	if self:isplayer() then
		if self.move.sync_recvmovedesttime ~= nil then
			return true
		end
		if self:isme() then
			if not self:movable() then
				return false
			end
			if playerapproach_moving() then
				return true
			end
			return (self.move.inputmove_x ~= 0.0 or self.move.inputmove_y ~= 0.0 or self.move.inputmove_z ~= 0.0)
		else
			return self.move.sync ~= nil and #self.move.sync > 0
		end
	elseif self:isdynamicnpc() then
		return self.move.sync_npcmovespeed ~= nil and self.move.sync_npcmovespeed ~= 0.0 and self.move.sync_npcmovetimelength ~= 0
	end
   return false
end

function _actorclass:setactorposition(px, py, pz, rot)
	self.attr.posx = px
	self.attr.posy = py
	self.attr.posz = pz
	self.attr.rot = rot
	self:updateactorposition()
end

function _actorclass:setactorpositionskipfloor(px, py, pz, rot)
	self.attr.posx = px
	self.attr.posy = py
	self.attr.posz = pz
	self.attr.rot = rot
	local posy = self.attr.posy
	local rot = self.attr.rot
	if self.actionmain.posy ~= nil then
		posy = posy + self.actionmain.posy
	end
	if self.actionmain.rot ~= nil then
		rot = rot + self.actionmain.rot
	end
	self:setpositionrotation(self.attr.posx, posy, self.attr.posz, self.transform.rx, rot, self.transform.rz)
end

function _actorclass:setactorrotation(rot)
	self.attr.rot = rot
	self:setrotation(self.transform.rx, rot, self.transform.rz)
end

function _actorclass:updateactorposition()
	local posy = self.attr.posy
	if self:isplayer() then
		if self.attr.movetype == playermovestate.move and self.move.framevelocity ~= nil and self.move.framevelocity < 0.0 then
			local floorheight, physicmaterial = scene_getfloorheight(self.attr.posx, self.attr.posy, self.attr.posz, 1)
			if posy - floorheight < 0.1 then
				posy = floorheight
				self.transform.onfloor = true
				self.transform.physicmaterial = physicmaterial
			end
		end
	elseif self:isdynamicnpc() then
		if self.attr.aerial == 0 then
			local floorheight, physicmaterial = scene_getfloorheight(self.attr.posx, self.attr.posy, self.attr.posz, 1)
			posy = floorheight
			self.transform.onfloor = true
			self.transform.physicmaterial = physicmaterial
		elseif self.attr.aerial == 2 then
			local floorheight, physicmaterial = scene_getfloorheightlengthlimit(self.attr.posx, self.attr.posy, self.attr.posz, 5, 1)
			posy = floorheight
			if physicmaterial ~= nil then
				self.transform.onfloor = true
				self.transform.physicmaterial = physicmaterial
			else
				self.transform.onfloor = false
			end
		end
	end
	
	local rot = self.attr.rot
	if self.actionmain.posy ~= nil then
		posy = posy + self.actionmain.posy
	end
	if self.actionmain.rot ~= nil then
		rot = rot + self.actionmain.rot
	end
	self:setpositionrotation(self.attr.posx, posy, self.attr.posz, self.transform.rx, rot, self.transform.rz)
end

function _actorclass:setactorlook(target)
	if self:isnpc() and self.config_npc.stationary == 1 then
		return
	end
	if target.actorid ~= self.actorid then
		self:setlookrotation(target.transform.px, target.transform.py, target.transform.pz)
		self.attr.rot = self.transform.ry
	end
end
