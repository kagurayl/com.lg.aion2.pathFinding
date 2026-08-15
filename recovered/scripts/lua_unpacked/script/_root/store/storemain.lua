
local storecategory = 
{
    all = "ALL",
    cashback = "CASHBACK",
    payment = "PAYMENT",
    paylist = "PAYLIST",
}

local store_itemcol = 5
local m_uistore_main = uipanel_createhandle("store/store_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.fullscreen, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_store_inst = {category = "store/inst_storecategory", item = "store/inst_storeline", orderlist = "store/inst_storepaylist"}

function store_open()
    m_uistore_main:open()
end

function store_openpay()
    m_uistore_main:open()
    m_uistore_main.selectcategory = storecategory.payment
    store_updateui()
end

function store_main_addcategory(list_type, type, key)
    local line = list_type:add(m_store_inst.category)
    local button_type = line:getwidget("button_type")
    button_type.storecategory = type
    button_type:settext(key)
    button_type:setdelegate(store_main_delegate_type)
end

function store_main_onopen()
    m_uistore_main:setwidgetdelegate("image_bg/button_close", store_main_delegate_close)
    m_uistore_main.selectcategory = storecategory.all
    m_uistore_main.orderlist = nil
    local list_type = m_uistore_main:getwidget("list_type")
    list_type:init(uilistflag.vertical)

    local list_item = m_uistore_main:getwidget("list_item")
    list_item:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_item:setasyncdelegate(store_delegate_setlist)

    local list_paylist = m_uistore_main:getwidget("tabpaylist/list_paylist")
    list_paylist:init(uilistflag.vertical)

    local typearray = {"ALL", "SKIN", "VIP", "ENCHANT", "CONSUME", "MORPH", "CARD", "PET", "CASHBACK", "PAYMENT", "PAYLIST"}
    for i=1,#typearray do
        local key = "STORE_CATEGORY_" .. typearray[i]
        store_main_addcategory(list_type, typearray[i], key)
    end

    store_updateui()
end

function store_setorderlist(orderlist)
    if m_uistore_main:null() then
        return
    end
    m_uistore_main.orderlist = orderlist
    if m_uistore_main.selectcategory == storecategory.paylist then
        store_updateui()
    end
end

function store_setlimit(limit)
    m_uistore_main.limit = limit
    store_updateui()
end

local function store_additemlist(list_item)
    local storearray = c_config_getmetaall(configid.store)
    local line = nil
    local linedata = nil
    for i=1,#storearray do
        local config_store = storearray[i]
        if m_uistore_main.selectcategory == storecategory.all or config_store.category == m_uistore_main.selectcategory then
            local config_item = csvitem_getfromid(config_store.id)
            if config_item ~= nil and playercivavailable(config_store.civ, playerattr_info.civ) and playercivavailable(config_item.civ, playerattr_info.civ) then
                if line == nil or #linedata == store_itemcol then
                    linedata = {}
                    line = list_item:add(m_store_inst.item, i, linedata)
                end
                linedata[#linedata + 1] = config_store
            end
        end
    end
end

local function store_addpayment(list_item)
    local paymentarray = c_config_getmetaall(configid.payment)
    for i=1,#paymentarray do
		local config_payment = paymentarray[i]
        local image_bg = m_uistore_main:getwidget(string.format("tabpay/storepay_%d/image_bg", i))
        image_bg.payid = config_payment.id
        image_bg:setdelegate(store_main_delegate_pay)

        local text_name = m_uistore_main:getwidget(string.format("tabpay/storepay_%d/text_name", i))
        if config_payment.cashex > 0 then
            text_name:settext("STORE_PAYMENT_CASHEX", config_payment.cash, config_payment.cashex)
        else
            text_name:settext("STORE_PAYMENT_CASH", config_payment.cash)
        end

        local text_price = m_uistore_main:getwidget(string.format("tabpay/storepay_%d/text_price", i))
        text_price:settext("STORE_PAYMENT_PRICE", config_payment.price)        
	end
end

local function store_addpaylist()
    local list_paylist = m_uistore_main:getwidget("tabpaylist/list_paylist")
    list_paylist:savestate()
    list_paylist:clear()

    local text_paylistcount = m_uistore_main:getwidget("tabpaylist/text_paylistcount")
    if m_uistore_main.orderlist ~= nil then
        for i=1,#m_uistore_main.orderlist do
            local order = m_uistore_main.orderlist[i]
            local line = list_paylist:add(m_store_inst.orderlist)
            local text_orderid = line:getwidget("text_orderid")
            text_orderid:settext(order.orderid)

            local text_time = line:getwidget("text_time")
            text_time:settext(order.time)

            local text_amount = line:getwidget("text_amount")
            text_amount:settext(order.amount)

            local text_receive = line:getwidget("text_receive")
            local button_query = line:getwidget("button_query")
            button_query:setdelegate(store_main_delegate_queryorder)
            button_query.orderid = order.orderid
            if order.receive == 1 then
                text_receive:settext("STORE_PAYLIST_RECEIVE_OK")
                text_receive:setcolor(0.42, 0.9, 0, 1)
                button_query:setenable(false)
            else
                text_receive:settext("STORE_PAYLIST_RECEIVE_NONE")
                text_receive:setcolor(1.0, 0.72, 0.17, 1)
                button_query:setenable(true)
            end
        end
        text_paylistcount:settext("STORE_PAYLIST_COUNTMAX", #m_uistore_main.orderlist)
    else
        text_paylistcount:settext("STORE_PAYLIST_QUERYING")
    end
    list_paylist:restorestate()
end

function store_updateui()
    if m_uistore_main:null() then
        return
    end
   
    local list_type = m_uistore_main:getwidget("list_type")
    for i=1,list_type:getcount() do
        local line = list_type:getlinefromindex(i)
        local button_type = line:getwidget("button_type")
        button_type:setenable(button_type.storecategory ~= m_uistore_main.selectcategory)
    end

    local list_item = m_uistore_main:getwidget("list_item")
    list_item:savestate()
    list_item:clear()

    m_uistore_main:setwidgetvisiblenothit("tabpay", m_uistore_main.selectcategory == storecategory.payment)
    m_uistore_main:setwidgetvisiblenothit("tabpaylist", m_uistore_main.selectcategory == storecategory.paylist)
    if m_uistore_main.selectcategory == storecategory.payment then
        store_addpayment(list_item)
    elseif m_uistore_main.selectcategory == storecategory.paylist then
        store_addpaylist(list_item)
    else
        store_additemlist(list_item)
    end

    list_item:restorestate()

    local text_coin = m_uistore_main:getwidget("text_coin")
    text_coin:settext(playerattr_info.coin)

    local text_cash = m_uistore_main:getwidget("text_cash")
    text_cash:settext(playerattr_info.cash)

    local text_cashback = m_uistore_main:getwidget("text_cashback")
    text_cashback:settext("STORE_CASHBACK", playerattr_info.cashback)
end

local function store_getcountdesc(count)
    if count >= 100000000 then
        return string.format("%d%s", math.floor(count / 100000000), c_textformat("UNIT_Y"))
    elseif count >= 10000 then
        return string.format("%d%s", math.floor(count / 10000), c_textformat("UNIT_W"))
    end
    return string.format("%d", count)
end

function store_delegate_setlist(sender, line, data)
    for i=1,#data do
        local config_store = data[i]
        local subitemname = "inst_item_" .. i
        line:setwidgetvisible(subitemname, true)
        local config_item = csvitem_getfromid(config_store.id)

        local image_icon = line:getwidget(subitemname .. "/image_icon")
        image_icon:seticon(config_item.icon)
        image_icon:setdelegate(store_main_delegate_itemicon)
        image_icon.itemid = config_item.id

        local text_name = line:getwidget(subitemname .. "/text_name")
        if config_store.count > 1 then
            text_name:settextscale(c_textformat("STORE_NAMECOUNT", config_item.name, store_getcountdesc(config_store.count)))
        else
            text_name:settextscale(config_item.name)
        end
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local text_price = line:getwidget(subitemname .. "/text_price")
        if config_store.currency == 0 then
            text_price:settext(c_textformat("STORE_PRICE", config_store.price))
            if config_store.price <= playerattr_info.cash then
                text_price:setcolor(1,1,1,1)
            else
                text_price:setcolor(1,0,0,1)
            end
        else
            text_price:settext(c_textformat("STORE_PRICE_CASHBACK", config_store.price))
            if config_store.price <= playerattr_info.cashback then
                text_price:setcolor(1,1,1,1)
            else
                text_price:setcolor(1,0,0,1)
            end
        end

        local image_preview = line:getwidget(subitemname .. "/image_preview")
        local part = csvrender_getitemrender(config_item)
        if part ~= nil then
            image_preview:setvisible(true)
            image_preview:setdelegate(store_main_delegate_preview)
            image_preview.config_item = config_item
        else
            image_preview:setvisible(false)
        end

        local button_buy = line:getwidget(subitemname .. "/button_buy")
        button_buy:setdelegate(store_main_delegate_buy)
        button_buy.config_item = config_item
        button_buy.config_store = config_store
    end
    
    for i=#data+1,store_itemcol do
        line:setwidgetvisible("inst_item_" .. i, false)
    end
end

function store_main_delegate_type(sender, event)
    m_uistore_main.selectcategory = sender.storecategory
    tips_close()
    store_updateui()
    if m_uistore_main.selectcategory == storecategory.paylist then
        local msg = {messageid="CS_StorePayQueryList"}
        c_send(msg)
    end
end

function store_main_delegate_preview(sender, event)
    if m_me ~= nil and m_me:setpreview(sender.config_item, nil) then
        m_uistore_main:close()
    end
end

function store_delegate_input(data, count)
    if count > 0 then
        local msg = {messageid="CS_StoreBuy"}
        msg.itemid = data.id
        msg.count = count
        msg.currency = data.currency
        msg.price = data.price
        c_send(msg)
    end
end
function store_main_delegate_buy(sender, event)
    tips_close()
    local maxcount = 1
    if sender.config_item.id ~= itemid_coin and sender.config_item.stack ~= nil and sender.config_store.count == 1 then
        maxcount = math.tointegerfloor(sender.config_item.stack / sender.config_store.count)
    end
    inputcount_show("STORE_INPUTTITLE", sender.config_item, 1, maxcount, store_delegate_input, sender.config_store)
    if sender.config_store.currency == 0 then
        inputcount_addcurrency(currency_cash, sender.config_store.price, playerattr_info.cash)
    else
        inputcount_addcurrency(currency_cashback, sender.config_store.price, playerattr_info.cashback)
    end
    inputcount_updateprice()
end

function store_main_paytype(ok, data)
    local msg = {messageid="CS_StorePay"}
    msg.payid = data
    msg.paytype = math.ternary(ok, 0, 1)
    c_send(msg)
end

function store_main_delegate_pay(sender, event)
    messagebox_confirm("选择支付方式", store_main_paytype, sender.payid, "微信支付", "支付宝支付", nil)
end

function store_main_delegate_queryorder(sender, event)
    local msg = {messageid="CS_StorePayQueryOrder"}
    msg.orderid = sender.orderid
    c_send(msg)
end

function store_main_delegate_itemicon(sender, event)
    local x,y,w,h = sender:getabsolute()
    local extra = nil
    if m_uistore_main.limit ~= nil then
        extra = {}
        extra.limit = m_uistore_main.limit
    end
    tips_item(sender.itemid, 1, x + w, y + h, tipsflag.vright, extra, m_uistore_main)
end

function store_main_delegate_close()
    m_uistore_main:close()
end
