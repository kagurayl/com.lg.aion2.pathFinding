
local function action_battleattackplayer_setanim(actor)
    if actor.actionadditive.target ~= nil and actor.actionadditive.target ~= actor.actorid then
        local target = actormanager_getfromactorid(actor.actionadditive.target)
        if target ~= nil then
            actor:setactorlook(target)
        end
    end
    local alias = actor:playadditiveanim(actor.actionmain.animname, 0, actor.actionmain.animspeed)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + alias.length / actor.actionmain.animspeed - animblendin
    else
        actor.actionadditive.actioncomplete = 0
    end
    actor:setsubattackanim(actor.actionmain.animname, actor.actionmain.animspeed)
    actor.actionmain.animname = nil
end

function action_battleattackplayer_enter(actor)
    action_battleattackplayer_setanim(actor)
end

function action_battleattackplayer_leave(actor)
    actor:stopanim(actorrenderflag.additive, animblendout)
end

function action_battleattackplayer_update(actor)
    if actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    elseif actor.actionmain.animname ~= nil then
        action_battleattackplayer_setanim(actor)
    else
        actor:updateadditiveanim()
    end
end
