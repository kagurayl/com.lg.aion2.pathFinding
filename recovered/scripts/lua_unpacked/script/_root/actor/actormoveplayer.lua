
local actormoveplayer_predicttime = 1.0

function _actorclass:moveplayeraddmove(msg)
	if self.move.sync == nil then
		self.move.sync = {}
	end
	if #self.move.sync == 0 then
		self.move.sync_predict = 0.0
		self.move.sync_smoothtime = msg.time
	end
	self.move.sync[#self.move.sync + 1] = msg
end

function _actorclass:moveplayeraddrotate(rot)
	self.move.sync_rotstart = self.attr.rot
	self.move.sync_rotend = rot
	self.move.sync_rottime = time_game
end

function _actorclass:moveplayerclearmovequeue()
	if self.move.sync ~= nil and #self.move.sync > 0 then
		self.move.sync = {}
	end
end

function _actorclass:moveplayerclearrotate()
	self.move.sync_rotstart = nil
end

function _actorclass:moveplayerrotate()
	if self.move.sync_rotstart ~= nil then
		local t = math.min(1.0, (time_game - self.move.sync_rottime) * 10)
		local rot = math.lerpdegree(self.move.sync_rotstart, self.move.sync_rotend, t)
		self:setactorrotation(rot)
		if t >= 1.0 then
			self.move.sync_rotstart = nil
		end
	end
end

function _actorclass:moveplayerupdate()
	if scene_isloading() then
		return false
	end
	if self:moveplayerupdatemovedest() then
		self:moveplayerclearrotate()
		self:moveplayerclearmovequeue()
		return
	end
	if self.move.sync == nil or #self.move.sync == 0 then
		self:moveplayerrotate()
		if self.attr.movetype == playermovestate.move then
			if not self.transform.onfloor then
				self:moveplayerjumpauto()
				return
			end
		elseif self.attr.movetype == playermovestate.glide then
			self:moveplayerglideauto()
			return
		end
		self:moveplayergravity()
		return
	end
	self:moveplayerclearrotate()

	self.move.sync_smoothtime = self.move.sync_smoothtime + time_frame
	local timelength = time_frame
	while #self.move.sync > 1 do
		if self.move.sync_smoothtime >= self.move.sync[2].time then
			timelength = self.move.sync_smoothtime - self.move.sync[2].time
			self.move.sync_predict = 0.0
			table.remove(self.move.sync, 1)
		else
			break
		end
	end
	local timepredit = self.move.sync_predict + timelength
	if timepredit > actormoveplayer_predicttime then
		timelength = math.max(0.0, actormoveplayer_predicttime - self.move.sync_predict)
		self.move.sync_predict = actormoveplayer_predicttime
	else
		self.move.sync_predict = timepredit
	end
	local sync = self.move.sync[1]
	self.move.inputdirection = sync.direction

	if sync.rotstart == nil then
		sync.rotstart = self.attr.rot
		sync.posxfixtotal = sync.posx - self.attr.posx
		sync.posyfixtotal = sync.posy - self.attr.posy
		sync.poszfixtotal = sync.posz - self.attr.posz
		sync.posxfixremain = sync.posxfixtotal
		sync.posyfixremain = sync.posyfixtotal
		sync.poszfixremain = sync.poszfixtotal
	end

	local rotfix = math.min(1.0, (self.move.sync_smoothtime - sync.time) * 10.0)
	local rotcurrent = math.lerpdegree(sync.rotstart, sync.rot, rotfix)
	self:setactorrotation(rotcurrent)
	
	local posfix = time_frame * 10.0
	sync.posxfix = math.minabs(sync.posxfixremain, sync.posxfixtotal * posfix)
	sync.posyfix = math.minabs(sync.posyfixremain, sync.posyfixtotal * posfix)
	sync.poszfix = math.minabs(sync.poszfixremain, sync.poszfixtotal * posfix)
	sync.posxfixremain = sync.posxfixremain - sync.posxfix
	sync.posyfixremain = sync.posyfixremain - sync.posyfix
	sync.poszfixremain = sync.poszfixremain - sync.poszfix
	sync.velocity = self.move.framevelocity
	sync.movedist = timelength * self:getplayermovespeed()

	if self.attr.movetype == playermovestate.move then
		if self.transform.onfloor then
			self:moveplayermove(sync)
		else
			self:moveplayerjump(sync)
		end
	elseif self.attr.movetype == playermovestate.glide then
		self:moveplayerglide(sync)
	elseif self.attr.movetype == playermovestate.fly then
		self:moveplayerfly(sync)
	end
end

function _actorclass:moveplayermove(sync)
	self:movecapsule(sync.dirx * sync.movedist + sync.posxfix, sync.velocity + sync.posyfix, sync.dirz * sync.movedist + sync.poszfix)
end

function _actorclass:moveplayerjump(sync)
	local movex = self.actionmain.jumpdirx or 0
	local movez = self.actionmain.jumpdirz or 0
	if movex == 0 and movez == 0 then
		movex = sync.dirx / 5
        movez = sync.dirz / 5
	end
	movex = movex * sync.movedist
	movez = movez * sync.movedist
	self:movecapsule(movex + sync.posxfix, sync.velocity + sync.posyfix, movez + sync.poszfix)
end

function _actorclass:moveplayerjumpauto()
	local dirx = 0.0
	local dirz = 0.0
	if self.actionmain.jumpdirx ~= nil and self.actionmain.jumpdirz ~= nil then
		dirx = self.actionmain.jumpdirx * self.attr.movespeed * time_frame
		dirz = self.actionmain.jumpdirz * self.attr.movespeed * time_frame
	end
	self:movecapsule(dirx, self.move.framevelocity, dirz)
end

function _actorclass:moveplayerglide(sync)
	if self.move.framevelocity < 0.0 then
		local dirx, dirz = vector2_normalize(vector2_rotatestandard3d(sync.rot))
		local movex = nil
		local movey = nil
		local movez = nil
		if self:moveisglidedown() then
			movex = dirx
			movey = self.move.framevelocity
			movez = dirz
		else
			movex, movey, movez = self:movegetairflow(dirx, self.move.framevelocity, dirz)
		end
		movex = movex * sync.movedist
		movez = movez * sync.movedist
		self:movecapsule(movex + sync.posxfix, movey + sync.posyfix, movez + sync.poszfix)
	else
		self:movecapsule(sync.posxfix, sync.velocity + sync.posyfix, sync.poszfix)
	end
end

function _actorclass:moveplayerglideauto()
	local movey = self.move.framevelocity
	if movey < 0.0 then
		local glidespeed = self:getglidespeed()
		local movex, movez = self:getdirection2d()
		movex, movey, movez = self:movegetairflow(movex, movey, movez)
		movex = movex * time_frame * glidespeed
		movez = movez * time_frame * glidespeed
		self:movecapsule(movex, movey, movez)
	else
		self:movecapsule(0.0, movey, 0.0)
	end
end

function _actorclass:moveplayerfly(sync)
	local posx = self.attr.posx
	local posy = self.attr.posy
	local posz = self.attr.posz
	self:movecapsule(sync.dirx * sync.movedist + sync.posxfix, sync.diry * sync.movedist + sync.posyfix, sync.dirz * sync.movedist + sync.poszfix)
	local dx = self.attr.posx - posx
	local dy = self.attr.posy - posy
	local dz = self.attr.posz - posz
	if dx ~= 0 or dy ~= 0 or dz ~= 0 then
		dx, dy, dz = vector3_normalize(dx, dy, dz)
		local rx,ry,rz = vector3_fromtovector(0, 0, -1, dx, dy, dz)
		self:setrotation(rx, self.attr.rot, 0.0)
	end
end

function _actorclass:moveplayergravity()
	if self.move.framevelocity ~= 0.0 then
		self:movecapsule(0.0, self.move.framevelocity, 0.0)
	end
end
