
_fxcclass = _class("_fxcclass")

function _fxcclass:createbindfxc(actor, vfxarray, bind, file)
	local bonegroup = nil
	if bind ~= nil and actor.actordata.skillbone ~= nil then
		bonegroup = actor.actordata.skillbone[bind]
	end
	if bonegroup ~= nil and #bonegroup > 0 then
		local maxcount = math.min(2, #bonegroup)
		for i=1, maxcount do
			local vfx = vfxcreatefromfile(file)
			vfx.bind = bonegroup[i]
			vfxarray[#vfxarray + 1] = vfx
		end
	else
		local vfx = vfxcreatefromfile(file)
		vfx.bind = bind
		vfxarray[#vfxarray + 1] = vfx
	end
end

function _fxcclass:applyflag(actor, fxc)
	local free = bit.band(fxc.flag, vfxflag.free) > 0
	local vampiric = bit.band(fxc.flag, vfxflag.vampiric) > 0
	local linktarget = bit.band(fxc.flag, vfxflag.linktarget) > 0
	for i=1, #fxc.vfxarray do
		local vfx = fxc.vfxarray[i]
		vfx:setbind(actor, vfx.bind, fxc.flag, fxc.attackerid)
		if vampiric and (fxc.attackerid ~= 0 or fxc.targetid ~= 0) then
			vfx:setvampiric(fxc.attackerid, fxc.targetid)
		elseif linktarget and fxc.targetid ~= 0 then
			--vfx:setlinktarget(fxc.targetid)
		end
		if free then
			vfx:setfree()
		end
	end
end

function _fxcclass:initfxc(fxname, actor, fxbind, flag, attackerid, targetid)
	self.fxcarray = {}
	if string.startwith(fxname, "fc_") then
		local skillfxc = csvskillfxc_getfromname(fxname)
		if skillfxc ~= nil then
			for i=1, #skillfxc do
				local fxc = {}
				fxc.node = skillfxc[i]
				fxc.timestart = time_game + fxc.node.delay
				fxc.actorid = actor.actorid
				fxc.attackerid = attackerid
				fxc.targetid = targetid
				fxc.fxbind = fxbind
				fxc.flag = flag
				fxc.vfxarray = {}
				self.fxcarray[#self.fxcarray + 1] = fxc
			end
		end
	else
		local fxc = {}
		fxc.flag = flag
		fxc.attackerid = attackerid
		fxc.targetid = targetid
		fxc.vfxarray = {}
		if fxbind ~= nil then
			self:createbindfxc(actor, fxc.vfxarray, fxbind, fxname)
		else
			fxc.vfxarray[#fxc.vfxarray + 1] = vfxcreatefromfile(fxname)
		end
		self:applyflag(actor, fxc)
		self.fxcarray[#self.fxcarray + 1] = fxc
	end
end

function _fxcclass:createfxc(fxc)
	local actor = actormanager_getfromactorid(fxc.actorid)
	local node = fxc.node
	if node.particle ~= nil then
		if node.bind ~= nil then
			if actor ~= nil then
				self:createbindfxc(actor, fxc.vfxarray, node.bind, node.particle)
			end
		elseif fxc.fxbind ~= nil then
			if actor ~= nil then
				self:createbindfxc(actor, fxc.vfxarray, node.fxbind, node.particle)
			end
		else
			fxc.vfxarray[#fxc.vfxarray + 1] = vfxcreatefromfile(node.particle)
		end
	end
	self:applyflag(actor, fxc)
	if node.shaketime ~= nil and gamesetting_getnumber("CAMERASHAKE") > 0 then
		if fxc.attackerid == playerattr_info.actorid or fxc.targetid == playerattr_info.actorid then
			maincamera_shake(node.shaketime)
		end
	end
end

function _fxcclass:reload()
	if self.fxcarray == nil then
		return
	end
	for i=1,#self.fxcarray do
		local fxc = self.fxcarray[i]
		for j=1,#fxc.vfxarray do
			local vfx = fxc.vfxarray[j]
			vfx:createactor()
		end
	end
end

function _fxcclass:updatefxc(fxc)
	for i=#fxc.vfxarray,1,-1 do
		local vfx = fxc.vfxarray[i]
		if not vfx:update() then
			table.remove(fxc.vfxarray, i)
		end
	end
end

function _fxcclass:update()
	if self.fxcarray == nil then
		return false
	end
	for i=#self.fxcarray,1,-1 do
		local fxc = self.fxcarray[i]
		if fxc.timestart ~= nil then
			if fxc.timestart <= time_game then
				fxc.timestart = nil
				self:createfxc(fxc)
			end
		else
			self:updatefxc(fxc)
			if #fxc.vfxarray == 0 then
				table.remove(self.fxcarray, i)
			end
		end
	end
	return #self.fxcarray > 0
end

function _fxcclass:setposition(x, y, z)
	if self.fxcarray ~= nil then
		for i=1,#self.fxcarray do
			local fxc = self.fxcarray[i]
			for j=1,#fxc.vfxarray do
				local vfx = fxc.vfxarray[j]
				vfx:setposition(x, y, z)
			end
		end
		self.fxcarray = nil
	end
end

function _fxcclass:setammo(actor, target_x, target_y, target_z, t, type)
	if self.fxcarray == nil then
		return
	end
	for i=1,#self.fxcarray do
		local fxc = self.fxcarray[i]
		for j=1,#fxc.vfxarray do
			local vfx = fxc.vfxarray[j]
			if vfx.start_x == nil then
				vfx.start_x = actor.transform.px
				vfx.start_y = actor.transform.py
				vfx.start_z = actor.transform.pz
				local bindname = nil
				if fxc.node ~= nil and fxc.node.bind ~= nil then
					bindname, vfx.start_x, vfx.start_y, vfx.start_z = actor:getvfxbindname(fxc.node.bind)
				elseif fxc.fxbind ~= nil then
					bindname, vfx.start_x, vfx.start_y, vfx.start_z = actor:getvfxbindname(fxc.fxbind)
				elseif vfx.bind ~= nil then
					bindname, vfx.start_x, vfx.start_y, vfx.start_z = actor:getvfxbindname(vfx.bind)
				end
			end
			local px = math.lerp(vfx.start_x, target_x, t)
			local py = math.lerp(vfx.start_y, target_y, t)
			local pz = math.lerp(vfx.start_z, target_z, t)
			if type == 1 then
				local dist = vector2_distance(vfx.start_x, vfx.start_z, target_x, target_z)
				local height = math.min(3.0, dist * 0.1)
				local parabola = height * (1 - (2 * t - 1) * (2 * t - 1))
				py = py + parabola
			end
			local dx, dy, dz = vector3_normalize(target_x - vfx.start_x, target_y - vfx.start_y, target_z - vfx.start_z)
			local rx, ry, rz = vector3_fromtovector(0.0, 0.0, 1.0, -dx, -dy, -dz)
			vfx:setposition(px, py, pz)
			vfx:setrotation(rx, ry, rz)
		end
	end
end

function _fxcclass:setfade()
	if self.fxcarray ~= nil then
		for i=1,#self.fxcarray do
			local fxc = self.fxcarray[i]
			for j=1,#fxc.vfxarray do
				local vfx = fxc.vfxarray[j]
				vfx:setfade()
			end
		end
		self.fxcarray = nil
	end
end

function _fxcclass:destroy()
	if self.fxcarray ~= nil then
		for i=1,#self.fxcarray do
			local fxc = self.fxcarray[i]
			for j=1,#fxc.vfxarray do
				local vfx = fxc.vfxarray[j]
				vfx:destroy()
			end
		end
		self.fxcarray = nil
	end
end
