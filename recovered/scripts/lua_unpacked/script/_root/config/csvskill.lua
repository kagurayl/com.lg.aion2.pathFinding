
skill_gather_low = 30001
skill_gather_land = 30002
skill_gather_od = 30003
skill_gather_cooking = 40001
skill_gather_weapon = 40002
skill_gather_armor = 40003
skill_gather_tailor = 40004
skill_gather_alchemy = 40007
skill_gather_handiwork = 40008
skill_gather_convert = 40009

skill_skillbarslotmax = 15
skill_skillbarpagemax = 9
skill_actionbarslotmax = 40
skill_actionbarlineslot = 10

skill_counter_dodge = -1
skill_counter_parry = -2
skill_counter_block = -3
skill_counter_evade = -11
skill_counter_stumble = -21
skill_counter_stun = -22
skill_counter_stagger = -23
skill_counter_spin = -24
skill_counter_openaerial = -25

skill_counter_timeout = 5.0

csvskillsubtype =
{
    none = 0,
    attack = 1,
    buff = 2,
    debuff = 3,
    heal = 4,
    chant = 5,
    summon = 6,
    summontrap = 7,
    summonhoming = 8,
}

csvskillslottype =
{
    skill = 0,
    social = 1,
    item = 2,
    preset = 3,
    crafting = 4,
}

csvskillanimtype =
{
    fire = 1,
    cast = 2,
}

csvskillspellway =
{
    none = 0,
    passive = 1,
    active = 2,
    maintain = 3,
    toggle = 4,
    provoked = 5,
    qte = 6,
    dodge = 7,
    parry = 8,
    block = 9,
}

battleqtebufftype =
{
    srcshock = 1,
    dststun = 2,
    dstknockdown = 3,
    dstairhold = 4,
}

csvskillpresettype =
{
    qte = 0,
    sequence = 1,
    auto = 2,
}

local m_csvskill_qtesublink = {}
local m_csvskill_qtesublinkadjustpriority = {}

local function csvskill_getbuffqteskillid(bufftype)
    if bufftype == "openaerial" then
        return skill_counter_openaerial
    elseif bufftype == "spin" then
        return skill_counter_spin
    elseif bufftype == "stagger" then
        return skill_counter_stagger
    elseif bufftype == "stumble" then
        return skill_counter_stumble
    elseif bufftype == "stun" then
        return skill_counter_stun
    end
    return 0
end
local function csvskill_addqteskill(qteskillid, config_skill)
    local qtesublink = m_csvskill_qtesublink[qteskillid]
    if qtesublink == nil then
        qtesublink = {}
        m_csvskill_qtesublink[qteskillid] = qtesublink
    end
    qtesublink[#qtesublink + 1] = config_skill
end
local function csvskill_init(config_skill)
    local spellwaytype = config_skill.spellway
    if spellwaytype == csvskillspellway.qte then
        local qteinfocount = csvconfig_getsubcount(config_skill.qte) - 1
        for i=1,qteinfocount do
            local qteskillid = csvconfig_getsubvalue(config_skill.qte, i, configsubtype.int)
            csvskill_addqteskill(qteskillid, config_skill)
        end
    elseif spellwaytype == csvskillspellway.active then
        local selectstate = config_skill.selectstate
        if selectstate ~= nil then
            local buffenemey = false
            local bufflambda = nil
            local actioncount = selectstate.actioncount
            for i=1,actioncount do
                local sublambda = selectstate[i]
                if c_isaction(sublambda, "enemy") then
                    buffenemey = true
                elseif c_isaction(sublambda, "buff") then
                    bufflambda = sublambda
                end
            end
            if buffenemey and bufflambda ~= nil then
                for j=1,bufflambda.variablecount do
                    local skillid = csvskill_getbuffqteskillid(bufflambda.variable[j].str)
                    if skillid ~= 0 then
                        csvskill_addqteskill(skillid, config_skill)
                    end
                end
            end
        end
        if csvskill_getscript(config_skill, "evade") ~= nil then
            csvskill_addqteskill(skill_counter_evade, config_skill)
        end
    elseif spellwaytype == csvskillspellway.dodge then
        csvskill_addqteskill(skill_counter_dodge, config_skill)
    elseif spellwaytype == csvskillspellway.parry then
        csvskill_addqteskill(skill_counter_parry, config_skill)
    elseif spellwaytype == csvskillspellway.block then
        csvskill_addqteskill(skill_counter_block, config_skill)
    end
end

function csvskill_load()
    local count = c_config_count(configid.skill)
    for i=1,count do
        local config_skill = c_config_getmetaindex(configid.skill, i)
        if config_skill.category == 0 or config_skill.category == config_skill.id then
            csvskill_init(config_skill)
        end
    end
end

function csvskill_getscript(config_skill, type)
    local lambda = config_skill.lambda
    if lambda ~= nil then
        local actioncount = lambda.actioncount
        for i=1,actioncount do
            local sublambda = lambda[i]
            if c_isaction(sublambda, type) then
                return sublambda
            end
        end
    end
    return nil
end

function csvskill_getfromid(id)
    return c_config_getmetaid(configid.skill, id)
end

function csvskill_getcategoryarray(categoryid)
    return c_config_getmetaarray(configid.skill, "category", categoryid)
end

function csvskill_isattackskill(config_skill)
	if config_skill.subtype == csvskillsubtype.attack
    or config_skill.subtype == csvskillsubtype.debuff
    or config_skill.subtype == csvskillsubtype.summonhoming then
        return true
    end
    return false
end

function csvskill_issystemskill(skillid)
	return skillid >= skill_sysytem_idstart and skillid <= skill_sysytem_idend
end

function csvskill_spellwayactive(config_skill)
    local spellwaytype = config_skill.spellway
    if spellwaytype == csvskillspellway.active
    or spellwaytype == csvskillspellway.maintain
    or spellwaytype == csvskillspellway.toggle
    or spellwaytype == csvskillspellway.qte
    or spellwaytype == csvskillspellway.dodge
    or spellwaytype == csvskillspellway.parry
    or spellwaytype == csvskillspellway.block then
        return true
    end
    return false
end

function csvskill_getallqte()
    return m_csvskill_qtesublink
end

function csvskill_getqtesublink(config_skill)
    if config_skill.category ~= 0 then
        return m_csvskill_qtesublink[config_skill.category]
    else
        return m_csvskill_qtesublink[config_skill.id]
    end
end

function csvskill_getqtesublinkadjustpriority(skillid)
    local skillarray = nil
    if skillid > 0 then
        local config_skill = csvskill_getfromid(skillid)
        if config_skill ~= nil and config_skill.category ~= 0 then
            skillid = config_skill.category
        end
    end
    skillarray = m_csvskill_qtesublinkadjustpriority[skillid]
    if skillarray == nil then
        local srcsublink = m_csvskill_qtesublink[skillid]
        if srcsublink == nil then
            return
        end
        skillarray = table.clonearray(srcsublink)
    end
    playerskillpreset_adjustqtepriority(skillid, skillarray)
    return skillarray
end

function csvskill_getqtetimeout(config_skill)
    local qteinfocount = csvconfig_getsubcount(config_skill.qte)
    if qteinfocount > 1 then
        return csvconfig_getsubvalue(config_skill.qte, qteinfocount, configsubtype.flt)
    end
    return 0.0
end
