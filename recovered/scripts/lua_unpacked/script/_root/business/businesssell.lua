
local m_businesssell_maxitem = 15
local m_businesssell_inst = {item = "business/inst_itemsell"}
local m_businesssell_select = nil

function business_sell_onopen()
    m_uibusiness_main:setwidgetdelegate("tab_sell/button_take", business_sell_delegate_take)
    m_uibusiness_main:setwidgetdelegate("tab_sell/button_additem", business_sell_delegate_additem)
    m_uibusiness_main:setwidgetdelegate("tab_sell/button_addcoin", business_sell_delegate_addcoin)
    m_businesssell_select = nil

    local list_item = m_uibusiness_main:getwidget("tab_sell/list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(business_sell_delegate_select)
    business_sell_updateselect()
end

function business_sell_updateselect()
    m_uibusiness_main:setwidgetenable("tab_sell/button_take", m_businesssell_select ~= nil)
end

local function business_sell_setlinevisible(line, visible)
    line:setwidgetvisiblenothit("image_icon", visible)
    line:setwidgetvisiblenothit("text_count", visible)
    line:setwidgetvisiblenothit("text_name", visible)
    line:setwidgetvisiblenothit("text_level", visible)
    line:setwidgetvisiblenothit("text_price", visible)
    line:setwidgetvisiblenothit("text_date", visible)
    line:setwidgetvisiblenothit("image_coin", visible)
    line:setwidgetvisiblenothit("text_pricetotal", visible)
    line:setwidgetvisiblenothit("image_cointotal", visible)
    line:setwidgetvisiblenothit("image_preview", visible)
end
function business_sell_updateui()
    if m_uibusiness_main:null() or m_business_state ~= BusinessTab.sell then
        return
    end
    local text_sell_subtitle = m_uibusiness_main:getwidget("tab_sell/text_sell_subtitle")
    text_sell_subtitle:settext("BUSINESS_SELL_SUBTITLE", #playerattr_business, m_businesssell_maxitem)

    local list_item = m_uibusiness_main:getwidget("tab_sell/list_item")
    local prevselectavailable = false
    for i=1,#playerattr_business do
        if m_businesssell_select ~= nil and m_businesssell_select == playerattr_business[i].attr.uuid then
            prevselectavailable = true
        end
    end
    if not prevselectavailable then
        m_businesssell_select = nil
        business_sell_updateselect()
    end
    local totalcoin = 0
    local totalcash = 0
    list_item:savestate()
    list_item:clear()
    for i=1,#playerattr_business do
        local item = playerattr_business[i]
        local config_item = csvitem_getfromid(item.attr.itemid)
        local line = list_item:add(m_businesssell_inst.item, item.attr.uuid, item)
        business_sell_setlinevisible(line, true)
        local image_icon = line:getwidget("image_icon")
        local text_name = line:getwidget("text_name")
        local text_level = line:getwidget("text_level")
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
        else
            image_icon:setvisible(false)
            text_name:settext("")
            text_level:settext("")
        end

        local text_date = line:getwidget("text_date")
        text_date:settext(timerdesc_early(item.date))

        local text_count = line:getwidget("text_count")
        local text_price = line:getwidget("text_price")
        local text_pricetotal = line:getwidget("text_pricetotal")
        local image_coin = line:getwidget("image_coin")
        local image_cointotal = line:getwidget("image_cointotal")
        if item.attr.itemid == itemid_coin then
            totalcash = totalcash + item.price
            text_count:settext("")
            text_price:settext(string.format("%d", item.price))
            text_pricetotal:settext(string.format("%d", item.price))
            image_coin:setsprite("sp1/ccycash")
            image_cointotal:setsprite("sp1/ccycash")
        else
            totalcoin = totalcoin + item.price * item.attr.count
            text_count:settext(item.attr.count)
            text_price:settext(string.format("%d", item.price))
            text_pricetotal:settext(string.format("%d", item.price * item.attr.count))
            image_coin:setsprite("sp1/ccycoin")
            image_cointotal:setsprite("sp1/ccycoin")
        end
    end
    for i=#playerattr_business + 1,m_businesssell_maxitem do
        local line = list_item:add(m_businesssell_inst.item)
        business_sell_setlinevisible(line, false)
    end
    list_item:restorestate()

    local text_precash = m_uibusiness_main:getwidget("tab_sell/text_precash")
    text_precash:settext(string.format("%d", totalcash))

    local text_precoin = m_uibusiness_main:getwidget("tab_sell/text_precoin")
    text_precoin:settext(string.format("%d", totalcoin))
end

function business_sell_delegate_select(line, event, data)
    if m_businesssell_select == nil or m_businesssell_select ~= data.attr.uuid then
        m_businesssell_select = data.attr.uuid
        tips_close()
        business_sell_updateselect()
    else
        local image_bg1 = line:getwidget("image_bg1")
        local x,y,w,h = image_bg1:getabsolute()
        for i=1,#playerattr_business do
            local item = playerattr_business[i]
            if item.attr.uuid == data.attr.uuid then
                tips_item(item.attr.itemid, item.attr.count, x + w, y + h, tipsflag.vright, item.attr, m_uibusiness_main)
                break
            end
        end
    end
end

function business_sell_delegate_take()
    local list_item = m_uibusiness_main:getwidget("tab_sell/list_item")
    local data = list_item:getfirstselect()
    if data ~= nil then
        local msg = {messageid="CS_BusinessTake"}
        msg.npcactorid = m_uibusiness_main.npcactorid
        msg.uuid = data.attr.uuid
        c_send(msg)
    end
end

function business_sell_delegate_additem()
    if #playerattr_business < 15 then
        business_selladditem_open()
    else
        messagealert_addalert("STR_VENDOR_REGISTER_FULL_BASKET")
    end
end

function business_sell_delegate_addcoin()
    if #playerattr_business < 15 then
        business_selladdcoin_open()
    else
        messagealert_addalert("STR_VENDOR_REGISTER_FULL_BASKET")
    end
end
