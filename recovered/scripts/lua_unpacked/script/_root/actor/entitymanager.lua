
local entity_flag_disableportal = 0x1
local entity_flag_hidden = 0x2

local m_entityobject = {}
local m_entityvisible = {}

function entitymanager_create(entityid, flag, meshfile, px, py, pz, rx, ry, rz, sx, sy, sz)
	local entity = {}
	entity.entityid = entityid
	entity.px = px
	entity.py = py
	entity.pz = pz
	entity.rx = rx
	entity.ry = ry
	entity.rz = rz
	entity.sx = sx
	entity.sy = sy
	entity.sz = sz
	entity.anim = "nidle_001"
    entity.visible = 1
	if bit.band(flag, entity_flag_hidden) ~= 0 then
		entity.visible = 0
	end
	if meshfile ~= nil then
		meshfile = string.sub(meshfile, 1, #meshfile - 7)
		local index = string.reversefind(meshfile, ".")
		if index ~= nil then
			meshfile = string.sub(meshfile, 1, index - 1)
		end
		local meshtitle = meshfile
		index = string.reversefind(meshtitle, "/")
		if index ~= nil then
			meshtitle = string.sub(meshtitle, index + 1)
		end
		entity.animalias = csvanimalias_load(meshfile, meshtitle)
	end
	m_entityobject[entityid] = entity
	sceneentity_initentity(entityid)
	entitymanager_updatevisible(entity)
end

function entitymanager_updatevisible(entity)
	local entityvisible = m_entityvisible[entity.entityid]
	local visible = entity.visible
	if entityvisible ~= nil then
		if entityvisible.actorvisible ~= nil then
			visible = entityvisible.actorvisible
			local actorid = actormanager_getentityactorid(entity.entityid)
			if actorid ~= nil then
				local actor = actormanager_getfromactorid(actorid)
				if actor ~= nil then
					if visible > 0 then
						actor:createnameplate()
					else
						actor:destroynameplate()
					end
				end
			end
		elseif entityvisible.configvisible ~= nil then
			visible = entityvisible.configvisible
		end
	end
	if visible > 0 then
		entitymanager_playanim(entity, entity.anim, actorrenderflag.loopanim)
	else
		if entity.aliasplayer ~= nil then
			aliasmanager_destory(entity.aliasplayer)
			entity.aliasplayer = nil
		end
	end
	c_entity_setvisible(entity.entityid, visible)
end

function entitymanager_setconfigvisible(entityid, visible)
	local entityvisible = m_entityvisible[entityid]
	if entityvisible == nil then
		entityvisible = {}
		m_entityvisible[entityid] = entityvisible
	end
	entityvisible.configvisible = visible
	local entity = m_entityobject[entityid]
	if entity ~= nil then
		entitymanager_updatevisible(entity)
	end
end

function entitymanager_setactorvisible(entityid, visible)
	local entityvisible = m_entityvisible[entityid]
	if entityvisible == nil then
		entityvisible = {}
		m_entityvisible[entityid] = entityvisible
	end
	entityvisible.actorvisible = visible
	local entity = m_entityobject[entityid]
	if entity ~= nil then
		entitymanager_updatevisible(entity)
	end
end

function entitymanager_getactorvisible(entityid)
	local entityvisible = m_entityvisible[entityid]
	if entityvisible ~= nil and entityvisible.actorvisible ~= nil then
		return entityvisible.actorvisible > 0
	end
	return false
end

function entitymanager_destroy(entityid)
	local entity = m_entityobject[entityid]
	if entity ~= nil then
		m_entityobject[entityid] = nil
		if entity.aliasplayer ~= nil then
			aliasmanager_destory(entity.aliasplayer)
			entity.aliasplayer = nil
		end
		if entitymanager_getactorvisible(entityid) then
			local actorid = actormanager_getentityactorid(entityid)
			if actorid ~= nil then
				local actor = actormanager_getfromactorid(actorid)
				if actor ~= nil then
					actor:destroynameplate()
				end
			end
		end
	end
end

function entitymanager_clear()
	for key, val in pairs(m_entityobject) do
		if val.aliasplayer ~= nil then
			aliasmanager_destory(val.aliasplayer)
			val.aliasplayer = nil
		end
	end
	m_entityobject = {}
	m_entityvisible = {}
end

function entitymanager_playanim(entity, animname, flag)
	if entity.aliasplayer ~= nil then
		aliasmanager_destory(entity.aliasplayer)
		entity.aliasplayer = nil
	end
	entity.anim = animname
	local animspeed = 1.0
	c_entity_playanim(entity.entityid, animname, 0.0, animspeed)
	if entity.animalias ~= nil then
		local alias = entity.animalias.anim[animname]
		if alias ~= nil then
			if alias.marker ~= nil then
				entity.aliasplayer = aliasmanager_create(alias.marker, flag, nil, animspeed, 0.0)
			end
			return alias
		elseif entity.animalias.markerarray ~= nil then
			local marker = entity.animalias.markerarray[animname]
			if marker ~= nil then
				entity.aliasplayer = aliasmanager_create(marker, flag, nil, animspeed, 0.0)
			elseif table.valcount(entity.animalias.anim) == 0 and table.valcount(entity.animalias.markerarray) == 1 then
				for key, val in pairs(entity.animalias.markerarray) do
					marker = val
				end
				entity.aliasplayer = aliasmanager_create(marker, flag, nil, animspeed, 0.0)
			end
		end
	end
end

function entitymanager_playentityanim(entityid, animname, flag)
	local entity = m_entityobject[entityid]
	if entity ~= nil then
		return entitymanager_playanim(entity, animname, flag)
	end
end

function entitymanager_update()
	for key, val in pairs(m_entityobject) do
		if val.aliasplayer ~= nil then
			aliasmanager_update(val.aliasplayer, nil, val)
		end
	end
end
