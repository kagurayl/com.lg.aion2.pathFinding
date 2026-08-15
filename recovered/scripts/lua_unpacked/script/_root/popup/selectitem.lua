
selectitemcount =
{
    none = 0,
    count = 1,
    price = 2,
}

selectitemflag =
{
    bag = 0x1,
    equip1 = 0x2,
    equip2 = 0x4,
}

local m_uiselectitem = uipanel_createhandle("popup/selectitem", uilayer.top, uiflag.escapeclose)
local m_uiselectitem_inst = {inst = "popup/inst_selectitem"}

function selectitem_onopen()
    m_uiselectitem:setwidgetdelegate("image_bg/button_close", selectitem_delegate_close)
    local list_item = m_uiselectitem:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(selectitem_delegate_selectitem)
end

local function selectitem_additem(list_item, item)
    if m_uiselectitem.filterdelegate == nil or m_uiselectitem.filterdelegate(item) then
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            local line = list_item:add(m_uiselectitem_inst.inst, list_item:getcount(), item.uuid)
            line.config_item = config_item

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)

            local text_count = line:getwidget("text_count")
            text_count:settext(item.count)
        end
    end
end
function selectitem_show(title, counttitle, counttype, flag, filterdelegate, delegate, userdata)
    m_uiselectitem:open()
    m_uiselectitem.counttitle = counttitle
    m_uiselectitem.counttype = counttype
    m_uiselectitem.filterdelegate = filterdelegate
    m_uiselectitem.delegate = delegate
    m_uiselectitem.userdata = userdata
    local text_title = m_uiselectitem:getwidget("image_bg/text_title")
    text_title:settext(title)

    local list_item = m_uiselectitem:getwidget("list_item")
    list_item:clear()
    if bit.band(flag, selectitemflag.bag) ~= 0 then
        for i=1, #playerattr_bag do
            selectitem_additem(list_item, playerattr_bag[i])
        end
    end
    if bit.band(flag, selectitemflag.equip1) ~= 0 then
        for i=1, #playerattr_equip1 do
            selectitem_additem(list_item, playerattr_equip1[i])
        end
    end
    if bit.band(flag, selectitemflag.equip2) ~= 0 then
        for i=1, #playerattr_equip2 do
            selectitem_additem(list_item, playerattr_equip2[i])
        end
    end
end

function selectitem_delegate_count(count, uuid)
    local item = playeritem_getfromuuid(uuid)
    if item ~= nil then
        m_uiselectitem.delegate(item, string.tointeger(count) or 0)
    end
end

function selectitem_delegate_price(uuid, count, price)
    local item = playeritem_getfromuuid(uuid)
    if item ~= nil then
        m_uiselectitem.delegate(item, count, price)
    end
end

function selectitem_delegate_selectitem(line, event, uuid)
    local item = playeritem_getfromuuid(uuid)
    if item ~= nil then
        if m_uiselectitem.counttype == selectitemcount.none then
            m_uiselectitem.delegate(item, item.count, m_uiselectitem.userdata)
        elseif m_uiselectitem.counttype == selectitemcount.count then
            inputline_show(uiedittype.integer, m_uiselectitem.counttitle, item.count, selectitem_delegate_count, item.uuid)
        elseif m_uiselectitem.counttype == selectitemcount.price then
            sellinput_setitem(m_uiselectitem.counttitle, item, selectitem_delegate_price)
        end
    end
    m_uiselectitem:close()
end

function selectitem_delegate_close()
    m_uiselectitem:close()
end
