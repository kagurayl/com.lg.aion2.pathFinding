include("action/animlist")
include("action/action_idle")
include("action/action_sequence")
include("action/action_windpath")
include("action/action_move")
include("action/action_movetoskill")
include("action/action_fly")
include("action/action_glide")
include("action/action_jump")
include("action/action_jumpland")
include("action/action_dead")
include("action/action_despawn")
include("action/action_battleattackplayer")
include("action/action_battleattacknpc")
include("action/action_battlehurt")
include("action/action_spellskill")
include("action/action_spellquest")
include("action/action_spellsocial")
include("action/action_spellitem")
include("action/action_spellitembind")
include("action/action_enchant")
include("action/action_immobilize")
include("action/action_npcinteract")
include("action/action_petplay")
include("action/action_equipweapon")
include("action/action_castplayer")
include("action/action_castplayermovable")
include("action/action_castnpc")
include("action/action_convert")
include("action/action_gather")
include("action/action_gathercomplete")
include("action/action_crafting")
include("action/action_craftingcomplete")
include("action/action_talknpc")
include("action/action_artifact")
include("action/action_staticidle")
include("action/action_staticteleport")
include("action/action_staticdead")
include("action/action_consumeitem")

actionname =
{
	idle = 2,
	move = 3,
	movetoskill = 4,
	glide = 5,
	fly = 6,
	jump = 7,
	jumpland = 8,
	windpath = 9,
	dead = 10,
	despawn = 11,
	equipweapon = 12,
	sequence = 13,
	battleattackplayer = 14,
	battleattacknpc = 15,
	battlehurt = 16,
	spellskill = 17,
	spellquest = 18,
	spellsocial = 19,
	spellitem = 20,
	spellitembind = 21,
	consumeitem = 22,
	enchant = 23,
	immobilize = 24,
	castplayer = 25,
	castplayermovable = 26,
	castnpc = 27,
	freeze = 28,
	convert = 29,
	gather = 30,
	gathercomplete = 31,
	crafting = 32,
	craftingcomplete = 33,
	pickitem = 34,
	talknpc = 35,
	artifact = 36,
	staticidle = 37,
	staticteleport = 38,
	staticdead = 39,
	npcinteract = 40,
	petplay = 41,
}

local m_actionmanager_actionarray = {}

local function actionmanager_getfunction(actionindex, actionname, funcname)
	local str = string.format("action_%s_%s", actionname, funcname)
	return _G[str]	
end

local function actionmanager_addaction(actionname, actionindex)
	local action = {}
	action.actionid = actionindex
	action.enter = actionmanager_getfunction(actionindex, actionname, "enter")
	action.update = actionmanager_getfunction(actionindex, actionname, "update")
	action.leave = actionmanager_getfunction(actionindex, actionname, "leave")
	action.move = actionmanager_getfunction(actionindex, actionname, "move")
	action.reload = actionmanager_getfunction(actionindex, actionname, "reload")
	m_actionmanager_actionarray[actionindex] = action
end

function actionmanager_init()
	for key, val in pairs(actionname) do
		actionmanager_addaction(key, val)
	end
	animlist_init()
end

