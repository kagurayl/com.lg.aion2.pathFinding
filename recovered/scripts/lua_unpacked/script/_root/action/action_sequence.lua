
function action_sequence_update(actor)
    if actor.actordata.sequenceanim ~= nil then
        actor:playanim(string.lower(actor.actordata.sequenceanim), 0, actor.actordata.sequenceanimspeed, actor.actordata.sequenceanimblend, actor.actordata.sequenceanimskip)
        actor.actordata.sequenceanim = nil
        actor.actordata.sequenceanimblend = nil
        actor.actordata.sequenceanimskip = nil
        actor.actordata.sequenceanimspeed = nil
    end
end
