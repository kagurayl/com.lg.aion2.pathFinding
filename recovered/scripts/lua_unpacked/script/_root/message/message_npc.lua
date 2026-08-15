
local function harvestenter_create(msg)
	local config_harvest = csvcraftingharvest_getfromid(msg.configid)
	if config_harvest == nil then
		debugerror("failed harvestenter_create:" .. msg.configid)
		return
	end

	local actor = actormanager_createactor(RenderLayerNPC, msg.actorid)
	actor.actortype = actorgametype.harvest
	actor.config_npc = config_harvest
	actor.attr = {}
	actor.actorid = msg.actorid
	actor.attr.name = config_harvest.name
	actor.attr.hp = 1.0
	actor.attr.hpmax = 1.0
	actor.attr.posx = msg.posx
	actor.attr.posy = msg.posy
	actor.attr.posz = msg.posz
	actor.attr.rot = 0.0
	actor.attr.aerial = msg.aerial
	actor:initattr(nil)
	actor:updateharvesticon()
end

function SC_HarvestEnter(msg)
	harvestenter_create(msg.info)
end

function SC_HarvestEnterArray(msg)
	for i=1,#msg.info do
		harvestenter_create(msg.info[i])
	end
end

local function npcenter_create(msg)
	local config_npc = csvnpc_getfromid(msg.configid)
	if config_npc == nil then
		debugerror("failed npcenter_create:" .. msg.configid)
		return
	end
	local config_static = nil
	if msg.staticid ~= 0 then
		config_static = csvnpcstatic_getfromid(scene_getmapid(), msg.staticid)
		if config_static == nil then
			debugerror("failed npcenter_createstatic:" .. msg.staticid)
			return
		end
	end
	local actorlayer = RenderLayerNPC
	local spiritownername = nil
	if actoridisplayer(msg.spiritowner) then
		local owner = actormanager_getfromactorid(msg.spiritowner)
		if owner ~= nil then
			spiritownername = owner.attr.name
			if owner:isme() then
				if config_npc.tribe == "pet" or config_npc.tribe == "pet_dark" then
					actorlayer = RenderLayerMe
				end
			end
		end
	end
	local actor = actormanager_createactor(actorlayer, msg.actorid)
	actor.config_npc = config_npc
	actor.config_npcstatic = config_static
	if config_static ~= nil then
		actormanager_addentity(msg.staticid, msg.actorid)
		actor.actortype = actorgametype.staticnpc
		actor.actorstaticmesh = 1
	else
		actor.actortype = actorgametype.npc
	end
	actor.attr = {}
	actor.actorid = msg.actorid
	actor.attr.spiritowner = msg.spiritowner
	actor.attr.spiritownername = spiritownername
	actor.attr.name = config_npc.name
	actor.attr.hp = msg.hp
	actor.attr.hpmax = msg.hpmax
	actor.attr.attackspeed = msg.attackspeed
	actor.attr.posx = msg.posx
	actor.attr.posy = msg.posy
	actor.attr.posz = msg.posz
	actor.attr.rot = msg.rot
	
	actor.attr.civ = config_npc.civ
	actor.attr.level = config_npc.level
	actor.attr.npcstate = msg.state
	actor.attr.clientstate = npcclientstate.none
	actor.attr.aerial = msg.aerial
	actor.attr.qskmember = msg.qskmember
	actor.attr.qskremain = msg.qskremain
	actor.attr.qsktime = time_game + msg.qsktime
	actor.attr.isdead = msg.dead
	actor:movesetnpcmovesync(msg.destx, msg.desty, msg.destz, msg.speed, msg.moveanim)
	actor.actionmain.skillid = msg.skillid
	if actor.actionmain.skillid ~= 0 then
		actor.actionmain.config_skill = csvskill_getfromid(actor.actionmain.skillid)
	end
	actor.battle.spelltime = msg.skilltime
	actor.battle.spelltimestart = time_game - msg.skilltimecost
	if actor:isdead() then
		actor.attr.dropstate = msg.dropstate
		actor.attr.dropowner = msg.dropowner
	else
		actor.attr.selection = msg.targetid
	end
	actor:initattr(msg.buff)
	if actor.actorid == playerattr_info.spiritid then
		sidebar_updateteam()
		playerinfo_updatespirit()
	end
end

function SC_NPCEnter(msg)
	npcenter_create(msg.info)
end

function SC_NPCEnterArray(msg)
	for i=1,#msg.info do
		npcenter_create(msg.info[i])
	end
end

