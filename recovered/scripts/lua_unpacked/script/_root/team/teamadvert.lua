
local m_advert_inst = {advert = "team/inst_advert"}
local m_advert_select = 0

function teamadvert_onopen()
    local list_advert = m_uiteam_recruit:getwidget("tab_advert/list_advert")
    list_advert:init(uilistflag.vertical)
    list_advert:setclickdelegate(teamadvert_delegate_list_advert)
    local msg = {messageid="CS_TeamAdvertList"}
    c_send(msg)
end

function team_setadvert(msg)
    if m_uiteam_recruit:null() then
        return
    end
    local list_advert = m_uiteam_recruit:getwidget("tab_advert/list_advert")
    list_advert:clear()

    local removebuttonenable = false
    for i=1,#msg.info do
        local advert = msg.info[i]
        local line = list_advert:add(m_advert_inst.advert, advert.leader, advert.leader)
        line.advert = advert
        local r = 1
        local g = 1
        local b = 1
        local a = 1
        if playerattr_team ~= nil and playerattr_team.leader == advert.leader then
            r = 0
            b = 0
            removebuttonenable = true
        elseif playerattr_raid ~= nil and playerattr_raid.leader == advert.leader then
            r = 0
            b = 0
            removebuttonenable = true
        end

        local text_type = line:getwidget("text_type")
        text_type:setcolor(r,g,b,a)
        text_type:settext(math.ternary(advert.raid == 0, "RECRUIT_CHECK_TEAM", "RECRUIT_CHECK_RAID"))

        local text_content = line:getwidget("text_content")
        text_content:setcolor(r,g,b,a)
        text_content:settext(advert.text)

        local text_leader = line:getwidget("text_leader")
        text_leader:setcolor(r,g,b,a)
        text_leader:settext(advert.name)

        local text_count = line:getwidget("text_count")
        text_count:setcolor(r,g,b,a)
        if advert.raid == 0 then
            text_count:settext(advert.count .. "/6")
        else
            text_count:settext(advert.count .. "/" .. team_raid_maxmate)
        end

        local text_level = line:getwidget("text_level")
        text_level:setcolor(r,g,b,a)
        text_level:settext(string.format("%d~%d", advert.levelmin, advert.levelmax))
    end
    m_uiteam_recruit:setwidgetenable("button_delete", removebuttonenable)
    teamadvert_updaterequestenable()
end

function teamadvert_updaterequestenable()
    local list_advert = m_uiteam_recruit:getwidget("tab_advert/list_advert")
    for i=1,list_advert:getcount() do
        local line = list_advert:getlinefromindex(i)
        local button_request = line:getwidget("button_request")
        button_request:setdelegate(teamadvert_delegate_request)
        button_request.leader = line.advert.leader
        button_request.raid = line.advert.raid
        if playerattr_team ~= nil or playerattr_raid ~= nil then
            button_request:setenable(false)
        elseif m_advert_select ~= line.advert.leader then
            button_request:setenable(false)
        else
            button_request:setenable(true)
        end
    end
end

function teamadvert_delegate_request(sender, event)
    if sender.raid == 0 then
        local msg = {messageid="CS_TeamRequestSend"}
        msg.playerid = sender.leader
        c_send(msg)
    else
        local msg = {messageid="CS_RaidRequestSend"}
        msg.playerid = sender.leader
        c_send(msg)
    end
end

function teamadvert_delegate_list_advert(line, event, data)
    m_advert_select = line.advert.leader
    teamadvert_updaterequestenable()
end
