
local m_csvnpcspawn_map = nil
local m_csvnpcspawn_light = nil
local m_csvnpcspawn_dark = nil

function csvspawn_parsepoint(config_spawn)
    if config_spawn.position ~= nil then
        local pointarray = {}
        local subpos = string.split(config_spawn.position, ";")
        for i=1,#subpos do
            local pos = string.splitnumber(subpos[i], ",")
            pointarray[#pointarray + 1] = {x = pos[1], y = pos[2], z = pos[3]}
        end
        return pointarray
    end
end

function csvnpcspawn_getmapspawn(mapid)
    local config_array = c_config_getmetaarray(configid.spawn_npc, "mapid", mapid)
    local config_teammatearray = c_config_getmetaarray(configid.spawn_teammate, "mapid", mapid)
    if config_teammatearray ~= nil then
        if config_array == nil then
            config_array = {}
        end
        for teamindex=1,#config_teammatearray do
            config_array[#config_array + 1] = config_teammatearray[teamindex]
        end
    end
    return config_array
end

function csvnpcspawn_getmapspawnnpc(npcid)
    local config_array = c_config_getmetaarray(configid.spawn_npc, "id", npcid)
    local config_teammatearray = c_config_getmetaarray(configid.spawn_teammate, "id", npcid)
    if config_teammatearray ~= nil then
        if config_array == nil then
            config_array = {}
        end
        for teammateindex=1,#config_teammatearray do
            config_array[#config_array + 1] = config_teammatearray[teamindex]
        end
    end
    if config_array == nil then
        return
    end
    local localmap = false
    for i=1,#config_array do
        if config_array[i].mapid == scene_getmapid() then
            localmap = true
            break
        end
    end
    if localmap then
        for i=#config_array, 1, -1 do
            if config_array[i].mapid ~= scene_getmapid() then
                table.remove(config_array, i)
            end
        end
    end
    return config_array
end

function csvnpcstatic_getfromid(mapid, staticid)
    local config_array = c_config_getmetaarray(configid.spawn_static, "id", mapid, "staticid", staticid)
    if config_array ~= nil and #config_array > 0 then
        return config_array[1]
    end
    return nil
end

function csvnpcstatic_getfromnpcid(npcid)
    if npcid == 0 then
        return nil
    end
    local config_array = c_config_getmetaarray(configid.spawn_static, "npcid", npcid)
    if config_array ~= nil then
        local localmap = false
        for i=1,#config_array do
            if config_array[i].id == scene_getmapid() then
                localmap = true
                break
            end
        end
        if localmap then
            for i=#config_array, 1, -1 do
                if config_array[i].id ~= scene_getmapid() then
                    table.remove(config_array, i)
                end
            end
        end
    end
    return config_array
end

function csvnpcstatic_getfrommapid(mapid)
    local config_array = c_config_getmetaarray(configid.spawn_static, "id", mapid)
    return config_array
end
