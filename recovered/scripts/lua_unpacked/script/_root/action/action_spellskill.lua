
function action_spellskill_enter(actor)
    if actor.actordata.vfxspell ~= nil then
        actor.actordata.vfxspell:setfade()
		actor.actordata.vfxspell = nil
	end
    local config_skill = actor.actionmain.config_skill
    if actor.actionmain.target ~= nil and actor.actionmain.target ~= actor.actorid and playerskill_selectrotate(config_skill) then
        local target = actormanager_getfromactorid(actor.actionmain.target)
        if target ~= nil then
            actor:setactorlook(target)
        end
    end
    actor.battle.spellactionskillid = actor.actionmain.skillid
    local animname, speed = actor:getskillanimname(csvskillanimtype.cast, config_skill)
    if animname ~= nil then
        speed = speed * actor:getattackanimspeed()
        local fxspell = config_skill.fxspell
        actor.actordata.vfxspell = actor:createskillfxc(fxspell, bit.bor(vfxflag.followposscale, vfxflag.hidewithbuff), actor.actorid, actor.actionmain.target)
        local audio = csvconfig_getsubvalue(fxspell, 3, configsubtype.str)
        actor:playanim(animname, 0, speed, nil, nil, audio)
    end
    actor:updateweaponvisible()
end

function action_spellskill_leave(actor)
    if actor.actionmain.spelltype == playerspellstate.spellskill then
        actor:clearspell()
    end
    if actor.actordata.vfxspell ~= nil then
		actor.actordata.vfxspell:setfade()
		actor.actordata.vfxspell = nil
	end
    actor:updateweaponvisible()
end

function action_spellskill_move(actor)
    actor:clearspell()
    return false
end

function action_spellskill_update(actor)
    if actor.actionmain.skillid ~= nil then
        if actor.battle.spellactionskillid ~= actor.actionmain.skillid then
            action_spellskill_enter(actor)
        end
    end
    actor:movememove()
end
