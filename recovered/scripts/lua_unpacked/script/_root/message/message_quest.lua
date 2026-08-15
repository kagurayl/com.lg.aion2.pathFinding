
local function queststepstatealert(quest, nextstep, nextstate)
	if quest.config_step == nil then
		return
	end
	if nextstep == quest.step then
		if nextstate == nil then
			return
		end
		local same = true
		for i=1,#nextstate do
			if quest.state[i] ~= nextstate[i] then
				same = false
				break
			end
		end
		if same then
			return
		end
	end
	audiomanager_playaudioui(AudioQuestStepSuccess)
	local text, step = csvxml_getsummary(quest.xmlcontent, "quest_summary")
	if step == nil then
		return
	end
	local chatalerttext = textformat_args("STR_QUEST_SYSTEMMSG_UPDATE", quest.config_quest.name)
	chat_addsystem(chatalerttext)
	if nextstep > quest.step then
		local steplambda = quest.config_step[quest.step]
		local viewstateindex = 0
		if steplambda ~= nil then
			for lambdaindex=1,#steplambda do
				local lambda = steplambda[lambdaindex]
				local reqcount = csvqueststep_getreqcount(lambda)
				if quest.state ~= nil and lambdaindex <= #quest.state and quest.state[lambdaindex] ~= -1 and quest.state[lambdaindex] < reqcount then
					viewstateindex = lambdaindex
					break
				end
			end
		end
		quest.state = nil
		if nextstep <= #step then
			quest.step = nextstep
			quest.state = nextstate
			local desctext = questdesc_convertstep(quest, quest.step, step[quest.step], questdesctype.main)
			messagealert_addquest(desctext)
		else
			local desctext = nil
			if viewstateindex > 0 then
				desctext = questdesc_convertstep(quest, quest.step, step[quest.step], questdesctype.state, viewstateindex)
			end
			if desctext ~= nil then
				messagealert_addquest(desctext)
			else
				messagealert_addquest(chatalerttext)
			end
		end
	elseif nextstate ~= nil then
		local desctext = nil
		for i=1,#nextstate do
			if i <= #quest.state and quest.state[i] ~= -1 and quest.state[i] < nextstate[i] then
				quest.state = nextstate
				desctext = questdesc_convertstep(quest, quest.step, step[quest.step], questdesctype.state, i)
				break
			end
		end
		if desctext ~= nil then
			messagealert_addquest(desctext)
		end
	end
end

local function questinitconfig(quest)
	quest.config_quest = csvquest_getfromid(quest.questid)
	quest.config_additive, quest.config_step = csvqueststep_getstep(quest.questid)
	quest.xmlcontent = c_config_loadxml(csvquest_getxml(quest.questid))
	quest.config_submit = csvquest_parsesubmit(quest.config_quest, quest.config_additive, quest.config_step)
end

local function updatequestui(activequest)
	playerquest_updatenpcicon()
	quest_main_updateui()
	if activequest ~= nil then
		sidebar_activequest(activequest.questid)
	else
		sidebar_updatequest()
	end
	if m_uimap_main:alive() then
		maplabel_updateui()
	end
	mapopacity_updateui()
	actormanager_updatehead()
end

function SC_QuestReset(msg)
	if msg.type == 0 then
		playerattr_info.questresetday = msg.second
	else
		playerattr_info.questresetweek = msg.second
		playerattr_pvp.kill_lastweek = playerattr_pvp.kill_week
		playerattr_pvp.kill_week = 0
		player_main_updateui()
	end
	updatequestui()
end

function SC_QuestDailyReset(msg)
	playerattr_info.dailyquest = msg.questid
end

function SC_QuestList(msg)
	playerquest_clear()
	playerattr_info.dailyquest = msg.dailyquest
	playerattr_info.questexp50 = msg.questexp50
	playerattr_info.questexp55 = msg.questexp55
	for i=1,#msg.accept do
		local info = msg.accept[i]
		local quest = {}
		quest.questid = info.questid
		quest.trace = info.trace
		quest.step = info.step + 1
		quest.state = info.state
		quest.branch = info.branch
		questinitconfig(quest)
		playerattr_quest[i] = quest
    end
	for i=1,#msg.questrepeat do
		local info = msg.questrepeat[i]
		local quest = {}
		quest.questid = info.questid
		quest.count = info.count
		quest.branch = 0
		quest.time = info.time
		playerattr_questcomplete[quest.questid] = quest
    end
	for i=1,#msg.complete do
		local info = msg.complete[i]
		local quest = {}
		quest.questid = info.questid
		quest.count = 1
		quest.branch = info.branch
		quest.time = 0
		playerattr_questcomplete[quest.questid] = quest
    end
	quest_main_updateui()
	if m_uimap_main:alive() then
		maplabel_updateui()
	end
	mapopacity_updateui()
