
function action_craftingcomplete_enter(actor)
    local animname = action_crafting_getanim(actor.actionmain.skillid)
    local anim = nil
    if actor.battle.spellsuccess == 1 then
        anim = animlist[animname .. "succ"]
    else
        anim = animlist[animname .. "fail"]
    end
    local alias = actor:playanimlist(anim)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_craftingcomplete_update(actor)
    if actor.actionmain.actioncomplete < time_game then
        actor:clearspell()
    end
end
