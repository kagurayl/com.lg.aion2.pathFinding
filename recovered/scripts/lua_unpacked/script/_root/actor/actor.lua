
_actorclass = _class("_actorclass")

function _actorclass:initactor(renderlayer)
	self.actorflag = 0
	self.visible = true
	self.actionmain = {}
	self.actionadditive = {}
	self.actordata = {}
	self.actordata.nameheight = 0
	self.actordata.cameraheight = 1.5
	self.battle = {}
	self.battleinst = {}
	self.battleammo = {}
	self.battlehitvfx = {}
	self.battleprehitvfx = {}
	self.battleprehitpoint = {}
	self.battleprebuff = {}
	self.move = {}
	self.attrdisplay = {}
	self.renderlayer = renderlayer
end

function _actorclass:createactor(flag, debugname)
	if self.id ~= nil then
		c_actor_destroy(self.id)
	end
	self.id = csvconfig_generatescriptid()
	c_actor_create(self.id, self.transform.px, self.transform.py, self.transform.pz
	, self.transform.rx, self.transform.ry, self.transform.rz
	, self.transform.sx, self.transform.sy, self.transform.sz, self.renderlayer, flag, debugname)
	if self.visible ~= nil and not self.visible then
		c_actor_setvisible(self.id, false)
	end
end

function _actorclass:destroyactor()
	self:clearanimmesh()
	self:clearvfx()
	if self:isstaticnpc() then
		entitymanager_setactorvisible(self.config_npcstatic.staticid, 0)
		actormanager_removeentity(self.config_npcstatic.staticid)
	else
		if self.id ~= nil then
			self:destroysubactor()
			self:destroyadditive()
			c_actor_destroy(self.id)
			self.id = nil
		end
	end
end

function _actorclass:createplayeractor()
	if self:isstaticnpc() then
		actormanager_removedisappearentity(self.config_npcstatic.staticid)
		self:loadboundbox()
		self:updatequestvfx()
		entitymanager_setactorvisible(self.config_npcstatic.staticid, self.actorstaticmesh)
	else
		local flag = actorrenderflag.elevator
		local debugname = self.attr.name
		if self:isnpc() then
			debugname = string.format("%s_%d", self.attr.name, self.config_npc.id)
		end
		if self:isdynamicnpc() then
			flag = bit.bor(flag, actorrenderflag.bakemesh)
		end
		self:createactor(flag, debugname)
		self:loadboundbox()
		self:setactorposition(self.attr.posx, self.attr.posy, self.attr.posz, self.attr.rot)
	end
	if self.attr.stalladvert ~= nil and #self.attr.stalladvert > 0 then
		self:createstall(self.attr.stalladvert)
	end
end

function _actorclass:setactorvisible(visible)
	if self.visible ~= visible then
		self.visible = visible
		c_actor_setvisible(self.id, visible)
	end
end

function _actorclass:isvisible()
	return self.visible == nil or self.visible
end

function _actorclass:setflag(addflag, removeflag)
	self.actorflag = bit.bor(self.actorflag, addflag)
	self.actorflag = bit.band(self.actorflag, bit.bnot(removeflag))
	c_actor_setflag(self.id, addflag, removeflag)
end

function _actorclass:setboundbox(cx, cy, cz, sx, sy, sz)
	c_actor_setboundbox(self.id, cx, cy, cz, sx, sy, sz)
	self:setboundboxsize(cx, cy, cz, sx, sy, sz)
end

function _actorclass:setboundboxsize(cx, cy, cz, sx, sy, sz)
	self.boundboxtalksize = math.max(sx, sz) / 2
	self.boundboxsensorysize = math.min(sx, sz) / 2
end

function _actorclass:movedirect(vx, vy, vz, slide)
	local slideangle = math.ternary(slide, 45.0, 0)
	local state, x, y, z, dx, dy, dz, physicmaterial = c_actor_movedirect(self.id, vx, vy, vz, slideangle)
	self.transform.sliding = false
	if state ~= nil then
		self.transform.px = x
		self.transform.py = y
		self.transform.pz = z
		self.transform.onfloor = bit.band(state, ColliderHit) > 0
		self.transform.sliding = bit.band(state, ColliderSlide) > 0
		self.transform.physicmaterial = physicmaterial
	end
	self.attr.posx = self.transform.px
	self.attr.posy = self.transform.py
	self.attr.posz = self.transform.pz
	self.attr.rot = self.transform.ry
end

