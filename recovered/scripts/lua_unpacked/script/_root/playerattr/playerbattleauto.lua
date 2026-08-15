
local m_playerbattleauto_target = 0
local m_playerbattleauto_attacktime = 0
local m_playerbattleauto_pausetime = 0

function playerbattleauto_setattacktarget(actorid)
	m_playerbattleauto_target = actorid
end

function playerbattleauto_setattacktime(time)
	if time > 0 then
		m_playerbattleauto_attacktime = time
	else
		m_playerbattleauto_attacktime = 0
	end
	m_playerbattleauto_pausetime = 0
end

function playerbattleauto_pauseattack(time)
	m_playerbattleauto_pausetime = time_game + time
end

function playerbattleauto_stopattack()
	m_playerbattleauto_target = 0
	m_playerbattleauto_attacktime = 0
	m_playerbattleauto_pausetime = 0
	playerattr_skillpresetactive = nil
end

function playerbattleauto_startskillpreset(actorid)
	playerbattleauto_setattacktarget(actorid)
end

function playerbattleauto_startnormalattack(actorid)
	playerbattleauto_setattacktarget(actorid)
	playerbattleauto_update()
end

local function playerbattleauto_preset(actor)
	if playerattr_skillpresetactive == nil then
		return false
	end
	local preset = playerskillpreset_getpreset(playerattr_skillpresetactive)
	if preset == nil then
		return false
	end
	local skillindex, qtevfx = playerskillpreset_getactive(preset)
	if skillindex == 0 then
		return false
	end
	if preset.skillid[skillindex] == 0 then
		return false
	end
	local config_skill = csvskill_getfromid(preset.skillid[skillindex])
	if config_skill == nil then
		return false
	end
	local config_qte = playerskill_getqte(config_skill)
	if config_qte == nil then
		config_qte = playerskill_getcounterqte(config_skill)
	end
	if config_qte ~= nil then
		config_skill = config_qte
	end
	local config_toplevel = playerskill_gettoplevelavailable(config_skill)
	if config_toplevel ~= nil then
		config_skill = config_toplevel
	end
	if config_skill.select ~= nil then
		local sublambda = config_skill.select[1]
		if c_isaction(sublambda, "pickme") and actor:isme() then
			playerapproach_clear()
			playerbattle_spell(config_skill.id)
			return true
		end
		if c_isaction(sublambda, "pick") or c_isaction(sublambda, "pickme") then
			local lambdadist = playerbattle_pickdist(config_skill, sublambda.variable[1].flt, actor)
			local dist = vector3_distance(actor.transform.px,actor.transform.py,actor.transform.pz, m_me.transform.px,m_me.transform.py,m_me.transform.pz)
			if dist > lambdadist then
				if not playerapproach_ismovingtoactor(m_playerbattleauto_target) then
					playerapproach_normalattack(m_playerbattleauto_target, lambdadist)
				end
				return false
			end
		end
	end
	playerapproach_clear()
	playerbattle_spell(config_skill.id)
	return true
end

function playerbattleauto_attack(actor)
	if m_playerbattleauto_attacktime > time_game then
		return
	end
	local dist = vector3_distance(actor.transform.px,actor.transform.py,actor.transform.pz, m_me.transform.px,m_me.transform.py,m_me.transform.pz)
	local distmin = math.max(1, playerattr_info.attackrange)
	if actor ~= nil then
		distmin = actor:gettalkdist(distmin)
	end
	if dist > distmin then
		if gamesetting_getnumber("MANUALMOVEIN") == 0 then
			if not playerapproach_ismovingtoactor(m_playerbattleauto_target) then
				playerapproach_normalattack(m_playerbattleauto_target, distmin)
			end
		end
		return
	end
	playerapproach_clear()
	m_playerbattleauto_attacktime = time_game + math.min(playerbattle_getnormalattackdelay(), 0.5)
	local msg = {messageid="CS_NormalAttack"}
	msg.target = m_playerbattleauto_target
	c_send(msg)
end

function playerbattleauto_update()
	if m_playerbattleauto_target == 0 then
		return
	end
	if m_playerbattleauto_target ~= m_selectactorid then
		playerbattleauto_stopattack()
		return
	end
	local actor = actormanager_getfromactorid(m_playerbattleauto_target)
	if actor == nil or actor:isdead() then
		playerbattleauto_stopattack()
		return
	end
	if m_me == nil or m_me:isdead() or playerattr_isvehicle() then
		playerbattleauto_stopattack()
		return
	end
	if m_playerbattleauto_pausetime > time_game then
		return
	end
	if not playerbattleauto_preset(actor) then
		playerbattleauto_attack(actor)
	end
end
