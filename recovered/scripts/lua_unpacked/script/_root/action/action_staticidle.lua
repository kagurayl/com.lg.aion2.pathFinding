
function action_staticidle_enter(actor)
    if actor:isstaticnpc() then
        entitymanager_playentityanim(actor.config_npcstatic.staticid, "nidle_001", actorrenderflag.loopanim)
    end
end
