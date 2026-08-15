
local actionimmobilizestate = 
{
    flyoff = 0,
    pulled = 1,
    paralyze = 2,
    petrification = 3,
    stumblestart = 4,
    stumbleloop = 5,
    stumbleend = 6,
    stun = 7,
    stagger = 8,
    spin = 9,
    openaerial = 10,
    sleep = 11,
    root = 12,
}

function action_immobilize_enter(actor)
    local playidle = true
    local lambda = actor.actionmain.config_buffaction.lambda
    local arraycount = lambda.arraysize
    for i=1,arraycount do
        local lambda2 = lambda.lambdaarray[i]
        local actioncount = lambda2.actioncount
        for j=1,actioncount do
            local sublambda = lambda2[j]
            if c_isaction(sublambda, "flyoff") then
                actor.actionmain.immobilizestate = actionimmobilizestate.flyoff
            elseif c_isaction(sublambda, "pulled") then
                actor.actionmain.immobilizestate = actionimmobilizestate.pulled
            elseif c_isaction(sublambda, "paralyze") then
                actor.actionmain.immobilizestate = actionimmobilizestate.paralyze
                actor:setanimspeed(0.0, 0.0)
            elseif c_isaction(sublambda, "petrification") then
                actor.actionmain.immobilizestate = actionimmobilizestate.petrification
                actor:setanimspeed(0.0, 0.0)
            elseif c_isaction(sublambda, "stumble") then
                actor.actionmain.immobilizestate = actionimmobilizestate.stumblestart
                local alias = actor:playanimlist(animlist.stumblestart)
                if alias ~= nil then
                    playidle = false
                    actor.actionmain.immobilizefadeout = actor.actionmain.buffactiontimemout - alias.length
                    actor.actionmain.actioncomplete = time_game + alias.length
                else
                    actor.actionmain.immobilizefadeout = 0
                    actor.actionmain.actioncomplete = 0
                end
            elseif c_isaction(sublambda, "stun") then
                actor.actionmain.immobilizestate = actionimmobilizestate.stun
                local alias = nil
                if actor:getfly() then
                    alias = actor:playanimlist(animlist.fstun)
                else
                    alias = actor:playanimlist(animlist.nstun)
                end
                if alias ~= nil then
                    playidle = false
                end
            elseif c_isaction(sublambda, "stagger") then
                actor.actionmain.immobilizestate = actionimmobilizestate.stun
                local alias = nil
                if actor:getfly() then
                    alias = actor:playanimlist(animlist.fstun)
                else
                    alias = actor:playanimlist(animlist.nstun)
                end
                if alias ~= nil then
                    playidle = false
                end
            elseif c_isaction(sublambda, "spin") then
                actor.actionmain.immobilizestate = actionimmobilizestate.spin
                local alias = nil
                if actor:getfly() then
                    alias = actor:playanimlist(animlist.fstun)
                else
                    alias = actor:playanimlist(animlist.nstun)
                end
                if alias ~= nil then
                    playidle = false
                end
            elseif c_isaction(sublambda, "openaerial") then
                actor.actionmain.posy = 2.0
                actor.actionmain.immobilizestate = actionimmobilizestate.openaerial
                local alias = actor:playanimlist(animlist.aerialloop)
                if alias ~= nil then
                    playidle = false
                end
                actor:updateactorposition()
            elseif c_isaction(sublambda, "sleep") then
                actor.actionmain.immobilizestate = actionimmobilizestate.sleep
            elseif c_isaction(sublambda, "root") then
                actor.actionmain.immobilizestate = actionimmobilizestate.root
            end
        end
    end
    if playidle then
        actor:playanimlist(actor:getidleanim())
    end
end

function action_immobilize_leave(actor)
    actor:setanimspeed(1.0, 1.0)
    actor.actionmain.posy = 0.0
    actor:updateactorposition()
end

function action_immobilize_update(actor)
    if actor.actionmain.immobilizestate == actionimmobilizestate.stumblestart then
        if actor.actionmain.immobilizefadeout > 0 and actor.actionmain.immobilizefadeout < time_game then
            actor.actionmain.immobilizestate = actionimmobilizestate.stumbleend
            actor:playanimlist(animlist.stumbleend)
        elseif actor.actionmain.actioncomplete > 0 and actor.actionmain.actioncomplete < time_game then
            actor.actionmain.immobilizestate = actionimmobilizestate.stumbleloop
            actor:playanimlist(animlist.stumbleloop)
        end
    elseif actor.actionmain.immobilizestate == actionimmobilizestate.stumbleloop then
        if actor.actionmain.immobilizefadeout > 0 and actor.actionmain.immobilizefadeout < time_game then
            actor.actionmain.immobilizestate = actionimmobilizestate.stumbleend
            actor:playanimlist(animlist.stumbleend)
        end
    end
end
