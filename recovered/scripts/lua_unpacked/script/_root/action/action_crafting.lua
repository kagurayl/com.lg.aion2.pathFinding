
function action_crafting_getanim(skillid)
	if skillid == skill_gather_cooking then
		return "cooking"
    elseif skillid == skill_gather_weapon then
        return "wsmith"
    elseif skillid == skill_gather_armor then
        return "asmith"
    elseif skillid == skill_gather_tailor then
        return "tailoring"
    elseif skillid == skill_gather_alchemy then
        return "alchemy"
    elseif skillid == skill_gather_handiwork then
        return "handiwork"
	end
end

function action_crafting_enter(actor)
    local animname = action_crafting_getanim(actor.actionmain.skillid)
    local anim = animlist[animname]
    local alias = actor:playanimlist(anim)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0
    end
end

function action_crafting_update(actor)
    if actor.actionmain.actioncomplete > 0 and actor.actionmain.actioncomplete < time_game then
        actor.actionmain.actioncomplete = 0
        local animname = action_crafting_getanim(actor.actionmain.skillid)
        local anim = animlist[animname .. "loop"]
        actor:playanimlist(anim)
    end
end
