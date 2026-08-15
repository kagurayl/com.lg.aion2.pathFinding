
local function action_move_getplayeranim(actor)
    if actor.actionmain.moverun > 0 then
        if actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
            if actor.actionmain.movedir == movedirection.backward then
                return animlist.hiderunb
            elseif actor.actionmain.movedir == movedirection.left then
                return animlist.hiderunl
            elseif actor.actionmain.movedir == movedirection.right then
                return animlist.hiderunr
            else
                return animlist.hiderun
            end
        else
            if actor.attr.animrunkey == nil then
                if actor.actionmain.movedir == movedirection.backward then
                    return animlist.runb
                elseif actor.actionmain.movedir == movedirection.left then
                    return animlist.runl
                elseif actor.actionmain.movedir == movedirection.right then
                    return animlist.runr
                else
                    return animlist.run
                end
            else
                if actor.actionmain.movedir == movedirection.backward then
                    return actor.attr.animrunkey.runb
                elseif actor.actionmain.movedir == movedirection.left then
                    return actor.attr.animrunkey.runl
                elseif actor.actionmain.movedir == movedirection.right then
                    return actor.attr.animrunkey.runr
                else
                    return actor.attr.animrunkey.run
                end
            end
        end
    end
    if actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
        if actor.actionmain.movedir == movedirection.backward then
            return animlist.hidewalkb
        elseif actor.actionmain.movedir == movedirection.left then
            return animlist.hidewalkl
        elseif actor.actionmain.movedir == movedirection.right then
            return animlist.hidewalkr
        else
            return animlist.hidewalk
        end
    else
        if actor.actionmain.movedir == movedirection.backward then
            return animlist.walkb
        elseif actor.actionmain.movedir == movedirection.left then
            return animlist.walkl
        elseif actor.actionmain.movedir == movedirection.right then
            return animlist.walkr
        else
            return animlist.walk
        end
    end
end

local function action_move_updateanim(actor)
    if actor:isplayer() then
        actor.actionmain.movedir = actor.move.inputdirection
        actor.actionmain.movebattle = actor:getbattle()
        actor.actionmain.moverun = actor.attr.moverun
        actor.actionmain.buffaction = 0
        actor.actionmain.movehidelevel = actor.actionmain.buffhidelevel or 0
        local animlistkey = nil
        local animname = nil
        if actor.actionmain.buffdeform ~= nil then
            if actor.actionmain.moverun > 0 then
                animlistkey = animlist.run
            else
                animlistkey = animlist.walk
            end
        elseif actor.actionmain.config_buffaction ~= nil and actor.actionmain.config_buffaction.buffaction == buffactiontype.stance then
            actor.actionmain.buffaction = buffactiontype.stance
            if actor.actionmain.movedir == movedirection.backward then
                animname = "crunb_1hand_stance1_001"
            elseif actor.actionmain.movedir == movedirection.left then
                animname = "crunL_1hand_stance1_001"
            elseif actor.actionmain.movedir == movedirection.right then
                animname = "crunr_1hand_stance1_001"
            else
                animname = "crun_1hand_stance1_001"
            end
        else
            animlistkey = action_move_getplayeranim(actor)
        end
        if animlistkey ~= nil then
            local animspeed = actor:getmoveanimspeed()
            actor:playanimlist(animlistkey, actorrenderflag.loopanim, animspeed, nil, time_game - actor.actionmain.timestart)
        elseif animname ~= nil then
            actor:playanim(animname, actorrenderflag.loopanim, animspeed, nil, timestart, nil)
        end
    else
        actor.actionmain.movenpcstate = actor.attr.npcstate
        if actor:getfly() then
            actor:playanimlist(animlist.flyf, actorrenderflag.loopanim)
        else
            if actor.move.sync_npcmoveanim ~= nil and #actor.move.sync_npcmoveanim > 0 and actor.move.sync_npcmoveanim ~= "0" then
                local animname = nil
                if actor.move.sync_npcmoveanim == "(default nrun motion)" then
                    animname = "nrun_001"
                elseif actor.move.sync_npcmoveanim == "(default crun motion)"
                or actor.move.sync_npcmoveanim == "extended_crun_motion_1" then
                    animname = "nrun_001"
                elseif actor.move_sync_npcmoveanim == "(default nwalk motion)" then
                    animname = "nwalk_001"
                else
                    animname = string.format("nwalk_%s_001", actor.move.sync_npcmoveanim)
                end
                actor:playanim(animname, actorrenderflag.loopanim)
            else
                local animspeed = actor:getmoveanimspeed()
                if actor.attr.npcstate == npcsyncstate.movewalk then
                    actor:playanimlist(animlist.walk, actorrenderflag.loopanim, animspeed)
                else
                    actor:playanimlist(animlist.run, actorrenderflag.loopanim, animspeed)
                end
            end
        end
    end
end

function action_move_enter(actor)
    actor.actionmain.timestart = time_game
    actor.actionmain.movenpcstate = nil
    action_move_updateanim(actor)
end

function action_move_update(actor)
    if actor:isplayer() then
        local buffaction = 0
        if actor.actionmain.config_buffaction ~= nil and actor.actionmain.config_buffaction.buffaction == buffactiontype.stance then
            buffaction = buffactiontype.stance
        end
        local hidelevel = actor.actionmain.buffhidelevel or 0
        if actor.actionmain.movedir ~= actor.move.inputdirection
        or actor.actionmain.movebattle ~= actor:getbattle()
        or actor.actionmain.moverun ~= actor.attr.moverun
        or actor.actionmain.buffaction ~= buffaction
        or actor.actionmain.movehidelevel ~= hidelevel then
            action_move_updateanim(actor)
        end
        local time = time_game - actor.actionmain.timestart
        local speed = math.min(time / 0.2, 1.0)
        local animspeed = actor:getmoveanimspeed()
        actor:setanimspeed(speed * animspeed, -1)
        actor:updatewalkaudio()
    else
        if actor.actionmain.movenpcstate ~= actor.attr.npcstate then
            action_move_updateanim(actor)
        end
    end
    actor:movememove()
end

function action_move_reload(actor)
    action_move_updateanim(actor)
end
