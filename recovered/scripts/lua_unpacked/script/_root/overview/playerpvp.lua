
function playerpvp_updateui()
    if m_uioverview_playermain:null() then
        return
    end
    m_uioverview_playermain:setwidgetdelegate("tab_pvp/button_openrank", playerpvp_delegate_openrank)

    local text_current_level = m_uioverview_playermain:getwidget("tab_pvp/text_current_level")
    if playerattr_info.civ == playerciv.light then
        text_current_level:settext("PLAYER_PVPLEVEL_LIGHT" .. playerattr_pvp.title)
    else
        text_current_level:settext("PLAYER_PVPLEVEL_DARK" .. playerattr_pvp.title)
    end
    local text_current_score = m_uioverview_playermain:getwidget("tab_pvp/text_current_score")
    text_current_score:settext(playerattr_pvp.score)

    local text_current_rank = m_uioverview_playermain:getwidget("tab_pvp/text_current_rank")
    if playerattr_pvp.rank >= 0 and playerattr_pvp.rank <= 1000 then
        text_current_rank:settext("PLAYER_PVPINFO_RANK", playerattr_pvp.rank + 1)
    else
        text_current_rank:settext("PLAYER_PVPINFO_OUTRANK")
    end

    local config_next = c_config_getindex(configid.pvpscore, playerattr_pvp.title + 1)
    local progress_score = m_uioverview_playermain:getwidget("tab_pvp/progress_score")
    local text_next_level = m_uioverview_playermain:getwidget("tab_pvp/text_next_level")
    local text_next_score = m_uioverview_playermain:getwidget("tab_pvp/text_next_score")
    local text_next_rank = m_uioverview_playermain:getwidget("tab_pvp/text_next_rank")
    if config_next ~= nil then
        progress_score:setpercent(playerattr_pvp.score / config_next.score)
        if playerattr_info.civ == playerciv.light then
            text_next_level:settext("PLAYER_PVPLEVEL_LIGHT" .. playerattr_pvp.title + 1)
        else
            text_next_level:settext("PLAYER_PVPLEVEL_DARK" .. playerattr_pvp.title + 1)
        end
        text_next_score:settext(config_next.score)
        if config_next.rank > 0 then
            text_next_rank:settext("PLAYER_PVPINFO_RANK", config_next.rank)
        else
            text_next_rank:settext("PLAYER_PVPINFO_OUTRANK")
        end
    else
        progress_score:setpercent(0)
        text_next_level:settext("-")
        text_next_score:settext("-")
        text_next_rank:settext("-")
    end

    local text_today_kill = m_uioverview_playermain:getwidget("tab_pvp/text_today_kill")
    text_today_kill:settext(playerattr_pvp.kill_today)

    local text_today_score = m_uioverview_playermain:getwidget("tab_pvp/text_today_score")
    text_today_score:settext(playerattr_pvp.score_today)

    local text_week_kill = m_uioverview_playermain:getwidget("tab_pvp/text_week_kill")
    text_week_kill:settext(playerattr_pvp.kill_week)

    local text_week_score = m_uioverview_playermain:getwidget("tab_pvp/text_week_score")
    text_week_score:settext(playerattr_pvp.score_week)

    local text_lastweek_kill = m_uioverview_playermain:getwidget("tab_pvp/text_lastweek_kill")
    text_lastweek_kill:settext(playerattr_pvp.kill_lastweek)

    local text_lastweek_score = m_uioverview_playermain:getwidget("tab_pvp/text_lastweek_score")
    text_lastweek_score:settext(playerattr_pvp.score_lastweek)

    local text_total_kill = m_uioverview_playermain:getwidget("tab_pvp/text_total_kill")
    text_total_kill:settext(playerattr_pvp.kill_total)

    local text_total_level = m_uioverview_playermain:getwidget("tab_pvp/text_total_level")
    if playerattr_info.civ == playerciv.light then
        text_total_level:settext("PLAYER_PVPLEVEL_LIGHT" .. playerattr_pvp.titletop)
    else
        text_total_level:settext("PLAYER_PVPLEVEL_DARK" .. playerattr_pvp.titletop)
    end
end

function playerpvp_delegate_openrank()
    rank_openplayerrank()
end
