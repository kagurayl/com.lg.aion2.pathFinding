
function battletext_dead(actor, killer)
    if actor:isme() then
        battletext_setinfo(chatchanneltype.systemdeadself, 0, actor, actor.actorid, 0, 0)
        if killer ~= nil and #killer > 0 then
            battletext_addtextformat("STR_MSG_COMBAT_MY_DEATH_TO_B", killer)
        else
            battletext_addtextformat("STR_MSG_COMBAT_MY_DEATH")
        end
    elseif actor:isenemy() then
        battletext_setinfo(chatchanneltype.systemdeadenemy, 0, actor, actor.actorid, 0, 0)
        if killer ~= nil and #killer > 0 and killer ~= playerattr_info.name then
            battletext_addtextformat("STR_MSG_COMBAT_HOSTILE_DEATH_TO_B", killer, actor.attr.name)
        else
            battletext_addtextformat("STR_MSG_COMBAT_HOSTILE_DEATH_TO_ME", actor.attr.name)
        end
    else
        battletext_setinfo(chatchanneltype.systemdeadsipid, 0, actor, actor.actorid, 0, 0)
        if killer ~= nil and #killer > 0 and killer ~= playerattr_info.name then
            battletext_addtextformat("STR_MSG_COMBAT_FRIENDLY_DEATH_TO_B", actor.attr.name, killer)
        else
            battletext_addtextformat("STR_MSG_COMBAT_FRIENDLY_DEATH", actor.attr.name)
        end
    end
end

function battletext_drain(actor, action, skillid, val, ishp)
    local textchattype = battletext_getchattype(actor, actor, actor.actorid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, actor.actorid, 0, skillid)
    if ishp then
        if action == lambdapointtype.skillatkdrain then
            if actor:isme() then
                battletext_addtextformat("STR_SKILL_SUCC_SKILLATKDRAIN_INSTANT_INTERVAL_HEAL_TO_ME", val)
            else
                battletext_addtextformat("STR_SKILL_SUCC_SKILLATKDRAIN_INSTANT_INTERVAL_HEAL_TO_B", val)
            end
        elseif action == lambdapointtype.spellatkdrain then
            if actor:isme() then
                battletext_addtextformat("STR_SKILL_SUCC_SPELLATKDRAIN_INSTANT_INTERVAL_HEAL_TO_ME", val)
            else
                battletext_addtextformat("STR_SKILL_SUCC_SPELLATKDRAIN_INSTANT_INTERVAL_HEAL_TO_B", val)
            end
        end
    else
        if action == lambdapointtype.skillatkdrain then
            if actor:isme() then
                battletext_addtextformat("STR_SKILL_SUCC_SKILLATKDRAIN_INSTANT_INTERVAL_HEAL_MP_TO_ME", val)
            else
                battletext_addtextformat("STR_SKILL_SUCC_SKILLATKDRAIN_INSTANT_INTERVAL_HEAL_MP_TO_B", val)
            end
        elseif action == lambdapointtype.spellatkdrain then
            if actor:isme() then
                battletext_addtextformat("STR_SKILL_SUCC_SPELLATKDRAIN_INSTANT_INTERVAL_HEAL_MP_TO_ME", val)
            else
                battletext_addtextformat("STR_SKILL_SUCC_SPELLATKDRAIN_INSTANT_INTERVAL_HEAL_MP_TO_B", val)
            end
        end
    end
end

function battletext_blink(actor, skillid)
    local textchattype = battletext_getchattype(actor, actor, actor.actorid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, actor.actorid, 0, skillid)
    battletext_addtextformatex("STR_SKILL_SUCC_RANDOMMOVELOC_A_TO_ME", "STR_SKILL_SUCC_RANDOMMOVELOC_A_TO_B", "STR_SKILL_SUCC_RANDOMMOVELOC_A_TO_SELF",
                                "STR_SKILL_SUCC_RANDOMMOVELOC_ME_TO_SELF", "STR_SKILL_SUCC_RANDOMMOVELOC_ME_TO_B", val)
end

