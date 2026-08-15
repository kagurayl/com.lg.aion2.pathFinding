
local m_request_inst = {request = "team/inst_request"}

function teamrequest_onopen()
    local list_request = m_uiteam_recruit:getwidget("tab_request/list_request")
    list_request:init(uilistflag.vertical)
    list_request:setclickdelegate(teamrequest_delegate_list_request)
    teamrequest_updateui()
end

function teamrequest_updateui()
    if m_uiteam_recruit:null() then
		return
	end
    local list_request = m_uiteam_recruit:getwidget("tab_request/list_request")
    local teamempty = playerattr_team == nil or playerattr_team.request == nil or #playerattr_team.request == 0
    local raidempty = playerattr_raid == nil or playerattr_raid.request == nil or #playerattr_raid.request == 0
    if teamempty and raidempty then
        list_request:clear()
        return
    end

    local list_request = m_uiteam_recruit:getwidget("tab_request/list_request")
    list_request:savestate()
    list_request:clear()
    if playerattr_team ~= nil then
        for i=#playerattr_team.request, 1, -1 do
            local linedata = playerattr_team.request[i]
            local line = list_request:add(m_request_inst.request, linedata.playerid, linedata.playerid)

            local text_name = line:getwidget("text_name")
            text_name:settext(linedata.name)

            local text_icc = line:getwidget("text_icc")
            text_icc:settext(linedata.icc)

            local text_career = line:getwidget("text_career")
            text_career:settext(playercareertext[linedata.career])
            
            local text_level = line:getwidget("text_level")
            text_level:settext(linedata.level)

            local button_accept = line:getwidget("button_accept")
            button_accept:setdelegate(teamrequest_delegate_acceptteam)
            button_accept.playerid = linedata.playerid
        end
    elseif playerattr_raid ~= nil then
        for i=#playerattr_raid.request, 1, -1 do
            local linedata = playerattr_raid.request[i]
            local line = list_request:add(m_request_inst.request, linedata.playerid, linedata.playerid)

            local text_name = line:getwidget("text_name")
            text_name:settext(linedata.name)

            local text_icc = line:getwidget("text_icc")
            text_icc:settext(linedata.icc)

            local text_career = line:getwidget("text_career")
            text_career:settext(playercareertext[linedata.career])
            
            local text_level = line:getwidget("text_level")
            text_level:settext(linedata.level)

            local button_accept = line:getwidget("button_accept")
            button_accept:setdelegate(teamrequest_delegate_acceptraid)
            button_accept.playerid = linedata.playerid
        end
    end
    list_request:restorestate()
end

function teamrequest_delegate_acceptteam(sender, event)
    local msg = {messageid="CS_TeamRequestAccept"}
    msg.playerid = sender.playerid
    c_send(msg)
    if playerattr_team ~= nil then
        for i=1,#playerattr_team.request do
            if playerattr_team.request[i].playerid == sender.playerid then
                table.remove(playerattr_team.request, i)
                break
            end
        end
		teamrequest_updateui()
	end
end

function teamrequest_delegate_acceptraid(sender, event)
    local msg = {messageid="CS_RaidRequestAccept"}
    msg.playerid = sender.playerid
    c_send(msg)
    if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.request do
            if playerattr_raid.request[i].playerid == sender.playerid then
                table.remove(playerattr_raid.request, i)
                break
            end
        end
		teamrequest_updateui()
	end
end
