
Max_BagSlot = (108 + 90)
Max_EquipSlot = 17
Max_StallSlot = 10

playerattr_bag = nil
playerattr_equip1 = nil
playerattr_equip2 = nil
playerattr_stall = nil
playerattr_redeem = nil
playerattr_business = nil
playerattr_businessbill = nil
playerattr_costumespace = 0
playerattr_costume = nil
playerattr_costumeactive = nil
playerattr_bagspace = 0
playerattr_bagspacelevel = 0
playerattr_bagoverload = 0

function playeritem_clear()
	playerattr_bag = {}
	playerattr_equip1 = {}
	playerattr_equip2 = {}
	playerattr_stall = {}
	playerattr_redeem = {}
	playerattr_costumespace = 0
	playerattr_costume = {}
	playerattr_costumeactive = {}
	playerattr_business = {}
	playerattr_businessbill = {}
	playerattr_businessbill.billcoin = 0
	playerattr_businessbill.billcash = 0

	for i=1, Max_BagSlot do
		playerattr_bag[i] = {itemid = 0, slot = i}
	end
	for i=1, Max_EquipSlot do
		playerattr_equip1[i] = {itemid = 0, slot = i}
		playerattr_equip2[i] = {itemid = 0, slot = i}
	end
	for i=1, Max_StallSlot do
		playerattr_stall[i] = {itemid = 0, slot = i}
	end
	playerattr_bagspace = 0
end

function playeritem_copy(dst, src)
	dst.uuid = src.uuid
	dst.crafter = src.crafter
	dst.itemid = src.itemid
	dst.itemlock = src.itemlock
	dst.bindtime = src.bindtime
	dst.expire = src.expire
	dst.compound = src.compound
	dst.skin = src.skin
	dst.dye = src.dye
	dst.capacity = src.capacity
	dst.subcapacity = src.subcapacity
	dst.count = src.count
	dst.soul = src.soul
	dst.god = src.god
	dst.gem = {}
	dst.subgem = {}
	if src.gem ~= nil then
		for i=1,#src.gem do
			dst.gem[i] = src.gem[i]
		end
	end
	if src.subgem ~= nil then
		for i=1,#src.subgem do
			dst.subgem[i] = src.subgem[i]
		end
	end
end

function playeritem_swap(item1, item2)
	local uuid = item1.uuid
	local crafter = item1.crafter
	local itemid = item1.itemid
	local itemlock = item1.itemlock
	local bindtime = item1.bindtime
	local expire = item1.expire
	local compound = item1.compound
	local skin = item1.skin
	local dye = item1.dye
	local capacity = item1.capacity
	local subcapacity = item1.subcapacity
	local count = item1.count
	local soul = item1.soul
	local god = item1.god
	local gem = item1.gem
	local subgem = item1.subgem

	item1.uuid = item2.uuid
	item1.crafter = item2.crafter
	item1.itemid = item2.itemid
	item1.itemlock = item2.itemlock
	item1.bindtime = item2.bindtime
	item1.expire = item2.expire
	item1.compound = item2.compound
	item1.skin = item2.skin
	item1.dye = item2.dye
	item1.capacity = item2.capacity
	item1.subcapacity = item2.subcapacity
	item1.count = item2.count
	item1.soul = item2.soul
	item1.god = item2.god
	item1.gem = item2.gem
	item1.subgem = item2.subgem

	item2.uuid = uuid
	item2.crafter = crafter
	item2.itemid = itemid
	item2.itemlock = itemlock
	item2.bindtime = bindtime
	item2.expire = expire
	item2.compound = compound
	item2.skin = skin
	item2.dye = dye
	item2.capacity = capacity
	item2.subcapacity = subcapacity
	item2.count = count
	item2.soul = soul
	item2.god = god
	item2.gem = gem
	item2.subgem = subgem
end

function playeritem_set(msg)
	playerattr_bagspace = msg.bagspace
	playerattr_bagspacelevel = msg.bagspacelevel
	playerattr_bagoverload = msg.bagoverload
	for i=1, #msg.item do
		local slot = msg.item[i].slot + 1
		if slot <= #playerattr_bag then
			playeritem_copy(playerattr_bag[slot], msg.item[i].attr)
		end
	end
	playerattr_info.equipview = {}
	playerattr_info.equipdye = {}
	for i=1, #msg.equip1 do
		playeritem_copy(playerattr_equip1[i], msg.equip1[i])
	end
	for i=1, #msg.equip2 do
		playeritem_copy(playerattr_equip2[i], msg.equip2[i])
	end
	local activeequip = playeritem_getactiveequip()
	for i=1, #activeequip do
		playeritem_updateequipview(i)
	end
	richtext_setweaponreplace()
end

