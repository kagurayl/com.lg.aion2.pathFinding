

function SC_TeamAdvertList(msg)
	team_setadvert(msg)
end

function SC_TeamInviteSend(msg)
	chat_addsystemalert(c_textformat("TEAM_INVITE_SEND", msg.name))
end

function teaminvite_recv_confirm(ok, data)
	local msg = {messageid="CS_TeamInviteResponse"}
	msg.playerid = data
	msg.accept = math.ternary(ok, 1, 0)
	c_send(msg)
end
function SC_TeamInviteRecv(msg)
	local confirmtext = c_textformat("TEAM_INVITE_RECV", msg.name)
	messagebox_confirm(confirmtext, teaminvite_recv_confirm, msg.playerid, "TEAM_INVITE_ACCEPT", "TEAM_INVITE_REFUSE")
end

function SC_TeamInviteRefuse(msg)
	chat_addsystemalert("TEAM_INVITE_REFUSED")
end

function SC_TeamRequestSend(msg)
	chat_addsystemalert(c_textformat("RECRUIT_REQUEST_SEND", msg.name))
end

function SC_TeamRequestRecv(msg)
	if playerattr_team ~= nil then
		if playerattr_team.request == nil then
			playerattr_team.request = {}
		end
		for i=1,#playerattr_team.request do
			if playerattr_team.request[i].playerid == msg.playerid then
				table.remove(playerattr_team.request, i)
				break
			end
		end
		playerattr_team.request[#playerattr_team.request + 1] = msg
		chat_addsystemalert(c_textformat("RECRUIT_REQUEST_RECV", msg.name))
	end
	teamrequest_updateui()
end

function SC_TeamAddMate(msg)
	if playerattr_team ~= nil then
		playerattr_team.mate[#playerattr_team.mate + 1] = msg.info
		if playerattr_team.request ~= nil then
			for i=1,#playerattr_team.request do
				if playerattr_team.request[i].playerid == msg.info.playerid then
					table.remove(playerattr_team.request, i)
					teamrequest_updateui()
					break
				end
			end
		end
		sidebar_updateteam()
		local actor = actormanager_getfromactorid(msg.info.playerid)
		if actor ~= nil then
			actor:updatenameuilayout()
			selection_updatecolor(actor)
		end
		audiomanager_playaudioui(AudioTeamAddMate)
	end
end

function SC_TeamMate(msg)
	playerattr_teamselect = 0
	playerattr_team = {}
	playerattr_team.leader = msg.leader
	playerattr_team.kickable = msg.kickable
	playerattr_team.leaveable = msg.leaveable
	playerattr_team.mate = msg.mate
	playerattr_team.pickitem = msg.pickitem
	playerattr_team.randquality = msg.randquality
	team_setpickitem_showpickitem()
	sidebar_openteam()
	for i=1,#playerattr_team.mate do
		local mate = playerattr_team.mate[i]
		local actor = actormanager_getfromactorid(mate.playerid)
		if actor ~= nil then
			actor:updatenameuilayout()
			selection_updatecolor(actor)
		end
	end
	audiomanager_playaudioui(AudioTeamAddMate)
end

function SC_TeamSight(msg)
	if playerattr_team ~= nil then
		for i=1,#playerattr_team.mate do
			local mate = playerattr_team.mate[i]
			if mate.playerid == msg.playerid then
				mate.career = msg.career
				mate.level = msg.level
				mate.online = msg.online
				mate.hp = msg.hp
				mate.hpmax = msg.hpmax
				mate.mp = msg.mp
				mate.mpmax = msg.mpmax
				mate.fp = msg.fp
				mate.fpmax = msg.fpmax
				mate.flying = msg.flying
				mate.mapid = msg.mapid
				mate.posx = msg.posx
				mate.posy = msg.posy
				mate.posz = msg.posz
			end
		end
		sidebar_updateteam()
	end
end

function SC_TeamLeader(msg)
	playerattr_team.leader = msg.playerid
	if msg.playerid ~= playerattr_info.actorid then
		for i=1,#playerattr_team.mate do
			local mate = playerattr_team.mate[i]
			if mate.playerid == msg.playerid then
				chat_addsystemalert(c_textformat("TEAM_NOTIFY_LEADER_MATE", mate.name))
				break
			end
		end
	else
		chat_addsystemalert("TEAM_NOTIFY_LEADER_ME")
	end
	sidebar_updateteam()
end

function SC_TeamLeave(msg)
	if msg.playerid ~= playerattr_info.actorid then
		if playerattr_team ~= nil then
			for i=1,#playerattr_team.mate do
				local mate = playerattr_team.mate[i]
				if mate.playerid == msg.playerid then
					table.remove(playerattr_team.mate, i)
					if msg.kick > 0 then
						chat_addsystemalert(c_textformat("TEAM_NOTIFY_KICK_MATE", mate.name))
					else
						chat_addsystemalert(c_textformat("TEAM_NOTIFY_EXIT_MATE", mate.name))
					end
					break
				end
			end
		end
		local actor = actormanager_getfromactorid(msg.playerid)
		if actor ~= nil then
			actor:updatenameuilayout()
			selection_updatecolor(actor)
		end
	elseif playerattr_team ~= nil then
		local teammate = playerattr_team.mate
		playerattr_team = nil
		for i=1,#teammate do
			local mate = teammate[i]
			local actor = actormanager_getfromactorid(mate.playerid)
			if actor ~= nil then
				actor:updatenameuilayout()
				selection_updatecolor(actor)
			end
		end
		if msg.kick > 0 then
			chat_addsystemalert("TEAM_NOTIFY_KICK_ME")
		else
			chat_addsystemalert("TEAM_NOTIFY_EXIT_ME")
		end
		team_setpickitem_close()
	end
	sidebar_updateteam()
	audiomanager_playaudioui(AudioTeamAddMate)
end

function SC_TeamSummon(msg)
	team_summon_open(msg.playername, msg.skillid, msg.time)
end

function SC_TeamSummonConfirm(msg)
	if msg.accept > 0 then
		chat_addsystemalert(c_textformat("TEAM_SUMMON_ACCEPT", msg.playername))
	else
		chat_addsystemalert(c_textformat("TEAM_SUMMON_REFUSE", msg.playername))
	end
end

function SC_TeamPickItem(msg)
	if playerattr_team ~= nil then
		playerattr_team.pickitem = msg.pickitem
		team_setpickitem_updateui()
		team_setpickitem_showpickitem()
	end
end

function SC_TeamRandItem(msg)
	if playerattr_team ~= nil then
		playerattr_team.randquality = msg.quality
		team_setpickitem_updateui()
		team_setpickitem_showpickitem()
	end
end

function SC_TeamRandStart(msg)
	team_randitem_additem(msg.itemid, msg.count, msg.randid, msg.timelength)
end

function SC_TeamRandPoint(msg)
	local colorname = csvitem_getcolornamefromid(msg.itemid)
	if msg.point > 0 then
		if msg.playername == playerattr_info.name then
			chat_addsystemalert(c_textformat("TEAM_RANDITEM_RANDIDME", colorname, msg.point))
		else
			chat_addsystem(c_textformat("TEAM_RANDITEM_RANDID", msg.playername, colorname, msg.point))
		end
	else
		if msg.playername == playerattr_info.name then
			chat_addsystem(c_textformat("TEAM_RANDITEM_RANDPASSME", colorname))
		else
			chat_addsystem(c_textformat("TEAM_RANDITEM_RANDPASS", msg.playername, colorname))
		end
	end
	if msg.playername == playerattr_info.name then
		team_randitem_onrand(msg.randid)
	end
end

function SC_TeamRandPass(msg)
	chat_addsystem(c_textformat("TEAM_RANDITEM_RANDALLPASS", csvitem_getcolornamefromid(msg.itemid)))
end

function SC_TeamGetItem(msg)
	if msg.playername == playerattr_info.name then
		chat_addsystemalert(textformat_args("STR_GET_ITEM1", csvitem_getcolornamefromid(msg.itemid)))
	else
		chat_addsystem(textformat_args("STR_PARTY_ITEM_WIN", msg.playername, csvitem_getcolornamefromid(msg.itemid)))
	end
end
