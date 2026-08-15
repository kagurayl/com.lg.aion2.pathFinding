
local m_uibag_obs = uipanel_createhandle("bag/obs", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_uibag_obs_inst = {item = "bag/inst_obs"}
local m_uibag_obs_id = {186000051,186000052,186000053,186000054,186000055,186000056,186000057,186000058
                        ,186000059,186000060,186000061,186000062,186000063,186000064,186000065,186000066}
local m_uibag_obs_pricelow = { 6400, 4800, 2400, 1200, 3200, 2400, 1600, 800, 2400, 1800, 1200, 600, 1200, 900, 600, 300 }
local m_uibag_obs_pricehigh = { 9600, 7200, 4800, 2400, 4800, 3600, 2400, 1200, 2400, 1800, 1200, 600, 1200, 900, 600, 300 }

function obs_onopen()
    m_uibag_obs:setwidgetdelegate("button_ok", obs_delegate_ok)
    m_uibag_obs:setwidgetdelegate("image_bg/button_close", obs_delegate_close)
    m_uibag_obs.item = {}

    local itemlist_sell = m_uibag_obs:getwidget("itemlist_sell")
    itemlist_sell:init(uilistflag.vertical)
    itemlist_sell:setclickdelegate(obs_delegate_selectsell)

    local itemlist_bag = m_uibag_obs:getwidget("itemlist_bag")
    itemlist_bag:init(uilistflag.vertical)
    itemlist_bag:setclickdelegate(obs_delegate_selectbag)

    event_register(eventtype.item, obs_updateui, m_uibag_obs)
end

function obs_open(actorid, fullobs)
    m_uibag_obs:open()
    m_uibag_obs.npcactorid = actorid
    m_uibag_obs.fullobs = fullobs
    m_uibag_obs:setwidgetvisiblenothit("text_off", fullobs == 0)
    obs_updateui()
end

function obs_reset()
    if m_uibag_obs:null() then
        return
    end
    m_uibag_obs.item = {}
    obs_updateui()
end

local function obs_getprice(itemid)
    for i=1,#m_uibag_obs_id do
        if itemid == m_uibag_obs_id[i] then
            if m_uibag_obs.fullobs == 0 then
                return m_uibag_obs_pricelow[i]
            else
                return m_uibag_obs_pricehigh[i]
            end
        end
    end
    return 0
end
function obs_updateui()
    if m_uibag_obs:null() then
        return
    end

    local itemlist_bag = m_uibag_obs:getwidget("itemlist_bag")
    itemlist_bag:savestate()
    itemlist_bag:clear()

    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and obs_getprice(item.itemid) > 0 then
                local sellcount = 0
                for j=1,#m_uibag_obs.item do
                    if m_uibag_obs.item[j].uuid == item.uuid then
                        sellcount = sellcount + m_uibag_obs.item[j].count
                    end
                end
                if item.count > sellcount then
                    local line = itemlist_bag:add(m_uibag_obs_inst.item, i, item.uuid)
                    local icon_item = line:getwidget("icon_item")
                    icon_item:seticon(config_item.icon)

                    local text_name = line:getwidget("text_name")
                    text_name:settext(config_item.name)

                    local text_count = line:getwidget("text_count")
                    text_count:settext(item.count - sellcount)
                end
            end
        end
    end
    itemlist_bag:restorestate()

    local itemlist_sell = m_uibag_obs:getwidget("itemlist_sell")
    itemlist_sell:savestate()
    itemlist_sell:clear()

    local totalobs = 0
    for i=1,#m_uibag_obs.item do
        local item = m_uibag_obs.item[i]
        totalobs = totalobs + obs_getprice(item.itemid) * item.count
        local config_item = csvitem_getfromid(item.itemid)
        local line = itemlist_sell:add(m_uibag_obs_inst.item, i, item.uuid)
        local icon_item = line:getwidget("icon_item")
        icon_item:seticon(config_item.icon)

        local text_name = line:getwidget("text_name")
        text_name:settext(config_item.name)

        local text_count = line:getwidget("text_count")
        text_count:settext(item.count)
    end
    itemlist_sell:restorestate()

    local text_obstotal = m_uibag_obs:getwidget("text_obstotal")
    text_obstotal:settext(totalobs)
end

function obs_delegate_selectsell(line, event, data)
    for i=1,#m_uibag_obs.item do
        local item = m_uibag_obs.item[i]
        if item.uuid == data then
            item.count = item.count - 1
            if item.count == 0 then
                table.remove(m_uibag_obs.item, i)
            end
            obs_updateui()
            break
        end
    end
end

function obs_delegate_selectbag(line, event, data)
    for i=1,#playerattr_bag do
        local itembag = playerattr_bag[i]
        if itembag.itemid ~= 0 and itembag.uuid == data then
            local add = true
            for j=1,#m_uibag_obs.item do
                local itemsell = m_uibag_obs.item[j]
                if itemsell.uuid == data then
                    if itemsell.count < itembag.count then
                        itemsell.count = itemsell.count + 1
                    end
                    add = false
                    break
                end
            end
            if add then
                local itemsell = {}
                itemsell.itemid = itembag.itemid
                itemsell.uuid = itembag.uuid
                itemsell.count = itembag.count
                m_uibag_obs.item[#m_uibag_obs.item + 1] = itemsell
            end
            break
        end
    end
    obs_updateui()
end

function obs_delegate_ok()
    if #m_uibag_obs.item == 0 then
        return
    end
    local msg = {messageid="CS_ObsExchange"}
    msg.actorid = m_uibag_obs.npcactorid
    msg.uuid = {}
    msg.count = {}
    for i=1,#m_uibag_obs.item do
        local itemsell = m_uibag_obs.item[i]
        msg.uuid[#msg.uuid + 1] = itemsell.uuid
        msg.count[#msg.count + 1] = itemsell.count
    end
    c_send(msg)
end

function obs_delegate_close()
    m_uibag_obs:close()
end
