
local m_businesssellitem_subpanel = nil
local m_uibusiness_selladditem_inst = {item = "business/inst_itemselladditem"}
local m_uibusiness_selladditem_itemconfig = nil
local m_uibusiness_selladditem_uuid = 0
local m_uibusiness_selladditem_maxcount = 0

local function business_selladditem_getinputcount()
    local edit_count = m_businesssellitem_subpanel:getwidget("group_select/edit_count")
    local count = string.tointeger(edit_count:gettext()) or 0
    return count
end

local function business_selladditem_getinputprice()
    local edit_price = m_businesssellitem_subpanel:getwidget("group_select/edit_price")
    local price = string.tointeger(edit_price:gettext()) or 0
    return price
end

local function business_selladditem_setinputcount(count)
    local edit_count = m_businesssellitem_subpanel:getwidget("group_select/edit_count")
    edit_count:settext(count)
end

local function business_selladditem_additem(list_item, item)
    if playeritem_getitemdeal(item) then
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            local line = list_item:add(m_uibusiness_selladditem_inst.item, list_item:getcount(), item.uuid)
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_name = line:getwidget("text_name")
            text_name:settextscale(config_item.name)

            local text_count = line:getwidget("text_count")
            text_count:settext("x" .. item.count)
        end
    end

end
function business_selladditem_open()
    m_businesssellitem_subpanel = m_uibusiness_main:getwidget("tab_sellitem")
    m_businesssellitem_subpanel:setvisible(true)

    m_businesssellitem_subpanel:setwidgetdelegate("group_select/button_ok", business_selladditem_delegate_ok)
    m_businesssellitem_subpanel:setwidgetdelegate("group_select/button_pageprev", business_selladditem_delegate_pageprev)
    m_businesssellitem_subpanel:setwidgetdelegate("group_select/button_pagenext", business_selladditem_delegate_pagenext)

    m_businesssellitem_subpanel:setwidgetdelegate("image_bg/button_close", business_selladditem_delegate_close)
    local edit_price = m_businesssellitem_subpanel:getwidget("group_select/edit_price")
    edit_price:settext("0")
    edit_price:setdelegate(business_selladditem_delegate_price)

    local edit_count = m_businesssellitem_subpanel:getwidget("group_select/edit_count")
    edit_count:settext("1")
    edit_count:setdelegate(business_selladditem_delegate_count)

    m_uibusiness_selladditem_itemconfig = nil
    m_uibusiness_selladditem_uuid = 0
    m_uibusiness_selladditem_maxcount = 0

    local list_item = m_businesssellitem_subpanel:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(business_selladditem_delegate_listitem)
    for i=1, #playerattr_bag do
        local item = playerattr_bag[i]
        business_selladditem_additem(list_item, item)
    end
    business_selladditem_updateui()
end

function business_selladditem_updateui()
    local visible = m_uibusiness_selladditem_itemconfig ~= nil
    m_businesssellitem_subpanel:setwidgetvisible("text_none", not visible)
    m_businesssellitem_subpanel:setwidgetvisible("group_select", visible)
    if not visible then
        return
    end

    local image_icon = m_businesssellitem_subpanel:getwidget("group_select/image_icon")
    image_icon:seticon(m_uibusiness_selladditem_itemconfig.icon)

    local text_name = m_businesssellitem_subpanel:getwidget("group_select/text_name")
    text_name:settextscale(m_uibusiness_selladditem_itemconfig.name)
    text_name:setcolor(csvitem_getfloatcolor(m_uibusiness_selladditem_itemconfig))

    local count = business_selladditem_getinputcount()
    if count > m_uibusiness_selladditem_maxcount then
        count = m_uibusiness_selladditem_maxcount
        business_selladditem_setinputcount(count)
    end
    local pricetotal = business_selladditem_getinputprice() * count
    local text_pricetotal = m_businesssellitem_subpanel:getwidget("group_select/text_pricetotal")

    text_pricetotal:setmoney(pricetotal)

    local saletaxrate = math.ternary(#playerattr_business <= 10, m_uibusiness_main.saletax1, m_uibusiness_main.saletax2)

    local text_saletax = m_businesssellitem_subpanel:getwidget("group_select/text_saletax")
    text_saletax:setmoney(math.max(10, math.roundoff(pricetotal * saletaxrate / 10000)))

    local text_saletaxlevel = m_businesssellitem_subpanel:getwidget("group_select/text_saletaxlevel")
    text_saletaxlevel:settext("BUSINESS_SELLADD_SALELEVEL", #playerattr_business + 1, math.roundoff(saletaxrate / 100.0))
end

function business_selladditem_delegate_listitem(line, event, uuid)
    local item = playeritem_getfrombaguuid(uuid)
    if item ~= nil then
        m_uibusiness_selladditem_itemconfig = csvitem_getfromid(item.itemid)
        m_uibusiness_selladditem_uuid = uuid
        m_uibusiness_selladditem_maxcount = item.count
        local edit_price = m_businesssellitem_subpanel:getwidget("group_select/edit_price")
        edit_price:settext("0")
        business_selladditem_setinputcount(1)
    else
        m_uibusiness_selladditem_itemconfig = nil
        m_uibusiness_selladditem_uuid = 0
        m_uibusiness_selladditem_maxcount = 0
    end
    business_selladditem_updateui()
end

function business_selladditem_delegate_price(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(0, 2000000000)
        business_selladditem_updateui()
    end
end

function business_selladditem_delegate_count(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(1, m_uibusiness_selladditem_maxcount)
        business_selladditem_updateui()
    end
end

function business_selladditem_delegate_pageprev()
    local count = business_selladditem_getinputcount()
    if count > 1 then
        business_selladditem_setinputcount(count - 1)
        business_selladditem_updateui()
    end
end

function business_selladditem_delegate_pagenext()
    local count = business_selladditem_getinputcount()
    if count < m_uibusiness_selladditem_maxcount then
        business_selladditem_setinputcount(count + 1)
        business_selladditem_updateui()
    end
end

function business_selladditem_delegate_ok()
    if m_uibusiness_selladditem_itemconfig == nil then
        return
    end
    
    local count = business_selladditem_getinputcount()
    if count <= 0 then
        messagealert_addalert("STALL_PUT_COUNTLIMIT")
        return
    end

    local price = business_selladditem_getinputprice()
    if price <= 0 then
        messagealert_addalert("STALL_PUT_PRICELIMIT")
        return
    end

    local shopprice = csvitem_getsellprice(m_uibusiness_selladditem_itemconfig)
    if price < shopprice then
        messagealert_addalert(c_textformat("BUSINESS_SELLADD_PRICELOW", shopprice))
        return
    end

    local msg = {messageid="CS_BusinessPut"}
    msg.npcactorid = m_uibusiness_main.npcactorid
    msg.uuid = m_uibusiness_selladditem_uuid
    msg.price = price
    msg.count = count
    c_send(msg)

    m_businesssellitem_subpanel:setvisible(false)
end

function business_selladditem_delegate_close()
    m_businesssellitem_subpanel:setvisible(false)
end
