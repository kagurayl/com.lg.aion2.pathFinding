local m_maplabel_locationflicker = 0
local m_maplabel_location = nil
local m_maplabel_locationarray = nil

function maplabel_simplereset()
	m_maplabel_locationflicker = 0
	m_maplabel_location = nil
	m_maplabel_locationarray = nil
end

function maplabel_addnpclocation(npcid)
	if npcid == nil or #npcid == 0 then
		maplabel_simplereset()
		maplabel_updateui()
		return
	end

	local currentmapposition = nil
	local mapid = nil
	local mapposition = nil
	for i=1,#npcid do
		local config_spawn = csvnpcspawn_getmapspawnnpc(npcid[i])
		if config_spawn ~= nil and #config_spawn > 0 then
			local spawnposition = csvspawn_parsepoint(config_spawn[1])
			if spawnposition == nil or #spawnposition == 0 then
				return
			end
			if config_spawn[1].mapid == scene_getmapid() then
				currentmapposition = spawnposition[1]
				break
			elseif mapid == nil then
				mapid = config_spawn[1].mapid
				mapposition = spawnposition[1]
			end
		end

		local config_spawnstatic = csvnpcstatic_getfromnpcid(npcid[i])
		if config_spawnstatic ~= nil and #config_spawnstatic > 0 then
			local spawnposition = csvspawn_parsepoint(config_spawnstatic[1])
			if spawnposition == nil or #spawnposition == 0 then
				return
			end
			if config_spawnstatic[1].id == scene_getmapid() then
				currentmapposition = spawnposition[1]
				break
			elseif mapid == nil then
				mapid = config_spawnstatic[1].id
				mapposition = spawnposition[1]
			end
		end
	end

	if currentmapposition ~= nil then
		maplabel_addlocation(true, scene_getmapid(), currentmapposition.x, currentmapposition.y, currentmapposition.z)
	elseif mapid ~= nil then
		maplabel_addlocation(true, mapid, mapposition.x, mapposition.y, mapposition.z)
	end
end

function maplabel_addlocation(system, mapid, worldx, worldy, worldz)
	local config_map = csvmap_getfromid(mapid)
	if not mapview_openformap(config_map) then
		return
	end

	m_uimap_main:open()
	m_maplabel_location = {}
	m_maplabel_location.mapid = mapid
	m_maplabel_location.type = math.ternary(system, maplabeltype.systemlocation, maplabeltype.playerlocation)
	m_maplabel_location.worldx = worldx
	m_maplabel_location.worldy = worldy
	m_maplabel_location.worldz = worldz
	m_maplabel_locationflicker = time_game
	mapview_setmapid(mapid, csvmap_getlayer(config_map, worldy))
end

function maplabel_addlocationarray(locationarray)
	maplabel_simplereset()
	if locationarray == nil or #locationarray == 0 then
		maplabel_updateui()
		return
	end
	local config_map = csvmap_getfromid(locationarray[1].mapid)
	if not mapview_openformap(config_map) then
		maplabel_updateui()
		return
	end
	m_uimap_main:open()
	m_maplabel_locationarray = locationarray
	mapview_setmapid(locationarray[1].mapid, csvmap_getlayer(config_map, locationarray[1].worldy))
end

function maplabel_getlocation()
	return m_maplabel_location
end

