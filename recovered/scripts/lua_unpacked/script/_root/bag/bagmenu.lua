
function bag_itemmenu_delegate_acceptquest(data)
    local msg = {messageid="CS_QuestAcceptItem"}
	msg.questid = csvquest_getquestidfromitemid(data.config_item.id)
	c_send(msg)
end

function bag_itemmenu_delegate_consume(data)
    local msg = {messageid="CS_ItemConsume"}
	msg.uuid = data.uuid
	msg.target = m_selectactorid
	c_send(msg)
end

function bag_itemmenu_confirm_resetrolename(text, data)
    local msg = {messageid="CS_PlayerRename"}
    msg.itemuuid = data
    msg.name = text
    c_send(msg)
end
function bag_itemmenu_confirm_reseticcname(text, data)
    local msg = {messageid="CS_IccRename"}
    msg.itemuuid = data
    msg.name = text
    c_send(msg)
end
function bag_itemmenu_delegate_consumelambda(data)
    local itemlambda = data.config_item.lambda
    if itemlambda == nil then
        return
    end
    local actioncount = itemlambda.actioncount
    for i=1,actioncount do
        local sublambda = itemlambda[i]
        if c_isaction(sublambda, "resetrolename") then
            inputline_show(uiedittype.default, "PLAYER_ITEM_INPUTPLAYERNAME", nil, bag_itemmenu_confirm_resetrolename, data.uuid)
            break
        elseif c_isaction(sublambda, "reseticcname") then
            inputline_show(uiedittype.default, "PLAYER_ITEM_INPUTICCNAME", nil, bag_itemmenu_confirm_reseticcname, data.uuid)
            break
        end
    end
end

function bag_itemmenu_delegate_open(data)
    local msg = {messageid="CS_ItemGift"}
    msg.uuid = data.uuid
    msg.count = 1
    c_send(msg)
end

function bag_itemmenu_delegate_openall(data)
    local msg = {messageid="CS_ItemGift"}
    msg.uuid = data.uuid
    msg.count = data.count
    c_send(msg)
end

function bag_itemmenu_delegate_unbind(data)
    equiplab_show(data.uuid, equiplab_tabtype.unbind, 0)
end

function bag_itemmenu_delegate_doc(data)
    quest_doc_setdoc(data.config_item.id)
end

function bag_itemmenu_delegate_bind_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_ItemBind"}
        msg.uuid = data.uuid
        c_send(msg)
    end
