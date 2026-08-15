
function shop_main_onopen()
    m_uishop_main:setwidgetdelegate("button_buy", shop_main_delegate_buy)
    m_uishop_main:setwidgetdelegate("button_redeem", shop_main_delegate_redeem)
    m_uishop_main:setwidgetdelegate("button_junk", shop_main_delegate_junk)
    m_uishop_main:setwidgetdelegate("image_bg/button_close", shop_main_delegate_close)
    shopbuy_onopen()
    shopredeem_onopen()
    bag_open()
end

function shop_main_updateui()
    m_uishop_main:setwidgetvisible("tab_buy", m_uishop_main.shopstate == shopstate.buy)
    m_uishop_main:setwidgetvisible("tab_redeem", m_uishop_main.shopstate == shopstate.redeem)
    m_uishop_main:setwidgetenable("button_buy", m_uishop_main.shopstate ~= shopstate.buy)
    m_uishop_main:setwidgetenable("button_redeem", m_uishop_main.shopstate ~= shopstate.redeem)
end

function shop_main_delegate_buy()
    m_uishop_main.shopstate = shopstate.buy
    shop_updateshop()
end

function shop_main_delegate_redeem()
    m_uishop_main.shopstate = shopstate.redeem
    shop_updateshop()
end

function shop_main_delegate_junk_confirm(ok, data)
    if ok then
        c_send(data)
    end
end
function shop_main_delegate_junk()
    local price = 0
    local msg = {messageid="CS_ShopSell"}
    msg.actorid = m_uishop_main.npcactorid
    msg.uuid = {}
    msg.count = {}
    for i=1, #playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and config_item.quality == csvitemquality.grey then
                price = price + math.max(1, math.tointegerfloor(config_item.price / shopsell_ratio)) * item.count
                msg.uuid[#msg.uuid + 1] = item.uuid
                msg.count[#msg.count + 1] = item.count
            end
        end
    end
    if #msg.count > 0 then
        messagebox_confirm(c_textformat("SHOP_MAIN_SELLJUNK_CONFIRM", price), shop_main_delegate_junk_confirm, msg)
    else
        messagealert_addalert("SHOP_MAIN_SELLJUNK_NONE")
    end
end

function shop_main_delegate_close()
    m_uishop_main:close()
end
