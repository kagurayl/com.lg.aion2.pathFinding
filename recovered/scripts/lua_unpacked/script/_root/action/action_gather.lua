
function action_gather_enter(actor)
    local anim = animlist["gatheringstart_" .. actor.battle.spellanim]
    local alias = actor:playanimlist(anim)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_gather_update(actor)
    if actor.actionmain.actioncomplete > 0 and actor.actionmain.actioncomplete < time_game then
        actor.actionmain.actioncomplete = 0
        local anim = animlist["gathering_" .. actor.battle.spellanim]
        actor:playanimlist(anim, actorrenderflag.loopanim)
    end
    if actor:isme() and actor:ismoving() then
        local msg = {messageid="CS_CraftingCancel"}
        msg.actorid = actor.actionmain.target
        c_send(msg)
    end
end
