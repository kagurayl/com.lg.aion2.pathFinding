
local m_uiskill_stigma = uipanel_createhandle("skill/skill_stigma", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_uiskill_stigma_inst = {item = "skill/inst_stigmaitem"}
local m_uiskill_stigma_normalcount = 6
local m_uiskill_stigma_slotcount = 11

local function skill_stigma_active(index)
    if playerattr_info.civ == playerciv.light then
        if not playerquest_complete(1929) then
            local quest = playerquest_getquest(1929)
            if quest == nil or quest.step < 7 then
                return false
            end
        end
    else
        if not playerquest_complete(2900) then
            local quest = playerquest_getquest(2900)
            if quest == nil or quest.step < 7 then
                return false
            end
        end
    end
    if index <= 6 then
        if index == 1 or index == 2 then
            return playerattr_info.level >= 20
        elseif index == 3 then
            return playerattr_info.level >= 30
        elseif index == 4 then
            return playerattr_info.level >= 40
        elseif index == 5 then
            return playerattr_info.level >= 50
        elseif index == 6 then
            return playerattr_info.level >= 55
        end
    elseif playerattr_info.civ == playerciv.light then
        if index == 7 then
            return playerquest_complete(3930)
        elseif index == 8 then
            return playerquest_complete(3931)
        elseif index == 9 then
            return playerquest_complete(3932)
        elseif index == 10 then
            return playerquest_complete(11049)
        elseif index == 11 then
            return playerquest_complete(11276) or playerquest_complete(30217)
        end
    else
        if index == 7 then
            return playerquest_complete(4934)
        elseif index == 8 then
            return playerquest_complete(4935)
        elseif index == 9 then
            return playerquest_complete(4936)
        elseif index == 10 then
            return playerquest_complete(21049)
        elseif index == 11 then
            return playerquest_complete(21278) or playerquest_complete(30317)
        end
    end
    return false
end

function skill_stigma_open(actorid)
    m_uiskill_stigma.selectslot = 0
    m_uiskill_stigma:open()

    event_register(eventtype.item, skill_stigma_updateui, m_uiskill_stigma)
    skill_stigma_updateui()
end

function skill_stigma_onopen()
    local list_item = m_uiskill_stigma:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(skill_stigma_delegate_listitem)

    for i=1,m_uiskill_stigma_slotcount do
        local slot_root = m_uiskill_stigma:getwidget(string.format("stigma_%d", i))
        slot_root.slot = i
        slot_root:setdelegate(skill_stigma_delegate_slot)

        local button_remove = m_uiskill_stigma:getwidget(string.format("stigma_%d/button_remove", i))
        button_remove.slot = i
        button_remove:setdelegate(skill_stigma_delegate_remove)
    end
    m_uiskill_stigma:setwidgetdelegate("image_bg/button_close", skill_stigma_delegate_close)
end

function skill_stigma_updateui()
    if m_uiskill_stigma:null() then
        return
    end
    local text_shard = m_uiskill_stigma:getwidget("text_shard")
    text_shard:settext(playeritem_getcount(itemid_shard))

    for i=1,#playerattr_stigma do
        local text_name = m_uiskill_stigma:getwidget(string.format("stigma_%d/text_name", i))
        local image_icon_11 = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_icon_11", i))
        local image_icon_12 = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_icon_12", i))
        local image_icon_21 = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_icon_21", i))
        local image_icon_22 = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_icon_22", i))
        local image_select = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_select", i))
        local image_iconbg = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_iconbg", i))
        local image_icon = m_uiskill_stigma:getwidget(string.format("stigma_%d/image_icon", i))
        local button_remove = m_uiskill_stigma:getwidget(string.format("stigma_%d/button_remove", i))
        
        local normal = i <= m_uiskill_stigma_normalcount
        local active = skill_stigma_active(i)
        image_select:setvisible(active and m_uiskill_stigma.selectslot == i)
        local config_item = csvitem_getfromid(playerattr_stigma[i])
        if config_item ~= nil then
            text_name:settextscale(config_item.name)
            image_icon_11:setvisible(false)
            image_icon_12:setvisible(normal)
            image_icon_21:setvisible(false)
            image_icon_22:setvisible(not normal)
            image_iconbg:setvisible(true)
            image_icon:setvisible(true)
            image_icon:seticon(config_item.icon)
            button_remove:setvisible(m_uiskill_stigma.selectslot == i)
        else
            text_name:settext("")
            image_icon_11:setvisible(active and normal)
            image_icon_12:setvisible(false)
            image_icon_21:setvisible(active and not normal)
            image_icon_22:setvisible(false)
            image_iconbg:setvisible(false)
            image_icon:setvisible(false)
            button_remove:setvisible(false)
        end
    end

    local list_item = m_uiskill_stigma:getwidget("list_item")
    list_item:savestate()
    list_item:clear()
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and config_item.itemtype == csvitemtype.skill_stigma then
                local line = list_item:add(m_uiskill_stigma_inst.item, i, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)

                local text_name = line:getwidget("text_name")
                text_name:settext(config_item.name)
                text_name:setcolor(csvitem_getfloatcolor(config_item))
            end
        end
    end
    list_item:restorestate()

    local image_messagebg = m_uiskill_stigma:getwidget("image_messagebg")
    local text_messageslot = m_uiskill_stigma:getwidget("text_messageslot")
    if m_uiskill_stigma.selectslot == 0 then
        image_messagebg:setvisible(true)
        text_messageslot:setvisiblenothit(true)
        text_messageslot:settext("SITMGA_SELECT_SLOT")
    elseif list_item:getcount() == 0 then
        image_messagebg:setvisible(true)
        text_messageslot:setvisiblenothit(true)
        text_messageslot:settext("SITMGA_SELECT_NOSTIGMA")
    else
        image_messagebg:setvisible(false)
        text_messageslot:setvisiblenothit(false)
    end
end

function skill_stigma_delegate_slot(sender, event)
    if skill_stigma_active(sender.slot) then
        m_uiskill_stigma.selectslot = sender.slot
        skill_stigma_updateui()
    end
end

function skill_stigma_remove_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_SkillStigmaRemove"}
        msg.slot = data - 1
        c_send(msg)
    end
end
function skill_stigma_delegate_remove(sender, event)
    if playerattr_stigma[sender.slot] ~= 0 then
        local config_item = csvitem_getfromid(playerattr_stigma[sender.slot])
        local message = c_textformat("SITMGA_OFF_CONFIRM", config_item.name)
        messagebox_confirm(message, skill_stigma_remove_confirm, sender.slot)
    end
end

function skill_stigma_equip_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_SkillStigmaAdd"}
        msg.uuid = data
        msg.slot = m_uiskill_stigma.selectslot - 1
        c_send(msg)
    end
end
function skill_stigma_delegate_listitem(line, event, uuid)
    if m_uiskill_stigma.selectslot == 0 then
        return
    end
    local item, config_item = playeritem_getitemconfigfrombaguuid(uuid)
    if item == nil then
        return
    end
    local sublambda = csvitem_getscript(config_item, "stigma")
    if sublambda == nil then
        return
    end
    local shardcount = sublambda.variable[2].integer
    if playeritem_getcount(itemid_shard) < shardcount then
        messagealert_addalert(c_textformat("SITMGA_SHARD_NOTENOUGH", shardcount))
        return
    end
    if playerattr_stigma[m_uiskill_stigma.selectslot] ~= 0 then
        messagealert_addalert("SITMGA_ON_NOTEMPTY")
        return
    end
    local message = c_textformat("SITMGA_ON_CONFIRM", config_item.name, shardcount)
    messagebox_confirm(message, skill_stigma_equip_confirm, uuid)
end

function skill_stigma_delegate_close()
    m_uiskill_stigma:close()
end
