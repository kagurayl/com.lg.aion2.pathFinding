include("config/lambda")
include("config/player")
include("config/battle")
include("config/csvassetpreload")
include("config/csvasset")
include("config/csvrender")
include("config/csvrenderpreset")
include("config/csvanimalias")
include("config/csvlabelimage")
include("config/csvaudio")

include("config/csvmap")
include("config/csvmapdungeon")
include("config/csvmapbgm")
include("config/csvmaptimeenv")
include("config/csvmapwindpath")

include("config/csvitem")
include("config/csvitemset")
include("config/csvxml")
include("config/csvskill")
include("config/csvskillbuff")
include("config/csvskilllearn")
include("config/csvskillsocial")
include("config/csvskillbone")
include("config/csvskillfxc")
include("config/csvanimcard")
include("config/csvchat")

include("config/csvnpc")
include("config/csvnpctribe")
include("config/csvnpcspawn")

include("config/csvshop")

include("config/csvcrafting")
include("config/csvpet")

include("config/csvquest")
include("config/csvqueststep")

include("config/csvplayertitle")

include("config/gamesetting")
include("config/timer")
include("config/equip")
include("config/system")

configid =
{
    abyss_castle = 1,
    abyss_artifact = 2,
    crafting_recipe = 3,
    crafting_harvest = 4,
    crafting_task = 5,
    equip_weapon = 6,
    equip_armor = 7,
    equip_helmet = 8,
    equip_soulattr = 9,
    item_set = 10,
    item_normal = 11,
    item_category = 12,
    map = 13,
    map_dungeon = 14,
    map_timeenv = 15,
    map_bgm = 16,
    map_zone = 17,
    map_dict = 18,
    map_fogmask = 19,
    map_shape = 20,
    map_shapedata = 21,
    map_door = 22,
    map_windbox = 23,
    map_itemarea = 24,
    map_airport = 25,
    map_airline = 26,
    npc = 27,
    npc_dict = 28,
    npc_faction = 29,
    player_exp = 30,
    player_pvpscore = 31,
    player_title = 32,
    quest = 33,
    queststep = 34,
    cutscene = 35,
    render_skeleton = 36,
    render_preset = 37,
    render_additive = 38,
    render_physicmaterial = 39,
    shop = 40,
    shop_limit = 41,
    store = 42,
    payment = 43,
    skill = 44,
    skill_buff = 45,
    skill_social = 46,
    spawn_static = 47,
    spawn_npc = 48,
    spawn_teammate = 49,
    pet_main = 50,
    pet_feed = 51,
    tutorial = 52,
    tutorialtips = 53,
    npc_directportal = 54,
    equip_gemhole = 55,
}

configsubtype =
{
    str = 1,
    int = 2,
	hex = 3,
    flt = 4,
}

local m_scriptid = 0
local m_split_byte_comma = string.byte(",")
local m_split_byte_point = string.byte(".")
local m_split_byte_0 = string.byte("0")
local m_split_byte_9 = string.byte("9")
local m_split_byte_nag = string.byte("-")

function csvconfig_load()
    local configcount = 0
    for key, value in pairs(configid) do
		configcount = math.max(configcount, value + 1)
	end
    c_config_init(configcount, csvconfig_filename("csvstring"))

    for key, value in pairs(configid) do
        c_config_load(value, csvconfig_filename(key))
    end

    csvmapwindpath_load()
    csvnpctribe_load()
    
    csvskill_load()
    csvskillbuff_load()

    csvskilllearn_load()
    csvskillbone_load()
    csvskillfxc_load()

    csvanimcard_load()
    csvchat_load()
    csvquest_load()

    csvlabelimage_load()
    csvaudio_load()
end

function csvconfig_filename(key)
    return "config/" .. key .. ".txt"
end

function csvconfig_streamfilename(key)
    return "streamconfig/" .. key .. ".txt"
end

function csvconfig_loadsimple(config_array, config_val, index)
    local type = config_array[index]
    index = index + 1
    local arrayindex = 0
    while true do
        local val = config_array[index]
        index = index + 1
        if val == "\n" then
            break
        end
        arrayindex = arrayindex + 1
        config_val[arrayindex] = val
    end
    return type, index, arrayindex
end

function csvconfig_generatescriptid()
	m_scriptid = m_scriptid + 1
	return m_scriptid
end

function csvconfig_lambda(configlambda, type)
    if configlambda ~= nil then
        local actioncount = configlambda.actioncount
        for i=1,actioncount do
            local sublambda = configlambda[i]
            if c_isaction(sublambda, type) then
                return sublambda
            end
        end
    end
    return nil
end

function csvconfig_getsubcount(strlambda)
    local count = 1
    for i=1,#strlambda do
        local strbyte = string.byte(strlambda,i,i)
        if strbyte == m_split_byte_comma then
            count = count + 1
        end
    end
    return count
end

function csvconfig_getsubvalue(strlambda, index, variabletype)
    local varstart = 1
    local varend = #strlambda
    if index > 1 then
        local findindex = 1
        for i=varstart, varend do
            local strbyte = string.byte(strlambda,i,i)
            if strbyte == m_split_byte_comma then
                findindex = findindex + 1
                if findindex == index then
                    varstart = i + 1
                    break
                end
            end
        end
        if findindex ~= index then
            return nil
        end
    end
    for i=varstart,varend do
        local strbyte = string.byte(strlambda,i,i)
        if strbyte == m_split_byte_comma then
            varend = i - 1
            break
        end
    end
    if variabletype == configsubtype.str then
        if varstart == 1 and varend == #strlambda then
            return strlambda
        else
            return string.sub(strlambda, varstart, varend)
        end
    elseif variabletype == configsubtype.int then
        local val = 0
        local nag = false
        for j=varstart,varend do
            local strbyte2 = string.byte(strlambda,j,j)
            if strbyte2 == m_split_byte_nag then
                nag = true
            elseif strbyte2 >= m_split_byte_0 and strbyte2 <= m_split_byte_9 then
                val = val * 10 + strbyte2 - m_split_byte_0
            else
                break
            end
        end
        if nag then
            val = -val
        end
        return val
    elseif variabletype == configsubtype.hex then
        local val = 0
        for j=varstart,varend do
            local strbyte2 = string.byte(strlambda,j,j)
            if strbyte2 >= 48 and strbyte2 <= 57 then
                val = val * 16 + (strbyte2 - 48)
            elseif strbyte2 >= 65 and strbyte2 <= 70 then
                val = val * 16 + (strbyte2 - 55)
            elseif strbyte2 >= 97 and strbyte2 <= 102 then
                val = val * 16 + (strbyte2 - 87)
            else
                val = val * 16
            end
        end
        return val
    elseif variabletype == configsubtype.flt then
        local val = 0.0
        local frac = 0
        local nag = false
        for j=varstart,varend do
            local strbyte2 = string.byte(strlambda,j,j)
            if strbyte2 == m_split_byte_nag then
                nag = true
            elseif strbyte2 >= m_split_byte_0 and strbyte2 <= m_split_byte_9 then
                if frac > 0 then
                    val = val + (strbyte2 - m_split_byte_0) * frac
                    frac = frac * 0.1
                else
                    val = val * 10 + strbyte2 - m_split_byte_0
                end
            elseif strbyte2 == m_split_byte_point then
                frac = 0.1
            else
                break
            end
        end
        if nag then
            val = -val
        end
        return val
    end
	return nil
end
