
local m_uisellinput = uipanel_createhandle("root/sellinput", uilayer.normal, uiflag.escapeclose)
local m_sellinput_itemuuid = 0
local m_sellinput_delegate = 0

function sellinput_setitem(title, item, delegate)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    m_uisellinput:open()
    local text_title = m_uisellinput:getwidget("image_bg/text_title")
    text_title:settext(title)

    local text_name = m_uisellinput:getwidget("text_name")
    text_name:settext(config_item.name)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local image_icon = m_uisellinput:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    m_sellinput_itemuuid = item.uuid
    m_sellinput_delegate = delegate
    m_uisellinput:setwidgetdelegate("button_decmin", sellinput_delegate_decmin)
    m_uisellinput:setwidgetdelegate("button_decone", sellinput_delegate_decone)
    m_uisellinput:setwidgetdelegate("button_incone", sellinput_delegate_incone)
    m_uisellinput:setwidgetdelegate("button_incmax", sellinput_delegate_incmax)
    m_uisellinput:setwidgetdelegate("button_ok", sellinput_delegate_ok)
    m_uisellinput:setwidgetdelegate("image_bg/button_close", sellinput_delegate_close)
    local edit_price = m_uisellinput:getwidget("edit_price")
    edit_price:setdelegate(sellinput_delegate_price)
    edit_price:settext("0")

    local edit_count = m_uisellinput:getwidget("edit_count")
    edit_count:setdelegate(sellinput_delegate_count)
    edit_count:settext(item.count)
end

function sellinput_delegate_price(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(0, nil)
    end
end

function sellinput_delegate_count(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        local maxcount = playeritem_getcountfromuuid(m_sellinput_itemuuid)
        sender:setverifyinteger(1, maxcount)
    end
end

local function sellinput_getinputcount()
    local edit_count = m_uisellinput:getwidget("edit_count")
    local count = string.tointeger(edit_count:gettext()) or 0
    return count
end

local function sellinput_setinputcount(count)
    local edit_count = m_uisellinput:getwidget("edit_count")
    edit_count:settext(count)
end

function sellinput_delegate_decmin()
    local count = sellinput_getinputcount()
    if count > 1 then
        sellinput_setinputcount(1)
    end
end

function sellinput_delegate_decone()
    local count = sellinput_getinputcount()
    if count > 1 then
        sellinput_setinputcount(count - 1)
    end
end

function sellinput_delegate_incone()
    local count = sellinput_getinputcount()
    local maxcount = playeritem_getcountfromuuid(m_sellinput_itemuuid)
    if count < maxcount then
        sellinput_setinputcount(count + 1)
    end
end

function sellinput_delegate_incmax()
    local count = sellinput_getinputcount()
    local maxcount = playeritem_getcountfromuuid(m_sellinput_itemuuid)
    if count < maxcount then
        sellinput_setinputcount(maxcount)
    end
end

function sellinput_delegate_ok()
    local edit_price = m_uisellinput:getwidget("edit_price")
    local price = string.tointeger(edit_price:gettext()) or 0
    if price <= 0 then
        chat_addsystemalert("STALL_PUT_PRICELIMIT")
        return
    end

    local count = sellinput_getinputcount()
    if count <= 0 then
        chat_addsystemalert("STALL_PUT_COUNTLIMIT")
        return
    end

    m_sellinput_delegate(m_sellinput_itemuuid, count, price)
    m_uisellinput:close()
end

function sellinput_delegate_close()
    m_uisellinput:close()
end
