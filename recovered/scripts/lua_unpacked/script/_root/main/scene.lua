
local m_scene_mapconfig = nil
local m_scene_rendersetting = nil
local m_scene_renderhour = nil
local m_scene_updatezonetime = 0
local m_scene_zonetext = {}
local m_scene_loading = nil
local m_scene_bgmbattle = false
local m_scene_bgmevent = 0
local m_scene_bgmname = nil
local m_scene_bgmonce = false
local m_scene_elevatorzone = nil
local m_scene_shapemusicid = 0
local m_scene_shapefogid = 0
local m_scene_shapefog = nil
local m_scene_scenefog = nil

function scene_setmap(mapid)
	if m_scene_mapconfig ~= nil and m_scene_mapconfig.id == mapid then
		debuglog("scene_setmap raw:" .. mapid)
		if not loading_getassetloading() then
			scene_worldchanged()
		end
		return
	end
	local config_map = csvmap_getfromid(mapid)
	if config_map == nil then
		return
	end
	debuglog("scene_setmap:" .. mapid)
	scene_clear()
	actormanager_clearentity()
	vfxmanager_clear()
	m_scene_mapconfig = config_map
	sceneentity_load(mapid)
	loading_loadlevel(m_scene_mapconfig.id, m_scene_mapconfig.scene, m_scene_mapconfig.loading, true, scene_worldchanged)
end

function scene_clear()
	audiomanager_stopmusic()
	audiomanager_clearseek()
	dungeon_score_close()
	dungeon_darkpoeta_close()
	sceneentity_clear()
	entitymanager_clear()
	m_scene_bgmonce = false
	m_scene_elevatorzone = nil
	m_scene_shapemusicid = 0
	m_scene_shapefogid = 0
	m_scene_shapefog = nil
	m_scene_mapconfig = nil
	m_scene_rendersetting = nil
	m_scene_updatezonetime = 0
end

function scene_getmapconfig()
	return m_scene_mapconfig
end

function scene_getmapid()
	if m_scene_mapconfig ~= nil then
		return m_scene_mapconfig.id
	else
		return 0
	end
end

function scene_getelevatorzone()
	if m_scene_elevatorzone ~= nil then
		return m_scene_elevatorzone.id
	end
	return 0
end

function scene_setloading()
	m_scene_loading = {}
end

function scene_isloading()
	return m_scene_loading ~= nil
end

function scene_updatezone()
	m_scene_updatezonetime = 0
end

function scene_getloadingattr()
	return m_scene_loading
end

function scene_getfloorheight(x, y, z, getmaterial)
	if not scene_isloading() then
		local px, py, pz, physicmaterial = c_scene_pickscene(maskcollider, x, y + 2, z, 0, -1, 0, 100, getmaterial)
		if px ~= nil then
			return py, physicmaterial
		end
	end
	return y
end

function scene_getfloorheightlengthlimit(x, y, z, length, getmaterial)
	if not scene_isloading() then
		local px, py, pz, physicmaterial = c_scene_pickscene(maskcollider, x, y + 2, z, 0, -1, 0, length, getmaterial)
		if px ~= nil then
			return py, physicmaterial
		end
	end
	return y
end

function scene_setshape(zone_shape)
	local musicarray = nil
	local musicdataid = 0
	local fogparam = nil
	local fogdataid = 0
	if zone_shape ~= nil then
		local dayhour, dayminute = csvmaptimeenv_getgametime()
		local timedesc = "night"
		if dayhour >= 9 and dayhour <= 6 then
			timedesc = "day"
		end
		local musicshapepriority = 0
		local fogshapepriority = 0
		for shapeindex=1,#zone_shape do
			local shape = zone_shape[shapeindex]
			local data = shape.data
			local datacount = csvconfig_getsubcount(data)
			for i=1,datacount do
				local dataid = csvconfig_getsubvalue(data, i, configsubtype.int)
				local config_data = c_config_getmetaid(configid.map_shapedata, dataid)
				if config_data ~= nil then
					local datatime = config_data.time
					if config_data.type == 0 then
						if datatime == "0" or datatime == timedesc then
							if shape.priority >= musicshapepriority then
								musicarray = config_data.data
								musicshapepriority = shape.priority
								musicdataid = dataid
							end
						end
					elseif config_data.type == 1 then
						if datatime == "0" or datatime == timedesc then
							if shape.priority >= fogshapepriority then
								fogparam = config_data.data
								fogshapepriority = shape.priority
								fogdataid = dataid
							end
						end
					end
				end
			end
		end
	end
	if musicdataid ~= m_scene_shapemusicid then
		m_scene_shapemusicid = musicdataid
		if musicarray ~= nil then
			audiomanager_setambient(string.split(musicarray, ","))
		else
			audiomanager_setambient(nil)
		end
	end
	if fogdataid ~= m_scene_shapefogid then
		m_scene_shapefogid = fogdataid
		m_scene_shapefog = fogparam
		if fogparam ~= nil then
			c_scene_setenv("fog", m_scene_shapefog, 1.0)
		elseif m_scene_scenefog ~= nil then
			c_scene_setenv("fog", m_scene_scenefog, 1.0)
		end
	end
