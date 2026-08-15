
local function action_petplay_updateanim(actor)
    local animrand = "basic"
	local rand = math.random() * 100
	if rand > 80 then
		animrand = "d"
	elseif rand > 60 then
		animrand = "c"
	elseif rand > 40 then
		animrand = "b"
	elseif rand > 20 then
		animrand = "a"
	end
    local animname = string.format("n%s_%s_001", actor.actionmain.config_skill.anim, animrand)
    local flag = bit.bor(actorrenderflag.resetanim, actorrenderflag.syncstopaudio)
    local alias = actor:playanim(animname, flag)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
        actor.actionmain.actionskill = actor.actionmain.config_skill
    else
        actor.actionmain.actioncomplete = 0
        actor.actionmain.actionskill = nil
    end
end

function action_petplay_enter(actor)
    action_petplay_updateanim(actor)
end

function action_petplay_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.petplay then
        actor:clearspell()
    end
end

function action_petplay_move(actor)
    actor:clearspell()
    return false
end

function action_petplay_update(actor)
    if actor.actionmain.actionskill ~= actor.actionmain.config_skill then
        action_petplay_updateanim(actor)
    end
    if actor.actionmain.actioncomplete < time_game then
        actor:clearspell()
    end
end