end

function SC_QuestAcceptConfirm(msg)
	dialog_main_setdialogaccept(msg.questid, 0)
end

function SC_QuestShare(msg)
	local config_quest = csvquest_getfromid(msg.questid)
	if config_quest ~= nil then
		local alerttext = c_textformat("QUEST_SHAREFROMPLAYER", msg.playername, config_quest.name)
		messagealert_addquest(alerttext)
		chat_addsystem(alerttext)
		dialog_main_setdialogaccept(msg.questid, msg.actorid)
		actormanager_updatenameplatevisible()
	end
end

function SC_QuestAccept(msg)
	local quest = {}
	quest.questid = msg.questid
	quest.trace = 1
	quest.step = msg.step + 1
	quest.state = msg.state
	quest.branch = msg.branch
	questinitconfig(quest)
	for i=1,#playerattr_quest do
		if playerattr_quest[i].questid == msg.questid then
			table.remove(playerattr_quest, i)
			break
		end
    end
	playerattr_quest[#playerattr_quest + 1] = quest
	updatequestui(quest)
	if quest.config_quest.type ~= questtype.main then
		chat_addsystemalert(textformat_args("STR_QUEST_SYSTEMMSG_ACQUIRE", quest.config_quest.name))
	end
	if quest.config_quest.type == questtype.main then
		quest_main_showquest(quest.questid, true)
		audiomanager_playaudioui(AudioMissionAccept)
	else
		quest_main_showquest(quest.questid, false)
		audiomanager_playaudioui(AudioQuestAccept)
	end
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		dialog_main_setdialog(npctalktype.talkselect, msg.actorid, npc.config_npc, msg.questid, XML_AcceptQuest)
	else
		npc_closedialog()
	end
	tutorial_start(tutorialid.quest)
	actormanager_updatenameplatevisible()
end

function SC_PlayMovie(msg)
	if scene_isloading() then
		scene_getloadingattr().cutscene = msg.id
	else
		local config_cutscene = c_config_getmetaid(configid.cutscene, msg.id)
		if config_cutscene ~= nil then
			cgmask_start(config_cutscene.name, config_cutscene.timestart, config_cutscene.timeend - config_cutscene.timestart, true)
		end
	end
end

function SC_PlayVideo(msg)
	cgvideo_start(msg.moviename)
end

function SC_QuestBranch(msg)
	local quest = playerquest_getquest(msg.questid)
	if quest ~= nil then
		quest.branch = msg.branch
    end
end

function SC_QuestNotify(msg)
	local xmlcontent = c_config_loadxml(csvquest_getxml(msg.questid))
	if xmlcontent == nil then
		return
	end
	local text = csvxml_getnotify(xmlcontent, "quest_summary", msg.progress)
	if text ~= nil then
		messagealert_addquest(text)
	end
end

function SC_QuestTime(msg)
	questtime_create(msg.questid, msg.step, msg.timesecond)
end

function SC_QuestSelectReward(msg)
	local quest = playerquest_getquest(msg.questid)
	if quest ~= nil and quest.config_step ~= nil then
		local nextstep = #quest.config_step + 1
		queststepstatealert(quest, nextstep, nil)
		quest.step = nextstep
		updatequestui()
		audiomanager_playaudioui(AudioQuestStepSuccess)
		local npc = actormanager_getfromactorid(msg.actorid)
		if npc ~= nil then
			dialog_main_setdialog(npctalktype.talkselect, msg.actorid, npc.config_npc, msg.questid, XML_SelectQuestReward .. (quest.branch + 1))
		end
    end
end

function SC_QuestCheckItem(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	local quest = playerquest_getquest(msg.questid)
	if quest ~= nil and npc ~= nil and quest.config_step ~= nil then
		local ackname = nil
		local steplambdaarray = quest.config_step[msg.checkstep + 1]
		if steplambdaarray ~= nil then
			for i=1,#steplambdaarray do
				local lambda = steplambdaarray[i]
				if csvqueststep_istalklambda(lambda.action) and #lambda.variable > 3 then
					if msg.success == 1 then
						ackname = lambda.variable[3].str
					else
						ackname = lambda.variable[4].str
					end
				end
			end
			if ackname == nil and msg.success == 0 then
				ackname = XML_QuestItemFailed
			end
			if ackname ~= nil then
				dialog_main_setdialog(npctalktype.talkselect, msg.actorid, npc.config_npc, msg.questid, ackname)
			end
		end
	end
end

function SC_QuestStepState(msg)
	local quest = playerquest_getquest(msg.questid)
	if quest ~= nil then
		queststepstatealert(quest, msg.step + 1, msg.state)
		quest.state = msg.state
		quest.step = msg.step + 1
		updatequestui()
		actormanager_updatenameplatevisible()
	end
end

function SC_QuestSubmit(msg)
	for i=1,#playerattr_quest do
		if playerattr_quest[i].questid == msg.questid then
			local config_quest = playerattr_quest[i].config_quest
			local alerttext = textformat_args("STR_QUEST_SYSTEMMSG_COMPLETE", config_quest.name)
			messagealert_addquest(alerttext)
			chat_addsystem(alerttext)
			table.remove(playerattr_quest, i)
			if config_quest.type == questtype.main then
				audiomanager_playaudioui(AudioMissionReward)
			else
				audiomanager_playaudioui(AudioQuestReward)
			end
			break
		end
    end
	local questcomplete = playerattr_questcomplete[msg.questid]
	if questcomplete ~= nil then
		questcomplete.time = msg.time
		questcomplete.count = questcomplete.count + 1
	else
		local questcomplete = {}
		questcomplete.questid = msg.questid
		questcomplete.time = msg.time
		questcomplete.count = 1
		questcomplete.branch = msg.branch
		playerattr_questcomplete[msg.questid] = questcomplete
	end
	if msg.questid == playerattr_info.dailyquest then
		playerattr_info.dailyquest = 0
	end
	updatequestui()
	local acceptnext = 0
	local npc = actormanager_getfromactorid(m_selectactorid)
    if npc ~= nil and npc:isnpc() then
		local quest = csvnpc_getnpcquestlist(npc.config_npc, false)
		for questindex=1,#quest do
			if quest[questindex].state == queststate.acceptable then
				local config_quest = quest[questindex].config_quest
				local csvpremission = csvquest_getpremission(config_quest.id)
				if csvpremission ~= nil then
					for i=1,#csvpremission do
						if csvpremission[i] == msg.questid then
							acceptnext = config_quest.id
							break
						end
					end
					if acceptnext ~= 0 then
						break
					end
				end
				if acceptnext == 0 then
					local csvprequestgroup = csvquest_getprequestgroup(config_quest.id)
					if csvprequestgroup ~= nil then
						for prequestgroupindex=1,#csvprequestgroup do
							local prequestgroup = csvprequestgroup[prequestgroupindex]
							for i=1,#prequestgroup.prequest do
								if prequestgroup.prequest[i] == msg.questid then
									if prequestgroup.prequestbranch[i] == nil or prequestgroup.prequestbranch[i] == msg.branch then
										acceptnext = config_quest.id
										break
									end
								end
							end
							if acceptnext ~= 0 then
								break
							end
						end
					end
				end
			end
			if acceptnext ~= 0 then
				break
			end
		end
	end
	if acceptnext ~= 0 then
		npc_sendtalk(m_selectactorid, npctalktype.talkstart, acceptnext, nil)
	else
		npc_closedialog()
	end
	actormanager_updatenameplatevisible()
end

function SC_QuestAbandon(msg)
	for i=1,#playerattr_quest do
		local config_quest = playerattr_quest[i].config_quest
		if config_quest.id == msg.questid then
			local alerttext = textformat_args("STR_QUEST_SYSTEMMSG_GIVEUP", config_quest.name)
			messagealert_addquest(alerttext)
			chat_addsystem(alerttext)
			audiomanager_playaudioui(AudioQuestDelete)
			table.remove(playerattr_quest, i)
			updatequestui()
			actormanager_updatenameplatevisible()
			break
		end
    end
end

function SC_QuestNASubmit(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		dialog_main_setdialognasubmit(msg.actorid, npc.config_npc, msg.questid, msg.branch)
	else
		npc_closedialog()
	end
end
