
local m_current_playerid = 0

function SC_PlayerCore(msg)
	timer_setservertime(msg.servertime)
	serverattr_set(msg)
	playerattr_set(msg)
	richtext_updatereplace()
	playeritem_set(msg)
	playerskill_set(msg)
	playerfogmask_setmask(msg.fogmask)
	playerskill_updaterankskill()
	playerquest_updatenpcicon()
	equip_updatescript()
	actormanager_updatehead()
	actormanager_updateharvesticon()
	c_system_setcrashreport("playername", msg.name)
	for i=1,#msg.cd do
		local cd = msg.cd[i]
		timer_setcd(cd.id, cd.length, cd.remain)
	end

	if m_current_playerid == nil or m_current_playerid ~= msg.playerid then
		m_current_playerid = msg.playerid
		chat_reset()
	end
	matching_set(0)

	if playerattr_info.hp > 0 then
		c_camera_setposteffect(nil)
	end

	m_me = actormanager_createactor(RenderLayerMe, playerattr_info.actorid)
	m_me.actortype = actorgametype.player
	m_me.attr = playerattr_info
	m_me:initpet()
	m_me:initattr(msg.buff)
end

function SC_CD(msg)
    timer_setcd(msg.id, msg.cd, msg.cd)
end

function SC_RankPlayer(msg)
	rank_setplayerdata(msg)
end

function SC_RankICC(msg)
	rank_seticcdata(msg)
end

function SC_RankFinish(msg)
	rank_main_updateui()
end

function SC_BindResurrect(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:createvfx(EffectNPCBindPoint, nil, true)
		if actor:isme() then
			playerattr_info.resurrectid = msg.npcid
		end
	end
end

function SC_BindQsk(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:createvfx(EffectNPCBindPoint, nil, true)
		if actor:isme() then
			playerattr_info.qskactorid = msg.qskid
			playerattr_info.qskmember = msg.qskmember
			playerattr_info.qskremain = msg.qskremain
			playerattr_info.qsktime = time_game + msg.qsktime
		end
	end
end

function SC_QskSummon(msg)
	dialog_scriptoption_qsk(msg.actorid)
end

function SC_QskUpdate(msg)
	if msg.qskremain <= 0 then
		chat_addsystemalert("NPC_QSK_QSKDESTROY")
		playerattr_info.qskactorid = 0
		playerattr_info.qskmember = 0
		playerattr_info.qskremain = 0
		playerattr_info.qsktime = 0.0
	else
		if msg.qskremain < 5 then
			local text = textformat_args("STR_BINDSTONE_CAPACITY_LIMITTED_ALARM", msg.qskremain)
			chat_addsystemalert(text)
		end
		playerattr_info.qskmember = msg.qskmember
		playerattr_info.qskremain = msg.qskremain
	end
end

function SC_QskDestroy(msg)
	chat_addsystemalert("STR_BINDSTONE_DESTROYED")
	playerattr_info.qskactorid = 0
	playerattr_info.qskmember = 0
	playerattr_info.qskremain = 0
	playerattr_info.qsktime = 0.0
end

function SC_QskMemberAOI(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.qskmember = msg.qskmember
	end
end

function SC_QskRemainAOI(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.qskremain = msg.qskremain
	end
end

function SC_StateDeadAOI(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if scene_isloading() then
			actor.attr.deadtime = time_game - 5.0
		else
			actor.attr.deadtime = time_game
		end
		actor:updatenameuilayout()
		battletext_dead(actor, msg.killer)
	end
end

function SC_StateDead(msg)
	dead_reset(msg)
	if scene_isloading() then
		playerattr_info.deadtime = time_game - 5.0
	else
		playerattr_info.deadtime = time_game
	end
end

function SC_StateAlive(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			playerattr_info.fatigue = msg.fatigue
	        playerattr_info.explost = msg.explost
			c_camera_setposteffect(nil)
		end
		actor.attr.deadtime = nil
		if msg.anim > 0 then
			actor.attr.alivetime = time_game
		else
			actor.attr.alivetime = nil
		end
		actor.attr.hp = msg.hp
		actor.attr.mp = msg.mp
		actor.attr.dp = msg.dp
		actor:setactorposition(msg.posx, msg.posy, msg.posz, actor.attr.rot)
		if msg.skillid ~= 0 then
			battletext_resurrect(actor, msg.attacker, msg.skillid, msg.anim == 0)
		end
		if actor:isme() then
			event_active(eventtype.playerinfo)
			audiomanager_playaudioui(AudioResurrection)
		end
		actor:updatenameuilayout()
	end
end

function SC_StateBattle(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:setbattle(msg.battle, true)
	end
end

function SC_StateAreaFly(msg)
	if playerattr_info.areafly ~= msg.fly then
		playerattr_info.areafly = msg.fly
		if msg.fly > 0 then
			audiomanager_playaudioui(AudioFlyZoneIn)
		else
			audiomanager_playaudioui(AudioFlyZoneOut)
		end
		actionbar_setflyvfx(msg.fly > 0)
	end
end

function SC_StateAreaPVP(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.areapvp = msg.pvp
		if actor:isme() then
			actormanager_updatenameplate()
		else
			actor:updatenameuilayout()
		end
	end
end

function SC_EliteSkill(msg)
	local zonename = csvmap_getzonename(msg.mapid, msg.posx, msg.posy, msg.posz)
    if zonename == nil then
        return
    end
    local config_skill = csvskill_getfromid(msg.skillid)
    if config_skill == nil then
        return
    end
    local civ = math.ternary(msg.civ == playerciv.light, "UI_CIVNAME_ELF", "UI_CIVNAME_DARK")
    local str = textformat_args("STR_SKILL_ABYSS_SKILL_IS_FIRED", c_textformat(civ), msg.name, zonename, config_skill.name)
    chat_addsystemalert(str)
end

function SC_EliteDead(msg)
	local zonename = csvmap_getzonename(msg.mapid, msg.posx, msg.posy, msg.posz)
	if zonename == nil then
        return
    end
	local titlename = playerattr_getpvptitlename(msg.civ, msg.title)
	chat_addsystemalert(c_textformat("PLAYER_TIPS_PLAYERPVPDEAD", titlename, msg.name, zonename))
end

function SC_EliteEnterMap(msg)
	local zonename = csvmap_getzonename(msg.mapid, msg.posx, msg.posy, msg.posz)
	local titlename = playerattr_getpvptitlename(msg.civ, msg.title)
	local config_map = csvmap_getfromid(msg.mapid)
	if config_map ~= nil then
		local mapname = "STR_ZONE_NAME_" .. string.upper(config_map.scene)
		chat_addsystemalert(c_textformat("PLAYER_TIPS_PLAYERPVPMAP", titlename, msg.name, zonename, mapname))
	end
end

function SC_QueryPlayer(msg)
	playerquery_setplayer(msg)
end

function SC_FogMask(msg)
	playerfogmask_openmask(msg.id)
end