local function playeritem_setequipview(slot, equipactive)
	if slot == equipslot.weapon1 then
		playerattr_info.godstonemain = equipactive[slot].god
	elseif slot == equipslot.weapon2 then
		playerattr_info.godstonesub = equipactive[slot].god
	end
	local costumeindex = playerattr_costumeactive[slot]
	if costumeindex ~= nil then
		local costume = playerattr_costume[costumeindex]
		if costume ~= nil then
			local config_equip = nil
			if equipactive[slot].skin ~= 0 then
				config_equip = csvitem_getfromid(equipactive[slot].skin)
			else
				config_equip = csvitem_getfromid(equipactive[slot].itemid)
			end
			local config_costume = csvitem_getfromid(costume.skin)
			if config_costume ~= nil and config_equip ~= nil and csvitem_getskinable(config_equip.itemtype, config_costume.itemtype) then
				playerattr_info.equipview[slot] = costume.skin
				playerattr_info.equipdye[slot] = csvitem_getdyecolor(costume.dye)
				return
			end
		end
	end

	if equipactive[slot].skin ~= 0 then
		playerattr_info.equipview[slot] = equipactive[slot].skin
	else
		playerattr_info.equipview[slot] = equipactive[slot].itemid
	end
	playerattr_info.equipdye[slot] = csvitem_getdyecolor(equipactive[slot].dye)
end
function playeritem_updateequipview(slot)
	local equipactive, equipsecondard = playeritem_getactiveequip()
	if equipactive[slot].itemid ~= 0 then
		playeritem_setequipview(slot, equipactive)
	elseif playeritem_equipsparetire(slot) and equipsecondard[slot].itemid ~= 0 then
		playeritem_setequipview(slot, equipsecondard)
	else
		playerattr_info.equipview[slot] = 0
		playerattr_info.equipdye[slot] = nil
		if slot == equipslot.weapon1 then
			playerattr_info.godstonemain = 0
		elseif slot == equipslot.weapon2 then
			playerattr_info.godstonesub = 0
		end
		local costumeindex = playerattr_costumeactive[slot]
		if costumeindex ~= nil then
			local costume = playerattr_costume[costumeindex]
			if costume ~= nil then
				local config_costume = csvitem_getfromid(costume.skin)
				if config_costume ~= nil then
					local setcostume = false
					local costumeslot = csvitem_getequipslot(config_costume)
					if costumeslot == equipslot.weapon1 or slot == equipslot.weapon2 then
						setcostume = false
					elseif costumeslot == slot then
						setcostume = true
					elseif costumeslot == equipslot.earring1 and slot == equipslot.earring2 then
						setcostume = true
					elseif costumeslot == equipslot.ring1 and slot == equipslot.ring2 then
						setcostume = true
					end
					if setcostume then
						playerattr_info.equipview[slot] = costume.skin
						playerattr_info.equipdye[slot] = csvitem_getdyecolor(costume.dye)
					end
				end
			end
		end
	end
end

function playeritem_setstall(msg)
	for i=1, Max_StallSlot do
		playerattr_stall[i].itemid = 0
	end
	for i=1,#msg.item do
		local item = msg.item[i]
		local slot = item.slot + 1
		playeritem_copy(playerattr_stall[slot], item.attr)
		playerattr_stall[slot].price = item.price
	end
end

function playeritem_getequipcontainer(index)
    if index == 0 then
		return playerattr_equip1, playerattr_equip2
	else
		return playerattr_equip2, playerattr_equip1
	end
end

function playeritem_getactiveequip()
    return playeritem_getequipcontainer(playerattr_info.equipindex)
end

function playeritem_equipsparetire(slot)
	local sparetire = false
	if slot == equipslot.weapon1 then
		local container1, container2 = playeritem_getactiveequip()
		local itemattrspare = container2[equipslot.weapon1]
		if itemattrspare.itemid ~= 0 then
			local config_item = csvitem_getfromid(itemattrspare.itemid)
			if config_item ~= nil then
				local weapontype = config_item.itemtype
				if csvitem_getequipslotex(config_item) then
					local itemattrweapon2 = container1[equipslot.weapon2]
					if itemattrweapon2.itemid == 0 then
						sparetire = true
					end
				else
					sparetire = true
				end
			end
		end
	elseif slot == equipslot.weapon2 then
		local container1, container2 = playeritem_getactiveequip()
		local itemattrspare = container2[equipslot.weapon2]
		if itemattrspare.itemid ~= 0 then
			local config_item = csvitem_getfromid(itemattrspare.itemid)
			if config_item ~= nil then
				local itemattrweapon2 = container1[equipslot.weapon1]
				if itemattrweapon2.itemid ~= 0 then
					local config_itemweapon1 = csvitem_getfromid(itemattrweapon2.itemid)
					if config_itemweapon1 ~= nil and not csvitem_getequipslotex(config_itemweapon1) then
						sparetire = true
					end
				else
					sparetire = true
				end
			end
		end
	else
		sparetire = true
	end
	return sparetire
end

