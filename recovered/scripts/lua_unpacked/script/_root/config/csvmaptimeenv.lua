
csvmaptimeenv_daytimescale = 12

function csvmaptimeenv_getfrommap(mapid)
    return c_config_getmetaarray(configid.map_timeenv, "id", mapid)
end

function csvmaptimeenv_getfromzone(mapid, name)
    return c_config_getmetaarray(configid.map_timeenv, "id", mapid, "name", name)
end

function csvmaptimeenv_getgametime()
	local daytime = math.floor(timer_gettimesecond() * csvmaptimeenv_daytimescale)
    daytime = math.fmod(daytime, 86400)
	local dayhour = math.floor(daytime / 3600)
    local dayminute = math.fmod(math.floor(daytime / 60), 60)
	return dayhour, dayminute
end
