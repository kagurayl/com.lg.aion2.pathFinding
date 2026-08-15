
local petactionname =
{
	none = 0,
	spawn = 1,
	idle = 2,
	move = 3,
	play = 4,
}
local m_pet_distance_movetoidle = 1
local m_pet_distance_idletomove = 2
local m_pet_distance_movetoactor = 10

function _actorclass:initpet()
	self.pet = {}
	self.pet.config_pet = csvpet_getfromid(self.attr.petid)
	self.pet.petaction = petactionname.none
	self:loadpetasset()
end

function _actorclass:onclickpet()
	if self.pet.config_pet ~= nil and playerattr_info.petuuid ~= 0 then
		pet_menu_open(playerattr_info.petuuid)
	end
end

function _actorclass:playpet(socialid, critical)
	if self.petactor == nil then
		return
	end
	local animrand = "basic"
	local rand = math.random() * 100
	if critical then
		animrand = "critical"
	elseif rand > 80 then
		animrand = "d"
	elseif rand > 60 then
		animrand = "c"
	elseif rand > 40 then
		animrand = "b"
	elseif rand > 20 then
		animrand = "a"
	end
	local animname = "praise"
	if socialid == 121 then
		animname = "play"
	elseif socialid == 122 then
		animname = "care"
	elseif socialid == 123 then
		animname = "train"
	end
	local animfull = string.format("nreact_%s_%s_001", animname, animrand)
	local alias = self.petactor:playanim(animfull)
	if alias ~= nil then
		self.pet.petaction = petactionname.play
        self.pet.actioncomplete = time_game + alias.length
    end
end

function _actorclass:updatepetname()

end

function _actorclass:updatepetid()
	if self.pet.petloaded ~= nil and self.pet.petloaded ~= self.attr.petid then
		self:unloadpetasset()
	end
	self.pet.config_pet = csvpet_getfromid(self.attr.petid)
	self:loadpetasset()
end

function _actorclass:unloadpetasset()
	if self.petactor ~= nil then
		self.petactor:destroyactor()
		self.petactor = nil
	end
	if self.pet ~= nil then
		self.pet.petloaded = nil
	end
end

function _actorclass:loadpetasset()
	if self.pet.config_pet == nil then
		self:unloadpetasset()
		return
	end
	if not self.actordata.assetloaded or self.pet.petloaded ~= nil then
		return
	end
	self.pet.petloaded = self.attr.petid
	self.pet.petaction = petactionname.none
	self.pet.enemyalarm = 0
	if self:isme() then
		self:loadpet(RenderLayerNPC, self.pet.config_pet.mesh)
	else
		self:loadpet(RenderLayerPlayerIgnoreCollision, self.pet.config_pet.mesh)
	end
	local cx, cy, cz, sx, sy, sz = csvnpc_getboundbox(self.pet.config_pet.bound, self.pet.config_pet.scale)
	if sx > 0 or sy > 0 or sz > 0 then
		self.petactor:setboundbox(cx, cy, cz, sx, sy, sz)
	end
	if self.actordata.opacity ~= nil then
		self.petactor:setopacity(self.actordata.opacity)
	end
end

function _actorclass:updatepet_none()
	if self.petactor == nil then
		return
	end
	self.pet.petaction = petactionname.spawn
	local alias = self.petactor:playanim("nspawn_001")
	if alias ~= nil then
        self.pet.actioncomplete = time_game + alias.length
    else
        self.pet.actioncomplete = 0
    end
end

function _actorclass:updatepet_playalarmanim()
	local flag = actorrenderflag.loopanim
	if self.pet.enemyalarm > 0 then
		self.petactor:playanim("nalarm_001", flag)
	elseif self.pet.petaction == petactionname.move then
		if gamesetting_getnumber("PETAUDIO") == 0 then
			flag = bit.bor(flag, actorrenderflag.disablealiasaudio)
		end
		self.petactor:playanim("nrun_001", flag)
	else
		if gamesetting_getnumber("PETAUDIO") == 0 then
			flag = bit.bor(flag, actorrenderflag.disablealiasaudio)
		end
		self.petactor:playanim("nidle_001", flag)		
	end
end

function _actorclass:updatepet_spawn()
	if self.pet.actioncomplete < time_game then
		self.pet.petaction = petactionname.idle
		self:updatepet_playalarmanim()
	end
end

function _actorclass:updatepet_idle(updatealerm)
	local pt = self.petactor.transform
	local at = self.transform
	local dist = vector3_distance(pt.px, pt.py, pt.pz, at.px, at.py, at.pz)
	if dist > m_pet_distance_idletomove then
		self.pet.petaction = petactionname.move
		self:updatepet_playalarmanim()
	elseif updatealerm then
		self:updatepet_playalarmanim()
	end
end

function _actorclass:updatepet_move(updatealerm)
	local pt = self.petactor.transform
	local at = self.transform
	local dist = vector3_distance(pt.px, pt.py, pt.pz, at.px, at.py, at.pz)
	if dist < m_pet_distance_movetoidle then
		self.pet.petaction = petactionname.idle
		self:updatepet_playalarmanim()
		return
	end
	if updatealerm then
		self:updatepet_playalarmanim()
	end
	if dist > m_pet_distance_movetoactor then
		self.petactor:setposition(at.px, at.py, at.pz)
		return
	end
	local dx, dy, dz = vector3_normalize(at.px - pt.px, at.py - pt.py, at.pz - pt.pz)
	local movedist = self:getplayermovespeed() * time_frame
	local x = pt.px + dx * movedist
	local y = pt.py + dy * movedist
	local z = pt.pz + dz * movedist
	local pickx, picky, pickz = c_scene_pickscene(maskcollider, x, y + 1, z, 0, -1, 0, 5, false)
	if pickx ~= nil then
		y = picky
	end
	self.petactor:setposition(x, y, z)
	self.petactor:setlookrotation(at.px, at.py, at.pz)
end

function _actorclass:updatepet_play()
	if self.pet.actioncomplete < time_game then
		self.pet.petaction = petactionname.idle
		self:updatepet_playalarmanim()
	end
end

function _actorclass:updatepet()
	if self.pet.config_pet == nil or self.petactor == nil then
		return
	end
	local enemyalarm = 0
	if self:isme() and self.pet.config_pet.enemyalarm > 0 then
		local actorlist = actormanager_getactorlist()
		for key, actor in pairs(actorlist) do
			if actor:isplayer() and actor:isenemy() then
				enemyalarm = 1
				break
			end
		end
	end

	local updatealerm = false
	if self.pet.enemyalarm == nil or self.pet.enemyalarm ~= enemyalarm then
		self.pet.enemyalarm = enemyalarm
		updatealerm = true
		if enemyalarm > 0 then
			if self.pet.enemyalarmtime == nil or time_game - self.pet.enemyalarmtime > 10.0 then
				self.pet.enemyalarmtime = time_game
				local vfx = vfxmanager_createvfx(EffectPetAlarm)
				vfx:setbind(self.petactor, "fx_h01", vfxflag.bindposition)
				vfx:delaystop(1.5)
			end
		end
	end
	if self.pet.petaction == petactionname.none then
		self:updatepet_none()
	elseif self.pet.petaction == petactionname.spawn then
		self:updatepet_spawn()
	elseif self.pet.petaction == petactionname.idle then
		self:updatepet_idle(updatealerm)
	elseif self.pet.petaction == petactionname.move then
		self:updatepet_move(updatealerm)
	elseif self.pet.petaction == petactionname.play then
		self:updatepet_play()
	end
	self.petactor:updateanim()
end
