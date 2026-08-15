
animaliasfile =
{
    file = 0,
    name = 1,
    rand = 2,
}

animaliascommand =
{
    anim = 0,
    audiotype = 1,
    audiofile = 2,
    hitpoint = 3,
    attachmesh = 4,
    equipweapon = 5,
    vfx = 6,
}

local m_csv_animalias = {}
local m_csv_animmarker = {}

function csvanimmarker_load(meshname)
    local meshfile = m_csv_animmarker[meshname]
    if meshfile ~= nil then
        return meshfile
    end
    meshfile = {}
    m_csv_animmarker[meshname] = meshfile
    local config_array = c_config_loadsimplearray(csvconfig_streamfilename("animmarker/" .. meshname))
    local type = nil
    local config_val = {}
    local anim = nil
    local alias = nil
    local index = 1
    local valcount = 0
    while index < #config_array do
        type, index, valcount = csvconfig_loadsimple(config_array, config_val, index)
        if type == animaliascommand.anim then
            alias = {}
            meshfile[config_val[1]] = alias
        elseif type == animaliascommand.audiotype then
            if alias.audiotype == nil then
                alias.audiotype = {}
            end
            local audio = {}
            audio.time = tonumber(config_val[1])
            audio.type = config_val[2]
            audio.loop = config_val[3] == "1"
            audio.volume = tonumber(config_val[4])
            audio.inradius = tonumber(config_val[5])
            audio.outradius = tonumber(config_val[6])
            alias.audiotype[#alias.audiotype + 1] = audio
        elseif type == animaliascommand.audiofile then
            if alias.audiofile == nil then
                alias.audiofile = {}
            end
            local audio = {}
            audio.time = tonumber(config_val[1])
            audio.file = config_val[2]
            audio.loop = config_val[3] == "1"
            audio.volume = tonumber(config_val[4])
            audio.inradius = tonumber(config_val[5])
            audio.outradius = tonumber(config_val[6])
            alias.audiofile[#alias.audiofile + 1] = audio
        elseif type == animaliascommand.hitpoint then
            if alias.hitpoint == nil then
                alias.hitpoint = {}
            end
            local hitpoint = {}
            alias.hitpoint[#alias.hitpoint + 1] = hitpoint
            hitpoint.time = tonumber(config_val[1])
            for i=2, valcount do
                local subval = string.split(config_val[i], "=")
                hitpoint[subval[1]] = subval[2]
            end
        elseif type == animaliascommand.attachmesh then
            if alias.attachmesh == nil then
                alias.attachmesh = {}
            end
            local attachmesh = {}
            alias.attachmesh[#alias.attachmesh + 1] = attachmesh
            attachmesh.time = tonumber(config_val[1])
            attachmesh.detach = tonumber(config_val[2])
            attachmesh.mesh = config_val[3]
            attachmesh.bone = config_val[4]
        elseif type == animaliascommand.vfx then
            if alias.vfx == nil then
                alias.vfx = {}
            end
            local vfx = {}
            alias.vfx[#alias.vfx + 1] = vfx
            vfx.time = tonumber(config_val[1])
            vfx.name = config_val[2]
            vfx.bone = config_val[3]
            vfx.x = config_val[4]
            vfx.y = config_val[5]
            vfx.z = config_val[6]
        elseif type == animaliascommand.equipweapon then
            alias.equipweapon = tonumber(config_val[1])
        end
    end
    return meshfile
end

function csvanimalias_load(meshpath, meshtitle)
    local meshfile = m_csv_animalias[meshpath]
    if meshfile ~= nil then
        return meshfile
    end
    local marker = csvanimmarker_load(meshtitle)
    meshfile = {}
    meshfile.anim = {}
    meshfile.markerarray = marker
    m_csv_animalias[meshpath] = meshfile
    local config_array = c_config_loadsimplearray(csvconfig_streamfilename("animalias/" .. meshpath))
    local type = nil
    local config_val = {}
    local file = nil
    local length = 0
    local index = 1
    while index < #config_array do
        type, index = csvconfig_loadsimple(config_array, config_val, index)
        if type == animaliasfile.file then
            file = config_val[1]
            length = tonumber(config_val[2])
        elseif type == animaliasfile.name then
            local name = config_val[1]
            local anim = {}
            anim.file = file
            anim.marker = marker[name]
            anim.length = length
            anim.prob = 0
            if #config_val > 1 then
                anim.prob = tonumber(config_val[2])
            end
            meshfile.anim[name] = anim
        elseif type == animaliasfile.rand then
            if meshfile.rand == nil then
                meshfile.rand = {}
            end
            local rand = {}
            rand.name = config_val[1]
            rand.prob = {}
            for i=2,#config_val do
                rand.prob[#rand.prob + 1] = tonumber(config_val[i])
            end
            meshfile.rand[rand.name .. "_001"] = rand
        end
    end
    return meshfile
end

function csvanimalias_splithitpoint(splitcount, valtotal, randseed)
    local valsegment = valtotal / splitcount
    local randrange = valsegment * 0.2
    local valadd = 0.0
    local display = {}
    for i=1,splitcount do
        if i < splitcount then
            if math.fmod(i, 2) == 1 then
                valadd = math.fmod(randseed, 100.0) / 100.0 * randrange
            else
                valadd = -valadd
            end
            display[#display + 1] = math.floor(valsegment + valadd)
        else
            display[#display + 1] = valtotal
        end
        valtotal = valtotal - display[#display]
    end
    return display
end
