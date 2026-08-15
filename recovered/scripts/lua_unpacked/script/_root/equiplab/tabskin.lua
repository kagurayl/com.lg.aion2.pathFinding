
local m_tabskin_inst = {equip = "equiplab/inst_equip", item = "equiplab/inst_item"}

function tabskin_onopen()
    local list_equip2 = m_equiplabmain:getwidget("tab_skin/list_equip2")
    list_equip2:init(uilistflag.vertical)
    list_equip2:setclickdelegate(tabskin_delegate_listitem_equip2)

    local button_ok = m_equiplabmain:getwidget("tab_skin/button_ok")
    button_ok:setdelegate(tabskin_delegate_ok)
    button_ok:setenablenofade(false)
end

local function tabskin_getselectequip2uuid()
    local list_equip2 = m_equiplabmain:getwidget("tab_skin/list_equip2")
    local uuid = list_equip2:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

function tabskin_addequip(list_equip, equip, config_item, itemname)
    local skinenable = config_item.changeskin ~= nil and config_item.changeskin > 0

    local line = list_equip:add(m_tabskin_inst.equip, equip.uuid, math.ternary(skinenable, equip.uuid, 0))
    line:setselectable(skinenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(skinenable)
    if equip.skin ~= nil and equip.skin > 0 then
        text_desc:settextscale("LAB_ITEMSKIN_EQUIP_SKIN")
    elseif skinenable then
        text_desc:settextscale("LAB_ITEMSKIN_EQUIP_NONE")
    else
        text_desc:settextscale("LAB_ITEMSKIN_EQUIP_DISABLE")
    end
end

local function tabskin_updateequip2list()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local list_equip2 = m_equiplabmain:getwidget("tab_skin/list_equip2")
    list_equip2:savestate()
    list_equip2:clear()

    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 and item.uuid ~= m_equiplabmain.equipuuid then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil then
                local changeskin = config_item.changeskin ~= nil and config_item.changeskin > 0
                if changeskin then
                    if not csvitem_getskinable(config_equip.itemtype, config_item.itemtype) then
                        changeskin = false
                    end
                elseif csvitem_getscript(config_item, "removeskin") ~= nil then
                    changeskin = true
                end

                if changeskin then
                    local line = list_equip2:add(m_tabskin_inst.item, i, item.uuid)
                    local image_icon = line:getwidget("image_icon")
                    image_icon:seticon(config_item.icon)

                    local text_name = line:getwidget("text_name")
                    text_name:settextscale(config_item.name)
                    text_name:setcolor(csvitem_getfloatcolor(config_item))
                end
            end
        end
    end

    list_equip2:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_skin/text_noitem", list_equip2:getcount() == 0)
end

local function tabskin_updateequip2info()
    local button_ok = m_equiplabmain:getwidget("tab_skin/button_ok")
    local text_equip2name = m_equiplabmain:getwidget("tab_skin/text_equip2name")
    local text_equip2soul = m_equiplabmain:getwidget("tab_skin/text_equip2soul")
    local text_equip2gem = m_equiplabmain:getwidget("tab_skin/text_equip2gem")
    local text_equip2god = m_equiplabmain:getwidget("tab_skin/text_equip2god")
    local text_equip2compound = m_equiplabmain:getwidget("tab_skin/text_equip2compound")
    local text_reset = m_equiplabmain:getwidget("tab_skin/text_reset")
    local uuid = tabskin_getselectequip2uuid()
    local equip2, config_equip2 = playeritem_getitemconfigfromuuid(uuid)
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local visible = equip ~= nil and config_equip ~= nil and equip2 ~= nil and config_equip2 ~= nil
    local reset = false
    if visible then
        reset = csvitem_getscript(config_equip2, "removeskin") ~= nil
    end
    text_equip2name:setvisiblenothit(visible and not reset)
    text_equip2soul:setvisiblenothit(visible and not reset)
    text_equip2gem:setvisiblenothit(visible and not reset)
    text_equip2god:setvisiblenothit(visible and not reset)
    text_equip2compound:setvisiblenothit(visible and not reset)
    text_reset:setvisiblenothit(visible and reset)
    button_ok:setenable(visible)
    if not visible or reset then
        return
    end
    text_equip2name:settextscale(config_equip2.name)
    text_equip2name:setcolor(csvitem_getfloatcolor(config_equip2))

    text_equip2soul:settextscale("LAB_ITEMSKIN_SOULINFO", equip2.soul, config_equip.soul)
    text_equip2soul:setavailablecolor(equip2.soul > 0)

    local gemcount, gemmax = equip_getgemcount(equip2.gem)
    local subgemcount, subgemmax = equip_getgemcount(equip2.subgem)
    text_equip2gem:settextscale("LAB_ITEMSKIN_GEMINFO", equip2.soul, config_equip.soul, gemcount + subgemcount, gemmax + subgemmax)
    text_equip2gem:setavailablecolor(gemcount + subgemcount > 0)

    local config_god = nil
    if equip2.god ~= nil and equip2.god > 0 then
        config_god = csvitem_getfromid(equip2.god)
    end
    if config_god ~= nil then
        text_equip2god:settext(config_god.name)
    else
        text_equip2god:settext("LAB_ITEMSKIN_GODNONE")
    end
    text_equip2god:setavailablecolor(config_god ~= nil)

    if equip2.compound ~= nil and equip2.compound > 0 then
        local name = ""
        local compound = csvitem_getfromid(equip2.compound)
        if compound ~= nil then
            name = compound.name
        end
        text_equip2compound:settextscale("LAB_ITEMSKIN_SUBINFO", name)
    else
        text_equip2compound:settext("LAB_ITEMSKIN_SUBNONE")
    end
    text_equip2compound:setavailablecolor(equip2.compound ~= nil and equip2.compound > 0)
end

function tabskin_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_ITEMSKIN_TITLE")

    tabskin_updateequip2list()
    tabskin_updateequip2info()
end

function tabskin_delegate_listitem_equip2(line, event, uuid)
    tabskin_updateequip2info()
end

function tabskin_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipSkin"}
        msg.actorid = data.npcactorid
        msg.equipuuid = data.equipuuid
        msg.skinuuid = data.skinuuid
        c_send(msg)
    end
end

function tabskin_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local uuid = tabskin_getselectequip2uuid()
    local equip2, config_equip2 = playeritem_getitemconfigfromuuid(uuid)
    if equip2 == nil or config_equip2 == nil then
        return
    end
    local message = c_textformat("LAB_ITEMSKIN_TIPS_CONFIRM", config_equip2.name, config_equip.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    data.skinuuid = uuid
    messagebox_confirm(message, tabskin_confirm, data)
end
