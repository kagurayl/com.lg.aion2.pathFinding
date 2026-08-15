
m_uipet_menu = uipanel_createhandle("pet/pet_menu", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeleft))

function pet_menu_open(uuid)
    local pet = playerattr_getpet(uuid)
    if pet == nil then
        return
    end
    local config_pet = csvpet_getfromid(pet.petid)
    if config_pet == nil then
        return
    end
    m_uipet_menu.pet = pet
    m_uipet_menu.config_pet = config_pet
    m_uipet_menu:open()
    pet_menu_updateui()
end

function pet_menu_pethasaction(actionname)
    if playerattr_info.petuuid == 0 then
		return false
	end
    local pet = playerattr_getpet(playerattr_info.petuuid)
    if pet == nil then
        return false
    end
    local config_pet = csvpet_getfromid(pet.petid)
    if config_pet == nil then
        return false
    end
    local lambda1 = config_pet.skill1
    local lambda2 = config_pet.skill2
    if (lambda1 ~= nil and c_isaction(lambda1[1], actionname)) or (lambda2 ~= nil and c_isaction(lambda2[1], actionname)) then
        return true
    end
    return false
end

function pet_menu_opengift()
    if pet_menu_pethasaction("feed") then
        if m_uipet_menu:null() then
            pet_menu_open(playerattr_info.petuuid)
        end
        if m_uipet_menu:alive() then
            m_uipet_menu.tabmain:settab(3)
        end
    end
end

function pet_menu_opendop()
    if playerattr_info.petuuid == 0 then
		return
	end
    local pet = playerattr_getpet(playerattr_info.petuuid)
    if pet == nil then
        return
    end
	if not pet_menu_pethasaction("dop") then
        return
    end
    local alldisable = true
    for i=1,#pet.dopitem do
        if pet.dopactive[i] > 0 then
            alldisable = false
            break
        end
    end
    local enable = alldisable
    for i=1,#pet.dopitem do
        local msg = {messageid="CS_PetDopActive"}
        msg.uuid = playerattr_info.petuuid
        msg.index = i - 1
        if enable then
            msg.active = 1
        else
            msg.active = 0
        end
        c_send(msg)
    end
    if enable then
        chat_addsystemalert("PLAYER_PET_DOPENABLE")
    else
        chat_addsystemalert("PLAYER_PET_DOPDISABLE")
    end
end

function pet_menu_openloot()
    if pet_menu_pethasaction("loot") then
        if m_uipet_menu:null() then
            pet_menu_open(playerattr_info.petuuid)
        end
        if m_uipet_menu:alive() then
            m_uipet_menu.tabmain:settab(4)
        end
    end
end

function pet_menu_onopen()
    m_uipet_menu.tabmain = uitabcreate(m_uipet_menu)
    m_uipet_menu.tabmain:add("button_dop", "tab_dop", pet_menu_delegate_dop)
    m_uipet_menu.tabmain:add("button_bag", "tab_bag", pet_menu_delegate_bag)
    m_uipet_menu.tabmain:add("button_feed", "tab_feed", pet_menu_delegate_feed)
    m_uipet_menu.tabmain:add("button_loot", "tab_loot", pet_menu_delegate_loot)
    m_uipet_menu.tabmain:add("button_care", "tab_care", pet_menu_delegate_care)

    local lambda1 = m_uipet_menu.config_pet.skill1
    local lambda2 = m_uipet_menu.config_pet.skill2
    local dopenable = false
    local bagenable = false
    local feedenable = false
    local lootenable = false
    local careenable = false
    local tabindex = 5
    if (lambda1 ~= nil and c_isaction(lambda1[1], "loot")) or (lambda2 ~= nil and c_isaction(lambda2[1], "loot")) then
        lootenable = true
        tabindex = 4
    end
    if (lambda1 ~= nil and c_isaction(lambda1[1], "feed")) or (lambda2 ~= nil and c_isaction(lambda2[1], "feed")) then
        feedenable = true
        tabindex = 3
    end
    if (lambda1 ~= nil and c_isaction(lambda1[1], "bag")) or (lambda2 ~= nil and c_isaction(lambda2[1], "bag")) then
        bagenable = true
        tabindex = 2
    end
    if (lambda1 ~= nil and c_isaction(lambda1[1], "dop")) or (lambda2 ~= nil and c_isaction(lambda2[1], "dop")) then
        dopenable = true
        tabindex = 1
    end
    m_uipet_menu.tabmain:settab(tabindex)
    if not dopenable then
        m_uipet_menu.tabmain:settabavailable("tab_dop", false)
    end
    if not bagenable then
        m_uipet_menu.tabmain:settabavailable("tab_bag", false)
    end
    if not feedenable then
        m_uipet_menu.tabmain:settabavailable("tab_feed", false)
    end
    if not lootenable then
        m_uipet_menu.tabmain:settabavailable("tab_loot", false)
    end

    m_uipet_menu:setwidgetdelegate("button_deactive", pet_menu_delegate_deactive)
    m_uipet_menu:setwidgetdelegate("image_bg/button_close", pet_menu_delegate_close)
    audiomanager_playaudioui(string.format("sounds/pet/%s.ogg", m_uipet_menu.config_pet.targetsound))

    tabbag_onopen()
    tabfeed_onopen()
    tabcare_onopen()

    event_register(eventtype.item, pet_menu_updateitem, m_uipet_menu)
    event_register(eventtype.update, tabcare_update, m_uipet_menu)
end

function pet_menu_updateitem()
    tabfeed_updateui()
end

function pet_menu_updateui()
    if m_uipet_menu:null() then
        return
    end
    local image_icon = m_uipet_menu:getwidget("image_icon")
    image_icon:seticon(m_uipet_menu.config_pet.icon)

    local text_name = m_uipet_menu:getwidget("text_name")
    local name = m_uipet_menu.pet.name
    if name == nil or #name == 0 then
        name = m_uipet_menu.config_pet.name
    end
    text_name:settext(name)

    local text_desc = m_uipet_menu:getwidget("text_desc")
    text_desc:settext(m_uipet_menu.config_pet.desc)

    tabdop_updateui()
    tabfeed_updateui()
    tabloot_updateui()
    tabcare_updateui()
end

function pet_menu_update()
    tabcare_update()
end

function pet_menu_delegate_dop(sender, event)
    tabdop_updateui()
end

function pet_menu_delegate_bag(sender, event)

end

function pet_menu_delegate_feed(sender, event)
    tabfeed_updateui()
end

function pet_menu_delegate_loot(sender, event)
    tabloot_updateui()
end

function pet_menu_delegate_care(sender, event)
    tabcare_updateui()
end

function pet_menu_delegate_deactive()
    m_uipet_menu:close()
    local msg = {messageid="CS_PetActive"}
    msg.uuid = 0
    c_send(msg)
end

function pet_menu_delegate_close()
    m_uipet_menu:close()
end
