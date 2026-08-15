
quest_visiblelevel = 10

questtype =
{
    main = 0,
    mainguide = 1,
    important = 2,
    significant = 3,
    faction = 4,
    quest = 5,
    crafting = 6,
    evt = 7,
    noncount = 8,
}

queststate = 
{
    none = 0,
    acceptable = 1,
    accepted = 2,
    talkable = 3,
    finish = 4,
}

local m_csv_quest_acceptitemid = {}
local m_csv_quest_acceptfromnpc = {}
local m_csv_quest_acceptfromzone = {}
local m_csv_quest_submitnpc = {}
local m_csv_quest_premission = {}
local m_csv_quest_prequestgroup = {}
local m_csv_quest_mutexaccept = {}
local m_csv_quest_mutexcomplete = {}
local m_csv_quest_submitinfo = {}

function csvquest_getquestidfromitemid(itemid)
    return m_csv_quest_acceptitemid[itemid]
end

function csvquest_getnpcquestlist(npcid)
    return m_csv_quest_acceptfromnpc[npcid]
end

function csvquest_getnpcquestlistall()
    return m_csv_quest_acceptfromnpc
end

function csvquest_getnpcsubmitlist(npcid)
    return m_csv_quest_submitnpc[npcid]
end

function csvquest_getpremission(questid)
    return m_csv_quest_premission[questid]
end

function csvquest_getprequestgroup(questid)
    return m_csv_quest_prequestgroup[questid]
end

function csvquest_getmutexaccept(questid)
    return m_csv_quest_mutexaccept[questid]
end

function csvquest_getmutexcomplete(questid)
    return m_csv_quest_mutexcomplete[questid]
end

