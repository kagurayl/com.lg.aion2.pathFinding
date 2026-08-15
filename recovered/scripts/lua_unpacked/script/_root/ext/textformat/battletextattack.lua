
function battletext_addnormalattack(actor, attackerid, val, accuracy)
    local attacker = actormanager_getfromactorid(attackerid)
    if attacker == nil then
        return
    end
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    if accuracy == lambdaaccuracytype.shield or accuracy == lambdaaccuracytype.protect then
        battletext_setinfo(textchattype, chatbattletype.defense, actor, attackerid, 0, 0)
        local toward = battletext_gettoward(actor, attackerid)
        if toward == battletext_casttoward.me_to_b then
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_ME_TO_B")
        elseif toward == battletext_casttoward.a_to_me then
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_A_TO_ME")
        else
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_A_TO_B")
        end
    end
    if val <= 0 then
        return
    end
    if accuracy == lambdaaccuracytype.crit then
        battletext_setinfo(textchattype, chatbattletype.critical, actor, attackerid, 0, 0)
        if attackerid == playerattr_info.actorid then
            battletext_addtextformat("STR_MSG_COMBAT_MY_CRITICAL", actor.attr.name, val)
        elseif actor:isme() then
            battletext_addtextformat("STR_MSG_COMBAT_ENEMY_ATTACK", attacker.attr.name, val)
        else
            battletext_addtextformat("STR_MSG_COMBAT_PARTY_CRITICAL", attacker.attr.name, actor.attr.name, val)
        end
    else
        battletext_setinfo(textchattype, chatbattletype.attack, actor, attackerid, 0, 0)
        if attackerid == playerattr_info.actorid then
            battletext_addtextformat("STR_MSG_COMBAT_MY_ATTACK", actor.attr.name, val)
        elseif actor:isme() then
            battletext_addtextformat("STR_MSG_COMBAT_ENEMY_ATTACK", attacker.attr.name, val)
        else
            battletext_addtextformat("STR_MSG_COMBAT_PARTY_ATTACK", attacker.attr.name, actor.attr.name, val)
        end
    end
end

function battletext_addskillattack(actor, attackerid, action, skillid, val, accuracy)
    local attacker = actormanager_getfromactorid(attackerid)
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    if accuracy == lambdaaccuracytype.shield or accuracy == lambdaaccuracytype.protect then
        battletext_setinfo(textchattype, chatbattletype.defense, actor, attackerid, 0, skillid)
        local toward = battletext_gettoward(actor, attackerid)
        if toward == battletext_casttoward.me_to_b then
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_SKILL_ME_TO_B")
        elseif toward == battletext_casttoward.a_to_me then
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_SKILL_A_TO_ME")
        else
            battletext_addtextformat("STR_SKILL_SUCC_SHIELD_PROTECT_SKILL_A_TO_B")
        end
    end
    if val > 0 then
        local textkey = battletext_skillattack[action]
        if textkey ~= nil then
            battletext_setinfo(textchattype, chatbattletype.skill, actor, attackerid, 0, skillid)
            if accuracy == lambdaaccuracytype.crit then
                battletext_addtextformatex(textkey.a_to_me, textkey.a_to_b, textkey.a_to_self, textkey.me_to_self, textkey.me_to_b, val, 0, 0, 0, c_textformat("TIPS_CRITICAL"))
            else
                battletext_addtextformatex(textkey.a_to_me, textkey.a_to_b, textkey.a_to_self, textkey.me_to_self, textkey.me_to_b, val)
            end
        end
    end
end

function battletext_itempoint(actor, action, itemid, val)
    local texttype = battletext_skillattack[action]
    local isme = actor.actorid == playerattr_info.actorid
    local textkey = nil
    if texttype.type == lambdapointtype.hpinc then
        textkey = math.ternary(isme, "STR_MSG_HEAL_TO_ME", "STR_MSG_HEAL_TO_OTHER")
    elseif texttype.type == lambdapointtype.mpinc then
        textkey = math.ternary(isme, "STR_MSG_MPHEAL_TO_ME", "STR_MSG_MPHEAL_TO_OTHER")
    elseif texttype.type == lambdapointtype.fpinc then
        textkey = math.ternary(isme, "STR_MSG_FPHEAL_TO_ME", "STR_MSG_FPHEAL_TO_OTHER")
    else
        return false
    end
    if not c_textkey(textkey) then
        return true
    end
    local textchattype = math.ternary(isme, chatchanneltype.combatattack, chatchanneltype.combatplayerattack)
    local desc = textformat_gettext(c_textformat(textkey), function(key)
        if key == "num0" or key == "num1" then
            return val
        elseif key == 0 then
            return actor.attr.name
        end
    end)
    if #desc > 0 then
        chat_addchat(0, nil, 0, nil, textchattype + chatbattletype.attack, desc, nil)
    end
    return true
end
