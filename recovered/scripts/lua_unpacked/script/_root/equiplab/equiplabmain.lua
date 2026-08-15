
equiplab_tabtype =
{
    soul = 1,
    gem = 2,
    gemhole = 3,
    gemremove = 4,
    god = 5,
    compound = 6,
    decompound = 7,
    unbind = 8,
    charge = 9,
    skin = 10,
    dye = 11,
}

m_equiplabmain = uipanel_createhandle("equiplab/equiplabmain", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))
local m_equiplab_tabtype = equiplab_tabtype.soul

function equiplab_show(equipuuid, type, npcactorid)
    m_equiplab_tabtype = type
    m_equiplabmain.npcactorid = npcactorid
    m_equiplabmain.equipuuid = equipuuid
    m_equiplabmain:open()

    m_equiplabmain.tabmain:settabavailable("tab_soul", m_equiplabmain.npcactorid == 0)
    m_equiplabmain.tabmain:settabavailable("tab_gem", m_equiplabmain.npcactorid == 0)
    m_equiplabmain.tabmain:settabavailable("tab_hole", m_equiplabmain.npcactorid == 0)
    m_equiplabmain.tabmain:settabavailable("tab_gemremove", type == equiplab_tabtype.gemremove)
    m_equiplabmain.tabmain:settabavailable("tab_god", type == equiplab_tabtype.god)
    m_equiplabmain.tabmain:settabavailable("tab_compound", type == equiplab_tabtype.compound)
    m_equiplabmain.tabmain:settabavailable("tab_decompound", type == equiplab_tabtype.decompound)
    m_equiplabmain.tabmain:settabavailable("tab_unbind", m_equiplabmain.npcactorid == 0)
    m_equiplabmain.tabmain:settabavailable("tab_charge", m_equiplabmain.npcactorid == 0)
    m_equiplabmain.tabmain:settabavailable("tab_skin", type == equiplab_tabtype.skin)
    m_equiplabmain.tabmain:settabavailable("tab_dye", type == equiplab_tabtype.dye)
    m_equiplabmain.tabmain:settab(type)

    equiplabmain_updateui()
end

function equiplabmain_onopen()
    local list_equip = m_equiplabmain:getwidget("list_equip")
    list_equip:init(uilistflag.vertical)
    list_equip:setclickdelegate(equiplabmain_delegate_listequip)

    m_equiplabmain.tabmain = uitabcreate(m_equiplabmain)
    m_equiplabmain.tabmain:add("button_soul", "tab_soul", equiplabmain_delegate_tabsoul)
    m_equiplabmain.tabmain:add("button_gem", "tab_gem", equiplabmain_delegate_tabgem)
    m_equiplabmain.tabmain:add("button_gemhole", "tab_hole", equiplabmain_delegate_tabgemhole)
    m_equiplabmain.tabmain:add("button_gemremove", "tab_gemremove", equiplabmain_delegate_tabgemremove)
    m_equiplabmain.tabmain:add("button_god", "tab_god", equiplabmain_delegate_tabgod)
    m_equiplabmain.tabmain:add("button_compound", "tab_compound", equiplabmain_delegate_tabcompound)
    m_equiplabmain.tabmain:add("button_decompound", "tab_decompound", equiplabmain_delegate_tabdecompound)
    m_equiplabmain.tabmain:add("button_unbind", "tab_unbind", equiplabmain_delegate_tabunbind)
    m_equiplabmain.tabmain:add("button_charge", "tab_charge", equiplabmain_delegate_tabcharge)
    m_equiplabmain.tabmain:add("button_skin", "tab_skin", equiplabmain_delegate_tabskin)
    m_equiplabmain.tabmain:add("button_dye", "tab_dye", equiplabmain_delegate_tabdye)
    m_equiplabmain:setwidgetdelegate("image_bg/button_close", equiplabmain_delegate_close)

    tabsoul_onopen()
    tabgem_onopen()
    tabhole_onopen()
    tabgemremove_onopen()
    tabgod_onopen()
    tabcompound_onopen()
    tabdecompound_onopen()
    tabunbind_onopen()
    tabcharge_onopen()
    tabskin_onopen()
    tabdye_onopen()

    event_register(eventtype.item, equiplabmain_updateui, m_equiplabmain)
end

local function equiplabmain_addequip(list_equip, item, equipslot)
    if item.itemid == 0 then
        return
    end
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil or not csvitem_isequip(config_item) then
        return
    end
    local itemname = config_item.name
    if equipslot then
        itemname = itemname .. c_textformat("LAB_ROOT_EQUIPSLOT")
    end
    if m_equiplab_tabtype == equiplab_tabtype.soul then
        tabsoul_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.gem then
        tabgem_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.gemhole then
        tabhole_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.gemremove then
        tabgemremove_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.god then
        tabgod_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.compound then
        tabcompound_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.decompound then
        tabdecompound_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.unbind then
        tabunbind_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.charge then
        tabcharge_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.skin then
        tabskin_addequip(list_equip, item, config_item, itemname)
    elseif m_equiplab_tabtype == equiplab_tabtype.dye then
        tabdye_addequip(list_equip, item, config_item, itemname)
    end
end

