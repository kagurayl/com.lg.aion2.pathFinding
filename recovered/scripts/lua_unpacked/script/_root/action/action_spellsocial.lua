
local function action_spellsocial_updateanim(actor)
    local animname = string.format("n%s_001", actor.actionmain.config_skill.anim)
    local flag = bit.bor(actorrenderflag.resetanim, actorrenderflag.syncstopaudio)
    local alias = actor:playanim(animname, flag)
    if alias ~= nil then
        if actor.actionmain.config_skill.voice ~= nil and actor.actionmain.config_skill.voice ~= "0" then
            audiomanager_playactorvoice(actor, "vsocial", 1.0, 15.0, 20.0, actor.actionmain.config_skill.voice, audiopriority.normal)
        end
        actor.actionmain.actioncomplete = time_game + alias.length
        actor.actionmain.actionskill = actor.actionmain.config_skill
    else
        actor.actionmain.actioncomplete = 0
        actor.actionmain.actionskill = nil
    end
end

function action_spellsocial_enter(actor)
    action_spellsocial_updateanim(actor)
end

function action_spellsocial_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.spellsocial then
        actor:clearspell()
    end
end

function action_spellsocial_move(actor)
    actor:clearspell()
    return false
end

function action_spellsocial_update(actor)
    if actor.actionmain.actionskill ~= actor.actionmain.config_skill then
        action_spellsocial_updateanim(actor)
    end
    if actor.actionmain.actioncomplete < time_game then
        actor:clearspell()
    end
end
