
local m_uiquesttime = uipanel_createhandle("quest/questtime", uilayer.score, uiflag.holdonclear)

function questtime_onopen()
    event_register(eventtype.update, questtime_update, m_uiquesttime)
end

function questtime_update()
    local timedesc = timerdesc_getafter(m_uiquesttime.timesecond - time_game)

    local textdesc = c_textformat("QUEST_TIMEUPDATE", timedesc)
    local text_message = m_uiquesttime:getwidget("text_message")
    text_message:setrichtext(textdesc)

    local quest = playerquest_getquest(m_uiquesttime.questid)
    if quest == nil or quest.step ~= m_uiquesttime.queststep then
        questtime_close()
    end
end

function questtime_create(questid, queststep, timesecond)
    if timesecond > 0 then
        m_uiquesttime:open()
        m_uiquesttime.questid = questid
        m_uiquesttime.queststep = queststep + 1
        m_uiquesttime.timesecond = time_game + timesecond
    else
        m_uiquesttime:close()    
    end
end

function questtime_close()
    m_uiquesttime:close()
end
