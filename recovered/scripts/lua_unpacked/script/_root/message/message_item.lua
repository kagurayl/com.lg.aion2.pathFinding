
function item_updateui()
	event_active(eventtype.item)
	actormanager_updatehead()
end

function SC_BagSpace(msg)
	local space = playerattr_bagspace
	playerattr_bagspace = msg.space
	playerattr_bagspacelevel = msg.spacelevel
	if playerattr_bagspace > space then
		chat_addsystemalert("NPC_ASK_BAGEXTEND_SUCCESS")
		if msg.openbag > 0 then
			bag_open()
		end
	end
	item_updateui()
end

function SC_ItemAdd(msg)
	playeritem_copy(playerattr_bag[msg.slot + 1], msg.item)
	local config_item = csvitem_getfromid(msg.item.itemid)
	if config_item ~= nil then
		audiomanager_playaudioui(config_item.sound .. ".ogg")
	end
	item_updateui()
end

function SC_ItemConsume(msg)
	if msg.slot < #playerattr_bag then
		local item = playerattr_bag[msg.slot + 1]
		if msg.consume == 0 then
			local config_item = csvitem_getfromid(item.itemid)
			if config_item ~= nil then
				if item.count - msg.count > 1 then
					chat_addsystem(textformat_args("STR_USE_CASH_TYPE_ITEM2", config_item.name, item.count - msg.count))
				else
					chat_addsystem(textformat_args("STR_USE_CASH_TYPE_ITEM1", config_item.name))
				end
				if config_item.vfx ~= nil and config_item.vfx ~= "0" and m_me ~= nil then
					m_me:createskillfxc(config_item.vfx, bit.bor(vfxflag.free, vfxflag.spawnposition), m_me.actorid, m_me.actorid)
				end
				actionmanager_setitemaction(m_me, config_item)
			end
			audiomanager_playaudioui(AudioItemConsume)
		end
		item.count = msg.count
		if item.count == 0 then
			item.itemid = 0
		end
	end
	item_updateui()
end

