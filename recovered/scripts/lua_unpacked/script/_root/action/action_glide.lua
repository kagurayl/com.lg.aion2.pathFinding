

local actorglidestate = 
{
	glide = 1,
    glidedown = 2,
	glideend = 3,
}

function action_glide_enter(actor)
    actor.actionmain.glidestate = nil
    actor.actionmain.windpathidsync = nil
    actor.actionmain.actioncomplete = 0
end

function action_glide_leave(actor)
    actor.actionmain.glidestate = nil
    actor.actionmain.jumpdirx, actor.actionmain.jumpdirz = actor:getdirection2d()
end

function action_glide_update(actor)
    if actor.actionmain.glidestate == nil then
        if actor.attr.movetype == playermovestate.glide then
            if actor:moveisglidedown() then
                actor:playanimlist(animlist.glidedown)
                actor.actionmain.glidestate = actorglidestate.glidedown
            else
                actor:playanimlist(animlist.glide)
                actor.actionmain.glidestate = actorglidestate.glide
            end
        end
    elseif actor.actionmain.glidestate == actorglidestate.glide then
        if actor.attr.movetype ~= playermovestate.glide then
            actor.actionmain.glidestate = actorglidestate.glideend
            local alias = actor:playanimlist(animlist.glideend)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            end
        elseif actor:moveisglidedown() then
            actor:playanimlist(animlist.glidedown)
            actor.actionmain.glidestate = actorglidestate.glidedown
        end
    elseif actor.actionmain.glidestate == actorglidestate.glidedown then
        if actor.attr.movetype ~= playermovestate.glide then
            actor.actionmain.glidestate = actorglidestate.glideend
            local alias = actor:playanimlist(animlist.glideend)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            end
        elseif not actor:moveisglidedown() then
            actor:playanimlist(animlist.glide)
            actor.actionmain.glidestate = actorglidestate.glide
        end
    elseif actor.actionmain.glidestate == actorglidestate.glideend then
        if actor.actionmain.actioncomplete < time_game then
            actor.actionmain.glidestate = nil
        end
    end
    actor:movemeglide()
end

function action_glide_reload(actor)
    actor.actionmain.glidestate = nil
end
