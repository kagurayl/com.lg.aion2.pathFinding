
local m_tabgod_inst = {equip = "equiplab/inst_equip", god = "equiplab/inst_god"}

function tabgod_onopen()
    local list_god = m_equiplabmain:getwidget("tab_god/list_god")
    list_god:init(uilistflag.vertical)
    list_god:setclickdelegate(tabgod_delegate_listitem_god)

    local button_ok = m_equiplabmain:getwidget("tab_god/button_ok")
    button_ok:setdelegate(tabgod_delegate_ok)
    button_ok:setenablenofade(false)
end

function tabgod_addequip(list_equip, equip, config_item, itemname)
    local godenable = config_item.god > 0

    local line = list_equip:add(m_tabgod_inst.equip, equip.uuid, math.ternary(godenable, equip.uuid, 0))
    line:setselectable(godenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(godenable)
    if godenable then
        if equip.god ~= nil and equip.god ~= 0 then
            local config_god = csvitem_getfromid(equip.god)
            if config_god ~= nil then
                text_desc:settextscale(config_god.name)
            end
        else
            text_desc:settextscale("LAB_GODSTONE_EQUIP_GODNONE")
        end
    else
        text_desc:settextscale("LAB_GODSTONE_EQUIP_GODDISABLE")
    end
end

local function tabgod_getselectgoduuid()
    local list_god = m_equiplabmain:getwidget("tab_god/list_god")
    local uuid = list_god:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

local function tabgod_updatebuttonstate()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local god, config_god = playeritem_getitemconfigfromuuid(tabgod_getselectgoduuid())
    local button_ok = m_equiplabmain:getwidget("tab_god/button_ok")
    if equip == nil or config_equip == nil or god == nil or config_god == nil then
        button_ok:setenable(false)
    else
        button_ok:setenable(true)
    end
end

function tabgod_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_GODSTONE_TITLE")

    local list_god = m_equiplabmain:getwidget("tab_god/list_god")
    list_god:savestate()
    list_god:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil then
                if config_item.itemtype == csvitemtype.consume_god then
                    local line = list_god:add(m_tabgod_inst.god, i, item.uuid)
                    local image_stoneicon = line:getwidget("image_icon")
                    image_stoneicon:seticon(config_item.icon)

                    local text_name = line:getwidget("text_name")
                    if item.count > 1 then
                        text_name:settextscale(string.format("%s(%d)", config_item.name, item.count))
                    else
                        text_name:settextscale(config_item.name)                        
                    end
                    text_name:setcolor(csvitem_getfloatcolor(config_item))

                    local text_desc = line:getwidget("text_desc")
                    text_desc:settextscale(csvitem_getgoddesc(config_item))
                end
            end
        end
    end
    list_god:restorestate()

    local text_nogod = m_equiplabmain:getwidget("tab_god/text_nogod")
    text_nogod:setvisiblenothit(list_god:getcount() == 0)

    tabgod_updatebuttonstate()
end

function tabgod_delegate_listitem_god(line, event, uuid)
    tabgod_updatebuttonstate()
end

function tabgod_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipGod"}
        msg.actorid = data.npcactorid
        msg.equipuuid = data.equipuuid
        msg.stoneuuid = data.goduuid
        c_send(msg)
    end
end

function tabgod_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local uuid = tabgod_getselectgoduuid()
    local god, config_god = playeritem_getitemconfigfromuuid(uuid)
    if god == nil or config_god == nil then
        return
    end
    local message = c_textformat("LAB_GODSTONE_TIPS_CONFIRM", config_equip.name, config_god.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    data.goduuid = uuid
    messagebox_confirm(message, tabgod_confirm, data)
end
