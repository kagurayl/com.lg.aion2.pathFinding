
local actorjumpstate = 
{
	jump = 1,
	fall = 2,
}

function action_jump_enter(actor)
    actor.actionmain.jumpstate = nil
    actor.actionmain.actioncomplete = 0.0
end

function action_jump_leave(actor)
    actor.actionmain.jumpstate = nil
    actor.actionmain.jumpdirx = 0
	actor.actionmain.jumpdirz = 0
end

local function action_jump_getanim(actor, animname)
    if actor.attr.animjumpkey == nil then
        return animlist[animname]
    else
        return actor.attr.animjumpkey[animname]
    end
end

function action_jump_update(actor)
    if actor.actionmain.jumpstate == nil then
        if not actor.transform.onfloor then
            if actor.actionmain.jumptime ~= nil and time_game - actor.actionmain.jumptime < 0.2 then
                actor.actionmain.jumpstate = actorjumpstate.jump
                local alias = actor:playanimlist(action_jump_getanim(actor, "jumpstart"))
                if alias ~= nil then
                    actor.actionmain.actioncomplete = time_game + alias.length
                end
            else
                actor.actionmain.jumpstate = actorjumpstate.fall
                actor:playanimlist(action_jump_getanim(actor, "jumpair"))
            end
        end
    elseif actor.actionmain.jumpstate == actorjumpstate.jump then
        if actor.actionmain.actioncomplete < time_game then
            actor.actionmain.jumpstate = actorjumpstate.fall
            actor:playanimlist(action_jump_getanim(actor, "jumpair"))
        end
    elseif actor.actionmain.jumpstate == actorjumpstate.fall then
        if actor.transform.onfloor then
            actor.actionmain.jumpstate = nil
            if not actionmanager_playingadditive(actor) then
                actor.actionadditive.request = actionname.jumpland
            end
            if actor:isplayer() then
                actor:updatejumpaudio()
            end
        end
    end
    actor:movemejump()
end

function action_jump_reload(actor)
    if actor.actionmain.jumpstate ~= nil then
        actor.actionmain.jumpstate = actorjumpstate.fall
        actor:playanimlist(action_jump_getanim(actor, "jumpair"))
    end
end
