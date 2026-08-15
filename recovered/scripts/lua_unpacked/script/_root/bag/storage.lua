
local m_storage_maxspace = 108
local m_storage_lineitemcount = 6

local m_storage_inst = {item = "bag/inst_storage"}
m_uistorage = uipanel_createhandle("bag/storage", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft), AudioOpenUI, AudioCloseUI)

function storage_onopen()
    local list_item = m_uistorage:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    m_uistorage:setwidgetdelegate("button_sort", storage_delegate_sort)
    m_uistorage:setwidgetdelegate("button_extend", storage_delegate_extend)
    m_uistorage:setwidgetdelegate("button_putcoin", storage_delegate_putcoin)
    m_uistorage:setwidgetdelegate("button_getcoin", storage_delegate_getcoin)
    m_uistorage:setwidgetdelegate("image_bg/button_close", storage_delegate_close)
    event_register(eventtype.update, storage_update, m_uistorage)
end

function storage_open(msg)
    bag_open()
    m_uistorage:open()
    m_uistorage.npcactorid = msg.actorid
    m_uistorage.coin = msg.coin
    m_uistorage.space = msg.space
    m_uistorage.spacelevel = msg.spacelevel
    m_uistorage.item = {}
    for i=1, m_uistorage.space do
		m_uistorage.item[i] = {itemid = 0, slot = i}
	end
	for i=1, #msg.item do
		local slot = msg.item[i].slot + 1
		if slot <= #m_uistorage.item then
			playeritem_copy(m_uistorage.item[slot], msg.item[i].attr)
		end
	end
    m_uistorage.slot = {}
    storage_updateui()
end

function storage_getitem()
    if m_uistorage:alive() then
        return m_uistorage.item
    else
        return nil
    end
end

function storage_updatespace(msg)
    if m_uistorage:alive() then
        m_uistorage.space = msg.space
        m_uistorage.spacelevel = msg.spacelevel
        for i=#m_uistorage.item + 1, m_uistorage.space do
            m_uistorage.item[i] = {itemid = 0, slot = i}
        end
        storage_updateui()
    end
end

function storage_updatecoin(coin)
    if m_uistorage:alive() then
        m_uistorage.coin = coin
        storage_updateui()
    end
end

function storage_updateui()
    if m_uistorage:null() then
        return
    end
    local text_coin = m_uistorage:getwidget("text_coin")
    text_coin:settext(m_uistorage.coin)

    local fillcount = 0
    for i=1,#m_uistorage.item do
        local item = m_uistorage.item[i]
        if item.itemid ~= 0 then
            fillcount = fillcount + 1
        end
    end
    local text_space = m_uistorage:getwidget("text_space")
    text_space:settext(string.format("%d/%d", fillcount, m_uistorage.space))

    local list_item = m_uistorage:getwidget("list_item")
    m_uistorage.slot = itemcontainer_createlist(m_uistorage.space, m_uistorage.item, list_item, m_storage_inst.item
                                                , m_storage_lineitemcount, storage_delegate_icon)
end

function storage_update()
    for i=1,# m_uistorage.slot do
        itemcontainer_updatecd(m_uistorage.slot[i])
    end
end

function storage_itemmenu_delegate_getitem(data)
    local msg = {messageid="CS_StorageToBag"}
    msg.actorid = m_uistorage.npcactorid
    msg.uuid = data.uuid
    c_send(msg)
end

function storage_setmenu(itemuuid)
    local item = nil
    for i=1,#m_uistorage.item do
        if m_uistorage.item[i].itemid ~= 0 and m_uistorage.item[i].uuid == itemuuid then
            item = m_uistorage.item[i]
            break
        end
    end
    if item == nil then
        return
    end

    local data = {}
    data.uuid = itemuuid
    itemmenu_reset(data)
    itemmenu_addbutton("STORAGE_MENU_GETITEM", storage_itemmenu_delegate_getitem)

    local image_bg = m_uistorage:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    local menux = x + w
    local menuy = y + h / 2 + itemmenu_getheight() / 2
    itemmenu_open(menux, menuy, m_uistorage)

    tips_item(item.itemid, item.count, menux + itemmenu_getwidth(), -1, tipsflag.vright, item, m_uistorage)
end

function storage_delegate_icon(sender, event)
    if sender.itemuuid ~= nil then
        storage_setmenu(sender.itemuuid)
    end
end

function storage_delegate_sort()
    itemcontainer_sort(m_uistorage.item, "CS_StorageMove", m_uistorage.npcactorid)
end

function storage_extend_confirm(ok, data)
    if ok and m_uistorage:alive() then
        local msg = {messageid="CS_StorageExtend"}
        msg.actorid = m_uistorage.npcactorid
        msg.level = m_uistorage.spacelevel
        c_send(msg)
    end
end
function storage_delegate_extend()
    local npc = actormanager_getfromactorid(m_uistorage.npcactorid)
    if npc ~= nil then
        local lambda = csvnpc_getscript(npc.config_npc, "storage")
        if lambda ~= nil then
            local price =
            {
                1200, 24000, 72600, 181500, 363000, 1422000, 2844000, 5688000, 11376000, 21376000, 31376000,
                31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000,
                31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000, 31376000
            }
            if m_uistorage.spacelevel < #price then
                local text = c_textformat("STORAGE_EXTEND_CONFIRM", price[m_uistorage.spacelevel + 1])
                messagebox_confirm(text, storage_extend_confirm, m_uistorage.npcactorid)
            else
                chat_addsystemalert("STORAGE_EXTEND_FULL")
            end
        end
    end
end

function storage_putcoin_confirm(text)
    local coin = string.tointeger(text)
    if coin ~= nil and coin > 0 then
        local msg = {messageid="CS_StoragePutCoin"}
        msg.actorid = m_uistorage.npcactorid
        msg.coin = coin
        c_send(msg)
    end
end
function storage_delegate_putcoin()
    inputline_show(uiedittype.integer, "STORAGE_TITLE_PUTCOIN", playerattr_info.coin, storage_putcoin_confirm)
end

function storage_getcoin_confirm(text)
    local coin = string.tointeger(text)
    if coin ~= nil and coin > 0 then
        local msg = {messageid="CS_StorageGetCoin"}
        msg.actorid = m_uistorage.npcactorid
        msg.coin = coin
        c_send(msg)
    end
end
function storage_delegate_getcoin()
    inputline_show(uiedittype.integer, "STORAGE_TITLE_GETCOIN", m_uistorage.coin, storage_getcoin_confirm)
end

function storage_delegate_close()
    m_uistorage:close()
end
