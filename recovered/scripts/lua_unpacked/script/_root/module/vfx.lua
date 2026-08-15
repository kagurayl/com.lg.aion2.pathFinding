
local vfxstate =
{
    emit = 1,
    fade = 2,
	freerequest = 3,
    freedelay = 4,
	freestop = 5,
}

vfx_bind_ground = "ground"
vfx_bind_foot = "foot"
vfx_bind_top = "bboxtop"
vfx_bind_center = "bip01"
vfx_bind_weaponfront = "weaponfront"
vfx_bind_weaponend = "weaponend"

_vfxclass = _class("_vfxclass")

function vfxcreatefromfile(file)
	local vfx = _vfxclass.new()
	vfx.state = vfxstate.emit
    vfx.file = file
	vfx.alive = true
	vfx.visible = true
	vfx.px = 0
	vfx.py = 0
	vfx.pz = 0
	vfx.rx = 0
	vfx.ry = 0
	vfx.rz = 0
	vfx.sx = 1
	vfx.sy = 1
	vfx.sz = 1
	vfx:createactor()
	return vfx
end

function _vfxclass:createactor()
	if not scene_isloading() and self.file ~= nil and self.alive then
		if self.id ~= nil then
			c_actor_destroy(self.id)
		end
		self.id = csvconfig_generatescriptid()
		local path = string.format("effects/prt/%s.prefab", self.file)
		c_actor_create(self.id, self.px, self.py, self.pz, self.rx, self.ry, self.rz, self.sx, self.sy, self.sz, RenderLayerVFX, 0, self.file)
		c_actor_loadbp(self.id, path)
		if not self.visible then
			self:setvisible(self.visible)
		end
		if self.bindactor ~= 0 then
			local bindactor = actormanager_getfromactorid(self.bindactor)
			if bindactor ~= nil then
				if self.bindbp then
					c_actor_bindbp(self.id, bindactor.id, self.bindactorname, -1, -1, 0, 0, 0)
				elseif self.followposition or self.followrotation or self.followscale then
					c_actor_followbp(self.id, bindactor.id, self.bindactorname, self.followposition, self.followrotation, self.followscale, self.followx, self.followy, self.followz)
				end
			end
		end
    end
end

function _vfxclass:setbind(actor, bindname, bindflag, attackerid)
	local bindx = nil
	local bindy = nil
	local bindz = nil
	local bindbone = nil
	if bindname ~= nil then
		bindbone, bindx, bindy, bindz = actor:getvfxbindname(bindname)
	end
	local bindbp = bit.band(bindflag, vfxflag.bindposition) ~= 0 and bindname ~= vfx_bind_ground
	local followposition = bit.band(bindflag, vfxflag.followposition) ~= 0
	local followrotation = bit.band(bindflag, vfxflag.followrotation) ~= 0
	local followscale = bit.band(bindflag, vfxflag.followscale) ~= 0
	local spawn = bindx ~= nil and bit.band(bindflag, vfxflag.spawnposition) ~= 0
	if bindbp or followposition or followrotation or followscale then
		self.bindactor = actor.actorid
		self.bindactorname = bindbone
		self.bindbp = bindbp
		self.followposition = followposition
		self.followrotation = followrotation
		self.followscale = followscale
		self.followx = 0.0
		self.followy = 0.0
		self.followz = 0.0
		if bindx ~= nil and bindbone == nil then
			self.followx = bindx - actor.transform.px
			self.followy = bindy - actor.transform.py
			self.followz = bindz - actor.transform.pz
		end
		if self.id ~= nil then
			if bindbp then
				c_actor_bindbp(self.id, actor.id, bindbone, -1, -1, 0, 0, 0)
			else
				c_actor_followbp(self.id, actor.id, bindbone, followposition, followrotation, followscale, self.followx, self.followy, self.followz)
			end
		end
	elseif spawn then
		self:setposition(bindx, bindy, bindz)
	else
		self:setposition(actor.transform.px, actor.transform.py, actor.transform.pz)
	end
	local attacker = nil
	if attackerid ~= nil and attackerid ~= 0 and attackerid ~= actor.actorid then
		attacker = actormanager_getfromactorid(attackerid)
	end
	if attacker ~= nil then
		local dx = actor.transform.px - attacker.transform.px
		local dy = actor.transform.py - attacker.transform.py
		local dz = actor.transform.pz - attacker.transform.pz
		if dx ~= 0 or dy ~= 0 or dz ~= 0 then
			dx,dy,dz = vector3_normalize(dx, dy, dz)
			local angle = vector2_angle3d(dx, dz)
			self:setrotation(0.0, angle, 0.0)
		end
	else
		if bindbp then
			self:setrotation(0, 0, 0)
		else
			self:setrotation(0, actor.transform.ry, 0)			
		end	
	end
