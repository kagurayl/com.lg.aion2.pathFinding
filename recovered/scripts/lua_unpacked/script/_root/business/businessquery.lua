
local businessquery_querystate =
{
    notselect = 1,
    query = 2,
    empty = 3,
    display = 4,
}

local businessquery_querytype =
{
    catalog = 1,
    itemid = 2,
}

local m_businessquery_countperpage = 8
local m_businessquery_inst = {item = "business/inst_itemquery"}
local m_businessquery_itemlist = nil
local m_businessquery_select = nil
local m_businessquery_itemmaxpage = 1
local m_businessquery_querystate = businessquery_querystate.notselect
local m_businessquery_querypage = 0
local m_businessquery_querytype = businessquery_querytype.catalog
local m_businessquery_queryid = nil

function business_query_onopen()
    m_uibusiness_main:setwidgetdelegate("tab_query/button_filter", business_query_delegate_filter)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_refresh", business_query_delegate_refresh)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_buy", business_query_delegate_buy)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_pagefirst", business_query_delegate_pagefirst)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_pageprev", business_query_delegate_pageprev)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_pagenext", business_query_delegate_pagenext)
    m_uibusiness_main:setwidgetdelegate("tab_query/button_pagelast", business_query_delegate_pagelast)
    m_uibusiness_main:setwidgetdelegate("tab_query/edit_page", business_query_delegate_editpage)
    local list_item = m_uibusiness_main:getwidget("tab_query/list_item")
    list_item:init(bit.bor(uilistflag.vertical, uilistflag.scrolldisable))
    list_item:setclickdelegate(business_query_delegate_selectitem)

    business_query_addcatalog()

    m_businessquery_itemlist = nil
    m_businessquery_select = nil
    m_businessquery_querystate = businessquery_querystate.notselect
    m_businessquery_querypage = 0
    m_businessquery_querytype = businessquery_querytype.catalog
    m_businessquery_queryid = nil
    business_query_updateselect()
end

local function business_query_adjustpage()
    local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
    local page = string.tointeger(edit_page:gettext()) or 0
    page = math.clamp(page, 1, m_businessquery_itemmaxpage)
    edit_page:settext(page)
    return page
end

function business_query_sendquery()
    if m_businessquery_queryid ~= nil then
        m_businessquery_querypage = business_query_adjustpage() - 1
        local msg = {messageid="CS_BusinessQuery"}
        msg.npcactorid = m_uibusiness_main.npcactorid
        msg.page = m_businessquery_querypage
        msg.querytype = m_businessquery_querytype
        msg.queryid = m_businessquery_queryid
        c_send(msg)
    end
end

function business_query_setquerycatalog(typeidarray)
    m_businessquery_querystate = businessquery_querystate.query
    m_businessquery_querytype = businessquery_querytype.catalog
    m_businessquery_queryid = typeidarray
    business_query_sendquery()
    business_query_clearitemlist()
end

function business_query_setqueryitem(itemidarray)
    m_businessquery_querystate = businessquery_querystate.query
    m_businessquery_querytype = businessquery_querytype.itemid
    m_businessquery_queryid = itemidarray
    business_query_sendquery()
    business_query_clearitemlist()
end

function business_query_setqueryempty()
    m_businessquery_querystate = businessquery_querystate.empty
    business_query_clearitemlist()
end

function business_query_setquerynotselect()
    m_businessquery_querystate = businessquery_querystate.notselect
    m_businessquery_queryid = nil
    business_query_clearitemlist()
end

function business_query_clearitemlist()
    m_businessquery_itemlist = nil
    m_businessquery_itemmaxpage = 1
    business_query_updateui()
end

function business_query_setitem(msg)
    if msg.page ~= m_businessquery_querypage or msg.querytype ~= m_businessquery_querytype then
        return
    end
    if m_businessquery_queryid ~= nil and msg.queryid ~= nil then
        if #m_businessquery_queryid ~= #msg.queryid then
            return
        end
        for i=1,#m_businessquery_queryid do
            if m_businessquery_queryid[i] ~= msg.queryid[i] then
                return
            end
        end
    end

    if msg.count == 0 then
        m_businessquery_itemmaxpage = 1
        m_businessquery_querystate = businessquery_querystate.empty
    else
        m_businessquery_itemmaxpage = math.tointegerfloor((msg.count - 1) / m_businessquery_countperpage) + 1
        m_businessquery_querystate = businessquery_querystate.display
    end
    m_businessquery_itemlist = msg.item
    business_query_updateui()
end

function business_query_delegate_refresh()
    m_businessquery_querystate = businessquery_querystate.query
    business_query_sendquery()
    business_query_clearitemlist()
end

function business_query_buysuccess(msg)
    if m_businessquery_itemlist ~= nil then
        for i=1,#m_businessquery_itemlist do
            local item = m_businessquery_itemlist[i]
            if item.playerid == msg.playerid and item.attr.uuid == msg.uuid then
                if item.attr.count <= msg.count then
                    table.remove(m_businessquery_itemlist, i)
                else
                    item.attr.count = item.attr.count - msg.count
                end
                business_query_updateui()
                break
            end
        end
    end
