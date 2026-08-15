
local m_abyss_warningtype = 
{
    door = 0,
    doorrepair = 1,
    shield = 2,
    boss = 3,
}

function SC_AbyssCastleCiv(msg)
    local abyss = serverattr_abysscastle[msg.id]
    if abyss ~= nil then
        local config_castle = c_config_getmetaid(configid.abyss_castle, msg.id)
        if abyss.civ ~= msg.civ and config_castle ~= nil and config_castle.mapid == scene_getmapid()  then
            if abyss.civ == playerattr_info.civ then
                audiomanager_playaudioui(AudioCastleLost)
            elseif msg.civ == playerattr_info.civ then
                audiomanager_playaudioui(AudioCastleGet)
            end
            local text = textformat_args("STR_ABYSS_WIN_CASTLE", c_textformat(getplayercivtext(msg.civ)), config_castle.name)
            chat_addsystemalert(text)
        end
        abyss.civ = msg.civ
        abyss.mist = 0
        abyss.teleport = 0
        abyss.shield = 0
        abyss.carrier = 0
        sceneentity_updatecastleshield(abyss)
    end
end

function SC_AbyssCastleMist(msg)
    local abyss = serverattr_abysscastle[msg.id]
    if abyss ~= nil then
        local config_castle = c_config_getmetaid(configid.abyss_castle, msg.id)
        abyss.mist = msg.mist
        if abyss.mist == 1 then
            if config_castle ~= nil then
                if config_castle.mapid == scene_getmapid() then
                    audiomanager_playaudioui(AudioCastleMistStart)
                    audiomanager_setrepeatframe(AudioCastleMistStart, 60)
                end
                chat_addsystemalert(textformat_args("STR_ABYSS_PVP_ON", config_castle.name))
            end
        else
            if config_castle ~= nil then
                if config_castle.mapid == scene_getmapid() then
                    audiomanager_playaudioui(AudioCastleMistFinish)
                    audiomanager_setrepeatframe(AudioCastleMistFinish, 60)
                end
                chat_addsystemalert(textformat_args("STR_ABYSS_PVP_OFF", config_castle.name))
            end
        end
        sceneentity_updatecastlelogo(abyss.id, abyss.civ)
        sceneentity_updatecastleshield(abyss)
    end
end

function SC_AbyssCastleTeleporter(msg)
    local abyss = serverattr_abysscastle[msg.id]
    if abyss ~= nil then
        abyss.teleport = msg.teleport
    end
end

function SC_AbyssCastleShield(msg)
    local abyss = serverattr_abysscastle[msg.id]
    if abyss ~= nil then
        abyss.shield = msg.shield
        sceneentity_updatecastleshield(abyss)
    end
end

function SC_AbyssCastleNPCHurt(msg)
    if msg.type == m_abyss_warningtype.door then
        chat_addsystemalert("STR_ABYSS_DOOR_ATTACKED")
    elseif msg.type == m_abyss_warningtype.doorrepair then
        chat_addsystemalert("STR_ABYSS_REPAIR_ATTACKED")
    elseif msg.type == m_abyss_warningtype.shield then
        chat_addsystemalert("STR_ABYSS_SHIELD_ATTACKED")
    elseif msg.type == m_abyss_warningtype.boss then
        chat_addsystemalert("STR_ABYSS_BOSS_ATTACKED")
    end
    audiomanager_playaudioui(AudioCastleNPCHurt)
end

function SC_AbyssCastleNPCDead(msg)
    if msg.type == m_abyss_warningtype.door then
        local text = textformat_args("STR_ABYSS_DOOR_BROKEN", c_textformat(getplayercivtext(msg.civ)), msg.playername)
        chat_addsystemalert(text)
        audiomanager_playaudioui(AudioCastleDoorDead)
    elseif msg.type == m_abyss_warningtype.doorrepair then
        local text = textformat_args("STR_ABYSS_REPAIR_BROKEN", c_textformat(getplayercivtext(msg.civ)), msg.playername)
        chat_addsystemalert(text)
    elseif msg.type == m_abyss_warningtype.shield then
        local text = textformat_args("STR_ABYSS_SHIELD_BROKEN", c_textformat(getplayercivtext(msg.civ)), msg.playername)
        chat_addsystemalert(text)
    elseif msg.type == m_abyss_warningtype.boss then
        audiomanager_playaudioui(AudioCastleBossDead)
    end
