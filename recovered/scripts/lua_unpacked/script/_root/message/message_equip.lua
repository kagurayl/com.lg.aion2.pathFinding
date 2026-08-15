
local function equip_updateui()
	event_active(eventtype.item)
	richtext_setweaponreplace()
	equip_updatescript()
end

function equip_updateview(slot)
	playeritem_updateequipview(slot)
	if m_me ~= nil then
		m_me:setreloadasset(false)
	end
end

function SC_EquipOn(msg)
	local equipcontainer = playeritem_getequipcontainer(msg.equipindex)
	playeritem_swap(playerattr_bag[msg.bagslot + 1], equipcontainer[msg.equipslot + 1])
	equip_updateui()
	local updateequipslot = msg.equipslot + 1
	if updateequipslot == equipslot.weapon1 or updateequipslot == equipslot.weapon2 then
		equip_updateview(equipslot.weapon1)
		equip_updateview(equipslot.weapon2)
	else
		equip_updateview(updateequipslot)
	end
	audiomanager_playaudioui(AudioEquipOn)
end

function SC_EquipSwap(msg)
	local equipcontainer = playeritem_getequipcontainer(msg.equipindex)
	playeritem_swap(equipcontainer[msg.equipslot1 + 1], equipcontainer[msg.equipslot2 + 1])
	equip_updateui()
	equip_updateview(msg.equipslot1 + 1)
	equip_updateview(msg.equipslot2 + 1)
	audiomanager_playaudioui(AudioEquipOn)
end

function SC_EquipOff(msg)
	local equipcontainer = playeritem_getequipcontainer(msg.equipindex)
	playeritem_swap(playerattr_bag[msg.bagslot + 1], equipcontainer[msg.equipslot + 1])
 	equip_updateui()
	equip_updateview(msg.equipslot + 1)
	if msg.replace == 0 then
		audiomanager_playaudioui(AudioEquipOff)
	end
end

function SC_EquipRemove(msg)
	local equipcontainer = playeritem_getequipcontainer(msg.equipindex)
	equipcontainer[msg.slot + 1].itemid = 0
	equip_updateui()
	equip_updateview(msg.slot + 1)
end

function SC_EquipSwitch(msg)
	playerattr_info.equipindex = msg.index
	equip_updateui()
	for i=1, #playerattr_equip1 do
		equip_updateview(i)
	end
	audiomanager_playaudioui(AudioChangeWeapon)
end

function SC_EquipBatteryConsume(msg)
	local equipcontainer = playeritem_getequipcontainer(msg.equipindex)
	equipcontainer[equipslot.battery1].itemid = msg.item1
	equipcontainer[equipslot.battery1].count = msg.count1
	equipcontainer[equipslot.battery2].itemid = msg.item2
	equipcontainer[equipslot.battery2].count = msg.count2
	if msg.count1 == 0 and msg.count2 == 0 then
		playerattr_info.battery = 0
		chat_addsystemalert("STR_MSG_WEAPON_BOOST_MODE_BURN_OUT")
	end
	equip_updateui()
end

