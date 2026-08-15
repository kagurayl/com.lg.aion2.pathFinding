
playerattr_quest = nil
playerattr_questcomplete = nil
playerattr_questnpcicon = nil
playerattr_questnpcnameplate = nil

function playerquest_clear()
    playerattr_quest = {}
    playerattr_questcomplete = {}
    playerattr_questnpcicon = {}
    playerattr_questnpcnameplate = {}
end

function playerquest_loadxml(questid)
	local quest = playerquest_getquest(questid)
	if quest ~= nil and quest.xmlcontent ~= nil then
        return quest.xmlcontent
    end
    return c_config_loadxml(csvquest_getxml(questid))
end

function playerquest_getquest(id)
    for i=1,#playerattr_quest do
		if playerattr_quest[i].questid == id then
			return playerattr_quest[i]
		end
    end
end

function playerquest_complete(id)
    return playerattr_questcomplete[id] ~= nil
end

function playerquest_isquestconsumeitem(itemid)
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_step ~= nil and quest.step <= #quest.config_step then
            local steplambda = quest.config_step[quest.step]
            for lambdaindex=1,#steplambda do
                local action = steplambda[lambdaindex].action
                if action == QuestStep_Consume or action == QuestStep_ItemArea or action == QuestStep_ItemSphere then
                    if steplambda[lambdaindex].variable[1].integer == itemid then
                        return true
                    end
                end
            end
		end
    end
    return false
end

function playerquest_premissioncomplete(config_quest)
    local csvpremission = csvquest_getpremission(config_quest.id)
    if csvpremission ~= nil then
        for i=1,#csvpremission do
            local prequestinfo = playerattr_questcomplete[csvpremission[i]]
            if prequestinfo == nil then
                return false
            end
        end
    end
    return true
end

function playerquest_prequestcomplete(config_quest)
    local csvprequestgroup = csvquest_getprequestgroup(config_quest.id)
    if csvprequestgroup == nil then
        return true
    end
    for prequestgroupindex=1,#csvprequestgroup do
        local prequestgroup = csvprequestgroup[prequestgroupindex]
        local groupcomplete = true
        for i=1,#prequestgroup.prequest do
            local prequestinfo = playerattr_questcomplete[prequestgroup.prequest[i]]
            if prequestinfo == nil then
                groupcomplete = false
                break
            end
            if prequestgroup.prequestbranch[i] ~= nil and prequestgroup.prequestbranch[i] ~= prequestinfo.branch then
                groupcomplete = false
                break
            end
            local config_prequest = prequestgroup.config_prequest[i]
            if config_prequest ~= nil and config_prequest.repeatcount > 1 and prequestinfo.count < config_prequest.repeatcount then
                groupcomplete = false
                break
            end
        end
        if groupcomplete then
            return true
        end
    end
    return false
end

function playerquest_acceptable(config_quest)
    if config_quest == nil then
        return false
    end
    if config_quest.type ~= questtype.crafting and not csvqueststep_hasstep(config_quest.id) then
        return false
    end
    if playerattr_info.level < config_quest.level then
        return false
    end
    if bit.band(config_quest.civ, bit.lshift(1, playerattr_info.civ)) == 0 then
        return false
    end
    if bit.band(config_quest.career, bit.lshift(1, playerattr_info.career - 1)) == 0 then
        return false
    end
    if config_quest.sex ~= 0 and config_quest.sex ~= playerattr_info.sex then
        return false
    end
    if playerquest_getquest(config_quest.id) ~= nil then
        return false
    end
    local lambdapre = config_quest.prerequisite
    if lambdapre ~= nil then
        local actioncount = lambdapre.actioncount
        for lambdaindex=1,actioncount do
            local sublambda = lambdapre[lambdaindex]
            if c_isaction(sublambda, QuestAccept_preitem) then
                local itemid = sublambda.variable[1].integer
                local count = playeritem_getcount(itemid) + playeritem_getequipcount(itemid)
                if count < sublambda.variable[1].count then
                    return false
                end
            elseif c_isaction(sublambda, QuestAccept_preskill) then
                local craftingskill = playerskill_getcraftingskill(sublambda.variable[1].integer)
                if craftingskill == nil or craftingskill.level < sublambda.variable[1].count then
                    return false
                end
            end
        end
    end
    local questcomplete = playerattr_questcomplete[config_quest.id]
    if questcomplete ~= nil and config_quest.reset ~= 0 and csvquest_getrepeatcolding(config_quest, questcomplete.time) then
        return false
    end
    if config_quest.repeatcount == 1 then
        if questcomplete ~= nil then
            return false
        end
    elseif config_quest.repeatcount > 1 then
        if questcomplete ~= nil and questcomplete.count >= config_quest.repeatcount then
            return false
        end
    end
    if not playerquest_premissioncomplete(config_quest) or not playerquest_prequestcomplete(config_quest) then
        return false
    end
    local csvmutexaccept = csvquest_getmutexaccept(config_quest.id)
    if csvmutexaccept ~= nil then
        for i=1,#csvmutexaccept do
            local mutexquestid = csvmutexaccept[i]
            if playerquest_getquest(mutexquestid) ~= nil then
                return false
            end
        end
    end
    local csvmutexcomplete = csvquest_getmutexcomplete(config_quest.id)
    if csvmutexcomplete ~= nil then
        for i=1,#csvmutexcomplete do
            local mutexquestid = csvmutexcomplete[i]
            if playerattr_questcomplete[mutexquestid] ~= nil then
                return false
            end
        end
    end
    return true