end
function bag_itemmenu_delegate_equip(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item == nil then
        return
    end
    local bindrequire = csvitem_requirebindonuse(item, data.config_item)
    if bindrequire then
        messagebox_confirm(c_textformat("PLAYER_TIPS_ITEMBINDNOTRADE", data.config_item.name), bag_itemmenu_delegate_bind_confirm, data)
    else
        local msg = {messageid="CS_EquipOn"}
        msg.uuid = data.uuid
        msg.slot = -1
        c_send(msg)
    end
end

function bag_itemmenu_delegate_soul(data)
    equiplab_show(data.uuid, equiplab_tabtype.soul, 0)
end

function bag_itemmenu_delegate_gem(data)
    equiplab_show(data.uuid, equiplab_tabtype.gem, 0)
end

function bag_itemmenu_delegate_dye(data)
    equiplab_show(data.uuid, equiplab_tabtype.dye, 0)
end

function bag_itemmenu_delegate_preview(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item == nil then
        return
    end
    if m_me ~= nil and m_me:setpreview(data.config_item, item.dye) then
        itemmenu_close()
        m_uibag_bag:close()
    end
end

function bag_itemmenu_delegate_charge(data)
    equiplab_show(data.uuid, equiplab_tabtype.charge, 0)
end

function bag_itemmenu_delegate_dismantle_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipDismantle"}
        msg.equipuuid = data.uuid
        msg.stoneuuid = data.pincer
        c_send(msg)
    end
end
function bag_itemmenu_delegate_dismantle(data)
    local itempincer = playeritem_getitem(itemid_pincer)
    if itempincer == nil then
        chat_addsystemalert("EQUIPDISMANTLE_NOPINCER")
        return
    end
    local item = playeritem_getfromuuid(data.uuid)
    if item ~= nil then
        local text = c_textformat("EQUIPDISMANTLE_DESTROY", data.config_item.name)
        local confirmdata = {pincer = itempincer.uuid, uuid = data.uuid}
        messagebox_confirm(text, bag_itemmenu_delegate_dismantle_confirm, confirmdata)
    end
end

function bag_itemmenu_delegate_sendchat(data)
    chat_openinput()
    if csvitem_isequip(data.config_item) then
        chatinput_addtext(richtext_makeequip(data.uuid))
    else
        chatinput_addtext(richtext_makeitem(data.config_item.id))
    end
end

function bag_itemmenu_delegate_skillbar(data)
    skill_setting_opensetting(csvskillslottype.item, data.config_item.id, data.uuid)
end

function bag_itemmenu_delegate_erase_confirm(ok, data)
    if ok then
        local item = playeritem_getfromuuid(data.uuid)
        if item ~= nil and item.count == data.count then
            local msg = {messageid="CS_ItemErase"}
            msg.uuid = data.uuid
            msg.count = data.count
            c_send(msg)
        end
    end
end
function bag_itemmenu_delegate_drop(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item ~= nil then
        local text = c_textformat("BAG_ERASE_CONFIRM", item.count, data.config_item.name)
        local confirmdata = {count = item.count, uuid = data.uuid}
        messagebox_confirm(text, bag_itemmenu_delegate_erase_confirm, confirmdata, nil, nil, AudioItemDelete)
    end
end

function bag_itemmenu_delegate_unlock_confirm(ok, uuid)
    if ok then
        local item = playeritem_getfromuuid(uuid)
        if item ~= nil then
            local msg = {messageid="CS_ItemLock"}
            msg.uuid = uuid
            msg.itemlock = 0
            c_send(msg)
        end
    end
end
function bag_itemmenu_delegate_lock(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item ~= nil then
        if item.itemlock ~= nil and item.itemlock > 0 then
            local text = c_textformat("BAG_UNLOCK_CONFIRM", data.config_item.name)
            messagebox_confirm(text, bag_itemmenu_delegate_unlock_confirm, data.uuid)
        else
            local msg = {messageid="CS_ItemLock"}
            msg.uuid = data.uuid
            msg.itemlock = 1
            c_send(msg)
        end
    end
end

function bag_itemmenu_delegate_spearateinput(data, count)
    local item = playeritem_getfromuuid(data)
    if item ~= nil and item.count > 1 then
        for i=1, #playerattr_bag do
			if playerattr_bag[i].itemid == 0 then
                local msg = {messageid="CS_ItemStack"}
                msg.srcuuid = item.uuid
                msg.dstslot = i - 1
                msg.movecount = count
                c_send(msg)
                break
			end
		end
    end
end
function bag_itemmenu_delegate_spearate(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item ~= nil and item.count > 1 then
        inputcount_show("BAGSPEARATE_TITLE", data.config_item, 1, item.count - 1, bag_itemmenu_delegate_spearateinput, data.uuid)
        inputcount_updateprice()
    end
end

function bag_itemmenu_delegate_sellinput(data, count)
    if count > 0 then
        local msg = {messageid="CS_ShopSell"}
        msg.actorid = m_uishop_main.npcactorid
        msg.uuid = {}
        msg.count = {}
        msg.uuid[1] = data.uuid
        msg.count[1] = count
        c_send(msg)
    end
end
function bag_itemmenu_delegate_sell(data)
    local item = playeritem_getfromuuid(data.uuid)
    if item ~= nil then
        local price = 0
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            price = math.tointegerfloor(config_item.price / shopsell_ratio)
        end
        inputcount_show("SHOP_SELL_INPUT_TITLE", data.config_item, item.count, item.count, bag_itemmenu_delegate_sellinput, data)
        inputcount_addcurrency(currency_coin, price, nil)
        inputcount_updateprice()
    end
end

function bag_itemmenu_delegate_storage(data)
    local msg = {messageid="CS_BagToStorage"}
    msg.actorid = m_uistorage.npcactorid
    msg.uuid = data.uuid
    c_send(msg)
end

function bag_itemmenu_delegate_iccstorage(data)
    local msg = {messageid="CS_BagToIccStorage"}
    msg.actorid = m_uiiccstorage.npcactorid
    msg.uuid = data.uuid
    c_send(msg)
end

local function bag_setmenubutton(item, config_item)
    local itemlock = item.itemlock ~= nil and item.itemlock > 0
    local questitem = playerquest_isquestconsumeitem(config_item.id)
    local consume = false
    if questitem then
        itemmenu_addbutton("BAGITEM_MENU_CONSUME", bag_itemmenu_delegate_consume)
        consume = true
    elseif csvquest_getquestidfromitemid(config_item.id) ~= nil then
        itemmenu_addbutton("BAGITEM_MENU_CONSUME", bag_itemmenu_delegate_acceptquest)
        consume = true
    else
        local itemlambda = config_item.lambda
        if itemlambda ~= nil then
            local actioncount = itemlambda.actioncount
            for i=1,actioncount do
                local sublambda = itemlambda[i]
                if csvitem_consumeable(sublambda) then
                    itemmenu_addbutton("BAGITEM_MENU_CONSUME", bag_itemmenu_delegate_consume)
                    consume = true
                    break
                elseif c_isaction(sublambda, "resetrolename") or c_isaction(sublambda, "reseticcname") then
                    itemmenu_addbutton("BAGITEM_MENU_CONSUME", bag_itemmenu_delegate_consumelambda)
                    consume = true
                    break
                elseif c_isaction(sublambda, "gift") or c_isaction(sublambda, "giftrand") or c_isaction(sublambda, "gifttype") or c_isaction(sublambda, "gifttyperand") then
                    itemmenu_addbutton("BAGITEM_MENU_OPEN", bag_itemmenu_delegate_open)
                    itemmenu_addbutton("BAGITEM_MENU_OPENALL", bag_itemmenu_delegate_openall)
                    consume = true
                    break
                elseif c_isaction(sublambda, "unbind") then
                    itemmenu_addbutton("BAGITEM_MENU_CONSUME", bag_itemmenu_delegate_unbind)
                    consume = true
                    break
                elseif c_isaction(sublambda, "document") then
                    itemmenu_addbutton("BAGITEM_MENU_DOC", bag_itemmenu_delegate_doc)
                    consume = true
                    break
                end
            end
        end
    end

    if not consume then
        if config_item.itemtype == csvitemtype.consume_battery then
            itemmenu_addbutton("BAGITEM_MENU_EQUIPON", bag_itemmenu_delegate_equip)
        elseif csvitem_isequip(config_item) then
            local available, typetext = equip_getrequireskill(config_item)
            if available then
                itemmenu_addbutton("BAGITEM_MENU_EQUIPON", bag_itemmenu_delegate_equip)
            end
            if config_item.soul ~= nil and config_item.soul > 0 then
                itemmenu_addbutton("BAGITEM_MENU_SOUL", bag_itemmenu_delegate_soul)
            end
            if config_item.gem ~= nil and config_item.gem > 0 then
                itemmenu_addbutton("BAGITEM_MENU_GEM", bag_itemmenu_delegate_gem)
            end
            if playeritem_getitemdye(item, config_item) then
                itemmenu_addbutton("BAGITEM_MENU_DYE", bag_itemmenu_delegate_dye)
            end
            local part = csvrender_getitemrender(config_item)
            if part ~= nil then
                itemmenu_addbutton("BAGITEM_MENU_PREVIEW", bag_itemmenu_delegate_preview)
            end
            if config_item.charge ~= nil and config_item.charge ~= "0" then
                itemmenu_addbutton("BAGITEM_MENU_CHARGE", bag_itemmenu_delegate_charge)
            end
            if config_item.dismantle > 0 then
                if not itemlock then
                    itemmenu_addbutton("BAGITEM_MENU_DISMANTLE", bag_itemmenu_delegate_dismantle)
                else
                    itemmenu_addbutton("BAGITEM_MENU_DISMANTLE", nil)
                end
            end
        end    
    end

    itemmenu_addbutton("BAGITEM_MENU_SKILLBAR", bag_itemmenu_delegate_skillbar)
    itemmenu_addbutton("BAGITEM_MENU_CHAT", bag_itemmenu_delegate_sendchat)
    if config_item.stack ~= nil and config_item.stack > 1 and item.count > 1 then
        itemmenu_addbutton("BAGITEM_MENU_SPEARATE", bag_itemmenu_delegate_spearate)
    end
    if config_item.breakable > 0 and not playerquest_isquestitem(config_item.id) then
        if not itemlock then
            itemmenu_addbutton("BAGITEM_MENU_DROP", bag_itemmenu_delegate_drop)
        else
            itemmenu_addbutton("BAGITEM_MENU_DROP", nil)
        end
    end
    if not itemlock then
        itemmenu_addbutton("BAGITEM_MENU_LOCK", bag_itemmenu_delegate_lock)
    else
        itemmenu_addbutton("BAGITEM_MENU_UNLOCK", bag_itemmenu_delegate_lock)
    end
end

function bag_setmenu(itemuuid)
    local item = playeritem_getfromuuid(itemuuid)
    if item == nil then
        return
    end
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local storage = storage_getitem() ~= nil
    local iccstorage = iccstorage_getitem() ~= nil
    local sellshop = shop_sellenable()
    local itemlock = item.itemlock ~= nil and item.itemlock > 0
    local data = {}
    data.uuid = itemuuid
    data.count = item.count
    data.config_item = config_item
    itemmenu_reset(data)
    if storage then
        if config_item.storage ~= csvitemstorage.none then
            itemmenu_addbutton("BAGITEM_MENU_STORAGE", bag_itemmenu_delegate_storage)
        else
            itemmenu_addbutton("BAGITEM_MENU_STORAGE", nil)
        end
    elseif iccstorage then
        if config_item.storage == csvitemstorage.allstorage and playeritem_getitemdeal(item) then
            itemmenu_addbutton("BAGITEM_MENU_STORAGE", bag_itemmenu_delegate_iccstorage)
        else
            itemmenu_addbutton("BAGITEM_MENU_STORAGE", nil)
        end
    elseif sellshop then
        if not itemlock and config_item.price > 0 and config_item.sellnpc > 0 then
            itemmenu_addbutton("BAGITEM_MENU_SELL", bag_itemmenu_delegate_sell)
        else
            itemmenu_addbutton("BAGITEM_MENU_SELL", nil)
        end
    else
        bag_setmenubutton(item, config_item)
    end

    local image_bg = m_uibag_bag:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    local menux = x - itemmenu_getwidth()
    local menuy = y + h / 2 + itemmenu_getheight() / 2
    itemmenu_open(menux, menuy, m_uibag_bag)

    tips_item(item.itemid, item.count, menux, -1, tipsflag.vleft, item, itemmenu_getpanel())
end
