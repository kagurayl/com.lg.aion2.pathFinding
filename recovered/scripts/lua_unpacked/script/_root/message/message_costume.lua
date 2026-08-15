
function SC_CostumeList(msg)
	playerattr_costumespace = msg.space
	for i=1,#msg.costume do
		local costume = msg.costume[i]
		playerattr_costume[costume.index] = costume
	end
	for i=1,#msg.active do
		local active = msg.active[i]
		playerattr_costumeactive[active.slot + 1] = active.index
	end	
	costume_updateui()
end

function SC_CostumeExtend(msg)
	playerattr_costumespace = msg.space
	costume_updateui()
end

function SC_CostumeAdd(msg)
	local costume = msg.costume
	playerattr_costume[costume.index] = costume
	costume_updateui()
	chat_addsystemalert(c_textformat("COSTUME_ADDSUCCESS", costume.name))
end

function SC_CostumeActive(msg)
	if msg.index ~= -1 then
		playerattr_costumeactive[msg.slot + 1] = msg.index
	else
		playerattr_costumeactive[msg.slot + 1] = nil
	end
	costume_updateui()
	equip_updateview(msg.slot + 1)
end

function SC_CostumeRename(msg)
	local costume = playerattr_costume[msg.index]
	if costume ~= nil then
		costume.name = msg.name
		costume_updateui()
	end
end

function SC_CostumeDye(msg)
	local costume = playerattr_costume[msg.index]
	if costume ~= nil then
		costume.dye = msg.dye
		costume_updateui()
		local slot = playeritem_getcostumeslotfromindex(msg.index)
		if slot ~= 0 then
			equip_updateview(slot)
		end
		local config_item = csvitem_getfromid(msg.dye)
		if config_item ~= nil then
			local text = c_textformat("COSTUME_COLORSUCCESS", config_item.name, costume.name)
			chat_addsystemalert(text)
		end
	end
end

function SC_CostumeDelete(msg)
	local slot = playeritem_getcostumeslotfromindex(msg.index)
	if slot ~= 0 then
		playerattr_costumeactive[slot] = nil
		equip_updateview(slot)
	end
	playerattr_costume[msg.index] = nil
	costume_updateui()
end
