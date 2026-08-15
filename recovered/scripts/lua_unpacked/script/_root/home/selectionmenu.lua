
local m_selectionmenu = uipanel_createhandle("selection/selectionmenu", uilayer.top, 0)
local m_selectionmenu_inst = {button = "selection/inst_menubutton", icon = "selection/inst_menuicon"}

function selectionmenu_onopen()
    local list_menu = m_selectionmenu:getwidget("list_menu")
    list_menu:init(uilistflag.vertical)
end

function selectionmenu_addbutton(list_menu, name, delegate)
    local line = list_menu:add(m_selectionmenu_inst.button, name, name)
    local button_normal = line:getwidget("button_normal")
    button_normal:settext(name)
    button_normal:setdelegate(delegate)
end

function selectionmenu_addicon(list_menu, iconindex)
    local line = list_menu:add(m_selectionmenu_inst.icon, iconindex, iconindex)
    local button_normal = line:getwidget("button_normal")
    button_normal:settext("PLAYER_RBMENU_LOGO")
    button_normal:setdelegate(selectionmenu_button_logo)
    button_normal.iconindex = iconindex

    local image_icon = line:getwidget("image_icon")
    image_icon:setspritesize("name/logo" .. iconindex, 0.7)
end

function selectionmenu_popmenu(actorid)
    local actor = actormanager_getfromactorid(actorid)
    if actor == nil then
        return
    end
    m_selectionmenu:open()
    m_selectionmenu:setwidgetdelegate("button_close", selectionmenu_button_close)
    local list_menu = m_selectionmenu:getwidget("list_menu")
    list_menu:clear()

    m_selectionmenu.actorid = actorid

    local text_name = m_selectionmenu:getwidget("text_name")
    text_name:settext(name)
    if actor:isplayer() then
        if actor.attr.civ == playerattr_info.civ then
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_WHISPER", selectionmenu_button_whisper)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_BLACKLIST", selectionmenu_button_blacklist)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_STALL", selectionmenu_button_stall)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_FOLLOW", selectionmenu_button_follow)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_DEAL", selectionmenu_button_deal)
            if playerattr_raid == nil then
                selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_TEAM", selectionmenu_button_team)
            end
            if playerattr_team == nil then
                selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_RAID", selectionmenu_button_raid)
            end
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_ICCINVITE", selectionmenu_button_icc)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_PAL", selectionmenu_button_pal)
            selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_PVP", selectionmenu_button_pvp)
        end
        selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_QUERY", selectionmenu_button_query)
    else
        selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_TALKNPC", selectionmenu_button_talknpc)
    end

    if m_selectactor ~= nil and m_selectactor.actordata.logo ~= nil then
        selectionmenu_addbutton(list_menu, "PLAYER_RBMENU_REMOVELOGO", selectionmenu_button_removelogo)
    end

    for i=1,max_logo do
        selectionmenu_addicon(list_menu, i)
    end
end

function selectionmenu_button_close()
    m_selectionmenu:close()
end

function selectionmenu_button_talknpc()
    npc_startscript(m_selectionmenu.actorid)
    m_selectionmenu:close()
end

function selectionmenu_button_removelogo()
    local msg = {messageid="CS_ActorLogo"}
    msg.logo = m_selectactor.actordata.logo
    msg.actorid = 0
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_logo(sender, event)
    local msg = {messageid="CS_ActorLogo"}
    msg.logo = sender.iconindex
    msg.actorid = m_selectactorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_whisper()
    local actor = actormanager_getfromactorid(m_selectionmenu.actorid)
    if actor ~= nil then
        chat_whisperto(m_selectionmenu.actorid, actor.attr.name)
    end
    m_selectionmenu:close()
end

function selectionmenu_blacklist_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PalAddBlackList"}
        msg.playerid = data
        c_send(msg)
    end
end
function selectionmenu_button_blacklist()
    local actor = actormanager_getfromactorid(m_selectionmenu.actorid)
    if actor ~= nil then
        local confirmtext = c_textformat("PAL_BLACKLIST_TEXT", actor.attr.name)
        messagebox_confirm(confirmtext, selectionmenu_blacklist_confirm, m_selectionmenu.actorid)
    end
    m_selectionmenu:close()
end

function selectionmenu_button_query()
    local msg = {messageid="CS_QueryPlayer"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_stall()
    local msg = {messageid="CS_StallQuery"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_follow()
    playerapproach_follow(m_selectionmenu.actorid, 1.0)
    m_selectionmenu:close()
end

function selectionmenu_button_deal()
    local msg = {messageid="CS_DealRequest"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_team()
    local msg = {messageid="CS_TeamInviteSend"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_raid()
    local msg = {messageid="CS_RaidInviteSend"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_icc()
    local msg = {messageid="CS_IccInviteSend"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_pal()
    local msg = {messageid="CS_PalRequestSend"}
    msg.playerid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end

function selectionmenu_button_pvp()
    local msg = {messageid="CS_DuelInvite"}
    msg.actorid = m_selectionmenu.actorid
    c_send(msg)
    m_selectionmenu:close()
end