function maplabel_updatezonename(labelwidget, config_map)
	local zonecount = 1
	local zonenamepath = "scene_root/canvas_move/canvas_zonename/text_zonename_"
	local text_zonename_template = m_uimap_main:getwidget(zonenamepath .. 1)
	local config_zonearray = c_config_getmetaarray(configid.map_zone, "mapid", config_map.id, "type", mapzone.name)
	if config_zonearray ~= nil then
		for zoneindex=1,#config_zonearray do
			local config_zone = config_zonearray[zoneindex]
			local pointarray = string.split(config_zone.poly, ";")
			local heightrange = string.splitnumber(pointarray[1], ",")
			if maplabel_rangelayervisible(heightrange[1], heightrange[2]) then
				local x1, y1, x2, y2
				for i=2,#pointarray do
					local point = string.splitnumber(pointarray[i], ",")
					if x1 == nil then
						x1 = point[1]
						y1 = point[2]
						x2 = point[1]
						y2 = point[2]
					else
						x1 = math.min(x1, point[1])
						y1 = math.min(y1, point[2])
						x2 = math.max(x2, point[1])
						y2 = math.max(y2, point[2])
					end
				end
				local text_zonename = m_uimap_main:getwidget(zonenamepath .. zonecount)
				if text_zonename == nil then
					text_zonename = text_zonename_template:clone("text_zonename_" .. zonecount)
				end
				local splittext = string.split(c_textformat(config_zone.name), "\n")
				text_zonename:setvisiblenothit(true)
				text_zonename:settextraw(splittext[1])
				text_zonename:setposition(uix, uiy)
				text_zonename:sethexcolor(Color_MapSubZone)
				text_zonename.x1 = x1
				text_zonename.y1 = y1
				text_zonename.x2 = x2
				text_zonename.y2 = y2
				text_zonename.labeltype = maplabeltype.zonename
				labelwidget[#labelwidget + 1] = text_zonename
				zonecount = zonecount + 1
			end
		end
	end
	m_uimap_main:hideunused(zonenamepath, zonecount)
end

function maplabel_updatelocation(labelwidget, flickerwidget, config_map)
	local locationpath = "scene_root/canvas_move/canvas_location/image_location_"
	local locationindex = 1
	local image_locationtemplate = m_uimap_main:getwidget(locationpath .. 1)
	if m_maplabel_location ~= nil and m_maplabel_location.mapid == config_map.id and maplabel_layervisible(m_maplabel_location.worldy) then
		local imagelabel = nil
		if m_maplabel_location.type == maplabeltype.systemlocation then
			imagelabel = csvlabelimage.hint_system
		else
			imagelabel = csvlabelimage.hint_player
		end
		local image_location = image_locationtemplate
		locationindex = locationindex + 1
		if image_location.sprite == nil or image_location.sprite ~= imagelabel.image then
			image_location.sprite = imagelabel.image
			image_location:setsprite(imagelabel.image)
		end
		image_location:setsize(imagelabel.width * 2, imagelabel.height * 2)
		image_location.worldx = m_maplabel_location.worldx
		image_location.worldz = m_maplabel_location.worldz
		image_location.labeltype = m_maplabel_location.type
		image_location.flickertime = m_maplabel_locationflicker
		labelwidget[#labelwidget + 1] = image_location
		flickerwidget[#flickerwidget + 1] = image_location
	end
	if m_maplabel_locationarray ~= nil then
		for i=1,#m_maplabel_locationarray do
			local location = m_maplabel_locationarray[i]
			if location ~= nil and location.mapid == config_map.id and maplabel_layervisible(location.worldy) then
				local imagelabel = nil
				if location.type == maplabeltype.systemlocation then
					imagelabel = csvlabelimage.hint_system
				else
					imagelabel = csvlabelimage.hint_player
				end
				local image_location = m_uimap_main:getwidget(locationpath .. locationindex)
				if image_location == nil then
					image_location = image_locationtemplate:clone("image_location_" .. locationindex)
				end
				locationindex = locationindex + 1
				if image_location.sprite == nil or image_location.sprite ~= imagelabel.image then
					image_location.sprite = imagelabel.image
					image_location:setsprite(imagelabel.image)
				end
				image_location:setsize(imagelabel.width * 2, imagelabel.height * 2)
				image_location.worldx = location.worldx
				image_location.worldz = location.worldz
				image_location.labeltype = location.type
				image_location.flickertime = m_maplabel_locationflicker
				labelwidget[#labelwidget + 1] = image_location
				flickerwidget[#flickerwidget + 1] = image_location
			end
		end
	end
	m_uimap_main:hideunused(locationpath, locationindex)
end
