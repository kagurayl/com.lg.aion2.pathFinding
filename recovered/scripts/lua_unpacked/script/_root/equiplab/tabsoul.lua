
local m_tabsoul_inst = {equip = "equiplab/inst_equip", item2 = "equiplab/inst_item2", item = "equiplab/inst_item", text = "equiplab/inst_text"}

function tabsoul_onopen()
    local list_stone = m_equiplabmain:getwidget("tab_soul/list_stone")
    list_stone:init(uilistflag.vertical)
    list_stone:setclickdelegate(tabsoul_delegate_listitem_stone)

    local list_matter = m_equiplabmain:getwidget("tab_soul/list_matter")
    list_matter:init(uilistflag.vertical)
    list_matter:setclickdelegate(tabsoul_delegate_listitem_matter)

    local button_ok = m_equiplabmain:getwidget("tab_soul/button_ok")
    button_ok:setdelegate(tabsoul_delegate_ok)
    button_ok:setenablenofade(false)
end

function tabsoul_addequip(list_equip, equip, config_item, itemname)
    local soulenable = config_item.soul ~= nil and config_item.soul > 0

    local line = list_equip:add(m_tabsoul_inst.equip, equip.uuid, math.ternary(soulenable, equip.uuid, 0))
    line:setselectable(soulenable)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(itemname)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_desc = line:getwidget("text_desc")
    text_desc:setavailablecolor(soulenable)
    if soulenable then
        text_desc:settextscale("LAB_SOUL_EQUIP_SOUL", equip.soul, config_item.soul)
    else
        text_desc:settextscale("LAB_SOUL_EQUIP_DISABLE")
    end
end

local function tabsoul_getselectstoneuuid()
    local list_stone = m_equiplabmain:getwidget("tab_soul/list_stone")
    local uuid = list_stone:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

local function tabsoul_getselectmatteritemid()
    local list_matter = m_equiplabmain:getwidget("tab_soul/list_matter")
    local itemid = list_matter:getfirstselect()
    if itemid == nil then
        itemid = 0
    end
    return itemid
end

local function tabsoul_updatestonelist()
    local list_stone = m_equiplabmain:getwidget("tab_soul/list_stone")
    list_stone:savestate()
    list_stone:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and config_item.itemtype == csvitemtype.consume_soul then
                local line = list_stone:add(m_tabsoul_inst.item, i, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)
        
                local text_name = line:getwidget("text_name")
                text_name:settextscale(string.format("%s(%d)", config_item.name, item.count))
                text_name:setcolor(csvitem_getfloatcolor(config_item))
            end
        end
    end
    list_stone:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_soul/text_nostone", list_stone:getcount() == 0)
end

local function tabsoul_addmatter(matterlist, config_equip, itemid)
    for i=1,#matterlist do
        if matterlist[i].id == itemid then
            return
        end
    end
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil or config_item.itemtype ~= csvitemtype.matter or csvitem_getscript(config_item, "matter") == nil then
        return
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
    matterlist[#matterlist + 1] = matter
end

local function tabsoul_updatematterlist()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    
    local mattercost = 0
    local stone = playeritem_getfromuuid(tabsoul_getselectstoneuuid())
    if stone ~= nil then
        local config_stone = csvitem_getfromid(stone.itemid)
        if config_stone ~= nil then
            mattercost = config_stone.lambda[1].variable[1].integer
        end
    end

    local matterlist = {}
    if mattercost > 0 then
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
    end

    local list_matter = m_equiplabmain:getwidget("tab_soul/list_matter")
    list_matter:savestate()
    list_matter:clear()
    local emptyline = list_matter:add(m_tabsoul_inst.text, 0, 0)
    local text_desc = emptyline:getwidget("text_desc")
    text_desc:settext("LAB_SOUL_NOTUSEMATTER")
    for i=1,#matterlist do
        local matter = matterlist[i]
        local line = list_matter:add(m_tabsoul_inst.item2, i, matter.id)
        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(matter.config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(matter.config_item.name)
        text_name:setcolor(csvitem_getfloatcolor(matter.config_item))

        local available = mattercost <= matter.count and matter.count > 0
        local text_desc = line:getwidget("text_desc")
        text_desc:settextscale(string.format("%d/%d", matter.count, mattercost))
        text_desc:setavailablecolor(available)
        line:setselectable(available)
    end
    list_matter:restorestate()

    if list_matter:getfirstselect() == nil then
        list_matter:selectline(0)
    end
    local list_stone = m_equiplabmain:getwidget("tab_soul/list_stone")
    local button_ok = m_equiplabmain:getwidget("tab_soul/button_ok")
    button_ok:setenable(list_stone:getfirstselect() ~= nil)
end

function tabsoul_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_SOUL_TITLE")

    tabsoul_updatestonelist()
    tabsoul_updatematterlist()
end

function tabsoul_delegate_listitem_stone(line, event, uuid)
    tabsoul_updatematterlist()
end

function tabsoul_delegate_listitem_matter(line, event, uuid)

end

function tabsoul_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipSoul"}
        msg.equipuuid = data.equipuuid
        msg.stoneuuid = data.stoneuuid
        msg.matterid = data.matterid
        c_send(msg)
    end
end

function tabsoul_delegate_ok()
    local stoneuuid = tabsoul_getselectstoneuuid()
    if stoneuuid == 0 then
        return
    end
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local message = nil
    if equip.soul ~= nil and equip.soul > 10 then
        message = c_textformat("LAB_SOUL_CONFIRM2", config_equip.name)
    else
        message = c_textformat("LAB_SOUL_CONFIRM1", config_equip.name)
    end
    local data = {}
    data.equipuuid = m_equiplabmain.equipuuid
    data.stoneuuid = stoneuuid
    data.matterid = tabsoul_getselectmatteritemid()
    messagebox_confirm(message, tabsoul_confirm, data)
end
