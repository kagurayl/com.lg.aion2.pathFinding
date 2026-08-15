
local m_uiteamsetpickitem = uipanel_createhandle("team/team_setpickitem", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))

function team_setpickitem_open()
    m_uiteamsetpickitem:open()
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_round", team_setpickitem_delegate_round)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_free", team_setpickitem_delegate_free)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_quality1", team_setpickitem_delegate_quality1)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_quality2", team_setpickitem_delegate_quality2)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_quality3", team_setpickitem_delegate_quality3)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_quality4", team_setpickitem_delegate_quality4)
    m_uiteamsetpickitem:setwidgetdelegate("checkbox_quality5", team_setpickitem_delegate_quality5)
    m_uiteamsetpickitem:setwidgetdelegate("button_ok", team_setpickitem_delegate_ok)
    team_setpickitem_updateui()
end

function team_setpickitem_updateui()
    if m_uiteamsetpickitem:null() then
        return
    end
    if playerattr_team == nil and playerattr_raid == nil then
        return
    end
    local checkbox_round = m_uiteamsetpickitem:getwidget("checkbox_round")
    local checkbox_free = m_uiteamsetpickitem:getwidget("checkbox_free")
    local quality = csvitemquality.white
    if playerattr_team ~= nil then
        checkbox_round:setcheck(playerattr_team.pickitem == teampickitem.round)
        checkbox_free:setcheck(playerattr_team.pickitem == teampickitem.free)
        quality = playerattr_team.randquality
    elseif playerattr_raid ~= nil then
    --     checkbox_round:setcheck(playerattr_raid.pickitem == teampickitem.round)
    --     checkbox_free:setcheck(playerattr_raid.pickitem == teampickitem.free)
    --     quality = playerattr_raid.randquality
    end
    local checkbox_quality1 = m_uiteamsetpickitem:getwidget("checkbox_quality1")
    local checkbox_quality2 = m_uiteamsetpickitem:getwidget("checkbox_quality2")
    local checkbox_quality3 = m_uiteamsetpickitem:getwidget("checkbox_quality3")
    local checkbox_quality4 = m_uiteamsetpickitem:getwidget("checkbox_quality4")
    local checkbox_quality5 = m_uiteamsetpickitem:getwidget("checkbox_quality5")
    checkbox_quality1:setcheck(quality == csvitemquality.white)
    checkbox_quality2:setcheck(quality == csvitemquality.green)
    checkbox_quality3:setcheck(quality == csvitemquality.blue)
    checkbox_quality4:setcheck(quality == csvitemquality.yellow)
    checkbox_quality5:setcheck(quality == csvitemquality.red)
end

function team_setpickitem_showpickitem()
    if playerattr_team ~= nil then
        if playerattr_team.pickitem == teampickitem.round then
    		chat_addsystemalert(c_textformat("TEAM_PICKITEM_TIPS", "TEAM_PICKITEM_ROUND", "TEAM_PICKITEM_RAND_QUALITY" .. playerattr_team.randquality))
        elseif playerattr_team.pickitem == teampickitem.free then
            chat_addsystemalert(c_textformat("TEAM_PICKITEM_TIPS", "TEAM_PICKITEM_FREE", "TEAM_PICKITEM_RAND_QUALITY" .. playerattr_team.randquality))
        end
    elseif playerattr_raid ~= nil then
    --     if playerattr_raid.pickitem == teampickitem.round then
    -- 		chat_addsystemalert(c_textformat("TEAM_PICKITEM_TIPS", "TEAM_PICKITEM_ROUND", "TEAM_PICKITEM_RAND_QUALITY" .. playerattr_raid.randquality))
    --     elseif playerattr_raid.pickitem == teampickitem.free then
    --         chat_addsystemalert(c_textformat("TEAM_PICKITEM_TIPS", "TEAM_PICKITEM_FREE", "TEAM_PICKITEM_RAND_QUALITY" .. playerattr_raid.randquality))
    --     end
    end
end

function team_setpickitem_close()
    m_uiteamsetpickitem:close()
end

function team_setpickitem_delegate_round(sender, event)
    if playerattr_team ~= nil then
        local msg = {messageid="CS_TeamPickItem"}
        msg.pickitem = teampickitem.round
        c_send(msg)
        sender:setcheck(playerattr_team.pickitem == teampickitem.round)
    elseif playerattr_raid ~= nil then
    --     local msg = {messageid="CS_RaidPickItem"}
    --     msg.pickitem = teampickitem.round
    --     c_send(msg)
    end
end

function team_setpickitem_delegate_free(sender, event)
    if playerattr_team ~= nil then
        local msg = {messageid="CS_TeamPickItem"}
        msg.pickitem = teampickitem.free
        c_send(msg)
        sender:setcheck(playerattr_team.pickitem == teampickitem.free)
    elseif playerattr_raid ~= nil then
        -- local msg = {messageid="CS_RaidPickItem"}
        -- msg.pickitem = teampickitem.free
        -- c_send(msg)
    end
end

local function team_setpickitem_sendrandquality(sender, quality)
    if playerattr_team ~= nil then
        local msg = {messageid="CS_TeamRandItem"}
        msg.quality = quality
        c_send(msg)
        sender:setcheck(playerattr_team.randquality == quality)
    end
end

function team_setpickitem_delegate_quality1(sender, event)
    team_setpickitem_sendrandquality(sender, 1)
end

function team_setpickitem_delegate_quality2(sender, event)
    team_setpickitem_sendrandquality(sender, 2)
end

function team_setpickitem_delegate_quality3(sender, event)
    team_setpickitem_sendrandquality(sender, 3)
end

function team_setpickitem_delegate_quality4(sender, event)
    team_setpickitem_sendrandquality(sender, 4)
end

function team_setpickitem_delegate_quality5(sender, event)
    team_setpickitem_sendrandquality(sender, 5)
end

function team_setpickitem_delegate_ok(sender, event)
    m_uiteamsetpickitem:close()
end