function equiplabmain_updateui()
    if m_equiplabmain:null() then
        return
    end
    local list_equip = m_equiplabmain:getwidget("list_equip")
    list_equip:savestate()
    list_equip:clear()

    for i=1,#playerattr_bag do
        equiplabmain_addequip(list_equip, playerattr_bag[i], false)
    end
	for i=1, #playerattr_equip1 do
		equiplabmain_addequip(list_equip, playerattr_equip1[i], true)
	end
	for i=1, #playerattr_equip2 do
        equiplabmain_addequip(list_equip, playerattr_equip2[i], true)
	end
    m_equiplabmain:setwidgetvisiblenothit("text_noitem", list_equip:getcount() == 0)
    list_equip:restorestate()

    list_equip:selectline(m_equiplabmain.equipuuid)
    equiplabmain_updatesubui()
end

function equiplabmain_updateequipstate()
    local equipinfo = m_equiplabmain:getwidget("equipinfo")
    local text_notselect = m_equiplabmain:getwidget("text_equipnotselect")
    local equip = playeritem_getfromuuid(m_equiplabmain.equipuuid)
    if equip == nil then
        equipinfo:setvisiblenothit(false)
        text_notselect:setvisiblenothit(true)
        return
    end

    local config_equip = csvitem_getfromid(equip.itemid)
    if config_equip == nil then
        equipinfo:setvisiblenothit(false)
        text_notselect:setvisiblenothit(true)
        return
    end
    equipinfo:setvisiblenothit(true)
    text_notselect:setvisiblenothit(false)

    local image_icon = m_equiplabmain:getwidget("equipinfo/image_icon")
    image_icon:seticon(config_equip.icon)

    local text_equipname = m_equiplabmain:getwidget("equipinfo/text_equipname")
    if m_equiplab_tabtype == equiplab_tabtype.gem then
        text_equipname:settext(c_textformat("LAB_GEM_EQUIPNAME", config_equip.name, csvitem_getgemlevel(config_equip)))
    else
        text_equipname:settext(config_equip.name)
    end
    
    text_equipname:setcolor(csvitem_getfloatcolor(config_equip))

    local gemcount, gemmax = equip_getgemcount(equip.gem)
    local text_equipsoul = m_equiplabmain:getwidget("equipinfo/text_equipsoul")
    text_equipsoul:settext("LAB_ROOT_SOULGEMINFO", equip.soul, config_equip.soul, gemcount, gemmax)
    if equip.soul > 0 or gemcount > 0 then
        text_equipsoul:setavailablecolor(true)
    else
        text_equipsoul:setavailablecolor(false)
    end

    local text_equipgod = m_equiplabmain:getwidget("equipinfo/text_equipgod")
    local config_god = nil
    if equip.god ~= nil and equip.god > 0 then
        config_god = csvitem_getfromid(equip.god)
    end
    if config_god ~= nil then
        text_equipgod:settextscale("LAB_ROOT_GODINFO", config_god.name, csvitem_getgoddesc(config_god))
        text_equipgod:setavailablecolor(true)
    else
        text_equipgod:settextscale("LAB_ROOT_GODNONE")
        text_equipgod:setavailablecolor(false)
    end

    local text_equipsubweapon = m_equiplabmain:getwidget("equipinfo/text_equipsubweapon")
    local config_subequip = nil
    if equip.compound ~= nil and equip.compound > 0 then
        config_subequip = csvitem_getfromid(equip.compound)
    end
    if config_subequip ~= nil then
        gemcount, gemmax = equip_getgemcount(equip.subgem)
        text_equipsubweapon:settextscale("LAB_ROOT_SUBINFO", config_subequip.name, gemcount, gemmax)
        text_equipsubweapon:setavailablecolor(true)
    else
        text_equipsubweapon:settextscale("LAB_ROOT_SUBNONE")
        text_equipsubweapon:setavailablecolor(false)
    end
end

function equiplabmain_updatesubui()
    equiplabmain_updateequipstate()
    if m_equiplab_tabtype == equiplab_tabtype.soul then
        tabsoul_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.gem then
        tabgem_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.gemhole then
        tabhole_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.gemremove then
        tabgemremove_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.god then
        tabgod_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.compound then
        tabcompound_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.decompound then
        tabdecompound_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.unbind then
        tabunbind_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.charge then
        tabcharge_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.skin then
        tabskin_updateui()
    elseif m_equiplab_tabtype == equiplab_tabtype.dye then
        tabdye_updateui()
    end
end

function equiplabmain_delegate_tabsoul()
    m_equiplab_tabtype = equiplab_tabtype.soul
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabgem()
    m_equiplab_tabtype = equiplab_tabtype.gem
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabgemhole()
    m_equiplab_tabtype = equiplab_tabtype.gemhole
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabgemremove()
    m_equiplab_tabtype = equiplab_tabtype.gemremove
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabgod()
    m_equiplab_tabtype = equiplab_tabtype.god
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabcompound()
    m_equiplab_tabtype = equiplab_tabtype.compound
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabdecompound()
    m_equiplab_tabtype = equiplab_tabtype.decompound
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabunbind()
    m_equiplab_tabtype = equiplab_tabtype.unbind
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabcharge()
    m_equiplab_tabtype = equiplab_tabtype.charge
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabskin()
    m_equiplab_tabtype = equiplab_tabtype.skin
    equiplabmain_updateui()
end

function equiplabmain_delegate_tabdye()
    m_equiplab_tabtype = equiplab_tabtype.dye
    equiplabmain_updateui()
end

function equiplabmain_delegate_listequip(line, event, data)
    m_equiplabmain.equipuuid = line:getdata()
    equiplabmain_updatesubui()
end

function equiplabmain_delegate_close()
    m_equiplabmain:close()
end
