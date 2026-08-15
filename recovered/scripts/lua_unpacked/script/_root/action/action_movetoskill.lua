
local function action_movetoskill_updateanim(actor)
    actor.actionmain.movedir = actor.move.inputdirection
    actor.actionmain.movebattle = actor:getbattle()
    actor.actionmain.moverun = actor.attr.moverun
    local animspeed = actor:getmoveanimspeed()
    if actor.actionmain.config_buffaction ~= nil and actor.actionmain.config_buffaction.buffaction == buffactiontype.stance then
        actor:playanim("crun_1hand_stance1_001", 0, animspeed)
    else
        local anim = nil
        if actor.attr.movetype == playermovestate.move then
            if actor.actionmain.moverun > 0 then
                if actor.actionmain.buffdeform ~= nil then
                    anim = animlist.run
                elseif actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
                    anim = animlist.hiderun
                elseif actor.attr.animrunkey ~= nil then
                    anim = actor.attr.animrunkey.run
                else
                    anim = animlist.run
                end
            else
                if actor.actionmain.buffdeform ~= nil then
                    anim = animlist.walk
                elseif actor.actionmain.buffhidelevel ~= nil and actor.actionmain.buffhidelevel > 0 then
                    anim = animlist.hidewalk
                else
                    anim = animlist.walk
                end
            end
		elseif actor.attr.movetype == playermovestate.fly then
            anim = animlist.flyf
		end
        actor:playanimlist(anim, actorrenderflag.loopanim, animspeed, nil, time_game - actor.actionmain.timestart)
    end
end

function action_movetoskill_enter(actor)
    actor.actionmain.timestart = time_game
    action_movetoskill_updateanim(actor)
end

function action_movetoskill_update(actor)
    if actor.actionmain.movebattle ~= actor:getbattle()
    or actor.actionmain.moverun ~= actor.attr.moverun then
        action_movetoskill_updateanim(actor)
    end
    local time = time_game - actor.actionmain.timestart
    local speed = math.min(time / 0.2, 1.0)
    local animspeed = actor:getmoveanimspeed()
    actor:setanimspeed(speed * animspeed, -1)

    playerapproach_move()
end

function action_movetoskill_reload(actor)
    action_movetoskill_updateanim(actor)
end
