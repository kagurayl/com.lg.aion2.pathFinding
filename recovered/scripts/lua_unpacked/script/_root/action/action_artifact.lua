
function action_artifact_enter(actor)
    actor.actionmain.artifactcoretime = nil
    actor.actionmain.actioncomplete = 0
    if actor:isstaticnpc() then
        local alias = entitymanager_playentityanim(actor.config_npcstatic.staticid, "cidle_noweapon_001", 0)
        if alias ~= nil then
            actor.actionmain.actioncomplete = time_game + alias.length
            actor.actionmain.artifactcoretime = time_game + alias.length / 2
        end
    end
end

function action_artifact_update(actor)
    if actor.actionmain.artifactcoretime ~= nil and actor.actionmain.artifactcoretime < time_game then
        audiomanager_playaudioui(AudioArtifactCore)
        actor.actionmain.artifactcoretime = nil
    end
    if actor.actionmain.actioncomplete < time_game then
        actor.actionmain.actioncomplete = 0
        actor.attr.npcstate = npcsyncstate.idle
    end
end
