

function csvcraftingrecipe_getfromid(id)
    return c_config_getmetaid(configid.crafting_recipe, id)
end

function csvcraftingharvest_getfromid(id)
    return c_config_getmetaid(configid.crafting_harvest, id)
end

function csvcraftingtask_getfromid(id)
    return c_config_getmetaid(configid.crafting_task, id)
end

function csvcraftingtask_getskill(config_task)
    local config_quest = csvquest_getfromid(config_task.id)
    if config_quest == nil then
        return nil
    end
    local lambdapre = config_quest.prerequisite
    if lambdapre == nil then
        return nil
    end
    local actioncount = lambdapre.actioncount
    for lambdaindex=1,actioncount do
        local sublambda = lambdapre[lambdaindex]
        if c_isaction(sublambda, QuestAccept_preskill) then
            return csvskill_getfromid(sublambda.variable[1].integer)
        end
    end
end
