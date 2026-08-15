
function _actorclass:resetaction()
	self.actordata.wingactionvisible = self.attr.movetype == playermovestate.glide or self.attr.movetype == playermovestate.fly
end

function _actorclass:clearspell()
	self.actionmain.spelltype = nil
end

function _actorclass:clearsequence()
	self.actordata.sequencewingvisible = false
end

function _actorclass:updateaudiofootbone(footup, bonename)
	if footup == nil then
        footup = false
    end
    local px,py,pz,rx,ry,rz,sx,sy,sz,success = self:getsubtransform(bonename, true)
    if not success then
        return false
    end
	local floorheight = scene_getfloorheight(px, py, pz, 0)
    local offset = py - floorheight
    if offset > 0.1 then
        return true
    end
    if offset < 0.05 and footup and self.transform.physicmaterial ~= nil then
        self:addeventfx("walk", px, py, pz)
        footup = false
    end
    return footup
end

function _actorclass:updatewalkaudio()
	if self.transform.onfloor then
		self.actionmain.leftfootup = self:updateaudiofootbone(self.actionmain.leftfootup, "bip01 l toe0")
		self.actionmain.rightfootup = self:updateaudiofootbone(self.actionmain.rightfootup, "bip01 r toe0")
	else
		self.actionmain.leftfootup = true
		self.actionmain.rightfootup = true
	end
end

function _actorclass:updatejumpaudio()
    self:addeventfx("jump", self.transform.px, self.transform.py, self.transform.pz)
end

function _actorclass:addeventfx(evtname, px, py, pz)
    local audio = nil
    local foottex = nil
    local footfx = nil
    local config_map = scene_getmapconfig()
    if config_map ~= nil and self.attr.posy < config_map.waterlevel then
        audio = "mat_water"
    elseif self.transform.physicmaterial ~= nil then
        local config_physicmaterial = c_config_getmetaid(configid.render_physicmaterial, self.transform.physicmaterial)
        if config_physicmaterial ~= nil then
            audio = config_physicmaterial.name
            foottex = config_physicmaterial.foottex
            footfx = config_physicmaterial.footfx
        end
    end
    self:playeventaudio(evtname, audiochanneltype.envsfx, self.attr.matfoot, audio, px, py, pz)
    if self:isme() then
        if footfx ~= nil and footfx ~= "0" then
            local vfx = vfxmanager_createvfx(footfx)
			vfx:setposition(px, py, pz)
			vfx:setrotation(0, self.transform.ry, 0)
			vfx:setfree()
        end
    end
end

function _actorclass:playhitaudio(attackerid, accuracy)
    local attacker = actormanager_getfromactorid(attackerid)
    if attacker == nil then
        return
    end
    local eventname = nil
    if accuracy == lambdaaccuracytype.crit then
        eventname = "critical"
    elseif accuracy == lambdaaccuracytype.dodge then
        eventname = "dodge"
    elseif accuracy == lambdaaccuracytype.parry then
        eventname = "parry"
    elseif accuracy == lambdaaccuracytype.block then
        eventname = "block"
    elseif accuracy == lambdaaccuracytype.normal then
        eventname = "hit"
    end
    if eventname ~= nil then
        local at = self.transform
        self:playeventaudio(eventname, audiochanneltype.skill, attacker.attr.matweapon, self.attr.matdamage, at.px, at.py, at.pz)
    end
end

function _actorclass:playeventaudio(evtname, channeltype, srcname, dstname, x, y, z)
    local evt = csvaudio_getevent(evtname)
    if evt == nil then
        return
    end
    if srcname == nil then
        srcname = "mat_default"
    end
    local src = evt[srcname]
    if src == nil then
        return
    end
    if dstname == nil then
        dstname = "mat_default"
    end
    local dst = src[dstname]
    if dst == nil then
        return
    end
    local file = dst[1]
    if #dst > 1 then
        local prob = math.random() * 100 - file.prob
        if prob > 0 then
            for i=2,#dst do
                local file2 = dst[i]
                prob = prob - file2.prob
                if prob <= 0 then
                    file = file2
                    break
                end
            end
        end
    end
    csvasset_preload(file.file.filename)
    if self:isme() then
        audiomanager_playaudio2d(file.file.filename, channeltype, audiopriority.high)
    else
        audiomanager_playaudio3d(file.file.filename, 0, x, y, z, 1.0, 5.0, 25.0, channeltype, audiopriority.high)
    end
end

function _actorclass:getcgvoice()
    if self.attr.civ == playerciv.light then
        if self.attr.sex == playersex.male then
            return 0
        else
            return 1
        end
    else
        if self.attr.sex == playersex.male then
            return 2
        else
            return 3
        end
    end
end
