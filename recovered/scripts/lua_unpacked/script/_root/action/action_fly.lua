
local function action_fly_updateanim(actor)
    if actor:isplayer() then
        actor.actionmain.flydir = actor.move.inputdirection
        actor.actionmain.flybattle = actor:getbattle()
        local anim = nil
        if actor.actionmain.flydir == movedirection.forward then
            anim = animlist.flyf
        elseif actor.actionmain.flydir == movedirection.backward then
            anim = animlist.flyb
        elseif actor.actionmain.flydir == movedirection.left then
            anim = animlist.flyl
        elseif actor.actionmain.flydir == movedirection.right then
            anim = animlist.flyr
        elseif actor.actionmain.flydir == movedirection.up then
            anim = animlist.flyu
        elseif actor.actionmain.flydir == movedirection.down then
            anim = animlist.flyd
        end
        local animspeed = actor:getmoveanimspeed()
        actor:playanimlist(anim, bit.bor(actorrenderflag.loopanim, actorrenderflag.randanim), animspeed)
    end
end

function action_fly_enter(actor)
    actor.actionmain.timestart = time_game
    action_fly_updateanim(actor)
end

function action_fly_update(actor)
    if actor:isplayer() then
        if actor.actionmain.flydir ~= actor.move.inputdirection
        or actor.actionmain.flybattle ~= actor:getbattle() then
            action_fly_updateanim(actor)
        end
    end
    actor:movemefly()
end
