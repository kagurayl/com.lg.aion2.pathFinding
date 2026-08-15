
function SC_SkillStigmaOpen(msg)
    skill_stigma_open()
end

function SC_SkillStigma(msg)
    playerattr_stigma[msg.slot + 1] = msg.itemid
    skill_stigma_updateui()
end

function SC_SkillStigmaRemoveFail(msg)
    local config_itemstigma = csvitem_getfromid(msg.itemid)
    local config_itemrequired = csvitem_getfromid(msg.itemrequired)
    if config_itemstigma ~= nil and config_itemrequired ~= nil then
        chat_addsystemalert(c_textformat("SITMGA_OFF_REQUIRED", config_itemrequired.name, config_itemstigma.name))
    end
end

function SC_SkillAdd(msg)
    if not playerskill_available(msg.skillid) then
        playerattr_skill[msg.skillid] = msg.skillid
        local config_skill = csvskill_getfromid(msg.skillid)
        if config_skill ~= nil then
            chat_addsystemalert(c_textformat("SKILL_TIPS_GETSKILL", config_skill.name))
        end
    end
    skillbar_updateui()
    actionbar_updateui()
    if not tutorial_getfinish(tutorialid.skill) then
        uimanager_closecover(uiflag.placeall, -1)
        tutorial_start(tutorialid.skill)
    end
end

function SC_SkillRemove(msg)
    playerattr_skill[msg.skillid] = nil
    skillbar_updateui()
    actionbar_updateui()
end

function SC_SkillList(msg)
    for i=1,#msg.skillid do
        playerattr_skill[msg.skillid[i]] = msg.skillid[i]
    end
end

function SC_SkillSlotList(msg)
    playerattr_skillslot = msg.skillbar
    for i=1,#playerattr_skillslot do
        playerattr_skillslot[i].page = playerattr_skillslot[i].page + 1
        playerattr_skillslot[i].slot = playerattr_skillslot[i].slot + 1
    end
    playerattr_actionslot = msg.actionbar
    for i=1,#playerattr_actionslot do
        playerattr_actionslot[i].slot = playerattr_actionslot[i].slot + 1
    end
    skillbar_updateui()
    actionbar_updateui()
end

function SC_SkillBarSlot(msg)
    local slot = nil
    for i=1,#playerattr_skillslot do
        if playerattr_skillslot[i].page == msg.page + 1 and playerattr_skillslot[i].slot == msg.slot + 1 then
            slot = playerattr_skillslot[i]
            break
        end
    end
    if slot == nil then
        slot = {}
        slot.page = msg.page + 1
        slot.slot = msg.slot + 1
        playerattr_skillslot[#playerattr_skillslot + 1] = slot
    end
    slot.type = msg.type
    slot.skillid = msg.skillid
    slot.uuid = msg.uuid
    skill_main_updateui()
    skill_setting_updateui()
    skillbar_updateui()
end

function SC_SkillBarSlotRemove(msg)
    for i=1,#playerattr_skillslot do
        if playerattr_skillslot[i].page == msg.page + 1 and playerattr_skillslot[i].slot == msg.slot + 1 then
            table.remove(playerattr_skillslot, i)
            skill_main_updateui()
            skill_setting_updateui()
            skillbar_updateui()
            break
        end
    end
end

function SC_ActionBarSlot(msg)
    local slot = nil
    for i=1,#playerattr_actionslot do
        if playerattr_actionslot[i].slot == msg.slot + 1 then
            slot = playerattr_actionslot[i]
            break
        end
    end
    if slot == nil then
        slot = {}
        slot.slot = msg.slot + 1
        playerattr_actionslot[#playerattr_actionslot + 1] = slot
    end
    slot.type = msg.type
    slot.skillid = msg.skillid
    slot.uuid = msg.uuid
    skill_main_updateui()
    skill_setting_updateui()
    actionbar_updateui()
end

function SC_ActionBarSlotRemove(msg)
    for i=1,#playerattr_actionslot do
        if playerattr_actionslot[i].slot == msg.slot + 1 then
            table.remove(playerattr_actionslot, i)
            skill_main_updateui()
            skill_setting_updateui()
            actionbar_updateui()
            break
        end
    end
end

function SC_SkillSpell(msg)
    local actor = actormanager_getfromactorid(msg.attacker)
    if actor == nil then
        return
    end
    actor:clearspell()
    local config_skill = csvskill_getfromid(msg.skillid)
    if config_skill ~= nil then
        actor:setskillbattle(config_skill)
        if config_skill.anim ~= "0" then
            actor.actionmain.spelltype = playerspellstate.spellskill
            actor.actionmain.config_skill = config_skill
            actor.battle.spelltime = msg.spelltime
            actor.battle.spelltimestart = time_game
            actor.actionmain.target = msg.target
        end
        if actor:isme() then
            playerbattleauto_pauseattack(msg.spelltime + 0.5)
            playerskillpreset_updateindex(msg.skillid)
            spell_create(config_skill.name, spellcolor.normal, time_game, msg.spelltime)
        end
        if csvskill_isattackskill(config_skill) and msg.target == playerattr_info.actorid then
            actormanager_setattackme(actor)
        end
    end
end

function SC_SpellComplete(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor == nil then
        return
    end
    if actor.actionmain.spelltype == playerspellstate.spellitembind then
        actor.actionmain.spelltype = playerspellstate.spellitembindend
        actor:createvfx(EffectSoulbindSuccess, vfx_bind_center, true)
    else
        actor:clearspell()
    end
    if actor:isme() then
        spell_setstate(spellstate.complete)
    end
end

function SC_SpellCancel(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        actor:clearspell()
    end

    if msg.actorid == playerattr_info.actorid then
        spell_setstate(spellstate.cancel)
    end
end

function SC_ProtectHurt(msg)
    local attacker = actormanager_getfromactorid(msg.attacker)
    local protector = actormanager_getfromactorid(msg.protector)
    if protector ~= nil then
        protector.attr.hp = msg.current
        if protector:overlayable(msg.attacker, lambdapointtype.hpdec) then
            overlay_addpoint(protector, lambdapointtype.hpdec, nil, msg.val)
        end
        local target = actormanager_getfromactorid(msg.target)
        if target ~= nil then
            battletext_protect(target, msg.attacker, msg.protector, msg.skillid, math.tointegerfloor(msg.val))
        end
    end
end
