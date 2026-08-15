
local m_uiinputcount = uipanel_createhandle("root/inputcount", uilayer.top, uiflag.escapeclose)

function inputcount_show(title, config_item, defaultcount, maxcount, func, arg)
    m_uiinputcount:open()
    m_uiinputcount.delegatefunc = func
    m_uiinputcount.delegatearg = arg
    m_uiinputcount.maxcount = math.max(1, maxcount or 1)
    m_uiinputcount.currency = nil

    m_uiinputcount:setwidgetdelegate("button_ok", inputcount_delegate_ok)
    m_uiinputcount:setwidgetdelegate("image_bg/button_close", inputcount_delegate_close)

    local text_title = m_uiinputcount:getwidget("image_bg/text_title")
    text_title:settext(title)

    local text_name = m_uiinputcount:getwidget("text_name")
    text_name:settextscale(config_item.name)
    local r,g,b,a = csvitem_getfloatcolor(config_item)
    text_name:setcolor(r,g,b,a)

    local text_desc = m_uiinputcount:getwidget("text_desc")
    local itemdesc, itemspell = csvitem_getdesc(config_item)
    if itemdesc ~= nil then
        text_desc:setvisible(true)
        text_desc:settext(itemdesc)
    else
        text_desc:setvisible(false)
    end

    local image_icon = m_uiinputcount:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local edit_count = m_uiinputcount:getwidget("edit_count")
    edit_count:setdelegate(inputcount_delegate_count)
    edit_count:settext(defaultcount)

    local text_maxcount = m_uiinputcount:getwidget("text_maxcount")
    text_maxcount:settext(c_textformat("INPUTCOUNT_LIMIT", m_uiinputcount.maxcount))
end

function inputcount_addcurrency(currencytype, currencyprice,  currencyinventory)
    if m_uiinputcount.currency == nil then
        m_uiinputcount.currency = {}
    end
    m_uiinputcount.currency[#m_uiinputcount.currency + 1] = {currency = currencytype, price = currencyprice, inventory = currencyinventory}
end

function inputcount_setpricetext(text_price, image_sprite, image_icon, currency)
    if currency ~= nil then
        local edit_count = m_uiinputcount:getwidget("edit_count")
        local text = edit_count:gettext()
        local count = string.tointeger(text)
        if count ~= nil and count > 0 then
            text_price:setvisiblenothit(true)
            text_price:settext(c_textformat("INPUTCOUNT_PRICE", currency.price, currency.price * count))
            text_price:setwarningcolor(currency.inventory ~= nil and currency.price * count > currency.inventory)
            if currency.currency == currency_coin then
                image_sprite:setvisiblenothit(true)
                image_icon:setvisiblenothit(false)
                image_sprite:setsprite("sp1/ccycoin")
            elseif currency.currency == currency_cash then
                image_sprite:setvisiblenothit(true)
                image_icon:setvisiblenothit(false)
                image_sprite:setsprite("sp1/ccycash")
            elseif currency.currency == currency_abyss then
                image_sprite:setvisiblenothit(true)
                image_icon:setvisiblenothit(false)
                image_sprite:setsprite("sp1/ccyabyss")
            else
                if image_sprite ~= nil then
                    image_sprite:setvisiblenothit(false)
                end
                image_icon:setvisiblenothit(true)
                local config_currency = csvitem_getfromid(currency.currency)
                if config_currency ~= nil then
                    image_icon:seticon(config_currency.icon)
                else
                    image_icon:setvisiblenothit(false)
                end
            end
            return
        end
    end
    text_price:setvisiblenothit(false)
    image_icon:setvisiblenothit(false)
    if image_sprite ~= nil then
        image_sprite:setvisiblenothit(false)
    end
end

function inputcount_updateprice()
    local currency1 = nil
    local currency2 = nil
    if m_uiinputcount.currency ~= nil then
        currency1 = m_uiinputcount.currency[1]
        currency2 = m_uiinputcount.currency[2]
    end
    inputcount_setpricetext(m_uiinputcount:getwidget("text_price1"), m_uiinputcount:getwidget("image_coin"), m_uiinputcount:getwidget("image_currency1"), currency1)
    inputcount_setpricetext(m_uiinputcount:getwidget("text_price2"), nil, m_uiinputcount:getwidget("image_currency2"), currency2)
end

function inputcount_sethint(text)
    local edit_count = m_uiinputcount:getwidget("edit_count")
    edit_count:sethinttext(text)
end

function inputcount_delegate_count(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(1, m_uiinputcount.maxcount)
        inputcount_updateprice()
    end
end

function inputcount_delegate_ok(sender)
    local edit_count = m_uiinputcount:getwidget("edit_count")
    local text = edit_count:gettext()
    local count = string.tointeger(text)
    if count == nil or count < 1 or count > m_uiinputcount.maxcount then
        return
    end
    m_uiinputcount:close()
    m_uiinputcount.delegatefunc(m_uiinputcount.delegatearg, count)
end

function inputcount_delegate_close()
    m_uiinputcount:close()
end