function battletext_summon(actor, skillid, npcid)
    local textchattype = battletext_getchattype(actor, actor, actor.actorid)
    if textchattype == nil then
        return
    end
    local config_npc = csvnpc_getfromid(npcid)
    if config_npc ~= nil then
        battletext_setinfo(textchattype, chatbattletype.skill, actor, actor.actorid, 0, skillid)
        battletext_addtextformatex("STR_SKILL_SUCC_SUMMON_A_TO_ME", "STR_SKILL_SUCC_SUMMON_A_TO_B", "STR_SKILL_SUCC_SUMMON_A_TO_SELF",
                                    "STR_SKILL_SUCC_SUMMON_ME_TO_SELF", "STR_SKILL_SUCC_SUMMON_ME_TO_B", config_npc.name)
    end
end

function battletext_threat(actor, skillid, threat)
    local textchattype = battletext_getchattype(actor, actor, actor.actorid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, actor.actorid, 0, skillid)
    battletext_addtextformatex("STR_SKILL_SUCC_HOSTILEUP_A_TO_ME", "STR_SKILL_SUCC_HOSTILEUP_A_TO_B", "STR_SKILL_SUCC_HOSTILEUP_A_TO_SELF",
                                    "STR_SKILL_SUCC_HOSTILEUP_ME_TO_SELF", "STR_SKILL_SUCC_HOSTILEUP_ME_TO_B", threat)
end

function battletext_dispel(actor, attackerid, skillid, action)
    local attacker = actormanager_getfromactorid(attackerid)
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, attackerid, 0, skillid)
    if action == dispeltype.normal
    or action == dispeltype.normaltype
    or action == dispeltype.normalid then
        battletext_addtextformatex("STR_SKILL_SUCC_DISPEL_A_TO_ME", "STR_SKILL_SUCC_DISPEL_A_TO_B", "STR_SKILL_SUCC_DISPEL_A_TO_SELF",
                                    "STR_SKILL_SUCC_DISPEL_ME_TO_SELF", "STR_SKILL_SUCC_DISPEL_ME_TO_B")
    elseif action == dispeltype.buff
        or action == dispeltype.bufftype
        or action == dispeltype.buffid
        or action == dispeltype.npcbuff then
        battletext_addtextformatex("STR_SKILL_SUCC_DISPELBUFF_A_TO_ME", "STR_SKILL_SUCC_DISPELBUFF_A_TO_B", "STR_SKILL_SUCC_DISPELBUFF_A_TO_SELF",
                                    "STR_SKILL_SUCC_DISPELBUFF_ME_TO_SELF", "STR_SKILL_SUCC_DISPELBUFF_ME_TO_B")
    elseif action == dispeltype.debuff
        or action == dispeltype.npcdebuff then
        battletext_addtextformatex("STR_SKILL_SUCC_DISPELDEBUFF_A_TO_ME", "STR_SKILL_SUCC_DISPELDEBUFF_A_TO_B", "STR_SKILL_SUCC_DISPELDEBUFF_A_TO_SELF",
                                    "STR_SKILL_SUCC_DISPELDEBUFF_ME_TO_SELF", "STR_SKILL_SUCC_DISPELDEBUFF_ME_TO_B")
    elseif action == dispeltype.debuffphy then
        battletext_addtextformatex("STR_SKILL_SUCC_DISPELDEBUFFMENTAL_A_TO_ME", "STR_SKILL_SUCC_DISPELDEBUFFMENTAL_A_TO_B", "STR_SKILL_SUCC_DISPELDEBUFFMENTAL_A_TO_SELF",
                                    "STR_SKILL_SUCC_DISPELDEBUFFMENTAL_ME_TO_SELF", "STR_SKILL_SUCC_DISPELDEBUFFMENTAL_ME_TO_B")
    elseif action == dispeltype.debuffmag then
        battletext_addtextformatex("STR_SKILL_SUCC_DISPELDEBUFFPHYSICAL_A_TO_ME", "STR_SKILL_SUCC_DISPELDEBUFFPHYSICAL_A_TO_B", "STR_SKILL_SUCC_DISPELDEBUFFPHYSICAL_A_TO_SELF",
                                    "STR_SKILL_SUCC_DISPELDEBUFFPHYSICAL_ME_TO_SELF", "STR_SKILL_SUCC_DISPELDEBUFFPHYSICAL_ME_TO_B")
    end
