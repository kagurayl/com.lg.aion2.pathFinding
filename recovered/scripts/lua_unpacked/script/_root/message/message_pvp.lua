
function SC_PVPForceEnemy(msg)
	if msg.actorid ~= 0 then
		playerattr_info.forceenemy = msg.actorid
	else
		playerattr_info.forceenemy = nil
	end
	actormanager_updatenameplate()
	selection_updateui()
end

function SC_DuelInviteSend(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		chat_addsystemalert(c_textformat("PLAYER_DUEL_INVITESEND", actor.attr.name))
	end
end

function message_pvp_confirm(ok, data)
	local msg = {messageid="CS_DuelResponse"}
	msg.actorid = data
	if ok then
		msg.accept = 1
	else
		msg.accept = 0
	end
	c_send(msg)
end
function SC_DuelInviteRecv(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		messagebox_confirm(c_textformat("PLAYER_DUEL_INVITERECV", actor.attr.name), message_pvp_confirm, msg.actorid)
	end
end

function SC_DuelResponse(msg)
	if msg.accept == 0 then
		chat_addsystemalert(c_textformat("PLAYER_DUEL_INVITEREFUSE", msg.name))
	elseif msg.accept == 1 then
		chat_addsystemalert(c_textformat("PLAYER_DUEL_INVITEACCEPT", msg.name))
	else
		chat_addsystemalert(c_textformat("PLAYER_DUEL_INVITETIMEOUT", msg.name))
	end
end

function SC_DuelCountDown(msg)
	duelcountdown_settime(msg.countdown)
end

function SC_DuelStart(msg)
	duelcountdown_settext("PLAYER_DUEL_START", 3.0)
end

function SC_DuelAbort(msg)
	if msg.error == 0 then
		chat_addsystemalert("PLAYER_DUEL_ABORT_RANGE")
	elseif msg.error == 1 then
		chat_addsystemalert("PLAYER_DUEL_ABORT_PVP")
	end
end

function SC_DuelResult(msg)
	if msg.winner ~= 0 then
		local actor = actormanager_getfromactorid(msg.winner)
		if actor ~= nil then
			chat_addsystemalert(c_textformat("PLAYER_DUEL_WIN", actor.attr.name))
			actor:clearspell()
			local config_social = csvskillsocial_getfromid(8)
			if config_social ~= nil then
				actor.actionmain.spelltype = playerspellstate.spellsocial
				actor.actionmain.config_skill = config_social
			end
		end
	else
		chat_addsystemalert("PLAYER_DUEL_DRAW")
	end
	if msg.loser ~= 0 then
		local actor = actormanager_getfromactorid(msg.loser)
		if actor ~= nil then
			actor:clearspell()
		end
	end
end
