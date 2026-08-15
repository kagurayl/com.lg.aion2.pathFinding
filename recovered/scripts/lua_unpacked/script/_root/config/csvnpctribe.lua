
local m_csv_npctribeid = nil
local m_csv_npctribe = nil
local m_csv_lighttribe = nil
local m_csv_darktribe = nil

local function csvnpctribe_split(tribestr)
    if tribestr == "0" then
        return
    end
    return string.split(tribestr, ";")
end

function csvnpctribe_load()
    m_csv_npctribeid = {}
    m_csv_npctribe = {}
    local tribearray = c_config_loadscriptarray(csvconfig_filename("npc_tribe"))
    for i=1,#tribearray do
        local npctribe = {}
        local tribe = tribearray[i]
        npctribe.name = tribe.tribe
        npctribe.basename = tribe.base
        npctribe.friendly = csvnpctribe_split(tribe.friendly)
        npctribe.neutral = csvnpctribe_split(tribe.neutral)
        npctribe.aggressive = csvnpctribe_split(tribe.aggressive)
        npctribe.hostile = csvnpctribe_split(tribe.hostile)
        m_csv_npctribeid[tribe.id] = npctribe
        m_csv_npctribe[npctribe.name] = npctribe
    end
    for key, val in pairs(m_csv_npctribe) do
		val.tribe = m_csv_npctribe[val.name]
        val.basetribe = m_csv_npctribe[val.basename]
	end
    m_csv_lighttribe = m_csv_npctribe["pc"]
    m_csv_darktribe = m_csv_npctribe["pc_dark"]
end

function csvnpctribe_getfromid(id)
    return m_csv_npctribeid[id]
end

function csvnpctribe_gettribe(name)
    return m_csv_npctribe[name]
end

local function csvnpctribe_contain(tribearray, name)
    if tribearray ~= nil then
        for i=1,#tribearray do
            if tribearray[i] == name then
                return true
            end
        end
    end
    return false
end

function csvnpctribe_getplayertribe()
    return playerattr_info.tribe
end

function csvnpctribe_isfriendly(config_npc)
    local player = csvnpctribe_getplayertribe()
    local npc = csvnpc_gettribe(config_npc)
    if npc == nil or player == nil then
        return false
    end
    if npc.basetribe ~= nil then
        if csvnpctribe_contain(npc.basetribe.friendly, player.name) then
            return true
        end
        if csvnpctribe_contain(player.friendly, npc.basename) then
            return true
        end
    end
    if csvnpctribe_contain(npc.friendly, player.name) then
        return true
    end
    if csvnpctribe_contain(player.friendly, npc.name) then
        return true
    end
    return false
end

function csvnpctribe_isneutral(config_npc)
    local player = csvnpctribe_getplayertribe()
    local npc = csvnpc_gettribe(config_npc)
    if npc == nil or player == nil then
        return false
    end
    if npc.basetribe ~= nil then
        if csvnpctribe_contain(npc.basetribe.neutral, player.name) then
            return true
        end
        if csvnpctribe_contain(player.neutral, npc.basename) then
            return true
        end
    end
    if csvnpctribe_contain(npc.neutral, player.name) then
        return true
    end
    if csvnpctribe_contain(player.neutral, npc.name) then
        return true
    end
    return false
end

function csvnpctribe_isaggressive(config_npc)
    local player = csvnpctribe_getplayertribe()
    local npc = csvnpc_gettribe(config_npc)
    if npc == nil or player == nil then
        return false
    end
    if npc.basetribe ~= nil then
        if csvnpctribe_contain(npc.basetribe.aggressive, player.name) then
            return true
        end
        if csvnpctribe_contain(player.aggressive, npc.basename) then
            return true
        end
    end
    if csvnpctribe_contain(npc.aggressive, player.name) then
        return true
    end
    if csvnpctribe_contain(player.aggressive, npc.name) then
        return true
    end
    return false
end

function csvnpctribe_ishostile(config_npc)
    local player = csvnpctribe_getplayertribe()
    local npc = csvnpc_gettribe(config_npc)
    if npc == nil or player == nil then
        return false
    end
    if npc.basetribe ~= nil then
        if csvnpctribe_contain(npc.basetribe.hostile, player.name) then
            return true
        end
        if csvnpctribe_contain(player.hostile, npc.basename) then
            return true
        end
    end
    if csvnpctribe_contain(npc.hostile, player.name) then
        return true
    end
    if csvnpctribe_contain(player.hostile, npc.name) then
        return true
    end
    return false
end

function csvnpctribe_isenemy(tribe)
    local player = csvnpctribe_getplayertribe()
    if player == nil or tribe == nil then
        return false
    end
    if tribe.basetribe ~= nil then
        if csvnpctribe_contain(tribe.basetribe.aggressive, player.name) or csvnpctribe_contain(tribe.basetribe.hostile, player.name) then
            return true
        end
        if csvnpctribe_contain(player.aggressive, tribe.basename) or csvnpctribe_contain(player.hostile, tribe.basename) then
            return true
        end
    end
    if csvnpctribe_contain(tribe.aggressive, player.name) or csvnpctribe_contain(tribe.hostile, player.name) then
        return true
    end
    if csvnpctribe_contain(player.aggressive, tribe.name) or csvnpctribe_contain(player.hostile, tribe.name) then
        return true
    end
    return false
end

function csvnpctribe_isnpcenemy(config_npc)
    return csvnpctribe_isenemy(csvnpc_gettribe(config_npc))
end
