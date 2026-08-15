
local function action_battleattacknpc_setanim(actor)
    if actor.actionmain.target ~= nil and actor.actionmain.target ~= actor.actorid then
        local target = actormanager_getfromactorid(actor.actionmain.target)
        if target ~= nil then
            actor:setactorlook(target)
        end
    end
    local flag = actorrenderflag.resetanim
    local alias = actor:playanim(actor.actionmain.animname, flag, actor.actionmain.animspeed)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length / actor.actionmain.animspeed - animblendin
    else
        actor.actionmain.actioncomplete = 0
    end
    actor.actionmain.animname = nil
end

function action_battleattacknpc_enter(actor)
    action_battleattacknpc_setanim(actor)
end

function action_battleattacknpc_leave(actor)

end

function action_battleattacknpc_update(actor)
    if actor.actionmain.actioncomplete < time_game then
        actor.attr.clientstate = npcclientstate.none
    elseif actor.actionmain.animname ~= nil then
        action_battleattacknpc_setanim(actor)
    end
end
