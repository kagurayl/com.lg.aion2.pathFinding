
teamlinetype = 
{
    button = 0,
    mate = 1,
    spirit = 2,
}

spiritstate = 
{
    attack = 0,
    move = 1,
    idle = 2,
    dismiss = 3,
}

m_uiraidmain = uipanel_createhandle("team/raid_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_uiraidmain_widget = {}
local m_uiraidmain_select = 0
local m_uiraidmain_pressindex = 0
local m_uiraidmain_presstime = nil
local m_uiraidmain_movingactorid = nil

function raid_main_open()
    m_uiraidmain:open()
    m_uiraidmain_select = 0
    m_uiraidmain_pressindex = 0
    m_uiraidmain_presstime = nil
    m_uiraidmain_movingactorid = nil
    m_uiraidmain:setwidgetvisible("image_movingcover", false)
    raid_main_updateui()
end

function raid_main_onopen()
    for i=1,team_raid_groupcount do
        local text_name = m_uiraidmain:getwidget(string.format("group_%d/text_name", i))
        text_name:settext("TEAM_RAID_TEAMN", i)
    end
    for i=1,team_raid_maxmate do
        local groupindex = teamraid_getgroup(i)
        local mateindex = math.tointegerfloor((i - 1) % team_raid_groupmate) + 1
        local widgetpath = string.format("group_%d/mate_%d/", groupindex, mateindex)
        local widgetlist = {}
        widgetlist.text_hp = m_uiraidmain:getwidget(widgetpath .. "text_hp")
        widgetlist.text_mp = m_uiraidmain:getwidget(widgetpath .. "text_mp")
        widgetlist.progress_hp = m_uiraidmain:getwidget(widgetpath .. "progress_hp")
        widgetlist.progress_hpanim = m_uiraidmain:getwidget(widgetpath .. "progress_hpanim")
        widgetlist.progress_hpdebuff = m_uiraidmain:getwidget(widgetpath .. "progress_hpdebuff")
        widgetlist.progress_hpdebuffanim = m_uiraidmain:getwidget(widgetpath .. "progress_hpdebuffanim")
        widgetlist.progress_mp = m_uiraidmain:getwidget(widgetpath .. "progress_mp")
        widgetlist.progress_mpanim = m_uiraidmain:getwidget(widgetpath .. "progress_mpanim")
        widgetlist.image_flytime = m_uiraidmain:getwidget(widgetpath .. "image_flytime")

        widgetlist.image_leader = m_uiraidmain:getwidget(widgetpath .. "image_leader")
        widgetlist.image_select = m_uiraidmain:getwidget(widgetpath .. "image_select")
        widgetlist.image_icon = m_uiraidmain:getwidget(widgetpath .. "image_icon")
        widgetlist.text_level = m_uiraidmain:getwidget(widgetpath .. "text_level")
        widgetlist.text_name = m_uiraidmain:getwidget(widgetpath .. "text_name")

        local image_event = m_uiraidmain:getwidget(widgetpath .. "image_event")
        image_event:setdelegate(raid_main_delegate_member)
        image_event.index = i
        m_uiraidmain_widget[i] = widgetlist
    end
    m_uiraidmain:setwidgetdelegate("checkbox_matemove", raid_main_delegate_matemove)
    m_uiraidmain:setwidgetdelegate("image_movingcover", raid_main_delegate_movecover)
    m_uiraidmain:setwidgetdelegate("button_moveto", raid_main_delegate_moveto)
    m_uiraidmain:setwidgetdelegate("button_leader", raid_main_delegate_setleader)
    m_uiraidmain:setwidgetdelegate("button_leave", raid_main_delegate_leave)
    m_uiraidmain:setwidgetdelegate("button_kick", raid_main_delegate_kick)
    m_uiraidmain:setwidgetdelegate("image_bg/button_close", raid_main_delegate_close)

    event_register(eventtype.update2, raid_main_updatevalue, m_uiraidmain)
end

local function raid_main_setcolor(widget, enable)
    if enable then
        widget:setcolor(1.0, 1.0, 1.0, 1.0)
    else
        widget:setcolor(0.4, 0.4, 0.4, 1.0)  
    end
end
local function raid_main_setmatevalue(widgetlist, online, insight, debuff, hp, hpanim, hpmax, mp, mpanim, mpmax, flytime, flytimemax, flying)
    if online > 0 then
        widgetlist.text_hp:settext(string.format("%d/%d", math.tointegerfloor(hp), math.tointegerfloor(hpmax)))
        widgetlist.text_mp:settext(string.format("%d/%d", math.tointegerfloor(mp), math.tointegerfloor(mpmax)))
        if debuff then
            widgetlist.progress_hp:setpercent(0.0)
            widgetlist.progress_hpanim:setpercent(0.0)
            widgetlist.progress_hpdebuff:setpercent(hp / hpmax)
            widgetlist.progress_hpdebuffanim:setpercent(hpanim / hpmax)
        else
            widgetlist.progress_hp:setpercent(hp / hpmax)
            widgetlist.progress_hpanim:setpercent(hpanim / hpmax)
            widgetlist.progress_hpdebuff:setpercent(0.0)
            widgetlist.progress_hpdebuffanim:setpercent(0.0)
        end
        
        widgetlist.progress_mp:setpercent(mp / mpmax)
        widgetlist.progress_mpanim:setpercent(mpanim / mpmax)
        widgetlist.image_flytime:setpercent(flytime / flytimemax)
        raid_main_setcolor(widgetlist.text_name, true)
        raid_main_setcolor(widgetlist.progress_hp, insight)
        raid_main_setcolor(widgetlist.progress_hpanim, insight)
        raid_main_setcolor(widgetlist.progress_mp, insight)
        raid_main_setcolor(widgetlist.progress_mpanim, insight)
        raid_main_setcolor(widgetlist.image_flytime, flying)
    else
        raid_main_setcolor(widgetlist.text_name, false)
        widgetlist.text_hp:settext("")
        widgetlist.text_mp:settext("")
        widgetlist.progress_hp:setpercent(0.0)
        widgetlist.progress_hpanim:setpercent(0.0)
        widgetlist.progress_hpdebuff:setpercent(0.0)
        widgetlist.progress_hpdebuffanim:setpercent(0.0)
        widgetlist.progress_mp:setpercent(0.0)
        widgetlist.progress_mpanim:setpercent(0.0)
        widgetlist.image_flytime:setpercent(0.0)
    end
end

function raid_main_updatevalue()
    if m_uiraidmain:null() then
        return
    end
    if playerattr_raid == nil then
        m_uiraidmain:close()
        return
    end

    for i=1,team_raid_maxmate do
        local mate = playerpal_getraidmatefromindex(i)
        local widgetlist = m_uiraidmain_widget[i]
        if mate ~= nil then
            local actor = actormanager_getfromactorid(mate.playerid)
            if actor ~= nil then
                raid_main_setmatevalue(widgetlist, mate.online, true, actor.actionmain.buffhasdebuff
                , actor.attrdisplay.hp, actor.attrdisplay.hpanim, actor.attrdisplay.hpmax
                , actor.attrdisplay.mp, actor.attrdisplay.mpanim, actor.attrdisplay.mpmax
                , actor.attr.fp, actor.attr.fpmax, actor.attr.movetype == playermovestate.glide or actor.attr.movetype == playermovestate.fly)
            else
                raid_main_setmatevalue(widgetlist, mate.online, false, false, mate.hp, mate.hp, mate.hpmax, mate.mp, mate.mp, mate.mpmax, mate.fp, mate.fpmax, mate.flying > 0)
            end
        else
            raid_main_setmatevalue(widgetlist, 0, false, false, 0, 0, 1, 0, 0, 1, 0, 1, false)
        end
    end
    if m_uiraidmain_presstime ~= nil and time_game - m_uiraidmain_presstime > 0.5 and m_uiraidmain_select == m_uiraidmain_pressindex and playerattr_raid.leader == playerattr_info.actorid then
        m_uiraidmain_presstime = nil
        local selectmate = playerpal_getraidmatefromindex(m_uiraidmain_pressindex)
        if selectmate ~= nil then
            m_uiraidmain_movingactorid = selectmate.playerid
            local text_tipsmoving = m_uiraidmain:getwidget("text_tipsmoving")
            text_tipsmoving:setvisible(true)
            text_tipsmoving:settext("TEAM_RAID_LEADERMOVEPLAYER", selectmate.name)

            m_uiraidmain:setwidgetvisible("image_movingcover", true)
        end
    end
end

function raid_main_updateui()
    if m_uiraidmain:null() then
        return
    end
    if playerattr_raid == nil then
        m_uiraidmain:close()
        return
    end

    local matecount = 0
    for i=1,team_raid_maxmate do
        local mate = playerpal_getraidmatefromindex(i)
        local widgetlist = m_uiraidmain_widget[i]
        widgetlist.image_select:setvisible(i == m_uiraidmain_select)
        if mate ~= nil then
            matecount = matecount + 1
            widgetlist.image_leader:setvisible(mate.playerid == playerattr_raid.leader)
            widgetlist.image_icon:setvisible(true)
            widgetlist.image_icon:seticon(playercareericon[mate.career])
            
            widgetlist.text_level:settext(mate.level)
            widgetlist.text_name:settextscale(mate.name)
        else
            widgetlist.image_leader:setvisible(false)
            widgetlist.image_icon:setvisible(false)
            widgetlist.text_level:settext("")
            widgetlist.text_name:settext("")
        end
    end

    local selectmate = playerpal_getraidmatefromindex(m_uiraidmain_select)
    local leaderbutton = selectmate ~= nil and selectmate.playerid ~= playerattr_info.actorid and playerattr_raid.leader == playerattr_info.actorid
    local button_moveto = m_uiraidmain:getwidget("button_moveto")
    local button_leader = m_uiraidmain:getwidget("button_leader")
    local button_kick = m_uiraidmain:getwidget("button_kick")
    button_moveto:setenablenofade(playerattr_raid.leader == playerattr_info.actorid or playerattr_raid.matemove > 0)
    button_leader:setenablenofade(leaderbutton)
    button_kick:setenablenofade(leaderbutton)

    local checkbox_matemove = m_uiraidmain:getwidget("checkbox_matemove")
    checkbox_matemove:setcheck(playerattr_raid.matemove > 0)

    m_uiraidmain:setwidgetvisiblenothit("text_tips2", playerattr_raid.leader == playerattr_info.actorid)
    
    local text_tips = m_uiraidmain:getwidget("text_tips")
    text_tips:settext("TEAM_RAID_TIPS", matecount)
    raid_main_updatevalue()
end

function raid_main_delegate_member(sender, event)
    if event.name == "mousedown" then
        m_uiraidmain_select = sender.index
        if m_uiraidmain_movingactorid ~= nil then
            local msg = {messageid="CS_RaidMoveMate"}
            msg.playerid = m_uiraidmain_movingactorid
            msg.slot = sender.index - 1
            c_send(msg)
            raid_main_delegate_movecover(nil)
        else
            m_uiraidmain_presstime = time_game
            m_uiraidmain_pressindex = sender.index
        end
        raid_main_updateui()
	elseif event.name == "mouseup" then
        m_uiraidmain_presstime = nil
    end
end

function raid_main_delegate_movecover(sender)
    m_uiraidmain_movingactorid = nil
    m_uiraidmain:setwidgetvisible("text_tipsmoving", false)
    m_uiraidmain:setwidgetvisible("image_movingcover", false)
end

function raid_main_delegate_matemove(sender)
    local msg = {messageid="CS_RaidMateMoveEnable"}
    msg.enable = math.ternary(playerattr_raid.matemove == 0, 1, 0)
    c_send(msg)
    sender:setcheck(playerattr_raid.matemove > 0)
end

function raid_main_delegate_moveto(sender)
    if m_uiraidmain_select ~= 0 then
        local msg = {messageid="CS_RaidMoveSlot"}
        msg.slot = m_uiraidmain_select - 1
        c_send(msg)
    end
end

function raid_main_leader_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidLeader"}
        msg.playerid = data
        c_send(msg)
    end
end
function raid_main_delegate_setleader(sender)
    local selectmate = playerpal_getraidmatefromindex(m_uiraidmain_select)
    if selectmate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_LEADER_CONFIRMTEXT", selectmate.name)
        messagebox_confirm(confirmtext, raid_main_leader_confirm, selectmate.playerid)
    end
end

function raid_main_kick_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidKick"}
        msg.playerid = data
        c_send(msg)
    end
end
function raid_main_delegate_kick(sender)
    local selectmate = playerpal_getraidmatefromindex(m_uiraidmain_select)
    if selectmate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_KICK_CONFIRMTEXT_RAID", selectmate.name)
        messagebox_confirm(confirmtext, raid_main_kick_confirm, selectmate.playerid)
    end
end

function raid_main_leave_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidLeave"}
        c_send(msg)
    end
end
function raid_main_delegate_leave(sender)
    messagebox_confirm("TEAM_MATE_LEAVE_CONFIRMTEXT_RAID", raid_main_leave_confirm)
end

function raid_main_delegate_close()
    m_uiraidmain:close()
end
