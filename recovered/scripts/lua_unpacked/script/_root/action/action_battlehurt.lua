
function action_battlehurt_enter(actor)
    local accuracytype = actor.actionadditive.accuracytype
    local nanim = nil
    local fanim = nil
    if accuracytype == lambdaaccuracytype.dodge or accuracytype == lambdaaccuracytype.resist then
        nanim = animlist.ndodge
        fanim = animlist.fdodge
    elseif accuracytype == lambdaaccuracytype.parry or accuracytype == lambdaaccuracytype.block then
        nanim = animlist.nparry
        fanim = animlist.fparry
    else
        nanim = animlist.ndamage
        fanim = animlist.fdamage
    end
    local anim = nanim
    if actor:getfly() then
        anim = fanim
    end
    local animname = actor:getanimlistname(anim)
    local alias = actor:playadditiveanim(animname, 0, 1.0)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + math.min(alias.length, 0.2)
    else
        actor.actionadditive.actioncomplete = 0
    end
end

function action_battlehurt_leave(actor)
    actor:stopanim(actorrenderflag.additive, 0.1)
end

function action_battlehurt_update(actor)
    if actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    else
        actor:updateadditiveanim()
    end
end