local function actionmanager_getplayeraction(actor, moverequest)
	if actor.actordata.sequencetimestart ~= nil then
		return actionname.sequence
	end
	if actor.attr.movewindpathid ~= nil then
		return actionname.windpath
	end
	if actor.attr.deadtime ~= nil then
		return actionname.dead
	end
	if actor.actionmain.config_buffaction ~= nil then
		if actor.actionmain.config_buffaction.buffaction == buffactiontype.immobilize then
			return actionname.immobilize
		end
	end
	if actor.actionmain.spelltype ~= nil then
		if actor.actionmain.spelltype == playerspellstate.spellskill then
			return actionname.spellskill
		elseif actor.actionmain.spelltype == playerspellstate.spellcast then
			return actionname.castplayer
		elseif actor.actionmain.spelltype == playerspellstate.spellitem then
			return actionname.spellitem
		elseif actor.actionmain.spelltype == playerspellstate.spellquest then
			return actionname.spellquest
		elseif actor.actionmain.spelltype == playerspellstate.spellconvert then
			return actionname.convert
		elseif actor.actionmain.spelltype == playerspellstate.spellgather then
			return actionname.gather
		elseif actor.actionmain.spelltype == playerspellstate.spellgathercomplete then
			return actionname.gathercomplete
		elseif actor.actionmain.spelltype == playerspellstate.spellcrafting then
			return actionname.crafting
		elseif actor.actionmain.spelltype == playerspellstate.spellcraftingcomplete then
			return actionname.craftingcomplete
		elseif actor.actionmain.spelltype == playerspellstate.spellsocial then
			return actionname.spellsocial
		elseif actor.actionmain.spelltype == playerspellstate.spellitembind or actor.actionmain.spelltype == playerspellstate.spellitembindend then
			return actionname.spellitembind
		elseif actor.actionmain.spelltype == playerspellstate.enchantspell or actor.actionmain.spelltype == playerspellstate.enchantsuccess or actor.actionmain.spelltype == playerspellstate.enchantfail then
			return actionname.enchant
		elseif actor.actionmain.spelltype == playerspellstate.petplay then
			return actionname.petplay
		end
	end
	if actor.actionmain.talknpctype ~= nil then
		return actionname.talknpc
	end
	if actor.attr.movetype == playermovestate.glide or actor.actionmain.glidestate ~= nil then
		return actionname.glide
	end
	if actor.attr.movetype ~= playermovestate.fly then
		if not actor.transform.onfloor or actor.actionmain.jumpstate ~= nil then
			return actionname.jump
		end
	end
	if actor.attr.movetype == playermovestate.move or actor.attr.movetype == playermovestate.fly then
		if moverequest then
			if actor:isme() and playerapproach_moving() then
				return actionname.movetoskill
			end
			if actor.attr.movetype == playermovestate.move then
				return actionname.move
			elseif actor.attr.movetype == playermovestate.fly then
				return actionname.fly
			end
		end
	end
	return actionname.idle
end

local function actionmanager_getnpcaction(actor)
	if actor.attr.isdead > 0 then
		return actionname.dead
	end
	if actor.actionmain.config_buffaction ~= nil then
		if actor.actionmain.config_buffaction.buffaction == buffactiontype.immobilize then
			return actionname.immobilize
		end
	end
	if actor.attr.npcstate == npcsyncstate.movewalk or actor.attr.npcstate == npcsyncstate.moverun then
		if actor:ismoving() then
			return actionname.move
		end
	end
	if actor.attr.npcstate == npcsyncstate.despawn then
		return actionname.despawn
	end
	if actor.attr.npcstate == npcsyncstate.spell then
		return actionname.spellskill
	end
	if actor.attr.clientstate == npcclientstate.attack then
		return actionname.battleattacknpc
	end
	if actor.attr.clientstate == npcclientstate.cast then
		return actionname.castnpc
	end
	if actor.attr.clientstate == npcclientstate.despawn then
		return actionname.despawn
	end
	if actor.attr.clientstate == npcclientstate.interact then
		return actionname.npcinteract
	end
	return actionname.idle
end

local function actionmanager_getstaticnpcaction(actor)
	if actor.attr.isdead > 0 then
		return actionname.staticdead
	end
	if actor.attr.npcstate == npcsyncstate.artifact then
		return actionname.artifact
	end
	if actor.attr.npcstate == npcsyncstate.teleport then
		return actionname.staticteleport
	end
	return actionname.staticidle
end

local function actionmanager_updatestate(actor, state, action)
	if action == nil then
		return
	end
	if state.action ~= nil and state.action.actionid == action.actionid then
		return
	end
	if state.action ~= nil and state.action.leave ~= nil then
		state.action.leave(actor)
	end
	state.action = action
	state.timestart = time_game
	if state.action.enter ~= nil then
		state.action.enter(actor)
	end
end

