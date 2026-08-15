
local m_uinpc_pickitem_inst = {item = "npc/inst_pickitem"}
local m_uinpc_pickitem = uipanel_createhandle("npc/pickitem", uilayer.normal, uiflag.escapeclose, AudioOpenUI, AudioCloseUI)

function pickitem_onopen()
    m_uinpc_pickitem:setwidgetdelegate("button_pickall", pickitem_delegate_pickall)
    m_uinpc_pickitem:setwidgetdelegate("image_bg/button_close", pickitem_delegate_close)
    local list_content = m_uinpc_pickitem:getwidget("list_content")
    list_content:init(uilistflag.vertical)
    list_content:setclickdelegate(pickitem_delegate_listitem)
end

function pickitem_onclose()
    if m_uinpc_pickitem.npcactorid ~= nil then
        local msg = {messageid="CS_NPCQueryDropFinish"}
        msg.actorid = m_uinpc_pickitem.npcactorid
        c_send(msg)
    end
end

function pickitem_closefromserver()
    m_uinpc_pickitem.npcactorid = nil
    m_uinpc_pickitem:close()
end

function pickitem_close()
    m_uinpc_pickitem:close()
end

function pickitem_query(actorid)
    if m_uinpc_pickitem:alive() and m_uinpc_pickitem.npcactorid == actorid then
        pickitem_delegate_pickall()
    else
        local msg = {messageid="CS_NPCQueryDrop"}
        msg.actorid = actorid
        c_send(msg)
    end
end

function pickitem_setnpc(npc, itemarray)
    m_uinpc_pickitem:open()
    m_uinpc_pickitem.npcactorid = npc.actorid
    m_uinpc_pickitem.itemarray = itemarray

    local text_title = m_uinpc_pickitem:getwidget("image_bg/text_title")
    text_title:settext(npc.config_npc.name)

    local list_content = m_uinpc_pickitem:getwidget("list_content")
    list_content:clear()

    for i=1,#itemarray do
        pickitem_additem(itemarray[i].itemid, itemarray[i].itemcount, itemarray[i].pickid)
    end
end

function pickitem_removeitem(npc, pickid)
    if m_uinpc_pickitem:null() or m_uinpc_pickitem.npcactorid ~= npc.actorid then
        return
    end
    local itemarray = m_uinpc_pickitem.itemarray
    for i=1,#itemarray do
        if itemarray[i].pickid == pickid then
            table.remove(itemarray, i)
            break
        end
    end
    if #itemarray == 0 then
        pickitem_close()
        return
    end
    local list_content = m_uinpc_pickitem:getwidget("list_content")
    list_content:savestate()
    list_content:clear()
    for i=1,#itemarray do
        pickitem_additem(itemarray[i].itemid, itemarray[i].itemcount, itemarray[i].pickid)
    end
    list_content:restorestate()
end

function pickitem_additem(itemid, itemcount, pickid)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    local list_content = m_uinpc_pickitem:getwidget("list_content")
    local line = list_content:add(m_uinpc_pickitem_inst.item, pickid, pickid)

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_item.icon)

    local text_name = line:getwidget("text_name")
    text_name:settext(config_item.name)
    text_name:setcolor(csvitem_getfloatcolor(config_item))

    local text_count = line:getwidget("text_count")
    text_count:settext(itemcount)
end

function pickitem_delegate_listitem(line, event, pickid)
    local msg = {messageid="CS_NPCPickDrop"}
    msg.actorid = m_uinpc_pickitem.npcactorid
    msg.pickid = pickid
    c_send(msg)
end

function pickitem_delegate_pickall()
    local msg = {messageid="CS_NPCPickDropAll"}
    msg.actorid = m_uinpc_pickitem.npcactorid
    c_send(msg)
end

function pickitem_delegate_close()
    pickitem_close()
end
