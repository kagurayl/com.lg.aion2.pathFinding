
local playerfogmask = nil

function playerfogmask_setmask(fogmask)
	playerfogmask = {}
	local config_fogmaskarray = c_config_getmetaall(configid.map_fogmask)
    for i=1,#config_fogmaskarray do
        local config_fogmask = config_fogmaskarray[i]
        local bitarray = math.tointegerfloor((config_fogmask.id - 1) / 8) + 1
		local bitindex = math.fmod(config_fogmask.id - 1, 8)
		if fogmask[bitarray] ~= nil and bit.band(fogmask[bitarray], bit.lshift(1, bitindex)) ~= 0 then
			playerfogmask[config_fogmask.name] = 1
		end
    end
end

function playerfogmask_entermask(name)
	if playerfogmask[name] == nil then
		local config_fogmask = c_config_getmetacol(configid.map_fogmask, "name", name)
		if config_fogmask ~= nil then
			local msg = {messageid="CS_FogMask"}
			msg.id = config_fogmask.id
			c_send(msg)
		end
	end
end

function playerfogmask_openmask(id)
	local config_fogmask = c_config_getmetaid(configid.map_fogmask, id)
	if config_fogmask ~= nil then
		if config_fogmask.powermask > 0 then
			audiomanager_playaudioui(AudioEnterFogMaskPower)
		else
			audiomanager_playaudioui(AudioEnterFogMask)
		end
		playerfogmask[config_fogmask.name] = 1
		zonefog_create(config_fogmask.name)
		mapview_updatemask()
	end
end

function playerfogmask_createmasktexture(mapid)
	c_uiimage_clearpolymask()
	local config_fogmaskarray = c_config_getmetaarray(configid.map_fogmask, "mapid", mapid)
	if config_fogmaskarray ~= nil then
		for i=1,#config_fogmaskarray do
			local config_fogmask = config_fogmaskarray[i]
			if playerfogmask[config_fogmask.name] ~= nil then
				local config_zone = c_config_getmetaarray(configid.map_zone, "mapid", mapid, "name", config_fogmask.name)
				if config_zone ~= nil then
					config_zone = config_zone[1]
					local zonename = config_zone.name
					c_uiimage_addpolymask(config_zone.poly)
				end
			end
		end
	end
end
