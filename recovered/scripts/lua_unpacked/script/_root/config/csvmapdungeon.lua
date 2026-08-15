
function csvmapdungeon_getarray()
    local csvmapdungeon = c_config_getmetaall(configid.map_dungeon)
    local dungeonarray = {}
    for i=1,#csvmapdungeon do
        local config_dungeon = csvmapdungeon[i]
        if (config_dungeon.lightlevel > 0 and playerattr_info.civ == playerciv.light)
        or (config_dungeon.darklevel > 0 and playerattr_info.civ == playerciv.dark) then
            if config_dungeon.category > 0 then
                dungeonarray[#dungeonarray + 1] = config_dungeon
            end
        end
    end
    if playerattr_info.civ == playerciv.light then
        table.sort(dungeonarray, function(a, b) return (a.lightlevel < b.lightlevel) end)
    else
        table.sort(dungeonarray, function(a, b) return (a.darklevel < b.darklevel) end)
    end
    return dungeonarray
end

function csvmapdungeon_getfromid(id)
    return c_config_getmetaid(configid.map_dungeon, id)
end
