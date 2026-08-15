
local function action_consumeitem_setanim(actor)
    local anim = actor.actionadditive.config_item.anim
    local animname = nil
    if anim == "common" and actor:getfly() then
        animname = string.format("fuseitem_succ_%s_001", anim)
    else
        animname = string.format("nuseitem_succ_%s_001", anim)
    end
    local alias = actor:playadditiveanim(animname, 0, 1.0)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + alias.length - animblendin
    else
        actor.actionadditive.actioncomplete = 0
    end
    actor:setsubattackanim(animname, 1.0)
    actor.actionadditive.config_skill = nil
end

function action_consumeitem_enter(actor)
    action_consumeitem_setanim(actor)
end

function action_consumeitem_leave(actor)
    actor:stopanim(actorrenderflag.additive, animblendout)
end

function action_consumeitem_update(actor)
    if actor.actionadditive.config_skill ~= nil then
        action_consumeitem_setanim(actor)
    elseif actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    else
        actor:updateadditiveanim()
    end
end
