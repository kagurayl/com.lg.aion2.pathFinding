

function debugquestdesc_step(quest, step)
    local lambda = quest.config_step[viewstep]
    if lambda ~= nil then
        quest.state = {}
        for i=1,#lambda do
            quest.state[i] = 0
        end
    else
        quest.state = {}
    end

    for stepindex=1,#step do
        local steptext = questdesc_convertstep(quest, stepindex, step[stepindex], questdesctype.main)
        local steptext = questdesc_convertstep(quest, stepindex, step[stepindex], questdesctype.all)
    end
end

function debugquestdesc_state()
    local csv_quest = c_config_getmetaall(configid.quest)
    for i=1,#csv_quest do
        local quest = {}
		quest.questid = csv_quest[i].id
		quest.trace = 0
		quest.step = 1
		quest.state = nil
		quest.branch = 1
        quest.config_quest = csvquest_getfromid(quest.questid)
        quest.config_additive, quest.config_step = csvqueststep_getstep(quest.questid)
        quest.xmlcontent = c_config_loadxml(csvquest_getxml(quest.questid))
        quest.config_submit = csvquest_parsesubmit(quest.config_quest, quest.config_additive, quest.config_step)
        local xmlcontent = c_config_loadxml(csvquest_getxml(quest.questid))
        local text, step = csvxml_getsummary(xmlcontent, "quest_summary")
        if step ~= nil then
            debugquestdesc_step(quest, step)
        end
    end
end