end

function _vfxclass:setposition(x, y, z)
	self.px = x
	self.py = y
	self.pz = z
	if self.id ~= nil then
		c_actor_setpositon(self.id, x, y, z)
	end
end

function _vfxclass:setrotation(x, y, z)
	self.rx = x
	self.ry = y
	self.rz = z
	if self.id ~= nil then
		c_actor_setrotation(self.id, x, y, z)
	end
end

function _vfxclass:setpositionrotation(px, py, pz, rx, ry, rz)
	self.px = px
	self.py = py
	self.pz = pz
	self.rx = rx
	self.ry = ry
	self.rz = rz
	if self.id ~= nil then
		c_actor_setposrot(self.id, px, py, pz, rx, ry, rz)
	end
end

function _vfxclass:setscale(x, y, z)
	self.sx = x
	self.sy = y
	self.sz = z
	if self.id ~= nil then
		c_actor_setscale(self.id, x,y,z)
	end
end

function _vfxclass:setvampiric(attackerid, targetid)
	if self.id ~= nil then
		local attacker_x = self.px
		local attacker_y = self.py
		local attacker_z = self.pz
		local target_x = self.px
		local target_y = self.py
		local target_z = self.pz
		local attacker = actormanager_getfromactorid(attackerid)
		if attacker ~= nil then
			local bindname, x, y, z = attacker:getvfxbindname("fx_hit")
			attacker_x = x
			attacker_y = y
			attacker_z = z
		end
		local target = actormanager_getfromactorid(targetid)
		if target ~= nil then
			local bindname, x, y, z = target:getvfxbindname("fx_hit")
			target_x = x
			target_y = y
			target_z = z
		end
		c_actor_setvampiric(self.id, attacker_x, attacker_y, attacker_z, target_x, target_y, target_z)
	end
end

function _vfxclass:setlinktarget(targetid)
	if self.id ~= nil then
		local target = actormanager_getfromactorid(targetid)
		if target ~= nil then
			local bindname, x, y, z = target:getvfxbindname("fx_hit")
			c_actor_setlink(self.id, x, y, z)
		end
	end
end

function _vfxclass:setvisible(visible)
	self.visible = visible
	if self.id ~= nil then
		c_actor_setvisible(self.id, visible)
	end
end

function _vfxclass:setfree()
	if self.state == vfxstate.emit then
		self.state = vfxstate.freerequest
		vfxmanager_addvfxupdate(self)
	end
end

function _vfxclass:setfade()
	self.alive = false
	if self.state == vfxstate.emit then
		local fadelength = self:stop()
		if fadelength > 0.0 then
			self.state = vfxstate.fade
			self.timecomplete = time_game + math.min(1.0, fadelength)
			vfxmanager_addvfxupdate(self)
		else
			self:destroy()
		end
	end
end

function _vfxclass:delaystop(length)
	self.timecomplete = time_game + length
	self.state = vfxstate.freestop
	vfxmanager_addvfxupdate(self)
end

function _vfxclass:stop()
	self.alive = false
	if self.id ~= nil then
		return math.min(5.0, c_actor_vfxstop(self.id, 1.0))
	else
		return 0
	end
end

function _vfxclass:destroy()
	self.alive = false
	if self.id ~= nil then
		c_actor_destroy(self.id)
	end
end

function _vfxclass:getdelay()
	self.alive = false
	if self.id ~= nil then
		return c_actor_vfxdelay(self.id)
	else
		return 0
	end
end

function _vfxclass:getloop()
	return c_actor_vfxloop(self.id) > 0
end

function _vfxclass:restart()
	c_actor_vfxrestart(self.id)
end

function _vfxclass:update()
	if self.state == vfxstate.freerequest then
		local length = self:getdelay()
		if length >= 0.0 then
			length = math.min(length, 10)
			self.timecomplete = time_game + length + 0.5
			self.state = vfxstate.freedelay
		end
	elseif self.state == vfxstate.freedelay then
		if self.timecomplete < time_game then
			local length = self:stop()
			length = math.min(length, 10)
			self.timecomplete = time_game + length
			self.state = vfxstate.freestop
		end
	elseif self.state == vfxstate.freestop then
		if self.timecomplete < time_game then
			self:destroy()
			return false
		end
	elseif self.state == vfxstate.fade then
		if self.timecomplete < time_game then
			self:destroy()
			return false
		end
	end
	return true
end
