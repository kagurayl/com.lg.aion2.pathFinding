
local m_uipet_adopt = uipanel_createhandle("pet/pet_adopt", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))
local m_uipet_adopt_inst = {item = "pet/inst_petcard"}
local m_uipet_adopt_carduuid = 0

function pet_adopt_open(actorid)
    m_uipet_adopt_carduuid = 0
    m_uipet_adopt.npcactorid = actorid
    m_uipet_adopt:open()

    event_register(eventtype.item, pet_adopt_updateui, m_uipet_adopt)
    pet_adopt_updateui()
end

function pet_adopt_onopen()
    local list_item = m_uipet_adopt:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(pet_adopt_delegate_listitem)

    m_uipet_adopt:setwidgetdelegate("button_ok", pet_adopt_delegate_ok)
    m_uipet_adopt:setwidgetdelegate("image_bg/button_close", pet_adopt_delegate_close)
end

local function pet_adopt_updatepetlist(list_item)
    for i=1,#playerattr_bag do
        local item = playerattr_bag[i]
        if item.itemid ~= 0 then
            local config_item = csvitem_getfromid(item.itemid)
            if config_item ~= nil and config_item.itemtype == csvitemtype.consume_petcard then
                local line = list_item:add(m_uipet_adopt_inst.item, item.uuid, item.uuid)
                local image_icon = line:getwidget("image_icon")
                image_icon:seticon(config_item.icon)

                local text_name = line:getwidget("text_name")
                text_name:settext(config_item.name)
                text_name:setcolor(csvitem_getfloatcolor(config_item))
            end
        end
    end
end

local function pet_adopt_updatepetstate(item, config_item)
    local image_icon = m_uipet_adopt:getwidget("petcard/image_icon")
    local text_name = m_uipet_adopt:getwidget("petcard/text_name")
    local edit_name = m_uipet_adopt:getwidget("edit_name")
    local petdefaultname = c_textformat("PLAYER_PETADOPT_INPUTNAME")
    if config_item == nil then
        image_icon:setvisiblenothit(false)
        text_name:setvisiblenothit(false)
        edit_name:sethinttext(petdefaultname)
        return
    end
    image_icon:setvisiblenothit(true)
    text_name:setvisiblenothit(true)
    image_icon:seticon(config_item.icon)
    text_name:settext(config_item.name)
    text_name:setcolor(csvitem_getfloatcolor(config_item))
   
    local lambda = csvitem_getscript(config_item, "petcard")
    if lambda ~= nil then
        local config_pet = csvpet_getfromid(lambda.variable[1].integer)
        if config_pet ~= nil then
            petdefaultname = config_pet.name
        end
    end
    edit_name:sethinttext(petdefaultname)
end

function pet_adopt_updateui()
    local item, config_item = playeritem_getitemconfigfromuuid(m_uipet_adopt_carduuid)
    local list_item = m_uipet_adopt:getwidget("list_item")
    list_item:savestate()
    list_item:clear()
    pet_adopt_updatepetlist(list_item)
    list_item:restorestate()

    pet_adopt_updatepetstate(item, config_item)
end

function pet_adopt_delegate_listitem(line, event, uuid)
    m_uipet_adopt_carduuid = uuid
    pet_adopt_updateui()
end

function pet_adopt_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PetAdopt"}
        msg.actorid = m_uipet_adopt.npcactorid
        msg.itemuuid = m_uipet_adopt_carduuid
        msg.name = data
        c_send(msg)
        m_uipet_adopt:close()
    end
end

function pet_adopt_delegate_ok()
    local item, config_item = playeritem_getitemconfigfromuuid(m_uipet_adopt_carduuid)
    if config_item == nil then
        return
    end
    local edit_name = m_uipet_adopt:getwidget("edit_name")
    local name = edit_name:gettext()
    if name == nil or #name == 0 then
        name = edit_name:gethinttext()
        if name == nil or #name == 0 then
            chat_addsystemalert("PLAYER_PETADOPT_INPUTFIRST")
            return
        end
    end
    local message = c_textformat("PLAYER_PETADOPT_CONFIRM", config_item.name)
    messagebox_confirm(message, pet_adopt_confirm, name)
end

function pet_adopt_delegate_close()
    m_uipet_adopt:close()
end
