
function action_equipweapon_enter(actor)
    local flag = bit.bor(actorrenderflag.additive, actorrenderflag.mixanim)
    local alias = actor:playanimlist(animlist.weaponmove, flag)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + math.min(alias.length, 0.2)
    else
        actor.actionadditive.actioncomplete = 0
    end
end

function action_equipweapon_leave(actor)
    actor:stopanim(actorrenderflag.additive, animblendout)
end

function action_equipweapon_update(actor)
    if actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    end
end
