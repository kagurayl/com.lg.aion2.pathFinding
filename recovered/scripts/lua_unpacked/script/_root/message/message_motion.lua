
function SC_ChairSitDown(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.actionmain.talknpctype = npcmotiontype.chairsitdown
		actor.actionmain.talknpc = msg.staticid
	end
end

function SC_ChairStandUp(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil and actor.actionmain.chairsitdown then
		actor.actionmain.talknpctype = npcmotiontype.chairstandup
	end
end

function SC_RestoreExp(msg)
	playerattr_info.exp = msg.exp
	playerattr_info.explost = 0
	playerattr_info.fatigue = 0
end

function SC_Faction(msg)
	if msg.factionid ~= 0 then
		local config_faction = csvnpcfaction_getfromid(msg.factionid)
		if config_faction ~= nil then
			chat_addsystemalert(c_textformat("NPC_ASK_FACTION_JOINSUCCESS", config_faction.name))
		end
	elseif playerattr_info.faction ~= 0 then
		local config_faction = csvnpcfaction_getfromid(playerattr_info.faction)
		if config_faction ~= nil then
			chat_addsystemalert(c_textformat("NPC_ASK_FACTION_LEAVESUCCESS", config_faction.name))
		end
	end
	playerattr_info.faction = msg.factionid
	if msg.factionid == 0 then
		playerattr_info.dailyquest = 0
	end
end

function SC_ActorLogo(msg)
	local prevactorid = playerattr_logo[msg.logo]
	if prevactorid ~= nil then
		playerattr_logo[msg.logo] = nil
		local prevactorlogo = actormanager_getfromactorid(prevactorid)
		if prevactorlogo ~= nil then
			prevactorlogo.actordata.logo = nil
			prevactorlogo:updatenameuilayout()
		end
	end
	if msg.actorid ~= 0 then
		playerattr_logo[msg.logo] = msg.actorid
		local actorlogo = actormanager_getfromactorid(msg.actorid)
		if actorlogo ~= nil then
			actorlogo.actordata.logo = msg.logo
			actorlogo:updatenameuilayout()
		end
	end
end

function SC_LogoClear(msg)
	playerattr_logo = {}
	local actorlist = actormanager_getactorlist()
	for key, actor in pairs(actorlist) do
		if actor.actordata.logo ~= nil then
			actor.actordata.logo = nil
			actor:updatenameuilayout()
		end
	end
end

function SC_SwitchRun(msg)
	playerattr_info.moverun = msg.run
end

function SC_SwitchBattery(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			actor.attr.battery = msg.boost
			if actor.attr.battery > 0 then
				actor:createvfx(EffectBatteryEnable, vfx_bind_weaponfront, true)
				messagealert_addalert("STR_WEAPON_BOOST_BOOST_MODE_STARTED")
			else
				audiomanager_playaudioui(AudioEquipBatteryOff)
				messagealert_addalert("STR_WEAPON_BOOST_BOOST_MODE_ENDED")
			end
			player_main_updateui()
		end
	end
end

function SC_SwitchBatteryEmpty(msg)
	audiomanager_playaudioui(AudioEquipBatteryEmpty)
	chat_addsystemalert("STR_WEAPON_BOOST_NO_BOOSTER_EQUIPED")
end

function SC_PlayerRename(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.name = msg.name
		actor:updatenameuilayout()
		if actor:isme() then
			chat_addsystemalert(c_textformat("PLAYER_TIPS_PLAYERRENAME", msg.name))
		end
	end
end

function SC_PlayerResetSkinFinish(msg)
	playerattr_info.sex = msg.sex
	playerattr_info.voice = msg.voice
	csvrender_skintoattr(playerattr_info, msg.skin)
	if m_me ~= nil then
		m_me:setreloadasset(false)
	end
end
