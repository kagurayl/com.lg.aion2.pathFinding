
local m_businesssettle_inst = {item = "business/inst_itemsettle"}
local m_businesssettle_placecount = 8
local m_businesssettle_select = nil

function business_settle_onopen()
    m_uibusiness_main:setwidgetdelegate("tab_settle/button_settle", business_settle_delegate_settle)
    local list_item = m_uibusiness_main:getwidget("tab_settle/list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(business_settle_delegate_select)
    m_businesssettle_select = nil
end

local function business_settle_setlinevisible(line, visible)
    line:setwidgetvisiblenothit("image_icon", visible)
    line:setwidgetvisiblenothit("text_count", visible)
    line:setwidgetvisiblenothit("text_name", visible)
    line:setwidgetvisiblenothit("text_level", visible)
    line:setwidgetvisiblenothit("text_price", visible)
    line:setwidgetvisiblenothit("image_coin", visible)
    line:setwidgetvisiblenothit("text_date", visible)
    line:setwidgetvisiblenothit("text_settle", visible)
    line:setwidgetvisiblenothit("image_coinsettle", visible)
end
function business_settle_updateui()
    if m_uibusiness_main:null() or m_business_state ~= BusinessTab.settle then
        return
    end
    m_uibusiness_main:setwidgetvisible("tab_settle/text_none", #playerattr_businessbill.item == 0)

    local list_item = m_uibusiness_main:getwidget("tab_settle/list_item")
    list_item:savestate()
    list_item:clear()
    for i=1,#playerattr_businessbill.item do
        local item = playerattr_businessbill.item[i]
        local line = list_item:add(m_businesssettle_inst.item, i, item)
        business_settle_setlinevisible(line, true)
        local image_icon = line:getwidget("image_icon")
        local text_name = line:getwidget("text_name")
        local text_level = line:getwidget("text_level")
        local config_item = csvitem_getfromid(item.attr.itemid)
        if config_item ~= nil then
            image_icon:setvisible(true)
            image_icon:seticon(config_item.icon)
            if item.attr.itemid == itemid_coin then
                text_name:settext(string.format("%s(%d)", config_item.name, item.attr.count))
            else
                text_name:settext(config_item.name)
            end
            text_name:setcolor(csvitem_getfloatcolor(config_item))
            text_level:settext(config_item.itemlevel)
        else
            image_icon:setvisible(false)
            text_name:settext("")
            text_level:settext("")
        end

        local text_date = line:getwidget("text_date")
        if item.date ~= 0 then
            text_date:settext(timer_serverdate(item.date))
        else
            text_date:settext("BUSINESS_SETTLE_TIMEOUT")
        end

        local text_count = line:getwidget("text_count")
        local text_price = line:getwidget("text_price")
        local text_settle = line:getwidget("text_settle")
        local image_coin = line:getwidget("image_coin")
        local image_coinsettle = line:getwidget("image_coinsettle")
        if item.attr.itemid == itemid_coin then
            text_count:settext("")
            text_price:settext(item.price)
            if item.date ~= 0 then
                text_settle:settext(item.price)
            else
                text_settle:settext(0)
            end
            image_coin:setsprite("sp1/ccycash")
            image_coinsettle:setsprite("sp1/ccycash")
        else
            text_count:settext(item.attr.count)
            text_price:settext(item.price * item.attr.count)
            if item.date ~= 0 then
                text_settle:settext(item.price * item.attr.count)
            else
                text_settle:settext(0)
            end
            image_coin:setsprite("sp1/ccycoin")
            image_coinsettle:setsprite("sp1/ccycoin")
        end
    end
    for i=#playerattr_businessbill.item + 1,m_businesssettle_placecount do
        local line = list_item:add(m_businesssettle_inst.item)
        business_settle_setlinevisible(line, false)
    end
    list_item:restorestate()

    local text_totalcash = m_uibusiness_main:getwidget("tab_settle/text_totalcash")
    text_totalcash:settext(playerattr_businessbill.billcash)

    local text_totalcoin = m_uibusiness_main:getwidget("tab_settle/text_totalcoin")
    text_totalcoin:settext(playerattr_businessbill.billcoin)
end

function business_settle_delegate_select(line, event, data)
    if m_businesssettle_select == nil or m_businesssettle_select ~= data.attr.uuid then
        m_businesssettle_select = data.attr.uuid
        tips_close()
    else
        local image_bg1 = line:getwidget("image_bg1")
        local x,y,w,h = image_bg1:getabsolute()
        for i=1,#playerattr_businessbill.item do
            local item = playerattr_businessbill.item[i]
            if item.attr.uuid == data.attr.uuid then
                tips_item(item.attr.itemid, item.attr.count, x + w, y + h, tipsflag.vright, item.attr, m_uibusiness_main)
                break
            end
        end
    end
end

function business_settle_delegate_settle()
    local msg = {messageid="CS_BusinessSettle"}
    msg.npcactorid = m_uibusiness_main.npcactorid
    c_send(msg)
end
