
local m_businesssellcoin_subpanel = nil

local function business_selladdcoin_getinputcount()
    local edit_count = m_businesssellcoin_subpanel:getwidget("edit_count")
    local count = string.tointeger(edit_count:gettext()) or 0
    return count
end

local function business_selladdcoin_getinputprice()
    local edit_price = m_businesssellcoin_subpanel:getwidget("edit_price")
    local price = string.tointeger(edit_price:gettext()) or 0
    return price
end

function business_selladdcoin_open()
    m_businesssellcoin_subpanel = m_uibusiness_main:getwidget("tab_sellcoin")
    m_businesssellcoin_subpanel:setvisible(true)

    m_businesssellcoin_subpanel:setwidgetdelegate("button_ok", business_selladdcoin_delegate_ok)
    m_businesssellcoin_subpanel:setwidgetdelegate("image_bg/button_close", business_selladdcoin_delegate_close)
    local edit_price = m_businesssellcoin_subpanel:getwidget("edit_price")
    edit_price:settext("0")
    edit_price:setdelegate(business_selladdcoin_delegate_price)

    local edit_count = m_businesssellcoin_subpanel:getwidget("edit_count")
    edit_count:settext("0")
    edit_count:setdelegate(business_selladdcoin_delegate_count)

    local text_bagcoin = m_businesssellcoin_subpanel:getwidget("text_bagcoin")
    text_bagcoin:settext(playerattr_info.coin)
end

function business_selladdcoin_delegate_price(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(0, 2000000000)
    end
end

function business_selladdcoin_delegate_count(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(0, playerattr_info.coin)
    end
end

function business_selladdcoin_delegate_ok()
    local count = business_selladdcoin_getinputcount()
    if count < 1000000 then
        messagealert_addalert("BUSINESS_SELLADDCOIN_COUNTINVALID")
        return
    end

    local price = business_selladdcoin_getinputprice()
    if price <= 0 then
        messagealert_addalert("STALL_PUT_PRICELIMIT")
        return
    end

    local msg = {messageid="CS_BusinessPutCoin"}
    msg.npcactorid = m_uibusiness_main.npcactorid
    msg.price = price
    msg.count = count
    c_send(msg)

    m_businesssellcoin_subpanel:setvisible(false)
end

function business_selladdcoin_delegate_close()
    m_businesssellcoin_subpanel:setvisible(false)
end
