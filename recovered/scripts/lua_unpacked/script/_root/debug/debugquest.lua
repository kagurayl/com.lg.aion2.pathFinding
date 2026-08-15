
local function debugsend(str)
    local msg = {messageid = "CS_Chat"}
    msg.channel = chatchanneltype.chataoi
    msg.whisperid = 0
    msg.text = str
    c_send(msg)
end

local function debugquestgetnpc(npcid)
    local actorlist = actormanager_getactorlist()
    local dist = nil
    local npc = nil
    for key, actor in pairs(actorlist) do
		if actor:isnpc() and actor.config_npc.id == npcid then
            local d = vector3_distance(actor.transform.px, actor.transform.py, actor.transform.pz, m_me.transform.px, m_me.transform.py, m_me.transform.pz)
            if npc == nil or dist > d then
                npc = actor
                dist = d
            end
		end
	end
    return npc, dist
end

local function debugquestlambda(quest, lambda)
    if csvqueststep_istalklambda(lambda.action) then
        local npc, dist = debugquestgetnpc(lambda.variable[1].integer)
        if npc ~= nil and dist < 2 then
            npc_startscript(npc.actorid)
        else
            debugsend("@movetonpc " .. lambda.variable[1].integer)
        end
    elseif lambda.action == QuestStep_GetItem or lambda.action == QuestStep_BagItem then
        local itemid = lambda.variable[1].integer
        local additivelambdaarray = quest.config_additive[quest.step]
        if additivelambdaarray ~= nil then
            for lambdaindex=1,#additivelambdaarray do
                local additivelambda = additivelambdaarray[lambdaindex]
                if additivelambda.action == QuestAddititve_Drop then
                    if additivelambda.variable[1].integer == itemid then
                        local npc, dist = debugquestgetnpc(additivelambda.variable[3].integer)
                        if npc ~= nil and dist < 2 then
                            debugsend("@kill " .. npc.actorid)
                            local msg = {messageid="CS_NPCPickDropAll"}
                            msg.actorid = npc.actorid
                            c_send(msg)
                        else
                            debugsend("@movetonpc " .. additivelambda.variable[3].integer)
                        end
                        break
                    end
                end
            end
        end
    elseif lambda.action == QuestStep_Kill then
        local npc, dist = debugquestgetnpc(lambda.variable[2].integer)
        if npc ~= nil and dist < 2 then
            debugsend("@kill " .. npc.actorid)
            local msg = {messageid="CS_NPCPickDropAll"}
            msg.actorid = npc.actorid
            c_send(msg)
        else
            debugsend("@movetonpc " .. lambda.variable[2].integer)
        end
    end
end

local function debugquestaccept(questid)
    local config_quest = csvquest_getfromid(questid)
    if config_quest == nil then
        return
    end
    local lambdaaccept = config_quest.accept
    if lambdaaccept ~= nil then
        local actioncount = lambdaaccept.actioncount
        for lambdaindex=1,actioncount do
            local sublambda = lambdaaccept[lambdaindex]
            if c_isaction(sublambda, "npc") then
                local npc = debugquestgetnpc(sublambda.variable[1].integer)
                if npc ~= nil and vector3_distance(npc.transform.px, npc.transform.py, npc.transform.pz, m_me.transform.px, m_me.transform.py, m_me.transform.pz) < 2 then
                    npc_startscript(npc.actorid)
                else
                    debugsend("@movetonpc " .. sublambda.variable[1].integer)
                end
            elseif c_isaction(sublambda, "item") then
                local itemid = sublambda.variable[1].integer
                if playeritem_getcount(itemid) == 0 then
                    debugsend("@additem " .. itemid .. " 1")
                else
                    local msg = {messageid="CS_QuestAcceptItem"}
                    msg.questid = questid
                    c_send(msg)
                end
            end
        end
    end
end

local function debugquestsubmit(quest)
    local npcid = quest.config_submit.submitnpc
    if npcid == nil then
        return
    end
    local npc = debugquestgetnpc(npcid)
    if npc ~= nil and vector3_distance(npc.transform.px, npc.transform.py, npc.transform.pz, m_me.transform.px, m_me.transform.py, m_me.transform.pz) < 2 then
        npc_startscript(npc.actorid)
    else
        debugsend("@movetonpc " .. npcid)
    end
end

function debugquest(strquestid)
    local questid = string.tointeger(strquestid)
    local quest = playerquest_getquest(questid)
    if quest == nil or quest.config_step == nil then
        debugquestaccept(questid)
        return
    end
    if quest.step > #quest.config_step then
        debugquestsubmit(quest)
        return
    end
    local steplambdaarray = quest.config_step[quest.step]
    for lambdaindex=1,#steplambdaarray do
        local reqcount = csvqueststep_getreqcount(steplambdaarray[lambdaindex])
        if quest.state[lambdaindex] ~= nil and quest.state[lambdaindex] ~= -1 and quest.state[lambdaindex] < reqcount then
            debugquestlambda(quest, steplambdaarray[lambdaindex])
            return
        end
    end
end

function debugrecipepart()
    local config_recipe = m_uicrafting_recipe.selectrecipe
    if config_recipe == nil then
        return
    end
    if config_recipe.component ~= "0" then
        local itemarray = string.split(config_recipe.component, ";")
        for i=1,#itemarray do
            local iteminfo = string.split(itemarray[i], "x")
            local config_item = csvitem_getfromid(string.tointeger(iteminfo[1]))
            if config_item ~= nil then
                local requirecount = string.tointeger(iteminfo[2])
                local playeritemcount = playeritem_getcount(config_item.id)
                local addcount = requirecount - playeritemcount
                if addcount > 0 then
                    debugsend("@additem " .. config_item.id .. " " .. addcount)
                end
            end
        end
    end
end
