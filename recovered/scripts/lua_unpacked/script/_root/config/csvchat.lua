
chatsetting_maxchannel = 10
chatfont_small = 24
chatfont_mid = 32
chatfont_large = 40
chathistroy_chat = 200
chathistroy_system = 200

chatchanneltype =
{
    categorychat = 0,
    chataoi = 1,
    chatmap = 2,
    chatemoji = 3,
    chatrecvwhisper = 4,
    chatsendwhisper = 5,
    chatnpcsidpid = 6,
    chatnpcenemy = 7,
    chatteam = 8,
    chatraid = 9,
    chatraidmaster = 10,
    chatflock = 11,
    chatflockmaster = 12,
    chaticc = 13,
	chatcareer = 14,
    chatworld = 15,
    chatdeal = 16,
    chatrecruit = 17,
    chatrumor = 18,
    chathowlciv = 19,
    chathowlall = 20,

    categorysystem = 100,
    systeminfo = 101,
    systemwarning = 102,
    systemabyss = 103,
    systemteam = 104,
    systemproduce = 105,
    systemdeadself = 106,
    systemdeadsipid = 107,
    systemdeadenemy = 108,
    systemexp = 109,
    systemmoney = 110,
    systemitem = 111,

    combatattack = 200,
    combathurt = 300,
    combatteamattack = 400,
    combatteamhurt = 500,
    combatplayerattack = 600,
    combatplayerhurt = 700,
    combatnpcattack = 800,
}

chatbattletype =
{
    attack = 1,
    critical = 2,
    skill = 3,
    skillbuff = 4,
    skillperiod = 5,
    defense = 6,
    count = 6,
}

local m_csvchat_channelcategory = {}
local m_csvchat_channeldefaultcolor = {}
local m_csvchat_channelsetting = nil
local m_csvchat_channelcolorsetting = nil

local function csvchat_setchannel(category, type, color)
    m_csvchat_channelcategory[type] = category
    m_csvchat_channeldefaultcolor[type] = color
end

function csvchat_load()
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chataoi, 0xffffff)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatmap, 0xf26522)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatemoji, 0xf2daad)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatrecvwhisper, 0xa0ffa0)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatsendwhisper, 0xa0ffa0)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatnpcsidpid, 0xc4dfff)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatnpcenemy, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatteam, 0x05c8d7)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatraid, 0x9ce7dc)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatraidmaster, 0xf7941d)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatflock, 0x75a8f4)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatflockmaster, 0xf7941d)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chaticc, 0x98ed11)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatcareer, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatworld, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatdeal, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatrecruit, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chatrumor, 0xffb1b1)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chathowlciv, 0xf7d02c)
    csvchat_setchannel(chatchanneltype.categorychat, chatchanneltype.chathowlall, 0xf26522)

    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systeminfo, 0xf7d02c)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemwarning, 0xff0000)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemabyss, 0xa0ffa0)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemteam, 0xf7d02c)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemproduce, 0xa0ffa0)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemdeadself, 0xff0000)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemdeadsipid, 0xffffff)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemdeadenemy, 0xfddaad)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemexp, 0x00ffff)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemmoney, 0xffff00)
    csvchat_setchannel(chatchanneltype.categorysystem, chatchanneltype.systemitem, 0xffff00)

    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.attack, 0xfffac7)
    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.critical, 0xfff200)
    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.skill, 0xfff769)
    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.skillbuff, 0xfff769)
    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.skillperiod, 0xff85ff)
    csvchat_setchannel(chatchanneltype.combatattack, chatchanneltype.combatattack + chatbattletype.defense, 0xff7f7f)

    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.attack, 0xff7f7f)
    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.critical, 0xff0000)
    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.skill, 0xff00ff)
    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.skillbuff, 0xffffff)
    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.skillperiod, 0xfff769)
    csvchat_setchannel(chatchanneltype.combathurt, chatchanneltype.combathurt + chatbattletype.defense, 0xffffff)

    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.attack, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.critical, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.skill, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.skillbuff, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.skillperiod, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamattack, chatchanneltype.combatteamattack + chatbattletype.defense, 0xffffff)

    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.attack, 0xff7f7f)
    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.critical, 0xff7f7f)
    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.skill, 0xff00ff)
    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.skillbuff, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.skillperiod, 0xffffff)
    csvchat_setchannel(chatchanneltype.combatteamhurt, chatchanneltype.combatteamhurt + chatbattletype.defense, 0xffffff)

    for i=1,chatbattletype.count do
        csvchat_setchannel(chatchanneltype.combatplayerattack, chatchanneltype.combatplayerattack + i, 0x38ff73)
        csvchat_setchannel(chatchanneltype.combatplayerhurt, chatchanneltype.combatplayerhurt + i, 0x38ff73)
        csvchat_setchannel(chatchanneltype.combatnpcattack, chatchanneltype.combatnpcattack + i, 0x38ff73)
    end
end

function csvchat_loadsetting()
    m_csvchat_channelsetting = {}
    for i=0,chatsetting_maxchannel do
        local namesetting = gamesetting_gettable("CHATSETTING_" .. i)
        if namesetting == nil then
            namesetting = {}
        end
        m_csvchat_channelsetting[i] = namesetting
    end
end

function csvchat_loadcolor()
    m_csvchat_channelcolorsetting = {}
    local setting = gamesetting_gettable("CHATSETTING_COLOR")
    if setting ~= nil then
        for key, val in pairs(setting) do
            local channeltype = math.tointegerfloor(key)
            m_csvchat_channelcolorsetting[channeltype] = val
        end
    end
end

function csvchat_getchannelcolorsetting()
    return m_csvchat_channelcolorsetting
end

function csvchat_getchannelcolor(channeltype)
    local setting = csvchat_getchannelcolorsetting()
    if setting ~= nil then
        local settingcolor = setting[channeltype]
        if settingcolor ~= nil then
            return settingcolor
        end
    end
    local channelcolor = m_csvchat_channeldefaultcolor[channeltype]
    if channelcolor ~= nil then
        return channelcolor
    end
    return 0xffffff
end

function csvchat_getchannelvisible(channelindex, channeltype)
    local channelsetting = m_csvchat_channelsetting[channelindex]
    if channelsetting ~= nil then
        local category = m_csvchat_channelcategory[channeltype]
        if category ~= nil then
            local categoryvisible = false
            for i=1,#channelsetting do
                if channelsetting[i] == category then
                    categoryvisible = true
                    break
                end
            end
            if not categoryvisible then
                return false
            end
        end
        for i=1,#channelsetting do
            if channelsetting[i] == channeltype then
                return true
            end
        end
    end
    return false
end

function csvchat_getchannelname(nameindex)
    local name = c_textformat("CHAT_SETTING_CHANNEL_" .. nameindex)
    if nameindex > 0 then
        local namesetting = gamesetting_gettable("CHATSETTING_NAME")
        if namesetting ~= nil and namesetting[nameindex] ~= nil then
            if #namesetting[nameindex] > 0 then
                name = namesetting[nameindex]
            end
        else
            name = nil
        end
    end
    return name
end
