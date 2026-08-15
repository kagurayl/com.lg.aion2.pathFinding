
local m_iccstorage_maxspace = 120
local m_iccstorage_lineitemcount = 6

local m_iccstorage_inst = {item = "bag/inst_iccstorage"}
m_uiiccstorage = uipanel_createhandle("bag/iccstorage", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft), AudioOpenUI, AudioCloseUI)

function iccstorage_onopen()
    local list_item = m_uiiccstorage:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    m_uiiccstorage:setwidgetdelegate("button_sort", iccstorage_delegate_sort)
    m_uiiccstorage:setwidgetdelegate("image_bg/button_close", iccstorage_delegate_close)
    event_register(eventtype.update, iccstorage_update, m_uiiccstorage)
end

function iccstorage_open(msg)
    bag_open()
    m_uiiccstorage:open()
    m_uiiccstorage.npcactorid = msg.actorid
    m_uiiccstorage.space = m_iccstorage_maxspace
    m_uiiccstorage.item = {}
    for i=1, m_uiiccstorage.space do
		m_uiiccstorage.item[i] = {itemid = 0, slot = i}
	end
	for i=1, #msg.item do
		local slot = msg.item[i].slot + 1
		if slot <= #m_uiiccstorage.item then
			playeritem_copy(m_uiiccstorage.item[slot], msg.item[i].attr)
		end
	end
    m_uiiccstorage.slot = {}
    iccstorage_updateui()
end

function iccstorage_getitem()
    if m_uiiccstorage:alive() then
        return m_uiiccstorage.item
    else
        return nil
    end
end

function iccstorage_updateui()
    if m_uiiccstorage:null() then
        return
    end

    local fillcount = 0
    for i=1,#m_uiiccstorage.item do
        local item = m_uiiccstorage.item[i]
        if item.itemid ~= 0 then
            fillcount = fillcount + 1
        end
    end
    local text_space = m_uiiccstorage:getwidget("text_space")
    text_space:settext(string.format("%d/%d", fillcount, m_uiiccstorage.space))

    local list_item = m_uiiccstorage:getwidget("list_item")
    m_uiiccstorage.slot = itemcontainer_createlist(m_uiiccstorage.space, m_uiiccstorage.item, list_item, m_iccstorage_inst.item
                                                , m_iccstorage_lineitemcount, iccstorage_delegate_icon)
end

function iccstorage_update()
    for i=1,# m_uiiccstorage.slot do
        itemcontainer_updatecd(m_uiiccstorage.slot[i])
    end
end

function iccstorage_itemmenu_delegate_getitem(data)
    local msg = {messageid="CS_IccStorageToBag"}
    msg.actorid = m_uiiccstorage.npcactorid
    msg.uuid = data.uuid
    c_send(msg)
end

function iccstorage_setmenu(itemuuid)
    local item = nil
    for i=1,#m_uiiccstorage.item do
        if m_uiiccstorage.item[i].itemid ~= 0 and m_uiiccstorage.item[i].uuid == itemuuid then
            item = m_uiiccstorage.item[i]
            break
        end
    end
    if item == nil then
        return
    end

    local data = {}
    data.uuid = itemuuid
    itemmenu_reset(data)
    itemmenu_addbutton("STORAGE_MENU_GETITEM", iccstorage_itemmenu_delegate_getitem)

    local image_bg = m_uiiccstorage:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    local menux = x + w
    local menuy = y + h / 2 + itemmenu_getheight() / 2
    itemmenu_open(menux, menuy, m_uiiccstorage)

    tips_item(item.itemid, item.count, menux + itemmenu_getwidth(), -1, tipsflag.vright, item, m_uiiccstorage)
end

function iccstorage_delegate_icon(sender, event)
    if sender.itemuuid ~= nil then
        iccstorage_setmenu(sender.itemuuid)
    end
end

function iccstorage_delegate_sort()
    itemcontainer_sort(m_uiiccstorage.item, "CS_IccStorageMove", m_uiiccstorage.npcactorid)
end

function iccstorage_delegate_close()
    m_uiiccstorage:close()
end