end

function battletext_swaphpmp(actor, skillid)
    local textchattype = battletext_getchattype(actor, actor, actor.actorid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, actor.actorid, 0, skillid)
    battletext_addtextformatex("STR_SKILL_SUCC_SWITCHHPMP_INSTANT_A_TO_ME", "STR_SKILL_SUCC_SWITCHHPMP_INSTANT_A_TO_B", "STR_SKILL_SUCC_SWITCHHPMP_INSTANT_A_TO_SELF",
                                    "STR_SKILL_SUCC_SWITCHHPMP_INSTANT_ME_TO_SELF", "STR_SKILL_SUCC_SWITCHHPMP_INSTANT_ME_TO_B")
end

function battletext_protect(actor, attackerid, protecterid, skillid, val)
    local attacker = actormanager_getfromactorid(attackerid)
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, attackerid, protecterid, skillid)
    if protecterid == playerattr_info.actorid then
        if skillid ~= 0 then
            battletext_addtextformatex("STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_A_TO_ME", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_A_TO_B", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_A_TO_SELF",
                                    "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_ME_TO_SELF", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_ME_TO_B", val)
        else
            battletext_addtextformatex("STR_SKILL_SUCC_PROTECT_PROTECT_A_TO_ME", "STR_SKILL_SUCC_PROTECT_PROTECT_A_TO_B", "STR_SKILL_SUCC_PROTECT_PROTECT_A_TO_SELF",
                                    "STR_SKILL_SUCC_PROTECT_PROTECT_ME_TO_SELF", "STR_SKILL_SUCC_PROTECT_PROTECT_ME_TO_B", val)
        end
    else
        if skillid ~= 0 then
            battletext_addtextformatex("STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_HEAL_A_TO_ME", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_HEAL_A_TO_B", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_HEAL_A_TO_SELF",
                                    "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_HEAL_ME_TO_SELF", "STR_SKILL_SUCC_PROTECT_PROTECT_SKILL_HEAL_ME_TO_B", val)
        else
            battletext_addtextformatex("STR_SKILL_SUCC_PROTECT_PROTECT_HEAL_A_TO_ME", "STR_SKILL_SUCC_PROTECT_PROTECT_HEAL_A_TO_B", "STR_SKILL_SUCC_PROTECT_PROTECT_HEAL_A_TO_SELF",
                                    "STR_SKILL_SUCC_PROTECT_PROTECT_HEAL_ME_TO_SELF", "STR_SKILL_SUCC_PROTECT_PROTECT_HEAL_ME_TO_B", val)
        end
    end
end

function battletext_resurrect(actor, attackerid, skillid, positional)
    local attacker = actormanager_getfromactorid(attackerid)
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skill, actor, attackerid, 0, skillid)
    if positional then
        battletext_addtextformatex("STR_SKILL_SUCC_RESURRECTPOSITIONAL_A_TO_ME", "STR_SKILL_SUCC_RESURRECTPOSITIONAL_A_TO_B", "STR_SKILL_SUCC_RESURRECTPOSITIONAL_A_TO_SELF",
                                    "STR_SKILL_SUCC_RESURRECTPOSITIONAL_ME_TO_SELF", "STR_SKILL_SUCC_RESURRECTPOSITIONAL_ME_TO_B")
    else
        battletext_addtextformatex("STR_SKILL_SUCC_RESURRECT_A_TO_ME", "STR_SKILL_SUCC_RESURRECT_A_TO_B", "STR_SKILL_SUCC_RESURRECT_A_TO_SELF",
                                    "STR_SKILL_SUCC_RESURRECT_ME_TO_SELF", "STR_SKILL_SUCC_RESURRECT_ME_TO_B")
    end
end