function _actorclass:movecapsule(vx, vy, vz)
	local radius = 0.4
	local offsety = 1.5
	local state, px, py, pz, physicmaterial = c_actor_movecapsule(self.id, maskcollider, self.attr.posx, self.attr.posy, self.attr.posz, vx, vy, vz, radius, offsety)
	self:setposition(px, py, pz)
	self.attr.posx = px
	self.attr.posy = py
	self.attr.posz = pz
	self.transform.onfloor = bit.band(state, ColliderHit) > 0
	self.transform.physicmaterial = physicmaterial
end

function _actorclass:settransform(px, py, pz, rx, ry, rz, sx, sy, sz)
	if self.transform == nil then
		self.transform = {}
	end
	self.transform.px = px
	self.transform.py = py
	self.transform.pz = pz
	self.transform.rx = rx
	self.transform.ry = ry
	self.transform.rz = rz
	self.transform.sx = sx
	self.transform.sy = sy
	self.transform.sz = sz
	self.transform.onfloor = false
	self.transform.sliding = false
end

function _actorclass:setposition(x, y, z)
	self.transform.px = x
	self.transform.py = y
	self.transform.pz = z
	c_actor_setpositon(self.id, x, y, z)
end

function _actorclass:setrotation(x, y, z)
	self.transform.rx = x
	self.transform.ry = y
	self.transform.rz = z
	c_actor_setrotation(self.id, x, y, z)
end

function _actorclass:setscale(x, y, z)
	self.transform.sx = x
	self.transform.sy = y
	self.transform.sz = z
	c_actor_setscale(self.id, x,y,z)
end

function _actorclass:setpositionrotation(px, py, pz, rx, ry, rz)
	self.transform.px = px
	self.transform.py = py
	self.transform.pz = pz
	self.transform.rx = rx
	self.transform.ry = ry
	self.transform.rz = rz
	c_actor_setposrot(self.id, px, py, pz, rx, ry, rz)
end

function _actorclass:setlookrotation(look_x, look_y, look_z)
	local dx, dy = vector2_normalize(look_x - self.transform.px, look_z - self.transform.pz)
	self.transform.ry = vector2_angle3d(dx, dy)
	c_actor_setrotation(self.id, self.transform.rx, self.transform.ry, self.transform.rz)
end

function _actorclass:setsubposition(nodename, worldspace, px, py, pz)
	c_actor_setsubposition(self.id, nodename, worldspace, px, py, pz)
end

function _actorclass:setsubrotation(nodename, worldspace, rx, ry, rz)
	c_actor_setsubrotation(self.id, nodename, worldspace, rx, ry, rz)
end

function _actorclass:setsubscale(nodename, worldspace, sx, sy, sz)
	c_actor_setsubscale(self.id, nodename, worldspace, sx, sy, sz)
end

function _actorclass:setsubposrot(nodename, worldspace, px, py, pz, rx, ry, rz)
	c_actor_setsubposrot(self.id, nodename, worldspace, px, py, pz, rx, ry, rz)
end

function _actorclass:getsubtransform(nodename, worldspace)
	local px,py,pz,rx,ry,rz,sx,sy,sz = c_actor_getsubtransform(self.id, nodename, worldspace)
	if px ~= nil then
		return px,py,pz,rx,ry,rz,sx,sy,sz,true
	else
		return self.transform.px,self.transform.py,self.transform.pz,self.transform.rx,self.transform.ry,self.transform.rz,self.transform.sx,self.transform.sy,self.transform.sz,false
	end
end

function _actorclass:gethitpoint()
	local target_x,target_y,target_z,rx,ry,rz,sx,sy,sz,success = self:getsubtransform("fx_hit", true)
	if not success then
		target_x = self.transform.px
		target_y = self.transform.py + 1.5
		target_z = self.transform.pz
	end
	return target_x,target_y,target_z
end

function _actorclass:getbonetransform(bonename, worldspace)
	local px,py,pz,rx,ry,rz,sx,sy,sz = c_actor_getbonetransform(self.id, bonename, worldspace)
	if px ~= nil then
		return px,py,pz,rx,ry,rz,sx,sy,sz,true
	else
		return self.transform.px,self.transform.py,self.transform.pz,self.transform.rx,self.transform.ry,self.transform.rz,self.transform.sx,self.transform.sy,self.transform.sz,false
	end
end

function _actorclass:transformpoint(px, py, pz)
	local t = self.transform
	return c_math_transformpoint(t.px, t.py, t.pz, t.rx, t.ry, t.rz, t.sx, t.sy, t.sz, px, py, pz)
end

function _actorclass:getdirection2d()
	return vector2_normalize(vector2_rotatestandard3d(self.transform.ry))
end

function _actorclass:getdirection()
	return vector3_angletovector(self.transform.rx, self.transform.ry, self.transform.rz)
end
