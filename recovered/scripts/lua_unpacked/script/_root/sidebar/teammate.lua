
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

local m_teammate_inst = { teammate = "sidebar/inst_teammate", spirit = "sidebar/inst_spirit", teambutton = "sidebar/inst_teambutton" }

function team_mate_open()
    m_uisidebar_main:setwidgetvisible("tab_team", true)
    m_uisidebar_main.list_mate:setclickdelegate(team_mate_click)
end

function team_mate_close()
    m_uisidebar_main:setwidgetvisible("tab_team", false)
end

function team_mate_addmate(playerid, name, level, career, leaderid)
    local line = m_uisidebar_main.list_mate:add(m_teammate_inst.teammate, playerid, playerid)
    line.linetype = teamlinetype.mate
    line.text_hp = line:getwidget("text_hp")
    line.text_mp = line:getwidget("text_mp")
    line.progress_hp = line:getwidget("progress_hp")
    line.progress_hpanim = line:getwidget("progress_hpanim")
    line.progress_hpdebuff = line:getwidget("progress_hpdebuff")
    line.progress_hpdebuffanim = line:getwidget("progress_hpdebuffanim")
    line.progress_mp = line:getwidget("progress_mp")
    line.progress_mpanim = line:getwidget("progress_mpanim")
    line.image_flytime = line:getwidget("image_flytime")

    line.image_leader = line:getwidget("image_leader")
    line.image_select = line:getwidget("image_select")
    line.image_icon = line:getwidget("image_icon")
    line.text_level = line:getwidget("text_level")
    line.text_name = line:getwidget("text_name")
    line.image_leader:setvisible(playerid == leaderid)
    line.image_icon:seticon(playercareericon[career])
    line.text_level:settext(level)
    line.text_name:settextscale(name)
end

function team_mate_addspirit()
    local line = m_uisidebar_main.list_mate:add(m_teammate_inst.spirit, playerattr_info.spiritid, playerattr_info.spiritid)
    line.linetype = teamlinetype.spirit

	local actor = actormanager_getfromactorid(playerattr_info.spiritid)
	if actor ~= nil then
		local image_head = line:getwidget("image_head")
		image_head:seticon(actor:getheadicon())

		local text_level = line:getwidget("text_level")
		text_level:settext(actor.attr.level)
	end

	line:setwidgetvisiblenothit("image_attack/image_anim", playerattr_info.spiritstate == spiritstate.attack)
	line:setwidgetvisiblenothit("image_move/image_anim", playerattr_info.spiritstate == spiritstate.move)
	line:setwidgetvisiblenothit("image_idle/image_anim", playerattr_info.spiritstate == spiritstate.idle)
	line:setwidgetvisiblenothit("image_dismiss/image_anim", playerattr_info.spiritstate == spiritstate.dismiss)

    line:setwidgetdelegate("image_head", team_spiritinfo_delegate_select)
    line:setwidgetdelegate("image_attack/button_command", team_spiritinfo_delegate_attack)
	line:setwidgetdelegate("image_move/button_command", team_spiritinfo_delegate_move)
	line:setwidgetdelegate("image_idle/button_command", team_spiritinfo_delegate_idle)
	line:setwidgetdelegate("image_dismiss/button_command", team_spiritinfo_delegate_dismiss)

	line.progress_hp = line:getwidget("progress_hp")
	line.progress_hpanim = line:getwidget("progress_hpanim")
end

function team_mate_setcolor(widget, enable)
    if enable then
        widget:setcolor(1.0, 1.0, 1.0, 1.0)
    else
        widget:setcolor(0.4, 0.4, 0.4, 1.0)  
    end
end

