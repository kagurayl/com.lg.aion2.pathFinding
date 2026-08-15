
local function action_enchant_updatestate(actor)
    if actor.actionmain.spelltype == playerspellstate.enchantspell then
        if actor.actionmain.actionstate ~= playerspellstate.enchantspell then
            actor.actionmain.actionstate = playerspellstate.enchantspell
            local alias = actor:playanim("nuseitem_enchant_001")
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0
            end
        end
    elseif actor.actionmain.spelltype == playerspellstate.enchantsuccess then
        if actor.actionmain.actionstate ~= playerspellstate.enchantsuccess then
            actor.actionmain.actionstate = playerspellstate.enchantsuccess
            local alias = actor:playanim("nuseitem_succ_enchant_001")
            actor:createvfx(EffectEnchantSuccess, vfx_bind_center, true)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0
            end
        end
    elseif actor.actionmain.spelltype == playerspellstate.enchantfail then
        if actor.actionmain.actionstate ~= playerspellstate.enchantsuccess then
            actor.actionmain.actionstate = playerspellstate.enchantsuccess
            local alias = actor:playanim("nuseitem_fail_enchant_001")
            actor:createvfx(EffectEnchantFailure, vfx_bind_center, true)
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0
            end
        end
    end
    if actor.actionmain.actioncomplete < time_game then
        actor:clearspell()
    end
end

function action_enchant_enter(actor)
    actor.actionmain.actionstate = nil
    action_enchant_updatestate(actor)
end

function action_enchant_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.enchantspell
    or actor.actionmain.spelltype == playerspellstate.enchantsuccess
    or actor.actionmain.spelltype == playerspellstate.enchantfail then
        actor:clearspell()
    end
end

function action_enchant_move(actor)
    actor:clearspell()
    return false
end

function action_enchant_update(actor)
    action_enchant_updatestate(actor)
    actor:movememove()
end