end

function business_query_updateselect()
    m_uibusiness_main:setwidgetenable("tab_query/button_buy", m_businessquery_select ~= nil)
end

function business_query_updatepreviewimage()
    local list_item = m_uibusiness_main:getwidget("tab_query/list_item")
    for i=1,list_item:getcount() do
        local line = list_item:getlinefromindex(i)
        if line.image_preview ~= nil then
            local data = line:getdata()
            line.image_preview:setvisible(m_businessquery_select ~= nil and m_businessquery_select.uuid == data.uuid)
        end
    end
end

local function business_query_setlinevisible(line, visible)
    line:setwidgetvisiblenothit("image_icon", visible)
    line:setwidgetvisiblenothit("text_count", visible)
    line:setwidgetvisiblenothit("text_name", visible)
    line:setwidgetvisiblenothit("text_level", visible)
    line:setwidgetvisiblenothit("text_price", visible)
    line:setwidgetvisiblenothit("image_coin", visible)
    line:setwidgetvisiblenothit("text_pricetotal", visible)
    line:setwidgetvisiblenothit("image_cointotal", visible)
    line:setwidgetvisiblenothit("image_preview", visible)
end
function business_query_updateui()
    if m_uibusiness_main:null() or m_business_state ~= BusinessTab.query then
        return
    end
    local text_none = m_uibusiness_main:getwidget("tab_query/text_none")
    if m_businessquery_querystate == businessquery_querystate.notselect then
        text_none:setvisiblenothit(true)
        text_none:settext("BUSINESS_QUERY_BLANK")
    elseif m_businessquery_querystate == businessquery_querystate.empty then
        text_none:setvisiblenothit(true)
        text_none:settext("BUSINESS_QUERY_EMPTY")
    else
        text_none:setvisiblenothit(false)
    end

    local text_pagemax = m_uibusiness_main:getwidget("tab_query/text_pagemax")
    text_pagemax:settext("/" .. m_businessquery_itemmaxpage)
    business_query_adjustpage()

    local prevselectavailable = false
    if m_businessquery_select ~= nil and m_businessquery_itemlist ~= nil then
        for i=1,#m_businessquery_itemlist do
            local item = m_businessquery_itemlist[i]
            if m_businessquery_select.playerid == item.playerid and m_businessquery_select.uuid == item.attr.uuid then
                prevselectavailable = true
            end
        end
    end
    if not prevselectavailable then
        m_businessquery_select = nil
        business_query_updateselect()
    end

    local list_item = m_uibusiness_main:getwidget("tab_query/list_item")
    if m_businessquery_querystate == businessquery_querystate.notselect
    or m_businessquery_querystate == businessquery_querystate.query
    or m_businessquery_querystate == businessquery_querystate.empty then
        list_item:clear()
        return
    end
    list_item:savestate()
    list_item:clear()
    local itemcount = 0
    if m_businessquery_itemlist ~= nil then
        itemcount = #m_businessquery_itemlist
    end
    for i=1,itemcount do
        local item = m_businessquery_itemlist[i]
        local line = list_item:add(m_businessquery_inst.item, i, {playerid = item.playerid, uuid = item.attr.uuid})
        business_query_setlinevisible(line, true)
        local image_icon = line:getwidget("image_icon")
        local text_name = line:getwidget("text_name")
        local text_level = line:getwidget("text_level")
        local image_preview = line:getwidget("image_preview")
        local config_item = csvitem_getfromid(item.attr.itemid)
        line.image_preview = nil
        if config_item ~= nil then
            image_icon:setvisible(true)
            image_icon:seticon(config_item.icon)
            text_level:settext(config_item.itemlevel)
            if item.attr.itemid == itemid_coin then
                text_name:settext(string.format("%s(%d)", config_item.name, item.attr.count))
            else
                text_name:settext(config_item.name)
            end
            text_name:setcolor(csvitem_getfloatcolor(config_item))

            local part = csvrender_getitemrender(config_item)
            if part ~= nil then
                line.image_preview = image_preview
                image_preview:setvisible(true)
                image_preview:setdelegate(business_query_delegate_preview)
                image_preview.config_item = config_item
                image_preview.dye = item.attr.dye
            else
                image_preview:setvisible(false)
            end
        else
            image_icon:setvisible(false)
            text_name:settext("")
            text_level:settext("")
            image_preview:setvisible(false)
        end
        
        local text_count = line:getwidget("text_count")
        local text_price = line:getwidget("text_price")
        local image_coin = line:getwidget("image_coin")
        local text_pricetotal = line:getwidget("text_pricetotal")
        local image_cointotal = line:getwidget("image_cointotal")
        if item.attr.itemid == itemid_coin then
            text_count:settext("")
            text_price:settext(string.format("%d", item.price))
            text_pricetotal:settext(string.format("%d", item.price))
            image_coin:setsprite("sp1/ccycash")
            image_cointotal:setsprite("sp1/ccycash")
        else
            text_count:settext(item.attr.count)
            text_price:settext(string.format("%d", item.price))
            text_pricetotal:settext(string.format("%d", item.price * item.attr.count))
            image_coin:setsprite("sp1/ccycoin")
            image_cointotal:setsprite("sp1/ccycoin")
        end
    end
    for i=itemcount + 1,m_businessquery_countperpage do
        local line = list_item:add(m_businessquery_inst.item)
        business_query_setlinevisible(line, false)
    end
    list_item:restorestate()
    business_query_updatepreviewimage()
