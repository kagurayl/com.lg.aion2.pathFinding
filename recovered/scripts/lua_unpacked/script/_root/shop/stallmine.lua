
local m_stallmine_inst = {item = "shop/inst_stallsell", log = "shop/inst_stalllog"}
local m_stallmine_totalspace = 10
local m_stallmine_selectindex = 1
local m_stallmine_log = nil

local function stall_mine_setlinevisible(line, visible)
    line:setwidgetvisible("image_icon", visible)
    line:setwidgetvisible("text_count", visible)
    line:setwidgetvisible("text_name", visible)
    line:setwidgetvisible("text_pricename", visible)
    line:setwidgetvisible("text_price", visible)
    line:setwidgetvisible("image_coin", visible)
    line:setwidgetvisible("button_take", visible)
end

function stall_mine_onopen()
    m_uistall_mine:setwidgetdelegate("button_ok", stall_mine_delegate_ok)
    m_uistall_mine:setwidgetdelegate("image_bg/button_close", stall_mine_delegate_close)

    local edit_advert = m_uistall_mine:getwidget("edit_advert")
    edit_advert:settext(c_textformat("STR_PERSONAL_SHOP_DEFAULT_ADVERTISE_MSG"))

    local list_item = m_uistall_mine:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(stall_mine_delegate_listitem)
    for i=1,m_stallmine_totalspace do
        local line = list_item:add(m_stallmine_inst.item, i, i)
        line.index = i

        local button_take = line:getwidget("button_take")
        button_take:setdelegate(stall_mine_delegate_take)
        button_take.index = i
    end

    local list_log = m_uistall_mine:getwidget("list_log")
    list_log:init(uilistflag.vertical)

    m_stallmine_log = {}

    stall_mine_updateui()
end

function stall_mine_updateui()
    local list_item = m_uistall_mine:getwidget("list_item")
    for i=1,m_stallmine_totalspace do
        local visible = false
        local item = nil
        local config_item = nil
        if i <= #playerattr_stall then
            item = playerattr_stall[i]
            visible = item.itemid ~= 0
            config_item = csvitem_getfromid(item.itemid)
        end
        local line = list_item:getlinefromindex(i)
        stall_mine_setlinevisible(line, visible)
        if visible and config_item ~= nil then
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_count = line:getwidget("text_count")
            text_count:settextraw(item.count)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)

            local text_price = line:getwidget("text_price")
            text_price:settext(item.price)
        end
    end
    local button_ok = m_uistall_mine:getwidget("button_ok")
    if playerattr_info.stalladvert ~= nil and #playerattr_info.stalladvert > 0 then
        button_ok:settext("STALL_STOP")
    else
        button_ok:settext("STALL_START")
    end
end

function stall_mine_addlog(text)
    if m_uistall_mine:null() then
        return
    end
    if m_stallmine_log ~= nil then
        m_stallmine_log[#m_stallmine_log + 1] = text
    end
    local list_log = m_uistall_mine:getwidget("list_log")
    list_log:savestate()
    list_log:clear()

    for i=#m_stallmine_log,1,-1 do
        local line = list_log:add(m_stallmine_inst.log)

        local text_log = line:getwidget("text_log")
        text_log:settext(m_stallmine_log[i])
    end

    list_log:restorestate()
end

function stall_mine_delegate_ok()
    if playerattr_info.stalladvert ~= nil and #playerattr_info.stalladvert > 0 then
        local msg = {messageid="CS_StallStop"}
        c_send(msg)
    else
        local edit_advert = m_uistall_mine:getwidget("edit_advert")
        local advert = edit_advert:gettext()
        local msg = {messageid="CS_StallStart"}
        msg.rot = playerattr_info.rot
        msg.advert = advert
        c_send(msg)
    end
end

function stall_mine_delegate_sellinput(item, count, price)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item ~= nil then
        local shopprice = csvitem_getsellprice(config_item)
        if price < shopprice then
            messagealert_addalert(c_textformat("STALL_PUT_PRICELOW", shopprice))
            return
        end
    end

    local msg = {messageid="CS_StallPut"}
    msg.uuid = item.uuid
    msg.count = count
    msg.stallslot = m_stallmine_selectindex - 1
    msg.price = price
    c_send(msg)
end
function stall_mine_delegate_filter(item)
    return playeritem_getitemdeal(item)
end
function stall_mine_delegate_listitem(line, event, uuid)
    m_stallmine_selectindex = line.index
    if line.index > #playerattr_stall then
        return
    end
    local item = playerattr_stall[line.index]
    if item.itemid ~= 0 then
        return
    end
    selectitem_show("STALL_PUT_TITLE", "STALL_PUT_TITLE", selectitemcount.price, selectitemflag.bag, stall_mine_delegate_filter, stall_mine_delegate_sellinput)
end

function stall_mine_delegate_take(sender, event)
    local index = sender.index
    if index <= #playerattr_stall then
        local item = playerattr_stall[index]
        if item.itemid ~= 0 then
            local msg = {messageid="CS_StallTake"}
            msg.uuid = item.uuid
            msg.bagslot = -1
            c_send(msg)
        end
    end
end

function stall_mine_delegate_close()
    m_uistall_mine:close()
end
