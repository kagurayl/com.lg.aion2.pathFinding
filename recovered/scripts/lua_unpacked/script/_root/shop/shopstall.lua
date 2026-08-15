
local m_shopstall = uipanel_createhandle("shop/stall_buy", uilayer.normal, uiflag.escapeclose, AudioOpenUI, AudioCloseUI)
local m_shopstall_inst = {item = "shop/inst_stallbuy"}
local m_shopstall_totalspace = 10

local function stall_buy_setlinevisible(line, visible)
    line:setwidgetvisible("image_icon", visible)
    line:setwidgetvisible("text_count", visible)
    line:setwidgetvisible("text_name", visible)
    line:setwidgetvisible("text_price", visible)
    line:setwidgetvisible("image_coin", visible)
    line:setwidgetvisible("image_preview", visible)
    line:setwidgetvisible("button_buy", visible)
end

function stall_buy_onopen()
    m_shopstall:setwidgetdelegate("image_bg/button_close", stall_buy_delegate_close)
    local list_item = m_shopstall:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(stall_buy_delegate_listitem)
    for i=1,m_shopstall_totalspace do
        local line = list_item:add(m_shopstall_inst.item, i, i)

        local image_preview = line:getwidget("image_preview")
        image_preview:setdelegate(stall_buy_delegate_preview)

        local button_buy = line:getwidget("button_buy")
        button_buy:setdelegate(stall_buy_delegate_buy)
        stall_buy_setlinevisible(line, false)
    end
end

function stall_buy_openstall(msg)
    local actor = actormanager_getfromactorid(msg.playerid)
    if actor == nil then
        return
    end
    m_shopstall:open()
    if m_shopstall.queryplayerid ~= msg.playerid then
        m_shopstall.queryplayerid = msg.playerid
        m_shopstall.selectitemuuid = 0
    end

    local text_title = m_shopstall:getwidget("image_bg/text_title")
    text_title:settext(c_textformat("STALL_QUERY_TITLE", actor.attr.name))

    local list_item = m_shopstall:getwidget("list_item")
    for i=1,m_shopstall_totalspace do
        local line = list_item:getlinefromindex(i)
        stall_buy_setlinevisible(line, false)
    end
    for i=1,#msg.item do
        local stallitem = msg.item[i]
        local config_item = csvitem_getfromid(stallitem.attr.itemid)
        if config_item ~= nil then
            local line = list_item:getlinefromindex(stallitem.slot + 1)
            stall_buy_setlinevisible(line, true)
            line.stallitem = stallitem
            line.config_item = config_item

            local image_preview = line:getwidget("image_preview")
            local part = csvrender_getitemrender(config_item)
            image_preview:setvisible(part ~= nil)
            image_preview.config_item = config_item
            image_preview.dye = stallitem.attr.dye

            local button_buy = line:getwidget("button_buy")
            button_buy:setenable(m_shopstall.selectitemuuid == stallitem.attr.uuid)
            button_buy.stallitem = stallitem
            button_buy.config_item = config_item

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)

            local text_price = line:getwidget("text_price")
            text_price:settext(stallitem.price)

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_count = line:getwidget("text_count")
            text_count:settext(stallitem.attr.count)
        end
    end
end

function stall_buy_delegate_close()
    m_shopstall:close()
end

function stall_buy_delegate_preview(sender, event)
    if sender.config_item ~= nil and m_me ~= nil then
        m_me:setpreview(sender.config_item, sender.dye)
    end
end

function stall_buy_delegate_input(data, count)
    if count > 0 then
        local msg = {messageid="CS_StallBuy"}
        msg.playerid = m_shopstall.queryplayerid
        msg.uuid = m_shopstall.selectitemuuid
        msg.count = count
        c_send(msg)
    end
end
function stall_buy_delegate_oneconfirm(ok, data)
    if ok then
        local msg = {messageid="CS_StallBuy"}
        msg.playerid = m_shopstall.queryplayerid
        msg.uuid = m_shopstall.selectitemuuid
        msg.count = 1
        c_send(msg)
    end
end
function stall_buy_delegate_buy(sender, event)
    if sender.stallitem ~= nil then
        if m_shopstall.selectitemuuid == sender.stallitem.attr.uuid then
            tips_close()
            if sender.stallitem.attr.count > 1 then
                inputcount_show("SHOP_BUY_INPUT_TITLE", sender.config_item, sender.stallitem.attr.count, sender.stallitem.attr.count, stall_buy_delegate_input, nil)
                inputcount_addcurrency(currency_coin, sender.stallitem.price, playerattr_info.coin)
                inputcount_updateprice()
            else
                local message = c_textformat("SHOP_BUY_ONE", sender.config_item.name)
                messagebox_confirm(message, stall_buy_delegate_oneconfirm, nil, nil, nil, "")
            end
        end
    end
end

function stall_buy_delegate_listitem(line, event, data)
    local list_item = m_shopstall:getwidget("list_item")
    for i=1,m_shopstall_totalspace do
        local line2 = list_item:getlinefromindex(i)
        local button_buy = line2:getwidget("button_buy")
        button_buy:setenable(false)
    end
    tips_close()
    if line.stallitem ~= nil then
        m_shopstall.selectitemuuid = line.stallitem.attr.uuid
        local button_buy = line:getwidget("button_buy")
        button_buy:setenable(true)
        local image_bg = m_shopstall:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        tips_item(line.stallitem.attr.itemid, line.stallitem.attr.count, x + w, -1, tipsflag.vright, line.stallitem.attr, m_shopstall)
    end
end
