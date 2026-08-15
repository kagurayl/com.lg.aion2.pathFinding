
function SC_DungeonState(msg)
	playerattr_dungeon = {}
	for i=1,#msg.state do
		local state = msg.state[i]
		playerattr_dungeon[state.id] = time_game + state.cd
	end
	dungeonlist_updateui()
end

function dungeon_delegate_confirm(ok, data)
    if ok then
		local msg = {messageid="CS_DungeonEnter"}
		msg.id = data.id
		msg.type = data.type
		c_send(msg)
		npc_closedialog()
    end
end
function SC_DungeonConfirm(msg)
	local config_dungeon = csvmapdungeon_getfromid(msg.id)
	if config_dungeon ~= nil then
		local type = ""
		if msg.type == 1 then
			type = c_textformat("DUNGEON_ENTER_EASY")
		else
			type = c_textformat("DUNGEON_ENTER_HARD")
		end
		local text = c_textformat("DUNGEON_ENTER_TITLE", config_dungeon.name, type)
		local confirmdata = {id = msg.id, type = msg.type}
		messagebox_confirm(text, dungeon_delegate_confirm, confirmdata)	
	end
end

function SC_DungeonInCD(msg)
	local config_dungeon = csvmapdungeon_getfromid(msg.id)
	if config_dungeon ~= nil then
		local text = c_textformat("DUNGEON_ENTER_CD", config_dungeon.name, timerdesc_getafter(msg.second))
		chat_addsystemalert(text)
	end
end

function SC_DungeonOpen(msg)
	local config_dungeon = csvmapdungeon_getfromid(msg.dungeonid)
	if config_dungeon ~= nil then
		local text = nil
		if msg.difficulty > 0 then
			text = c_textformat("SERVER_TEAMDUNGEON_OPEN_" .. msg.difficulty, msg.playercount, config_dungeon.name)
		else
			text = c_textformat("SERVER_TEAMDUNGEON_OPEN", msg.playercount, config_dungeon.name)
		end
		chat_addsystemalert(text)
	end
end

function SC_DungeonMateState(msg)
	dungeonlist_setteaminfo(msg)
end

function SC_DredgionCountdown(msg)
	dungeon_score_settext(0, 0xffffffff, 0, 0xff0000ff)
	dungeon_score_settimer(msg.time, true)
	dungeon_score_settype(dungeonscoretype.dredgion)
end

function SC_DredgionStart(msg)
	dungeon_score_settext(0, 0xffffffff, 0, 0xff0000ff)
	dungeon_score_settimer(msg.time, true)
	dungeon_score_settype(dungeonscoretype.dredgion)
end

function SC_DredgionPlayerEnter(msg)
	dredgion_scorelist_addplayer(msg)
end

function SC_DredgionPlayerLeave(msg)
	dredgion_scorelist_removeplayer(msg.actorid)
end

function SC_DredgionPlayerScore(msg)
	local player = dredgion_scorelist_getplayer(msg.actorid)
	if player ~= nil then
		player.score = msg.score
		player.killplayer = msg.killplayer
		player.killnpc = msg.killnpc
		player.killbuilding = msg.killbuilding
	end
end

function SC_DredgionTotalScore(msg)
	dredgion_scorelist_setscore(msg.scorelight, msg.scoredark)
end

function SC_DredgionClear(msg)
	for i=1, #msg.info do
		local actor = dredgion_scorelist_getplayer(msg.info[i].actorid)
		if actor ~= nil then
			actor.obs = msg.info[i].obs
			actor.winobs = msg.info[i].winobs
		end
	end
	dredgion_scorelist_finish(msg.winciv, msg.scorelight, msg.scoredark)
end

function SC_ArenaPVERoundStart(msg)
	arenastage_create(msg.stage, msg.round)
end

function SC_ArenaPVPRoundWait(msg)
	dungeon_score_settext(c_textformat("DUNGEON_ARENA_ROUND", msg.round + 1), 0xffffffff, arena_scorelist_getscore(), 0xffffffff)
	dungeon_score_settimer(msg.time, true)
	dungeon_score_settype(dungeonscoretype.arenapvp)
end

function SC_ArenaPVPRoundStart(msg)
	arenastage_create(0, msg.round + 1)
	dungeon_score_settext(c_textformat("DUNGEON_ARENA_ROUND", msg.round + 1), 0xffffffff, arena_scorelist_getscore(), 0xffffffff)
	dungeon_score_settimer(msg.time, true)
	dungeon_score_settype(dungeonscoretype.arenapvp)
end

function SC_ArenaPlayerEnter(msg)
	arena_scorelist_addplayer(msg)
end

function SC_ArenaPlayerLeave(msg)
	arena_scorelist_removeplayer(msg.actorid)
end

function SC_ArenaPlayerScore(msg)
	local player = arena_scorelist_getplayer(msg.actorid)
	if player ~= nil then
		player.score = msg.score
		player.killplayer = msg.killplayer
		player.pvpscore = msg.score
		arena_scorelist_checkrank()
		dungeon_score_settext(nil, 0xffffffff, arena_scorelist_getscore(), 0xffffffff)
	end
end

function SC_ArenaClear(msg)
	for i=1, #msg.info do
		local actor = arena_scorelist_getplayer(msg.info[i].actorid)
		if actor ~= nil then
			local info = msg.info[i]
			actor.rank = i
			actor.itemid1 = info.itemid1
			actor.itemid2 = info.itemid2
			actor.itemcount1 = info.itemcount1
			actor.itemcount2 = info.itemcount2
			actor.rankscore = info.rankscore
			actor.timescore = info.timescore
			actor.obs = info.obs
		end
	end
	arena_scorelist_finish()
end

function SC_DarkPoeta(msg)
	dungeon_darkpoeta_settext(msg.state, msg.score, msg.time)
end
