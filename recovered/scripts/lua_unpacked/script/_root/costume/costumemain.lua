
local m_uicostumemain = uipanel_createhandle("costume/costume", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)
local m_costumemain_inst = {costume = "costume/inst_costume", add = "costume/inst_add", lock = "costume/inst_lock"}
local m_costumemain_type = nil
local m_costumemain_unlockcost = 10000

function costume_open()
    m_uicostumemain:open()
end

function costume_onopen()
    m_uicostumemain:setwidgetdelegate("image_bg/button_close", costume_delegate_close)
    m_uicostumemain:setwidgetdelegate("button_all", costume_delegate_typeall)
    m_uicostumemain:setwidgetdelegate("button_weapon", costume_delegate_typeweapon)
    m_uicostumemain:setwidgetdelegate("button_helmet", costume_delegate_typehelmet)
    m_uicostumemain:setwidgetdelegate("button_torso", costume_delegate_typetorso)
    m_uicostumemain:setwidgetdelegate("button_pants", costume_delegate_typepants)
    m_uicostumemain:setwidgetdelegate("button_shoulder", costume_delegate_typeshoulder)
    m_uicostumemain:setwidgetdelegate("button_glove", costume_delegate_typeglove)
    m_uicostumemain:setwidgetdelegate("button_shoes", costume_delegate_typeshoes)
    m_uicostumemain:setwidgetdelegate("button_wing", costume_delegate_typewing)
    m_uicostumemain:setwidgetdelegate("button_accessory", costume_delegate_typeaccessory)

	local list_costume = m_uicostumemain:getwidget("list_costume")
    list_costume:init(uilistflag.vertical)
    list_costume:setclickdelegate(costume_delegate_list_costume)
    costume_delegate_typeall()
end

function costume_clearselect()
    itemmenu_close()
    local list_costume = m_uicostumemain:getwidget("list_costume")
    list_costume:clearselect()
end

local function costume_updatebutton(selectbutton)
    m_uicostumemain:setwidgetenable("button_all", selectbutton ~= "button_all")
    m_uicostumemain:setwidgetenable("button_weapon", selectbutton ~= "button_weapon")
    m_uicostumemain:setwidgetenable("button_helmet", selectbutton ~= "button_helmet")
    m_uicostumemain:setwidgetenable("button_torso", selectbutton ~= "button_torso")
    m_uicostumemain:setwidgetenable("button_pants", selectbutton ~= "button_pants")
    m_uicostumemain:setwidgetenable("button_shoulder", selectbutton ~= "button_shoulder")
    m_uicostumemain:setwidgetenable("button_glove", selectbutton ~= "button_glove")
    m_uicostumemain:setwidgetenable("button_shoes", selectbutton ~= "button_shoes")
    m_uicostumemain:setwidgetenable("button_wing", selectbutton ~= "button_wing")
    m_uicostumemain:setwidgetenable("button_accessory", selectbutton ~= "button_accessory")
end

local function costume_addcostume(list_costume, costume)
    local config_item = csvitem_getfromid(costume.skin)
    if config_item ~= nil and m_costumemain_type ~= nil then
        local add = false
        for i=1,#m_costumemain_type do
            if m_costumemain_type[i] == config_item.itemtype then
                add = true
                break
            end
        end
        if not add then
            return
        end
    end
    local line = list_costume:add(m_costumemain_inst.costume, costume.index, costume.index)
    local text_name = line:getwidget("text_name")
    text_name:settext(costume.name)
    if playeritem_getcostumeslotfromindex(costume.index) ~= 0 then
        text_name:setcolor(0,1,0,1)
    else
        text_name:setcolor(1,1,1,1)
    end

    local image_color = line:getwidget("image_color")
    local text_color = line:getwidget("text_color")
    if costume.dye ~= 0 then
        local config_dye = csvitem_getfromid(costume.dye)
        if config_dye ~= nil then
            text_color:settext("COSTUME_DYEITEM", config_dye.name)
            local r, g, b = HexRGBDefault(csvitem_getdyecolorfromconfig(config_dye))
            image_color:setcolor(r, g, b, 1.0)
        end
    else
        if config_item ~= nil then
            if playerattr_info.sex == playersex.male then
                local r, g, b = HexRGBDefault(config_item.colormale)
                image_color:setcolor(r, g, b, 1.0)
            else
                local r, g, b = HexRGBDefault(config_item.colorfemale)
                image_color:setcolor(r, g, b, 1.0)
            end
        end
        if config_item.dye ~= nil and config_item.dye > 0 then
            text_color:settext("COSTUME_NODYE")
        else
            text_color:settext("COSTUME_CANNOTDYE")
        end
    end

    local image_icon = line:getwidget("image_icon")
    if config_item ~= nil then
        image_icon:setvisiblenothit(true)
        image_icon:seticon(config_item.icon)
    else
        image_icon:setvisible(false)
    end
end

