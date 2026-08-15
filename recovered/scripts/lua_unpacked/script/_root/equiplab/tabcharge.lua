
local m_tabcharge_inst = {equip = "equiplab/inst_equip", equipcharge = "equiplab/inst_equipcharge", item2 = "equiplab/inst_item2"}

function tabcharge_onopen()
    local list_charger = m_equiplabmain:getwidget("tab_charge/list_charger")
    list_charger:init(uilistflag.vertical)
    list_charger:setclickdelegate(tabcharge_delegate_listitem_charger)

    local button_ok = m_equiplabmain:getwidget("tab_charge/button_ok")
    button_ok:setdelegate(tabcharge_delegate_ok)
    button_ok:setenablenofade(false)
end

function tabcharge_addequip(list_equip, equip, config_item, itemname)
    local chargeenable = config_item.charge ~= nil and config_item.charge ~= "0"
    if chargeenable then
        local line = list_equip:add(m_tabcharge_inst.equipcharge, equip.uuid, equip.uuid)

        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(itemname)
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local progress_level1 = line:getwidget("progress_level1")
        local progress_level2 = line:getwidget("progress_level2")
        equip_setchargeprogress(progress_level1, progress_level2, equip.capacity)
    else
        local line = list_equip:add(m_tabcharge_inst.equip)
        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settextscale(itemname)
        text_name:setcolor(csvitem_getfloatcolor(config_item))

        local text_desc = line:getwidget("text_desc")
        text_desc:setavailablecolor(chargeenable)
        text_desc:settextscale("LAB_ITEMCHARGE_CHARGEDISABLE")
    end
end

local function tabsoul_getselectchargeruuid()
    local list_charger = m_equiplabmain:getwidget("tab_charge/list_charger")
    local uuid = list_charger:getfirstselect()
    if uuid == nil then
        uuid = 0
    end
    return uuid
end

local function tabcharge_updatechargerlist()
    local list_charger = m_equiplabmain:getwidget("tab_charge/list_charger")
    list_charger:savestate()
    list_charger:clear()

    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item.itemtype == csvitemtype.consume_charger then
                local lambda = csvitem_getscript(config_item, "charge")
                if lambda ~= nil and lambda.variable[1].integer == 0 then
                    local line = list_charger:add(m_tabcharge_inst.item2, i, item.uuid)
                    local image_icon = line:getwidget("image_icon")
                    image_icon:seticon(config_item.icon)

                    local text_name = line:getwidget("text_name")
                    text_name:settextscale(config_item.name)
                    text_name:setcolor(csvitem_getfloatcolor(config_item))

                    local text_desc = line:getwidget("text_desc")
                    text_desc:settext(string.format("%d/1", item.count))
                end
            end
        end
    end

    list_charger:restorestate()
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/text_nocharger", list_charger:getcount() == 0)    
end

local function tabcharge_setequipstatevisible(visible)
    local button_ok = m_equiplabmain:getwidget("tab_charge/button_ok")
    button_ok:setenable(visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/text_currentstate", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_currentstatebg", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_currentstatelevel1", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_currentstatelevel2", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/text_chargestate", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_chargestatebg", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_chargestatelevel1", visible)
    m_equiplabmain:setwidgetvisiblenothit("tab_charge/progress_chargestatelevel2", visible)
end

local function tabcharge_updateequipstate()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        tabcharge_setequipstatevisible(false)
        return
    end
    local chargeenable = config_equip.charge ~= nil and config_equip.charge ~= "0"
    if not chargeenable then
        tabcharge_setequipstatevisible(false)
        return
    end
    local charger, config_charger = playeritem_getitemconfigfromuuid(tabsoul_getselectchargeruuid())
    if charger == nil or config_charger == nil then
        tabcharge_setequipstatevisible(false)
        return
    end
    local lambda = csvitem_getscript(config_charger, "charge")
    if lambda == nil then
        tabcharge_setequipstatevisible(false)
        return
    end
    tabcharge_setequipstatevisible(true)
    local equipchargelevel = csvconfig_getsubvalue(config_equip.charge, 1, configsubtype.int)
    local chargelevel = lambda.variable[2].integer

    local progress_currentstatelevel1 = m_equiplabmain:getwidget("tab_charge/progress_currentstatelevel1")
    local progress_currentstatelevel2 = m_equiplabmain:getwidget("tab_charge/progress_currentstatelevel2")
    equip_setchargeprogress(progress_currentstatelevel1, progress_currentstatelevel2, equip.capacity)

    local capacity = 0
    if chargelevel == 2 and equipchargelevel >= 2 then
        capacity = charge_level2
    else
        capacity = charge_level1
    end
    local progress_chargestatelevel1 = m_equiplabmain:getwidget("tab_charge/progress_chargestatelevel1")
    local progress_chargestatelevel2 = m_equiplabmain:getwidget("tab_charge/progress_chargestatelevel2")
    equip_setchargeprogress(progress_chargestatelevel1, progress_chargestatelevel2, capacity)
end

function tabcharge_updateui()
    local text_title = m_equiplabmain:getwidget("image_bg/text_title")
    text_title:settext("LAB_ITEMCHARGE_TITLE")

    tabcharge_updatechargerlist()
    tabcharge_updateequipstate()
end

function tabcharge_delegate_listitem_charger(line, event, uuid)
    tabcharge_updateequipstate()
end

function tabcharge_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_EquipCharge"}
        msg.equipuuid = data.equipuuid
        msg.itemuuid = data.chargeruuid
        c_send(msg)
    end
end

function tabcharge_delegate_ok()
    local equip, config_equip = playeritem_getitemconfigfromuuid(m_equiplabmain.equipuuid)
    if equip == nil or config_equip == nil then
        return
    end
    local uuid = tabsoul_getselectchargeruuid()
    if uuid == 0 then
        return
    end
    local charger, config_charger = playeritem_getitemconfigfromuuid(uuid)
    if charger == nil or config_charger == nil then
        return
    end
    local message = c_textformat("LAB_ITEMCHARGE_TIPS_CONFIRM", config_charger.name, config_equip.name)
    local data = {}
    data.equipuuid = m_equiplabmain.equipuuid
    data.chargeruuid = uuid
    messagebox_confirm(message, tabcharge_confirm, data)
end
