
function action_despawn_enter(actor)
    if actor:isplayer() then
        
    else
        actor:playanimlist(animlist.npcdespawn)
    end
end
