

function action_npcinteract_enter(actor)
    local alias = actor:playanim("nclick_001")
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_npcinteract_update(actor)
    if actor.actionmain.actioncomplete < time_game then
        actor.attr.clientstate = npcclientstate.none
    end
end

function action_npcinteract_leave(actor)
    if actor.attr.clientstate == npcclientstate.interact then
        actor.attr.clientstate = npcclientstate.none
    end
end