end

function scene_setrender(render)
	local dayhour, dayminute = csvmaptimeenv_getgametime()
	if m_scene_rendersetting == render and m_scene_renderhour == dayhour then
		return
	end
	local lerptime = math.ternary(m_scene_rendersetting ~= nil, 5.0, 0.0)
	m_scene_rendersetting = render
	m_scene_renderhour = dayhour
	
	local setting = nil
	local config_setting = csvmaptimeenv_getfromzone(m_scene_mapconfig.id, render)
	if config_setting ~= nil and #config_setting > 0 then
		setting = config_setting[#config_setting]
		for i=1,#config_setting do
			if dayhour >= config_setting[i].hour then
				setting = config_setting[i]
			end
		end
	else
		local config_setting = csvmaptimeenv_getfrommap(m_scene_mapconfig.id)
		if config_setting ~= nil and #config_setting > 0 then
			setting = config_setting[1]
		end
		if setting == nil then
			return
		end
	end
	if m_scene_mapconfig.shadow > 0 then
		c_scene_setenv("shadow", "1,0.2,5", 0.0)
	else
		c_scene_setenv("shadow", "0,0.2,5", 0.0)
	end
	c_scene_setenv("envcolor", m_scene_mapconfig.envcolor, 0.0)
	c_scene_setenv("suncolor", m_scene_mapconfig.suncolor, 0.0)
	c_scene_setenv("sunangle", m_scene_mapconfig.sunangle, 0.0)
	c_scene_setenv("skybox", setting.skybox .. ",textures/skybox/fog/fog.png", 0.0)
	c_scene_setenv("camera", setting.dist, lerptime)
	c_scene_setenv("ambient", setting.ambient, lerptime)
	m_scene_scenefog = string.format("%d,%d,%d", setting.fogcolor, setting.fognear, setting.fogfar)
	if m_scene_shapefog ~= nil then
		c_scene_setenv("fog", m_scene_shapefog, lerptime)
	else
		c_scene_setenv("fog", m_scene_scenefog, lerptime)
	end
end

function scene_setzonename(zonename)
	if m_scene_zonetext.key == nil or zonename ~= m_scene_zonetext.key then
		m_scene_zonetext.key = zonename
		local title, note = csvmap_splitzonename(zonename)
		zone_create(title, note)
		minimapadditive_setname(title)
	end
end

local function scene_getpoly()
	local zone_name = nil
	local zone_radar = nil
	local zone_render = nil
	local zone_music = nil
	local zone_elevator = nil
	local polyarray = c_config_getmetapoly(configid.map_zone, "mapid", m_scene_mapconfig.id, playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
	if polyarray ~= nil then
		for i=1,#polyarray do
			local poly = polyarray[i]
			if poly.type == mapzone.name then
				playerfogmask_entermask(poly.name)
				playerquest_enterzone(poly.name)
				if zone_name == nil or zone_name.priority > poly.priority then
					zone_name = poly
				end
			elseif poly.type == mapzone.radar then
				if zone_radar == nil or zone_radar.priority > poly.priority then
					zone_radar = poly
				end
			elseif poly.type == mapzone.render then
				if zone_render == nil or zone_render.priority > poly.priority then
					zone_render = poly
				end
			elseif poly.type == mapzone.music then
				if zone_music == nil or zone_music.priority > poly.priority then
					zone_music = poly
				end
			elseif poly.type == mapzone.elevator then
				zone_elevator = poly
			end
		end
	end
	local zone_shape = c_config_getmetapoly(configid.map_shape, "mapid", m_scene_mapconfig.id, playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
	return zone_name, zone_radar, zone_render, zone_music, zone_elevator, zone_shape
end

local function scene_playermusictype(config_bgmarray, type)
	local bgmlist = nil
	for i=1,#config_bgmarray do
		local config_bgm = config_bgmarray[i]
		if config_bgm.type == type and config_bgm.filename ~= "0" then
			if bgmlist == nil then
				bgmlist = {}
			end
			bgmlist[#bgmlist + 1] = config_bgmarray[i]
		end
	end
	if bgmlist == nil then
		return false
	end
	local flag = 0
	local config_bgm = bgmlist[math.random(1, #bgmlist)]
	m_scene_bgmonce = config_bgm.loop == 0
	if config_bgm.loop > 0 and #bgmlist == 1 then
		flag = audioflag.loop
	end
	audiomanager_playmusic(config_bgm.filename, 2.0, flag)
	return true
end
local function scene_updatebattlemusic(config_bgmarray, zone_music)
	if gamesetting_getnumber("BATTLEMUSIC") == 0 then
		return false
	end
	if m_me == nil or not m_me:getbattle() then
		return false
	end
	if m_scene_bgmbattle and m_scene_bgmname ~= nil then
		return true
	end
	if not scene_playermusictype(config_bgmarray, mapbgmtype.battle) then
		return false
	end
	m_scene_bgmbattle = true
	m_scene_bgmname = zone_music.name
	return true
end
local function scene_updatebgmusic(config_bgmarray, zone_music)
	if m_scene_bgmname ~= nil then
		return
	end
	if not scene_playermusictype(config_bgmarray, m_scene_bgmevent) then
		return
	end
	m_scene_bgmname = zone_music.name
end
local function scene_getdeadmusic()
	if m_scene_mapconfig.id == 400010000 then
		return "sounds/music/death_bgm-abyss.ogg"
	elseif m_me.attr.civ == playerciv.light then
		return "sounds/music/death_bgm-light.ogg"
	else
		return "sounds/music/death_bgm-dark.ogg"
	end
end
local function scene_updatemusic(zone_music)
	if cgmask_playing() then
		audiomanager_stopmusic()
		return
	end
	if m_me ~= nil and m_me:isdead() then
		local musicpath = scene_getdeadmusic()
		if m_scene_bgmname ~= nil and m_scene_bgmname ~= musicpath then
			audiomanager_stopmusic()
			m_scene_bgmname = nil
		end
		if m_scene_bgmname == nil then
			audiomanager_playmusic(musicpath, 10.0, audioflag.loop)
			m_scene_bgmname = musicpath
		end
		return
	end
	if m_scene_bgmname ~= nil then
		if m_scene_bgmname ~= zone_music.name then
			m_scene_bgmname = nil
			audiomanager_stopmusic()
		elseif not m_scene_bgmonce and not audiomanager_musicplaying() then
			m_scene_bgmname = nil
		end
	end
	local config_bgmarray = csvmapbgm_getfrommap(m_scene_mapconfig.id, zone_music.name)
	if config_bgmarray == nil then
		audiomanager_stopmusic()
		return
	end
	if not scene_updatebattlemusic(config_bgmarray, zone_music) then
		if m_scene_bgmbattle then
			audiomanager_stopmusic()
			m_scene_bgmbattle = false
			m_scene_bgmname = nil
		end
		scene_updatebgmusic(config_bgmarray, zone_music)
	end
end
function scene_update()
	if scene_isloading() or m_scene_mapconfig == nil or playerattr_info == nil then
		return
	end
	if playerattr_info ~= nil then
		c_scene_updatetile(playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
	end
    if m_scene_updatezonetime < time_game then
        m_scene_updatezonetime = time_game + 1.0
		local zone_name, zone_radar, zone_render, zone_music, zone_elevator, zone_shape = scene_getpoly()
		if zone_name ~= nil then
			scene_setzonename(zone_name.name)
		else
			minimapadditive_setname(nil)
		end
		if zone_radar ~= nil then
			minimap_setradar(m_scene_mapconfig, zone_radar.name)
		else
			minimap_setradar(m_scene_mapconfig, nil)
		end
		if zone_shape ~= nil then
			scene_setshape(zone_shape)
		else
			scene_setshape(nil)
		end
		if zone_render ~= nil then
			scene_setrender(zone_render.name)
		else
			scene_setrender("0")
		end
		if zone_music ~= nil then
			scene_updatemusic(zone_music)
		else
			audiomanager_stopmusic()
		end
		m_scene_elevatorzone = zone_elevator
	end
end

function scene_worldchanged()
	debuglog("scene_worldchanged:" .. scene_getmapid())
	local loadingattr = m_scene_loading
	m_scene_zonename = nil
	m_scene_updatezonetime = 0
	m_scene_loading = nil
	if playerattr_info.movetype == playermovestate.move then
		playerattr_info.posy = scene_getfloorheight(playerattr_info.posx, playerattr_info.posy, playerattr_info.posz, 0)
	end
	actormanager_reload()
	if m_me ~= nil then
		m_me:setbattle(0, false)
		if m_me.actionmain.talknpcteleport ~= nil then
			m_me.actionmain.talknpctype = npcmotiontype.teleportin
			m_me.actionmain.talknpcteleport = nil
		end
	end
	serverattr_update()
	sceneentity_updatewindpath()
	if loadingattr ~= nil then
		if loadingattr.flightpath ~= nil then
			m_me:clearsequence()
			m_me.actordata.sequencetimestart = time_game - loadingattr.flighttimestart
			m_me.actordata.sequencecg = false
			c_actor_flightstart(loadingattr.flightpath, m_me.id, m_me:getcgvoice(), loadingattr.flighttimestart)
			loadingattr.flightpath = nil
		elseif loadingattr.cutscene ~= nil then
			local config_cutscene = c_config_getmetaid(configid.cutscene, loadingattr.cutscene)
			if config_cutscene ~= nil then
				cgmask_start(config_cutscene.name, config_cutscene.timestart, config_cutscene.timeend - config_cutscene.timestart, true)
			end
		end
	end
	home_main_create()
end
