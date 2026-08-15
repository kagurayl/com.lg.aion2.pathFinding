
local m_uiteam_summon = uipanel_createhandle("team/team_summon", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function team_summon_onopen()
    m_uiteam_summon:setwidgetdelegate("button_accept", team_summon_delegate_accept)
    m_uiteam_summon:setwidgetdelegate("button_refuse", team_summon_delegate_refuse)
    event_register(eventtype.update, team_summon_update, m_uiteam_summon)
end

function team_summon_open(name, skillid, time)
    m_uiteam_summon:open()
    m_uiteam_summon.playername = name
    m_uiteam_summon.skillid = skillid
    m_uiteam_summon.time = time_game + time
end

function team_summon_update()
    local config_skill = csvskill_getfromid(m_uiteam_summon.skillid)
    if config_skill ~= nil then
        local text_message = m_uiteam_summon:getwidget("text_message")
        text_message:settext("TEAM_SUMMON_CONFIRM", m_uiteam_summon.playername, config_skill.name, math.tointegerfloor(math.max(0.0, m_uiteam_summon.time - time_game)))
    end
    if m_uiteam_summon.time < time_game then
        team_summon_delegate_refuse()
    end
end

function team_summon_delegate_accept(sender, event)
    local msg = {messageid="CS_TeamSummonConfirm"}
    msg.accept = 1
    c_send(msg)
    m_uiteam_summon:close()
end

function team_summon_delegate_refuse(sender, event)
    local msg = {messageid="CS_TeamSummonConfirm"}
    msg.accept = 0
    c_send(msg)
    m_uiteam_summon:close()
end