function team_mate_setmatevalue(line, online, insight, debuff, hp, hpanim, hpmax, mp, mpanim, mpmax, flytime, flytimemax, flying)
    if online > 0 then
        line.text_hp:settext(string.format("%d/%d", math.tointegerfloor(hp), math.tointegerfloor(hpmax)))
        line.text_mp:settext(string.format("%d/%d", math.tointegerfloor(mp), math.tointegerfloor(mpmax)))
        if debuff then
            line.progress_hp:setpercent(0.0)
            line.progress_hpanim:setpercent(0.0)
            line.progress_hpdebuff:setpercent(hp / hpmax)
            line.progress_hpdebuffanim:setpercent(hpanim / hpmax)
        else
            line.progress_hp:setpercent(hp / hpmax)
            line.progress_hpanim:setpercent(hpanim / hpmax)
            line.progress_hpdebuff:setpercent(0.0)
            line.progress_hpdebuffanim:setpercent(0.0)
        end
        
        line.progress_mp:setpercent(mp / mpmax)
        line.progress_mpanim:setpercent(mpanim / mpmax)
        line.image_flytime:setpercent(flytime / flytimemax)
        team_mate_setcolor(line.text_name, true)
        team_mate_setcolor(line.progress_hp, insight)
        team_mate_setcolor(line.progress_hpanim, insight)
        team_mate_setcolor(line.progress_mp, insight)
        team_mate_setcolor(line.progress_mpanim, insight)
        team_mate_setcolor(line.image_flytime, flying)
    else
        team_mate_setcolor(line.text_name, false)
        line.text_hp:settext("")
        line.text_mp:settext("")
        line.progress_hp:setpercent(0.0)
        line.progress_hpanim:setpercent(0.0)
        line.progress_hpdebuff:setpercent(0.0)
        line.progress_hpdebuffanim:setpercent(0.0)
        line.progress_mp:setpercent(0.0)
        line.progress_mpanim:setpercent(0.0)
        line.image_flytime:setpercent(0.0)
    end
end

function team_spirit_setmatevalue(line)
	local spirit = actormanager_getfromactorid(playerattr_info.spiritid)
	if spirit ~= nil then
		line.progress_hp:setpercent(spirit.attrdisplay.hp / spirit.attrdisplay.hpmax)
		line.progress_hpanim:setpercent(spirit.attrdisplay.hpanim / spirit.attrdisplay.hpmax)
		playerbuff_updateactorui(spirit, line)
	end
end

function team_mate_updatevalue()
    if m_uisidebar_main:null() then
        return
    end
    local list_mate = m_uisidebar_main.list_mate
    local removespirit = 0
    for i=1,list_mate:getcount() do
        local line = list_mate:getlinefromindex(i)
        if line.linetype == teamlinetype.mate then
            local playerid = line:getdata()
            local actor = actormanager_getfromactorid(playerid)
            if actor ~= nil then
                local mate = playerpal_getmatefromplayerid(playerid)
                local online = 1
                if mate ~= nil then
                    online = mate.online
                end
                team_mate_setmatevalue(line, online, true, actor.actionmain.buffhasdebuff
                , actor.attrdisplay.hp, actor.attrdisplay.hpanim, actor.attrdisplay.hpmax
                , actor.attrdisplay.mp, actor.attrdisplay.mpanim, actor.attrdisplay.mpmax
                , actor.attr.fp, actor.attr.fpmax, actor.attr.movetype == playermovestate.glide or actor.attr.movetype == playermovestate.fly)
                playerbuff_updateactorui(actor, line)
            elseif playerattr_team ~= nil then
                local mate = playerpal_getmatefromplayerid(playerid)
                if mate ~= nil then
                    team_mate_setmatevalue(line, mate.online, false, false, mate.hp, mate.hp, mate.hpmax, mate.mp, mate.mp, mate.mpmax, mate.fp, mate.fpmax, mate.flying > 0)
                    playerbuff_updateactorui(nil, line)
                end
            end
        elseif line.linetype == teamlinetype.spirit then
            team_spirit_setmatevalue(line)
            if playerattr_info.spiritid == 0 then
                removespirit = i
            end
        end
    end
    if removespirit > 0 then
        list_mate:remove(removespirit)
    end
end

function team_mate_updateui()
    if m_uisidebar_main:null() then
        return
    end
    local list_mate = m_uisidebar_main.list_mate
    list_mate:savestate()
    list_mate:clear()

    if playerattr_team ~= nil then
        if gamesetting_getnumber("TEAMME") > 0 then
            team_mate_addmate(playerattr_info.actorid, playerattr_info.name, playerattr_info.level, playerattr_info.career, playerattr_team.leader)
        end
    end
    if playerattr_info.spiritid ~= 0 then
        team_mate_addspirit()
    end
    if playerattr_team ~= nil then
        for i=1, #playerattr_team.mate do
            local mate = playerattr_team.mate[i]
            team_mate_addmate(mate.playerid, mate.name, mate.level, mate.career, playerattr_team.leader)
        end
    end

    team_mate_updatevalue()

    if playerattr_team == nil and playerattr_info.spiritid == 0 then
        local line = list_mate:add(m_teammate_inst.teambutton)
        line.linetype = teamlinetype.button
        local text_team = line:getwidget("text_team")
        text_team:settext("SIDEBAR_TEAMCREATE")
        text_team:setdelegate(team_matebutton_teamcreate)

        line = list_mate:add(m_teammate_inst.teambutton)
        line.linetype = teamlinetype.button
        text_team = line:getwidget("text_team")
        text_team:settext("SIDEBAR_TEAMINVITE")
        text_team:setdelegate(team_matebutton_teaminvite)
    end

    list_mate:restorestate()
