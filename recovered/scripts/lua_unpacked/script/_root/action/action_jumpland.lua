
function action_jumpland_enter(actor)
    local anim = nil
    if actor.attr.animjumpkey == nil then
        anim = animlist.jumpend
    else
        anim = actor.attr.animjumpkey.jumpend
    end
    local animname = actor:getanimlistname(anim)
    local alias = actor:playadditiveanim(animname, 0, 1.0)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + math.min(alias.length, 0.2)
    else
        actor.actionadditive.actioncomplete = 0
    end
end

function action_jumpland_leave(actor)
    actor:stopanim(actorrenderflag.additive, animblendout)
end

function action_jumpland_update(actor)
    if actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    else
        actor:updateadditiveanim()
    end
end
