
include("overview/playerattrview")
include("overview/playerequip")
include("overview/playertitle")
include("overview/playeranim")
include("overview/playerpvp")
include("overview/playerquery")
include("overview/playervip")

local overviewtab = 
{
    equip = 1,
    title = 2,
    anim = 3,
    pvp = 4,
    vip = 5,
}
local m_overview_tab = overviewtab.equip
m_uioverview_playermain = uipanel_createhandle("overview/player_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft), AudioOpenUI, AudioCloseUI)

function player_main_onopen()
    m_uioverview_playermain:setwidgetdelegate("image_bg/button_close", player_main_delegate_close)
    
    local button_equip = m_uioverview_playermain:getwidget("button_equip")
    button_equip:settext("PLAYER_INFO_EQUIPTAB")
    button_equip:setdelegate(player_main_delegate_equip)

    local button_title = m_uioverview_playermain:getwidget("button_title")
    button_title:settext("PLAYER_INFO_TITLETAB")
    button_title:setdelegate(player_main_delegate_title)

    local button_anim = m_uioverview_playermain:getwidget("button_anim")
    button_anim:settext("PLAYER_INFO_ANIMTAB")
    button_anim:setdelegate(player_main_delegate_anim)

    local button_pvp = m_uioverview_playermain:getwidget("button_pvp")
    button_pvp:settext("PLAYER_INFO_PVPTAB")
    button_pvp:setdelegate(player_main_delegate_pvp)

    local button_vip = m_uioverview_playermain:getwidget("button_vip")
    button_vip:settext("PLAYER_INFO_VIPTAB")
    button_vip:setdelegate(player_main_delegate_vip)

    playerequip_onopen()
    playertitle_onopen()
    playeranim_onopen()
    playervip_onopen()
    player_main_updateui()
    event_register(bit.bor(eventtype.item, eventtype.playerinfo), player_main_updateui, m_uioverview_playermain)
end

function player_main_updateui()
    if m_uioverview_playermain:null() then
        return
    end

    local text_playername = m_uioverview_playermain:getwidget("tab_equip/text_playername")
    text_playername:settext(playerattr_info.name)

    local text_playerevel = m_uioverview_playermain:getwidget("tab_equip/text_playerevel")
    text_playerevel:settext("PLAYER_INFO_LEVEL", playerattr_info.level, c_textformat(playercareertext[playerattr_info.career]))

    m_uioverview_playermain:setwidgetenable("button_equip", m_overview_tab ~= overviewtab.equip)
    m_uioverview_playermain:setwidgetenable("button_title", m_overview_tab ~= overviewtab.title)
    m_uioverview_playermain:setwidgetenable("button_anim", m_overview_tab ~= overviewtab.anim)
    m_uioverview_playermain:setwidgetenable("button_pvp", m_overview_tab ~= overviewtab.pvp)
    m_uioverview_playermain:setwidgetenable("button_vip", m_overview_tab ~= overviewtab.vip)
    m_uioverview_playermain:setwidgetvisiblenothit("tab_equip", m_overview_tab == overviewtab.equip)
    m_uioverview_playermain:setwidgetvisiblenothit("tab_title", m_overview_tab == overviewtab.title)
    m_uioverview_playermain:setwidgetvisiblenothit("tab_anim", m_overview_tab == overviewtab.anim)
    m_uioverview_playermain:setwidgetvisiblenothit("tab_pvp", m_overview_tab == overviewtab.pvp)
    m_uioverview_playermain:setwidgetvisiblenothit("tab_vip", m_overview_tab == overviewtab.vip)
    if m_overview_tab == overviewtab.equip then
        playerequip_updateui()
    elseif m_overview_tab == overviewtab.title then
        playertitle_updateui()
    elseif m_overview_tab == overviewtab.anim then
        playeranim_updateui()
    elseif m_overview_tab == overviewtab.pvp then
        playerpvp_updateui()
    elseif m_overview_tab == overviewtab.vip then
        playervip_updateui()
    end
end

function player_main_delegate_equip()
    m_overview_tab = overviewtab.equip
    player_main_updateui()
end

function player_main_delegate_title()
    m_overview_tab = overviewtab.title
    player_main_updateui()
end

function player_main_delegate_anim()
    m_overview_tab = overviewtab.anim
    player_main_updateui()
end

function player_main_delegate_pvp()
    m_overview_tab = overviewtab.pvp
    player_main_updateui()
end

function player_main_delegate_vip()
    m_overview_tab = overviewtab.vip
    player_main_updateui()
end

function player_main_delegate_close()
    m_uioverview_playermain:close()
    tutorial_start(tutorialid.playerinfo)
end
