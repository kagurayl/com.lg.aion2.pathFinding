
function action_staticteleport_enter(actor)
    if actor:isstaticnpc() then
        local alias = entitymanager_playentityanim(actor.config_npcstatic.staticid, "nwork_001", 0)
        if alias ~= nil then
            actor.actionmain.actioncomplete = time_game + alias.length
        else
            actor.actionmain.actioncomplete = 0
        end
    end
end

function action_staticteleport_update(actor)
    if actor.actionmain.actioncomplete < time_game then
        actor.actionmain.actioncomplete = 0
        actor.attr.npcstate = npcsyncstate.idle
    end
end
