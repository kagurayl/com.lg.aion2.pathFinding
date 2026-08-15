
local m_tabcompound_inst = {equip = "equiplab/inst_equip", item = "equiplab/inst_item"}

function tabcompound_onopen()
    local list_equip2 = m_equiplabmain:getwidget("tab_compound/list_equip2")
    list_equip2:init(uilistflag.vertical)
    list_equip2:setclickdelegate(tabcompound_delegate_listitem_equip2)

    local button_ok = m_equiplabmain:getwidget("tab_compound/button_ok")
    button_ok:setdelegate(tabcompound_delegate_ok)
    button_ok:setenablenofade(false)
end

local function tabcompound_getcomposite(config_item)
    local itemtype = config_item.itemtype
    if itemtype == csvitemtype.weapon_sword2
    or itemtype == csvitemtype.weapon_polearm
    or itemtype == csvitemtype.weapon_staff
    or itemtype == csvitemtype.weapon_bow
    or itemtype == csvitemtype.weapon_book
    or itemtype == csvitemtype.weapon_orb then
        return true
    end
    return false
end

local function tabcompound_getselectequip2uuid()
    local list_equip2 = m_equiplabmain:getwidget("tab_compound/list_equip2")
    local uuid = list_equip2:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

function tabcompound_addequip(list_equip, equip, config_item, itemname)
    local compoundenable = tabcompound_getcomposite(config_item)

    local line = list_equip:add(m_tabcompound_inst.equip, equip.uuid, math.ternary(compoundenable, equip.uuid, 0))
    line:setselectable(compoundenable)

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
        text_desc:settextscale("LAB_COMPOUNT_EQUIP_INFO", name)
    elseif compoundenable then
        text_desc:settextscale("LAB_COMPOUNT_EQUIP_NONE")
    else
        text_desc:settextscale("LAB_COMPOUNT_EQUIP_DISABLE")
    end
end

local function tabcompound_updateequip2list()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local list_equip2 = m_equiplabmain:getwidget("tab_compound/list_equip2")
    list_equip2:savestate()
    list_equip2:clear()

    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 and item.uuid ~= m_equiplabmain.equipuuid then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and tabcompound_getcomposite(config_item) and config_item.itemlevel <= config_equip.itemlevel and config_item.itemtype == config_equip.itemtype then
                local line = list_equip2:add(m_tabcompound_inst.item, i, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)

                local text_name = line:getwidget("text_name")
                text_name:settextscale(config_item.name)
                text_name:setcolor(csvitem_getfloatcolor(config_item))
            end
        end
    end

    list_equip2:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_compound/text_noequip2", list_equip2:getcount() == 0)
end

local function tabcompound_updateequip2info()
    local button_ok = m_equiplabmain:getwidget("tab_compound/button_ok")
    local text_equip2name = m_equiplabmain:getwidget("tab_compound/text_equip2name")
    local text_equip2soul = m_equiplabmain:getwidget("tab_compound/text_equip2soul")
    local text_equip2gem = m_equiplabmain:getwidget("tab_compound/text_equip2gem")
    local text_equip2god = m_equiplabmain:getwidget("tab_compound/text_equip2god")
    local text_equip2compound = m_equiplabmain:getwidget("tab_compound/text_equip2compound")
    local uuid = tabcompound_getselectequip2uuid()
    local equip2, config_equip2 = playeritem_getitemconfigfromuuid(uuid)
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    local visible = equip ~= nil and config_equip ~= nil and equip2 ~= nil and config_equip2 ~= nil
    text_equip2name:setvisiblenothit(visible)
    text_equip2soul:setvisiblenothit(visible)
    text_equip2gem:setvisiblenothit(visible)
    text_equip2god:setvisiblenothit(visible)
    text_equip2compound:setvisiblenothit(visible)
    button_ok:setenable(visible)
    if not visible then
        return
    end
    text_equip2name:settextscale(config_equip2.name)
    text_equip2name:setcolor(csvitem_getfloatcolor(config_equip2))

    text_equip2soul:settextscale("LAB_COMPOUNT_SOULINFO", equip2.soul, config_equip.soul)
    text_equip2soul:setavailablecolor(equip2.soul > 0)

    local gemcount, gemmax = equip_getgemcount(equip2.gem)
    local subgemcount, subgemmax = equip_getgemcount(equip2.subgem)
    text_equip2gem:settextscale("LAB_COMPOUNT_GEMINFO", equip2.soul, config_equip.soul, gemcount + subgemcount, gemmax + subgemmax)
    text_equip2gem:setavailablecolor(gemcount + subgemcount > 0)

    local config_god = nil
    if equip2.god ~= nil and equip2.god > 0 then
        config_god = csvitem_getfromid(equip2.god)
    end
    if config_god ~= nil then
        text_equip2god:settext(config_god.name)
    else
        text_equip2god:settext("LAB_COMPOUNT_GODNONE")
    end
    text_equip2god:setavailablecolor(config_god ~= nil)

    if equip2.compound ~= nil and equip2.compound > 0 then
        local name = ""
        local compound = csvitem_getfromid(equip2.compound)
        if compound ~= nil then
            name = compound.name
        end
        text_equip2compound:settextscale("LAB_COMPOUNT_SUBINFO", name)
    else
        text_equip2compound:settext("LAB_COMPOUNT_SUBNONE")
    end
    text_equip2compound:setavailablecolor(equip2.compound ~= nil and equip2.compound > 0)
end

function tabcompound_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_COMPOUNT_TITLE")

    tabcompound_updateequip2list()
    tabcompound_updateequip2info()
end

function tabcompound_delegate_listitem_equip2(line, event, uuid)
    tabcompound_updateequip2info()
end

function tabcompound_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipCompound"}
        msg.actorid = data.npcactorid
        msg.equipuuid = data.equipuuid
        msg.equipuuid2 = data.equipuuid2
        c_send(msg)
    end
end

function tabcompound_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local uuid = tabcompound_getselectequip2uuid()
    local equip2, config_equip2 = playeritem_getitemconfigfromuuid(uuid)
    if equip2 == nil or config_equip2 == nil then
        return
    end
    local message = c_textformat("LAB_COMPOUNT_TIPS_CONFIRM", config_equip2.name, config_equip.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    data.equipuuid2 = uuid
    messagebox_confirm(message, tabcompound_confirm, data)
end