end

function team_mate_click(line, event, quest)
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
            team_mate_updateui()
            itemmenu_close()
        elseif showmenu then
            local mate = playerpal_getmatefromplayerid(playerid)
            itemmenu_reset(playerid)
            if mate ~= nil then
                if playerattr_team.leader == playerattr_info.actorid then
                    itemmenu_addbutton("PLAYER_RBMENU_TEAMLEADER", team_menu_button_teamleader)
                    if playerattr_team.kickable > 0 then
                        itemmenu_addbutton("PLAYER_RBMENU_TEAMKICK", team_menu_button_teamkick)
                    end
                end
                itemmenu_addbutton("PLAYER_RBMENU_WHISPER", team_menu_button_whisper)
            end
            itemmenu_addbutton("PLAYER_RBMENU_TEAMPICKMODE", team_menu_button_teampickmode)
            if playerattr_team.leader == playerattr_info.actorid then
                itemmenu_addbutton("PLAYER_RBMENU_RAIDUP", team_menu_button_raidup)
            end
            if playerattr_team.leaveable > 0 then
                itemmenu_addbutton("PLAYER_RBMENU_TEAMLEAVE", team_menu_button_teamleave)
            end
            local x,y,w,h = line.image_select:getabsolute()
            itemmenu_open(x + w, y + h / 2, m_uisidebar_main)
        end
    end
end

function team_matebutton_teamcreate(sender, event)
    local msg = {messageid="CS_TeamCreate"}
    c_send(msg)
end

function team_matebutton_teaminvite(sender, event)
    inputkey_openteam()
end

function team_menu_button_whisper(data)
    local mate = playerpal_getmatefromplayerid(data)
    if mate ~= nil then
        chat_whisperto(mate.playerid, mate.name)
    end
end

function team_mate_leader_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_TeamLeader"}
        msg.playerid = data
        c_send(msg)
    end
end
function team_menu_button_teamleader(data)
    local mate = playerpal_getmatefromplayerid(data)
    if mate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_LEADER_CONFIRMTEXT", mate.name)
        messagebox_confirm(confirmtext, team_mate_leader_confirm, mate.playerid)
    end
end

function team_mate_kick_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_TeamKick"}
        msg.playerid = data
        c_send(msg)
    end
end
function team_menu_button_teamkick(data)
    local mate = playerpal_getmatefromplayerid(data)
    if mate ~= nil then
        local confirmtext = c_textformat("TEAM_MATE_KICK_CONFIRMTEXT", mate.name)
        messagebox_confirm(confirmtext, team_mate_kick_confirm, mate.playerid)
    end
end

function team_mate_raidup_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RaidCreate"}
        c_send(msg)
    end
end
function team_menu_button_raidup(data)
    messagebox_confirm("TEAM_RAID_TEAMLEVELUP", team_mate_raidup_confirm)
end

function team_mate_leave_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_TeamLeave"}
        c_send(msg)
    end
end
function team_menu_button_teamleave(data)
    messagebox_confirm("TEAM_MATE_LEAVE_CONFIRMTEXT", team_mate_leave_confirm)
end

function team_menu_button_teampickmode(data)
    team_setpickitem_open()
end

function team_spiritinfo_delegate_select(sender, event)
    local actor = actormanager_getfromactorid(playerattr_info.spiritid)
    if actor ~= nil then
        actormanager_selectactor(actor)
    end
end

function team_spiritinfo_delegate_attack(sender, event)
    systemskill_spiritattack()
end

function team_spiritinfo_delegate_move(sender, event)
    systemskill_spiritmove()
end

function team_spiritinfo_delegate_idle(sender, event)
    systemskill_spiritidle()
end

function team_spiritinfo_delegate_dismiss(sender, event)
    systemskill_spiritdismiss()
end
