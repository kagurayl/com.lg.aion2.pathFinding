
local m_uiarena_stage = uipanel_createhandle("dungeon/arena_stage", uilayer.top, 0)

function arenastage_create(stage, round)
    m_uiarena_stage:open()
    local text_stage = m_uiarena_stage:getwidget("text_stage")
    local text_round = m_uiarena_stage:getwidget("text_round")
    if stage > 0 then
        text_stage:settext("DUNGEON_ARENA_STAGE", stage)
        text_round:settext("DUNGEON_ARENA_ROUND", round)
    else
        text_stage:settext("DUNGEON_ARENA_ROUND", round)
        text_round:settext("DUNGEON_ARENA_START")
    end
    m_uiarena_stage.timeclose = time_game + 2
    audiomanager_playaudioui(DungeonArenaStart)
    event_register(eventtype.update, arenastage_update, m_uiarena_stage)
end

function arenastage_update()
    if m_uiarena_stage.timeclose < time_game then
        m_uiarena_stage:close()
    end
end
