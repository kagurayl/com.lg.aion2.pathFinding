
local m_uinpc_abyssrepair = uipanel_createhandle("npc/abyssrepair", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function abyssrepair_setrepair(actorid, cd)
    m_uinpc_abyssrepair:open()
    m_uinpc_abyssrepair.npcactorid = actorid
    m_uinpc_abyssrepair.cdtime = time_game + cd

    m_uinpc_abyssrepair:setwidgetdelegate("button_ok", abyssrepair_delegate_ok)
    m_uinpc_abyssrepair:setwidgetdelegate("image_bg/button_close", abyssrepair_delegate_close)

    local config_item = csvitem_getfromid(itemid_abyssrepair)
    if config_item ~= nil then
        local image_icon = m_uinpc_abyssrepair:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_count = m_uinpc_abyssrepair:getwidget("text_count")
        text_count:settext(1)

        local text_name = m_uinpc_abyssrepair:getwidget("text_name")
        text_name:settext(csvitem_getcolorname(config_item) .. "x1")
        if playeritem_getcount(itemid_abyssrepair) > 0 then
            text_name:setcolor(1,1,1,1)
        else
            text_name:setcolor(1,0,0,1)
        end
    end

    event_register(eventtype.update, abyssrepair_update, m_uinpc_abyssrepair)
    abyssrepair_update()
end

function abyssrepair_update()
    if m_uinpc_abyssrepair:null() then
        return
    end
    local text_cd = m_uinpc_abyssrepair:getwidget("text_cd")
    local cd = m_uinpc_abyssrepair.cdtime - time_game
    if cd > 0 then
        text_cd:settext("NPC_ABYSSREPAIR_CDING", timerdesc_getafter(cd))
        text_cd:setcolor(1,0,0,1)
    else
        text_cd:settext("NPC_ABYSSREPAIR_CD", timerdesc_getafter(600.0))
        text_cd:setcolor(1,1,1,1)
    end
end

function abyssrepair_delegate_startconfirm(ok, npcactorid)
    if ok then
        local msg = {messageid="CS_AbyssDoorRepair"}
        msg.actorid = npcactorid
        c_send(msg)
        m_uinpc_abyssrepair:close()
    end
end

function abyssrepair_delegate_ok()
    if playeritem_getcount(itemid_abyssrepair) == 0 then
        chat_addsystemalert("NPC_ABYSSREPAIR_ITEMNOTENOUGH")
        return
    end
    if m_uinpc_abyssrepair.cdtime > time_game then
        chat_addsystemalert("NPC_ABYSSREPAIR_STARTCDING")
        return
    end
    messagebox_confirm("NPC_ABYSSREPAIR_CONFIRM", abyssrepair_delegate_startconfirm, m_uinpc_abyssrepair.npcactorid)
end

function abyssrepair_delegate_close()
    m_uinpc_abyssrepair:close()
end
