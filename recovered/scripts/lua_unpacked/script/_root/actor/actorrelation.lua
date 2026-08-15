
function _actorclass:isme()
	return self.actorid == playerattr_info.actorid
end

function _actorclass:overlayable(attackerid, pointtype)
    if self:isme() or self:ismyspirit() or playerattr_info.actorid == attackerid or playerattr_info.spiritid == attackerid then
        return true
    end
    local attackeractor = actormanager_getfromactorid(attackerid)
    if attackeractor ~= nil then
        if attackeractor:ismyspirit() then
            if pointtype ~= nil and pointtype == lambdapointtype.hpdec then
                return true
            end
        end
    end
    return false
end

function _actorclass:ismyspirit()
	return self.attr.spiritowner == playerattr_info.actorid
end

function _actorclass:isteam()
	return playerpal_getmatefromplayerid(self.actorid) ~= nil
end

function _actorclass:israid()
	return playerpal_getraidmatefromplayerid(self.actorid) ~= nil
end

function _actorclass:israidteam()
    local mate1 = playerpal_getraidmatefromplayerid(self.actorid)
    local mate2 = playerpal_getraidmatefromplayerid(playerattr_info.actorid)
    if mate1 ~= nil and mate2 ~= nil then
        local team1 = math.tointegerfloor(mate1.index / 6)
        local team2 = math.tointegerfloor(mate2.index / 6)
        return team1 == team2
    end
	return false
end

function _actorclass:isflock()
	return playerpal_getraidmatefromplayerid(self.actorid) ~= nil
end

function _actorclass:isiccmember()
	return false
end

function _actorclass:isplayer()
	return self.actortype == actorgametype.player
end

function _actorclass:isnpc()
	return self.actortype == actorgametype.npc or self.actortype == actorgametype.staticnpc or self.actortype == actorgametype.harvest
end

function _actorclass:isdynamicnpc()
    return self.actortype == actorgametype.npc
end

function _actorclass:isstaticnpc()
    return self.actortype == actorgametype.staticnpc
end

function _actorclass:isharvest()
    return self.actortype == actorgametype.harvest
end

function _actorclass:isspirit()
    return self.attr.spiritowner ~= 0
end

function _actorclass:isdead()
    if self:isplayer() then
        return self.attr.deadtime ~= nil
    elseif self:isdynamicnpc() or self:isstaticnpc() then
        return self.attr.isdead > 0
    else
        return false
    end
end

function _actorclass:isenemy()
    if self:isnpc() then
        if self.attr.spiritowner ~= nil and self.attr.spiritowner == playerattr_info.forceenemy then
            return true
        end
        if self:isdynamicnpc() or self:isstaticnpc() then
            if csvnpctribe_isnpcenemy(self.config_npc) then
                return true
            end
        end
    else
        if not self:isme() and playerattr_info.forceenemy == self.actorid then
            return true
        end
        if self:isteam() or self:israid() then
            return false
        end
        if self.attr.civ ~= playerattr_info.civ then
            return true
        end
        if playerattr_info.areapvp > 0 and self.attr.areapvp > 0 then
            return true
        end
    end
	return false
end

function _actorclass:attackable()
    if self:isdynamicnpc() or self:isstaticnpc() then
        local attackable = csvnpc_getattackable(self.config_npc)
        if attackable == nil or not attackable then
            return false
        end
    end
	return true
end

function _actorclass:getheadicon()
    if self:isplayer() then
        return playercareericon[self.attr.career]
    elseif self:isdynamicnpc() or self:isstaticnpc() then
        local icon = csvnpc_getheadicon(self.config_npc)
        if csvnpctribe_isaggressive(self.config_npc) then
            return string.format("emblem/icon_emblem_%s_a", icon)
        else
            return string.format("emblem/icon_emblem_%s", icon)
        end
    else
        return "emblem/icon_emblem_etc"
    end
end

