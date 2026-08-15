
local m_tabunbind_inst = {equip = "equiplab/inst_equip"}

function tabunbind_onopen()
    local button_ok = m_equiplabmain:getwidget("tab_unbind/button_ok")
    button_ok:setdelegate(tabunbind_delegate_ok)
    button_ok:setenablenofade(false)
end

function tabunbind_addequip(list_equip, equip, config_item, itemname)
    local unbindenable = equip_isbindontrade(equip)

    local line = list_equip:add(m_tabunbind_inst.equip, equip.uuid, math.ternary(unbindenable, equip.uuid, 0))
    line:setselectable(unbindenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(unbindenable)
    if unbindenable then
        text_desc:settextscale("LAB_UNBIND_ENABLE")
    else
        text_desc:settextscale("LAB_UNBIND_DISABLE")
    end
end

function tabunbind_updateui()
    local count = 0
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and csvitem_getscript(config_item, "unbind") ~= nil then
                count = count + item.count
            end
        end
    end
    local text_count = m_equiplabmain:getwidget("tab_unbind/text_count")
    text_count:settext("LAB_UNBIND_COUNT", count)
    text_count:setavailablecolor(count > 0)
    
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local button_ok = m_equiplabmain:getwidget("tab_unbind/button_ok")
    button_ok:setdelegate(tabunbind_delegate_ok)
    button_ok:setenablenofade(count > 0 and equip_isbindontrade(equip))
end

function tabunbind_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipUnBind"}
        msg.itemuuid = data.itemuuid
        msg.equipuuid = data.equipuuid
        c_send(msg)
    end
end

function tabunbind_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil or not equip_isbindontrade(equip) then
        return
    end
    local itemuuid = 0
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and csvitem_getscript(config_item, "unbind") ~= nil then
                itemuuid = item.uuid
                break
            end
        end
    end
    if itemuuid == 0 then
        return
    end
    local message = c_textformat("LAB_UNBIND_TIPS_CONFIRM", config_equip.name)
    local data = {}
    data.itemuuid = itemuuid
    data.equipuuid = m_equiplabmain.equipuuid
    messagebox_confirm(message, tabunbind_confirm, data)
end