end

function playerquest_prepair(questid)
    local config_quest = csvquest_getfromid(questid)
    if config_quest == nil then
        return false
    end
    if config_quest.type == questtype.crafting then
        local space = playerattr_bagspace - playeritem_getfillcount()
        if space < 3 then
            chat_addsystemalert("QUEST_ACCEPT_BAGFULL")
            return false
        end
    else
        local itemcount = 0
        local config_additive, config_step = csvqueststep_getstep(questid)
        local additivelambdaarray = config_additive[1]
        if additivelambdaarray ~= nil then
            for lambdaindex=1,#additivelambdaarray do
                local lambda = additivelambdaarray[lambdaindex]
                if lambda.action == QuestAddititve_Item then
                    itemcount = itemcount + #lambda.variable
                end
            end
        end
        if itemcount > 0 then
            local space = playerattr_bagspace - playeritem_getfillcount()
            if space < itemcount then
                chat_addsystemalert("QUEST_ACCEPT_BAGFULL")
                return false
            end
        end
    end
    return true
end

function playerquest_stepvisible(quest, stepindex)
    if quest.config_step ~= nil and stepindex <= #quest.config_step then
        local additivelambdaarray = quest.config_additive[stepindex]
        if additivelambdaarray ~= nil then
            for lambdaindex=1,#additivelambdaarray do
                local lambda = additivelambdaarray[lambdaindex]
                if lambda.action == QuestAddititve_Branch then
                    local visible = false
                    for i=1,#lambda.variable do
                        if lambda.variable[i].integer == quest.branch then
                            visible = true
                        end
                    end
                    return visible
                end
            end
        end
        return true
    end
    return false
end

function playerquest_talkvisible(quest)
    if quest.config_step == nil then
        return false
    end
    if quest.step <= 1 and quest.config_quest.type == questtype.main then
        if not playerquest_premissioncomplete(quest.config_quest) or not playerquest_prequestcomplete(quest.config_quest) then
            return false
        end
    end
    if not playerquest_stepvisible(quest, quest.step) then
        return false
    end
    return true
end

function playerquest_talkable(quest, config_npc, talkwithuncomplete)
    if not playerquest_talkvisible(quest) then
        return false
    end
    local steplambda = quest.config_step[quest.step]
    for lambdaindex=1,#steplambda do
        if quest.state == nil or lambdaindex > #quest.state then
            break
        end
        local lambda = steplambda[lambdaindex]
        if csvqueststep_istalklambda(lambda.action) then
            if lambda.variable[1].integer == config_npc.id then
                if quest.state[lambdaindex] == -1 then
                    return false
                end
                local reqcount = csvqueststep_getreqcount(lambda)
                if quest.state[lambdaindex] < reqcount then
                    return true
                end
                return false
            end
            if lambda.action == QuestStep_Talk and #lambda.variable == 1 and quest.state[lambdaindex] ~= -1 then
                break
            end
        else
            local reqcount = csvqueststep_getreqcount(lambda)
            if quest.state[lambdaindex] ~= -1 and quest.state[lambdaindex] < reqcount and not talkwithuncomplete then
                break
            end
        end
    end
    local additivelambdaarray = quest.config_additive[quest.step]
    if additivelambdaarray ~= nil then
        for lambdaindex=1,#additivelambdaarray do
            local additivelambda = additivelambdaarray[lambdaindex]
            if additivelambda.action == QuestAddititve_Talk or additivelambda.action == QuestAddititve_Spawn then
                if additivelambda.variable[1].integer == config_npc.id then
                    return true
                end
            end
        end
    end
    return false
end

