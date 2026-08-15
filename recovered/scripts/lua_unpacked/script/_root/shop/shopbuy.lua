
local shopbuytype =
{
    gold = 0,
    currency = 1,
    tradein = 2,
    abyss = 3,
}

local m_shopbuy_inst = {item = "shop/inst_buy"}

local function shopbuy_updatebutton()
    if m_uishop_main.shopid == nil then
        return
    end
    local typecount = 1
    for i=1, #m_uishop_main.shopid do
        local button_type = m_uishop_main:getwidget("button_type_" .. typecount)
        if button_type == nil then
            break
        end
        local config_shop = csvshop_getshop(m_uishop_main.shopid[i])
        if config_shop == nil then
            break
        end
        typecount = typecount + 1
        button_type:setvisible(true)
        button_type:settextscale(config_shop.name)
        button_type:setenable(m_uishop_main.shopselect ~= i)
        button_type.typeindex = i
        button_type:setdelegate(shopbuy_delegate_type)
    end
    m_uishop_main:hideunused("button_type_", typecount)
end

local function shopbuy_updateshop()
    if m_uishop_main.shopid == nil then
        return
    end
    local config_shop = csvshop_getshop(m_uishop_main.shopid[m_uishop_main.shopselect])
    if config_shop == nil then
        return
    end
    local itemidarray = string.splitinterger(config_shop.item, ";")
    local itemsortarray = {}
    for i=1,#itemidarray do
        local sort = {}
        sort.id = itemidarray[i]
        sort.skillcareer = nil
        sort.skilllevel = nil
        local config_item = csvitem_getfromid(sort.id)
        if config_item ~= nil then
            if config_item.itemtype == csvitemtype.skill_book then
                local lambda = csvitem_getscript(config_item, "addskill")
                if lambda ~= nil then
                    local config_skilllearn = csvskilllearn_getfromid(lambda.variable[1].integer)
                    if config_skilllearn ~= nil then
                        sort.skillcareer = config_skilllearn.career
                        sort.skilllevel = config_skilllearn.playerlevel
                        if playerskill_available(config_skilllearn.id) then
                            sort = nil
                        end
                    end
                end
            elseif csvitem_isrecipe(config_item) then
                local lambda = csvitem_getscript(config_item, "addrecipe")
                if lambda ~= nil and playerskill_getrecipe(lambda.variable[1].integer) ~= nil then
                    sort = nil
                end
            end
        end
        if sort ~= nil then
            itemsortarray[#itemsortarray + 1] = sort
        end
    end
    table.sort(itemsortarray, function(p1, p2)
        if p1.skillcareer ~= nil and p2.skillcareer ~= nil then
            if p1.skillcareer == p2.skillcareer then
                return p1.skilllevel < p2.skilllevel
            else
                return p1.skillcareer < p2.skillcareer
            end
        else
            return p1.id < p2.id
        end
    end)

    local list_item = m_uishop_main:getwidget("tab_buy/list_item")
    list_item:savestate()
    list_item:clear()
    for i=1,#itemsortarray do
        list_item:add(m_shopbuy_inst.item, i, itemsortarray[i].id)
    end
    list_item:restorestate()
end

function shopbuy_onopen()
    local list_item = m_uishop_main:getwidget("tab_buy/list_item")
    list_item:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_item:setasyncdelegate(shopbuy_delegate_setlist)
    list_item:setclickdelegate(shopbuy_delegate_listitem)

    shopbuy_updatebutton()
    shopbuy_updateshop()
end

function shopbuy_updateui()
    local text_title = m_uishop_main:getwidget("image_bg/text_title")
    text_title:settext("SHOP_MAIN_BUY")

    shopbuy_updatebutton()
    shopbuy_updateshop()
end

function shopbuy_delegate_input(data, count)
    if count > 0 then
        local msg = {messageid="CS_ShopBuy"}
        msg.actorid = m_uishop_main.npcactorid
        msg.itemid = data.id
        msg.count = count
        c_send(msg)
    end
end

function shopbuy_delegate_oneconfirm(ok, data)
    if ok then
        local msg = {messageid="CS_ShopBuy"}
        msg.actorid = m_uishop_main.npcactorid
        msg.itemid = data.id
        msg.count = 1
        c_send(msg)
    end
end

function shopbuy_convertcurrency(itemid)
    if itemid == 186000130 then
        if playerattr_info.civ == playerciv.dark then
            return 186000131
        end
    end
    return itemid
end

function shopbuy_delegate_buy(data)
    local config_item = csvitem_getfromid(data)
    if config_item ~= nil then
        if config_item.stack ~= nil and config_item.stack > 1 then
            inputcount_show("SHOP_BUY_INPUT_TITLE", config_item, 1, config_item.stack, shopbuy_delegate_input, config_item)
            local shoptype = m_uishop_main.shoptype[m_uishop_main.shopselect]
            if shoptype == shopbuytype.gold then
                inputcount_addcurrency(currency_coin, config_item.price, playerattr_info.coin)
            elseif shoptype == shopbuytype.currency then
                local currency = csvconfig_lambda(config_item.tradein, "currency")
                if currency ~= nil then
                    local itemid = currency.variable[1].integer
                    local itemcount = currency.variable[1].count
                    inputcount_addcurrency(itemid, itemcount, playeritem_getcount(shopbuy_convertcurrency(itemid)))
                end
            elseif shoptype == shopbuytype.tradein then
                local tradein = csvconfig_lambda(config_item.tradein, "tradein")
                if tradein ~= nil then
                    local itemid = tradein.variable[1].integer
                    local itemcount = tradein.variable[1].count
                    inputcount_addcurrency(itemid, itemcount, playeritem_getcount(shopbuy_convertcurrency(itemid)))
                    if tradein.variablecount > 1 then
                        itemid = tradein.variable[2].integer
                        itemcount = tradein.variable[2].count
                        inputcount_addcurrency(itemid, itemcount, playeritem_getcount(shopbuy_convertcurrency(itemid)))
                    end
                end
            elseif shoptype == shopbuytype.abyss then
                local abyss = csvconfig_lambda(config_item.tradein, "abyss")
                if abyss ~= nil then
                    local point = abyss.variable[1].integer
                    inputcount_addcurrency(currency_abyss, point, playerattr_pvp.score)
                    local itemid = abyss.variable[2].integer
                    local itemcount = abyss.variable[2].count
                    if itemid ~= 0 then
                        inputcount_addcurrency(itemid, itemcount, playeritem_getcount(shopbuy_convertcurrency(itemid)))
                    end
                end
            end
            inputcount_updateprice()
        else
            local message = c_textformat("SHOP_BUY_ONE", config_item.name)
            messagebox_confirm(message, shopbuy_delegate_oneconfirm, config_item, nil, nil, "")
        end
    end
end

function shopbuy_delegate_preview(data)
    local config_item = csvitem_getfromid(data)
    if config_item ~= nil then
        if config_item ~= nil and m_me ~= nil then
            m_me:setpreview(config_item, nil)
        end
    end
end

function shopbuy_delegate_listitem(line, event, itemid)
    itemmenu_reset(itemid)
    itemmenu_addbutton("SHOP_MAIN_BUY", shopbuy_delegate_buy)

    local part = csvrender_getitemrender(csvitem_getfromid(itemid))
    if part ~= nil then
        itemmenu_addbutton("SHOP_MAIN_PREVIEW", shopbuy_delegate_preview)
    end

    local image_bg = m_uishop_main:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    local menux = x + w
    local menuy = y + h / 2 + itemmenu_getheight() / 2
    itemmenu_open(menux, menuy, m_uishop_main)

    local extra = nil
    if m_uishop_main.limit ~= nil then
        extra = {}
        extra.limit = m_uishop_main.limit
    end
    tips_item(itemid, 1, menux + itemmenu_getwidth(), -1, tipsflag.vright, extra, m_uishop_main)
end

function shopbuy_delegate_setlist(sender, line, itemid)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    local text_name = line:getwidget("text_name")
    text_name:settext(config_item.name)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_count = line:getwidget("text_count")
    text_count:setvisiblenothit(false)

    local image_coin = line:getwidget("image_coin")
    local image_currency1 = line:getwidget("image_currency1")
    local image_currency2 = line:getwidget("image_currency2")
    local text_price1 = line:getwidget("text_price1")
    local text_price2 = line:getwidget("text_price2")
    local shoptype = m_uishop_main.shoptype[m_uishop_main.shopselect]
    if shoptype == shopbuytype.gold then
        image_coin:setvisible(true)
        image_currency1:setvisible(false)
        image_currency2:setvisible(false)
        text_price2:setvisible(false)
        image_coin:setsprite("sp1/ccycoin")
        text_price1:settext(config_item.price)
        text_price1:setwarningcolor(config_item.price > playerattr_info.coin)
    elseif shoptype == shopbuytype.currency then
        image_coin:setvisible(false)
        image_currency1:setvisible(true)
        image_currency2:setvisible(false)
        text_price2:setvisible(false)
        local currency = csvconfig_lambda(config_item.tradein, "currency")
        if currency ~= nil then
            local itemid = currency.variable[1].integer
            local itemcount = currency.variable[1].count
            local config_currency = csvitem_getfromid(itemid)
            if config_currency ~= nil then
                image_currency1:seticon(config_currency.icon)
            end
            text_price1:settext("x" .. itemcount)
            text_price1:setwarningcolor(itemcount > playeritem_getcount(shopbuy_convertcurrency(itemid)))
        end
    elseif shoptype == shopbuytype.tradein then
        image_coin:setvisible(false)
        local tradein = csvconfig_lambda(config_item.tradein, "tradein")
        if tradein ~= nil then
            local itemid = tradein.variable[1].integer
            local itemcount = tradein.variable[1].count
            image_currency1:setvisible(true)
            local config_currency = csvitem_getfromid(itemid)
            if config_currency ~= nil then
                image_currency1:seticon(config_currency.icon)
            end
            text_price1:settext("x" .. itemcount)
            text_price1:setwarningcolor(itemcount > playeritem_getcount(shopbuy_convertcurrency(itemid)))
            if tradein.variablecount > 1 then
                itemid = tradein.variable[2].integer
                itemcount = tradein.variable[2].count
                image_currency2:setvisible(true)
                text_price2:setvisible(true)
                config_currency = csvitem_getfromid(itemid)
                if config_currency ~= nil then
                    image_currency2:seticon(config_currency.icon)
                end
                text_price2:settext("x" .. itemcount)
                text_price2:setwarningcolor(itemcount > playeritem_getcount(shopbuy_convertcurrency(itemid)))
            else
                image_currency2:setvisible(false)
                text_price2:setvisible(false)
            end
        end
    elseif shoptype == shopbuytype.abyss then
        image_coin:setvisible(true)
        image_coin:setsprite("sp1/ccyabyss")
        image_currency1:setvisible(false)
        image_currency2:setvisible(true)
        text_price2:setvisible(true)   
        local abyss = csvconfig_lambda(config_item.tradein, "abyss")
        if abyss ~= nil then
            local point = abyss.variable[1].integer
            local itemid = abyss.variable[2].integer
            local itemcount = abyss.variable[2].count
            text_price1:settext(point)
            text_price1:setwarningcolor(point > playerattr_pvp.score)
            if itemid ~= 0 then
                local config_currency = csvitem_getfromid(itemid)
                if config_currency ~= nil then
                    image_currency2:seticon(config_currency.icon)
                else
                    image_currency2:setvisible(false)
                end
                text_price2:settext("x" .. itemcount)
                text_price2:setwarningcolor(itemcount > playeritem_getcount(shopbuy_convertcurrency(itemid)))
            else
                image_currency2:setvisible(false)
                text_price2:setvisible(false)
            end
        end
    end
end

function shopbuy_delegate_type(sender)
    m_uishop_main.shopselect = sender.typeindex
    shopbuy_updateui()
end
