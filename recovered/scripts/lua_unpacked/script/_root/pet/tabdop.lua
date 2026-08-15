
local function tabdop_setinst(instname, index, itemtype, itemenable)
    local image_click = m_uipet_menu:getwidget(instname .. "/image_click")
    if itemenable then
        image_click:setdelegate(tabdop_delegate_inst)
    else
        image_click:setdelegate(nil)
    end
    image_click.instindex = index
    image_click.itemtype = itemtype
    
    local button_remove = m_uipet_menu:getwidget(instname .. "/button_remove")
    button_remove:setdelegate(tabdop_delegate_remove)
    button_remove.instindex = index

    local image_icon = m_uipet_menu:getwidget(instname .. "/image_icon")
    local text_desc = m_uipet_menu:getwidget(instname .. "/text_desc")
    local image_iconfx = m_uipet_menu:getwidget(instname .. "/image_iconfx")
    if m_uipet_menu.pet.dopitem[index] > 0 then
        image_icon:setvisible(true)
        button_remove:setvisible(true)
        image_iconfx:setvisiblenothit(m_uipet_menu.pet.dopactive[index] > 0)
        local config_item = csvitem_getfromid(m_uipet_menu.pet.dopitem[index])
        if config_item ~= nil then
            image_icon:seticon(config_item.icon)
            text_desc:settext(config_item.name)
            text_desc:setcolor(csvitem_getfloatcolor(config_item))
        end
    else
        text_desc:settext("PETMENU_DOP_EMPTY")
        image_icon:setvisible(false)
        button_remove:setvisible(false)
        image_iconfx:setvisiblenothit(false)
    end

    local text_name = m_uipet_menu:getwidget(instname .. "/text_name")
    text_name:setavailablecolor(itemenable)

    text_desc:setavailablecolor(itemenable)
end

function tabdop_updateui(uud)
    if m_uipet_menu:null() then
        return
    end
    local foodenable = false
    local drinkenable = false
    local scrollcount = 0
    local lambda1 = m_uipet_menu.config_pet.skill1
    local lambda2 = m_uipet_menu.config_pet.skill2
    local lambda = nil
    if lambda1 ~= nil and c_isaction(lambda1[1], "dop") then
        lambda = lambda1
    elseif lambda2 ~= nil and c_isaction(lambda2[1], "dop") then
        lambda = lambda2
    end
    if lambda ~= nil then
        foodenable = lambda[1].variable[1].integer > 0
        drinkenable = lambda[1].variable[2].integer > 0
        scrollcount = lambda[1].variable[3].integer
    end

    tabdop_setinst("tab_dop/inst_petfood", 1, csvitemtype.consume_food, foodenable)
    tabdop_setinst("tab_dop/inst_petdrink", 2, csvitemtype.consume_drink, drinkenable)
    tabdop_setinst("tab_dop/inst_petscroll1", 3, csvitemtype.consume_scroll, scrollcount > 0)
    tabdop_setinst("tab_dop/inst_petscroll2", 4, csvitemtype.consume_scroll, scrollcount > 1)
end

function tabdop_delegate_selectdopcomplete(item, count, data)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local msg = {messageid="CS_PetDop"}
    msg.uuid = data.uuid
    msg.index = data.index - 1
    msg.itemid = item.itemid
    msg.active = 1
    c_send(msg)
end
function tabdop_delegate_filterfood(item)
    local config_item = csvitem_getfromid(item.itemid)
    return config_item ~= nil and config_item.itemtype == csvitemtype.consume_food
end
function tabdop_delegate_filterdrink(item)
    local config_item = csvitem_getfromid(item.itemid)
    return config_item ~= nil and config_item.itemtype == csvitemtype.consume_drink
end
function tabdop_delegate_filterscroll(item)
    local config_item = csvitem_getfromid(item.itemid)
    return config_item ~= nil and config_item.itemtype == csvitemtype.consume_scroll
end
function tabdop_delegate_inst(sender, event)
    local index = sender.instindex
    if m_uipet_menu.pet.dopitem[index] == 0 then
        local filter = nil
        if sender.itemtype == csvitemtype.consume_food then
            filter = tabdop_delegate_filterfood
        elseif sender.itemtype == csvitemtype.consume_drink then
            filter = tabdop_delegate_filterdrink
        elseif sender.itemtype == csvitemtype.consume_scroll then
            filter = tabdop_delegate_filterscroll
        end
        local data = {}
        data.index = index
        data.uuid = m_uipet_menu.pet.uuid
        selectitem_show("PETMENU_DOP_SELECTTITLE", nil, selectitemcount.none, selectitemflag.bag, filter, tabdop_delegate_selectdopcomplete, data)
    else
        local msg = {messageid="CS_PetDopActive"}
        msg.uuid = m_uipet_menu.pet.uuid
        msg.index = index - 1
        if m_uipet_menu.pet.dopactive[index] > 0 then
            msg.active = 0
        else
            msg.active = 1
        end
        c_send(msg)
    end
end

function tabdop_delegate_remove(sender, event)
    local msg = {messageid="CS_PetDop"}
    msg.uuid = m_uipet_menu.pet.uuid
    msg.index = sender.instindex - 1
    msg.itemid = 0
    msg.active = 0
    c_send(msg)
end
