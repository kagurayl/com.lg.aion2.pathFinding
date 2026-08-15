include("bag/itemcontainer")
include("bag/storage")
include("bag/iccstorage")
include("bag/bagmenu")
include("bag/obs")

local m_bag_lineitemcount = 6

local m_bag_inst = {item = "bag/inst_bag"}
m_uibag_bag = uipanel_createhandle("bag/bag", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)

function bag_onopen()
    local list_item = m_uibag_bag:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    m_uibag_bag:setwidgetdelegate("button_sort", bag_delegate_sort)
    m_uibag_bag:setwidgetdelegate("image_bg/button_close", bag_delegate_close)
    event_register(bit.bor(eventtype.item, eventtype.money), bag_updateitem, m_uibag_bag)
    event_register(eventtype.update, bag_update, m_uibag_bag)
    bag_updateitem()
end

function bag_updateitem()
    if m_uibag_bag:null() then
        return
    end

    local text_coin = m_uibag_bag:getwidget("text_coin")
    text_coin:settext(playerattr_info.coin)

    local text_cash = m_uibag_bag:getwidget("text_cash")
    text_cash:settext(playerattr_info.cash)

    local text_space = m_uibag_bag:getwidget("text_space")
    if playerattr_bagoverload > 0 then
        text_space:setcolor(1,0,0,1)
        text_space:settext(string.format("??/%d", playerattr_bagspace))
    else
        text_space:setcolor(1,1,1,1)
        text_space:settext(string.format("%d/%d", playeritem_getfillcount(), playerattr_bagspace))
    end

    local list_item = m_uibag_bag:getwidget("list_item")
    m_uibag_bag.slot = itemcontainer_createlist(playerattr_bagspace, playerattr_bag, list_item, m_bag_inst.item, m_bag_lineitemcount, bag_delegate_icon)
end

function bag_delegate_icon(sender, event)
    if sender.itemuuid ~= nil then
        bag_setmenu(sender.itemuuid)
    end
end

function bag_update()
    for i=1,#m_uibag_bag.slot do
        itemcontainer_updatecd(m_uibag_bag.slot[i])
    end
end

function bag_delegate_sort()
    itemcontainer_sort(playerattr_bag, "CS_ItemMove", nil)
end

function bag_delegate_close()
    m_uibag_bag:close()
end

function bag_open()
    m_uibag_bag:open()
end

function bag_consumeitem_delegate_bind_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_ItemBind"}
        msg.uuid = data
        c_send(msg)
    end
end
function bag_consumeitem(uuid, itemid)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    local item = playeritem_getfromuuid(uuid)
    if item == nil then
        local isequip = csvitem_isequip(config_item)
        if not isequip then
            item = playeritem_getitem(itemid)
        end
    end
    if item == nil then
        return
    end
    local consume = false
    local bindrequire = csvitem_requirebindonuse(item, config_item)
    if bindrequire then
        messagebox_confirm(c_textformat("PLAYER_TIPS_ITEMBINDNOTRADE", config_item.name), bag_consumeitem_delegate_bind_confirm, item.uuid)
        return
    end

    local questitem = playerquest_isquestconsumeitem(config_item.id)
    if questitem then
        local msg = {messageid="CS_ItemConsume"}
        msg.uuid = item.uuid
        msg.target = m_selectactorid
        c_send(msg)
        return
    end

    if csvquest_getquestidfromitemid(config_item.id) ~= nil then
        local msg = {messageid="CS_QuestAcceptItem"}
        msg.questid = csvquest_getquestidfromitemid(config_item.id)
        c_send(msg)
        return
    end

    local itemlambda = config_item.lambda
    if itemlambda ~= nil then
        local actioncount = itemlambda.actioncount
        for i=1,actioncount do
            local sublambda = itemlambda[i]
            if csvitem_consumeable(sublambda) then
                local msg = {messageid="CS_ItemConsume"}
                msg.uuid = item.uuid
                msg.target = m_selectactorid
                c_send(msg)
                return
            end
            if c_isaction(sublambda, "gift") or c_isaction(sublambda, "giftrand") or c_isaction(sublambda, "gifttype") or c_isaction(sublambda, "gifttyperand") then
                local msg = {messageid="CS_ItemGift"}
                msg.uuid = item.uuid
                msg.count = 1
                c_send(msg)
                return
            end
            if c_isaction(sublambda, "document") then
               quest_doc_setdoc(config_item.id)
               return
            end
        end
    end

    if config_item.itemtype == csvitemtype.consume_battery then
        local msg = {messageid="CS_EquipOn"}
        msg.uuid = item.uuid
        msg.slot = -1
        c_send(msg)
        return
    end
    if csvitem_isequip(config_item) then
        local available, typetext = equip_getrequireskill(config_item)
        if available then
            local msg = {messageid="CS_EquipOn"}
            msg.uuid = item.uuid
            msg.slot = -1
            c_send(msg)
            return
        end
    end
end