function SC_ItemConsumeAOI(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
		local config_item = csvitem_getfromid(msg.itemid)
		if config_item ~= nil then
			if config_item.vfx ~= nil and config_item.vfx ~= "0" then
				actor:createskillfxc(config_item.vfx, bit.bor(vfxflag.free, vfxflag.spawnposition), actor.actorid, actor.actorid)
			end
			actionmanager_setitemaction(actor, config_item)
		end
    end
end

function SC_ItemSpell(msg)
	local actor = actormanager_getfromactorid(msg.attacker)
    if actor ~= nil then
		actor:clearspell()
    end
	local config_item = csvitem_getfromid(msg.itemid)
	if msg.attacker == playerattr_info.actorid then
		audiomanager_playaudioui(AudioItemSpell)
		local color = spellcolor.normal
		if msg.itemid == itemid_pincer then
			color = spellcolor.red
		end
		if config_item ~= nil then
			spell_create(config_item.name, color, time_game, msg.spelltime)
		else
			spell_create("", color, time_game, msg.spelltime)
		end
	end
	if actor ~= nil and config_item ~= nil then
		local itemtype = config_item.itemtype
		if itemtype == csvitemtype.consume_gem or itemtype == csvitemtype.consume_soul then
			actor:clearspell()
			actor.actionmain.spelltype = playerspellstate.enchantspell
			actor.battle.spelltime = msg.spelltime
		else
			actor:clearspell()
			actor.actionmain.spelltype = playerspellstate.spellitem
			actor.actionmain.config_item = config_item
			actor.battle.spelltime = msg.spelltime
		end
	end
end

function SC_ItemBindSpell(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
    if actor ~= nil then
		actor:clearspell()
		actor.actionmain.spelltype = playerspellstate.spellitembind
    end
end

function SC_ItemBind(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			playerattr_bag[msg.slot + 1].bindtime = msg.bindtime
			local config_item = csvitem_getfromid(playerattr_bag[msg.slot + 1].itemid)
			if config_item ~= nil then
				chat_addsystemalert(textformat_args("STR_SOUL_BOUND_ITEM_SUCCEED", config_item.name))
			end
		end
		actor:clearspell()
	end
end

function SC_ItemBindCancel(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			local config_item = csvitem_getfromid(msg.itemid)
			if config_item ~= nil then
				chat_addsystemalert(textformat_args("STR_SOUL_BOUND_ITEM_CANCELED", config_item.name))
			end
		end
		actor:clearspell()
	end
end

function SC_ItemMove(msg)
	container_move(playerattr_bag, msg.srcslot, msg.srccount, msg.dstslot, msg.dstcount)
end

function SC_ItemSwap(msg)
	container_swap(playerattr_bag, msg.srcslot, msg.dstslot)
end

function SC_ItemStack(msg)
	local srcitem = playerattr_bag[msg.srcslot + 1]
	local dstitem = playerattr_bag[msg.dstslot + 1]
	playeritem_copy(dstitem, srcitem)
	srcitem.count = msg.srccount
	dstitem.count = msg.dstcount
	dstitem.uuid = msg.dstuuid
	event_active(eventtype.item)
end

function SC_ItemLock(msg)
	local item = playerattr_bag[msg.slot + 1]
	item.itemlock = msg.itemlock
	event_active(eventtype.item)
end

function SC_ItemErase(msg)
	if msg.slot + 1 <= #playerattr_bag then
		local config_item = csvitem_getfromid(playerattr_bag[msg.slot + 1].itemid)
		if config_item ~= nil then
			chat_addsystemalert(textformat_args("STR_BREAK_ITEM", config_item.name))
		end
		playerattr_bag[msg.slot + 1].itemid = 0
		item_updateui()
		audiomanager_playaudioui(AudioItemDecreased)
	end
end

function SC_ItemExpire(msg)
	if msg.slot + 1 <= #playerattr_bag then
		local config_item = csvitem_getfromid(playerattr_bag[msg.slot + 1].itemid)
		if config_item ~= nil then
			chat_addsystemalert(c_textformat("PLAYER_TIPS_ITEMEXPIRED", config_item.name))
		end
		playerattr_bag[msg.slot + 1].itemid = 0
		item_updateui()
	end
end

function SC_ItemAddNotify(msg)
	local notify = nil
	if msg.overload > 0 then
		notify = c_textformat("BAG_PROMPT_ADDITEMOVERLOAD", msg.count, csvitem_getcolornamefromid(msg.itemid), msg.overload)
	elseif msg.count > 1 then
		notify = textformat_args("STR_MSG_GET_ITEM_MULTI", csvitem_getcolornamefromid(msg.itemid), msg.count)
	else
		notify = textformat_args("STR_MSG_GET_ITEM", csvitem_getcolornamefromid(msg.itemid))
	end
	chat_addsimple(chatchanneltype.systemitem, notify)
	messagealert_addalert(notify)
end

function SC_ItemOverload(msg)
	playerattr_bagoverload = msg.overload
	item_updateui()
end

function SC_StorageOpen(msg)
	storage_open(msg)
end

function SC_StorageSpace(msg)
	storage_updatespace(msg)
	chat_addsystemalert(c_textformat("STORAGE_EXTEND_SUCCESS"))
end

function SC_StorageCoin(msg)
	playerattr_info.coin = msg.bagcoin
	event_active(eventtype.money)
	storage_updatecoin(msg.storagecoin)
end

function SC_BagToStorage(msg)
	container_bagtostorage(storage_getitem(), msg.bagslot, msg.storageslot, nil)
	storage_updateui()
end

function SC_StorageToBag(msg)
	container_storagetobag(storage_getitem(), msg.storageslot, msg.bagslot, msg.attr)
	storage_updateui()
end

function SC_StorageMove(msg)
	container_move(storage_getitem(), msg.srcslot, msg.srccount, msg.dstslot, msg.dstcount)
end

function SC_StorageSwap(msg)
	container_swap(storage_getitem(), msg.srcslot, msg.dstslot)
end

function SC_IccStorageOpen(msg)
	iccstorage_open(msg)
end

function SC_BagToIccStorage(msg)
	container_bagtostorage(iccstorage_getitem(), msg.bagslot, msg.storageslot, msg.uuid)
	iccstorage_updateui()
end

function SC_IccStorageToBag(msg)
	container_storagetobag(iccstorage_getitem(), msg.storageslot, msg.bagslot, msg.attr)
	iccstorage_updateui()
end

function SC_IccStorageMove(msg)
	container_move(iccstorage_getitem(), msg.srcslot, msg.srccount, msg.dstslot, msg.dstcount)
end

function SC_IccStorageSwap(msg)
	container_swap(iccstorage_getitem(), msg.srcslot, msg.dstslot)
end

function SC_ItemMoveFinish(msg)
	event_active(eventtype.item)
	storage_updateui()
	iccstorage_updateui()
end
