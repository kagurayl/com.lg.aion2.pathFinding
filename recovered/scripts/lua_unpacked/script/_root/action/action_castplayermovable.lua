
local function action_castplayermovable_setanim(actor)
    local animname, speed = actor:getskillanimname(csvskillanimtype.fire, actor.actionadditive.config_skill)
    if animname == nil then
        actor.actionadditive.actioncomplete = 0
        actor.actionadditive.config_skill = nil
        return
    end
    speed = speed * actor:getattackanimspeed()
    local alias = actor:playadditiveanim(animname, 0, speed)
    if alias ~= nil then
        actor.actionadditive.actioncomplete = time_game + alias.length / speed - animblendin
        actor:createcastvfx(actor.actionadditive.config_skill.fxcast, actor.actionadditive.castinstid)
    else
        actor.actionadditive.actioncomplete = 0
    end
    actor:setsubattackanim(animname, speed)
    actor:updateweaponvisible()
    actor.actionadditive.config_skill = nil
end

function action_castplayermovable_enter(actor)
    action_castplayermovable_setanim(actor)
end

function action_castplayermovable_leave(actor)
    actor:stopanim(actorrenderflag.additive, animblendout)
    actor:updateweaponvisible()
end

function action_castplayermovable_update(actor)
    if actor.actionadditive.config_skill ~= nil then
        action_castplayermovable_setanim(actor)
    elseif actor.actionadditive.actioncomplete < time_game then
        actor.actionadditive.complete = true
    else
        actor:updateadditiveanim()
    end
end
