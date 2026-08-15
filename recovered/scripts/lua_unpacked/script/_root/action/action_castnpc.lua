
local function action_castnpc_setanim(actor)
    local animname, speed = actor:getskillanimname(csvskillanimtype.fire, actor.actionmain.config_skill)
    if animname == nil then
        actor.actionmain.actioncomplete = 0
        actor.actionmain.config_skill = nil
        return
    end
    speed = speed * actor:getattackanimspeed()
    local alias = actor:playanim(animname, 0, speed)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length / speed - animblendin
        actor:createcastvfx(actor.actionmain.config_skill.fxcast, actor.actionmain.castinstid)
    else
        if csvnpc_getscript(actor.config_npc, "summonskill") ~= nil then
            if actor.actordata.vfxmesh == nil then
                actor.actordata.vfxmesh = actor:createskillfxc(actor.actionmain.config_skill.fxcast, vfxflag.hidewithbuff)
            end
        end
        actor.actionmain.actioncomplete = 0
    end
    actor.actionmain.config_skill = nil
end

function action_castnpc_enter(actor)
    action_castnpc_setanim(actor)
end

function action_castnpc_leave(actor)
    if actor.attr.clientstate == npcclientstate.cast then
        actor.attr.clientstate = npcclientstate.none
    end
end

function action_castnpc_update(actor)
    if actor.actionmain.config_skill ~= nil then
        action_castnpc_setanim(actor)
    elseif actor.actionmain.actioncomplete < time_game then
        actor.attr.clientstate = npcclientstate.none
    end
end
