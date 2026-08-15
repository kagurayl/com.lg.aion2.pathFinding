
local m_tabdye_inst = {equip = "equiplab/inst_equip", equipdye = "equiplab/inst_equipdye", dye = "equiplab/inst_dye", item = "equiplab/inst_item"}

function tabdye_onopen()
    local list_dye = m_equiplabmain:getwidget("tab_dye/list_dye")
    list_dye:init(uilistflag.vertical)
    list_dye:setclickdelegate(tabdye_delegate_listitem_dye)

    local button_ok = m_equiplabmain:getwidget("tab_dye/button_ok")
    button_ok:setdelegate(tabdye_delegate_ok)
    button_ok:setenablenofade(false)
end

local function tabdye_getselectdyeuuid()
    local list_dye = m_equiplabmain:getwidget("tab_dye/list_dye")
    local uuid = list_dye:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

local function tabdye_getequipdye(equip, config_item)
    if equip.dye ~= 0 then
        return HexRGBDefault(csvitem_getdyecolor(equip.dye))
    elseif playerattr_info.sex == playersex.male then
        return HexRGB(config_item.colormale)
    else
        return HexRGB(config_item.colorfemale)
    end
end

function tabdye_addequip(list_equip, equip, config_item, itemname)
    local dyeenable = config_item.dye ~= nil and config_item.dye > 0
    if dyeenable then
        local line = list_equip:add(m_tabdye_inst.equipdye, equip.uuid, equip.uuid)
        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(itemname)
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local r, g, b = tabdye_getequipdye(equip, config_item)
        local image_color = line:getwidget("image_color")
        image_color:setcolor(r, g, b, 1.0)
    else
        local line = list_equip:add(m_tabdye_inst.equip)
        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(itemname)
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local text_desc = line:getwidget("text_desc")
        text_desc:setavailablecolor(false)
        text_desc:settextscale("LAB_ITEMDYE_DISABLE")
    end
end

local function tabdye_updatedyelist()
    local list_dye = m_equiplabmain:getwidget("tab_dye/list_dye")
    list_dye:savestate()
    list_dye:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item.itemtype == csvitemtype.consume_dye then
                if csvitem_getscript(config_item, "dye") ~= nil then
                    local line = list_dye:add(m_tabdye_inst.dye, i, item.uuid)
                    local image_icon = line:getwidget("image_icon")
                    image_icon:seticon(config_item.icon)

                    local text_count = line:getwidget("text_count")
                    text_count:settext(item.count)

                    local text_name = line:getwidget("text_name")
                    text_name:settextscale(config_item.name)
                    text_name:setcolor(csvitem_getfloatcolor(config_item))

                    local r, g, b = HexRGBDefault(csvitem_getdyecolorfromconfig(config_item))
                    local image_color = line:getwidget("image_color")
                    image_color:setcolor(r, g, b, 1.0)
                elseif csvitem_getscript(config_item, "removedye") ~= nil then
                    local line = list_dye:add(m_tabdye_inst.item, i, item.uuid)
                    local image_icon = line:getwidget("image_icon")
                    image_icon:seticon(config_item.icon)

                    local text_name = line:getwidget("text_name")
                    text_name:settextscale(config_item.name)
                    text_name:setcolor(csvitem_getfloatcolor(config_item))
                end
            end
        end
    end

    list_dye:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_dye/text_noitem", list_dye:getcount() == 0)
end

local function tabdye_updatecolorinfo()
    local button_ok = m_equiplabmain:getwidget("tab_dye/button_ok")
    local text_currentcolor = m_equiplabmain:getwidget("tab_dye/text_currentcolor")
    local text_dyestate = m_equiplabmain:getwidget("tab_dye/text_dyestate")
    local image_currentcolor = m_equiplabmain:getwidget("tab_dye/image_currentcolor")
    local image_dyecolor = m_equiplabmain:getwidget("tab_dye/image_dyecolor")
    local uuid = tabdye_getselectdyeuuid()
    local dye, config_dye = playeritem_getitemconfigfromuuid(uuid)
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local visible = equip ~= nil and config_equip ~= nil and dye ~= nil and config_dye ~= nil
    text_currentcolor:setvisiblenothit(visible)
    text_dyestate:setvisiblenothit(visible)
    image_currentcolor:setvisiblenothit(visible)
    image_dyecolor:setvisiblenothit(visible)
    button_ok:setenable(visible)
    if not visible then
        return
    end
    local r, g, b = tabdye_getequipdye(equip, config_equip)
    image_currentcolor:setcolor(r, g, b, 1.0)

    r, g, b = HexRGBDefault(csvitem_getdyecolorfromconfig(config_dye))
    image_dyecolor:setcolor(r, g, b, 1.0)
end

function tabdye_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_ITEMDYE_TITLE")

    tabdye_updatedyelist()
    tabdye_updatecolorinfo()
end

function tabdye_delegate_listitem_dye(line, event, uuid)
    tabdye_updatecolorinfo()
end

function tabdye_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipDye"}
        msg.equipuuid = data.equipuuid
        msg.dyeuuid = data.dyeuuid
        c_send(msg)
    end
end

function tabdye_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local uuid = tabdye_getselectdyeuuid()
    if uuid == 0 then
        return
    end
    local dye, config_dye = playeritem_getitemconfigfromuuid(uuid)
    if dye == nil or config_dye == nil then
        return
    end
    local message = c_textformat("LAB_ITEMDYE_TIPS_CONFIRM", config_dye.name, config_equip.name)
    local data = {}
    data.equipuuid = m_equiplabmain.equipuuid
    data.dyeuuid = uuid
    messagebox_confirm(message, tabdye_confirm, data)
end
