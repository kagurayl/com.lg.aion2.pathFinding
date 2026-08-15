
local m_tabdecompound_inst = {equip = "equiplab/inst_equip"}

function tabdecompound_onopen()
    local button_ok = m_equiplabmain:getwidget("tab_decompound/button_ok")
    button_ok:setdelegate(tabdecompound_delegate_ok)
    button_ok:setenablenofade(false)
end

function tabdecompound_addequip(list_equip, equip, config_item, itemname)
    local decompoundenable = equip.compound ~= nil and equip.compound > 0

    local line = list_equip:add(m_tabdecompound_inst.equip, equip.uuid, math.ternary(decompoundenable, equip.uuid, 0))
    line:setselectable(decompoundenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(compoundenable)
    if equip.compound ~= nil and equip.compound > 0 then
        local name = ""
        local compound = csvitem_getfromid(equip.compound)
        if compound ~= nil then
            name = compound.name
        end
        text_desc:settextscale("LAB_DECOMPOUNT_EQUIP_INFO", name)
    else
        text_desc:settextscale("LAB_DECOMPOUNT_EQUIP_NONE")
    end
end

function tabdecompound_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_DECOMPOUNT_TITLE")

    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local button_ok = m_equiplabmain:getwidget("tab_decompound/button_ok")
    button_ok:setenable(equip ~= nil and config_equip ~= nil and equip.compound ~= nil and equip.compound > 0)
end

function tabdecompound_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipDecompound"}
        msg.actorid = data.npcactorid
        msg.equipuuid = data.equipuuid
        c_send(msg)
    end
end

function tabdecompound_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local message = c_textformat("LAB_DECOMPOUNT_TIPS_CONFIRM", config_equip.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    messagebox_confirm(message, tabdecompound_confirm, data)
end
