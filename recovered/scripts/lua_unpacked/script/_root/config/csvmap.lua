
mapzone = 
{
    name = 0,
    radar = 1,
    render = 2,
    music = 3,
    fly = 4,
    elevator = 5,
}

mapid_resetskin = 1
mapid_resetsex = 2

function csvmap_getfromid(id)
    local config_map = c_config_getmetaid(configid.map, id)
	return config_map
end

function csvmap_getlayer(config_map, height)
	if config_map ~= nil and config_map.layer1 ~= 0 and height ~= nil then
		if height < config_map.layer1 then
			return 1
		elseif height > config_map.layer2 then
			return 3
		else
			return 2
		end
	end
	return nil
end

function csvmap_getrangelayer(config_map, bottom, top)
	if config_map ~= nil and config_map.layer1 ~= 0 then
		if bottom < config_map.layer1 then
			return 1
		elseif top > config_map.layer2 then
			return 3
		else
			return 2
		end
	end
end

function csvmap_hasmap(config_map, bottom, top)
	if config_map == nil then
		return false
	end
	if config_map.layer1 ~= 0 then
		return true
	end
	local imagepath = string.format("map/%s/%s_%03d", config_map.scene, config_map.scene, 1)
	local imagewidth, imageheight = c_uigettexturesize(unity_uitexturepath(imagepath))
	if imagewidth == 0.0 or imageheight == 0.0 then
		return false
	end
	return true
end

function csvmap_splitzonename(zonename)
	local zonetext = c_textformat(zonename)
	local splittext = string.split(zonetext, "\n")
	if #splittext == 1 then
		splittext = string.split(zonetext, "n")
	end
	local title = splittext[1]
	local note = ""
	if #splittext > 1 then
		note = splittext[2]
	end
	return title, note
end

function csvmap_getzonename(mapid, x, y, z)
	local zone_name = nil
	local polyarray = c_config_getmetapoly(configid.map_zone, "mapid", mapid, x, y, z)
	if polyarray ~= nil then
		for i=1,#polyarray do
			local poly = polyarray[i]
			if poly.type == mapzone.name then
				if zone_name == nil or zone_name.priority > poly.priority then
					zone_name = poly
				end
			end
		end
	end
	if zone_name == nil then
		return nil
	end
	local title, note = csvmap_splitzonename(zone_name.name)
    return title, note
end