function costume_updateui()
    if m_uicostumemain:null() then
        return
    end

    local text_space = m_uicostumemain:getwidget("text_space")
    text_space:settext("COSTUME_SPACE", table.valcount(playerattr_costume), playerattr_costumespace)

    local list_costume = m_uicostumemain:getwidget("list_costume")
    list_costume:savestate()
    list_costume:clear()

    for i=1,playerattr_costumespace do
        local index = i - 1
        local costume = playerattr_costume[index]
        if costume ~= nil then
            costume_addcostume(list_costume, costume)
        else
            local line = list_costume:add(m_costumemain_inst.add)
            local image_add = line:getwidget("image_add")
            image_add.costumeindex = index
            image_add:setdelegate(costume_delegate_add)
        end
    end
    local line = list_costume:add(m_costumemain_inst.lock)
    line:setwidgetdelegate("button_lock", costume_delegate_lock)

    list_costume:restorestate()
    list_costume:updatecontentsize()
end

function costume_delegate_close()
    m_uicostumemain:close()
end

function costume_delegate_list_costume(line, event, data)
    if data ~= nil then
        local costume = playerattr_costume[data]
        if costume == nil then
            return
        end
        local config_item = csvitem_getfromid(costume.skin)
        if config_item == nil then
            return
        end
        itemmenu_reset(data)
        if playeritem_getcostumeslotfromindex(costume.index) == 0 then
            if config_item.itemtype == csvitemtype.weapon_tool1
            or config_item.itemtype == csvitemtype.weapon_mace
            or config_item.itemtype == csvitemtype.weapon_dagger
            or config_item.itemtype == csvitemtype.weapon_sword1
            or config_item.itemtype == csvitemtype.accessory_earring
            or config_item.itemtype == csvitemtype.accessory_ring then
                itemmenu_addbutton("COSTUME_ACTIVE1", costume_delegate_active1)
                itemmenu_addbutton("COSTUME_ACTIVE2", costume_delegate_active2)
            else
                itemmenu_addbutton("COSTUME_ACTIVE", costume_delegate_active1)
            end
        else
            itemmenu_addbutton("COSTUME_DEACTIVE", costume_delegate_deactive)
        end
        itemmenu_addbutton("COSTUME_NOTE", costume_delegate_rename)
        if config_item.dye ~= nil and config_item.dye > 0 then
            itemmenu_addbutton("COSTUME_COLOR", costume_delegate_color)
        end
        itemmenu_addbutton("COSTUME_DELETE", costume_delegate_delete)

        local image_bg = m_uicostumemain:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        local menux = x - itemmenu_getwidth()
        local menuy = y + h / 2 + itemmenu_getheight() / 2
        itemmenu_open(menux, menuy, m_uicostumemain)
    end
end

function costume_unlock_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_CostumeExtend"}
        msg.current = playerattr_costumespace
        c_send(msg)
    end
end
function costume_delegate_lock(sender, event)
    costume_clearselect()
    local text = c_textformat("COSTUME_UNLOCKCOMFIRM", m_costumemain_unlockcost)
    messagebox_confirm(text, costume_unlock_confirm)
end

function costume_add_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_CostumeAdd"}
        msg.index = data.index
        msg.itemuuid = data.uuid
        msg.name = data.name
        c_send(msg)
    end
end
function costume_delegate_selectequipcomplete(item, count, data)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local text = c_textformat("COSTUME_ADDTIPS", csvitem_getcolorname(config_item))
    local itemdata = {}
    itemdata.name = config_item.name
    itemdata.uuid = item.uuid
    itemdata.index = data
    messagebox_confirm(text, costume_add_confirm, itemdata)
end
function costume_delegate_filterequip(item)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return false
    end
    if config_item.changeskin ~= nil and config_item.changeskin > 0 then
        return true
    end
    return false
end
function costume_delegate_add(sender, event)
    costume_clearselect()
    selectitem_show("COSTUME_SELECTITEM", nil, selectitemcount.none, selectitemflag.bag, costume_delegate_filterequip, costume_delegate_selectequipcomplete, sender.costumeindex)
end

function costume_delegate_typeall(sender, event)
    costume_clearselect()
    costume_updatebutton("button_all")
    m_costumemain_type = nil
    costume_updateui()
end

