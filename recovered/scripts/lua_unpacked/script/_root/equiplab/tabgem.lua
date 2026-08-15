
local m_tabgem_inst = {equip = "equiplab/inst_equip", item2 = "equiplab/inst_item2", text = "equiplab/inst_text"}

function tabgem_onopen()
    local list_stone = m_equiplabmain:getwidget("tab_gem/list_stone")
    list_stone:init(uilistflag.vertical)
    list_stone:setclickdelegate(tabgem_delegate_listitem_stone)

    local list_matter = m_equiplabmain:getwidget("tab_gem/list_matter")
    list_matter:init(uilistflag.vertical)
    list_matter:setclickdelegate(tabgem_delegate_listitem_matter)

    local button_ok = m_equiplabmain:getwidget("tab_gem/button_ok")
    button_ok:setdelegate(tabgem_delegate_ok)
    button_ok:setenablenofade(false)

    local checkbox_subweapon = m_equiplabmain:getwidget("tab_gem/checkbox_subweapon")
    checkbox_subweapon:setcheck(false)
end

function tabgem_addequip(list_equip, equip, config_item, itemname)
    local gemcount, gemmax = equip_getgemcount(equip.gem)
    local gemsubcount, gemsubmax = equip_getgemcount(equip.subgem)
    local gemenable = gemmax + gemsubmax > 0

    local line = list_equip:add(m_tabgem_inst.equip, equip.uuid, math.ternary(gemenable, equip.uuid, 0))
    line:setselectable(gemenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(gemenable)
    if gemenable then
        text_desc:settextscale("LAB_GEM_EQUIP_GEM", gemcount + gemsubcount, gemmax + gemsubmax)
    else
        text_desc:settextscale("LAB_GEM_EQUIP_DISABLE")
    end
end

local function tabgem_getselectstoneuuid()
    local list_stone = m_equiplabmain:getwidget("tab_gem/list_stone")
    local uuid = list_stone:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

local function tabgem_getselectmatteritemid()
    local list_matter = m_equiplabmain:getwidget("tab_gem/list_matter")
    local itemid = list_matter:getfirstselect()
    if itemid == nil then
        itemid = 0
    end
    return itemid
end

local function tabgem_updatestonelist()
    local gemlevel = 0
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if config_equip ~= nil then
        gemlevel = csvitem_getgemlevel(config_equip)
    end
    local list_stone = m_equiplabmain:getwidget("tab_gem/list_stone")
    list_stone:savestate()
    list_stone:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and config_item.itemtype == csvitemtype.consume_gem then
                local line = list_stone:add(m_tabgem_inst.item2, i, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)
        
                local text_name = line:getwidget("text_name")
                text_name:settextscale(string.format("%s(%d)", config_item.name, item.count))
                text_name:setcolor(csvitem_getfloatcolor(config_item))

                local text_desc = line:getwidget("text_desc")
                text_desc:settextscale(c_textformat("LAB_GEM_STONELEVEL", config_item.itemlevel))
                text_desc:setavailablecolor(config_item.itemlevel <= gemlevel)
            end
        end
    end
    list_stone:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_gem/text_nogem", list_stone:getcount() == 0)
end

local function tabsoul_addmatter(matterlist, config_equip, itemid)
    for i=1,#matterlist do
        if matterlist[i].id == itemid then
            return
        end
    end
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil or config_item.itemtype ~= csvitemtype.matter then
        if csvitem_getscript(config_item, "matter") == nil and csvitem_getscript(config_item, "mattergem") == nil then
            return
        end 
    end
    if config_equip.quality <= csvitemquality.blue then
        if config_item.quality > csvitemquality.blue then
            return
        end
    elseif config_equip.quality ~= config_item.quality then
        return
    end
    local matter = {}
    matter.id = itemid
    matter.config_item = config_item
    matter.count = playeritem_getcount(itemid)
    local lambda = csvitem_getscript(config_item, "matter")
    if lambda ~= nil and lambda.variable[1].integer >= 4 then
        matter.cost = 1
    else
        lambda = csvitem_getscript(config_item, "mattergem")
        if lambda ~= nil and lambda.variable[1].integer >= 4 then
            matter.cost = 1
        end
    end
    matterlist[#matterlist + 1] = matter
end

local function tabgem_updatematterlist()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local matterlist = {}
    if config_equip.quality <= csvitemquality.blue then
        tabsoul_addmatter(matterlist, config_equip, 166100002)
        tabsoul_addmatter(matterlist, config_equip, 166100001)
        tabsoul_addmatter(matterlist, config_equip, 166100000)
    elseif config_equip.quality == csvitemquality.yellow then
        tabsoul_addmatter(matterlist, config_equip, 166100005)
        tabsoul_addmatter(matterlist, config_equip, 166100004)
        tabsoul_addmatter(matterlist, config_equip, 166100003)
    elseif config_equip.quality == csvitemquality.red then
        tabsoul_addmatter(matterlist, config_equip, 166100008)
        tabsoul_addmatter(matterlist, config_equip, 166100007)
        tabsoul_addmatter(matterlist, config_equip, 166100006)
    end
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            tabsoul_addmatter(matterlist, config_equip, item.itemid)
        end
    end

    local mattercost = 0
    local stone = playeritem_getfromuuid(tabgem_getselectstoneuuid())
    if stone ~= nil then
        local config_stone = csvitem_getfromid(stone.itemid)
        if config_stone ~= nil then
            mattercost = config_stone.lambda[1].variable[1].integer
        end
    end

    local list_matter = m_equiplabmain:getwidget("tab_gem/list_matter")
    list_matter:savestate()
    list_matter:clear()
    local emptyline = list_matter:add(m_tabgem_inst.text, 0, 0)
    local text_desc = emptyline:getwidget("text_desc")
    text_desc:settext("LAB_GEM_NOTUSEMATTER")
    for i=1,#matterlist do
        local matter = matterlist[i]
        local line = list_matter:add(m_tabgem_inst.item2, i, matter.id)
        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(matter.config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(matter.config_item.name)
        text_name:setcolor(csvitem_getfloatcolor(matter.config_item))

        local cost = matter.cost
        if cost == nil then
            cost = mattercost
        end
        local available = cost <= matter.count and matter.count > 0
        local text_desc = line:getwidget("text_desc")
        text_desc:settextscale(string.format("%d/%d", matter.count, cost))
        text_desc:setavailablecolor(available)
        line:setselectable(available)
    end
    list_matter:restorestate()

    if list_matter:getfirstselect() == nil then
        list_matter:selectline(0)
    end
    
    local list_stone = m_equiplabmain:getwidget("tab_gem/list_stone")
    local button_ok = m_equiplabmain:getwidget("tab_gem/button_ok")
    button_ok:setenable(list_stone:getfirstselect() ~= nil)
end

function tabgem_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_GEM_TITLE")

    tabgem_updatestonelist()
    tabgem_updatematterlist()
end

function tabgem_delegate_listitem_stone(line, event, uuid)
    tabgem_updatematterlist()
end

function tabgem_delegate_listitem_matter(line, event, uuid)

end

function tabgem_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipGem"}
        msg.equipuuid = data.equipuuid
        msg.stoneuuid = data.stoneuuid
        msg.matterid = data.matterid
        msg.subequip = data.subequip
        c_send(msg)
    end
end

function tabgem_delegate_ok()
    local stoneuuid = tabgem_getselectstoneuuid()
    if stoneuuid == 0 then
        return
    end
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local checkbox_subweapon = m_equiplabmain:getwidget("tab_gem/checkbox_subweapon")
    local subequip = checkbox_subweapon:getcheck()
    local message = nil
    if subequip then
        message = c_textformat("LAB_GEM_SUBCONFIRM", config_equip.name)
    else
        message = c_textformat("LAB_GEM_CONFIRM", config_equip.name)
    end
    local data = {}
    data.equipuuid = m_equiplabmain.equipuuid
    data.stoneuuid = stoneuuid
    data.matterid = tabgem_getselectmatteritemid()
    data.subequip = math.ternary(subequip, 1, 0)
    messagebox_confirm(message, tabgem_confirm, data)
end
