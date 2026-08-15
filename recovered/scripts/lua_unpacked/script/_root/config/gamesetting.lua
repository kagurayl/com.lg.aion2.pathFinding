
local m_localsettingfile = "playerconfig/localsetting.txt"
local m_gamesetting = nil

local function setting_toarray(setting)
    local array = {}
    local index = 1
    while setting[index] ~= nil do
        array[index] = setting[index]
        index = index + 1
    end
    return array
end

local function setting_set(config, textkey, default, uidata, savedb, toarray)
    if default ~= nil then
        if type(default) == "table" then
            default = c_config_table2json(default)
        else
            default = tostring(default)
        end
    end
    local current = nil
    if config ~= nil then
        current = config[textkey]
        if current ~= nil then
            if type(current) == "table" then
                if toarray then
                    current = setting_toarray(current)
                end
                current = c_config_table2json(current)
            else
                if toarray then
                    current = c_config_json2table(current)
                    if current ~= nil then
                        current = setting_toarray(current)
                        if #current < 100 then
                            current = c_config_table2json(current)
                        else
                            current = nil
                        end
                    else
                        current = {}
                    end
                else
                    current = tostring(current)
                end
            end
        end
        config[textkey] = nil
    end
    if current == nil then
        current = default
    end
    local setting = {}
    setting.name = textkey
    setting.default = default
    setting.store = current
    setting.current = current
    setting.savedb = savedb
    setting.data = uidata
    m_gamesetting[textkey] = setting
    return setting
end

local function setting_setlocal(config, textkey, default, uidata)
    setting_set(config, textkey, default, uidata, false, false)
end

local function setting_setplayer(config, textkey, default, uidata)
    setting_set(config, textkey, default, uidata, true, false)
end

local function setting_setplayerarray(config, textkey, default, uidata)
    setting_set(config, textkey, default, uidata, true, true)
end