function playerquest_itemchecked(quest)
    if quest.config_step == nil then
        return true
    end
    local steplambda = quest.config_step[quest.step]
    for lambdaindex=1,#steplambda do
        if steplambda[lambdaindex].action == QuestStep_GetItem or steplambda[lambdaindex].action == QuestStep_CheckItem then
            if quest.state ~= nil and lambdaindex <= #quest.state and quest.state[lambdaindex] ~= -1 then
                return false
            end
        end
    end
    return true
end

function playerquest_checksubmit(quest)
    if quest.config_quest.type == questtype.crafting then
        local config_task = csvcraftingtask_getfromid(quest.config_quest.id)
        if config_task == nil then
            return false
        end
        local subitem = string.splitnumber(config_task.product, "x")
        if playeritem_getcount(subitem[1]) < subitem[2] then
            return false
        end
    end
    return true
end
function playerquest_submitable(quest, config_npc, submitlist)
    if submitlist == nil then
        return false
    end
    if quest.config_step ~= nil and quest.step <= #quest.config_step then
        return false
    end
    for submitindex=1,#submitlist do
        if submitlist[submitindex] == quest.questid then
            if quest.config_submit.submitbranch ~= nil then
                for i=1,#quest.config_submit.submitbranch do
                    if quest.config_submit.submitbranch[i].branch == quest.branch
                    and quest.config_submit.submitbranch[i].npcid == config_npc.id then
                        return playerquest_checksubmit(quest)
                    end
                end
                return false
            end
            return playerquest_checksubmit(quest)
        end
    end
    return false
end

