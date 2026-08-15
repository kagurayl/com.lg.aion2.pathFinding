
skilltextflag =
{
	spellcost = 0x1,
}

function skilltext_delegate_damage(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt
end

function skilltext_delegate_mindamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt + math.tointegerfloor(playerattr_info.damagemin)
end

function skilltext_delegate_maxdamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt + sublambda.variable[2].flt + math.tointegerfloor(playerattr_info.damagemax)
end

function skilltext_delegate_fixdamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt + math.tointegerfloor(playerattr_info.damagemin)
end

function skilltext_delegate_adddamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[4].flt + math.tointegerfloor(playerattr_info.damagemin)
end

function skilltext_delegate_ratedamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[3].flt
end

function skilltext_delegate_addeffectcondition(config_skill, skilllevel, sublambda)
    local varindex = 1
    local filterciv = sublambda.variable[varindex].integer
    local filterdir = sublambda.variable[varindex + 1].integer
    local text = ""
    local varcount = sublambda.variablecount
    for i=varindex+2,varcount do
        local textaction = c_textformat("TIPS_STATUS_" .. string.upper(sublambda.variable[i].str))
        if #text > 0 then
            text = text .. c_textformat("UI_SPLIT")
        end
        text = text .. textaction
    end
    return text
end

local function skilltext_delegate_geteffectdesc(buffid)
    local config_buff = csvskillbuff_getfromid(buffid)
    if config_buff ~= nil and config_buff.lambda ~= nil then
        local lambda = config_buff.lambda
        local arraycount = lambda.arraysize
        for i=1,arraycount do
            local lambda2 = lambda.lambdaarray[i]
            local actioncount = lambda2.actioncount
            for j=1,actioncount do
                local sublambda = lambda2[j]
                local textkey = "TIPS_STATUS_" .. string.upper(sublambda.action)
                local text = c_textformat(textkey)
                if textkey ~= text then
                    return text
                end
            end
        end
    end
end
function skilltext_delegate_addeffect(config_skill, skilllevel, sublambda)
    return skilltext_delegate_geteffectdesc(sublambda.variable[1].integer)
end

function skilltext_delegate_signetbursteffect(config_skill, skilllevel, sublambda)
    return skilltext_delegate_geteffectdesc(sublambda.variable[6].integer)
end

function skilltext_delegate_distance(config_skill, skilllevel, sublambda)
    return math.abs(sublambda.variable[1].flt)
end

function skilltext_delegate_heal(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt + sublambda.variable[2].flt * skilllevel
end

function skilltext_delegate_healcaster(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt
end

function skilltext_delegate_healcasterrange(config_skill, skilllevel, sublambda)
    return sublambda.variable[2].flt
end

function skilltext_delegate_hpheal(config_skill, skilllevel, sublambda)
    return sublambda.variable[3].flt
end

function skilltext_delegate_mpheal(config_skill, skilllevel, sublambda)
    return sublambda.variable[4].flt
end

function skilltext_delegate_summontime(config_skill, skilllevel, sublambda)
    return timerdesc_getafter(sublambda.variable[2].flt)
end

function skilltext_delegate_unitnumber(config_skill, skilllevel, sublambda)
    return sublambda.variable[3].flt
end

function skilltext_delegate_dispelcount(config_skill, skilllevel, sublambda)
    return sublambda.variable[2].flt
end

function skilltext_delegate_dispeldamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[4].flt
end

function skilltext_delegate_dispeladddamage(config_skill, skilllevel, sublambda)
    return sublambda.variable[6].flt
end

function skilltext_delegate_signetgrade(config_skill, skilllevel, sublambda)
    return sublambda.variable[4].flt
end

function skilltext_delegate_bonusdroprate(config_skill, skilllevel, sublambda)
    return sublambda.variable[1].flt
end

function skilltext_delegate_randomtime(config_buff, skilllevel, sublambda, subbuff)
    local timearray = string.splitnumber(config_buff.timemin, ";")
    return timerdesc_getafter(timearray[subbuff])
end

function skilltext_delegate_remaintime(config_buff, skilllevel, sublambda, subbuff)
    local timearray = string.splitnumber(config_buff.timemax, ";")
    return timerdesc_getafter(timearray[subbuff])
end

function skilltext_delegate_checktime(config_buff, skilllevel, sublambda, subbuff)
    local time = 0.0
    local lambda = config_buff.dot
    if lambda ~= nil then
        local arraycount = lambda.arraysize
        if subbuff <= arraycount then
            local lambda2 = lambda.lambdaarray[subbuff]
            local sublambda = lambda2[1]
            if c_isaction(sublambda, "time") then
                time = sublambda[1].variable[2].flt
            end
        end
    end
    return timerdesc_getafter(time)
end

function skilltext_delegate_statname(config_buff, skilllevel, sublambda, subbuff)
    local action = sublambda.action
    if string.endwith(action, "+") or string.endwith(action, "-") then
        action = string.sub(action, 1, #action - 1)
    end
    local textkey = "TIPS_ATTR_" .. string.upper(action)
    return c_textformat(textkey)
end

function skilltext_delegate_statvalue(config_buff, skilllevel, sublambda, subbuff)
    if sublambda.variablecount > 1 then
        return sublambda.variable[1].flt + sublambda.variable[2].flt * skilllevel
    else
        return sublambda.variable[1].flt
    end
end

function skilltext_delegate_dot(config_buff, skilllevel, sublambda, subbuff)
    local lambda = config_buff.dot
    if lambda ~= nil then
        local arraycount = lambda.arraysize
        if subbuff <= arraycount then
            local lambda2 = lambda.lambdaarray[subbuff]
            local sublambda2 = lambda2[1]
            if c_isaction(sublambda2, "time") then
                return c_textformat("TIPS_BUFFDOT_TIME", sublambda2.variable[2].flt)
            elseif c_isaction(sublambda2, "spell") then
                return c_textformat("TIPS_BUFFDOT_SPELL")
            elseif c_isaction(sublambda2, "attack") then
                return c_textformat("TIPS_BUFFDOT_ATTACK")
            elseif c_isaction(sublambda2, "hurt") then
                return c_textformat("TIPS_BUFFDOT_HURT", "TIPS_ATTACKTYPE_" .. string.upper(sublambda2.variable[2].str))
            elseif c_isaction(sublambda2, "cand") then
                return sublambda2.variable[3].flt
            elseif c_isaction(sublambda2, "dead") then
                return c_textformat("TIPS_BUFFDOT_DEAD")
            elseif c_isaction(sublambda2, "delay") then
                local timearray = string.splitnumber(config_buff.timemax, ";")
                return timerdesc_getafter(timearray[subbuff])
            end
        end
    end
end

function skilltext_delegate_dotstat(config_buff, skilllevel, sublambda, subbuff)
    local lambda = config_buff.dot
    if lambda ~= nil then
        local arraycount = lambda.arraysize
        if subbuff <= arraycount then
            local lambda2 = lambda.lambdaarray[subbuff]
            local sublambda2 = lambda2[1]
            if c_isaction(sublambda2, "cand") then
                if sublambda2.variable[2].str == "hp" then
                    return c_textformat("TIPS_ATTR_HP")
                end
            end
        end
    end
end

function skilltext_delegate_dotprob(config_buff, skilllevel, sublambda, subbuff)
    local lambda = config_buff.dot
    if lambda ~= nil then
        local arraycount = lambda.arraysize
        if subbuff <= arraycount then
            local lambda2 = lambda.lambdaarray[subbuff]
            local sublambda2 = lambda2[1]
            return sublambda2.variable[1].flt
        end
    end
end

function skilltext_delegate_covervalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_shieldvalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[2].flt
end

function skilltext_delegate_buffeffect(config_buff, skilllevel, sublambda, subbuff)
    local textkey = "TIPS_STATUS_" .. string.upper(sublambda.action)
    return c_textformat(textkey)
end

function skilltext_delegate_subtype(config_buff, skilllevel, sublambda, subbuff)
    return c_textformat("TIPS_SUBTYPE_" .. sublambda.variable[1].integer)
end

function skilltext_delegate_castingbonus(config_buff, skilllevel, sublambda, subbuff)
    return math.abs(sublambda.variable[2].flt)
end

function skilltext_delegate_count(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].integer
end

function skilltext_delegate_effectbonus(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_fixvalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_ratevalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_equipcategory(config_buff, skilllevel, sublambda, subbuff)
    return c_textformat(csvitem_gettypetext(sublambda.variable[1].integer))
end

function skilltext_delegate_equipstatname(config_buff, skilllevel, sublambda, subbuff)
    local equipstatname = sublambda.action
    local textkey = "TIPS_ATTR_" .. string.upper(string.sub(equipstatname, 6, #equipstatname))
    return c_textformat(textkey)
end

function skilltext_delegate_equipvalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[2].flt
end

function skilltext_delegate_bonusvalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_range(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_rangereflect(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[4].flt
end

function skilltext_delegate_protectvalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[3].flt
end

function skilltext_delegate_cursevalue(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_hidespeed(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[2].flt
end

function skilltext_delegate_boostcount(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_bonusrate(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

function skilltext_delegate_attacktype(config_buff, skilllevel, sublambda, subbuff)
    return c_textformat("TIPS_ATTACKTYPE_" .. string.upper(sublambda.variable[2].str))
end

function skilltext_delegate_attackcount(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[3].integer
end

function skilltext_delegate_currenthpmp(config_buff, skilllevel, sublambda, subbuff)
    return sublambda.variable[1].flt
end

local function skilltext_parselambda(substr, index, config_skill, skilllevel)
    if #substr < index + 2 then
        return nil
    end
    local type = substr[index]
    local lambdaindex = string.tointeger(substr[index + 1])
    local funcname = substr[index + 2]
    if type == nil or lambdaindex == nil or funcname == nil then
        return nil
    end
    local func = _G["skilltext_delegate_" .. funcname]
    if func == nil then
        debugerror("failed skilltext_parselambda:" .. funcname)
        return nil
    end
    if config_skill == nil then
        return nil
    end
    if skilllevel == nil then
        skilllevel = 1
        local config_skilllearn = csvskilllearn_getfromid(config_skill.id)
        if config_skilllearn ~= nil and config_skilllearn.playerlevel < playerattr_info.level then
            skilllevel = math.min(playerattr_info.level - config_skilllearn.playerlevel, 9)
        end
    end
    if type == "skill" then
        local lambda = config_skill.lambda
        if lambda == nil then
            return nil
        end
        local lambdacount = lambda.actioncount
        if lambdaindex > lambdacount then
            return nil
        end
        local lambda2 = lambda[lambdaindex]
        return func(config_skill, skilllevel, lambda2)
    else
        local config_buff = csvskillbuff_getfromid(config_skill.id)
        if config_buff == nil or config_buff.lambda == nil then
            return nil
        end
        local subbuff = 1
        local lambda = config_buff.lambda
        local arraycount = lambda.arraysize
        for i=1,arraycount do
            local lambda2 = lambda.lambdaarray[i]
            local actioncount = lambda2.actioncount
            if lambdaindex <= actioncount then
                local sublambda = lambda2[lambdaindex]
                return func(config_buff, skilllevel, sublambda, subbuff)
            else
                lambdaindex = lambdaindex - actioncount
                subbuff = subbuff + 1
            end
        end
        return nil
    end
end

local function skilltext_parseskill(config_skill, type)
    if type == "0" then
        local config_spawn = csvnpcspawn_getmapspawnnpc(playerattr_info.resurrectid)
        if config_spawn ~= nil and #config_spawn > 0 then
            local spawnposition = csvspawn_parsepoint(config_spawn[1])
            if spawnposition ~= nil and #spawnposition > 0 then
                local title, note = csvmap_getzonename(config_spawn[1].mapid, spawnposition[1].x, spawnposition[1].y, spawnposition[1].z)
                return title
            end
        end
        local config_spawnstatic = csvnpcstatic_getfromnpcid(playerattr_info.resurrectid)
        if config_spawnstatic ~= nil and #config_spawnstatic > 0 then
            local spawnposition = csvspawn_parsepoint(config_spawnstatic[1])
            if spawnposition ~= nil and #spawnposition > 0 then
                local title, note = csvmap_getzonename(config_spawnstatic[1].id, spawnposition[1].x, spawnposition[1].y, spawnposition[1].z)
                return title
            end
        end
        if playerattr_info.civ == playerciv.light then
            local title, note = csvmap_splitzonename("STR_SZ_LF1_AKARIOS_FIELDS")
            return title
        else
            local title, note = csvmap_splitzonename("STR_SZ_DF1_1_Q1")
            return title
        end
    elseif type == "dist" and config_skill.select ~= nil then
        local lambda = config_skill.select
        local actioncount = lambda.actioncount
        for i=1,actioncount do
            local sublambda = lambda[1]
            if c_isaction(sublambda, "pick") or c_isaction(sublambda, "pickme") or c_isaction(sublambda, "spirit") or c_isaction(sublambda, "mouse") then
                return math.tointegerfloor(playerbattle_pickdist(config_skill, sublambda.variable[1].flt, nil))
            end
        end
    end
    return ""
end

function skilltext_getdesc(textdesc, config_skill, skilllevel, flag)
    if textdesc == nil or config_skill == nil then
        return ""
    end
    local desc = textformat_gettext(textdesc, function(key)
        if type(key) == "string" then
            local substr = string.split(key, ",")
            if substr[1] == "redirect" then
                local skillid = string.tointeger(substr[2])
                return skilltext_parselambda(substr, 3, csvskill_getfromid(skillid), nil)
            elseif substr[1] == "skill" or substr[1] == "buff" then
                return skilltext_parselambda(substr, 1, config_skill, skilllevel)
            else
                return skilltext_parseskill(config_skill, substr[1])
            end
        end
    end)
    if bit.band(flag, skilltextflag.spellcost) ~= 0 then
        if csvskill_spellwayactive(config_skill) then
            local spelltime = ""
            if config_skill.spell > 0 then
                spelltime = c_textformat("TIPS_SPELLTIME", timerdesc_getdesc(config_skill.spell, true, true, true))
            else
                spelltime = c_textformat("TIPS_SPELLTIME_NONE")
            end
            desc = desc .. "\n" .. spelltime
        end

        if config_skill.cd > 0 then
            desc = desc .. "\n" .. c_textformat("TIPS_COLDTIME", timerdesc_getdesc(config_skill.cd, true, true, true))
        end
        
        local lambdacost = config_skill.cost
        if lambdacost ~= nil then
            local spellcost = nil
            local actioncount = lambdacost.actioncount
            for i=1,actioncount do
                local sublambda = lambdacost[i]
                local subcost = nil
                if c_isaction(sublambda, "hp") then
                    local perc = sublambda.variable[1].perc
                    if perc ~= nil then
                        subcost = c_textformat("TIPS_SPELLCOST_HPPERC", math.tointegerfloor(perc * 100.0))
                    else
                        subcost = c_textformat("TIPS_SPELLCOST_HP", sublambda.variable[1].flt)
                    end
                elseif c_isaction(sublambda, "mp") then
                    local perc = sublambda.variable[1].perc
                    if perc then
                        subcost = c_textformat("TIPS_SPELLCOST_MPPERC", math.tointegerfloor(perc * 100.0))
                    else
                        subcost = c_textformat("TIPS_SPELLCOST_MP", sublambda.variable[1].flt)
                    end
                elseif c_isaction(sublambda, "dp") then
                    local perc = sublambda.variable[1].perc
                    if perc then
                        subcost = c_textformat("TIPS_SPELLCOST_DPPERC", math.tointegerfloor(perc * 100.0))
                    else
                        subcost = c_textformat("TIPS_SPELLCOST_DP", sublambda.variable[1].flt)
                    end
                elseif c_isaction(sublambda, "item") then
                    local itemid = sublambda.variable[1].integer
                    local itemcount = sublambda.variable[1].count
                    local config_item = csvitem_getfromid(itemid)
                    if config_item ~= nil then
                        subcost = c_textformat("TIPS_SPELLCOST_ITEM", config_item.name, itemcount)
                    end
                end
                if subcost ~= nil then
                    if spellcost ~= nil then
                        spellcost = spellcost .. c_textformat("UI_SPLIT") .. subcost
                    else
                        spellcost = subcost
                    end
                end
            end
            if spellcost ~= nil then
                desc = desc .. "\n" .. c_textformat("TIPS_SPELLCOST", spellcost)
            end
        end
    end
    return desc
end
