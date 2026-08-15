
sceneentitytype =
{
	npc = 1,
	door = 2,
 	windbox = 3,
    logo = 4,
	shield = 5,
}

local scenedoorstate =
{
	close = 0,
 	open = 1,
    openwithcollider = 2,
}

local m_scene_windpath = nil
local m_scene_entityconfig = nil

function sceneentity_load(mapid)
	m_scene_entityconfig = {}
	local config_spawnstatic = csvnpcstatic_getfrommapid(mapid)
	if config_spawnstatic ~= nil then
		for i=1,#config_spawnstatic do
			local config_staticnpc = config_spawnstatic[i]
			if config_staticnpc.npcid ~= 0 then
				m_scene_entityconfig[config_staticnpc.staticid] = {type = sceneentitytype.npc, actorid = 0, npcid = m_scene_entityconfig.npcid}
				if config_staticnpc.npcid ~= 0 then
					entitymanager_setconfigvisible(config_staticnpc.staticid, 0)
				end
			end
		end
	end
	local config_doorarray = c_config_getmetaarray(configid.map_door, "id", mapid)
	if config_doorarray ~= nil and #config_doorarray > 0 then
		for i=1,#config_doorarray do
			m_scene_entityconfig[config_doorarray[i].entityid] = {type = sceneentitytype.door, state = 0, config_door = config_doorarray[i]}
		end
	end
	local config_windboxarray = c_config_getmetaarray(configid.map_windbox, "id", mapid)
	if config_windboxarray ~= nil and #config_windboxarray > 0 then
		for i=1,#config_windboxarray do
			m_scene_entityconfig[config_windboxarray[i].entityid] = {type = sceneentitytype.windbox, config_windbox = config_windboxarray[i]}
			entitymanager_setconfigvisible(config_windboxarray[i].entityid, config_windboxarray[i].enable)
		end
	end
	local castlearray = c_config_getmetaarray(configid.abyss_castle, "mapid", mapid)
	if castlearray ~= nil then
		for castleindex=1,#castlearray do
			local config_castle = castlearray[castleindex]
			if config_castle.mapid == mapid then
				local sublogo = string.split(config_castle.logo, ";")
				for i=1,#sublogo do
					local entityid = string.tointeger(sublogo[i])
					m_scene_entityconfig[entityid] = {type = sceneentitytype.logo, abyssid = config_castle.id}
				end

				local subshield = string.split(config_castle.shield, ";")
				for i=1,#subshield do
					local entityid = string.tointeger(subshield[i])
					m_scene_entityconfig[entityid] = {type = sceneentitytype.shield, abyssid = config_castle.id}
				end
			end
		end
	end
	local artifactarray = c_config_getmetaarray(configid.abyss_artifact, "mapid", mapid)
	if artifactarray ~= nil then
		for artifactindex=1,#artifactarray do
			local config_artifact = artifactarray[artifactindex]
			if config_artifact.mapid == mapid then
				if config_artifact.logo ~= 0 then
					m_scene_entityconfig[config_artifact.logo] = {type = sceneentitytype.logo, abyssid = config_artifact.id}
				end
			end
		end
	end
end

function sceneentity_clear()
	m_scene_windpath = nil
	m_scene_entityconfig = nil
end

function sceneentity_reset()
	if m_scene_windpath ~= nil then
		for key, val in pairs(m_scene_windpath) do
			c_scene_setobjectvisible(val.mesh, true)
		end
		m_scene_windpath = nil
	end
	if m_scene_entityconfig ~= nil then
		for entityid, entity in pairs(m_scene_entityconfig) do
			if entity.type == sceneentitytype.door then
				if entity.state > 0 then
					entity.state = 0
					c_entity_playanim(entityid, nil, 0.0, -1.0)
				end
			end
		end
	end
end

function sceneentity_initentity(entityid)
	if m_scene_entityconfig == nil then
		return
	end
	local entity = m_scene_entityconfig[entityid]
	if entity == nil then
		return
	end
	if entity.type == sceneentitytype.door then
		if entity.state > 0 then
			c_entity_playanim(entityid, nil, 1.0, 1.0)
		else
			c_entity_playanim(entityid, nil, 0.0, -1.0)
		end
	elseif entity.type == sceneentitytype.logo then
		local castle = serverattr_abysscastle[entity.abyssid]
		if castle ~= nil then
			sceneentity_setcastlelogo(entityid, castle.civ)
		else
			local artifact = serverattr_abyssartifact[entity.abyssid]
			if artifact ~= nil then
				sceneentity_setcastlelogo(entityid, artifact.civ)
			end
		end
	end
end

function sceneentity_setstate(entityid, state, anim)
	local entity = m_scene_entityconfig[entityid]
	if entity == nil then
		return
	end
	entity.state = state
	if entity.type == sceneentitytype.door then
		if anim then
			if entity.state > 0 then
				local length = c_entity_playanim(entityid, nil, 0.0, 1.0)
				if entity.config_door.audioopen ~= "0" then
					audiomanager_playaudio2d(entity.config_door.audioopen, audiochanneltype.envsfx, audiopriority.normal)
				end
			else
				local length = c_entity_playanim(entityid, nil, 1.0, -1.0)
				if entity.config_door.audioclose ~= "0" then
					audiomanager_playaudio2d(entity.config_door.audioclose, audiochanneltype.envsfx, audiopriority.normal)
				end
			end
		else
			if entity.state > 0 then
				c_entity_playanim(entityid, nil, 1.0, 1.0)
			else
				c_entity_playanim(entityid, nil, 0.0, -1.0)
			end
		end
	end
end

function sceneentity_setcastlelogo(entityid, civ)
	if civ == playerciv.light then
		c_entity_settexture(entityid, "textures/icclogo/default_l.png")
	elseif civ == playerciv.dark then
		c_entity_settexture(entityid, "textures/icclogo/default_d.png")
	else
		c_entity_settexture(entityid, "textures/icclogo/default_r.png")
	end
end

function sceneentity_updatecastlelogo(abssid, civ)
	for entityid, entity in pairs(m_scene_entityconfig) do
		if entity.type == sceneentitytype.logo and entity.abyssid == abssid then
			sceneentity_setcastlelogo(entityid, civ)
		end
	end
end

function sceneentity_updatecastleshield(castle)
	for entityid, entity in pairs(m_scene_entityconfig) do
		if entity.type == sceneentitytype.shield and entity.abyssid == castle.id then
			entitymanager_setactorvisible(entityid, math.ternary(castle.mist > 0 and castle.shield > 0, 1, 0))
		end
	end
end

function sceneentity_getconfig(entityid)
	return m_scene_entityconfig[entityid]
end

function sceneentity_updatewindpath(id, mesh, visible)
	if m_scene_windpath ~= nil then
		for key, val in pairs(m_scene_windpath) do
			c_scene_setobjectvisible(val.mesh, val.visible > 0)
		end
	end
end

function sceneentity_setwindpath(id, mesh, visible)
	if m_scene_windpath == nil then
		m_scene_windpath = {}
	end
	local windpath = m_scene_windpath[id]
	if windpath == nil then
		windpath = {}
		windpath.mesh = mesh
		m_scene_windpath[id] = windpath
	end
	windpath.visible = visible
	sceneentity_updatewindpath()
end

function sceneentity_getwindpath(id)
	if m_scene_windpath == nil then
		return true
	end
	local windpath = m_scene_windpath[id]
	if windpath == nil then
		return true
	end
	return windpath.visible > 0
end
