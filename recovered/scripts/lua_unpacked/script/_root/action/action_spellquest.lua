
function action_spellquest_enter(actor)
    if actor.actionmain.target ~= nil and actor.actionmain.target ~= actor.actorid then
        local target = actormanager_getfromactorid(actor.actionmain.target)
        if target ~= nil then
            local lambda = csvnpc_getscript(target.config_npc, "talkanim")
            if lambda ~= nil then
                local animname = lambda.variable[1].str
                local anim = animlist["spellquest_" .. animname]
                if anim == nil then
                    animlist_addsimple("spellquest_" .. animname, "n" .. animname, 0)
                    anim = animlist["spellquest_" .. animname]
                end
                actor:playanimlist(anim)
            end
        end
    end
end

function action_spellquest_update(actor)
    actor:movememove()
end
