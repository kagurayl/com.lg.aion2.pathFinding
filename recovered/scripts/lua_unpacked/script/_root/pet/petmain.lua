
m_uipetmain = uipanel_createhandle("pet/pet_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)
local m_petmain_inst = {inst = "pet/inst_petlist"}
local m_petmain_selectpet = nil

function pet_main_open()
    m_uipetmain:open()
end

function pet_main_openpet(selectuuid)
    m_petmain_selectpet = selectuuid
    if m_uipetmain:alive() then
        pet_main_updateui()
    else
        m_uipetmain:open()
    end
end

function pet_main_onopen()
    m_uipetmain:setwidgetdelegate("image_bg/button_close", pet_main_delegate_close)
	local list_pet = m_uipetmain:getwidget("list_pet")
    list_pet:init(uilistflag.vertical)
    list_pet:setclickdelegate(pet_main_delegate_list_pet)
    pet_main_updateui()
end

function pet_main_updateui()
    if m_uipetmain:null() then
        return
    end

    local list_pet = m_uipetmain:getwidget("list_pet")
    list_pet:savestate()
    list_pet:clear()

    for i=#playerattr_petlist,1,-1 do
        local pet = playerattr_petlist[i]
        if pet.expiredate > 0 and pet.expiredate < timer_gettimesecond() then
            table.remove(playerattr_petlist, i)
        end
    end
    for i=1,#playerattr_petlist do
        local pet = playerattr_petlist[i]
        local config_pet = csvpet_getfromid(pet.petid)
        if config_pet ~= nil then
            local line = list_pet:add(m_petmain_inst.inst, pet.uuid, pet.uuid)
            local text_name = line:getwidget("text_name")
            local name = pet.name
            if name == nil or #name == 0 then
                name = config_pet.name
            end
            text_name:settext(name)

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_pet.icon)

            local desc = c_textformat(config_pet.desc)
            if pet.expiredate > 0 then
                local expiretext = timer_servercountdown(pet.expiredate, true, true, false)
                if expiretext ~= nil then
                    desc = desc .. string.format("\n%s", c_textformat("PLAYER_PET_EXPIRE", expiretext))
                end
            end
            local text_desc = line:getwidget("text_desc")
            text_desc:settext(desc)
            local w, h = text_desc:setheightfromrendersize()
            local x, y = text_desc:getposition()
            local button_active = line:getwidget("button_active")
            local button_deactive = line:getwidget("button_deactive")
            local button_rename = line:getwidget("button_rename")
            local linesize = -(y - h)
            if m_petmain_selectpet == pet.uuid then
                button_active.petuuid = pet.uuid
                button_active:setvisible(true)
                button_active:setdelegate(pet_main_delegate_active)
                button_deactive.petuuid = pet.uuid
                button_deactive:setvisible(true)
                button_deactive:setdelegate(pet_main_delegate_deactive)
                button_rename.petuuid = pet.uuid
                button_rename:setvisible(true)
                button_rename:setdelegate(pet_main_delegate_rename)
                local button_x, button_y = button_active:getposition()
                local button_w, button_h = button_active:getsize()
                button_active:setposition(button_x, y - h - button_h / 2)

                button_x, button_y = button_deactive:getposition()
                button_deactive:setposition(button_x, y - h - button_h / 2)

                button_x, button_y = button_rename:getposition()
                button_rename:setposition(button_x, y - h - button_h / 2)

                linesize = linesize + button_h + 10
            else
                button_active:setvisible(false)
                button_deactive:setvisible(false)
                button_rename:setvisible(false)
            end
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
    list_pet:restorestate()
    list_pet:updatecontentsize()
end

function pet_main_delegate_close()
    m_uipetmain:close()
end

function pet_main_delegate_list_pet(line, event, data)
    m_petmain_selectpet = data
    pet_main_updateui()
end

function pet_main_delegate_active(sender, event)
    local msg = {messageid="CS_PetActive"}
    msg.uuid = sender.petuuid
    c_send(msg)
end

function pet_main_delegate_deactive(sender, event)
    local msg = {messageid="CS_PetActive"}
    msg.uuid = 0
    c_send(msg)
end

function pet_main_rename_confirm(text, uuid)
    local msg = {messageid="CS_PetRename"}
    msg.uuid = uuid
    msg.name = text
    c_send(msg)
end
function pet_main_delegate_rename(sender, event)
    local pet = playerattr_getpet(sender.petuuid)
	if pet ~= nil then
		inputline_show(uiedittype.default, "PLAYER_PET_RENAMETITLE", pet.name, pet_main_rename_confirm, sender.petuuid)
	end
end
