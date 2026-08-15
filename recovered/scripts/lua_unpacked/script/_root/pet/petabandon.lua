
local m_uipet_abandon = uipanel_createhandle("pet/pet_abandon", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall))
local m_uipet_abandon_inst = {item = "pet/inst_petabandon"}
local m_uipet_abandon_petuuid = 0

function pet_abandon_open(actorid)
    m_uipet_abandon_petuuid = 0
    m_uipet_abandon.npcactorid = actorid
    m_uipet_abandon:open()

    event_register(eventtype.playerinfo, pet_abandon_updateui, m_uipet_abandon)
    pet_abandon_updateui()
end

function pet_abandon_onopen()
    local list_item = m_uipet_abandon:getwidget("list_item")
    list_item:init(uilistflag.vertical)
    list_item:setclickdelegate(pet_abandon_delegate_listitem)

    m_uipet_abandon:setwidgetdelegate("button_ok", pet_abandon_delegate_ok)
    m_uipet_abandon:setwidgetdelegate("image_bg/button_close", pet_abandon_delegate_close)
end

function pet_abandon_updateui()
    local list_item = m_uipet_abandon:getwidget("list_item")
    list_item:savestate()
    list_item:clear()

    for i=1,#playerattr_petlist do
        local pet = playerattr_petlist[i]
        local config_pet = csvpet_getfromid(pet.petid)
        if config_pet ~= nil then
            local line = list_item:add(m_uipet_abandon_inst.item, pet.uuid, pet.uuid)
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_pet.icon)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_pet.name)

            local desc = c_textformat(config_pet.desc)
            if pet.expiredate > 0 then
                local expiretext = timer_servercountdown(pet.expiredate, true, true, false)
                if expiretext ~= nil then
                    desc = desc .. string.format("\n%s%s", c_textformat("PLAYER_PET_EXPIRE"), expiretext)
                end
            end

            local text_desc = line:getwidget("text_desc")
            text_desc:settext(desc)
            local w, h = text_desc:setheightfromrendersize()
            local x, y = text_desc:getposition()
            local linesize = -(y - h)
            local image_bg = line:getwidget("image_bg")
            local image_select = line:getwidget("image_select")
            local image_event = line:getwidget("image_event")
            w,h = image_select:getsize()
            image_bg:setsize(w, linesize)
            image_select:setsize(w, linesize)
            image_event:setsize(w, linesize)
            line:setsize(linesize)
        end
    end

    list_item:restorestate()
    list_item:updatecontentsize()
end

function pet_abandon_delegate_listitem(line, event, uuid)
    m_uipet_abandon_petuuid = uuid
    pet_abandon_updateui()
end

function pet_abandon_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PetAbandon"}
        msg.actorid = m_uipet_abandon.npcactorid
        msg.uuid = m_uipet_abandon_petuuid
        c_send(msg)
        m_uipet_abandon:close()
    end
end

function pet_abandon_delegate_ok()
    local pet = playerattr_getpet(m_uipet_abandon_petuuid)
    if pet ~= nil then
        local config_pet = csvpet_getfromid(pet.petid)
        if config_pet ~= nil then
            local message = c_textformat("PLAYER_PETABANDON_CONFIRM", config_pet.name)
            messagebox_confirm(message, pet_abandon_confirm)
        end
    end
end

function pet_abandon_delegate_close()
    m_uipet_abandon:close()
end
