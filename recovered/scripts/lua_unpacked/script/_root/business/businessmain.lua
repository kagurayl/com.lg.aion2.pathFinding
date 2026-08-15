
include("business/businessquery")
include("business/businessquerycatalog")
include("business/businessfilter")
include("business/businesssell")
include("business/businesssettle")
include("business/businessselladdcoin")
include("business/businessselladditem")

BusinessTab =
{
    query = 1,
    sell = 2,
    settle = 3,
}
m_business_state = BusinessTab.query
m_uibusiness_main = uipanel_createhandle("business/business_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.fullscreen, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function business_main_onopen()
    m_uibusiness_main:setwidgetdelegate("image_bg/button_close", business_main_delegate_close)

    m_uibusiness_main.tabmain = uitabcreate(m_uibusiness_main)
    m_uibusiness_main.tabmain:add("button_query", "tab_query", business_main_delegate_query)
    m_uibusiness_main.tabmain:add("button_sell", "tab_sell", business_main_delegate_sell)
    m_uibusiness_main.tabmain:add("button_settle", "tab_settle", business_main_delegate_settle)
    m_uibusiness_main.tabmain:settab(1)

    m_business_state = BusinessTab.query
    business_query_onopen()
    business_sell_onopen()
    business_settle_onopen()
    business_main_updateui()
end

function business_main_updateui()
    if m_uibusiness_main:null() then
        return
    end
    m_uibusiness_main:setwidgetvisible("tab_filter", false)
    m_uibusiness_main:setwidgetvisible("tab_sellcoin", false)
    m_uibusiness_main:setwidgetvisible("tab_sellitem", false)
    if m_business_state == BusinessTab.query then
        business_query_updateui()
    elseif m_business_state == BusinessTab.sell then
        business_sell_updateui()
    elseif m_business_state == BusinessTab.settle then
        business_settle_updateui()
    end
end

function business_main_delegate_query()
    m_business_state = BusinessTab.query
    tips_close()
    business_main_updateui()
end

function business_main_delegate_sell()
    m_business_state = BusinessTab.sell
    tips_close()
    business_main_updateui()
end

function business_main_delegate_settle()
    m_business_state = BusinessTab.settle
    tips_close()
    business_main_updateui()
end

function business_main_delegate_close()
    m_uibusiness_main:close()
end