function actionmanager_update(actor)
	local actionid = actionname.idle
	if actor:isplayer() then
		actor:resetaction()
		local moverequest = actor:ismoving()
		if moverequest and actor:isme() and actor.actionmain.action ~= nil and actor.actionmain.action.move ~= nil then
			moverequest = not actor.actionmain.action.move(actor)
		end
		actionid = actionmanager_getplayeraction(actor, moverequest)
	elseif actor:isdynamicnpc() then
		actionid = actionmanager_getnpcaction(actor)
	elseif actor:isstaticnpc() then
		actionid = actionmanager_getstaticnpcaction(actor)
	end
	if actor.actionmain.action ~= nil and actor.actionmain.action.actionid ~= actionid then
		if actor.actionadditive.action ~= nil and not actor.actionadditive.mixed then
			actor.actionadditive.complete = true
			actor.actionadditive.request = nil
		end
	end

	local requestaction = m_actionmanager_actionarray[actionid]
	actionmanager_updatestate(actor, actor.actionmain, requestaction)
	if actor.actionmain.action ~= nil and actor.actionmain.action.update ~= nil then
		actor.actionmain.action.update(actor)
	end

	if actor.actionadditive.request ~= nil then
		if actor.actionadditive.action ~= nil then
			if actor.actionadditive.action.leave ~= nil then
				actor.actionadditive.action.leave(actor)
			end
			actor.actionadditive.action = nil
		end
		actor.actionadditive.complete = false
		local additiverequest = m_actionmanager_actionarray[actor.actionadditive.request]
		actionmanager_updatestate(actor, actor.actionadditive, additiverequest)
		actor.actionadditive.request = nil
	end
	if actor.actionadditive.action ~= nil and actor.actionadditive.action.update ~= nil then
		actor.actionadditive.action.update(actor)
		if actor.actionadditive.complete then
			if actor.actionadditive.action.leave ~= nil then
				actor.actionadditive.action.leave(actor)
			end
			actor.actionadditive.action = nil
		end
	end
end

function actionmanager_reload(actor)
	if actor.actionmain.action ~= nil and actor.actionmain.action.reload ~= nil then
		actor.actionmain.action.reload(actor)
	end
end

function actionmanager_getactionid(actor)
	if actor.actionmain.action ~= nil then
		return actor.actionmain.action.actionid
	end
end

function actionmanager_playingadditive(actor)
	return actor.actionadditive.action ~= nil
end

function actionmanager_mixadditive(actor)
	if actor.actionmain.action ~= nil then
		local actionid = actor.actionmain.action.actionid
		return actionid ~= actionname.idle
		and actionid ~= actionname.immobilize
		and actionid ~= actionname.jump
	end
	return false
end

function actionmanager_setdamageaction(actor, accuracytype)
	if accuracytype ~= lambdaaccuracytype.shield and accuracytype ~= lambdaaccuracytype.protect and actor.actionadditive.action == nil then
		if actor:isplayer() then
			actor.actionadditive.request = actionname.battlehurt
			actor.actionadditive.accuracytype = accuracytype
		else
			if actor.actionmain.action ~= nil
			and actor.actionmain.action.actionid ~= actionname.battleattacknpc
			and actor.actionmain.action.actionid ~= actionname.spellskill
			and actor.actionmain.action.actionid ~= actionname.castnpc then
				actor.actionadditive.request = actionname.battlehurt
				actor.actionadditive.accuracytype = accuracytype
			end
		end
	end
end

function actionmanager_setattackaction(actor, target)
	actor:clearspell()
    if actor:isplayer() then
		actor.actionadditive.request = actionname.battleattackplayer
		actor.actionadditive.target = target
    else
        actor.attr.clientstate = npcclientstate.attack
		actor.actionmain.target = target
    end
end

function actionmanager_setcastaction(actor, instid, config_skill)
	if config_skill.anim ~= "0" then
		if actor:isplayer() then
			if config_skill.movable > 0 then
				actor.actionadditive.request = actionname.castplayermovable
				actor.actionadditive.castinstid = instid
				actor.actionadditive.config_skill = config_skill
			else
				actor:clearspell()
				actor.actionmain.spelltype = playerspellstate.spellcast
				actor.actionmain.castinstid = instid
				actor.actionmain.config_skill = config_skill	
			end
		else
			actor.attr.clientstate = npcclientstate.cast
			actor.actionmain.castinstid = instid
			actor.actionmain.config_skill = config_skill
		end
    end
end

function actionmanager_setitemaction(actor, config_item)
	if config_item.anim ~= nil and actor:isplayer() and actor.attr.movetype ~= playermovestate.rest then
		actor.actionadditive.request = actionname.consumeitem
		actor.actionadditive.config_item = config_item
	end
end
