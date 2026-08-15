
local function icc_updatenameui(actorid)
	local actor = actormanager_getfromactorid(actorid)
	if actor ~= nil then
		actor:updatenameuilayout()
	end
end

function icc_updateui()
	icc_main_updateui()
	icc_logo_updateui()
end

function SC_IccInfo(msg)
	playerattr_icc = msg
	playerattr_info.iccname = msg.name
	playerattr_info.icclogo = msg.logo
	icc_updatenameui(playerattr_info.actorid)
	if m_me ~= nil then
		m_me:setreloadasset(false)
	end
end

function SC_IccCreating(msg)
	chat_addsystemalert(c_textformat("ICC_CREATE_CREATING", msg.name))
end

function SC_IccCreatSuccess(msg)
	chat_addsystemalert(c_textformat("ICC_CREATE_SUCCESS", msg.name))
	m_uiicc_main:open()
end

function SC_IccRename(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.iccname = msg.name
		actor:updatenameuilayout()
		if actor:isme() then
			if playerattr_icc ~= nil then
				playerattr_icc.name = msg.name
			end
			chat_addsystemalert(c_textformat("ICC_NOTIFY_RENAME", msg.name))
			icc_updateui()
		end
	end
end

function SC_IccSetLogo(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.icclogo = msg.logo
		if actor:isme() then
			if playerattr_icc ~= nil and gamesetting_getnumber("RENDEREMBLEM") > 0 then
				actor:setreloadasset(false)
			end
			icc_updateui()
		elseif actor:isplayer() then
			if actor.attr.renderemblem > 0 then
				actor:setreloadasset(false)
			end
		end
	end
end

function SC_IccInviteSend(msg)
	chat_addsystemalert(c_textformat("ICC_INVITE_SEND", msg.name))
end

function SC_IccInviteRefuse(msg)
	chat_addsystemalert(c_textformat("ICC_INVITE_REFUSED", msg.name))
end

function iccinvite_recv_confirm(ok, data)
	local msg = {messageid="CS_IccInviteResponse"}
	msg.playerid = data
	msg.accept = math.ternary(ok, 1, 0)
	c_send(msg)
end
function SC_IccInviteRecv(msg)
	local confirtext = c_textformat("ICC_INVITE_RECV", msg.playername, msg.iccname)
	messagebox_confirm(confirtext, iccinvite_recv_confirm, msg.playerid, "ICC_INVITE_ACCEPT", "ICC_INVITE_REFUSE")
end

function SC_IccAddMember(msg)
	chat_addsystemalert(c_textformat("ICC_NOTIFY_PLAYERJOIN", msg.info.name))
	playerattr_icc.member[#playerattr_icc.member + 1] = msg.info
	icc_updateui()
end

function SC_IccJoin(msg)
	chat_addsystemalert(c_textformat("ICC_NOTIFY_JOIN", msg.name))
end

function SC_IccKick(msg)
	if msg.playerid == playerattr_info.actorid then
		chat_addsystemalert("ICC_NOTIFY_KICK")
		playerattr_icc = nil
		icc_updateui()
		if m_me ~= nil then
			m_me:setreloadasset(false)
		end
	else
		for i=1,#playerattr_icc.member do
			local member = playerattr_icc.member[i]
			if member.playerid == msg.playerid then
				chat_addsystemalert(c_textformat("ICC_NOTIFY_MEMBERKICK", member.name))
				table.remove(playerattr_icc.member, i)
				icc_updateui()
				break
			end
		end
	end
end

function SC_IccLeave(msg)
	if msg.playerid == playerattr_info.actorid then
		chat_addsystemalert("ICC_NOTIFY_LEAVE")
		playerattr_icc = nil
		icc_updateui()
		if m_me ~= nil then
			m_me:setreloadasset(false)
		end
	else
		for i=1,#playerattr_icc.member do
			local member = playerattr_icc.member[i]
			if member.playerid == msg.playerid then
				chat_addsystemalert(c_textformat("ICC_NOTIFY_MEMBERLEAVE", member.name))
				table.remove(playerattr_icc.member, i)
				icc_updateui()
				break
			end
		end
	end
end

function SC_IccSenior(msg)
	for i=1,#playerattr_icc.member do
		if playerattr_icc.member[i].playerid == msg.playerid then
			playerattr_icc.member[i].senior = msg.senior
			icc_updateui()
			break
		end
	end
end

function SC_IccNote(msg)
	chat_addsystemalert("ICC_NOTE_SUCCESS")
	playerattr_icc.note = msg.note
	icc_updateui()
end

function SC_IccLog(msg)
	table.insert(playerattr_icc.log, 1, msg.log)
	icclog_updateui()
end

function SC_IccName(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.iccname = msg.name
		actor:updatenameuilayout()
	end
end

function SC_IccDisband(msg)
	chat_addsystemalert(c_textformat("ICC_DISBAND_WAIT", timerdesc_countdown(msg.time)))
	playerattr_icc.disband = msg.time
	icc_updateui()
end

function SC_IccDisbandCancel(msg)
	chat_addsystemalert("ICC_DISBAND_CANCELSUCCESS")
	playerattr_icc.disband = 0.0
	icc_updateui()
end

function SC_IccDisbandComplete(msg)
	chat_addsystemalert("ICC_NOTIFY_DISBAND")
	playerattr_icc = nil
	icc_updateui()
	if m_me ~= nil then
		m_me:setreloadasset(false)
	end
end

function SC_IccLevelUp(msg)
	chat_addsystemalert(textformat_args("STR_GUILD_CHANGE_LEVEL_DONE", msg.level))
end
