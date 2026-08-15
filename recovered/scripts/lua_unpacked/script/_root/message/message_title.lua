

local function updatetitleui()
	event_active(eventtype.playerinfo)
end

function SC_TitleList(msg)
	playerattr_titlelist = msg.title
	playerattr_info.title = msg.activeid
	updatetitleui()
end

function SC_TitleActive(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.title = msg.titleid
		actor:updatenameuilayout()
		if actor:isme() then
			updatetitleui()
		end
	end
end

function SC_TitleAdd(msg)
	local title = nil
	for i=1,#playerattr_titlelist do
		if playerattr_titlelist[i].titleid == msg.titleid then
			title = playerattr_titlelist[i]
			break
		end
	end
	if title == nil then
		title = {}
		title.titleid = msg.titleid
		playerattr_titlelist[#playerattr_titlelist + 1] = title
	end
	title.entitledate = msg.entitledate
	title.expiredate = msg.expiredate
	local config_title = csvplayertitle_getfromid(msg.titleid)
	if config_title ~= nil then
		chat_addsystemalert(textformat_args("STR_MSG_GET_CASH_TITLE", config_title.name))
	end
	updatetitleui()
end

function SC_TitleExpire(msg)
	local config_title = csvplayertitle_getfromid(msg.titleid)
	if config_title ~= nil then
		local text = textformat_args("STR_MSG_DELETE_CASH_TITLE_BY_TIMEOUT", config_title.name)
		chat_addsystemalert(text)
	end
	updatetitleui()
end

function SC_PVPScore(msg)
	if playerattr_pvp.score ~= nil and msg.score > playerattr_pvp.score then
		chat_addsimple(chatchanneltype.systemabyss, textformat_args("STR_MSG_COMBAT_MY_ABYSS_POINT_GAIN", msg.score - playerattr_pvp.score))
	end
	if playerattr_pvp.title ~= nil and playerattr_pvp.title ~= msg.title then
		local title = nil
		if playerattr_info.civ == playerciv.light then
			title = c_textformat("PLAYER_PVPLEVEL_LIGHT" .. msg.title)
		else
			title = c_textformat("PLAYER_PVPLEVEL_DARK" .. msg.title)
		end
		local text = textformat_args("STR_ABYSS_CHANGE_RANK", title)
		chat_addsystemalert(text)
	end
	playerattr_pvp.title = msg.title
	playerattr_pvp.score = msg.score
	playerattr_pvp.rank = msg.rank
	playerattr_pvp.kill_today = msg.kill_today
	playerattr_pvp.kill_week = msg.kill_week
	playerattr_pvp.kill_lastweek = msg.kill_lastweek
	playerattr_pvp.kill_total = msg.kill_total
	playerattr_pvp.score_today = msg.score_today
	playerattr_pvp.score_week = msg.score_week
	playerattr_pvp.score_lastweek = msg.score_lastweek
	playerattr_pvp.titletop = msg.titletop
	updatetitleui()
	if m_me ~= nil then
		playerskill_updaterankskill()
		m_me:updatenameuilayout()
	end
end

function SC_PVPTitle(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.pvptitle = msg.titleid
		actor:updatenameuilayout()
	end
end
