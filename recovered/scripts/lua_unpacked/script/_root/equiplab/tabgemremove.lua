
local m_tabgemremove_inst = {equip = "equiplab/inst_equip", item = "equiplab/inst_item", text = "equiplab/inst_text"}

function tabgemremove_onopen()
    local list_gemmain = m_equiplabmain:getwidget("tab_gemremove/list_gemmain")
    list_gemmain:init(uilistflag.vertical)
    list_gemmain:setclickdelegate(tabgemremove_delegate_listitem_gemmain)

    local list_gemsub = m_equiplabmain:getwidget("tab_gemremove/list_gemsub")
    list_gemsub:init(uilistflag.vertical)
    list_gemsub:setclickdelegate(tabgemremove_delegate_listitem_gemsub)

    local button_removemain = m_equiplabmain:getwidget("tab_gemremove/button_removemain")
    button_removemain:setdelegate(tabgemremove_delegate_removemain)
    button_removemain:setenablenofade(false)

    local button_removesub = m_equiplabmain:getwidget("tab_gemremove/button_removesub")
    button_removesub:setdelegate(tabgemremove_delegate_removesub)
    button_removesub:setenablenofade(false)
end

function tabgemremove_addequip(list_equip, equip, config_item, itemname)
    local gemcount, gemmax = equip_getgemcount(equip.gem)
    local gemsubcount, gemsubmax = equip_getgemcount(equip.subgem)
    local gemenable = gemmax + gemsubmax > 0 and gemcount + gemsubcount > 0

    local line = list_equip:add(m_tabgemremove_inst.equip, equip.uuid, math.ternary(gemenable, equip.uuid, 0))
    line:setselectable(gemenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(gemenable)
    if gemenable then
        text_desc:settextscale("LAB_GEMREMOVE_EQUIP_GEM", gemcount + gemsubcount, gemmax + gemsubmax)
    else
        text_desc:settextscale("LAB_GEMREMOVE_EQUIP_DISABLE")
    end
end

local function tabgemremove_addgemlist(list_gem, gem)
    list_gem:savestate()
    list_gem:clear()
    for i=1,#gem do
        local config_item = csvitem_getfromid(gem[i])
        if config_item ~= nil then
            local line = list_gem:add(m_tabgemremove_inst.item, i, i)
            local image_icon = line:getwidget("image_icon")
            local text_name = line:getwidget("text_name")
            image_icon:seticon(config_item.icon)
            text_name:settextscale(config_item.name)
            text_name:setcolor(csvitem_getfloatcolor(config_item))
        else
            local line = list_gem:add(m_tabgemremove_inst.text)
            local text_desc = line:getwidget("text_desc")
            text_desc:settext("LAB_GEMREMOVE_EQUIP_EMPTY")
        end
    end
    list_gem:restorestate()
end

local function tabgemremove_updategemlist()
    local gem = {}
    local subgem = {}
    local equip = playeritem_getfromuuid(m_equiplabmain.equipuuid)
    if equip ~= nil then
        if equip.gem ~= nil then
            gem = equip.gem
        end
        if equip.subgem ~= nil then
            subgem = equip.subgem
        end
    end

    local list_gemmain = m_equiplabmain:getwidget("tab_gemremove/list_gemmain")
    tabgemremove_addgemlist(list_gemmain, gem)

    local list_gemsub = m_equiplabmain:getwidget("tab_gemremove/list_gemsub")
    tabgemremove_addgemlist(list_gemsub, subgem)
end

local function tabgemremove_getselectgem()
    local equip = playeritem_getfromuuid(m_equiplabmain.equipuuid)
    local gemindex = 0
    local subgemindex = 0
    if equip ~= nil then
        if equip.gem ~= nil and #equip.gem > 0 then
            local list_gemmain = m_equiplabmain:getwidget("tab_gemremove/list_gemmain")
            gemindex = list_gemmain:getfirstselect()
            if gemindex == nil or gemindex > #equip.gem then
                gemindex = 0
            end
        end
        if equip.subgem ~= nil and #equip.subgem > 0 then
            local list_gemsub = m_equiplabmain:getwidget("tab_gemremove/list_gemsub")
            subgemindex = list_gemsub:getfirstselect()
            if subgemindex == nil or subgemindex > #equip.subgem then
                subgemindex = 0
            end
        end
    end
    return equip, gemindex, subgemindex
end

local function tabgemremove_updatebuttonstate()
    local equip, gemindex, subgemindex = tabgemremove_getselectgem()
    local button_removemain = m_equiplabmain:getwidget("tab_gemremove/button_removemain")
    button_removemain:setenable(gemindex > 0 and gemindex <= #equip.gem)

    local button_removesub = m_equiplabmain:getwidget("tab_gemremove/button_removesub")
    button_removesub:setenable(subgemindex > 0 and subgemindex <= #equip.subgem)
end

function tabgemremove_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_GEMREMOVE_TITLE")

    tabgemremove_updategemlist()
end

function tabgemremove_delegate_listitem_gemmain(line, event, uuid)
    tabgemremove_updatebuttonstate()
end

function tabgemremove_delegate_listitem_gemsub(line, event, uuid)
    tabgemremove_updatebuttonstate()
end

function tabgemremove_confirm(ok, data)
    if ok then
        local equip = playeritem_getfromuuid(m_gemremove_equipuuid)
        local msg = {messageid="CS_EquipRemoveGem"}
        msg.actorid = data.npcactorid
        msg.equipuuid = data.equipuuid
        msg.gemindex = data.gemindex - 1
        msg.subequip = data.subequip
        c_send(msg)
    end
end

function tabgemremove_delegate_removemain()
    local equip, gemindex, subgemindex = tabgemremove_getselectgem()
    if gemindex <= 0 or gemindex > #equip.gem then
        return
    end
    local config_item = csvitem_getfromid(equip.gem[gemindex])
    if config_item == nil then
        return
    end
    local message = c_textformat("LAB_GEMREMOVE_TIPS_CONFIRM", gemindex, config_item.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    data.gemindex = gemindex
    data.subequip = 0
    messagebox_confirm(message, tabgemremove_confirm, data)
end

function tabgemremove_delegate_removesub()
    local equip, gemindex, subgemindex = tabgemremove_getselectgem()
    if subgemindex <= 0 or subgemindex > #equip.subgem then
        return
    end
    local config_item = csvitem_getfromid(equip.subgem[subgemindex])
    if config_item == nil then
        return
    end
    local message = c_textformat("LAB_GEMREMOVE_TIPS_SUBCONFIRM", subgemindex, config_item.name)
    local data = {}
    data.npcactorid = m_equiplabmain.npcactorid
    data.equipuuid = m_equiplabmain.equipuuid
    data.gemindex = subgemindex
    data.subequip = 1
    messagebox_confirm(message, tabgemremove_confirm, data)
end
