
local m_tabfeed_inst = {item = "pet/inst_petfeed"}

function tabfeed_onopen()
    m_uipet_menu:setwidgetdelegate("tab_feed/button_gift", tabfeed_delegate_gift)

    local list_item = m_uipet_menu:getwidget("tab_feed/list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(tabfeed_delegate_listitem)
end

local function tabfeed_isflavor(config_feed, config_item)
    if config_item == nil then
        return false
    end
    local flavor = config_item.flavor
    if flavor == nil or flavor == "0" then
        return false
    end
    local flavorcount = csvconfig_getsubcount(flavor)
    for i=1,flavorcount do
        local flavorid = csvconfig_getsubvalue(flavor, i, configsubtype.int)
        if flavorid ~= 0 then
            if config_feed.flavor == flavorid then
                return true
            end
            if m_uipet_menu.pet.flavorcount < config_feed.lovecount then
                if config_feed.flavor1 == flavorid
                or config_feed.flavor2 == flavorid
                or config_feed.flavor3 == flavorid
                or config_feed.flavor4 == flavorid then
                    return true
                end
            end
        end
    end
    return false
end

function tabfeed_updateui()
    if m_uipet_menu:null() then
        return
    end
    local lambda1 = m_uipet_menu.config_pet.skill1
    local lambda2 = m_uipet_menu.config_pet.skill2
    local config_feed = nil
    if lambda1 ~= nil and c_isaction(lambda1[1], "feed") then
        config_feed = csvpetfeed_getfromid(lambda1[1].variable[1].integer)
    elseif lambda2 ~= nil and c_isaction(lambda2[1], "feed") then
        config_feed = csvpetfeed_getfromid(lambda2[1].variable[1].integer)
    end
    if config_feed == nil then
        return
    end
    local list_item = m_uipet_menu:getwidget("tab_feed/list_item")
    list_item:savestate()
    list_item:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if tabfeed_isflavor(config_feed, config_item) then
                local line = list_item:add(m_tabfeed_inst.item, item.uuid, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)

                local text_name = line:getwidget("text_name")
                text_name:settextscale(string.format("%s(%d)", config_item.name, item.count))
                text_name:setcolor(csvitem_getfloatcolor(config_item))
            end
        end
    end
    list_item:restorestate()

    local text_noitem = m_uipet_menu:getwidget("tab_feed/text_noitem")
    text_noitem:setvisiblenothit(list_item:getcount() == 0)

    local text_progress = m_uipet_menu:getwidget("tab_feed/text_progress")
    text_progress:settext("PETMENU_FEED_PROGRESS", m_uipet_menu.pet.feedprogress / config_feed.feedcount * 100)

    local text_flavor1 = m_uipet_menu:getwidget("tab_feed/text_flavor1")
    if config_feed.flavor > 0 then
        text_flavor1:settext("PETMENU_FEED_FLAVOR1", "STR_FLAVOR_ID_" .. config_feed.flavor)
    else
        text_flavor1:settext("PETMENU_FEED_FLAVOR1NONE")
    end

    local flavorex = ""
    if config_feed.flavor1 > 0 then
        flavorex = flavorex .. c_textformat("STR_FLAVOR_ID_" .. config_feed.flavor1)
    end
    if config_feed.flavor2 > 0 then
        flavorex = flavorex .. c_textformat("UI_SPLIT") .. c_textformat("STR_FLAVOR_ID_" .. config_feed.flavor2)
    end
    if config_feed.flavor3 > 0 then
        flavorex = flavorex .. c_textformat("UI_SPLIT") .. c_textformat("STR_FLAVOR_ID_" .. config_feed.flavor3)
    end
    if config_feed.flavor3 > 0 then
        flavorex = flavorex .. c_textformat("UI_SPLIT") .. c_textformat("STR_FLAVOR_ID_" .. config_feed.flavor4)
    end
    local text_flavor2 = m_uipet_menu:getwidget("tab_feed/text_flavor2")
    if #flavorex > 0 and m_uipet_menu.pet.flavorcount < config_feed.lovecount then
        text_flavor2:settext("PETMENU_FEED_FLAVOR2", flavorex, config_feed.lovecount - m_uipet_menu.pet.flavorcount)
    else
        text_flavor2:settext("PETMENU_FEED_FLAVOR2NONE")
    end

    local button_gift = m_uipet_menu:getwidget("tab_feed/button_gift")
    button_gift:setenable(m_uipet_menu.pet.feedprogress >= config_feed.feedcount)
end

function tabfeed_delegate_input(data, count)
    if count > 0 then
        local msg = {messageid="CS_PetFeed"}
        msg.petuuid = m_uipet_menu.pet.uuid
        msg.itemuuid = data
        msg.count = count
        c_send(msg)
    end
end

function tabfeed_delegate_listitem(line, event, uuid)
    local item = playeritem_getfromuuid(uuid)
    if item ~= nil then
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            inputcount_show("PETMENU_FEED_INPUTCOUNT", config_item, item.count, item.count, tabfeed_delegate_input, uuid)
            inputcount_updateprice()
        end
    end
end

function tabfeed_delegate_gift(sender, event)
    local msg = {messageid="CS_PetGetFeedGift"}
    msg.uuid = m_uipet_menu.pet.uuid
    c_send(msg)
end