function playeritem_getspareequip(slot)
	local container1, container2 = playeritem_getactiveequip()
	local itemattr1 = container1[slot]
    if itemattr1.itemid == 0 and playeritem_equipsparetire(slot) then
		local itemattr2 = container2[slot];
		if itemattr2.itemid ~= 0 then
			itemattr1 = itemattr2
		end
	end
	return itemattr1
end

function playeritem_getcostumeslotfromindex(index)
	for key, val in pairs(playerattr_costumeactive) do
		if val == index then
			return key
		end
	end
    return 0
end

function playeritem_getitem(itemid)
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid == itemid then
            return item
        end
    end
end

function playeritem_getcount(itemid)
	local count = 0
	if itemid ~= 0 then
		for i=1, #playerattr_bag do
			if playerattr_bag[i].itemid == itemid then
				count = count + playerattr_bag[i].count
			end
		end
	end
	return count
end

function playeritem_getequipcount(itemid)
	local count = 0
	for i=1, #playerattr_equip1 do
		if playerattr_equip1[i].itemid == itemid then
			count = count + playerattr_equip1[i].count
		end
	end
	for i=1, #playerattr_equip2 do
		if playerattr_equip2[i].itemid == itemid then
			count = count + playerattr_equip2[i].count
		end
	end
	return count
end

function playeritem_getcountfromuuid(uuid)
	local item = playeritem_getfromuuid(uuid)
	if item ~= nil then
		return item.count
	else
		return 0
	end
end

function playeritem_getfillcount()
	local fillcount = 0
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            fillcount = fillcount + 1
        end
    end
    return fillcount
end

function playeritem_getfromslot(slot)
	if slot > 0 and slot < #playerattr_bag then
		return playerattr_bag[slot]
	end
end

function playeritem_getfromequipuuid(uuid)
	if uuid ~= nil and uuid > 0 then
		for i=1, #playerattr_equip1 do
			local item = playerattr_equip1[i]
			if item.itemid ~= 0 and item.uuid == uuid then
				return item, playerattr_equip1
			end
		end
		for i=1, #playerattr_equip2 do
			local item = playerattr_equip2[i]
			if item.itemid ~= 0 and item.uuid == uuid then
				return item, playerattr_equip1
			end
		end
	end
end

function playeritem_getfrombaguuid(uuid)
	if uuid ~= nil and uuid > 0 then
		for i=1, #playerattr_bag do
			if playerattr_bag[i].itemid ~= 0 and playerattr_bag[i].uuid == uuid then
				return playerattr_bag[i]
			end
		end
	end
end

function playeritem_getfrombagscript(script)
	for bagindex=1, #playerattr_bag do
		if playerattr_bag[bagindex].itemid ~= 0 then
			local config_item = csvitem_getfromid(playerattr_bag[bagindex].itemid)
			if config_item ~= nil then
				local itemlambda = config_item.lambda
				if itemlambda ~= nil then
					local actioncount = itemlambda.actioncount
					for i=1,actioncount do
						local sublambda = itemlambda[i]
						if c_isaction(sublambda, script) then
							return playerattr_bag[bagindex]
						end
					end
				end
			end
		end
	end
end

function playeritem_getfromuuid(uuid)
	if uuid ~= nil and uuid > 0 then
		for i=1, #playerattr_bag do
			local item = playerattr_bag[i]
			if item.itemid ~= 0 and item.uuid == uuid then
				return item
			end
		end
		for i=1, #playerattr_equip1 do
			local item = playerattr_equip1[i]
			if item.itemid ~= 0 and item.uuid == uuid then
				return item
			end
		end
		for i=1, #playerattr_equip2 do
			local item = playerattr_equip2[i]
			if item.itemid ~= 0 and item.uuid == uuid then
				return item
			end
		end
	end
end

function playeritem_getitemconfigfrombaguuid(uuid)
	local item = playeritem_getfrombaguuid(uuid)
    if item ~= nil then
		local config_item = csvitem_getfromid(item.itemid)
		return item, config_item
    end
end

function playeritem_getitemconfigfromuuid(uuid)
	local item = playeritem_getfromuuid(uuid)
    if item ~= nil then
		local config_item = csvitem_getfromid(item.itemid)
		return item, config_item
    end
end

function playeritem_getitemdeal(item)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return false
    end
	if item.itemlock ~= nil and item.itemlock > 0 then
		return false
	end
    if config_item.deal == csvitemdeal.nodeal then
        return false
	elseif config_item.deal == csvitemdeal.bindonuse then
        return item.bindtime == 0
	elseif config_item.deal == csvitemdeal.bindontrade then
        return item.bindtime == 0
    end
    return true
end

function playeritem_getitemdye(item, config_item)
    if item.skin ~= nil and item.skin ~= 0 then
		local config_skin = csvitem_getfromid(item.skin)
		if config_skin ~= nil then
			return config_skin.dye ~= nil and config_skin.dye > 0
		end
    end
    return config_item.dye ~= nil and config_item.dye > 0
end
