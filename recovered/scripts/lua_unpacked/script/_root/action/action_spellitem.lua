
function action_spellitem_enter(actor)
    actor.actionmain.spellitemid = actor.actionmain.config_item.id
    local anim = actor.actionmain.config_item.anim
    local animname = nil
    if anim == "common" and actor:getfly() then
        animname = string.format("fuseitem_%s_001", anim)
    else
        animname = string.format("nuseitem_%s_001", anim)
    end
    actor:playanim(animname)
end

function action_spellitem_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.spellitem then
        actor:clearspell()
    end
end

function action_spellitem_move(actor)
    actor:clearspell()
    return false
end

function action_spellitem_update(actor)
    if actor.actionmain.config_item ~= nil then
        if actor.actionmain.spellitemid ~= actor.actionmain.config_item.id then
            action_spellitem_enter(actor)
        end
    end
    actor:movememove()
end
