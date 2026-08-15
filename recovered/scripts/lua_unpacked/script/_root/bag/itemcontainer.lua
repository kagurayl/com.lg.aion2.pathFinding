
function itemcontainer_createslot(index, config_item, image_cd, text_cd)
    local slot = {}
    slot.image_cd = image_cd
    slot.text_cd = text_cd
    slot.image_cd:setvisiblenothit(false)
    slot.text_cd:setvisiblenothit(false)
    slot.config_item = config_item
    slot.cdcovervisible = false
    slot.cdtextvisible = false
    slot.itemslot = index
    return slot
end

local function itemcontainer_cleargrid(line, gridindex)
    local image_iconroot = line:getwidget(string.format("icon_%d", gridindex))
    image_iconroot.itemuuid = nil

    local text_count = line:getwidget(string.format("icon_%d/text_count", gridindex))
    text_count:settext("")

    local image_icon = line:getwidget(string.format("icon_%d/image_icon", gridindex))
    image_icon:setvisiblenothit(false)

    line:setwidgetvisiblenothit(string.format("icon_%d/image_cd", gridindex), false)
    line:setwidgetvisiblenothit(string.format("icon_%d/text_cd", gridindex), false)
    line:setwidgetvisiblenothit(string.format("icon_%d/image_itemlock", gridindex), false)
    line:setwidgetvisiblenothit(string.format("icon_%d/image_lock", gridindex), true)
end

