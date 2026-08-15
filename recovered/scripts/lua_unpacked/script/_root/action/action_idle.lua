
local actionidlestate = 
{
    none = 0,
    spawn = 1,
    idle = 2,
    battleidle = 3,
    stanceidle = 4,
    hideidle = 5,
    flyidle = 6,
    flybattleidle = 7,
    reststart = 8,
    restloop = 9,
    reststand = 10,
    battleon = 11,
    battleoff = 12,
    alive = 13,
    stall = 14,
}

local actionidleflag = 
{
    loop = 0x1,
}

function action_idle_setstate(actor, state, anim, flag)
    actor.actionmain.actionstate = state
    local alias = actor:playanimlist(anim, bit.bor(flag, actorrenderflag.stopinvalidanim))
    if alias ~= nil and bit.band(flag, actorrenderflag.loopanim) == 0 then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

local function action_idle_getnpcanim(actor)
    if actor:getfly() then
        return animlist.fidle
    end
    if actor:getbattle() then
        return animlist.nidle
    end
    local animname = nil
    local lambda = csvnpc_getscript(actor.config_npc, "idle")
    if lambda ~= nil then
        animname = "n" .. lambda.variable[1].str
    else
        lambda = csvnpc_getscript(actor.config_npc, "rest")
        if lambda ~= nil then
            animname = "r" .. lambda.variable[1].str
            actor.actionmain.rot = 180.0
            actor:updateactorposition()
        end
    end
    if animname ~= nil then
        local anim = animlist["npcidle_" .. animname]
        if anim == nil then
            local fullanimname = animlist_getanim(animname, 0, nil, nil, nil, 1)
            local alias = actor:getanimalias(fullanimname)
            if alias == nil then
                return animlist.npcidle
            end
            animlist_addsimple("npcidle_" .. animname, animname, 0)
            anim = animlist["npcidle_" .. animname]
        end
        return anim
    else
        return animlist.npcidle
    end
end

local function action_idle_updatenpcstate(actor)
    if actor.attr.npcstate == npcsyncstate.spawn then
        if actor.actionmain.actionstate ~= actionidlestate.spawn then
            action_idle_setstate(actor, actionidlestate.spawn, animlist.npcspawn, 0)
            return
        end
        actor.attr.npcstate = npcsyncstate.idle
    end
    if actor:getbattle() then
        local idlestate = actionidlestate.battleidle
        if actor.actionmain.actionstate == idlestate then
            return
        end
        if actor.actionmain.actionstate == actionidlestate.idle then
            if actor.battle.battlestatebindanim ~= nil and actor.battle.battlestatebindanim > time_game then
                actor.battle.battlestatebindanim = nil
                action_idle_setstate(actor, actionidlestate.battleon, animlist.weapon, 0)
                return
            end
        end
        action_idle_setstate(actor, idlestate, action_idle_getnpcanim(actor), actorrenderflag.loopanim)
        return
    else
        local idlestate = actionidlestate.idle
        if actor.actionmain.actionstate == idlestate then
            return
        end
        if actor.actionmain.actionstate == actionidlestate.battleidle then
            if actor.battle.battlestatebindanim ~= nil and actor.battle.battlestatebindanim > time_game then
                actor.battle.battlestatebindanim = nil
                action_idle_setstate(actor, actionidlestate.battleoff, animlist.weapon, 0)
                return
            end
        end
        action_idle_setstate(actor, idlestate, action_idle_getnpcanim(actor), bit.bor(actorrenderflag.loopanim, actorrenderflag.randanim))
        return
    end
end

local function action_idle_getrestanim(actor, animname)
    if actor.attr.animrestkey == nil then
        return animlist[animname]
    else
        return actor.attr.animrestkey[animname]
    end
end

