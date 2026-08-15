
csvskilllearntype =
{
    auto = 1,
    skillbook = 2,
    stigma = 3,
    stigmaadvance = 4,
}

local m_csv_skilllearnid = nil
local m_csv_skilllearnlight = nil
local m_csv_skilllearndark = nil

local function csvskilllearn_prepare(config_skilllearn)
    if config_skilllearn.autolearn > 0 then
        config_skilllearn.learntype = csvskilllearntype.auto
    elseif config_skilllearn.stigma == 1 then
        config_skilllearn.learntype = csvskilllearntype.stigma
    elseif config_skilllearn.stigma == 2 then
        config_skilllearn.learntype = csvskilllearntype.stigmaadvance
    else
        config_skilllearn.learntype = csvskilllearntype.skillbook
    end
end

local function csvskilllearn_addskillcareer(config_skilllearn, skilltable, career)
    local skill = skilltable[career]
    if skill == nil then
        skill = {}
        skilltable[career] = skill
    end
    skill[config_skilllearn.id] = config_skilllearn
end

local function csvskilllearn_addskill(config_skilllearn, career)
    if playercivavailable(config_skilllearn.civ, playerciv.light) then
        csvskilllearn_addskillcareer(config_skilllearn, m_csv_skilllearnlight, career)
    end
    if playercivavailable(config_skilllearn.civ, playerciv.dark) then
        csvskilllearn_addskillcareer(config_skilllearn, m_csv_skilllearndark, career)
    end
end

function csvskilllearn_load()
    m_csv_skilllearnid = {}
    m_csv_skilllearnlight = {}
    m_csv_skilllearndark = {}
    local config_array = c_config_loadscriptarray(csvconfig_filename("skill_learn"))
    for i=1, #config_array do
        local config_skilllearn = config_array[i]
        m_csv_skilllearnid[config_skilllearn.id] = config_skilllearn
        config_skilllearn.config_skill = csvskill_getfromid(config_skilllearn.id)
        csvskilllearn_prepare(config_skilllearn)

        if config_skilllearn.career > 0 then
            csvskilllearn_addskill(config_skilllearn, config_skilllearn.career)
            if config_skilllearn.career < playercareer.fighter then
                if config_skilllearn.career == playercareer.warrior then
                    csvskilllearn_addskill(config_skilllearn, playercareer.fighter)
                    csvskilllearn_addskill(config_skilllearn, playercareer.knight)
                elseif config_skilllearn.career == playercareer.cleric then
                    csvskilllearn_addskill(config_skilllearn, playercareer.priest)
                    csvskilllearn_addskill(config_skilllearn, playercareer.chanter)
                elseif config_skilllearn.career == playercareer.scout then
                    csvskilllearn_addskill(config_skilllearn, playercareer.assassin)
                    csvskilllearn_addskill(config_skilllearn, playercareer.ranger)
                elseif config_skilllearn.career == playercareer.mage then
                    csvskilllearn_addskill(config_skilllearn, playercareer.wizard)
                    csvskilllearn_addskill(config_skilllearn, playercareer.elementallist)
                end
            end
        else
            local startcareer = math.ternary(config_skilllearn.playerlevel < 10, 1, playercareer.fighter)
            for j=startcareer, playercareer.count do
                csvskilllearn_addskill(config_skilllearn, j)
            end
        end
    end
end

function csvskilllearn_getfromid(id)
    return m_csv_skilllearnid[id]
end

function csvskilllearn_getfromcivcareer(civ, career)
    if civ == playerciv.light then
        return m_csv_skilllearnlight[career]
    else
        return m_csv_skilllearndark[career]
    end
end
