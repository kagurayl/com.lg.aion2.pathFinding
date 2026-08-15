
function SC_SkillPresetList(msg)
    playerattr_skillpreset = msg.preset
end

function SC_SkillPresetCreate(msg)
    playerattr_skillpreset[#playerattr_skillpreset + 1] = msg.preset
    skill_tabpreset_updateui()
end

function SC_SkillPresetDelete(msg)
    for i=1,#playerattr_skillpreset do
        if playerattr_skillpreset[i].uuid == msg.uuid then
            table.remove(playerattr_skillpreset, i)
            break
        end
    end
    skill_tabpreset_updateui()
end

function SC_SkillPresetSetIcon(msg)
    local preset = playerskillpreset_getpreset(msg.uuid)
    if preset ~= nil then
        preset.icon = msg.icon
    end
    skill_tabpreset_seticon(msg.uuid, msg.icon)
    skillbar_updateui()
    actionbar_updateui()
end

function SC_SkillPresetSetName(msg)
    local preset = playerskillpreset_getpreset(msg.uuid)
    if preset ~= nil then
        preset.name = msg.name
    end
    skill_tabpreset_setname(msg.uuid, msg.name)
end

function SC_SkillPresetSetType(msg)
    local preset = playerskillpreset_getpreset(msg.uuid)
    if preset ~= nil then
        preset.type = msg.type
    end
    skill_tabpreset_settype(msg.uuid, msg.type)
end

function SC_SkillPresetSetSkill(msg)
    local preset = playerskillpreset_getpreset(msg.uuid)
    if preset ~= nil then
        preset.skillid[msg.slot + 1] = msg.skillid
    end
    skill_tabpreset_setskill(msg.uuid, msg.slot + 1, msg.skillid)
    if msg.slot == 0 then
        skillbar_updateui()
        actionbar_updateui()
    end
end

function SC_SkillQtePriorityList(msg)
    playerattr_skillqtepriority = msg.priority
end

function SC_SkillQtePriority(msg)
    playerattr_skillqtepriority = msg.priority
    skill_main_updatetabqte()
end
