
function action_gathercomplete_enter(actor)
    local anim = nil
    if actor.battle.spellsuccess == 1 then
        anim = animlist["gathering_succ_" .. actor.battle.spellanim]
    else
        anim = animlist["gathering_fail_" .. actor.battle.spellanim]
    end
    local alias = actor:playanimlist(anim)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_gathercomplete_update(actor)
    if actor.actionmain.actioncomplete < time_game then
        actor:clearspell()
    end
end
