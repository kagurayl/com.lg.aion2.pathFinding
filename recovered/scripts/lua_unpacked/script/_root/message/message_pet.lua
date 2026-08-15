
function SC_PetList(msg)
	playerattr_petlist = msg.pet
	playerattr_info.petuuid = msg.activeuuid
	playerattr_info.petid = 0
	local pet = playerattr_getpet(msg.activeuuid)
	if pet ~= nil then
		playerattr_info.petid = pet.petid
	end
	pet_main_updateui()
end

function SC_PetAdopt(msg)
	playerattr_petlist[#playerattr_petlist + 1] = msg.pet
	local config_pet = csvpet_getfromid(msg.pet.petid)
	if config_pet ~= nil then
		chat_addsystemalert(c_textformat("PLAYER_PET_ADOPTSUCCESS", config_pet.name))
	end
	pet_main_openpet(msg.pet.uuid)
end

function SC_PetExpire(msg)
	for i=1,#playerattr_petlist do
		if playerattr_petlist[i].uuid == msg.uuid then
			local config_pet = csvpet_getfromid(playerattr_petlist[i].petid)
			if config_pet ~= nil then
				local text = c_textformat("PLAYER_PET_EXPIREDALERT", config_pet.name)
				chat_addsystemalert(text)
			end
			table.remove(playerattr_petlist, i)
			break
		end
	end
	if playerattr_info.petuuid == msg.uuid then
		playerattr_info.petuuid = 0
		playerattr_info.petid = 0
		if m_me ~= nil then
			m_me:updatepetid()
		end
	end
	pet_main_updateui()
end

function SC_PetAbando(msg)
	for i=1,#playerattr_petlist do
		if playerattr_petlist[i].uuid == msg.uuid then
			local config_pet = csvpet_getfromid(playerattr_petlist[i].petid)
			if config_pet ~= nil then
				local text = c_textformat("PLAYER_PET_ABADONALERT", config_pet.name)
				chat_addsystemalert(text)
			end
			table.remove(playerattr_petlist, i)
			break
		end
	end
	if playerattr_info.petuuid == msg.uuid then
		playerattr_info.petuuid = 0
		playerattr_info.petid = 0
		if m_me ~= nil then
			m_me:updatepetid()
		end
	end
	pet_main_updateui()
end

function SC_PetActive(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		playerattr_info.petuuid = msg.uuid
		playerattr_info.petid = pet.petid
	else
		playerattr_info.petuuid = 0
		playerattr_info.petid = 0
	end
	if m_me ~= nil then
		m_me:updatepetid()
	end
	pet_main_updateui()
end

function SC_PetRender(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.petid = msg.petid
		actor:updatepetid()
	end
end

function SC_PetRename(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.name = msg.name
		if m_me ~= nil then
			m_me:updatepetname()
		end
		pet_main_updateui()
	end
end

function SC_PetPlay(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		local config_social = csvskillsocial_getfromid(msg.socialid)
		if config_social ~= nil then
			actor:clearspell()
			actor.actionmain.spelltype = playerspellstate.petplay
			actor.actionmain.config_skill = config_social
			if actor.petactor ~= nil then
				actor:setactorlook(actor.petactor)
			end
		end
		actor:playpet(msg.socialid, msg.critical > 0)
	end
end

function SC_PetReward(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.reward = msg.reward
		pet_menu_updateui(msg.uuid)
	end
end

function SC_PetLoot(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.lootquality = msg.quality
		pet.lootquestitem = msg.questitem
		tabloot_updateui(msg.uuid)
	end
end

function SC_PetDop(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.dopitem = msg.itemid
		pet.dopactive = msg.active
		tabdop_updateui(msg.uuid)
	end
end

function SC_PetFeedSpell(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
		actor:clearspell()
    end
	if msg.actorid == playerattr_info.actorid then
		local config_item = csvitem_getfromid(msg.itemid)
		if config_item ~= nil then
			spell_create(config_item.name, spellcolor.normal, time_game, msg.spelltime)
		else
			spell_create("", spellcolor.normal, time_game, msg.spelltime)
		end
	end
end

function SC_PetFeed(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.feedprogress = msg.feed
		tabfeed_updateui(msg.uuid)
	end
end

function SC_PetFeedFlavor(msg)
	local pet = playerattr_getpet(msg.uuid)
	if pet ~= nil then
		pet.flavorcount = msg.flavor
		tabfeed_updateui(msg.uuid)
	end
end