function SC_EquipEnchantNotify(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		if msg.type == 1 then
			actor:clearspell()
			actor.actionmain.spelltype = playerspellstate.enchantsuccess
		elseif msg.type == 2 then
			actor:clearspell()
			actor.actionmain.spelltype = playerspellstate.enchantfail
		end
	end
end

function SC_EquipGemSuccess(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		if msg.subequip > 0 then
			item.subgem[msg.equiphole + 1] = msg.gemid
		else
			item.gem[msg.equiphole + 1] = msg.gemid
		end
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		local config_gem = csvitem_getfromid(msg.gemid)
		if config_item ~= nil and config_gem ~= nil then
			local text = c_textformat("LAB_GEM_SUCCESS", config_item.name, config_gem.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipGemFailed(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		if msg.subequip > 0 then
			for i=1,#item.subgem do
				item.subgem[i] = 0
			end
		else
			for i=1,#item.gem do
				item.gem[i] = 0
			end
		end
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_GEM_FAILED", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipGemHole(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		for i=#item.gem + 1, msg.hole do
			item.gem[i] = 0
		end
		for i=#item.subgem + 1, msg.subhole do
			item.subgem[i] = 0
		end
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_HOLE_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipSoulSuccess(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.soul = msg.equipsoul
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_SOUL_SUCCESS", config_item.name, msg.equipsoul)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipSoulMax(msg)
	local config_item = csvitem_getfromid(msg.itemid)
	if config_item ~= nil then
		local text = c_textformat("LAB_SOUL_NOTIFY", msg.playername, config_item.name, msg.soul)
		chat_addsystemalert(text)
	end
end

function SC_EquipSoulFailed(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.soul = msg.equipsoul
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_SOUL_FAILED", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipGodSuccess(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.god = msg.equipgod
		equip_updateui()
		equip_updateview(equipslot.weapon1)
		equip_updateview(equipslot.weapon2)
		local config_item = csvitem_getfromid(item.itemid)
		local config_god = csvitem_getfromid(item.god)
		if config_item ~= nil and config_god ~= nil then
			local text = c_textformat("LAB_GODSTONE_TIPS_SUCCESS", config_item.name, config_god.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipCompound(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.compound = msg.compound
		item.bindtime = msg.bindtime
		for i=1,msg.subgemslot do
			item.subgem[i] = msg.subgem[i]
		end
		for i=msg.subgemslot + 1,#item.subgem do
			item.subgem[i] = nil
		end
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_COMPOUNT_TIPS_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipDecompound(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.compound = 0
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_DECOMPOUNT_TIPS_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipUnBind(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if item ~= nil then
		item.bindtime = 0
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_UNBIND_TIPS_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_EquipRemoveGem(msg)
	local item = playeritem_getfromuuid(msg.equipuuid)
	if msg.subequip > 0 then
		if item ~= nil and item.subgem ~= nil then
			local config_item = csvitem_getfromid(item.subgem[msg.gemindex + 1])
			if config_item ~= nil then
				local text = c_textformat("LAB_GEMREMOVE_TIPS_SUCCESS", config_item.name)
				chat_addsystemalert(text)
			end
			item.subgem[msg.gemindex + 1] = 0
			equip_updateui()
		end
	else
		if item ~= nil and item.gem ~= nil then
			local config_item = csvitem_getfromid(item.gem[msg.gemindex + 1])
			if config_item ~= nil then
				local text = c_textformat("LAB_GEMREMOVE_TIPS_SUCCESS", config_item.name)
				chat_addsystemalert(text)
			end
			item.gem[msg.gemindex + 1] = 0
			equip_updateui()
		end
	end
end

function SC_EquipSkin(msg)
	local item, container = playeritem_getfromequipuuid(msg.equipuuid)
	if item == nil then
		item = playeritem_getfromuuid(msg.equipuuid)
	end
	if item ~= nil then
		item.skin = msg.skinid
		item.dye = msg.dye
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_ITEMSKIN_TIPS_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
		if container ~= nil then
			equip_updateview(item.slot)
		end
	end
end

function SC_EquipDye(msg)
	local item, container = playeritem_getfromequipuuid(msg.equipuuid)
	if item == nil then
		item = playeritem_getfromuuid(msg.equipuuid)
	end
	if item ~= nil then
		item.dye = msg.dye
		equip_updateui()
		local config_item = csvitem_getfromid(item.itemid)
		if config_item ~= nil then
			local text = c_textformat("LAB_ITEMDYE_TIPS_SUCCESS", config_item.name)
			chat_addsystemalert(text)
		end
		if container ~= nil then
			equip_updateview(item.slot)
		end
	end
end

function SC_EquipCharge(msg)
	local item, container = playeritem_getfromequipuuid(msg.equipuuid)
	if item == nil then
		item = playeritem_getfromuuid(msg.equipuuid)
	end
	if item ~= nil then
		if item.capacity < msg.capacity or item.subcapacity < msg.subcapacity then
			local config_item = csvitem_getfromid(item.itemid)
			if config_item ~= nil then
				local text = c_textformat("LAB_ITEMCHARGE_TIPS_SUCCESS", config_item.name)
				chat_addsystemalert(text)
			end
		end
		item.capacity = msg.capacity
		item.subcapacity = msg.subcapacity
		equip_updateui()
	end
end

function SC_EquipChargeAll(msg)
	for i=1,#msg.equipuuid do
		local item, container = playeritem_getfromequipuuid(msg.equipuuid[i])
		if item == nil then
			item = playeritem_getfromuuid(msg.equipuuid[i])
		end
		if item ~= nil then
			item.capacity = msg.capacity[i]
			item.subcapacity = msg.subcapacity[i]
		end
	end
	local text = c_textformat("ITEMCHARGE_NPC_ALLSUCCESS", #msg.equipuuid)
	chat_addsystemalert(text)
	equip_updateui()
end

function SC_EquipChargeBurn(msg)
	local item, container = playeritem_getfromequipuuid(msg.equipuuid)
	if item ~= nil then
		item.capacity = msg.capacity
	end
end

function SC_EquipChargeBurn2(msg)
	local item, container = playeritem_getfromequipuuid(msg.equipuuid)
	if item ~= nil then
		item.capacity = msg.capacity
		item.subcapacity = msg.subcapacity
	end
end

function SC_EquipView(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		local clientslot = msg.slot + 1
		actor.attr.equipview[clientslot] = msg.itemid
		actor.attr.equipdye[clientslot] = csvitem_getdyecolor(msg.dye)
		if clientslot == equipslot.weapon1 then
			actor.attr.godstonemain = msg.godstone
		elseif clientslot == equipslot.weapon2 then
			actor.attr.godstonesub = msg.godstone
		end
		actor:setreloadasset(false)
	end
end

function SC_EquipViewArray(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		for i=1,#msg.equip do
			actor.attr.equipview[i] = msg.equip[i]
			actor.attr.equipdye[i] = csvitem_getdyecolor(msg.dye[i])
		end
		actor.attr.godstonemain = msg.godstonemain
		actor.attr.godstonesub = msg.godstonesub
		actor:setreloadasset(false)
	end
end
