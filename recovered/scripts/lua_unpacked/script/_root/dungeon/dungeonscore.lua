
dungeonscoretype =
{
    dredgion = 1,
    arenapvp = 2,
}

local m_uidungeon_score = uipanel_createhandle("dungeon/dungeon_score", uilayer.score, bit.bor(uiflag.scale, uiflag.holdonclear))

function dungeon_score_onopen()
    m_uidungeon_score:setwidgetdelegate("button_click", dungeon_score_delegate_scorelist)
end

function dungeon_score_settype(type)
    m_uidungeon_score.scoretype = type
end

function dungeon_score_settext(teamtext, teamcolor, enemytext, enemycolor)
    m_uidungeon_score:open()
    if teamtext ~= nil then
        local text_scoreteam = m_uidungeon_score:getwidget("text_scoreteam")
        text_scoreteam:settext(teamtext)
        text_scoreteam:sethexcolor(teamcolor)
    end

    if enemytext ~= nil then
        local text_scoreenemy = m_uidungeon_score:getwidget("text_scoreenemy")
        text_scoreenemy:settext(enemytext)
        text_scoreenemy:sethexcolor(enemycolor)
    end
end

function dungeon_score_settimer(time, countdown)
    m_uidungeon_score:open()
    m_uidungeon_score.countdown = countdown
    if countdown then
        m_uidungeon_score.timestart = time_game
        m_uidungeon_score.timelength = time
    else
        m_uidungeon_score.timestart = time_game - time
    end
    event_register(eventtype.update, dungeon_score_update, m_uidungeon_score)
end

function dungeon_score_update()
    local text_time = m_uidungeon_score:getwidget("text_time")
    local second = 0
    local color = 0xffffffff
    if m_uidungeon_score.countdown then
        local cost = time_game - m_uidungeon_score.timestart
        second = m_uidungeon_score.timelength - cost
        color = 0xff0000ff
    else
        second = time_game - m_uidungeon_score.timestart
    end
    second = math.max(second, 0)
    local hour = math.tointegerfloor(second / 3600)
    local minute = math.fmod(math.tointegerfloor(second / 60), 60)
    second = math.fmod(math.tointegerfloor(second), 60)
    local text = string.format("%02d:%02d:%02d", hour, minute, second)
    text_time:settext(text)
    text_time:sethexcolor(color)
end

function dungeon_score_close()
    m_uidungeon_score:close()
end

function dungeon_score_delegate_scorelist()
    if m_uidungeon_score.scoretype == dungeonscoretype.dredgion then
        dredgion_scorelist_open()
    elseif m_uidungeon_score.scoretype == dungeonscoretype.arenapvp then
        arena_scorelist_open()
    end
end
