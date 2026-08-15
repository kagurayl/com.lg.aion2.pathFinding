
local SENIOR_CEO = 0
local SENIOR_VP = 1
local SENIOR_MEMBER = 2
local m_iccmember_inst = {member = "icc/inst_member"}

local SeniorText =
{
    "ICC_SENIOR_CEO",
    "ICC_SENIOR_VP",
    "ICC_SENIOR_MEMBER",
}

local function iccmember_getmember(playerid)
    for i=1,#playerattr_icc.member do
        local member = playerattr_icc.member[i]
        if member.playerid == playerid then
            return member
        end
    end
end

function iccmember_onopenui()
    local list_member = m_uiicc_main:getwidget("tab_member/list_member")
    list_member:init(uilistflag.vertical)
    list_member:setclickdelegate(iccmember_delegate_list_member)
end

function iccmember_updateui()
    if m_uiicc_main:null() then
        return
    end
    local list_member = m_uiicc_main:getwidget("tab_member/list_member")
    list_member:savestate()
    list_member:clear()
    for i=1,#playerattr_icc.member do
        local member = playerattr_icc.member[i]
        local line = list_member:add(m_iccmember_inst.member, member.playerid, member.playerid)

        local text_name = line:getwidget("text_name")
        text_name:settext(member.name)

        local text_level = line:getwidget("text_level")
        text_level:settext(member.level)

        local text_career = line:getwidget("text_career")
        text_career:settext(playercareertext[member.career])

        local text_senior = line:getwidget("text_senior")
        text_senior:settext(SeniorText[member.senior + 1])

        local text_state = line:getwidget("text_state")
        if member.disconnect > 0 then
            text_state:settext(timerdesc_early(member.disconnect))
        else
            text_state:settext("PLAYER_STATE_ONLINE")
        end
    end
    list_member:restorestate()
end

function iccmember_delegate_list_member(line, event, data)
    local member = iccmember_getmember(data)
    if member == nil then
        return
    end
    local player = iccmember_getmember(playerattr_info.actorid)
    if player == nil then
        return
    end
    itemmenu_reset(member.playerid)
    if playerattr_info.actorid ~= member.playerid then
        itemmenu_addbutton("PLAYER_RBMENU_WHISPER", iccmember_delegate_menu_whisper)
        if player.senior == SENIOR_CEO then
            itemmenu_addbutton("PLAYER_RBMENU_ICCSETCEO", iccmember_delegate_menu_setceo)
            if member.senior ~= SENIOR_VP then
                itemmenu_addbutton("PLAYER_RBMENU_ICCSETVP", iccmember_delegate_menu_setvp)
            end
            if member.senior ~= SENIOR_MEMBER then
                itemmenu_addbutton("PLAYER_RBMENU_ICCSETMEMBER", iccmember_delegate_menu_setmember)
            end
            itemmenu_addbutton("PLAYER_RBMENU_ICCKICK", iccmember_delegate_menu_kick)
        elseif player.senior == SENIOR_VP then
            if member.senior == SENIOR_MEMBER then
                itemmenu_addbutton("PLAYER_RBMENU_ICCKICK", iccmember_delegate_menu_kick)
            end
        end
    else
        itemmenu_addbutton("PLAYER_RBMENU_ICCLEAVE", iccmember_delegate_menu_leave)
    end
    itemmenu_open(event.mousex, event.mousey, m_uiicc_main)
end

function iccmember_delegate_menu_whisper(data)
    local member = iccmember_getmember(data)
    if member ~= nil then
        chat_whisperto(member.playerid, member.name)
    end
end

function iccmember_setceo_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccSenior"}
        msg.playerid = data
        msg.senior = SENIOR_CEO
        c_send(msg)
    end
end
function iccmember_delegate_menu_setceo(data)
    local member = iccmember_getmember(data)
    if member ~= nil then
        local confirmtext = c_textformat("ICC_CONFIRM_SETCEO", member.name)
        messagebox_confirm(confirmtext, iccmember_setceo_confirm, data)
    end
end

function iccmember_delegate_menu_setvp(data)
    local member = iccmember_getmember(data)
    if member ~= nil then
        local msg = {messageid="CS_IccSenior"}
        msg.playerid = member.playerid
        msg.senior = SENIOR_VP
        c_send(msg)
    end
end

function iccmember_delegate_menu_setmember(data)
    local member = iccmember_getmember(data)
    if member ~= nil then
        local msg = {messageid="CS_IccSenior"}
        msg.playerid = member.playerid
        msg.senior = SENIOR_MEMBER
        c_send(msg)
    end
end

function iccmember_kick_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccKick"}
        msg.playerid = data
        c_send(msg)
    end
end
function iccmember_delegate_menu_kick(data)
    local member = iccmember_getmember(data)
    if member ~= nil then
        local confirmtext = c_textformat("ICC_CONFIRM_KICK", member.name)
        messagebox_confirm(confirmtext, iccmember_kick_confirm, member.playerid)
    end
end

function iccmember_leave_confirm(ok)
    if ok then
        local msg = {messageid="CS_IccLeave"}
        c_send(msg)
    end
end
function iccmember_delegate_menu_leave()
    messagebox_confirm("ICC_CONFIRM_LEAVE", iccmember_leave_confirm, 0)
end
