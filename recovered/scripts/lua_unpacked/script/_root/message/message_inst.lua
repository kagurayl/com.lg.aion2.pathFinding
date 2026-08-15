
local function inst_getattackerinst(attackerid, instid)
    local attacker = actormanager_getfromactorid(attackerid)
    local inst = nil
    if attacker ~= nil then
        inst = attacker:getattackerinst(instid)
    end
    return attacker, inst
end

function SC_NormalAttackStart(msg)
    local attacker = actormanager_getfromactorid(msg.attacker)
    if attacker == nil then
        return
    end
    local target = actormanager_getfromactorid(msg.target)
    if target == nil then
        return
    end
    if attacker:isme() then
        playerbattleauto_setattacktime(time_game + playerbattle_getnormalattackdelay())
        playerbattle_updatebattlestate()
    end
    attacker:setbattle(1, false)
    actionmanager_setattackaction(attacker, msg.target)
    
    local aliasindex = msg.animindex + 1
    local anim = nil
    if attacker.attr.movetype == playermovestate.fly then
        anim = animlist["xattack" .. aliasindex]
    else
        anim = animlist["cattack" .. aliasindex]
    end
    local animname = attacker:getanimlistname(anim)
    local alias = attacker:getanimalias(animname)
    if alias == nil then
        return
    end
    attacker.actionmain.animname = animname
    attacker.actionmain.animspeed = attacker:getattackanimspeed()

    local inst = {}
    inst.instid = msg.instid
    inst.timestart = time_game
    inst.marker = alias.marker
    inst.animspeed = attacker.actionmain.animspeed
    attacker:addattackerinst(inst)

    if msg.ammo > 0 and #inst.marker.hitpoint > 0 then
        local animtime = inst.marker.hitpoint[1].time / inst.animspeed
        if msg.ammo > animtime then
            local config_weapon = attacker.attr.config_weapon
            if config_weapon ~= nil then
                local fxammo = nil
                if config_weapon.itemtype == csvitemtype.weapon_book then
                    fxammo = EffectSkillMageAmmo
                elseif config_weapon.itemtype == csvitemtype.weapon_bow then
                    fxammo = EffectSkillMageBow
                end
                if fxammo ~= nil then
                    local ammo = {}
                    ammo.fxammo = fxammo
                    ammo.targetid = msg.target
                    ammo.timelength = msg.ammo - animtime
                    ammo.timestart = time_game + animtime
                    attacker.battleammo[#attacker.battleammo + 1] = ammo
                end
            end
        end
    end
    if target:isme() then
        actormanager_setattackme(attacker)
    end
end

function SC_NormalAttackHurt(msg)
    local target = actormanager_getfromactorid(msg.target)
    if target == nil then
        return
    end
    battletext_addnormalattack(target, msg.attacker, math.tointegerfloor(msg.hurt), msg.accuracy)
    local attacker, inst = inst_getattackerinst(msg.attacker, msg.instid)
    local valdelay = target:setpoint(lambdapointtype.hpdec, msg.current)
    if inst == nil or inst.marker == nil or inst.marker.hitpoint == nil then
        if target:overlayable(msg.attacker, lambdapointtype.hpdec) then
            overlay_addpoint(target, lambdapointtype.hpdec, msg.accuracy, msg.hurt)
        end
        actionmanager_setdamageaction(target, msg.accuracy)
        return
    end
    if #inst.marker.hitpoint > 1 then
        local valdisplay = csvanimalias_splithitpoint(#inst.marker.hitpoint, msg.hurt, msg.randseed)
        for i=1,#valdisplay do
            local animtime = inst.timestart + inst.marker.hitpoint[i].time / inst.animspeed
            target:createdelaypoint(msg.attacker, animtime, lambdapointtype.hpdec, msg.accuracy, valdisplay[i], valdelay, true)
            target:createhitvfx(attacker, nil, msg.accuracy, msg.battery, animtime)
            valdelay = valdelay - valdelay
        end
    else
        local animtime = inst.timestart + inst.marker.hitpoint[1].time / inst.animspeed
        target:createdelaypoint(msg.attacker, animtime, lambdapointtype.hpdec, msg.accuracy, msg.hurt, valdelay, true)
        target:createhitvfx(attacker, nil, msg.accuracy, msg.battery, animtime)
    end
end

function SC_SkillCast(msg)
    local attacker = actormanager_getfromactorid(msg.attacker)
    if attacker == nil then
        return
    end
    attacker:setcostpoint(msg.hp, msg.mp, msg.dp)
    local config_skill = csvskill_getfromid(msg.skillid)
    if config_skill == nil then
        return
    end
    attacker:setskillbattle(config_skill)
    actionmanager_setcastaction(attacker, msg.instid, config_skill)
    if msg.maintarget ~= 0 and msg.attacker ~= msg.maintarget and playerskill_selectrotate(config_skill) then
        local target = actormanager_getfromactorid(msg.maintarget)
        if target ~= nil then
            attacker:setactorlook(target)
        end
    end
    local animname, animspeed = attacker:getskillanimname(csvskillanimtype.fire, config_skill)
    if animname == nil then
        return
    end
    local alias = attacker:getanimalias(animname)
    if alias == nil or alias.marker == nil or alias.marker.hitpoint == nil then
        return
    end
    local inst = {}
    inst.instid = msg.instid
    inst.maintarget = msg.maintarget
    inst.config_skill = config_skill
    inst.timestart = time_game
    inst.hit = {}
    attacker:addattackerinst(inst)
    
    animspeed = animspeed * attacker:getattackanimspeed()
    local casttime = alias.marker.hitpoint[#alias.marker.hitpoint].time / animspeed
    local castfinish = time_game + casttime + 0.2
    if attacker:isme() then
        playerskill_setgcd(casttime)
        if msg.maintarget ~= 0 then
            if config_skill.autoattack == 0 then
                playerbattleauto_setattacktime(castfinish)
            elseif config_skill.autoattack == 1 then
                if msg.maintarget ~= playerattr_info.actorid then
                    playerbattleauto_setattacktarget(msg.maintarget)
                end
                playerbattleauto_setattacktime(castfinish)
            elseif config_skill.autoattack == 2 then
                playerbattleauto_stopattack()
            end
        end
    end
    if config_skill.movable == 0 then
        attacker.actionmain.movabletime = castfinish
    end
    
    local fxprehittime = 0.0
    if config_skill.fxprehit ~= "0" then
        local fxprehit = csvconfig_getsubvalue(config_skill.fxprehit, 3, configsubtype.flt)
        if fxprehit ~= nil then
            fxprehittime = fxprehit
        end
    end
    local splash = config_skill.splash > 0
    local splashammotime = 0
    if splash then
        local ammo = nil
        for i=1,#msg.ammo do
            if msg.ammo[i].target == msg.maintarget then
                ammo = msg.ammo[i]
                break
            end
        end
        if ammo ~= nil and ammo.time > 0.0 and config_skill.fxammo ~= "0" then
            local target = actormanager_getfromactorid(msg.maintarget)
            if target ~= nil then
                for i=1,#alias.marker.hitpoint do
                    local animtime = alias.marker.hitpoint[i].time / animspeed
                    local timeprehit = time_game + animtime + ammo.time
                    local fxammo = {}
                    fxammo.fxammo =  config_skill.fxammo
                    fxammo.targetid = ammo.target
                    fxammo.timelength = ammo.time
                    fxammo.timestart = time_game + animtime
                    attacker.battleammo[#attacker.battleammo + 1] = fxammo
                    splashammotime = ammo.time
                    target:createprehitvfx(msg.attacker, config_skill, timeprehit)
                end
            end
        end
    end
    for i=1,#alias.marker.hitpoint do
        local animtime = alias.marker.hitpoint[i].time / animspeed
        for j=1,#msg.ammo do
            local ammo = msg.ammo[j]
            local target = actormanager_getfromactorid(ammo.target)
            if target ~= nil then
                local timeprehit = time_game + animtime
                if not splash then
                    if ammo.time > 0.0 and config_skill.fxammo ~= "0" then
                        local fxammo = {}
                        fxammo.fxammo =  config_skill.fxammo
                        fxammo.targetid = ammo.target
                        fxammo.timelength = ammo.time
                        fxammo.timestart = time_game + animtime
                        attacker.battleammo[#attacker.battleammo + 1] = fxammo
                        timeprehit = timeprehit + ammo.time
                    end
                    target:createprehitvfx(msg.attacker, config_skill, timeprehit)
                else
                    timeprehit = timeprehit + splashammotime
                end
                local hit = {}
                hit.target = ammo.target
                if not splash or hit.target == msg.maintarget then
                    hit.timehit = timeprehit + fxprehittime
                end
                hit.timeoverlay = timeprehit + fxprehittime
                inst.hit[#inst.hit + 1] = hit
            end
        end
    end
    if csvskill_isattackskill(config_skill) and msg.maintarget == playerattr_info.actorid then
        actormanager_setattackme(attacker)
    end
end

function SC_SkillAccuracy(msg)
    battletext_accuracy(msg.actorid, msg.attacker, msg.skillid, msg.accuracy)
    local target = actormanager_getfromactorid(msg.actorid)
    if target == nil then
        return
    end
    local attacker, inst = inst_getattackerinst(msg.attacker, msg.instid)
    if inst == nil or inst.marker == nil or inst.marker.hitpoint == nil then
        if target:overlayable(msg.attacker, lambdapointtype.hpdec) then
            overlay_addpoint(target, lambdapointtype.hpdec, msg.accuracy, 0)
        end
        actionmanager_setdamageaction(target, msg.accuracy)
        return
    end
    local animtime = inst.timestart + inst.marker.hitpoint[1].time / inst.animspeed
    target:createdelaypoint(msg.attacker, animtime, lambdapointtype.hpdec, msg.accuracy, 0.0, 0.0, true)
end

function SC_SkillBuffARP(msg)
    battletext_arp(msg.actorid, msg.attacker, msg.skillid)
end

local function lambdapoint_prehit(attacker, actor, inst, convertaction, totalval, msg)
    local valdelay = actor:setpoint(convertaction, msg.current)
    local overlayindex = 1
    for i=1,#inst.hit do
        local hit = inst.hit[i]
        if hit.target == actor.actorid then
            if overlayindex <= #msg.val then
                actor:createdelaypoint(msg.attacker, hit.timeoverlay, convertaction, msg.accuracy, msg.val[overlayindex], valdelay, false)
                overlayindex = overlayindex + 1
                valdelay = valdelay - valdelay
            end
            if hit.timehit ~= nil then
                actor:createhitvfx(attacker, inst.config_skill, msg.accuracy, 0, hit.timehit)
                hit.timehit = nil
            end
        end
    end
    for i=overlayindex,#msg.val do
        actor:createdelaypoint(msg.attacker, 0.0, convertaction, msg.accuracy, msg.val[overlayindex], valdelay, false)
        overlayindex = overlayindex + 1
        valdelay = valdelay - valdelay
    end
end
local function lambdapoint_raw(attacker, actor, convertaction, totalval, msg)
    actor:setpoint(convertaction, msg.current)
    if actor:overlayable(msg.attacker, convertaction) then
        for i=1,#msg.val do
            overlay_addpoint(actor, convertaction, msg.accuracy, msg.val[i])
        end
    end
    local config_skill = csvskill_getfromid(msg.skillid)
    if config_skill ~= nil then
        actor:createhitvfx(attacker, config_skill, msg.accuracy, 0, 0)
    end
    if convertaction == lambdapointtype.hpdec then
        actionmanager_setdamageaction(actor, msg.accuracy)
    end
end
function SC_LambdaPoint(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor == nil then
        return
    end
    local convertaction = battletext_skillattack[msg.action]
    if convertaction ~= nil then
        convertaction = convertaction.type
    else
        convertaction = msg.action
    end
    local totalval = 0
    for i=1,#msg.val do
        totalval = totalval + msg.val[i]
    end
    
    local skillpoint = true
    if msg.itemid ~= 0 then
        if battletext_itempoint(actor, msg.action, msg.itemid, totalval) then
            skillpoint = false
        end
    end
    if skillpoint then
        battletext_addskillattack(actor, msg.attacker, msg.action, msg.skillid, math.tointegerfloor(totalval), msg.accuracy)
    end

    local attacker, inst = inst_getattackerinst(msg.attacker, msg.instid)
    if inst ~= nil then
        lambdapoint_prehit(attacker, actor, inst, convertaction, totalval, msg)
    else
        lambdapoint_raw(attacker, actor, convertaction, totalval, msg)
    end
end

function SC_LambdaDrain(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor == nil then
        return
    end
    actor.attr.hp = msg.hpcurrent
    if actor:isplayer() then
        actor.attr.mp = msg.mpcurrent
    end
    if msg.hp > 0.0 then
        if actor:isme() then
            overlay_addpoint(actor, lambdapointtype.hpinc, nil, msg.hp)
        end
        battletext_drain(actor, msg.action, msg.skillid, math.tointegerfloor(msg.hp), true)
    end
    if msg.mp > 0.0 then
        if actor:isme() then
            overlay_addpoint(actor, lambdapointtype.mpinc, nil, msg.mp)
        end
        battletext_drain(actor, msg.action, msg.skillid, math.tointegerfloor(msg.mp), false)
    end
end

function SC_LambdaVFX(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor == nil then
        return
    end
    local attacker, inst = inst_getattackerinst(msg.attacker, msg.instid)
    if inst ~= nil then
        for i=1,#inst.hit do
            local hit = inst.hit[i]
            if hit.timehit ~= nil and hit.target == msg.actorid then
                actor:createhitvfx(attacker, inst.config_skill, lambdaaccuracytype.normal, 0, hit.timehit)
                hit.timehit = nil    
            end
        end
    else
        local config_skill = csvskill_getfromid(msg.skillid)
        if config_skill ~= nil then
            actor:createhitvfx(attacker, config_skill, lambdaaccuracytype.normal, 0, 0)
        end
    end
end

function SC_BuffDot(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        local pointtype = nil
        local pointsign = 0
        local pointprefix = nil
        local convertaction = battletext_buffdot[msg.action]
        if convertaction ~= nil then
            convertaction = convertaction.type
        else
            convertaction = msg.action
        end
        if convertaction == buffpointtype.hpinc then
            actor.attr.hp = msg.current
            pointtype = overlaytype.hpinc
        elseif convertaction == buffpointtype.hpdec  then
            actor.attr.hp = msg.current
            if actor:isme() then
                pointtype = overlaytype.hurt
            else
                pointtype = overlaytype.damage
            end
            if msg.crit == 1 then
                if actor:isme() then
                    pointprefix = overlayprefix.critical_r
                else
                    pointprefix = overlayprefix.critical_w
                end
            end
        elseif convertaction == buffpointtype.mpinc then
            actor.attr.mp = msg.current
            pointtype = overlaytype.mpinc
            pointsign = 1
        elseif convertaction == buffpointtype.mpdec then
            actor.attr.mp = msg.current
            pointtype = overlaytype.mpinc
            pointsign = -1
        elseif convertaction == buffpointtype.dpinc then
            actor.attr.dp = msg.current
        elseif convertaction == buffpointtype.dpdec then
            actor.attr.dp = msg.current
        elseif convertaction == buffpointtype.fpinc then
            actor.attr.fp = msg.current
        elseif convertaction == buffpointtype.fpdec then
            actor.attr.fp = msg.current
        end
        if pointtype ~= nil and actor:overlayable(msg.attacker, pointtype) then
            overlay_add(actor.actorid, pointtype, overlayanim.standard, pointprefix, pointsign, msg.val)
        end
        local config_skill = csvskill_getfromid(msg.skillid)
        if config_skill ~= nil then
            actor:createskillfxc(config_skill.fxhitinterval, bit.bor(vfxflag.free, vfxflag.spawnposition, vfxflag.hidewithbuff))
        end
        battletext_addbuffdot(actor, msg.attacker, msg.action, msg.skillid, math.tointegerfloor(msg.val), msg.crit)
    end
end

function SC_LambdaBuff(msg)
    local config_buff = csvskillbuff_getfromid(msg.buffid)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor == nil or config_buff == nil then
        return
    end
    local buff = {}
    buff.itemid = msg.itemid
    buff.skillid = msg.skillid
    buff.buffid = msg.buffid
    buff.skilllevel = msg.skilllevel
    buff.config_skill = csvskill_getfromid(msg.skillid)
    buff.config_buff = config_buff
    buff.buffinstid = msg.buffinstid
    buff.timestart = 0.0
    buff.timelength = msg.length
    buff.timeout = time_game + buff.timelength
    buff.vfxcreated = false
    buff.attacker = msg.attacker
    playerbuff_initview(buff)
    local attacker, inst = inst_getattackerinst(msg.attacker, msg.instid)
    if inst ~= nil then
        if inst.hit ~= nil then
            if #inst.hit > 0 then
                for i=1,#inst.hit do
                    local hit = inst.hit[i]
                    if hit.target == actor.actorid and hit.timehit ~= nil then
                        actor:createhitvfx(attacker, inst.config_skill, lambdaaccuracytype.normal, 0, hit.timehit)
                        hit.timehit = nil
                        buff.timestart = hit.timeoverlay
                        buff.timeout = buff.timestart + buff.timelength
                        break
                    end
                end
            end
        else
            local animtime = inst.timestart + inst.marker.hitpoint[1].time / inst.animspeed
            buff.timestart = animtime
            buff.timeout = buff.timestart + buff.timelength
        end
    end
    if buff.timestart <= time_game then
        actor:applybuff(buff)
        if msg.itemid == 0 then
            battletext_addbuff(actor, buff)
        end
    else
        actor.battleprebuff[#actor.battleprebuff + 1] = buff
    end
end

function SC_LambdaBuffRemove(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        for i=1,#actor.buff do
            if actor.buff[i].buffinstid == msg.buffinstid then
                actor:removebuffvfx(actor.buff[i])
                battletext_removebuff(actor, actor.buff[i])
                table.remove(actor.buff, i)
                break
            end
        end
        for i=1,#actor.battleprebuff do
            if actor.battleprebuff[i].buffinstid == msg.buffinstid then
                table.remove(actor.battleprebuff, i)
                break
            end
        end
    end
end

function SC_LambdaBuffRemoveList(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        for i=1,#msg.buffinstid do
            local buffinstid = msg.buffinstid[i]
            for j=1,#actor.buff do
                if actor.buff[j].buffinstid == buffinstid then
                    actor:removebuffvfx(actor.buff[j])
                    battletext_removebuff(actor, actor.buff[j])
                    table.remove(actor.buff, j)
                    break
                end
            end
            for i=1,#actor.battleprebuff do
                if actor.battleprebuff[i].buffinstid == buffinstid then
                    table.remove(actor.battleprebuff, i)
                    break
                end
            end
        end
    end
end

function SC_LambdaAttackSkill(msg)
    playerattr_qte.attackskillid = 0
    if msg.qtecategory ~= 0 then
        local config_skill = csvskill_getfromid(msg.qtecategory)
        if config_skill ~= nil then
            local qtesublink = csvskill_getqtesublink(config_skill)
            if qtesublink ~= nil then
                for i=1,#qtesublink do
                    if playerskill_gettoplevelavailable(qtesublink[i]) ~= nil then
                        playerattr_qte.attackskillid = config_skill.category
                        if playerattr_qte.attackskillid == 0 then
                            playerattr_qte.attackskillid = config_skill.id
                        end
                        playerattr_qte.attacktimestart = time_game
                        break
                    end
                end
            end
        end
    end
    playerskillpreset_updateindex(msg.skillid)
end

function SC_LambdaCounterQte(msg)
    local counterskillid = 0
    if msg.type == lambdaaccuracytype.dodge then
        counterskillid = skill_counter_dodge
    elseif msg.type == lambdaaccuracytype.parry then
        counterskillid = skill_counter_parry
    elseif msg.type == lambdaaccuracytype.block then
        counterskillid = skill_counter_block
    else
        return
    end
    playerattr_qte.countertype = counterskillid
    playerattr_qte.countertimestart = time_game
end

function SC_LambdaRemoveAttackQte(msg)
    playerattr_qte.attackskillid = 0
end

function SC_LambdaSummon(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        battletext_summon(actor, msg.skillid, msg.npcid)
    end
end

function SC_LambdaThreat(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        battletext_threat(actor, msg.skillid, msg.threat)
    end
end

function SC_LambdaDispel(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        battletext_dispel(actor, msg.attacker, msg.skillid, msg.action)
    end
end

function SC_LambdaSwapHPMP(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        battletext_swaphpmp(actor, msg.skillid)
    end
end

function SC_LambdaResurrent(msg)
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
        dead_setskill(msg.actorid, msg.skillid, msg.time)
    end
end

function SC_LambdaTransfer(msg)
    local actor = actormanager_getfromactorid(msg.target)
    if actor ~= nil then
        if msg.time > 0.0 then
            actor:moveplayersetmovedest(msg.posx, msg.posy, msg.posz, msg.time)
        else
            local config_skill = csvskill_getfromid(msg.skillid)
            if config_skill ~= nil and csvskill_getscript(config_skill, "blink") ~= nil then
                battletext_blink(actor, msg.skillid)
            end
            if msg.vfx > 0 then
                actor:createvfx(EffectSkillDimensiondoor, nil, true)
            end
            actor:setactorposition(msg.posx, msg.posy, msg.posz, actor.attr.rot)
            if msg.vfx > 0 then
                actor:createvfx(EffectSkillDimensiondoor, nil, true)
            end
        end
    end
end