local function costume_addtype(type)
    m_costumemain_type[#m_costumemain_type + 1] = type
end
function costume_delegate_typeweapon(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.weapon_tool1)
    costume_addtype(csvitemtype.weapon_mace)
    costume_addtype(csvitemtype.weapon_dagger)
    costume_addtype(csvitemtype.weapon_sword1)
    costume_addtype(csvitemtype.weapon_shield)
    costume_addtype(csvitemtype.weapon_sub)
    costume_addtype(csvitemtype.weapon_tool2)
    costume_addtype(csvitemtype.weapon_sword2)
    costume_addtype(csvitemtype.weapon_polearm)
    costume_addtype(csvitemtype.weapon_staff)
    costume_addtype(csvitemtype.weapon_bow)
    costume_addtype(csvitemtype.weapon_book)
    costume_addtype(csvitemtype.weapon_orb)
    costume_updateui()
end

function costume_delegate_typehelmet(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.accessory_helmet)
    costume_updateui()
end

function costume_delegate_typetorso(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.cosplay_torso)
    costume_addtype(csvitemtype.plate_torso)
    costume_addtype(csvitemtype.chain_torso)
    costume_addtype(csvitemtype.leather_torso)
    costume_addtype(csvitemtype.cloth_torso)
    costume_updateui()
end

function costume_delegate_typepants(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.cosplay_pants)
    costume_addtype(csvitemtype.plate_pants)
    costume_addtype(csvitemtype.chain_pants)
    costume_addtype(csvitemtype.leather_pants)
    costume_addtype(csvitemtype.cloth_pants)
    costume_updateui()
end

function costume_delegate_typeshoulder(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.cosplay_shoulder)
    costume_addtype(csvitemtype.plate_shoulder)
    costume_addtype(csvitemtype.chain_shoulder)
    costume_addtype(csvitemtype.leather_shoulder)
    costume_addtype(csvitemtype.cloth_shoulder)
    costume_updateui()
end

function costume_delegate_typeglove(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.cosplay_glove)
    costume_addtype(csvitemtype.plate_glove)
    costume_addtype(csvitemtype.chain_glove)
    costume_addtype(csvitemtype.leather_glove)
    costume_addtype(csvitemtype.cloth_glove)
    costume_updateui()
end

function costume_delegate_typeshoes(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.cosplay_shoes)
    costume_addtype(csvitemtype.plate_shoes)
    costume_addtype(csvitemtype.chain_shoes)
    costume_addtype(csvitemtype.leather_shoes)
    costume_addtype(csvitemtype.cloth_shoes)
    costume_updateui()
end

function costume_delegate_typewing(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.accessory_wing)
    costume_updateui()
end

function costume_delegate_typeaccessory(sender, event)
    costume_clearselect()
    costume_updatebutton(sender:getname())
    m_costumemain_type = {}
    costume_addtype(csvitemtype.accessory_necklace)
    costume_addtype(csvitemtype.accessory_earring)
    costume_addtype(csvitemtype.accessory_ring)
    costume_addtype(csvitemtype.accessory_belt)
    costume_updateui()
end

function costume_delegate_active1(data)
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end
    local config_item = csvitem_getfromid(costume.skin)
    if config_item == nil then
        return
    end
    local slot = csvitem_getequipslot(config_item)
    if slot == nil then
        return
    end
    local msg = {messageid="CS_CostumeActive"}
    msg.slot = slot - 1
    msg.index = costume.index
    c_send(msg)
end

function costume_delegate_active2(data)
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end
    local config_item = csvitem_getfromid(costume.skin)
    if config_item == nil then
        return
    end
    local slot = csvitem_getequipslot(config_item)
    if slot == nil then
        return
    end
    if slot == equipslot.weapon1 then
        slot = equipslot.weapon2
    elseif slot == equipslot.earring1 then
        slot = equipslot.earring2
    elseif slot == equipslot.ring1 then
        slot = equipslot.ring2
    end
    local msg = {messageid="CS_CostumeActive"}
    msg.slot = slot - 1
    msg.index = costume.index
    c_send(msg)
end

function costume_delegate_deactive(data)
    local msg = {messageid="CS_CostumeActive"}
    msg.slot = playeritem_getcostumeslotfromindex(data) - 1
    msg.index = -1
    c_send(msg)
end

function costume_rename_confirm(text, index)
    local msg = {messageid="CS_CostumeRename"}
    msg.index = index
    msg.name = text
    c_send(msg)
end
function costume_delegate_rename(data)
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end
    inputline_show(uiedittype.default, "COSTUME_NOTE", costume.name, costume_rename_confirm, data)
end

function costume_color_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_CostumeDye"}
        msg.index = data.index
        msg.itemuuid = data.uuid
        c_send(msg)
    end
end
function costume_delegate_selectdyecomplete(item, count, data)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return
    end
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end

    local text = c_textformat("COSTUME_COLORCONFIRM", csvitem_getcolorname(config_item), costume.name)
    local itemdata = {}
    itemdata.uuid = item.uuid
    itemdata.index = data
    messagebox_confirm(text, costume_color_confirm, itemdata)
end
function costume_delegate_filterdye(item)
    local config_item = csvitem_getfromid(item.itemid)
    if config_item == nil then
        return false
    end
    if config_item.itemtype == csvitemtype.consume_dye then
        return true
    end
    return false
end
function costume_delegate_color(data)
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end
    selectitem_show("COSTUME_SELECTDYE", nil, selectitemcount.none, selectitemflag.bag, costume_delegate_filterdye, costume_delegate_selectdyecomplete, data)
end

function costume_delete_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_CostumeDelete"}
        msg.index = data
        c_send(msg)
    end
end

function costume_delegate_delete(data)
    local costume = playerattr_costume[data]
    if costume == nil then
        return
    end
    local text = c_textformat("COSTUME_DELETECONFIRM", costume.name)
    messagebox_confirm(text, costume_delete_confirm, costume.index)
end