local function action_idle_updateplayerstate(actor)
    if actor.attr.alivetime ~= nil then
        if time_game - actor.attr.alivetime < 1.0 then
            if actor.attr.movetype == playermovestate.fly then
                action_idle_setstate(actor, actionidlestate.alive, animlist.falive, 0)
            else
                action_idle_setstate(actor, actionidlestate.alive, animlist.nalive, 0)
            end
            actor.actionmain.actioncomplete = actor.actionmain.actioncomplete - 0.5
            return
        end
        actor.attr.alivetime = nil
    end
    if actor.attr.movetype == playermovestate.rest then
        if actor.actionmain.actionstate == actionidlestate.battleidle then
            action_idle_setstate(actor, actionidlestate.battleoff, animlist.weapon, 0)
            return
        end
        if actor.actionmain.actionstate == actionidlestate.restloop then
            return
        end
        if actor.actionmain.actionstate ~= actionidlestate.reststart then
            action_idle_setstate(actor, actionidlestate.reststart, action_idle_getrestanim(actor, "rsit"), 0)
            return
        end
        action_idle_setstate(actor, actionidlestate.restloop, action_idle_getrestanim(actor, "ridle"), actorrenderflag.loopanim)
        return
    end
    if actor.actionmain.actionstate == actionidlestate.restloop then
        action_idle_setstate(actor, actionidlestate.reststand, action_idle_getrestanim(actor, "nstand"), 0)
        return
    end
    if actor.actionmain.config_buffaction ~= nil and actor.actionmain.config_buffaction.buffaction == buffactiontype.stance then
        if actor.actionmain.actionstate ~= actionidlestate.stanceidle then
            actor.actionmain.actionstate = actionidlestate.stanceidle
            actor:playanim("cidle_1hand_stance1_001")
        end
        return
    end
    if actor:getbattle() then
        local idlestate = actionidlestate.battleidle
        if actor.attr.movetype ~= playermovestate.fly then
            idlestate = actionidlestate.flybattleidle
        end	
        if actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
            idlestate = actionidlestate.hideidle
        end
        if actor.actionmain.actionstate == idlestate then
            return
        end
        if actor.actionmain.actionstate == actionidlestate.idle or actor.actionmain.actionstate == actionidlestate.flyidle then
            if actor.battle.battlestatebindanim ~= nil and actor.battle.battlestatebindanim > time_game then
                actor.battle.battlestatebindanim = nil
                action_idle_setstate(actor, actionidlestate.battleon, animlist.weapon, 0)
                return
            end
        end
        action_idle_setstate(actor, idlestate, actor:getidleanim(), actorrenderflag.loopanim)
        return
    else
        local idlestate = actionidlestate.idle
        if actor.attr.movetype == playermovestate.fly then
            idlestate = actionidlestate.flyidle
        end	
        if actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
            idlestate = actionidlestate.hideidle
        end
        if actor.attr.stalladvert ~= nil and #actor.attr.stalladvert > 0 then
            idlestate = actionidlestate.stall
        end
        if actor.actionmain.actionstate == idlestate then
            return
        end
        if idlestate == actionidlestate.stall then
            action_idle_setstate(actor, idlestate, animlist.stall, bit.bor(actorrenderflag.loopanim, actorrenderflag.randanim))
            return
        end
        if actor.actionmain.actionstate == actionidlestate.battleidle or actor.actionmain.actionstate == actionidlestate.flybattleidle then
            if actor.battle.battlestatebindanim ~= nil and actor.battle.battlestatebindanim > time_game then
                actor.battle.battlestatebindanim = nil
                action_idle_setstate(actor, actionidlestate.battleoff, animlist.weapon, 0)
                return
            end
        end
        if actor.attr.movetype == playermovestate.fly then
            actor:setrotation(0.0, actor.attr.rot, 0.0)
        end
        action_idle_setstate(actor, idlestate, actor:getidleanim(), bit.bor(actorrenderflag.loopanim, actorrenderflag.randanim))
        return
    end
end

function action_idle_enter(actor)
    actor.actionmain.actionstate = 0
    actor.actionmain.actioncomplete = 0
    actor.actionmain.idlesyncrest = 0
end

function action_idle_update(actor)
    if actor.actionmain.actioncomplete > time_game then
        return
    end
    if actor:isnpc() then
        if actor:isdynamicnpc() or actor:isstaticnpc() then
            action_idle_updatenpcstate(actor)
        end
    else
        action_idle_updateplayerstate(actor)
    end
end

function action_idle_move(actor)
    if actor.actionmain.actionstate == actionidlestate.restloop then
        if actor.actionmain.idlesyncrest < time_game then
            actor.actionmain.idlesyncrest = time_game + 2
            local msg = {messageid="CS_SwitchRest"}
            msg.rest = 0
            c_send(msg)    
        end
        return true
    end
    if actor.actionmain.actionstate == actionidlestate.reststart or actor.actionmain.actionstate == actionidlestate.reststand then
        return true
    end
    return false
end

function action_idle_leave(actor)
    actor.actionmain.rot = 0.0
    actor:updateactorposition()
end

function action_idle_reload(actor)
    actor.actionmain.actionstate = 0
    actor.actionmain.actioncomplete = 0
end