function battletext_accuracy(actorid, attackerid, skillid, accuracy)
    local actor = actormanager_getfromactorid(actorid)
    if actor == nil then
        return
    end
    local attacker = actormanager_getfromactorid(attackerid)
    if attacker == nil then
        return
    end
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    local textchatbattletype = chatbattletype.attack
    if skillid ~= 0 then
        textchatbattletype = chatbattletype.skill
    end
    battletext_setinfo(textchattype, textchatbattletype, actor, attackerid, 0, skillid)
    local toward = battletext_gettoward(actor, attackerid)
    if accuracy == lambdaaccuracytype.dodge then
        if toward == battletext_casttoward.me_to_b then
            battletext_addtextformat("STR_MSG_COMBAT_DODGED_ME_TO_B", actor.attr.name)
        elseif toward == battletext_casttoward.a_to_me then
            battletext_addtextformat("STR_MSG_COMBAT_DODGED_A_TO_ME", attacker.attr.name)
        else
            battletext_addtextformat("STR_MSG_COMBAT_DODGED_A_TO_B", actor.attr.name, attacker.attr.name)
        end
    elseif accuracy == lambdaaccuracytype.parry then
        if toward == battletext_casttoward.me_to_b then
            battletext_addtextformat("STR_MSG_COMBAT_PARRY_ME_TO_B", actor.attr.name)
        elseif toward == battletext_casttoward.a_to_me then
            battletext_addtextformat("STR_MSG_COMBAT_PARRY_A_TO_ME", attacker.attr.name)
        else
            battletext_addtextformat("STR_MSG_COMBAT_PARRY_A_TO_B", actor.attr.name)
        end
    elseif accuracy == lambdaaccuracytype.block then
        if toward == battletext_casttoward.me_to_b then
            battletext_addtextformat("STR_MSG_COMBAT_BLOCK_ME_TO_B", actor.attr.name)
        elseif toward == battletext_casttoward.a_to_me then
            battletext_addtextformat("STR_MSG_COMBAT_BLOCK_A_TO_ME", attacker.attr.name)
        else
            battletext_addtextformat("STR_MSG_COMBAT_BLOCK_A_TO_B", actor.attr.name)
        end
    elseif accuracy == lambdaaccuracytype.resist then
        if skillid ~= 0 then
            local config_skill = csvskill_getfromid(skillid)
            if config_skill ~= nil then
                if config_skill.type == 0 then
                    if toward == battletext_casttoward.me_to_b then
                        battletext_addtextformat("STR_SKILL_DODGED_ME_TO_B")
                    elseif toward == battletext_casttoward.a_to_me then
                        battletext_addtextformat("STR_SKILL_DODGED_A_TO_ME")
                    else
                        battletext_addtextformat("STR_SKILL_DODGED_A_TO_B")
                    end
                else
                    if toward == battletext_casttoward.me_to_b then
                        battletext_addtextformat("STR_SKILL_RESISTED_ME_TO_B")
                    elseif toward == battletext_casttoward.a_to_me then
                        battletext_addtextformat("STR_SKILL_RESISTED_A_TO_ME")
                    else
                        battletext_addtextformat("STR_SKILL_RESISTED_A_TO_B")
                    end
                end
            end
        else
            if toward == battletext_casttoward.me_to_b then
                battletext_addtextformat("STR_MSG_COMBAT_RESISTED_ME_TO_B", actor.attr.name)
            elseif toward == battletext_casttoward.a_to_me then
                battletext_addtextformat("STR_MSG_COMBAT_RESISTED_A_TO_ME", attacker.attr.name)
            else
                battletext_addtextformat("STR_MSG_COMBAT_RESISTED_A_TO_B", actor.attr.name, attacker.attr.name)
            end
        end
    end
end

function battletext_arp(actorid, attackerid, skillid)
    local actor = actormanager_getfromactorid(actorid)
    if actor == nil then
        return
    end
    local attacker = actormanager_getfromactorid(attackerid)
    if attacker == nil then
        return
    end
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skillbuff, actor, attackerid, 0, skillid)
    local toward = battletext_gettoward(actor, attackerid)
    if toward == battletext_casttoward.me_to_b then
        battletext_addtextformat("STR_SKILL_IMMUNED_ME_TO_B")
    elseif toward == battletext_casttoward.a_to_me then
        battletext_addtextformat("STR_SKILL_IMMUNED_A_TO_ME")
    else
        battletext_addtextformat("STR_SKILL_IMMUNED_A_TO_B")
    end
end
