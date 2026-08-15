
local m_debugenable = false
local m_debugmemory = nil

local function debuginput_collectasset(key, func)
    -- local json = {}
    -- json.command = "sancmuteserver"
    -- json.message = "sancmuteserver"
    -- c_sendjson(c_config_table2json(json))
    -- debugasset_collect()
    -- debugerror(collectgarbage("count") .. " KB")
    -- debugdllmemory()
end

local function debuginput_printquestcomplete()
    for key, val in pairs(playerattr_questcomplete) do
		local config_quest = csvquest_getfromid(key)
        if config_quest ~= nil then
            debugerror(config_quest.name)
        end
	end
end

function debuginput_init()
    m_debugenable = true
end

function debuginfo()
    if m_selectactor ~= nil then
        if m_selectactor:isnpc() then
            debugerror(m_selectactor.actorid)
            debugerror(m_selectactor.id)
            debugerror(m_selectactor.config_npc.id)
            debugerror(m_selectactor.attr.posx)
            debugerror(m_selectactor.attr.posy)
            debugerror(m_selectactor.attr.posz)
            local script = csvnpc_getscript(m_selectactor.config_npc, "pattern")
            if script ~= nil then
                debugerror("pattern:" .. script.variable[1].str)
            end
            local dialog = csvnpc_getscript(m_selectactor.config_npc, "dialog")
            if dialog ~= nil then
                debugerror("dialog:" .. dialog.variable[1].str)
            end
            senddebugcommand("@npcinfo " .. m_selectactor.actorid)
        end
    end
end

function senddebugcommand(str)
    local msg = {messageid = "CS_Chat"}
    msg.channel = m_chatinput_channel
    msg.whisperid = m_chatinput_whisper
    msg.text = str
    c_send(msg)
end

function debugcommand(str)
    if debuglocalcommand(str) then
        return
    end
    if str == "@kill" then
        str = str .. " " .. m_selectactorid
        senddebugcommand(str)
        return
    end
    if str == "@killenemy" then
        local actorlist = actormanager_getactorlist()
        for key, actor in pairs(actorlist) do
            if actor:isnpc() and actor:isenemy() then
                senddebugcommand("@kill " .. actor.actorid)
            end
        end
        return
    end
    if string.startwith(str, "@target") then
        str = str .. " " .. m_selectactorid
        senddebugcommand(str)
        return
    end
    senddebugcommand(str)
end

