
local dealstate = 
{
    idle = 1,
    lock = 2,
    submit = 3,
}

local m_shop_playerdeal = uipanel_createhandle("shop/player_deal", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_shop_deal_inst = {item = "shop/inst_deal", additem = "shop/inst_dealadditem"}
local m_shop_deal_stateme = nil
local m_shop_deal_statesucker = nil
local m_shop_deal_listmine = nil
local m_shop_deal_listsucker = nil
local m_shop_deal_item = nil
local m_shop_deal_item_max = 10

local function playerdeal_updatebutton()
    local button_lock = m_shop_playerdeal:getwidget("button_lock")
    button_lock:setenable(m_shop_deal_stateme == dealstate.idle)

    local button_ok = m_shop_playerdeal:getwidget("button_ok")
    button_ok:setenable(m_shop_deal_stateme == dealstate.lock and m_shop_deal_statesucker ~= dealstate.idle)
end

function player_deal_onopen()
    m_shop_playerdeal:setwidgetdelegate("button_lock", playerdeal_delegate_lock)
    m_shop_playerdeal:setwidgetdelegate("button_ok", playerdeal_delegate_submit)
    m_shop_playerdeal:setwidgetdelegate("image_bg/button_close", playerdeal_delegate_close)

    local itemlist_mine = m_shop_playerdeal:getwidget("itemlist_mine")
    itemlist_mine:init(uilistflag.vertical)

    local itemlist_sucker = m_shop_playerdeal:getwidget("itemlist_sucker")
    itemlist_sucker:init(uilistflag.vertical)
end

function player_deal_onclose()
    local msg = {messageid="CS_DealCancel"}
    c_send(msg)
end

function playerdeal_opendeal(msg)
    m_shop_playerdeal:open()

    local text_namemine = m_shop_playerdeal:getwidget("text_namemine")
    text_namemine:settext(playerattr_info.name)

    local text_namesucker = m_shop_playerdeal:getwidget("text_namesucker")
    text_namesucker:settext(msg.name)

    local edit_coinmine = m_shop_playerdeal:getwidget("edit_coinmine")
    edit_coinmine:setdelegate(playerdeal_delegate_editcoin)
    edit_coinmine:settext("0")
    
    local itemlist_mine = m_shop_playerdeal:getwidget("itemlist_mine")
    itemlist_mine:clear()

    local text_coinsucker = m_shop_playerdeal:getwidget("text_coinsucker")
    text_coinsucker:settext("0")

    local itemlist_sucker = m_shop_playerdeal:getwidget("itemlist_sucker")
    itemlist_sucker:clear()

    m_shop_deal_stateme = dealstate.idle
    m_shop_deal_statesucker = dealstate.idle
    m_shop_deal_item = {}
    m_shop_deal_listmine = {}
    m_shop_deal_listsucker = {}
    playerdeal_updatebutton()
    playerdeal_updatemineitem()
end

function playerdeal_updatemineitem()
    if m_shop_playerdeal:null() then
        return
    end
    local listitem = m_shop_playerdeal:getwidget("itemlist_mine")
    listitem:savestate()
    listitem:clear()
    for i=1,#m_shop_deal_item do
        local item = m_shop_deal_item[i]
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            local line = listitem:add(m_shop_deal_inst.item)
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_count = line:getwidget("text_count")
            text_count:settext(item.count)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)
        end
    end
    if #m_shop_deal_item < m_shop_deal_item_max then
        local line = listitem:add(m_shop_deal_inst.additem)
        local button_additem = line:getwidget("button_additem")
        button_additem:setdelegate(playerdeal_delegate_additem)
    end
    listitem:restorestate()
end

function playerdeal_updatesuckeritem()
    if m_shop_playerdeal:null() then
        return
    end
    local listitem = m_shop_playerdeal:getwidget("itemlist_sucker")
    listitem:savestate()
    listitem:clear()
    for i=1,#m_shop_deal_listsucker do
        local item = m_shop_deal_listsucker[i]
        local config_item = csvitem_getfromid(item.itemid)
        if config_item ~= nil then
            local line = listitem:add(m_shop_deal_inst.item)
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)

            local text_count = line:getwidget("text_count")
            text_count:settext(item.count)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)
        end
    end
    listitem:restorestate()
end

function playerdeal_onput(msg)
    if m_shop_playerdeal:null() then
        return
    end
    if playerattr_info.actorid == msg.playerid then
        m_shop_deal_item[#m_shop_deal_item + 1] = msg.item
        playerdeal_updatemineitem()
    else
        m_shop_deal_listsucker[#m_shop_deal_listsucker + 1] = msg.item
        playerdeal_updatesuckeritem()
    end
end

function playerdeal_onlock(msg)
    if m_shop_playerdeal:null() then
        return
    end
    if playerattr_info.actorid == msg.playerid then
        m_shop_deal_stateme = dealstate.lock
        local edit_coinmine = m_shop_playerdeal:getwidget("edit_coinmine")
        edit_coinmine:settext(msg.coin)
        edit_coinmine:setenable(false)
    else
        m_shop_deal_statesucker = dealstate.lock
        local text_coinsucker = m_shop_playerdeal:getwidget("text_coinsucker")
        text_coinsucker:settext(msg.coin)
    end
    playerdeal_updatebutton()
    audiomanager_playaudioui(AudioTradeConfirm)
end

function playerdeal_onsubmit(msg)
    if m_shop_playerdeal:null() then
        return
    end
    if playerattr_info.actorid == msg.playerid then
        m_shop_deal_stateme = dealstate.submit
    else
        m_shop_deal_statesucker = dealstate.submit
    end
    playerdeal_updatebutton()
end

function playerdeal_oncomplete(msg)
    m_shop_playerdeal:close()
end

function playerdeal_oncancel(msg)
    if m_shop_playerdeal:alive() then
        if playerattr_info.actorid == msg.playerid then
            chat_addsystemalert("PLAYER_DEAL_CANCELME")
        else
            chat_addsystemalert("PLAYER_DEAL_CANCELSUCKER")
        end
        m_shop_playerdeal:close()
    end
end

function playerdeal_delegate_editcoin(sender, event)
    if event.name == "submit" or event.name == "textchanged" then
        sender:setverifyinteger(0, playerattr_info.coin)
    end
end

function playerdeal_delegate_lock()
    local edit_coinmine = m_shop_playerdeal:getwidget("edit_coinmine")
    local msg = {messageid="CS_DealLock"}
    msg.coin = string.tointeger(edit_coinmine:gettext())
    c_send(msg)
end

function playerdeal_delegate_submit()
    local msg = {messageid="CS_DealSubmit"}
    c_send(msg)
end

function playerdeal_delegate_close()
    m_shop_playerdeal:close()
end

function playerdeal_delegate_filteritemitem(item)
    for i=1,#m_shop_deal_item do
        if item.uuid == m_shop_deal_item[i].uuid then
            return false
        end
    end
    return playeritem_getitemdeal(item)
end
function playerdeal_delegate_inputitem(item, count)
    if count > 0 then
        local msg = {messageid="CS_DealPut"}
        msg.uuid = item.uuid
        msg.count = count
        c_send(msg)
    end
end
function playerdeal_delegate_additem()
    selectitem_show("PLAYER_DEAL_ADDITEM", "PLAYER_DEAL_INPUTCOUNT", selectitemcount.count, selectitemflag.bag, playerdeal_delegate_filteritemitem, playerdeal_delegate_inputitem)
end