function playerquest_enterzone(zonename)
    local config_quest = csvquest_getautoaccept(zonename)
    if config_quest ~= nil then
        if playerquest_acceptable(config_quest) then
            local msg = {}
            msg.messageid = "CS_QuestAccept"
            msg.actorid = 0
            msg.questid = config_quest.id
            c_send(msg)
        end
    end
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_step ~= nil and quest.step <= #quest.config_step then
            local steplambda = quest.config_step[quest.step]
            for lambdaindex=1,#steplambda do
                local lambda = steplambda[lambdaindex]
                if lambda.action == QuestStep_Zone then
                    if lambda.variable[1].integer == scene_getmapid() and lambda.variable[2].str == zonename then
                        local msg = {}
                        msg.messageid = "CS_QuestStepZone"
                        msg.questid = quest.questid
                        c_send(msg)
                        break
                    end
                elseif lambda.action == QuestStep_Sphere then
                    if lambda.variable[1].integer == scene_getmapid() then
                        local px = lambda.variable[2].flt
                        local py = lambda.variable[3].flt
                        local pz = lambda.variable[4].flt
                        local dist = vector3_distance(px, py, pz, playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
                        if dist < lambda.variable[5].flt then
                            local msg = {}
                            msg.messageid = "CS_QuestStepZone"
                            msg.questid = quest.questid
                            c_send(msg)
                            break
                        end
                    end
                end
            end
		end
    end
end

function playerquest_isquestitem(itemid)
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_step ~= nil and quest.step <= #quest.config_step then
            local additivelambdaarray = quest.config_additive[quest.step]
            if additivelambdaarray ~= nil then
                for lambdaindex=1,#additivelambdaarray do
                    local additivelambda = additivelambdaarray[lambdaindex]
                    if additivelambda.action == QuestAddititve_Item then
                        for itemindex=1,#additivelambda.variable do
                            if additivelambda.variable[itemindex].integer == itemid then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end

local function playerquest_addmapnpclist(quest)
    if quest.config_step ~= nil and quest.step <= #quest.config_step then
        local npcicon = csvquest_getimagefromtypestate(quest.config_quest.type, queststate.talkable)
        if playerquest_talkvisible(quest) and npcicon ~= nil then
            local steplambdaarray = quest.config_step[quest.step]
            for lambdaindex=1,#steplambdaarray do
                if quest.state == nil or lambdaindex > #quest.state then
                    break
                end
                local lambda = steplambdaarray[lambdaindex]
                if csvqueststep_istalklambda(lambda.action) then
                    if quest.state[lambdaindex] ~= -1 then
                        local reqcount = csvqueststep_getreqcount(lambda)
                        if quest.state[lambdaindex] < reqcount then
                            playerattr_questnpcicon[lambda.variable[1].integer] = npcicon
                        end
                    end
                else
                    local reqcount = csvqueststep_getreqcount(lambda)
                    if quest.state[lambdaindex] ~= -1 and quest.state[lambdaindex] < reqcount then
                        break
                    end
                end
            end
            local additivelambdaarray = quest.config_additive[quest.step]
            if additivelambdaarray ~= nil then
                for lambdaindex=1,#additivelambdaarray do
                    local additivelambda = additivelambdaarray[lambdaindex]
                    if additivelambda.action == QuestAddititve_Talk or additivelambda.action == QuestAddititve_Spawn then
                        playerattr_questnpcicon[additivelambda.variable[1].integer] = npcicon
                        break
                    end
                end
            end
        end
    else
        local npcicon = csvquest_getimagefromtypestate(quest.config_quest.type, queststate.finish)
        if npcicon ~= nil then
            if playerquest_checksubmit(quest) then
                if quest.config_submit.submitbranch ~= nil then
                    for i=1,#quest.config_submit.submitbranch do
                        if quest.config_submit.submitbranch[i].branch == quest.branch then
                            playerattr_questnpcicon[quest.config_submit.submitbranch[i].npcid] = npcicon
                        end
                    end
                end
                if quest.config_submit.submitnpcarray ~= nil then
                    for i=1,#quest.config_submit.submitnpcarray do
                        playerattr_questnpcicon[quest.config_submit.submitnpcarray[i]] = npcicon
                    end
                elseif quest.config_submit.submitnpc ~= nil then
                    playerattr_questnpcicon[quest.config_submit.submitnpc] = npcicon
                end
            end
        end
    end
end

local function playerquest_addnameplatedropitem(quest, itemid)
    local additivelambdaarray = quest.config_additive[quest.step]
    if additivelambdaarray ~= nil then
        for lambdaindex=1,#additivelambdaarray do
            local lambda = additivelambdaarray[lambdaindex]
            if lambda.action == QuestAddititve_Drop and lambda.variable[1].integer == itemid then
                for i=3,#lambda.variable do
                    playerattr_questnpcnameplate[lambda.variable[i].integer] = quest.config_quest.type
                end
            end
        end
    end
end
local function playerquest_addnameplateicon(quest)
    if quest == nil or quest.config_step == nil or quest.step > #quest.config_step then
        return
    end
    local steplambdaarray = quest.config_step[quest.step]
    for lambdaindex=1,#steplambdaarray do
        local lambda = steplambdaarray[lambdaindex]
        if lambda.action == QuestStep_Kill then
            if quest.state ~= nil and quest.state[lambdaindex] ~= -1 then
                for i=2,#lambda.variable do
                    playerattr_questnpcnameplate[lambda.variable[i].integer] = quest.config_quest.type
                end
            end
        elseif lambda.action == QuestStep_GetItem or lambda.action == QuestStep_BagItem then
            if quest.state ~= nil and lambdaindex <= #quest.state and quest.state[lambdaindex] ~= -1 then
                local itemid = lambda.variable[1].integer
                local reqcount = lambda.variable[1].count
                if quest.state[lambdaindex] < reqcount then
                    playerquest_addnameplatedropitem(quest, itemid)
                end
            end
        end
    end
    local additivelambdaarray = quest.config_additive[quest.step]
    if additivelambdaarray ~= nil then
        for lambdaindex=1,#additivelambdaarray do
            local lambda = additivelambdaarray[lambdaindex]
            if lambda.action == QuestAddititve_Kill then
                for i=1,#lambda.variable do
                    playerattr_questnpcnameplate[lambda.variable[i].integer] = quest.config_quest.type
                end
            elseif lambda.action == QuestAddititve_PickItem then
                local itemid = lambda.variable[1].integer
                playerquest_addnameplatedropitem(quest, itemid)
            end
        end
    end
end

function playerquest_visible(config_quest)
    if config_quest.type ~= questtype.quest then
        return true
    end
    if gamesetting_getnumber("NORMALQUEST") == 0 then
        return false
    end
    if playerattr_info.level - config_quest.level > quest_visiblelevel and gamesetting_getnumber("LOWLEVELQUEST") == 0 then
        return false
    end
    return true
end

function playerquest_updatenpcicon()
    playerattr_questnpcicon = {}
    playerattr_questnpcnameplate = {}
    local npcaccept = csvquest_getnpcquestlistall()
    for npcid, questlist in pairs(npcaccept) do
		for i=1,#questlist do
            local config_quest = questlist[i]
            if playerquest_visible(config_quest) then
                local npcicon = csvquest_getimagefromtypestate(config_quest.type, queststate.acceptable)
                if npcicon ~= nil and playerquest_acceptable(config_quest) then
                    playerattr_questnpcicon[npcid] = npcicon
                end
            end
        end
	end
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_quest.type ~= questtype.main then
            playerquest_addmapnpclist(quest)
        end
    end
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_quest.type == questtype.main then
            playerquest_addmapnpclist(quest)
        end
    end
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_quest.type ~= questtype.main then
            playerquest_addnameplateicon(quest)
        end
    end
    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest.config_quest.type == questtype.main then
            playerquest_addnameplateicon(quest)
        end
    end
end