function gamesetting_loadlocal()
    m_gamesetting = {}
    local defaultlanguage = c_system_cmdline("language")
    if defaultlanguage == nil then
        defaultlanguage = "cn"
        local sdklanguage = c_system_sdk("InstallerLanguage")
        if sdklanguage ~= nil and string.len(sdklanguage) > 0 then
            defaultlanguage = sdklanguage
        end
    end
    local systemlocale = "en_US"
    if defaultlanguage == "cn" then
        systemlocale = "zh_CN.UTF-8"
    end
    c_system_setlocale(systemlocale)

    local localconfig = c_config_loadtable(m_localsettingfile)
    setting_setlocal(localconfig, "ENVMUSICVOLUME", 0.4, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "ENVSOUNDVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "MUSICVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "UIVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "SKILLVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "VOICEVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "ALERTVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "DEVICEVOLUME", 1, {min = 0.0, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "BATTLEMUSIC", 0)
    setting_setlocal(localconfig, "PETAUDIO", 1)

    setting_setlocal(localconfig, "OVERALL", 3)
    setting_setlocal(localconfig, "ANTIALIASING", 3)
    setting_setlocal(localconfig, "SHADOW", 3)
    setting_setlocal(localconfig, "TEXTURE", 3)
    setting_setlocal(localconfig, "SYSTEMFPS", 1)
    setting_setlocal(localconfig, "CAMERASHAKE", 1)
    setting_setlocal(localconfig, "FPSLIMIT", 0.05, {min = 20, max = 220})
    setting_setlocal(localconfig, "CAMERAFOV", 0, {min = 30, max = 60})
    setting_setlocal(localconfig, "UISCALE", 1, {min = 0.5, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "MAPOPACITY", 1, {min = 0.2, max = 1.0, perc = 1})
    setting_setlocal(localconfig, "ENEMYPLAYERACTOR", 1)
    setting_setlocal(localconfig, "ENEMYNPCACTOR", 1)
    setting_setlocal(localconfig, "SIPIDPLAYERACTOR", 1)
    setting_setlocal(localconfig, "SIPIDNPCACTOR", 1)
    setting_setlocal(localconfig, "TEAMACTOR", 1)

    setting_setlocal(localconfig, "CAMERARANGE", 0, {min = 1, max = 1.5, perc = 1})
    setting_setlocal(localconfig, "CAMERASPEED", 0.2, {min = 0.5, max = 2, perc = 1})
    setting_setlocal(localconfig, "CAMERAFLIPV", 0)
    setting_setlocal(localconfig, "CAMERADIST", 20)
    setting_setlocal(localconfig, "CAMERAPITCH", 10)
    setting_setlocal(localconfig, "CAMERAYAW", 270)
    setting_setlocal(localconfig, "ORIENTATION", 0)

    setting_setlocal(localconfig, "LANGUAGE", defaultlanguage)

    local language = m_gamesetting["LANGUAGE"]
    c_textloadstring("config/string_" .. language.current .. ".txt")
    language.loadlanguage = language.current
    
    settingapply_uiscale(m_gamesetting["UISCALE"], false)
    settingapply_antialiasing(m_gamesetting["ANTIALIASING"], false)
    settingapply_shadow(m_gamesetting["SHADOW"], false)
    settingapply_texture(m_gamesetting["TEXTURE"], false)
    settingapply_fpslimit(m_gamesetting["FPSLIMIT"], false)
    settingapply_camerafov(m_gamesetting["CAMERAFOV"], false)
    settingapply_camerarange(m_gamesetting["CAMERARANGE"], false)
    audiomanager_updatevolume()
end

function gamesetting_loadplayer(playerconfig)
    setting_setplayer(playerconfig, "PLAYERNAME", 1)
    setting_setplayer(playerconfig, "TEAMNAME", 1)
    setting_setplayer(playerconfig, "RAIDNAME", 1)
    setting_setplayer(playerconfig, "FLOCKNAME", 1)
    setting_setplayer(playerconfig, "SIPIDNAME", 1)
    setting_setplayer(playerconfig, "ENEMYNAME", 1)
    setting_setplayer(playerconfig, "NPCNAME", 1)
    setting_setplayer(playerconfig, "MONSTERNAME", 1)
    setting_setplayer(playerconfig, "TITLE", 1)
    setting_setplayer(playerconfig, "PVPTITLE", 0)
    setting_setplayer(playerconfig, "ICCNAME", 1)
    setting_setplayer(playerconfig, "TEAMME", 1)
    setting_setplayer(playerconfig, "NORMALQUEST", 1)
    setting_setplayer(playerconfig, "LOWLEVELQUEST", 0)
    setting_setplayer(playerconfig, "RENDERHELMET", 1)
    setting_setplayer(playerconfig, "RENDEREMBLEM", 0)
    setting_setplayer(playerconfig, "REFUSEQUERY", 0)
    setting_setplayer(playerconfig, "REFUSEDEAL", 0)
    setting_setplayer(playerconfig, "REFUSETEAM", 0)
    setting_setplayer(playerconfig, "REFUSEICC", 0)
    setting_setplayer(playerconfig, "REFUSEPAL", 0)
    setting_setplayer(playerconfig, "REFUSEPK", 0)
    setting_setplayer(playerconfig, "MANUALMOVEIN", 0)
    setting_setplayer(playerconfig, "MOVEBACK", 0)
    setting_setplayer(playerconfig, "ATTACKSHOCK", 1)
    setting_setplayer(playerconfig, "MAPSHOWNPC", 1)
    setting_setplayer(playerconfig, "MAPSHOWQUEST", 1)
    setting_setplayer(playerconfig, "MINIMAPSCALE", 1)
    setting_setplayer(playerconfig, "SHORTCUTPAGE", 1)
    setting_setplayer(playerconfig, "ACTIONLINE2", 0)
    setting_setplayer(playerconfig, "ACTIONLINE3", 0)
    setting_setplayer(playerconfig, "ACTIONLINE4", 0)
    setting_setplayer(playerconfig, "HIDEEMPTYSKILLBAR", 0)
    setting_setplayer(playerconfig, "TABENEMYNPC", 1)
    setting_setplayer(playerconfig, "TABENEMYPLAYER", 1)
    setting_setplayer(playerconfig, "TABSIPIDNPC", 1)
    setting_setplayer(playerconfig, "TABSIPIDPLAYER", 1)
    setting_setplayer(playerconfig, "TABENEMYNPCDEAD", 1)
    setting_setplayer(playerconfig, "TABSIPIDPLAYERDEAD", 1)
    setting_setplayer(playerconfig, "TABHARVEST", 1)

    setting_setplayer(playerconfig, "KEY_MOVEFORWARD", "W")
    setting_setplayer(playerconfig, "KEY_MOVEBACKWARD", "S")
    setting_setplayer(playerconfig, "KEY_MOVELEFT", "A")
    setting_setplayer(playerconfig, "KEY_MOVERIGHT", "D")
    setting_setplayer(playerconfig, "KEY_FLYUP", "R")
    setting_setplayer(playerconfig, "KEY_FLYDOWN", "F")
    setting_setplayer(playerconfig, "KEY_JUMP", "Space")
    setting_setplayer(playerconfig, "KEY_REST", ",")
    setting_setplayer(playerconfig, "KEY_ATTACK", "C")
    setting_setplayer(playerconfig, "KEY_SWITCHBATTLE", "T")
    setting_setplayer(playerconfig, "KEY_SWITCHEQUIP", "S+T")
    setting_setplayer(playerconfig, "KEY_BATTERY", "B")
    setting_setplayer(playerconfig, "KEY_SELECTENEMY", "Tab")
    setting_setplayer(playerconfig, "KEY_SELECTSIPID", "S+Tab")
    setting_setplayer(playerconfig, "KEY_SELECTPVPENEMY", "")
    setting_setplayer(playerconfig, "KEY_SELECTANY", "C+Tab")
    setting_setplayer(playerconfig, "KEY_SELECTSUBTARGET", "C+S+Tab")
    setting_setplayer(playerconfig, "KEY_SPIRITATTACK", "")
    setting_setplayer(playerconfig, "KEY_SPIRITMOVE", "")
    setting_setplayer(playerconfig, "KEY_SPIRITIDLE", "")
    setting_setplayer(playerconfig, "KEY_SPIRITDISMISS", "")
    setting_setplayer(playerconfig, "KEY_SELECTME", "F1")
    setting_setplayer(playerconfig, "KEY_SELECTMATE1", "F2")
    setting_setplayer(playerconfig, "KEY_SELECTMATE2", "F3")
    setting_setplayer(playerconfig, "KEY_SELECTMATE3", "F4")
    setting_setplayer(playerconfig, "KEY_SELECTMATE4", "F5")
    setting_setplayer(playerconfig, "KEY_SELECTMATE5", "F6")
    setting_setplayer(playerconfig, "KEY_CHATBOX", "Enter")
    setting_setplayer(playerconfig, "KEY_ESCAPE", "Escape")
    setting_setplayer(playerconfig, "KEY_UIOVERVIEW", "P")
    setting_setplayer(playerconfig, "KEY_UIBAG", "I")
    setting_setplayer(playerconfig, "KEY_UIQUEST", "J")
    setting_setplayer(playerconfig, "KEY_UISKILL", "K")
    setting_setplayer(playerconfig, "KEY_UIMAP", "M")
    setting_setplayer(playerconfig, "KEY_UIMAPOPACITY", "S+M")
    setting_setplayer(playerconfig, "KEY_UISTALL", "Y")
    setting_setplayer(playerconfig, "KEY_UIPETLIST", "")
    setting_setplayer(playerconfig, "KEY_UIPET", "")
    setting_setplayer(playerconfig, "KEY_UIPAL", "L")
    setting_setplayer(playerconfig, "KEY_UITEAM", "C+T")
    setting_setplayer(playerconfig, "KEY_UIRAID", "")
    setting_setplayer(playerconfig, "KEY_UIICC", "G")
    setting_setplayer(playerconfig, "KEY_UIRANK", "C+R")
    setting_setplayer(playerconfig, "KEY_UIDUNGEON", "U")

    for i=1,max_logo do
        setting_setplayer(playerconfig, "KEY_SETLOGO_" .. i, "")
        setting_setplayer(playerconfig, "KEY_SELECTELOGO_" .. i, "")
    end

	for i=1,skill_skillbarslotmax do
        local keyname = string.format("KEY_SKILL_%d", i)
        setting_setplayer(playerconfig, keyname, "")
	end

    setting_setplayer(playerconfig, "KEY_ACTION_1_1", "1")
    setting_setplayer(playerconfig, "KEY_ACTION_1_2", "2")
    setting_setplayer(playerconfig, "KEY_ACTION_1_3", "3")
    setting_setplayer(playerconfig, "KEY_ACTION_1_4", "4")
    setting_setplayer(playerconfig, "KEY_ACTION_1_5", "5")
    setting_setplayer(playerconfig, "KEY_ACTION_1_6", "6")
    setting_setplayer(playerconfig, "KEY_ACTION_1_7", "7")
    setting_setplayer(playerconfig, "KEY_ACTION_1_8", "8")
    setting_setplayer(playerconfig, "KEY_ACTION_1_9", "9")
    setting_setplayer(playerconfig, "KEY_ACTION_1_10", "0")
    for i=11,skill_actionbarslotmax do
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local keyname = string.format("KEY_ACTION_%d_%d", lineindex, slotindex)
    	setting_setplayer(playerconfig, keyname, "")
	end

    local chat_default_0 =
    {
        chatchanneltype.categorychat, chatchanneltype.chataoi, chatchanneltype.chatmap, chatchanneltype.chatemoji, chatchanneltype.chatrecvwhisper, chatchanneltype.chatsendwhisper,
        chatchanneltype.chatnpcsidpid, chatchanneltype.chatnpcenemy, chatchanneltype.chatteam, chatchanneltype.chatraid, chatchanneltype.chatraidmaster, chatchanneltype.chaticc,
        chatchanneltype.chatworld, chatchanneltype.chatdeal, chatchanneltype.chatrecruit, chatchanneltype.chatrumor, chatchanneltype.chathowlciv, chatchanneltype.chathowlall,
        chatchanneltype.categorysystem, chatchanneltype.systeminfo, chatchanneltype.systemwarning, chatchanneltype.systemabyss, chatchanneltype.systemteam,
        chatchanneltype.systemproduce, chatchanneltype.systemdeadself, chatchanneltype.systemdeadsipid, chatchanneltype.systemdeadenemy, 
        chatchanneltype.systemmoney, chatchanneltype.systemexp, chatchanneltype.systemitem, 
    }
    setting_setplayerarray(playerconfig, "CHATSETTING_0", chat_default_0)

    local chat_default_1 =
    {
        chatchanneltype.categorychat, chatchanneltype.chataoi, chatchanneltype.chatemoji, chatchanneltype.chatnpcsidpid, chatchanneltype.chatnpcenemy,
        chatchanneltype.categorysystem, chatchanneltype.systemwarning
    }
    setting_setplayerarray(playerconfig, "CHATSETTING_1", chat_default_1)

    local chat_default_2 =
    {
        chatchanneltype.categorychat, chatchanneltype.chatmap, chatchanneltype.chatcareer, chatchanneltype.chatworld, chatchanneltype.chatdeal,
        chatchanneltype.chatrecruit, chatchanneltype.chatrumor, chatchanneltype.chathowlciv, chatchanneltype.chathowlall,
        chatchanneltype.categorysystem, chatchanneltype.systemwarning
    }
    setting_setplayerarray(playerconfig, "CHATSETTING_2", chat_default_2)

    local chat_combatarray = { chatchanneltype.combatattack, chatchanneltype.combathurt, chatchanneltype.combatteamattack, chatchanneltype.combatteamhurt,
                            chatchanneltype.combatplayerattack, chatchanneltype.combatplayerhurt, chatchanneltype.combatnpcattack }
    local chat_default_3 = {}
    for i=1,#chat_combatarray do
        local combatcatagory = chat_combatarray[i]
        chat_default_3[#chat_default_3 + 1] = combatcatagory
        for j=chatbattletype.attack,chatbattletype.count do
            chat_default_3[#chat_default_3 + 1] = combatcatagory + j
        end
    end
    setting_setplayerarray(playerconfig, "CHATSETTING_3", chat_default_3)

    local chat_default_4 =
    {
        chatchanneltype.categorychat, chatchanneltype.chatrecvwhisper, chatchanneltype.chatsendwhisper, chatchanneltype.chatteam, chatchanneltype.chatraid,
        chatchanneltype.chatraidmaster, chatchanneltype.chatflock, chatchanneltype.chatflockmaster, chatchanneltype.chaticc,
        chatchanneltype.categorysystem, chatchanneltype.systemwarning
    }
    setting_setplayerarray(playerconfig, "CHATSETTING_4", chat_default_4)

    local chat_default_5 =
    {
        chatchanneltype.categorysystem, chatchanneltype.systeminfo, chatchanneltype.systemwarning, chatchanneltype.systemabyss,chatchanneltype.systemteam,
        chatchanneltype.systemproduce, chatchanneltype.systemdeadself, chatchanneltype.systemdeadsipid, chatchanneltype.systemdeadenemy,
        chatchanneltype.systemmoney, chatchanneltype.systemexp, chatchanneltype.systemitem
    }
    setting_setplayerarray(playerconfig, "CHATSETTING_5", chat_default_5)

    setting_setplayerarray(playerconfig, "CHATSETTING_6", {})
    setting_setplayerarray(playerconfig, "CHATSETTING_7", {})
    setting_setplayerarray(playerconfig, "CHATSETTING_8", {})
    setting_setplayerarray(playerconfig, "CHATSETTING_9", {})
    setting_setplayerarray(playerconfig, "CHATSETTING_10", {})

    setting_setplayerarray(playerconfig, "CHATSETTING_NAME", {"", "", "", "", ""})
    setting_setplayer(playerconfig, "CHATSETTING_COLOR", {})
    csvchat_loadsetting()
    csvchat_loadcolor()

    local msg = {messageid="CS_RemoveSetting"}
    msg.name = {}
    for name, setting in pairs(playerconfig) do
        msg.name[#msg.name + 1] = name
    end
    if #msg.name > 0 then
        c_send(msg)
    end
end

function gamesetting_saved(playerconfig)
    for key, value in pairs(playerconfig) do
        if value ~= nil and string.len(value) > 0 then
            if m_gamesetting[key] ~= nil then
                m_gamesetting[key].store = value
            end
        else
            if m_gamesetting[key] ~= nil then
                m_gamesetting[key].store = m_gamesetting[key].default
            end
        end
    end
end

function gamesetting_get()
    return m_gamesetting
end

function gamesetting_modify(name, val)
    local setting = m_gamesetting[name]
    if setting ~= nil then
        setting.current = val
        gamesetting_savesetting(setting)
    end
end

function gamesetting_savesetting(setting)
    if setting.current ~= nil then
        local type = type(setting.current)
        if type == "table" then
            setting.current = c_config_table2json(setting.current)
        elseif type ~= "string" then
            setting.current = tostring(setting.current)
        end
    else
        setting.current = ""
    end
    if setting.current == setting.store then
        return
    end
    setting.store = setting.current
    if setting.savedb then
        local info = {}
        info.name = setting.name
        if setting.current ~= setting.default then
            info.data = setting.current
        else
            info.data = ""
        end
        local playersetting = {}
        playersetting[#playersetting + 1] = info
        local msg = {messageid="CS_ModifySetting"}
        msg.setting = playersetting
        c_send(msg)
    else
        local localsetting = {}
        for name, setting2 in pairs(m_gamesetting) do
            if not setting2.savedb and setting2.current ~= setting2.default then
                localsetting[name] = setting2.current
            end
        end
        c_config_savetable(m_localsettingfile, localsetting)
    end
end

function gamesetting_savelocal()
    local localsetting = {}
    for name, setting in pairs(m_gamesetting) do
        if not setting.savedb then
            local type = type(setting.current)
            if type == "table" then
                setting.current = c_config_table2json(setting.current)
            elseif type ~= "string" then
                setting.current = tostring(setting.current)
            end
            if setting.current ~= setting.default then
                localsetting[name] = setting.current
            end
        end
    end
    c_config_savetable(m_localsettingfile, localsetting)
end

function gameseting_getval(name)
    if m_gamesetting[name] ~= nil then
        local val = m_gamesetting[name].current
        if val ~= nil then
            if type(val) == "string" then
                if #val > 0 then
                    return val
                else
                    return m_gamesetting[name].default
                end
            else
                return val
            end
        else
            return m_gamesetting[name].default
        end
    end
    return ""
end

function gamesetting_getkeyval(settingname)
    local setting = m_gamesetting[settingname]
    if setting.current ~= nil and #setting.current > 0 then
        return setting.current
    end
    for key2, val2 in pairs(m_gamesetting) do
        if string.startwith(key2, "KEY_") and val2.current == setting.default then
            return nil
        end
    end
    return setting.default
end

function gamesetting_getkeynamefromval(settingval)
    for key, val in pairs(m_gamesetting) do
        if string.startwith(key, "KEY_") and val.current == settingval then
            return key
        end
    end
    for key, val in pairs(m_gamesetting) do
        if string.startwith(key, "KEY_") and (val.current == nil or val.current == "") and val.default == settingval then
            return key
        end
    end
    return nil
end

function gamesetting_getnumber(name)
    return tonumber(gameseting_getval(name)) or 0
end

function gamesetting_getnumberdata(name)
    local setting = m_gamesetting[name]
    local val = nil
    if setting ~= nil then
        local current = setting.current
        if current ~= nil then
            if type(current) == "string" then
                if #current > 0 then
                    val = tonumber(current)
                else
                    val = tonumber(setting.default)
                end
            else
                val = current
            end
        else
            val = tonumber(setting.default)
        end
    end
    if val == nil then
        val = 0.0
    end
    if setting ~= nil and setting.data ~= nil then
         val = math.lerp(setting.data.min, setting.data.max, val)
    end
    return val
end

function gamesetting_gettable(name)
    local strsetting = gameseting_getval(name)
    if strsetting ~= nil then
        return c_config_json2table(strsetting)
    end
end
