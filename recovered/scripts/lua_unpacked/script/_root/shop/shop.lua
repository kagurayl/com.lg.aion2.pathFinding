
include("shop/shopmain")
include("shop/shopbuy")
include("shop/shopredeem")
include("shop/shopstall")
include("shop/stallmine")
include("shop/playerdeal")

shopstate = 
{
    buy = 1,
    redeem = 2,
}

m_uishop_main = uipanel_createhandle("shop/shop_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft), AudioOpenUI, AudioCloseUI)
m_uistall_mine = uipanel_createhandle("shop/stall_mine", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)

function shop_setshop(actorid, buy, price, shopid, shoptype)
    m_uishop_main.npcactorid = actorid
    m_uishop_main.shopid = shopid
    m_uishop_main.shoptype = shoptype
    m_uishop_main.shopstate = shopstate.buy
    m_uishop_main.shopselect = 1
    m_uishop_main.limit = nil
    m_uishop_main:open()
    shop_updateshop()
end

function shop_setlimit(limit)
    m_uishop_main.limit = limit
    shop_updateshop()
end

function shop_sellenable()
    if m_uishop_main:alive() then
        if m_uishop_main.shopstate == shopstate.buy or m_uishop_main.shopstate == shopstate.redeem then
            return true
        end
    end
    return false
end

function shop_updateshop()
    if m_uishop_main:alive() then
        shop_main_updateui()
        if m_uishop_main.shopstate == shopstate.buy then
            shopbuy_updateui()
        elseif m_uishop_main.shopstate == shopstate.redeem then
            shopredeem_updateui()
        end
    end
end
function shop_updatestall()
    if m_uistall_mine:alive() then
        stall_mine_updateui()
    end
end
