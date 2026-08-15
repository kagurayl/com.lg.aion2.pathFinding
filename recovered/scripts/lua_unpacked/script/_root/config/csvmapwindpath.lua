
local m_csv_windpath = nil
local m_csv_windpathradius = 10.0
function csvmapwindpath_load()
    m_csv_windpath = c_config_loadscripttable(csvconfig_filename("map_windpath"))
    for key, val in pairs(m_csv_windpath) do
        local config_windpath = val
        local posarray = string.split(config_windpath.position, ";")
        config_windpath.position = {}
        for j=1,#posarray do
            local pos = string.splitnumber(posarray[j], ",")
            config_windpath.position[j] = pos
            if config_windpath.min ~= nil then
                config_windpath.min[1] = math.min(config_windpath.min[1], pos[1])
                config_windpath.min[2] = math.min(config_windpath.min[2], pos[2])
                config_windpath.min[3] = math.min(config_windpath.min[3], pos[3])
                config_windpath.max[1] = math.max(config_windpath.max[1], pos[1])
                config_windpath.max[2] = math.max(config_windpath.max[2], pos[2])
                config_windpath.max[3] = math.max(config_windpath.max[3], pos[3])
            else
                config_windpath.min = {pos[1], pos[2], pos[3]}
                config_windpath.max = {pos[1], pos[2], pos[3]}
            end
        end
        for i=1,3 do
            config_windpath.min[i] = config_windpath.min[i] - m_csv_windpathradius
            config_windpath.max[i] = config_windpath.max[i] + m_csv_windpathradius
        end
    end
end

function csvmapwindpath_getfromid(id)
    return m_csv_windpath[id]
end

function csvmapwindpath_getsegment()
    local xmin = playerattr_info.posx - m_csv_windpathradius
    local xmax = playerattr_info.posx + m_csv_windpathradius
    local ymin = playerattr_info.posy - m_csv_windpathradius
    local ymax = playerattr_info.posy + m_csv_windpathradius
    local zmin = playerattr_info.posz - m_csv_windpathradius
    local zmax = playerattr_info.posz + m_csv_windpathradius
    local distmin = nil
    local windpath = nil
    local windpathpointindex = nil
    for key, val in pairs(m_csv_windpath) do
        local config_windpath = val
        if config_windpath.mapid == playerattr_info.mapid and sceneentity_getwindpath(config_windpath.id) then
            if playerattr_info.posx > config_windpath.min[1] and playerattr_info.posx < config_windpath.max[1]
            and playerattr_info.posy > config_windpath.min[2] and playerattr_info.posy < config_windpath.max[2]
            and playerattr_info.posz > config_windpath.min[3] and playerattr_info.posz < config_windpath.max[3] then
                for j=1,#config_windpath.position do
                    local pathpos = config_windpath.position[j]
                    if pathpos[1] > xmin and pathpos[1] < xmax
                    and pathpos[2] > ymin and pathpos[2] < ymax
                    and pathpos[3] > zmin and pathpos[3] < zmax then
                        local dist = vector3_distance(pathpos[1], pathpos[2], pathpos[3], playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
                        if distmin == nil or dist < distmin then
                            distmin = dist
                            windpath = config_windpath
                            windpathpointindex = j
                        end
                    end
                end
            end
        end
    end
    return windpath, windpathpointindex
end