end

function SC_AbyssCastleCarrier(msg)
    local abyss = serverattr_abysscastle[msg.id]
    if abyss ~= nil then
        local config_castle = c_config_getmetaid(configid.abyss_castle, msg.id)
        if msg.state == 1 then
            if config_castle ~= nil and config_castle.mapid == scene_getmapid() then
                audiomanager_playaudioui(AudioCastleCarrierStart)
            end
            abyss.carrier = time_game + time_abysscarrier_spawn
            chat_addsystemalert("STR_FIELDABYSS_CARRIER_SPAWN")
        elseif msg.state == 2 then
            if config_castle ~= nil and config_castle.mapid == scene_getmapid() then
                audiomanager_playaudioui(AudioCastleCarrierStrong)
            end
            abyss.carrier = 0
            chat_addsystemalert("STR_FIELDABYSS_CARRIER_DROP_DRAGON")
        end
    end
end

function SC_AbyssArtifact(msg)
    local abyss = serverattr_abyssartifact[msg.id]
    if abyss == nil then
        abyss = {}
        serverattr_abyssartifact[msg.id] = abyss
    end
    if abyss.civ ~= msg.civ then
        local config_artifact = c_config_getmetaid(configid.abyss_artifact, msg.id)
        if config_artifact ~= nil and config_artifact.abyss ~= 0 then
            if msg.civ == playerattr_info.civ then
                audiomanager_playaudioui(AudioArtifactGet)
                local text = textformat_args("STR_EVENT_WIN_ARTIFACT", c_textformat(getplayercivtext(msg.civ)), config_artifact.name)
                chat_addsystemalert(text)
            else
                audiomanager_playaudioui(AudioArtifactLost)
                local text = textformat_args("STR_EVENT_LOSE_ARTIFACT", c_textformat(getplayercivtext(msg.civ)), config_artifact.name)
                chat_addsystemalert(text)
            end
        end
    end
    abyss.civ = msg.civ
    sceneentity_updatecastlelogo(abyss.id, abyss.civ)
end

function SC_AbyssArtifactQuery(msg)
    artifact_setartifact(msg.actorid, msg.artifactid, msg.cd)
end

function SC_AbyssArtifactSpell(msg)
    local config_artifact = c_config_getmetaid(configid.abyss_artifact, msg.artifactid)
    if config_artifact ~= nil then
        chat_addsystemalert(textformat_args("STR_ARTIFACT_CASTING", c_textformat(getplayercivtext(msg.civ)), msg.playername, config_artifact.name))
    end
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil and actor:isstaticnpc() then
        actor.attr.npcstate = npcsyncstate.artifact
    end
    audiomanager_playaudioui(AudioArtifactCast)
end

function SC_AbyssArtifactSuccess(msg)
    local config_artifact = c_config_getmetaid(configid.abyss_artifact, msg.artifactid)
    if config_artifact ~= nil then
        chat_addsystemalert(textformat_args("STR_ARTIFACT_FIRE", c_textformat(getplayercivtext(msg.civ)), msg.playername, config_artifact.name))
    end
    audiomanager_playaudioui(AudioArtifactFire)
end

function SC_AbyssArtifactFail(msg)
    local config_artifact = c_config_getmetaid(configid.abyss_artifact, msg.artifactid)
    if config_artifact ~= nil then
        chat_addsystemalert(textformat_args("STR_ARTIFACT_CANCELED", c_textformat(getplayercivtext(msg.civ)), config_artifact.name))
    end
    local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil and actor:isstaticnpc() then
        actor.attr.npcstate = npcsyncstate.idle
    end
    audiomanager_playaudioui(AudioArtifactCancel)
end

function SC_AbyssDoorRepairQuery(msg)
    abyssrepair_setrepair(msg.actorid, msg.cd)
end

function SC_AbyssDoorRepair(msg)
    chat_addsystemalert(c_textformat("NPC_ABYSSREPAIR_SUCCESS",msg.name))
end
