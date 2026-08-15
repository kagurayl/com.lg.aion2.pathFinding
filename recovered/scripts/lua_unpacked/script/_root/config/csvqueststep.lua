QuestAddititve_Drop = "drop"
QuestAddititve_Branch = "branch"
QuestAddititve_Submit = "submit"
QuestAddititve_Item = "item"
QuestAddititve_PickItem = "pickitem"
QuestAddititve_Talk = "scripttalk"
QuestAddititve_Spawn = "spawn"
QuestAddititve_Interact = "scriptinteract"
QuestAddititve_Kill = "scriptkill"
QuestAddititve_View = "view"

QuestAccept_preitem = "bagitem"
QuestAccept_preskill = "skill"

QuestStep_Talk = "talk"
QuestStep_TalkFinish = "talkfinish"
QuestStep_TalkOneOf = "talkoneof"
QuestStep_TalkBranch = "talkbranch"
QuestStep_Movie = "movie"
QuestStep_Video = "video"
QuestStep_MoveTo = "moveto"
QuestStep_Kill = "kill"
QuestStep_PVPTitle = "pvptitle"
QuestStep_PVPMap = "pvpmap"
QuestStep_GetItem = "getitem"
QuestStep_BagItem = "bagitem"
QuestStep_CheckItem = "checkitem"
QuestStep_Consume = "consume"
QuestStep_Skill = "skill"
QuestStep_Map = "map"
QuestStep_ItemArea = "itemarea"
QuestStep_ItemSphere = "itemsphere"
QuestStep_Zone = "zone"
QuestStep_Sphere = "sphere"
QuestStep_LureSphere = "luresphere"
QuestStep_Escort = "escort"

local function csvqueststep_parseadditive(lambdastr)
    return lambda_parse(lambdastr)
end

local function csvqueststep_parsestep(lambdastr)
    local steplambdaarray = lambda_parse(lambdastr)
    if steplambdaarray == nil then
        steplambdaarray = {}
        steplambdaarray[1] = {action = "script", variable = {}}
    end
    return steplambdaarray
end

function csvqueststep_hasstep(questid)
    return c_config_getmetaarray(configid.queststep, "id", questid) ~= nil
end

function csvqueststep_getstep(questid)
    local config_queststeparray = c_config_getmetaarray(configid.queststep, "id", questid)
	if config_queststeparray == nil then
        return
    end
    local additivearray = {}
    local steparray = {}
    for i=1,#config_queststeparray do
        local config_queststep = config_queststeparray[i]
        local additive = csvqueststep_parseadditive(config_queststep.additive)
        local step = csvqueststep_parsestep(config_queststep.lambda)
        additivearray[i] = additive
        steparray[i] = step
    end
    return additivearray, steparray
end

function csvqueststep_gettrace(questid, step)
    local config_queststeparray = c_config_getmetaarray(configid.queststep, "id", questid)
	if config_queststeparray ~= nil then
        local substep = config_queststeparray[step]
        if substep ~= nil then
            return substep.trace
        end
    end
end

function csvqueststep_getreqcount(lambda)
    if lambda.action == QuestStep_GetItem or lambda.action == QuestStep_BagItem then
        if lambda.variable[1].integer == itemid_coin then
            return 0
        end
        return lambda.variable[1].count
    elseif lambda.action == QuestStep_Talk or lambda.action == QuestStep_TalkFinish then
        return lambda.variable[1].count
    elseif lambda.action == QuestStep_Kill then
        return lambda.variable[1].integer
    end
    return 1
end

function csvqueststep_istalklambda(action)
    return action == QuestStep_Talk or action == QuestStep_TalkOneOf or action == QuestStep_TalkBranch or action == QuestStep_TalkFinish
end
