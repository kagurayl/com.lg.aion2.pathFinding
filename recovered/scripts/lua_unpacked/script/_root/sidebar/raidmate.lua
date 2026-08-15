
local m_raidmate_inst = { teammate = "sidebar/inst_teammate", teambutton = "sidebar/inst_teambutton" }

function raid_mate_open()
    m_uisidebar_main:setwidgetvisible("tab_team", true)
    m_uisidebar_main.list_mate:setclickdelegate(raid_mate_click)
end

function raid_mate_close()
    m_uisidebar_main:setwidgetvisible("tab_team", false)
end

function raid_mate_updatevalue()
    if m_uisidebar_main:null() or playerattr_raid == nil then
        return
    end
    local list_mate = m_uisidebar_main.list_mate
    for i=1,list_mate:getcount() do
        local line = list_mate:getlinefromindex(i)
        if line.linetype == teamlinetype.mate then
            local playerid = line:getdata()
            local actor = actormanager_getfromactorid(playerid)
            if actor ~= nil then
                local mate = playerpal_getraidmatefromplayerid(playerid)
                local online = 1
                if mate ~= nil then
                    online = mate.online
                end
                team_mate_setmatevalue(line, online, true, actor.actionmain.buffhasdebuff
                , actor.attrdisplay.hp, actor.attrdisplay.hpanim, actor.attrdisplay.hpmax
                , actor.attrdisplay.mp, actor.attrdisplay.mpanim, actor.attrdisplay.mpmax
                , actor.attr.fp, actor.attr.fpmax, actor.attr.movetype == playermovestate.glide or actor.attr.movetype == playermovestate.fly)
                playerbuff_updateactorui(actor, line)
            else
                local mate = playerpal_getraidmatefromplayerid(playerid)
                if mate ~= nil then
                    team_mate_setmatevalue(line, mate.online, false, false, mate.hp, mate.hp, mate.hpmax, mate.mp, mate.mp, mate.mpmax, mate.fp, mate.fpmax, mate.flying > 0)
                    playerbuff_updateactorui(nil, line)
                end
            end
        end
    end
end

function raid_mate_updateui()
    if m_uisidebar_main:null() or playerattr_raid == nil then
        return
    end
    local list_mate = m_uisidebar_main.list_mate
    list_mate:savestate()
    list_mate:clear()

    local groupindex = 0
    for i=1,#playerattr_raid.mate do
		if playerattr_raid.mate[i].playerid == playerattr_info.actorid then
			groupindex = teamraid_getgroup(playerattr_raid.mate[i].index + 1)
            break
		end
	end
    if groupindex == 0 then
        return
    end
    local matearray = {}
    local startindex = (groupindex - 1) * team_raid_groupmate
    for i=1,team_raid_groupmate do
        local mate = playerpal_getraidmatefromindex(i + startindex)
        if mate ~= nil then
            team_mate_addmate(mate.playerid, mate.name, mate.level, mate.career, playerattr_raid.leader)
        end
    end
    raid_mate_updatevalue()

    list_mate:restorestate()
end

function raid_mate_click(line, event, quest)
    if line.linetype == teamlinetype.mate then
        local playerid = line:getdata()
        local showmenu = playerid == playerattr_teamselect
        local actor = actormanager_getfromactorid(playerid)
        if actor ~= nil then
            showmenu = playerid == m_selectactorid
            actormanager_selectactor(actor)
        end
        if playerattr_teamselect ~= playerid then
            playerattr_teamselect = playerid
            raid_mate_updateui()
            itemmenu_close()
        elseif showmenu then
            local mate = playerpal_getraidmatefromplayerid(playerid)
            itemmenu_reset(playerid)
            if mate ~= nil then
                if mate.playerid ~= playerattr_info.actorid and playerattr_raid.leader == playerattr_info.actorid then
                    itemmenu_addbutton("PLAYER_RBMENU_RAIDLEADER", raid_menu_button_raidleader)
                    itemmenu_addbutton("PLAYER_RBMENU_RAIDKICK", raid_menu_button_raidkick)
                end
                itemmenu_addbutton("PLAYER_RBMENU_RAIDUI", raid_menu_button_raidui)
            end
            --itemmenu_addbutton("PLAYER_RBMENU_TEAMPICKMODE", raid_menu_button_pickmode)
            itemmenu_addbutton("PLAYER_RBMENU_RAIDLEAVE", raid_menu_button_leave)
            local x,y,w,h = line.image_select:getabsolute()
            itemmenu_open(x + w, y + h / 2, m_uisidebar_main)
        end
    end
end

function raid_mate_leader_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidLeader"}
        msg.playerid = data
        c_send(msg)
    end
end
function raid_menu_button_raidleader(data)
    local mate = playerpal_getraidmatefromplayerid(data)
    if mate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_LEADER_CONFIRMTEXT", mate.name)
        messagebox_confirm(confirmtext, raid_mate_leader_confirm, mate.playerid)
    end
end

function raid_mate_kick_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidKick"}
        msg.playerid = data
        c_send(msg)
    end
end
function raid_menu_button_raidkick(data)
    local mate = playerpal_getraidmatefromplayerid(data)
    if mate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_KICK_CONFIRMTEXT_RAID", mate.name)
        messagebox_confirm(confirmtext, raid_mate_kick_confirm, mate.playerid)
    end
end

function raid_menu_button_raidui(data)
    raid_main_open()
end

function raid_mate_leave_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidLeave"}
        c_send(msg)
    end
end
function raid_menu_button_leave(data)
    messagebox_confirm("TEAM_MATE_LEAVE_CONFIRMTEXT_RAID", raid_mate_leave_confirm)
end

function raid_menu_button_pickmode(data)
    team_setpickitem_open()
end
