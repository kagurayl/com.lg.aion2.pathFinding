

local SkillBoneCommand =
{
    skeleton = 0,
    group = 1,
    bone = 2,
}
local m_csv_skillbone = {}

function csvskillbone_load()
    local config_array = c_config_loadsimplearray(csvconfig_filename("skillbone"))
    local config_skeleton = nil
    local config_group = nil
    local config_val = {}
    local type = nil
    local index = 1
    while index < #config_array do
        type, index = csvconfig_loadsimple(config_array, config_val, index)
        if type == SkillBoneCommand.skeleton then
            config_skeleton = {}
            m_csv_skillbone[config_val[1]] = config_skeleton
        elseif type == SkillBoneCommand.group then
            config_group = {}
            config_skeleton[config_val[1]] = config_group
        elseif type == SkillBoneCommand.bone then
            config_group[#config_group + 1] = config_val[1]
        end
    end
end

function csvskillbone_getskeleton(name)
    return m_csv_skillbone[name]
end