function debugfloodnpc(count, range)
    local config_npcarray = c_config_getmetaall(configid.npc)
    for i=1,count do
        local config_npc = config_npcarray[math.random(1, #config_npcarray)]
        local posx = playerattr_info.posx + (math.random() * 2.0 - 1.0) * range
        local posy = playerattr_info.posy
        local posz = playerattr_info.posz + (math.random() * 2.0 - 1.0) * range
        local str = string.format("@npcpos %d %d %d %d", config_npc.id, posx, posy, posz)
        senddebugcommand(str)
    end
end

function debuglocalcommand(str)
    if str == "@hermespos" then
        if m_me == nil then
            debugerror("HERMES_XYZ NO_PLAYER")
        else
            debugerror(string.format("HERMES_XYZ %.9f %.9f %.9f", m_me.transform.px, m_me.transform.py, m_me.transform.pz))
        end
        return true
    end
    if string.startwith(str, "@hermespath") then
        local x, y, z = string.match(str, "^@hermespath%s+([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)$")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if m_me == nil or x == nil or y == nil or z == nil then
            debugerror("HERMES_PATH INVALID")
            return true
        end
        local sx, sy, sz = c_scene_worldtonavigation(m_me.transform.px, m_me.transform.py, m_me.transform.pz, 200)
        local tx, ty, tz = c_scene_worldtonavigation(x, y, z, 200)
        if sx == nil or tx == nil then
            debugerror("HERMES_PATH NO_NAVIGATION")
            return true
        end
        debugerror(string.format("HERMES_NAV START %.9f %.9f %.9f TARGET %.9f %.9f %.9f", sx, sy, sz, tx, ty, tz))
        local path = c_scene_path(sx, sy, sz, tx, ty, tz)
        if path == nil or #path == 0 then
            debugerror("HERMES_PATH EMPTY")
            return true
        end
        inputmove_setpath(path)
        debugerror(string.format("HERMES_PATH OK %d %.9f %.9f %.9f", #path, tx, ty, tz))
        return true
    end
    if string.startwith(str, "@hermesdirect") then
        local x, y, z = string.match(str, "^@hermesdirect%s+([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)$")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if m_me == nil or x == nil or y == nil or z == nil then
            debugerror("HERMES_DIRECT INVALID")
            return true
        end
        inputmove_sethermesdirect(x, y, z)
        debugerror(string.format("HERMES_DIRECT OK %.9f %.9f %.9f", x, y, z))
        return true
    end
    if string.startwith(str, "@hermesteleport") then
        local x, y, z = string.match(str, "^@hermesteleport%s+([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)$")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if m_me == nil or x == nil or y == nil or z == nil then
            debugerror("HERMES_TELEPORT INVALID")
            return true
        end
        inputmove_setpath(nil)
        m_me.move.inputmove_x = 0
        m_me.move.inputmove_y = 0
        m_me.move.inputmove_z = 0
        m_me:setactorposition(x, y, z, m_me.attr.rot)
        m_me:movesendsync(true)
        debugerror(string.format("HERMES_TELEPORT OK %.9f %.9f %.9f", m_me.transform.px, m_me.transform.py, m_me.transform.pz))
        return true
    end
    if string.startwith(str, "@hermespacketwalk") then
        local x, y, z = string.match(str, "^@hermespacketwalk%s+([%-%d%.]+)%s+([%-%d%.]+)%s+([%-%d%.]+)$")
        x, y, z = tonumber(x), tonumber(y), tonumber(z)
        if m_me == nil or x == nil or y == nil or z == nil then
            debugerror("HERMES_PACKETWALK INVALID")
            return true
        end
        if m_me.attr.movetype ~= playermovestate.move or not m_me.transform.onfloor then
            debugerror("HERMES_PACKETWALK NOT_GROUND")
            return true
        end
        inputmove_sethermespacketwalk(x, y, z)
        debugerror(string.format("HERMES_PACKETWALK START %.9f %.9f %.9f", x, y, z))
        return true
    end
    if str == "@hermeswalkstop" then
        inputmove_stophermespacketwalk()
        debugerror("HERMES_PACKETWALK STOP")
        return true
    end
    if string.startwith(str, "@questauto") then
        debugquest(string.sub(str, 12))
        return true
    end
    if string.startwith(str, "@questaddcraftingpart") then
        debugrecipepart()
        return true
    end
    if string.startwith(str, "@info") then
        debuginfo()
        return true
    end
    if string.startwith(str, "@disconnectrelogin") then
        c_disconnect()
        gameserver_getverify().uuid = 0
        return true
    end
    if string.startwith(str, "@disconnect") then
        c_disconnect()
        return true
    end
    if string.startwith(str, "@mem") then
        collectgarbage("collect")
        debugerror(collectgarbage("count") .. " KB")
        if snapshot ~= nil then
            if m_debugmemory ~= nil then
                local memory = snapshot.snapshot(_G, "_G")
                local diff = snapshot.incr(m_debugmemory, memory)
                snapshot.to_jsonfilefmt(diff, "D:/mem.txt")
                m_debugmemory = nil
            else
                m_debugmemory = snapshot.snapshot(_G, "_G")
                debugerror("snapshot start")
            end
        end
        return true
    end
    if str == "@flood" then
        zergflood_create(1, 1000)
        c_floodclone(true)
        return true
    end
    if str == "@floodclone" then
        c_floodclone(false)
        return true
    end
    if str == "@floodnpc" then
        debugfloodnpc(100, 10)
        return true
    end
    if str == "@questlist" then
        debuginput_printquestcomplete()
        return true
    end
    return false
end

function debuginput_getenable()
    return m_debugenable
end
