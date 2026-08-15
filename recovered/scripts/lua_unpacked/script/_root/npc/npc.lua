include("npc/dialogtask")
include("npc/dialogmain")
include("npc/dialogscripthtml")
include("npc/dialogscript")
include("npc/artifact")
include("npc/abyssrepair")
include("npc/pickitem")
include("npc/npcstatic")
include("npc/equipcharge")

function npc_closedialog()
    m_uinpc_dialogmain:close()
end

function npc_sendtalk(actorid, type, questid, selectname)
    local msg = {messageid="CS_NPCTalk"}
    msg.actorid = actorid
    msg.type = type
    msg.questid = questid
    msg.name = selectname
    c_send(msg)
end

function npc_startscript(actorid)
    joystick_stoplockmove()
    local npc = actormanager_getfromactorid(actorid)
    if npc == nil or not npc:isnpc() then
        return
    end
    if not npc:isdead() and npc:isenemy() and npc:attackable() then
        playerbattleauto_startnormalattack(actorid)
        return
    end

    local talkdist = 0.0
    if npc:isharvest() then
        talkdist = npc:gettalkdist(3.0)
    else
        talkdist = npc:gettalkdist(5.0)
    end
    
    local talkable = false
    if npc:isstaticnpc() then
        local cx, cy, cz, sx, sy, sz, nameheight = csvnpc_getboundbox(npc.config_npcstatic.bound, 1.0)
        local dist = vector2_distance(npc.transform.px, npc.transform.pz, m_me.transform.px, m_me.transform.pz)
        local heightsize = sy / 2
        local top = npc.transform.py + cy + heightsize
        local bottom = npc.transform.py + cy - heightsize
        local disttop = m_me.transform.py - top
        local distbottom = bottom - m_me.transform.py
        talkable = dist < talkdist and (disttop - talkdist < heightsize or distbottom - talkdist < heightsize)
    else
        local dist = vector3_distance(npc.transform.px,npc.transform.py,npc.transform.pz, m_me.transform.px,m_me.transform.py,m_me.transform.pz)
        talkable = dist < talkdist
    end
    if not talkable then
        if gamesetting_getnumber("MANUALMOVEIN") == 0 then
    		playerapproach_talk(actorid, talkdist)
            return
        end
	end
    if npc:isdead() then
        pickitem_query(actorid)
        return
    end
    if npc:isharvest() then
        if npc.config_npc.skillid == skill_gather_low and playercareeradvance(playerattr_info.career) then
            chat_addsystemalert(c_textformat("STR_GATHER_INCORRECT_SKILL"))
            return
        end
        local craftingskill = playerskill_getcraftingskill(npc.config_npc.skillid)
        if craftingskill == nil then
            return
        end
        local config_craftingskill = csvskill_getfromid(npc.config_npc.skillid)
        if config_craftingskill == nil then
            return
        end
        if craftingskill.level < npc.config_npc.skilllevel then
            chat_addsystemalert(c_textformat("CRAFTING_GATHER_SKILL", config_craftingskill.name, npc.config_npc.skilllevel))
            return
        end
        if playerattr_info.level < npc.config_npc.playerlevel then
            chat_addsystemalert(c_textformat("CRAFTING_GATHER_LEVEL",npc.config_npc.playerlevel))
            return
        end
        local msg = {messageid="CS_CraftingGather"}
        msg.actorid = actorid
        c_send(msg)
        return
    end
    local questlist = csvnpc_getnpcquestlist(npc.config_npc, true)
    if #questlist > 0 then
        if #questlist > 1 or csvnpc_getscript(npc.config_npc, "dialog") ~= nil then
            npc_sendtalk(actorid, npctalktype.talkstart, 0, nil)
            return
        end
        local questid = questlist[1].config_quest.id
        local quest = playerquest_getquest(questid)
        if quest == nil or quest.config_step == nil then
            npc_sendtalk(actorid, npctalktype.talkstart, 0, nil)
            return
        end
        if quest.step > #quest.config_step then
            npc_sendtalk(actorid, npctalktype.talkselect, questid, XML_SelectQuestReward .. (quest.branch + 1))
            return
        end
        local ackname = nil
		local steplambdaarray = quest.config_step[quest.step]
		for i=1,#steplambdaarray do
			local lambda = steplambdaarray[i]
			if csvqueststep_istalklambda(lambda.action) and #lambda.variable > 1 and lambda.variable[1].integer == npc.config_npc.id  then
				ackname = lambda.variable[2].str
                break
			end
		end
        if ackname ~= nil then
            npc_sendtalk(actorid, npctalktype.talkselect, quest.questid, ackname)
        else
            npc_sendtalk(actorid, npctalktype.interactstart, quest.questid, nil)
        end
        return
    end

    for questindex=1,#playerattr_quest do
        local quest = playerattr_quest[questindex]
        if quest ~= nil and quest.config_step ~= nil and quest.step <= #quest.config_step then
            local steplambdaarray = quest.config_step[quest.step]
            for i=1,#steplambdaarray do
                local lambda = steplambdaarray[i]
                if lambda.action == QuestStep_Kill then
                    for i=2,#lambda.variable do
                        if lambda.variable[i].integer == npc.config_npc.id then
                            npc_sendtalk(actorid, npctalktype.interactstart, quest.questid, nil)
                            return
                        end
                    end
                end
            end
            local additivelambdaarray = quest.config_additive[quest.step]
            if additivelambdaarray ~= nil then
                for lambdaindex=1,#additivelambdaarray do
                    local lambda = additivelambdaarray[lambdaindex]
                    if lambda.action == QuestAddititve_Drop then
                        for i=3,#lambda.variable do
                            if lambda.variable[i].integer == npc.config_npc.id then
                                npc_sendtalk(actorid, npctalktype.interactstart, quest.questid, nil)
                                return
                            end
                        end
                    elseif lambda.action == QuestAddititve_Spawn then
                        if lambda.variable[1].integer == npc.config_npc.id then
                            npc_sendtalk(actorid, npctalktype.interactstart, quest.questid, nil)
                            return
                        end
                    elseif lambda.action == QuestAddititve_Interact then
                        for i=1,#lambda.variable do
                            if lambda.variable[i].integer == npc.config_npc.id then
                                npc_sendtalk(actorid, npctalktype.interactstart, quest.questid, nil)
                                return
                            end
                        end
                    end
                end
            end
        end
    end

    if csvnpc_getscript(npc.config_npc, "dialog") ~= nil then
        npc_sendtalk(actorid, npctalktype.talkstart, 0, nil)
        return
    end

    local script = dialog_scriptoption_scripttext(npc.config_npc)
    if script ~= nil then
        npc_sendtalk(actorid, npctalktype.talkmodule, 0, nil)
        return
    end

    if csvnpc_getscript(npc.config_npc, "pattern") ~= nil
    or csvnpc_getscript(npc.config_npc, "talkdistance") ~= nil
    or csvnpc_getscript(npc.config_npc, "talkdelay") ~= nil
    or csvnpc_getscript(npc.config_npc, "talkanim") ~= nil then
        npc_sendtalk(actorid, npctalktype.interactstart, 0, nil)
        return
    end
end
