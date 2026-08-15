
function action_staticdead_enter(actor)
    if actor:isstaticnpc() then
        entitymanager_playentityanim(actor.config_npcstatic.staticid, "cdie_noweapon_001", 0)
    end
end