function _actorclass:setbattle(battle, equipanim)
    if battle == 0 and self.actionmain.config_buffaction ~= nil and self.actionmain.config_buffaction.buffaction == buffactiontype.stance then
        battle = 1
    end
    if self.battle.battlestate ~= battle then
        self.battle.battlestate = battle
        local alias = nil 
        if equipanim then
            if self:isplayer() then
                if self.attr.movetype == playermovestate.move then
                    if self.actionmain.action ~= nil and self.actionmain.action.actionid == actionname.move then
                        alias = self:getanimalias(self:getanimlistname(animlist.weaponmove))
                        self.actionadditive.request = actionname.equipweapon
                    else
                        alias = self:getanimalias(self:getanimlistname(animlist.weapon))
                    end
                end
            else
                if battle == 0 and self.attr.npcstate == npcsyncstate.idle then
                    alias = self:getanimalias(self:getanimlistname(animlist.weapon))
                end
            end
        end
        if alias ~= nil and alias.marker ~= nil and alias.marker.equipweapon ~= nil then
            self.battle.battlestatebindtime = time_game + alias.marker.equipweapon
            self.battle.battlestatebindanim = time_game + alias.length
        else
            self.battle.battlestatebindtime = nil
            self:updatebattlemesh(battle > 0)
        end
        self:updatesubbind()
    end
    if battle > 0 then
        self.battle.battlestatetimeout = time_game + 40.0
    end
end

function _actorclass:setskillbattle(config_skill)
    if csvskill_isattackskill(config_skill) then
        self:setbattle(1, false)
        if self:isme() then
            playerbattle_updatebattlestate()
        end
    end
end

function _actorclass:getbattle()
    if self.battle.battlestate ~= nil and self.battle.battlestate > 0 then
        return true
    end
    return false
end

function _actorclass:getattackanimspeed()
    return 1.0 / self.attr.attackspeed
end

function _actorclass:getglidespeed()
    if self.attr.movewindleavetime ~= nil and self.attr.movewinddashspeed ~= nil then
        local time = time_game - self.attr.movewindleavetime
        if time < 1.0 then
            return math.lerp(self.attr.movewinddashspeed, self.attr.flyspeed, time)
        end
    end
    return self.attr.flyspeed
end

function _actorclass:getfly()
    if self:isplayer() then
        return self.attr.movetype == playermovestate.fly
    else
        return self.attr.aerial == 1
    end
end

function _actorclass:movable()
    if self.actionmain.movabletime ~= nil and self.actionmain.movabletime > time_game then
		return false
	end
    if self.attr.stalladvert ~= nil and #self.attr.stalladvert > 0 then
        return false
    end
    return self.actionmain.buffmoveable
end

function _actorclass:getplayermovespeed()
    if self:isplayer() then
        if self.attr.movetype == playermovestate.fly or self.attr.movetype == playermovestate.glide then
            return self.attr.flyspeed
        else
            return self.attr.movespeed
        end
    end
    return 0.0
end

function _actorclass:getidleanim()
    if self:getfly() then
        return animlist.fidle
    elseif self.actionmain.buffdeform ~= nil then
        return animlist.npcidle
    elseif self.actionmain.buffhidelevel ~= nil and self.actionmain.buffhidelevel > 0 then
        return animlist.hideidle
    elseif self.attr.animidlekey == nil then
        return animlist.nidle
    else
        local animname = self:getanimlistname(self.attr.animidlekey)
        if animname ~= nil and self:getanimalias(animname) ~= nil then
            return self.attr.animidlekey
        else
            return animlist.nidle
        end
    end
end

function _actorclass:gettalkdist(dist)
	if self.boundboxtalksize ~= nil then
		dist = dist + self.boundboxtalksize
	end
    return dist
end

function _actorclass:autoselectable(flag)
    if self.actorid == playerattr_info.actorid or self.actorid == playerattr_info.spiritid or self.actorid == m_selectactorid then
        return false
    end
    if self:isdynamicnpc() and self.config_npc.hidenpc > 0 then
        return false
    end
    if self:isharvest() then
        return bit.band(flag, actorautoselect.harvest) ~= 0
    end
    if self:isenemy() then
        if self:isplayer() then
            if not self:isdead() then
                return bit.band(flag, actorautoselect.enemyplayer) ~= 0
            end
        else
            if self:isdead() then
                return bit.band(flag, actorautoselect.enemynpcdead) ~= 0
            else
                return bit.band(flag, actorautoselect.enemynpc) ~= 0
            end
        end
    else
        if self:isplayer() then
            if self:isdead() then
                return bit.band(flag, actorautoselect.sipidplayerdead) ~= 0
            else
                return bit.band(flag, actorautoselect.sipidplayer) ~= 0
            end
            return bit.band(flag, actorautoselect.sipidplayer) ~= 0
        else
            return bit.band(flag, actorautoselect.sipidnpc) ~= 0
        end
    end
    return false
end
