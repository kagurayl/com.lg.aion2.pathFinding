
local darkpoetastate =
{
    wait = 0,
    playing = 1,
    finish = 2,
}

local m_uidungeon_darkpoeta = uipanel_createhandle("dungeon/dungeon_darkpoeta", uilayer.score, bit.bor(uiflag.scale, uiflag.holdonclear))

function dungeon_darkpoeta_settext(state, score, time)
    if state == darkpoetastate.wait or state == darkpoetastate.playing then
        m_uidungeon_darkpoeta:open()
        local text_score = m_uidungeon_darkpoeta:getwidget("text_score")
        text_score:settext(score)

        m_uidungeon_darkpoeta.timestart = time_game
        m_uidungeon_darkpoeta.timelength = time

        event_register(eventtype.update, dungeon_darkpoeta_update, m_uidungeon_darkpoeta)
    else
        m_uidungeon_darkpoeta:close()
    end
end

function dungeon_darkpoeta_update()
    local text_time = m_uidungeon_darkpoeta:getwidget("text_time")

    local cost = time_game - m_uidungeon_darkpoeta.timestart
    local second = m_uidungeon_darkpoeta.timelength - cost
    second = math.max(second, 0)
    local hour = math.tointegerfloor(second / 3600)
    local minute = math.fmod(math.tointegerfloor(second / 60), 60)
    second = math.fmod(math.tointegerfloor(second), 60)
    local text = string.format("%02d:%02d:%02d", hour, minute, second)
    text_time:settext(text)
end

function dungeon_darkpoeta_close()
    m_uidungeon_darkpoeta:close()
end