local function csvquest_parsequest(config_quest)
    local lambdaaccept = config_quest.accept
    if lambdaaccept ~= nil then
        local actioncount = lambdaaccept.actioncount
        for lambdaindex=1,actioncount do
            local sublambda = lambdaaccept[lambdaindex]
            if c_isaction(sublambda, "npc") then
                local npcid = sublambda.variable[1].integer
                local questlist = m_csv_quest_acceptfromnpc[npcid]
                if questlist == nil then
                    questlist = {}
                    m_csv_quest_acceptfromnpc[npcid] = questlist
                end
                questlist[#questlist + 1] = config_quest
            elseif c_isaction(sublambda, "item") then
                m_csv_quest_acceptitemid[sublambda.variable[1].integer] = config_quest.id
            elseif c_isaction(sublambda, "zone") then
                local data = {}
                data.config_quest = config_quest
                data.mapid = sublambda.variable[1].integer
                data.zonename = sublambda.variable[2].str
                m_csv_quest_acceptfromzone[#m_csv_quest_acceptfromzone + 1] = data
            end
        end
    end

    if config_quest.prequest ~= "0" then
        local questpremission = nil
        local questprequestgroup = nil
        local subprequestgroup = string.split(config_quest.prequest, ";")
        for groupindex=1,#subprequestgroup do
            local subprequest = string.split(subprequestgroup[groupindex], ",")
            if subprequest[1] == "fm" then
                if questpremission == nil then
                    questpremission = {}
                end
                for questindex=2,#subprequest do
                    questpremission[questindex - 1] = string.tointeger(subprequest[questindex])
                end
            else
                if questprequestgroup == nil then
                    questprequestgroup = {}
                end
                local prequest = {}
                local prequestconfig = {}
                local prequestbranch = {}
                for questindex=1,#subprequest do
                    local questinfo = string.split(subprequest[questindex], ":")
                    prequest[questindex] = string.tointeger(questinfo[1])
                    prequestconfig[questindex] = csvquest_getfromid(prequest[questindex])
                    if #questinfo > 1 then
                        prequestbranch[questindex] = string.tointeger(questinfo[2])
                    end
                end
                local prequestgroup = {}
                prequestgroup.prequest = prequest
                prequestgroup.config_prequest = prequestconfig
                prequestgroup.prequestbranch = prequestbranch
                questprequestgroup[#questprequestgroup + 1] = prequestgroup
            end
        end
        if questpremission ~= nil then
            m_csv_quest_premission[config_quest.id] = questpremission
        end
        if questprequestgroup ~= nil then
            m_csv_quest_prequestgroup[config_quest.id] = questprequestgroup
        end
    end
    if config_quest.mutexaccept ~= "0" then
        local mutexaccept = {}
        local submutexquest = string.split(config_quest.mutexaccept, ";")
        for i=1,#submutexquest do
            mutexaccept[i] = string.tointeger(submutexquest[i])
        end
        m_csv_quest_mutexaccept[config_quest.id] = mutexaccept
    end
    if config_quest.mutexcomplete ~= "0" then
        mutexcomplete = {}
        local submutexquest = string.split(config_quest.mutexcomplete, ";")
        for i=1,#submutexquest do
            mutexcomplete[i] = string.tointeger(submutexquest[i])
        end
        m_csv_quest_mutexcomplete[config_quest.id] = mutexcomplete
    end
end

local function csvquest_addsubmitnpc(config_quest, npcid)
    local questlist = csvquest_getnpcsubmitlist(npcid)
    if questlist == nil then
        questlist = {}
        m_csv_quest_submitnpc[npcid] = questlist
    end
    local exist = false
    for i=1,#questlist do
        if questlist[i] == config_quest.id then
            exist = true
            break
        end
    end
    if not exist then
        questlist[#questlist + 1] = config_quest.id
    end
end

local function csvquest_parsesubmitnpc(submit, config_quest, config_step, stepindex, branch)
    local steplambdaarray = config_step[stepindex]
    if steplambdaarray == nil then
        return
    end
    for lambdaindex=#steplambdaarray,1,-1 do
        local lambda = steplambdaarray[lambdaindex]
        if lambda.action == QuestStep_Talk or lambda.action == QuestStep_TalkFinish then
            if branch ~= nil then
                if submit.submitbranch == nil then
                    submit.submitbranch = {}
                end
                local npc = {}
                npc.branch = branch
                npc.npcid = lambda.variable[1].integer
                submit.submitbranch[#submit.submitbranch + 1] = npc
                csvquest_addsubmitnpc(config_quest, npc.npcid)
            else
                submit.submitnpc = lambda.variable[1].integer
                csvquest_addsubmitnpc(config_quest, submit.submitnpc)
            end
            break
        end
        if (lambda.accept == QuestStep_TalkOneOf or lambda.accept == QuestStep_TalkBranch) and lambda.variable[1].integer == config_npc.id then
            if branch ~= nil then
                if submit.submitbranch == nil then
                    submit.submitbranch = {}
                end
                local npc = {}
                npc.branch = branch
                npc.npcid = lambda.variable[1].integer
                submit.submitbranch[#submit.submitbranch + 1] = npc
                csvquest_addsubmitnpc(config_quest, npc.npcid)
            else
                if submit.submitnpcarray == nil then
                    submit.submitnpcarray = {}
                end
                submit.submitnpcarray[#submit.submitnpcarray + 1] = lambda.variable[1].integer
                csvquest_addsubmitnpc(config_quest, lambda.variable[1].integer)
            end
        end
    end
end

function csvquest_parsesubmit(config_quest, config_additive, config_step)
    local submit = m_csv_quest_submitinfo[config_quest.id]
    if submit ~= nil then
        return submit
    end
    submit = {}
    m_csv_quest_submitinfo[config_quest.id] = submit
    if config_step ~= nil then
        for stepindex=1,#config_step do
            local steplambda = config_additive[stepindex]
            if steplambda ~= nil then
                for lambdaindex=1,#steplambda do
                    if steplambda[lambdaindex].action == QuestAddititve_Submit then
                        csvquest_parsesubmitnpc(submit, config_quest, config_step, stepindex, steplambda[lambdaindex].variable[1].integer)
                    end
                end    
            end
        end
        if submit.submitbranch == nil then
            csvquest_parsesubmitnpc(submit, config_quest, config_step, #config_step, nil)
        end
    end
    if submit.submitnpc == nil and submit.submitnpcarray == nil and submit.submitbranch == nil then
        local lambdaaccept = config_quest.accept
        if lambdaaccept ~= nil then
            local actioncount = lambdaaccept.actioncount
            for lambdaindex=1,actioncount do
                local sublambda = lambdaaccept[lambdaindex]
                if c_isaction(sublambda, "npc") then
                    if sublambda.variablecount > 1 then
                        submit.submitnpcarray = {}
                        for j=1,#sublambda.variablecount do
                            submit.submitnpcarray[#submit.submitnpcarray + 1] = sublambda.variable[j].integer
                            csvquest_addsubmitnpc(config_quest, sublambda.variable[j].integer)
                        end
                    else
                        submit.submitnpc = sublambda.variable[1].integer
                        csvquest_addsubmitnpc(config_quest, submit.submitnpc)
                    end
                end
            end
        end
    end
    return submit
end

function csvquest_load()
    local csv_quest = c_config_getmetaall(configid.quest)
    for i=1,#csv_quest do
        csvquest_parsequest(csv_quest[i])
    end
end

function csvquest_getfromid(id)
    return c_config_getmetaid(configid.quest, id)
end

function csvquest_getxml(questid)
    local dir = nil
    if questid < 10000 then
        dir = "dialog/0_9999"
    elseif questid < 20000 then
        dir = "dialog/10000_19999"
    elseif questid < 30000 then
        dir = "dialog/20000_29999"
    elseif questid < 40000 then
        dir = "dialog/30000_39999"
    elseif questid < 50000 then
        dir = "dialog/40000_49999"
    elseif questid < 60000 then
        dir = "dialog/50000_59999"
    elseif questid < 70000 then
        dir = "dialog/60000_69999"
    elseif questid < 80000 then
        dir = "dialog/70000_79999"
    elseif questid < 90000 then
        dir = "dialog/80000_89999"
    end
    return string.format("streamconfig/%s/quest_q%s.html", dir, questid)
end

function csvquest_getimagefromtypestate(type, state)
    if type == questtype.main then
        if state == queststate.talkable then
            return csvlabelimage.quest_mainquesting
        elseif state == queststate.finish then
            return csvlabelimage.quest_mainquestcomplete
        end
    elseif type == questtype.quest or type == questtype.crafting or type == questtype.noncount then
        if state == queststate.acceptable then
            return csvlabelimage.quest_stdqueststart
        elseif state == queststate.talkable then
            return csvlabelimage.quest_stdquesting
        elseif state == queststate.finish then
            return csvlabelimage.quest_stdquestcomplete
        end
    elseif type == questtype.important or type == questtype.significant or type == questtype.faction then
        if state == queststate.acceptable then
            return csvlabelimage.quest_guidequeststart
        elseif state == queststate.talkable then
            return csvlabelimage.quest_guidequesting
        elseif state == queststate.finish then
            return csvlabelimage.quest_guidequestcomplete
        end
    elseif type == questtype.evt or type == questtype.mainguide then
        if state == queststate.acceptable then
            return csvlabelimage.quest_festqueststart
        elseif state == queststate.talkable then
            return csvlabelimage.quest_festquesting
        elseif state == queststate.finish then
            return csvlabelimage.quest_festquestcomplete
        end
    end
    return nil
end

function csvquest_getrepeatcolding(config_quest, completetime)
    if config_quest.reset == 1 then
        return completetime > playerattr_info.questresetday
    elseif config_quest.reset == 2 then
        return completetime > playerattr_info.questresetweek
    end
    return false
end

function csvquest_getautoaccept(zonename)
    for i=1,#m_csv_quest_acceptfromzone do
        local data = m_csv_quest_acceptfromzone[i]
        if data.mapid == scene_getmapid() and data.zonename == zonename then
            return data.config_quest
        end
    end
end