function itemcontainer_createlist(playerspace, containeritem, list_item, lineinst, colcount, delegate)
    local slotarray = {}
    local uispace = playerspace
    for i=playerspace + 1,#containeritem do
        local item = containeritem[i]
        if item ~= nil and item.itemid ~= 0 then
            uispace = i
        end
    end
    list_item:savestate()
    list_item:clear()
    for itemslot=1, uispace do
        local lineindex = math.floor((itemslot - 1) / colcount) + 1
        local gridindex = (itemslot - 1) % colcount + 1
        local line = list_item:getlinefromindex(lineindex)
        if line == nil then
            line = list_item:add(lineinst)
            for i=1, colcount do
                itemcontainer_cleargrid(line, i)
            end
        end
        local config_item = nil
        local item = containeritem[itemslot]
        if item ~= nil and item.itemid ~= 0 then
            config_item = csvitem_getfromid(item.itemid)
        end
        if config_item ~= nil then
            local image_iconroot = line:getwidget(string.format("icon_%d", gridindex))
            image_iconroot.itemuuid = item.uuid
            image_iconroot:setdelegate(delegate)

            local text_count = line:getwidget(string.format("icon_%d/text_count", gridindex))
            if item.count > 1 then
                text_count:setvisiblenothit(true)
                text_count:settext(item.count)
            else
                text_count:setvisiblenothit(false)
                text_count:settext(item.count)
            end

            local image_icon = line:getwidget(string.format("icon_%d/image_icon", gridindex))
            image_icon:setvisiblenothit(true)
            image_icon:seticon(config_item.icon)

            local image_cd = line:getwidget(string.format("icon_%d/image_cd", gridindex))
            local text_cd = line:getwidget(string.format("icon_%d/text_cd", gridindex))
            local slot = itemcontainer_createslot(itemslot, config_item, image_cd, text_cd)
            itemcontainer_updatecd(slot)
            slotarray[#slotarray + 1] = slot
        end
        if itemslot <= playerspace or config_item ~= nil then
            line:setwidgetvisiblenothit(string.format("icon_%d/image_lock", gridindex), false)
        end
        line:setwidgetvisiblenothit(string.format("icon_%d/image_itemlock", gridindex), item ~= nil and item.itemid ~= 0 and item.itemlock ~= nil and item.itemlock > 0)
	end

    local listsize = list_item:getlistsize()
    while list_item._contentsize < listsize do
        local line = list_item:add(lineinst)
        for i=1, colcount do
            itemcontainer_cleargrid(line, i)
        end
    end
    list_item:restorestate()
    return slotarray
end

function itemcontainer_updatecd(slot)
    local cdlength, cdremain = timer_getcdfromid(cdtype_itemcd, slot.config_item.cdid)
    local cdcovervisible = false
    if cdlength > 0 and cdremain > 0 then
        cdcovervisible = true
        local percent = cdremain / cdlength
        slot.image_cd:setpercent(percent)
        slot.text_cd:settext(timerdesc_getfloatdesc(cdremain))
    end
    if cdcovervisible ~= slot.cdcovervisible then
        slot.cdcovervisible = cdcovervisible
        slot.image_cd:setvisiblenothit(cdcovervisible)
        slot.text_cd:setvisiblenothit(cdcovervisible)
    end
end

function itemcontainer_sort(containeritem, messagename, actorid)
    local tempitem = {}
    for i=1, #containeritem do
        local item = containeritem[i]
        if item.itemid ~= 0 then
            local itemcopy = {}
            itemcopy.slot = i
            itemcopy.itemid = item.itemid
            itemcopy.count = item.count
            itemcopy.uuid = item.uuid
            itemcopy.itemlock = item.itemlock
            local config_item = csvitem_getfromid(item.itemid)
            if config_item == nil then
                return
            end
            itemcopy.stack = config_item.stack or 1
            tempitem[#tempitem + 1] = itemcopy
        end
    end

    for i=1, #tempitem do
        local item = tempitem[i]
        for j=#tempitem, i+1, -1 do
            if item.itemid == 0 or item.count >= item.stack then
                break
            end
            local item2 = tempitem[j]
            if item.itemid == item2.itemid and item.count > 0 and item2.count > 0 and item.itemlock == item2.itemlock then
                local movecount = math.min(item.stack - item.count, item2.count)
                item.count = item.count + movecount
                item2.count = item2.count - movecount

                local msg = {messageid = messagename}
                msg.actorid = actorid
                msg.srcuuid = item2.uuid
                msg.dstslot = item.slot - 1
                msg.movecount = movecount
                c_send(msg)
            end
        end
    end

    for i=#tempitem, 1, -1 do
        if tempitem[i].count == 0 then
            table.remove(tempitem, i)
        end
    end

    table.sort(tempitem, function(p1, p2)
        if p1.itemid == p2.itemid then
            if p1.itemlock ~= nil and p2.itemlock ~= nil and p1.itemlock ~= p2.itemlock then
                return p1.itemlock > p2.itemlock
            else
                return p1.count > p2.count
            end
        else
            return p1.itemid < p2.itemid
        end
    end)

    for i=1, #tempitem do
        if tempitem[i].slot ~= i then
            local msg = {messageid = messagename}
            msg.actorid = actorid
            msg.srcuuid = tempitem[i].uuid
            msg.dstslot = i - 1
            msg.movecount = 0
            c_send(msg)

            for j=i+1, #tempitem do
                if tempitem[j].slot == i then
                    tempitem[j].slot = tempitem[i].slot
                    break
                end
            end
            tempitem[i].slot = i
        end
    end

    local msg = {messageid = "CS_MoveItemFinish"}
    c_send(msg)
end

function container_bagtostorage(storageitem, bagslot, storageslot, storageuuid)
    if storageitem ~= nil then
        local srcitem = playerattr_bag[bagslot + 1]
        local dstitem = storageitem[storageslot + 1]
        playeritem_swap(srcitem, dstitem)
        if storageuuid ~= nil then
            dstitem.uuid = storageuuid
        end
    else
        playerattr_bag[bagslot + 1].itemid = 0
    end
    event_active(eventtype.item)
end

function container_storagetobag(storageitem, storageslot, bagslot, itemattr)
    if storageitem ~= nil then
        local srcitem = storageitem[storageslot + 1]
        srcitem.itemid = 0
    end
    playeritem_copy(playerattr_bag[bagslot + 1], itemattr)
    event_active(eventtype.item)
end

function container_move(itemarray, srcslot, srccount, dstslot, dstcount)
    if itemarray ~= nil then
        local srcitem = itemarray[srcslot + 1]
        local dstitem = itemarray[dstslot + 1]
        srcitem.count = srccount
        dstitem.count = dstcount
        if srcitem.count == 0 then
            srcitem.itemid = 0
        end
        if dstitem.count == 0 then
            dstitem.itemid = 0
        end
    end
end

function container_swap(itemarray, srcslot, dstslot)
    if itemarray ~= nil then
        local srcitem = itemarray[srcslot + 1]
        local dstitem = itemarray[dstslot + 1]
        playeritem_swap(srcitem, dstitem)
    end
end
