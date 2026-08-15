
local actionspellitembindstate = 
{
    start = 1,
    spell = 2,
    spellend = 3,
}

function action_spellitembind_enter(actor)
    actor.actionmain.actionstate = actionspellitembindstate.start
    local alias = actor:playanimlist(animlist.soulbind_start)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_spellitembind_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.spellitembind or actor.actionmain.spelltype == playerspellstate.spellitembindend then
        actor:clearspell()
    end
end

function action_spellitembind_move(actor)
    actor:clearspell()
    return false
end

function action_spellitembind_update(actor)
    if actor.actionmain.actionstate == actionspellitembindstate.start then
        if actor.actionmain.actioncomplete < time_game then
            actor:playanimlist(animlist.soulbind)
            actor.actionmain.actionstate = actionspellitembindstate.spell
        end
    elseif actor.actionmain.actionstate == actionspellitembindstate.spell then
        if actor.actionmain.spelltype == playerspellstate.spellitembindend then
            actor.actionmain.actionstate = actionspellitembindstate.spellend
            local alias = actor:playanimlist(animlist.soulbind_end)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0
            end
        end
    elseif actor.actionmain.actionstate == actionspellitembindstate.spellend then
        if actor.actionmain.spelltype == playerspellstate.spellitembind then
            actor.actionmain.actionstate = actionspellitembindstate.start
            local alias = actor:playanimlist(animlist.soulbind_start)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0
            end
        elseif actor.actionmain.actioncomplete < time_game then
            actor:clearspell()
        end
    end
    actor:movememove()
end
