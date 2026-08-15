
local m_playerapproach_followactor = nil
local m_playerapproach_followstoptime = 0
local m_playerapproach_actor = nil
local m_playerapproach_position = nil
local m_playerapproach_dist = nil
local m_playerapproach_delegate = nil
local m_playerapproach_data = nil

function playerapproach_clear()
	m_playerapproach_followactor = nil
	m_playerapproach_actor = nil
	m_playerapproach_position = nil
end

function playerapproach_moving()
	if m_playerapproach_actor ~= nil or m_playerapproach_position ~= nil then
		return true
	end
	if m_playerapproach_followactor ~= nil then
		local actor = actormanager_getfromactorid(m_playerapproach_followactor)
		if actor ~= nil then
			local dist = vector3_distance(actor.transform.px, actor.transform.py, actor.transform.pz, m_me.transform.px, m_me.transform.py, m_me.transform.pz)
			if dist > m_playerapproach_dist then
				m_playerapproach_followstoptime = time_game + 0.05
			end
			return m_playerapproach_followstoptime > time_game
		else
			m_playerapproach_followactor = nil
		end
	end
	return false
end

function playerapproach_ismovingtoactor(actorid)
	return m_playerapproach_actor == actorid
end

function playerapproach_normalattack(actorid, distmin)
	m_me.move.inputdirection = movedirection.forward
	m_playerapproach_actor = actorid
	m_playerapproach_position = nil
	m_playerapproach_dist = distmin
	m_playerapproach_data = nil
	m_playerapproach_delegate = nil
end

function playerapproach_skill(actorid, distmin, skillid)
	m_me.move.inputdirection = movedirection.forward
	m_playerapproach_actor = actorid
	m_playerapproach_position = nil
	m_playerapproach_dist = distmin
	m_playerapproach_data = skillid
	m_playerapproach_delegate = playerapproach_skill_delegate
end

function playerapproach_talk(actorid, distmin)
	m_me.move.inputdirection = movedirection.forward
	m_playerapproach_actor = actorid
	m_playerapproach_position = nil
	m_playerapproach_dist = distmin
	m_playerapproach_data = nil
	m_playerapproach_delegate = playerapproach_talk_delegate
end

function playerapproach_entity(config_npcstatic, pos, distmin)
	m_me.move.inputdirection = movedirection.forward
	m_playerapproach_actor = nil
	m_playerapproach_position = pos
	m_playerapproach_dist = distmin
	m_playerapproach_data = config_npcstatic
	m_playerapproach_delegate = playerapproach_entity_delegate
end

function playerapproach_follow(actorid, distmin)
	local actor = actormanager_getfromactorid(actorid)
	if actor == nil then
		return
	end
	m_me.move.inputdirection = movedirection.forward
	m_playerapproach_followactor = actorid
	m_playerapproach_position = nil
	m_playerapproach_dist = distmin
	m_playerapproach_data = nil
	m_playerapproach_delegate = nil
	messagealert_showfollow(actor.attr.name)
end

function playerapproach_isfollow()
	return m_playerapproach_followactor ~= nil
end

function playerapproach_update()
	if m_playerapproach_followactor ~= nil then
		local actor = actormanager_getfromactorid(m_playerapproach_followactor)
		if actor == nil then
			m_playerapproach_followactor = nil
		end
	end
	if m_playerapproach_actor ~= nil and m_playerapproach_actor ~= m_selectactorid then
		m_playerapproach_actor = nil
	end
end

local function playerapproach_movefollow()
	local actor = actormanager_getfromactorid(m_playerapproach_followactor)
	if actor == nil then
		m_playerapproach_followactor = nil
		return
	end
	if m_me.attr.movetype == playermovestate.glide or m_me.attr.movetype == playermovestate.rest then
		m_playerapproach_followactor = nil
		return
	end
	m_me:movemeauto(actor.transform.px, actor.transform.py, actor.transform.pz, m_playerapproach_dist * 0.9)
	m_me:movesendsync(true)
end

local function playerapproach_movetoactor()
	if m_selectactor == nil or m_playerapproach_actor == nil or m_selectactorid ~= m_playerapproach_actor then
		m_playerapproach_actor = nil
		return
	end
	if m_me.attr.movetype == playermovestate.glide or m_me.attr.movetype == playermovestate.rest then
		m_playerapproach_actor = nil
		return
	end
	if not m_me:movemeauto(m_selectactor.transform.px, m_selectactor.transform.py, m_selectactor.transform.pz, m_playerapproach_dist * 0.9) then
		return
	end
	m_me:movesendsync(true)
	local actorid = m_playerapproach_actor
	local data = m_playerapproach_data
	m_playerapproach_actor = nil
	m_playerapproach_data = nil
	if m_playerapproach_delegate ~= nil then
		m_playerapproach_delegate(actorid, data)
	end
end

local function playerapproach_movetoposition()
	if m_me.attr.movetype == playermovestate.glide or m_me.attr.movetype == playermovestate.rest then
		m_playerapproach_position = nil
		return
	end
	if not m_me:movemeauto(m_playerapproach_position[1], m_playerapproach_position[2], m_playerapproach_position[3], m_playerapproach_dist * 0.9) then
		return
	end
	m_me:movesendsync(true)
	local data = m_playerapproach_data
	m_playerapproach_position = nil
	m_playerapproach_data = nil
	if m_playerapproach_delegate ~= nil then
		m_playerapproach_delegate(0, data)
	end
end

function playerapproach_move()
	if m_playerapproach_followactor ~= nil then
		playerapproach_movefollow()
	elseif m_playerapproach_actor ~= nil then
		playerapproach_movetoactor()
	elseif m_playerapproach_position ~= nil then
		playerapproach_movetoposition()
	end
end

function playerapproach_skill_delegate(actorid, data)
	playerbattle_spell(data)
end

function playerapproach_talk_delegate(actorid, data)
	npc_startscript(actorid)
end

function playerapproach_entity_delegate(actorid, data)
	npc_staticscript_movecomplete(data)
end
