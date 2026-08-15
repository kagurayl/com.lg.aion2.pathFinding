
function action_dead_enter(actor)
    actor.actionmain.actioncomplete = 0
    if actor:isplayer() then
        local timestart = time_game - actor.attr.deadtime
        if timestart < 5.0 then
            timestart = 0.0
        end
        local alias = nil
        if actor.attr.movetype == playermovestate.glide or actor.attr.movetype == playermovestate.fly then
            alias = actor:playanimlist(animlist.fdead, 0, 1.0, 0.0, timestart)
        else
            alias = actor:playanimlist(animlist.ndead, 0, 1.0, 0.0, timestart)
        end
        if alias ~= nil then
            actor.actionmain.actioncomplete = time_game + alias.length
        end
    else
        local timestart = 0
        if actor.attr.npcstate == npcsyncstate.dead then
            timestart = 1000.0
        end
        if actor:playanimlist(animlist.npcdead1, 0, 1.0, 0.0, timestart) == nil then
            actor:playanimlist(animlist.npcdead2, 0, 1.0, 0.0, timestart)
        end
    end
    if actor:isnpc() then
        actor:destroyallplate()
    end
    if actor:isme() then
        actor.actionmain.vfxtimestart = time_game
        c_camera_setposteffect("matdead")
    end
end

function action_dead_update(actor)
    if actor:isme() then
        if actor.actionmain.actioncomplete < time_game then
            actor.actordata.wingactionvisible = true
            dead_openui()
        end
        if actor.actionmain.vfxtimestart ~= nil then
            local time = (time_game - actor.actionmain.vfxtimestart) / 5.0
            if time > 1.0 then
                time = 1.0
                actor.actionmain.vfxtimestart = nil
            end
            c_camera_setposteffectcolor("_Color", time, time, time, 1.0)
        end
    end
end

function action_dead_leave(actor)
    c_camera_setposteffect(nil)
end

function action_dead_reload(actor)
    if not actor:isdead() then
        return
    end
    if actor:isplayer() then
        local timestart = time_game - actor.attr.deadtime
        if actor.attr.movetype == playermovestate.glide or actor.attr.movetype == playermovestate.fly then
            actor:playanimlist(animlist.fdead, 0, 1.0, 0.0, timestart)
        else
            actor:playanimlist(animlist.ndead, 0, 1.0, 0.0, timestart)
        end
        actor.actionmain.actioncomplete = 0
    else
        local timestart = 0
        if actor.attr.npcstate == npcsyncstate.dead then
            timestart = 1000.0
        end
        if actor:playanimlist(animlist.npcdead1, 0, 1.0, 0.0, timestart) == nil then
            actor:playanimlist(animlist.npcdead2, 0, 1.0, 0.0, timestart)
        end
    end
    actor:destroyallplate()
end
