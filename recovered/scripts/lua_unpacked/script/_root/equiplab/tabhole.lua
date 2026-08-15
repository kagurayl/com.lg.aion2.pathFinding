
local m_tablehole_gemmax = 6
local m_tabhole_inst = {equip = "equiplab/inst_equip"}

function tabhole_onopen()
    local button_ok = m_equiplabmain:getwidget("tab_hole/button_ok")
    button_ok:setdelegate(tabhole_delegate_ok)
    button_ok:setenablenofade(false)

    local checkbox_subweapon = m_equiplabmain:getwidget("tab_hole/checkbox_subweapon")
    checkbox_subweapon:setcheck(false)
    checkbox_subweapon:setdelegate(tabhole_delegate_subweapon)
end

function tabhole_addequip(list_equip, equip, config_item, itemname)
    local gemcount = 0
    local gemmax = 0
    if equip.gem ~= nil and #equip.gem > 0 then
        gemcount = gemcount + #equip.gem
        gemmax = gemmax + m_tablehole_gemmax
    end
    if equip.subgem ~= nil and #equip.subgem > 0 then
        gemcount = gemcount + #equip.subgem
        gemmax = gemmax + m_tablehole_gemmax
    end
    local holeenable = gemcount < gemmax
    local line = list_equip:add(m_tabhole_inst.equip, equip.uuid, math.ternary(holeenable, equip.uuid, 0))
    line:setselectable(holeenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(holeenable)
    if holeenable then
        text_desc:settextscale("LAB_HOLE_EQUIP_HOLE", gemcount, gemmax)
    else
        text_desc:settextscale("LAB_HOLE_EQUIP_DISABLE")
    end
end

function tabhole_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_HOLE_TITLE")

    local text_desc = m_equiplabmain:getwidget("tab_hole/text_desc")
    local text_coin = m_equiplabmain:getwidget("tab_hole/text_coin")
    local text_cash = m_equiplabmain:getwidget("tab_hole/text_cash")
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local checkbox_subweapon = m_equiplabmain:getwidget("tab_hole/checkbox_subweapon")
    local subequip = checkbox_subweapon:getcheck()
    if subequip then
        local config_subequip = nil
        if equip ~= nil and equip.compound ~= nil and equip.compound > 0 then
            config_subequip = csvitem_getfromid(equip.compound)
        end
        local holeenable = equip ~= nil and config_subequip ~= nil and equip.subgem ~= nil and #equip.subgem > 0 and #equip.subgem < m_tablehole_gemmax
        if holeenable then
            local config_hole = nil
            local config_zonearray = c_config_getmetaarray(configid.equip_gemhole, "quality", config_subequip.quality, "hole", #equip.subgem + 1)
            if config_zonearray ~= nil then
                config_hole = config_zonearray[1]
            end
            if config_hole ~= nil then
                text_desc:settextscale("LAB_HOLE_COSTDESC", #equip.subgem + 1)
                text_coin:settext(config_hole.coin)
                text_cash:settext(config_hole.cash)
            else
                text_desc:settextscale("LAB_HOLE_EQUIP_DISABLE")
                text_coin:settext("0")
                text_cash:settext("0")
            end
        else
            text_desc:settextscale("LAB_HOLE_EQUIP_DISABLE")
            text_coin:settext("0")
            text_cash:settext("0")
        end

        local button_ok = m_equiplabmain:getwidget("tab_hole/button_ok")
        button_ok:setenable(holeenable)
    else
        local holeenable = equip ~= nil and config_equip ~= nil and equip.gem ~= nil and #equip.gem > 0 and #equip.gem < m_tablehole_gemmax
        if holeenable then
            local config_hole = nil
            local config_zonearray = c_config_getmetaarray(configid.equip_gemhole, "quality", config_equip.quality, "hole", #equip.gem + 1)
            if config_zonearray ~= nil then
                config_hole = config_zonearray[1]
            end
            if config_hole ~= nil then
                text_desc:settextscale("LAB_HOLE_COSTDESC", #equip.gem + 1)
                text_coin:settext(config_hole.coin)
                text_cash:settext(config_hole.cash)
            else
                text_desc:settextscale("LAB_HOLE_EQUIP_DISABLE")
                text_coin:settext("0")
                text_cash:settext("0")
            end
        else
            text_desc:settextscale("LAB_HOLE_EQUIP_DISABLE")
            text_coin:settext("0")
            text_cash:settext("0")
        end

        local button_ok = m_equiplabmain:getwidget("tab_hole/button_ok")
        button_ok:setenable(holeenable)
    end
end

function tabhole_delegate_subweapon(sender, event)
    tabhole_updateui()
end

function tabhole_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipGemHole"}
        msg.equipuuid = data.equipuuid
        msg.subweapon = data.subequip
        msg.hole = data.equiphole
        c_send(msg)
    end
end

function tabhole_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local checkbox_subweapon = m_equiplabmain:getwidget("tab_hole/checkbox_subweapon")
    local subequip = checkbox_subweapon:getcheck()
    local message = nil
    if subequip then
        if equip.subgem == nil then
            return
        end
        message = c_textformat("LAB_HOLE_CONFIRMSUBWEAPON", config_equip.name, #equip.subgem + 1)
    else
        if equip.gem == nil then
            return
        end
        message = c_textformat("LAB_HOLE_CONFIRM", config_equip.name, #equip.gem + 1)
    end
    local data = {}
    data.equipuuid = m_equiplabmain.equipuuid
    data.equiphole = #equip.gem + 1
    data.subequip = math.ternary(subequip, 1, 0)
    messagebox_confirm(message, tabhole_confirm, data)
end
