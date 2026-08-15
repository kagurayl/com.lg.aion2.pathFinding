
local function action_castplayer_setanim(actor)
    local animname, speed = actor:getskillanimname(csvskillanimtype.fire, actor.actionmain.config_skill)
    if animname == nil then
        actor:clearspell()
        return
    end
    speed = speed * actor:getattackanimspeed()
    local alias = actor:playanim(animname, actorrenderflag.resetanim, speed)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length / speed - animblendin
        actor:createcastvfx(actor.actionmain.config_skill.fxcast, actor.actionmain.castinstid)
    else
        actor.actionmain.actioncomplete = 0
    end
    actor:setsubattackanim(animname, speed)
    actor:updateweaponvisible()
    actor.actionmain.config_skillanim = actor.actionmain.config_skill
    actor.actionmain.config_skill = nil
end

function action_castplayer_enter(actor)
    action_castplayer_setanim(actor)
end

function action_castplayer_leave(actor)
    actor:updateweaponvisible()
end

function action_castplayer_update(actor)
    if actor.actionmain.config_skill ~= nil then
        action_castplayer_setanim(actor)
    elseif actor.actionmain.actioncomplete < time_game or actor:ismoving() then
        actor:clearspell()
    end
end

function action_castplayer_reload(actor)
    if actor.actionmain.config_skillanim ~= nil then
        local animname, speed = actor:getskillanimname(csvskillanimtype.fire, actor.actionmain.config_skillanim)
        if animname ~= nil then
            speed = speed * actor:getattackanimspeed()
            local time = time_game - actor.actionmain.timestart
            local alias = actor:playanim(animname, actorrenderflag.syncanim, speed, 0.0, time)
            if alias ~= nil then
                actor.actionmain.actioncomplete = actor.actionmain.timestart + alias.length / speed - animblendin
            end
        end
    end
end
