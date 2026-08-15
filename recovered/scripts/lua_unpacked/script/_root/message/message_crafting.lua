
function SC_CraftingList(msg)
    playerattr_craftingskill = msg.skill
    playerattr_craftingrecipe = msg.recipe
end

function SC_CraftingGather(msg)
	local player = actormanager_getfromactorid(msg.playerid)
	local npc = actormanager_getfromactorid(msg.npcid)
	if player == nil or npc == nil or not npc:isharvest() then
		return
	end
	player:clearspell()
	player.actionmain.spelltype = playerspellstate.spellgather
	player.actionmain.target = msg.npcid
	player.actionmain.skillid = 0
	player.battle.spellanim = npc.config_npc.anim
	if player:isme() then
		crafting_progress_create(msg.skillid, msg.itemid, 1, 0)
	end
end

function SC_CraftingGatherComplete(msg)
	local player = actormanager_getfromactorid(msg.playerid)
	local npc = actormanager_getfromactorid(msg.npcid)
	if player == nil or npc == nil or not npc:isharvest() then
		return
	end
	player:clearspell()
	if msg.success >= 0 then
		player.actionmain.spelltype = playerspellstate.spellgathercomplete
		player.actionmain.skillid = 0
		player.battle.spellanim = npc.config_npc.anim
		player.battle.spellsuccess = msg.success
	end
	if player:isme() then
		crafting_progress_close()
	end
end

function SC_CraftingSpell(msg)
	crafting_progress_setprogress(msg.color, msg.success, msg.fail)
end

function SC_CraftingConvertStart(msg)
	local player = actormanager_getfromactorid(msg.playerid)
	if player == nil then
		return
	end
	player:clearspell()
	player.actionmain.spelltype = playerspellstate.spellconvert
	if player:isme() then
		local config_recipe = csvcraftingrecipe_getfromid(msg.recipeid)
		if config_recipe ~= nil then
			local name = nil
			if msg.batchcount > 1 then
				local name = string.format("%s(%d)", config_recipe.name, msg.batchcount)
				spell_create(name, spellcolor.normal, time_game, msg.time, {recipeid = msg.recipeid, batchount = msg.batchcount})
			else
				spell_create(config_recipe.name, spellcolor.normal, time_game, msg.time)
			end
		end
	end
end

function SC_CraftingConvertComplete(msg)
	local player = actormanager_getfromactorid(msg.playerid)
	if player == nil then
		return
	end
	player:clearspell()
	if player:isme() then
		spell_setstate(spellstate.complete)
		local data = spell_getdata()
		if data ~= nil and data.batchount > 1 then
			local msgconvert = {messageid="CS_CraftingConvert"}
			msgconvert.recipeid = data.recipeid
			msgconvert.batchcount = data.batchount - 1
			c_send(msgconvert)
		end
	end
end

function SC_RecipeAdd(msg)
	for i=1,#playerattr_craftingrecipe do
		if playerattr_craftingrecipe[i].recipeid == msg.recipeid then
			playerattr_craftingrecipe[i].limit = msg.limit
			craftingproduct_updatelist()
			return
		end
	end
	playerattr_craftingrecipe[#playerattr_craftingrecipe + 1] = msg
	craftingproduct_updatelist()
end

function SC_RecipeRemove(msg)
	for i=1,#playerattr_craftingrecipe do
		if playerattr_craftingrecipe[i].recipeid == msg.recipeid then
			table.remove(playerattr_craftingrecipe, i)
			break
		end
	end
	craftingproduct_updatelist()
end

function SC_RecipeMakeStart(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor == nil then
		return
	end
	actor:clearspell()
	actor.actionmain.spelltype = playerspellstate.spellcrafting
	actor.actionmain.skillid = msg.skillid
	if actor:isme() then
		crafting_progress_create(msg.skillid, msg.itemid, msg.batchcount, msg.critical)
		if msg.critical > 0 then
			audiomanager_playaudioui(AudioSocialCombo)
		end
	end
end

function SC_RecipeMakeComplete(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor == nil then
		return
	end
	actor:clearspell()
	if msg.success >= 0 then
		actor.actionmain.spelltype = playerspellstate.spellcraftingcomplete
		actor.actionmain.skillid = msg.skillid
		actor.battle.spellsuccess = msg.success
	end
	if actor:isme() then
		local batchcount = crafting_progress_getbatch()
		if batchcount > 1 then
			local msgmake = {messageid="CS_RecipeMake"}
            msgmake.entityid = msg.entityid
            msgmake.recipeid = msg.recipeid
			msgmake.recipequest = msg.recipequest
            msgmake.batchcount = batchcount - 1
            c_send(msgmake)
		end
		crafting_progress_close()
	end
end

function SC_CraftingSkillExp(msg)
	local skill = playerskill_getcraftingskill(msg.skillid)
	if skill ~= nil then
		if msg.level > skill.level then
			local config_skill = csvskill_getfromid(skill.skillid)
			if config_skill ~= nil then
				local text = c_textformat("CRAFTING_SKILL_LEVELUP", config_skill.name, msg.level)
				chat_addsystemalert(text)
			end
		end
	else
		skill = {}
		skill.skillid = msg.skillid
		playerattr_craftingskill[#playerattr_craftingskill + 1] = skill
		local config_skill = csvskill_getfromid(skill.skillid)
		if config_skill ~= nil then
			local text = c_textformat("CRAFTING_SKILL_LEVELUP", config_skill.name, 1)
			chat_addsystemalert(text)
		end
	end
	skill.level = msg.level
	skill.levelmax = msg.levelmax
	skill.exp = msg.exp
	skill.expmax = msg.expmax
	skill_main_updateui()
	crafting_recipe_updateskill()
	actormanager_updateharvesticon()
end

function SC_CraftingSkillRemove(msg)
	for i=1,#playerattr_craftingskill do
		if playerattr_craftingskill[i].skillid == msg.skillid then
			table.remove(playerattr_craftingskill, i)
			break
		end
	end
	skill_main_updateui()
	crafting_recipe_updateskill()
end