function SC_NPCAggressive(msg)
	if m_selectactorid ~= msg.actorid then
		local npc = actormanager_getfromactorid(msg.actorid)
		if npc ~= nil then
			audiomanager_playaudioui(AudioMonsterDiscovery)
		end
	end
end

function SC_NPCMoveBack(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		chat_addsystem(textformat_args("STR_UI_COMBAT_NPC_RETURN", npc.attr.name))
		audiomanager_playaudioui(AudioMonsterPass)
	end
end

function SC_NPCDead(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor == nil then
		return
	end
	actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
	actor:stopmove()
	actor.attr.hp = 0
	actor.attr.isdead = 1
	actor.attr.npcstate = npcsyncstate.deadanim
	actor.attr.dropstate = msg.dropstate
	actor.attr.dropowner = msg.dropowner
	actor:loadboundbox()
	if actor:isdynamicnpc() then
		actor:loaddropvfx()
	end
	for i=1,#actor.buff do
		actor:removebuffvfx(actor.buff[i])
	end
	actor.buff = {}
end

function SC_NPCTalk(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc == nil then
		npc_closedialog()
		return
	end
	dialog_main_setdialog(msg.type, msg.actorid, npc.config_npc, msg.questid, msg.name)
	if m_uinpc_dialogmain:alive()
	and npc:isdynamicnpc()
	and csvnpc_getscript(npc.config_npc, "rest") == nil
	and csvnpc_gettalkrotate(npc.config_npc) then
		npc:setactorlook(m_me)
	end
end

function SC_NPCTalkClose(msg)
	npc_closedialog()
end

function SC_NPCInteract(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		npc.attr.clientstate = npcclientstate.interact
	end
end

function SC_NPCIdle(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		npc.attr.npcstate = npcsyncstate.idle
		npc:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
		npc:stopmove()
	end
end

function SC_NPCRotation(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		npc:setrotation(msg.rot)
	end
end

function SC_NPCShare(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		npc.attr.dropstate = msg.dropstate
		npc:loaddropvfx()
	end
end

function SC_NPCQueryDropItem(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		pickitem_setnpc(npc, msg.item)
	end
end

function SC_NPCQueryDropState(msg)
	local player = actormanager_getfromactorid(msg.playerid)
	if player ~= nil then
		if msg.npcid ~= 0 then
			player.actionmain.talknpctype = npcmotiontype.pickitem
			player.actionmain.talknpc = msg.npcid
		else
			if player.actionmain.talknpctype == npcmotiontype.pickitem then
				player.actionmain.talknpctype = nil
			end
			if player:isme() then
				pickitem_closefromserver()
			end
		end
	end
end

function SC_NPCPickDrop(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		pickitem_removeitem(npc, msg.pickid)
	end
end

function SC_NPCDisappear(msg)
	local npc = actormanager_getfromactorid(msg.actorid)
	if npc ~= nil then
		actormanager_disappear(npc, 1.0)
	end
end

function SC_NPCBattleSpell(msg)
	local config_skill = csvskill_getfromid(msg.skillid)
	if config_skill ~= nil then
		local actor = actormanager_getfromactorid(msg.actorid)
		if actor ~= nil then
			actor.attr.npcstate = npcsyncstate.spell
			actor.actionmain.skillid = msg.skillid
			actor.actionmain.config_skill = config_skill
			actor.battle.spelltime = msg.spelltime
			actor.battle.spelltimestart = time_game
			actor.actionmain.target = msg.targetid
			if csvskill_isattackskill(config_skill) and msg.targetid == playerattr_info.actorid and m_selectactorid == 0 then
				actormanager_selectactor(actor)
			end
		end
	end
end

function SC_NPCBattleSpellCancel(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor.attr.npcstate == npcsyncstate.spell then
			actor.attr.npcstate = npcsyncstate.idle
		end
	end
end

function SC_NPCBattleHurtCiv(msg)
	abyss_bosshurt_settext(msg)
end

function SC_QuestSpell(msg)
	local player = actormanager_getfromactorid(msg.playerid)
    if player == nil then
        return
    end
    local npc = actormanager_getfromactorid(msg.npcid)
    if npc == nil then
        return
    end
	player:clearspell()
	player.actionmain.spelltype = playerspellstate.spellquest
    player.battle.spelltime = msg.time
    player.actionmain.target = msg.npcid
	player:setactorlook(npc)

    if player:isme() then
        spell_create("NPC_QUEST_SPELL", spellcolor.normal, time_game, msg.time)
    end
end
