
function SC_RaidInviteSend(msg)
	chat_addsystemalert(c_textformat("TEAM_RAID_INVITE_SEND", msg.name))
end

function raidinvite_recv_confirm(ok, data)
	local msg = {messageid="CS_RaidInviteResponse"}
	msg.playerid = data
	msg.accept = math.ternary(ok, 1, 0)
	c_send(msg)
end
function SC_RaidInviteRecv(msg)
	local confirmtext = c_textformat("TEAM_RAID_INVITE_RECV", msg.name)
	messagebox_confirm(confirmtext, raidinvite_recv_confirm, msg.playerid, "TEAM_INVITE_ACCEPT", "TEAM_INVITE_REFUSE")
end

function SC_RaidInviteRefuse(msg)
	chat_addsystemalert("TEAM_RAID_INVITE_REFUSED")
end

function SC_RaidRequestSend(msg)
	chat_addsystemalert(c_textformat("TEAM_RAID_INVITE_SEND", msg.name))
end

function SC_RaidRequestRecv(msg)
	if playerattr_raid.request == nil then
		playerattr_raid.request = {}
	end
	for i=1,#playerattr_raid.request do
		if playerattr_raid.request[i].playerid == msg.playerid then
			table.remove(playerattr_raid.request, i)
			break
		end
	end
	playerattr_raid.request[#playerattr_raid.request + 1] = msg
	chat_addsystemalert(c_textformat("RECRUIT_RAID_REQUEST_RECV", msg.name))
	teamrequest_updateui()
end

function SC_RaidAddMate(msg)
	if playerattr_raid ~= nil then
		playerattr_raid.mate[#playerattr_raid.mate + 1] = msg.info
		if playerattr_raid.request ~= nil then
			for i=1,#playerattr_raid.request do
				if playerattr_raid.request[i].playerid == msg.info.playerid then
					table.remove(playerattr_raid.request, i)
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

function SC_RaidMate(msg)
	playerattr_raid = {}
	playerattr_raid.leader = msg.leader
	playerattr_raid.mate = msg.mate
	playerattr_raid.pickitem = msg.pickitem
	playerattr_raid.matemove = msg.matemove
	--team_setpickitem_showpickitem()
	sidebar_openteam()
	for i=1,#playerattr_raid.mate do
		local mate = playerattr_raid.mate[i]
		local actor = actormanager_getfromactorid(mate.playerid)
		if actor ~= nil then
			actor:updatenameuilayout()
			selection_updatecolor(actor)
		end
	end
	audiomanager_playaudioui(AudioTeamAddMate)
	chat_addsystemalert("TEAM_NOTIFY_RAID_ME")
end

function SC_RaidSight(msg)
	if playerattr_raid ~= nil then
		for i=1,#playerattr_raid.mate do
			local mate = playerattr_raid.mate[i]
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

function SC_RaidLeader(msg)
	playerattr_raid.leader = msg.playerid
	if msg.playerid ~= playerattr_info.actorid then
		for i=1,#playerattr_raid.mate do
			local mate = playerattr_raid.mate[i]
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

function SC_RaidLeave(msg)
	if msg.playerid ~= playerattr_info.actorid then
		if playerattr_raid ~= nil then
			for i=1,#playerattr_raid.mate do
				local mate = playerattr_raid.mate[i]
				if mate.playerid == msg.playerid then
					table.remove(playerattr_raid.mate, i)
					if msg.kick > 0 then
						chat_addsystemalert(c_textformat("TEAM_NOTIFY_KICK_MATE_RAID", mate.name))
					else
						chat_addsystemalert(c_textformat("TEAM_NOTIFY_EXIT_MATE_RAID", mate.name))
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
	elseif playerattr_raid ~= nil then
		local teammate = playerattr_raid.mate
		playerattr_raid = nil
		for i=1,#teammate do
			local mate = teammate[i]
			local actor = actormanager_getfromactorid(mate.playerid)
			if actor ~= nil then
				actor:updatenameuilayout()
				selection_updatecolor(actor)
			end
		end
		if msg.kick > 0 then
			chat_addsystemalert("TEAM_NOTIFY_KICK_ME_RAID")
		else
			chat_addsystemalert("TEAM_NOTIFY_EXIT_ME_RAID")
		end
		team_setpickitem_close()
	end
	sidebar_updateteam()
	audiomanager_playaudioui(AudioTeamAddMate)
end

function SC_RaidMoveSlot(msg)
	if playerattr_raid ~= nil then
		for i=1,#playerattr_raid.mate do
			local mate = playerattr_raid.mate[i]
			if mate.playerid == msg.playerid then
				for j=1,#playerattr_raid.mate do
					local mate2 = playerattr_raid.mate[j]
					if mate2.index == msg.slot then
						mate2.index = mate.index
						local actor2 = actormanager_getfromactorid(mate2.playerid)
						if actor2 ~= nil then
							actor2:updatenameuilayout()
							selection_updatecolor(actor2)
						end
						break
					end
				end
				mate.index = msg.slot
				if mate.playerid == playerattr_info.actorid then
					for j=1,#playerattr_raid.mate do
						local actor = actormanager_getfromactorid(playerattr_raid.mate[j].playerid)
						if actor ~= nil then
							actor:updatenameuilayout()
							selection_updatecolor(actor)
						end
					end
				else
					local actor = actormanager_getfromactorid(mate.playerid)
					if actor ~= nil then
						actor:updatenameuilayout()
						selection_updatecolor(actor)
					end
				end
				sidebar_updateteam()
				break
			end
		end
	end
end

function SC_RaidPickItem(msg)
	if playerattr_raid ~= nil then
		playerattr_raid.pickitem = msg.pickitem
		team_setpickitem_updateui()
		--team_setpickitem_showpickitem()
	end
end

function SC_RaidMateMoveEnable(msg)
	if playerattr_raid ~= nil then
		playerattr_raid.matemove = msg.enable
		raid_main_updateui()
	end
end
