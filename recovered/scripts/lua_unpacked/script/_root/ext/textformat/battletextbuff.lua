
local function battletext_onbuffchange(textchattype, textbattletype, actor, buff, addbuff)
    local lambda = buff.config_buff.lambda
    if lambda ~= nil then
        battletext_setinfo(textchattype, textbattletype, actor, buff.attacker, 0, buff.skillid)
        local arraycount = lambda.arraysize
        for arrayindex=1,arraycount do
            local hidelog = csvconfig_getsubvalue(buff.config_buff.hidelog, arrayindex, configsubtype.int)
            if hidelog == 0 then
                local lambda2 = lambda.lambdaarray[arrayindex]
                local actioncount = lambda2.actioncount
                for lambdaindex=1,actioncount do
                    local sublambda = lambda2[lambdaindex]
                    for key, val in pairs(battletext_buffkey) do
                        if c_isaction(sublambda, key) then
                            if addbuff then
                                battletext_addtextformatex(val.add.a_to_me, val.add.a_to_b, val.add.a_to_self, val.add.me_to_self, val.add.me_to_b)
                            else
                                battletext_addtextformatex(val.remove.a_to_me, val.remove.a_to_b, val.remove.a_to_self, val.remove.me_to_self, val.remove.me_to_b, val)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function battletext_buffstat(textchattype, actor, buff)
    local statup = nil
    local statdown = nil
    local lambda = buff.config_buff.lambda
    if lambda == nil then
        return
    end
    battletext_setinfo(textchattype, chatbattletype.skillbuff, actor, buff.attacker, 0, buff.skillid)
    local arraycount = lambda.arraysize
    for arrayindex=1,arraycount do
        local hidelog = csvconfig_getsubvalue(buff.config_buff.hidelog, arrayindex, configsubtype.int)
        if hidelog == 0 then
            local lambda2 = lambda.lambdaarray[arrayindex]
            local actioncount = lambda2.actioncount
            for lambdaindex=1,actioncount do
                local sublambda = lambda2[lambdaindex]
                local action = sublambda.action
                if action == "deform" then
                    local config_npc = csvnpc_getfromid(sublambda.variable[1].integer)
                    if config_npc ~= nil then
                        battletext_addtextformatex("STR_SKILL_SUCC_DEFORM_A_TO_ME", "STR_SKILL_SUCC_DEFORM_A_TO_B", "STR_SKILL_SUCC_DEFORM_A_TO_SELF",
                                "STR_SKILL_SUCC_DEFORM_ME_TO_SELF", "STR_SKILL_SUCC_DEFORM_ME_TO_B", config_npc.name)
                    end
                elseif action == "hate" then
                    if sublambda.variable[1].integer > 0 then
                        battletext_addtextformatex("STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_ME", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_B", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_SELF",
                                "STR_SKILL_SUCC_CHANGEHATEONATTACKED_ME_TO_SELF", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_ME_TO_B", c_textformat("TIPS_BUFFSTAT_INC"))
                    else
                        battletext_addtextformatex("STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_ME", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_B", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_A_TO_SELF",
                                "STR_SKILL_SUCC_CHANGEHATEONATTACKED_ME_TO_SELF", "STR_SKILL_SUCC_CHANGEHATEONATTACKED_ME_TO_B", c_textformat("TIPS_BUFFSTAT_DEC"))
                    end
                elseif string.endwith(action, "+") then
                    local key = string.sub(action, 1, #action - 1)
                    local str = battletext_attr[key]
                    if str ~= nil then
                        if statup ~= nil then
                            statup = statup .. c_textformat("UI_SPLIT") .. c_textformat(str)
                        else
                            statup = c_textformat(str)
                        end
                    end
                elseif string.endwith(action, "-") then
                    local key = string.sub(action, 1, #action - 1)
                    local str = battletext_attr[key]
                    if str ~= nil then
                        if statdown ~= nil then
                            statdown = statdown .. c_textformat("UI_SPLIT") .. c_textformat(str)
                        else
                            statdown = c_textformat(str)
                        end
                    end
                end
            end
        end
    end

    if statup ~= nil then
        battletext_addtextformatex("STR_SKILL_SUCC_STATUP_A_TO_ME", "STR_SKILL_SUCC_STATUP_A_TO_B", "STR_SKILL_SUCC_STATUP_A_TO_SELF",
                                "STR_SKILL_SUCC_STATUP_ME_TO_SELF", "STR_SKILL_SUCC_STATUP_ME_TO_B", statup)
    end
    if statdown ~= nil then
        battletext_addtextformatex("STR_SKILL_SUCC_STATDOWN_A_TO_ME", "STR_SKILL_SUCC_STATDOWN_A_TO_B", "STR_SKILL_SUCC_STATDOWN_A_TO_SELF",
                                "STR_SKILL_SUCC_STATDOWN_ME_TO_SELF", "STR_SKILL_SUCC_STATDOWN_ME_TO_B", statdown)
    end
end

function battletext_addbuff(actor, buff)
    local attacker = actormanager_getfromactorid(buff.attacker)
    local textchattype = battletext_getchattype(actor, attacker, buff.attacker)
    if textchattype == nil then
        return
    end
    battletext_onbuffchange(textchattype, chatbattletype.skillbuff, actor, buff, true)
    if buff.config_skill ~= nil and buff.config_skill.spellway == csvskillspellway.toggle then
        battletext_setinfo(textchattype, chatbattletype.skillbuff, actor, buff.attacker, 0, buff.skillid)
        battletext_addtextformatex("STR_SKILL_SUCC_AURA_A_TO_ME", "STR_SKILL_SUCC_AURA_A_TO_B", "STR_SKILL_SUCC_AURA_A_TO_SELF",
                                "STR_SKILL_SUCC_AURA_ME_TO_SELF", "STR_SKILL_SUCC_AURA_ME_TO_B")
    end
    battletext_buffstat(textchattype, actor, buff)
end

function battletext_removebuff(actor, buff)
    local attacker = actormanager_getfromactorid(buff.attacker)
    local textchattype = battletext_getchattype(actor, attacker, buff.attacker)
    if textchattype == nil then
        return
    end
    battletext_onbuffchange(textchattype, chatbattletype.skillbuff, actor, buff, false)
    if buff.config_skill ~= nil and buff.config_skill.spellway == csvskillspellway.toggle then
        battletext_setinfo(textchattype, chatbattletype.skillbuff, actor, buff.attacker, 0, buff.skillid)
        battletext_addtextformatex("STR_SKILL_SUCC_AURA_END_A_TO_ME", "STR_SKILL_SUCC_AURA_END_A_TO_B", "STR_SKILL_SUCC_AURA_END_A_TO_SELF",
                                "STR_SKILL_SUCC_AURA_END_ME_TO_SELF", "STR_SKILL_SUCC_AURA_END_ME_TO_B")
    end
end

function battletext_addbuffdot(actor, attackerid, action, skillid, val, crit)
    local attacker = actormanager_getfromactorid(attackerid)
    
    local textchattype = battletext_getchattype(actor, attacker, attackerid)
    if textchattype == nil then
        return
    end
    local textkey = battletext_buffdot[action]
    if textkey ~= nil then
        if action == buffpointtype.reflector then
            if attacker == nil then
                return
            end
            battletext_setinfo(textchattype, chatbattletype.skillperiod, attacker, attackerid, 0, skillid)
            if attacker:isme() then
                battletext_addtextformat(textkey.to_me, val)
            else
                battletext_addtextformat(textkey.to_b, val)
            end
        else
            battletext_setinfo(textchattype, chatbattletype.skillperiod, actor, attackerid, 0, skillid)
            if actor:isme() then
                if crit == 1 then
                    battletext_addtextformat(textkey.to_me, val, nil, nil, nil, c_textformat("TIPS_CRITICAL"))
                else
                    battletext_addtextformat(textkey.to_me, val)
                end
            else
                if crit == 1 then
                    battletext_addtextformat(textkey.to_b, val, nil, nil, nil, c_textformat("TIPS_CRITICAL"))
                else
                    battletext_addtextformat(textkey.to_b, val)
                end
            end
        end
    end
end
