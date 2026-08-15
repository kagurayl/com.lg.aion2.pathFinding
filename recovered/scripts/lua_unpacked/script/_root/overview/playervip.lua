
local m_playervip_vipcost = 9800

function playervip_onopen()
    m_uioverview_playermain:setwidgetdelegate("tab_vip/button_pay", playervip_delegate_pay)
end

function playervip_updateui()
    local text_viptime = m_uioverview_playermain:getwidget("tab_vip/text_viptime")
    local viptime = "PLAYER_INFO_VIPNONE"
    if playerattr_info.viptime > time_game then
        viptime = timerdesc_getafter(playerattr_info.viptime - time_game)
    end
    text_viptime:settext("PLAYER_INFO_VIPTIME", viptime)

    local text_vipdesc = m_uioverview_playermain:getwidget("tab_vip/text_vipdesc")
    text_vipdesc:settext("PLAYER_INFO_VIPDESC")
    text_vipdesc:setavailablecolor(playerattr_info.viptime > time_game)

    local text_vipprice = m_uioverview_playermain:getwidget("tab_vip/text_vipprice")
    text_vipprice:settext("PLAYER_INFO_VIPPRICE", m_playervip_vipcost)
end

function playervip_unlock_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_VIPBuy"}
        msg.currentcash = playerattr_info.cash
        c_send(msg)
    end
end
function playervip_delegate_pay(sender, event)
    local text = c_textformat("PLAYER_INFO_VIPPAYCOMFIRM", m_playervip_vipcost)
    messagebox_confirm(text, playervip_unlock_confirm)
end
