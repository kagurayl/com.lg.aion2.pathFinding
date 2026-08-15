
function playerequip_onopen()
	local list_attr = m_uioverview_playermain:getwidget("tab_equip/list_attr")
    list_attr:init(uilistflag.vertical)
end

function playerequip_updateui()
    local equipactive, equipsecondard = playeritem_getactiveequip()
    local attrequip = {}
    for key, val in pairs(equipslot) do
        local equip = equipactive[val]
        local equip2 = equipsecondard[val]
        local icon_root = m_uioverview_playermain:getwidget("tab_equip/equipactive/icon_" .. key)
        icon_root:setdelegate(playerequip_delegate_equipicon)
        icon_root.equipslot = val

        local icon_equip = m_uioverview_playermain:getwidget("tab_equip/equipactive/icon_" .. key .. "/image_icon")
        local text_count = m_uioverview_playermain:getwidget("tab_equip/equipactive/icon_" .. key .. "/text_count")
        local image_anim = m_uioverview_playermain:getwidget("tab_equip/equipactive/icon_" .. key .. "/image_anim")
        if equip.itemid ~= 0 then
            icon_equip:setopacity(1.0)
            local config_item = csvitem_getfromid(equip.itemid)
            if config_item ~= nil then
                icon_equip:seticon(config_item.icon)
            end
            if val == equipslot.battery1 or val == equipslot.battery2 then
                text_count:setvisiblenothit(true)
                text_count:setopacity(1.0)
                text_count:settext(equip.count)
                image_anim:setvisiblenothit(playerattr_info.battery > 0)
            else
                text_count:setvisible(false)
                image_anim:setvisible(false)
            end
            attrequip[val] = equip
        elseif equip2.itemid ~= 0 and playeritem_equipsparetire(val) then
            if val == equipslot.battery1 or val == equipslot.battery2 then
                icon_equip:setopacity(0)
            else
                icon_equip:setopacity(0.3)
                local config_item = csvitem_getfromid(equip2.itemid)
                if config_item ~= nil then
                    icon_equip:seticon(config_item.icon)
                end
            end
            text_count:setvisible(false)
            image_anim:setvisible(false)
            attrequip[val] = equip2
        else
            icon_equip:setopacity(0)
            text_count:setvisible(false)
            image_anim:setvisible(false)
        end

        local icon_equip2 = m_uioverview_playermain:getwidget("tab_equip/equipsecondary/icon_" .. key .. "/image_icon")
        icon_equip2:setvisible(equip2.itemid ~= 0)
        if equip2.itemid ~= 0 then
            local config_item = csvitem_getfromid(equip2.itemid)
            if config_item ~= nil then
                icon_equip2:seticon(config_item.icon)
            end
        end
	end

    local list_attr = m_uioverview_playermain:getwidget("tab_equip/list_attr")
    playerattrview_setattr(list_attr, playerattr_info, attrequip)
end

function playerequip_itemmenu_delegate_equip(data)
    local msg = {messageid="CS_EquipOff"}
    msg.equipuuid = data.uuid
    msg.bagslot = -1
    c_send(msg)
end

function playerequip_itemmenu_delegate_soul(data)
    equiplab_show(data.uuid, equiplab_tabtype.soul, 0)
end

function playerequip_itemmenu_delegate_gem(data)
    equiplab_show(data.uuid, equiplab_tabtype.gem, 0)
end

function playerequip_itemmenu_delegate_dye(data)
    equiplab_show(data.uuid, equiplab_tabtype.dye, 0)
end

function playerequip_itemmenu_delegate_sendchat(data)
    chat_openinput()
    chatinput_addtext(richtext_makeequip(data.uuid))
end

function playerequip_delegate_equipicon(sender, event)
    local activeequip = playeritem_getactiveequip()
    local item = activeequip[sender.equipslot]
    if item == nil or item.itemid == 0 then
        return
    end
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local data = {}
    data.slot = sender.equipslot
    data.uuid = item.uuid
    itemmenu_reset(data)

    itemmenu_addbutton("BAGITEM_MENU_EQUIPOFF", playerequip_itemmenu_delegate_equip)
    if config_item.soul ~= nil and config_item.soul > 0 then
        itemmenu_addbutton("BAGITEM_MENU_SOUL", playerequip_itemmenu_delegate_soul)
    end
    if config_item.gem ~= nil and config_item.gem > 0 then
        itemmenu_addbutton("BAGITEM_MENU_GEM", playerequip_itemmenu_delegate_gem)
    end
    if playeritem_getitemdye(item, config_item) then
        itemmenu_addbutton("BAGITEM_MENU_DYE", playerequip_itemmenu_delegate_dye)
    end
    itemmenu_addbutton("BAGITEM_MENU_CHAT", playerequip_itemmenu_delegate_sendchat)
    
    local image_bg = m_uioverview_playermain:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    local menux = x + w
    local menuy = y + h / 2 + itemmenu_getheight() / 2
    itemmenu_open(menux, menuy, m_uioverview_playermain)

    tips_item(item.itemid, item.count, menux + itemmenu_getwidth(), -1, tipsflag.vright, item, m_uioverview_playermain)
end
