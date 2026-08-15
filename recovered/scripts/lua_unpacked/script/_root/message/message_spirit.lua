
function SC_SpiritSummon(msg)
	playerattr_info.spiritid = msg.actorid
	playerattr_info.spiritstate = msg.state
	playerattr_info.spiritconfigid = msg.configid
	sidebar_updateteam()
	playerinfo_updatespirit()
	tutorial_start(tutorialid.spirit)
end

function SC_SpiritAttack(msg)
	playerattr_info.spiritstate = spiritstate.attack
	sidebar_updateteam()
end

function SC_SpiritMove(msg)
	playerattr_info.spiritstate = spiritstate.move
	sidebar_updateteam()
end

function SC_SpiritIdle(msg)
	playerattr_info.spiritstate = spiritstate.idle
	sidebar_updateteam()
end

function SC_SpiritDismiss(msg)
	playerattr_info.spiritstate = spiritstate.dismiss
	sidebar_updateteam()
	playerinfo_updatespirit()
	if msg.errordismiss > 0 and playerattr_info.spiritconfigid ~= nil then
		local config_npc = csvnpc_getfromid(playerattr_info.spiritconfigid)
		if config_npc ~= nil then
			chat_addsystemalert(textformat_args("STR_SKILL_SUMMON_UNSUMMONED", config_npc.name))
		end
	end
	playerattr_info.spiritconfigid = nil
end
