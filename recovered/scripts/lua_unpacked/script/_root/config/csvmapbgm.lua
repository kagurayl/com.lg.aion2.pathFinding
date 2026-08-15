
mapbgmtype =
{
    battle = -1,
    bgm = 0,
    year = 1,
}

function csvmapbgm_getfrommap(mapid, name)
    return c_config_getmetaarray(configid.map_bgm, "id", mapid, "name", name)
end
