
function equipcharge_getitemprice(itemid, itemcapacity)
    local price = 0
    local config_item = csvitem_getfromid(itemid)
    if config_item ~= nil and config_item.charge ~= nil and config_item.charge ~= "0" then
        local chargelevel = csvconfig_getsubvalue(config_item.charge, 1, configsubtype.int)
        if chargelevel > 0 then
            if chargelevel == 1 then
                local percent = (charge_level1 - itemcapacity) / charge_level1
                if percent > 0.0 then
                    local price1 = csvconfig_getsubvalue(config_item.charge, 2, configsubtype.int)
                    price = price + math.tointegerfloor(price1 * percent)
                end
            elseif chargelevel == 2 then
                local percent = (charge_level2 - itemcapacity) / charge_level2
                if percent > 0.0 then
                    local price2 = csvconfig_getsubvalue(config_item.charge, 3, configsubtype.int)
                    price = price + math.tointegerfloor(price2 * percent)
                end
            end
        end
    end
    return price
end

function equipcharge_getprice(item)
    local price = equipcharge_getitemprice(item.itemid, item.capacity)
    if item.compound ~= 0 then
        price = price + equipcharge_getitemprice(item.compound, item.subcapacity)
    end
    return price
end

function equipcharge_single_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipNPCChargeSelect"}
        msg.actorid = data.actorid
        msg.equipuuid = data.uuid
        c_send(msg)
    end
end
function equipcharge_delegate_selectequipcomplete(item, count, data)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local price = equipcharge_getprice(item)
    if price == 0 then
        chat_addsystemalert("ITEMCHARGE_NPC_SINGLEFULL")
        return
    end
    local text = c_textformat("ITEMCHARGE_NPC_SINGLECONFIRM", csvitem_getcolorname(config_item), price)
    local itemdata = {}
    itemdata.uuid = item.uuid
    itemdata.actorid = data
    messagebox_confirm(text, equipcharge_single_confirm, itemdata)
end
function equipcharge_delegate_filterequip(item)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return false
    end
    if config_item.charge ~= nil and config_item.charge ~= "0" then
        return true
    end
    return false
end
function equipcharge_single(actorid)
    npc_closedialog()
    local flag = bit.bor(selectitemflag.bag, selectitemflag.equip1, selectitemflag.equip2)
    selectitem_show("ITEMCHARGE_NPC_SELECTEQUIP", nil, selectitemcount.none, flag, equipcharge_delegate_filterequip, equipcharge_delegate_selectequipcomplete, actorid)
end

function equipcharge_all_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipNPCChargeAll"}
        msg.actorid = data
        c_send(msg)
    end
end
function equipcharge_all(actorid)
    npc_closedialog()
    local price = 0
    for i=1, #playerattr_bag do
        if playerattr_bag[i].itemid ~= 0 then
            price = price + equipcharge_getprice(playerattr_bag[i])
        end
    end
    for i=1, #playerattr_equip1 do
        if playerattr_equip1[i].itemid ~= 0 then
            price = price + equipcharge_getprice(playerattr_equip1[i])
        end
    end
    for i=1, #playerattr_equip2 do
        if playerattr_equip2[i].itemid ~= 0 then
            price = price + equipcharge_getprice(playerattr_equip2[i])
        end
    end
    if price == 0 then
        chat_addsystemalert("ITEMCHARGE_NPC_ALLFULL")
        return
    end
    local text = c_textformat("ITEMCHARGE_NPC_ALLCONFIRM", price)
    messagebox_confirm(text, equipcharge_all_confirm, actorid)
end
