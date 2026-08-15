
local m_uiroulette_main = uipanel_createhandle("store/roulette", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.fullscreen, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_roulette_inst = {player = "store/inst_rouletteplayer", item = "store/inst_rouletteitem"}
local m_roulette_item = nil

function roulette_open(msg)
    m_uiroulette_main:open()
    
    local text_cash_one = m_uiroulette_main:getwidget("text_cash_one")
    text_cash_one:settext("ROULETTE_PRICE", msg.priceone)

    local text_cash_ten = m_uiroulette_main:getwidget("text_cash_ten")
    text_cash_ten:settext("ROULETTE_PRICE", msg.priceten)
end

function roulette_setlog(msg)
    if m_uiroulette_main:null() then
        return
    end
    local list_player = m_uiroulette_main:getwidget("list_player")
    list_player:savestate()
    list_player:clear()

    for i=#msg.log,1,-1 do
        local line = list_player:add(m_roulette_inst.player)
        local log = msg.log[i]
        local logtext = c_textformat("ROULETTE_LOG_PLAYER", log.playername, csvitem_getcolornamefromid(log.itemid))
        local text_name = line:getwidget("text_name")
        text_name:settextscale(logtext)
    end

    list_player:restorestate()

    local text_cash = m_uiroulette_main:getwidget("text_cash")
    text_cash:settext(playerattr_info.cash)

    local text_cashback = m_uiroulette_main:getwidget("text_cashback")
    text_cashback:settext("STORE_CASHBACK", playerattr_info.cashback)

    local list_item = m_uiroulette_main:getwidget("list_item")
    list_item:savestate()
    list_item:clear()

    for i=1,#m_roulette_item do
        local item = m_roulette_item[i]
        local line = list_item:add(m_roulette_inst.item)
        local text_name = line:getwidget("text_name")
        text_name:settextscale(c_textformat("ROULETTE_ITEMLIST_NAME", csvitem_getcolornamefromid(item.itemid), item.itemcount))
    end

    list_item:restorestate()
end

function roulette_additem(msg)
    for i=1,#m_roulette_item do
        if m_roulette_item[i].itemid == msg.itemid then
            m_roulette_item[i].itemcount = m_roulette_item[i].itemcount + msg.itemcount
            return
        end
    end
    local item = {}
    item.itemid = msg.itemid
    item.itemcount = msg.itemcount
    m_roulette_item[#m_roulette_item + 1] = item
end

local function roulette_setitem(index, itemid, itemcount)
    local config_item = csvitem_getfromid(itemid)
    if config_item ~= nil then
        local widgetroot = m_uiroulette_main:getwidget("item_" .. index)
        widgetroot.itemid = itemid
        widgetroot:setdelegate(roulette_delegate_itemicon)
        widgetroot.image_iconbg = widgetroot:getwidget("image_iconbg")

        local image_icon = widgetroot:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_name = widgetroot:getwidget("text_name")
        text_name:settextscale(config_item.name)
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local text_count = widgetroot:getwidget("text_count")
        text_count:settext(itemcount)
    end
end

function roulette_onopen()
    m_uiroulette_main:setwidgetdelegate("image_close", roulette_delegate_close)

    local list_player = m_uiroulette_main:getwidget("list_player")
    list_player:init(uilistflag.vertical)

    local list_item = m_uiroulette_main:getwidget("list_item")
    list_item:init(uilistflag.vertical)

    m_uiroulette_main:setwidgetdelegate("button_one", roulette_delegate_one)
    m_uiroulette_main:setwidgetdelegate("button_ten", roulette_delegate_ten)
    m_uiroulette_main:setwidgetdelegate("button_pay", roulette_delegate_pay)

    local text_desc = m_uiroulette_main:getwidget("text_desc")
    text_desc:settext("ROULETTE_RULE_DESC")

    roulette_setitem(1, 168000037, 1)
    roulette_setitem(2, 168000038, 1)
    roulette_setitem(3, 100200561, 1)
    roulette_setitem(4, 101300591, 1)
    roulette_setitem(5, 100100521, 1)

    m_roulette_item = {}
end

function roulette_delegate_itemicon(sender, event)
    local x,y,w,h = sender.image_iconbg:getabsolute()
    tips_item(sender.itemid, 1, x + w, y + h, tipsflag.vright, nil, m_uiroulette_main)
end

function roulette_delegate_one(sender, event)
    local msg = {messageid="CS_RouletteGacha"}
    msg.type = 1
    c_send(msg)
end

function roulette_delegate_ten(sender, event)
    local msg = {messageid="CS_RouletteGacha"}
    msg.type = 10
    c_send(msg)
end

function roulette_delegate_pay(sender, event)
    store_openpay()
end

function roulette_delegate_close()
    m_uiroulette_main:close()
end