end

function business_query_delegate_selectitem(line, event, data)
    if m_businessquery_select == nil or m_businessquery_select.uuid ~= data.uuid then
        m_businessquery_select = data
        tips_close()
        business_query_updateselect()
        business_query_updatepreviewimage()
    else
        local image_bg1 = line:getwidget("image_bg1")
        if image_bg1 ~= nil then
            local x,y,w,h = image_bg1:getabsolute()
            for i=1,#m_businessquery_itemlist do
                local item = m_businessquery_itemlist[i]
                if item.attr.uuid == data.uuid then
                    tips_item(item.attr.itemid, item.attr.count, x + w, y + h, tipsflag.vright, item.attr, m_uibusiness_main)
                    break
                end
            end
        end
    end
end

function business_query_delegate_preview(sender, event)
    if m_me ~= nil and m_me:setpreview(sender.config_item, sender.dye) then
        m_uibusiness_main:close()
    end
end

function business_query_delegate_editpage(sender, event)
    if event.name == "submit" then
        business_query_sendquery()
    elseif event.name == "textchanged" then
        local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
        local text = edit_page:gettext()
        if text ~= nil and #text > 0 then
            business_query_adjustpage()
        end
    end
end

function business_query_delegate_filter()
    business_filter_open()
end

function business_query_delegate_pagefirst()
    local page = business_query_adjustpage()
    if page > 1 then
        local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
        edit_page:settext(1)
        business_query_sendquery()
    end
end

function business_query_delegate_pageprev()
    local page = business_query_adjustpage()
    if page > 1 then
        local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
        edit_page:settext(page - 1)
        business_query_sendquery()
    end
end

function business_query_delegate_pagenext()
    local page = business_query_adjustpage()
    if page < m_businessquery_itemmaxpage then
        local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
        edit_page:settext(page + 1)
        business_query_sendquery()
    end
end

function business_query_delegate_pagelast()
    local page = business_query_adjustpage()
    if page < m_businessquery_itemmaxpage then
        local edit_page = m_uibusiness_main:getwidget("tab_query/edit_page")
        edit_page:settext(m_businessquery_itemmaxpage)
        business_query_sendquery()
    end
end

local function functionbusyness_query_getselectitem(select)
    if select == nil then
        return
    end
    for i=1,#m_businessquery_itemlist do
        local item = m_businessquery_itemlist[i]
        if select.playerid == item.playerid and select.uuid == item.attr.uuid then
            return item
        end
    end
end
function business_query_delegate_buyinput(data, count)
    if count > 0 then
        local item = functionbusyness_query_getselectitem(data)
        if item ~= nil then
            local msg = {messageid="CS_BusinessBuy"}
            msg.npcactorid = m_uibusiness_main.npcactorid
            msg.playerid = item.playerid
            msg.uuid = item.attr.uuid
            msg.count = count
            c_send(msg)
        end
    end
end
function business_query_delegate_oneconfirm(ok, data)
    if ok then
        local item = functionbusyness_query_getselectitem(data)
        if item ~= nil then
            local msg = {messageid="CS_BusinessBuy"}
            msg.npcactorid = m_uibusiness_main.npcactorid
            msg.playerid = item.playerid
            msg.uuid = item.attr.uuid
            msg.count = 1
            c_send(msg)
        end
    end
end
function business_query_delegate_buy()
    local item = functionbusyness_query_getselectitem(m_businessquery_select)
    if item ~= nil then
        local config_item = csvitem_getfromid(item.attr.itemid)
        if config_item ~= nil then
            if item.attr.count > 1 then
                if config_item.id == itemid_coin then
                    inputcount_show("SHOP_BUY_INPUT_TITLE", config_item, 1, 1, business_query_delegate_buyinput, m_businessquery_select)
                    inputcount_addcurrency(currency_cash, item.price, playerattr_info.cash)
                else
                    inputcount_show("SHOP_BUY_INPUT_TITLE", config_item, item.attr.count, item.attr.count, business_query_delegate_buyinput, m_businessquery_select)
                    inputcount_addcurrency(currency_coin, item.price, playerattr_info.coin)                
                end
                inputcount_updateprice()
            else
                local message = c_textformat("SHOP_BUY_ONE", config_item.name)
                messagebox_confirm(message, business_query_delegate_oneconfirm, m_businessquery_select, nil, nil, "")
            end
        end
    end
end
