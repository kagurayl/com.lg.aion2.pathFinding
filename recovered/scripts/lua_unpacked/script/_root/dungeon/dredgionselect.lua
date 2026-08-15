
local m_uidredgionselect = uipanel_createhandle("dungeon/dredgion_select", uilayer.normal, 0)

function dredgionselect_open()
	m_uidredgionselect:open()
end

function dredgion_select_onopen()
	m_uidredgionselect:setwidgetdelegate("button_cancel", dredgion_select_delegate_close)
	m_uidredgionselect:setwidgetdelegate("image_bg/button_close", dredgion_select_delegate_close)

	local button_solo = m_uidredgionselect:getwidget("button_solo")
	button_solo:settext("DREDGION_SOLODESC")
	button_solo:setdelegate(dredgion_select_delegate_solo)

	local button_random = m_uidredgionselect:getwidget("button_random")
	button_random:settext("DREDGION_RANDOMDESC")
	button_random:setdelegate(dredgion_select_delegate_random)

	local button_team = m_uidredgionselect:getwidget("button_team")
	button_team:settext("DREDGION_TEAMDESC")
	button_team:setdelegate(dredgion_select_delegate_team)
end

function dredgion_select_solo_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_MatchStart"}
		if playerattr_info.level > 50 then
    	    msg.type = matching_type.dredgion55solo
		else
	        msg.type = matching_type.dredgion50solo
		end
        c_send(msg)
    end
end
function dredgion_select_delegate_solo()
	messagebox_confirm("DREDGION_SOLOCONFIRM", dredgion_select_solo_confirm)
	m_uidredgionselect:close()
end

function dredgion_select_random_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_MatchStart"}
		if playerattr_info.level > 50 then
    	    msg.type = matching_type.dredgion55random
		else
	        msg.type = matching_type.dredgion50random
		end
        c_send(msg)
    end
end
function dredgion_select_delegate_random()
	messagebox_confirm("DREDGION_RANDOMCONFIRM", dredgion_select_random_confirm)
	m_uidredgionselect:close()
end

function dredgionselect_team_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_MatchStart"}
		if playerattr_info.level > 50 then
    	    msg.type = matching_type.dredgion55team
		else
	        msg.type = matching_type.dredgion50team
		end
        c_send(msg)
    end
end
function dredgion_select_delegate_team()
	messagebox_confirm("DREDGION_TEAMCONFIRM", dredgionselect_team_confirm)
	m_uidredgionselect:close()
end

function dredgion_select_delegate_close()
	m_uidredgionselect:close()
end
