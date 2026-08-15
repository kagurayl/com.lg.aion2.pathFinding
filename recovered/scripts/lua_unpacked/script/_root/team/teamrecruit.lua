
function team_recruit_onopen()
    m_uiteam_recruit.tabmain = uitabcreate(m_uiteam_recruit)
    m_uiteam_recruit.tabmain:add("button_advert", "tab_advert")
    m_uiteam_recruit.tabmain:add("button_request", "tab_request")
    m_uiteam_recruit.tabmain:settab(1)

    m_uiteam_recruit:setwidgetdelegate("image_bg/button_close", team_recruit_close)
    m_uiteam_recruit:setwidgetdelegate("button_createteam", team_recruit_createteam)
    m_uiteam_recruit:setwidgetdelegate("button_delete", team_recruit_delete)
    m_uiteam_recruit:setwidgetdelegate("button_publish", team_recruit_publish)
    teamadvert_onopen()
    teamrequest_onopen()
end

function team_recruit_createteam()
    local msg = {messageid="CS_TeamCreate"}
    c_send(msg)
end

function team_recruit_delete()
    if playerattr_team ~= nil then
        local msg = {messageid="CS_TeamAdvertRemove"}
        c_send(msg)
    elseif playerattr_raid ~= nil then
        local msg = {messageid="CS_RaidAdvertRemove"}
        c_send(msg)
    end
end

function team_recruit_publish_confirm(text)
    if playerattr_team ~= nil then
        local msg = {messageid="CS_TeamAdvertAdd"}
        msg.text = text
        c_send(msg)
    elseif playerattr_raid ~= nil then
        local msg = {messageid="CS_RaidAdvertAdd"}
        msg.text = text
        c_send(msg)
    end
end

function team_recruit_publish()
    inputline_show(uiedittype.default, "RECRUIT_PUBLISH_TITLE", nil, team_recruit_publish_confirm, nil)
end

function team_recruit_close()
    m_uiteam_recruit:close()
end
