
local m_shopredeem_inst = {item = "shop/inst_buy"}

local function shopredeem_updatebutton()
    local button_type = m_uishop_main:getwidget("button_type_1")
    button_type:setvisible(true)
    button_type:setenable(false)
    button_type:settext("SHOP_MAIN_BUY")
    m_uishop_main:hideunused("button_type_", 2)
end

local function shopredeem_updateshop()
    local list_item = m_uishop_main:getwidget("tab_redeem/list_item")
    list_item:clear()
    for i=1,#playerattr_redeem do
        local redeem = playerattr_redeem[i]
        local config_item = csvitem_getfromid(redeem.itemid)
        if config_item ~= nil then
            local line = list_item:add(m_shopredeem_inst.item, i, i)
            line.redeem = redeem
            line.config_item = config_item

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)

            local image_currency1 = line:getwidget("image_currency1")
            image_currency1:setvisiblenothit(false)

            local image_currency2 = line:getwidget("image_currency2")
            image_currency2:setvisiblenothit(false)
        
            local text_price1 = line:getwidget("text_price1")
            text_price1:settext(config_item.price)

            local text_price2 = line:getwidget("text_price2")
            text_price2:setvisiblenothit(false)

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_count = line:getwidget("text_count")
            text_count:settext(redeem.count)

            local image_coin = line:getwidget("image_coin")
            image_coin:setsprite("sp1/ccycoin")
        end
    end
end

function shopredeem_onopen()
    local list_item = m_uishop_main:getwidget("tab_redeem/list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(shopredeem_delegate_listitem)
end

function shopredeem_updateui()
    local text_title = m_uishop_main:getwidget("image_bg/text_title")
    text_title:settext("SHOP_MAIN_REDEEM")

    shopredeem_updatebutton()
    shopredeem_updateshop()
end

function shopredeem_delegate_input(ok, data)
    if ok then
        local msg = {messageid="CS_ShopRedeem"}
        msg.actorid = m_uishop_main.npcactorid
        msg.uuid = data
        c_send(msg)
    end
end

function shopredeem_delegate_listitem(line, event, itemid)
    local text = c_textformat("SHOP_REDEEM_CONFIRM", line.config_item.name, line.redeem.count)
    messagebox_confirm(text, shopredeem_delegate_input, line.redeem.uuid)
end
