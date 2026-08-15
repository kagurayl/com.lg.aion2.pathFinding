
local m_uinpc_artifact = uipanel_createhandle("npc/artifact", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function artifact_setartifact(actorid, artifactid, cd)
    local config_artifact = c_config_getmetaid(configid.abyss_artifact, artifactid)
    if config_artifact == nil then
        return
    end

    m_uinpc_artifact:open()
    m_uinpc_artifact.npcactorid = actorid
    m_uinpc_artifact.artifactid = artifactid
    m_uinpc_artifact.cdlength = time_game + cd
    m_uinpc_artifact.coldtime = config_artifact.coldtime 

    m_uinpc_artifact:setwidgetdelegate("button_start", artifact_delegate_start)
    m_uinpc_artifact:setwidgetdelegate("image_bg/button_close", artifact_delegate_close)

    local text_title = m_uinpc_artifact:getwidget("image_bg/text_title")
    text_title:settext(config_artifact.name)

    local text_skillspell = m_uinpc_artifact:getwidget("text_skillspell")
    text_skillspell:settext("NPC_ARTIFACT_SPELL", timerdesc_getdesc(config_artifact.spell, true, true, true))

    local itemcount = string.split(config_artifact.item, "x")
    m_uinpc_artifact.artifactname = config_artifact.name
    m_uinpc_artifact.itemid = string.tointeger(itemcount[1])
    m_uinpc_artifact.itemcount = string.tointeger(itemcount[2])
    local config_item = csvitem_getfromid(m_uinpc_artifact.itemid)
    if config_item ~= nil then
        local image_icon = m_uinpc_artifact:getwidget("image_icon")
        image_icon:seticon(config_item.icon)

        local text_count = m_uinpc_artifact:getwidget("text_count")
        text_count:settext(m_uinpc_artifact.itemcount)

        local text_name = m_uinpc_artifact:getwidget("text_name")
        text_name:settext(csvitem_getcolorname(config_item) .. "x" .. m_uinpc_artifact.itemcount)
        if playeritem_getcount(m_uinpc_artifact.itemid) >= m_uinpc_artifact.itemcount then
            text_name:setcolor(1,1,1,1)
        else
            text_name:setcolor(1,0,0,1)
        end
    end

    local text_skillarea = m_uinpc_artifact:getwidget("text_skillarea")
    text_skillarea:settext(config_artifact.skillarea)

    local text_skilleffect = m_uinpc_artifact:getwidget("text_skilleffect")
    text_skilleffect:settext(config_artifact.skilleffect)

    event_register(eventtype.update, artifact_update, m_uinpc_artifact)
    artifact_update()
end

function artifact_update()
    if m_uinpc_artifact:null() then
        return
    end
    local text_cd = m_uinpc_artifact:getwidget("text_cd")
    local cd = m_uinpc_artifact.cdlength - time_game
    if cd > 0 then
        text_cd:settext("NPC_ARTIFACT_CDING", timerdesc_getafter(cd))
        text_cd:setcolor(1,0,0,1)
    else
        text_cd:settext("NPC_ARTIFACT_CD", timerdesc_getafter(m_uinpc_artifact.coldtime))
        text_cd:setcolor(1,1,1,1)
    end
end

function artifact_delegate_startconfirm(ok, npcactorid)
    if ok then
        local msg = {messageid="CS_AbyssArtifactSpell"}
        msg.actorid = npcactorid
        c_send(msg)
        m_uinpc_artifact:close()
    end
end

function artifact_delegate_start()
    if playeritem_getcount(m_uinpc_artifact.itemid) < m_uinpc_artifact.itemcount then
        chat_addsystemalert("NPC_ARTIFACT_ITEMNOTENOUGH")
        return
    end
    if m_uinpc_artifact.cdlength > time_game then
        chat_addsystemalert("NPC_ARTIFACT_STARTCDING")
        return
    end
    messagebox_confirm(c_textformat("NPC_ARTIFACT_CONFIRM", m_uinpc_artifact.artifactname), artifact_delegate_startconfirm, m_uinpc_artifact.npcactorid)
end

function artifact_delegate_close()
    m_uinpc_artifact:close()
end
