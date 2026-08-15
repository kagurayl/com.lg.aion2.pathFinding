
function skillslot_showicon(slot, visible, hideempty)
	slot.qtevisible = nil
    slot.cdcovervisible = nil
    slot.cdtextvisible = nil
    slot.busyvisible = nil
    slot.qteanim = nil
    slot.iconfxvisible = nil
    slot.slotvisible = visible
	slot.text_count:setvisiblenothit(visible)
	slot.text_cd:setvisiblenothit(visible)
   
	slot.image_cd:setvisiblenothit(visible)
    slot.image_busy:setvisiblenothit(visible)
	slot.image_qte:setvisiblenothit(visible)
    slot.image_marker:setvisiblenothit(visible)
	slot.text_qtecount:setvisiblenothit(visible)
	slot.image_icon:setvisible(visible)
    slot.image_iconfx:setvisible(visible)
    slot.image_preset:setvisiblenothit(visible)
    if slot.image_empty ~= nil then
        slot.image_empty:setvisible(not visible and not hideempty)
    end
    if system_ispc() and (visible or not hideempty) then
        slot.text_key:setvisiblenothit(true)
        local key = gamesetting_getkeyval(slot.keyname)
        if key ~= nil and #key > 0 then
            slot.text_key:settext(key)
        else
            slot.text_key:settext("")
        end
    else
        slot.text_key:setvisiblenothit(false)
    end
end

function skillslot_createslot(panel, slotname, markername, keyname)
    local slot = {}
    slot.slotroot = panel:getwidget(slotname)
    slot.text_count = panel:getwidget(string.format("%s/text_count", slotname))
    slot.text_cd = panel:getwidget(string.format("%s/text_cd", slotname))
    slot.text_key = panel:getwidget(string.format("%s/text_key", slotname))
    slot.image_cd = panel:getwidget(string.format("%s/image_cd", slotname))
    slot.image_busy = panel:getwidget(string.format("%s/image_busy", slotname))
    slot.image_qte = panel:getwidget(string.format("%s/image_qte", slotname))
    slot.image_marker = panel:getwidget(markername)
    slot.text_qtecount = panel:getwidget(string.format("%s/text_qtecount", slotname))
    slot.image_icon = panel:getwidget(string.format("%s/image_icon", slotname))
    slot.image_iconfx = panel:getwidget(string.format("%s/image_iconfx", slotname))
    slot.image_empty = panel:getwidget(string.format("%s/image_empty", slotname))
    slot.image_preset = panel:getwidget(string.format("%s/image_preset", slotname))
    slot.slotroot:setdelegate(skillslot_delegate_skill)
    slot.slotroot.slot = slot
    slot.keyname = keyname
    skillslot_showicon(slot, false, false)
    return slot
end

function skillslot_setskillicon(slot, icon, iconpreset, count, warning)
	slot.image_icon:seticon(icon)
    slot.image_icon:setavailablecolor(not warning)
    if iconpreset ~= nil then
        slot.image_preset:seticon(iconpreset)
    else
        slot.image_preset:setvisible(false)
    end
    if count ~= nil then
        slot.text_count:settext(count)
        slot.text_count:setwarningcolor(warning)
    else
    	slot.text_count:settext("")
    end
	slot.text_cd:setvisible(false)
	slot.image_cd:setvisible(false)
    slot.image_busy:setvisible(false)
	slot.image_qte:setvisible(false)
    slot.image_marker:setvisible(false)
    slot.image_iconfx:setvisible(false)
	slot.text_qtecount:setvisible(false)
	slot.qtevisible = nil
    slot.cdcovervisible = nil
    slot.cdtextvisible = nil
    slot.busyvisible = nil
end

function skillslot_updateslot(slot, attr, hideemptyskillbar)
    slot.config_skill = nil
    slot.config_social = nil
    slot.config_item = nil
    slot.config_crafting = nil
    slot.preset = nil
    slot.uuid = 0
    if attr == nil then
        skillslot_showicon(slot, false, hideemptyskillbar)
        return
    end
    local icon = nil
    local iconpreset = nil
    local warning = false
    local count = nil
    if attr.type == csvskillslottype.skill then
        slot.config_skill = csvskill_getfromid(attr.skillid)
        if slot.config_skill ~= nil then
            local config_toplevel = nil
           	if playerattr_isvehicle() then
                config_toplevel = slot.config_skill
            else
                config_toplevel = playerskill_gettoplevelavailable(slot.config_skill)
            end
            if config_toplevel ~= nil then
                slot.config_skill = config_toplevel
            else
                warning = true
            end
            icon = slot.config_skill.icon
            count = playerskill_getitemcount(slot.config_skill)
        end
    elseif attr.type == csvskillslottype.preset then
        slot.preset = playerskillpreset_getpreset(attr.uuid)
        if slot.preset ~= nil then
            icon = playerskillpreset_geticon(slot.preset.icon)
            iconpreset = icon
            local config_skill = csvskill_getfromid(slot.preset.skillid[1])
            if config_skill ~= nil then
                local config_toplevel = playerskill_gettoplevelavailable(config_skill)
                if config_toplevel ~= nil then
                    config_skill = config_toplevel
                end
                icon = config_skill.icon
                count = playerskill_getitemcount(config_skill)
            end
        end
    elseif attr.type == csvskillslottype.social then
        slot.config_social = csvskillsocial_getfromid(attr.skillid)
        if slot.config_social ~= nil then
            icon = slot.config_social.icon
        end
    elseif attr.type == csvskillslottype.item then
        slot.config_item = csvitem_getfromid(attr.skillid)
        if slot.config_item ~= nil then
            slot.uuid = attr.uuid
            icon = slot.config_item.icon
            count = 0
            if csvitem_isequip(slot.config_item) then
                if playeritem_getfromuuid(attr.uuid) ~= nil then
                    count = 1
                end
            else
                count = playeritem_getcount(slot.config_item.id)
            end
            warning = count == 0
        end
    elseif attr.type == csvskillslottype.crafting then
        slot.config_crafting = csvskill_getfromid(attr.skillid)
        if slot.config_crafting ~= nil then
            icon = slot.config_crafting.icon
            count = playerskill_getcraftingskilllevel(attr.skillid)
        end
    end
    if icon ~= nil then
        skillslot_showicon(slot, true, hideemptyskillbar)
        skillslot_setskillicon(slot, icon, iconpreset, count, warning)
    else
        skillslot_showicon(slot, false, hideemptyskillbar)
    end
end

function skillslot_updatecd(slot)
    if not slot.slotvisible then
        return
    end
    local cdlength = 0
    local cdremain = 0
    local viewskill = nil
    local qteskill = nil
    local qteiconalways = false
    local qteanimalways = false
    local qteanim = false
    local busyvisible = false
    local cdcovervisible = false
    local iconfxvisible = false
    if slot.config_item ~= nil then
        cdlength, cdremain = timer_getcdfromid(cdtype_itemcd, slot.config_item.cdid)
        if csvitem_isequip(slot.config_item) then
            busyvisible = playeritem_getfrombaguuid(slot.uuid) == nil
        else
            busyvisible = playeritem_getcount(slot.config_item.id) <= 0
        end        
    elseif slot.config_skill ~= nil then
        viewskill = slot.config_skill
        if m_me ~= nil then
            if viewskill.spellway == csvskillspellway.toggle then
                for buffindex=1, #m_me.buff do
                    local buff = m_me.buff[buffindex]
                    if buff.skillid == viewskill.id then
                        iconfxvisible = true
                        break
                    end
                end
            elseif playerattr_info.spiritid ~= 0 and csvskill_issystemskill(viewskill.id) then
                if viewskill.id == skill_system_spiritattack then
                    iconfxvisible = playerattr_info.spiritstate == spiritstate.attack
                elseif viewskill.id == skill_system_spiritmove then
                    iconfxvisible = playerattr_info.spiritstate == spiritstate.move
                elseif viewskill.id == skill_system_spiritidle then
                    iconfxvisible = playerattr_info.spiritstate == spiritstate.idle
                elseif viewskill.id == skill_system_spiritdismiss then
                    iconfxvisible = playerattr_info.spiritstate == spiritstate.dismiss
                end
            end
        end
    elseif slot.preset ~= nil then
        local skillindex, qtevfx = playerskillpreset_getactive(slot.preset)
        if skillindex ~= 0 and slot.preset.skillid[skillindex] ~= 0 then
            viewskill = csvskill_getfromid(slot.preset.skillid[skillindex])
            local config_toplevel = playerskill_gettoplevelavailable(viewskill)
            if config_toplevel ~= nil then
                viewskill = config_toplevel
            end
            qteiconalways = true
            qteanimalways = qtevfx
        else
            if slot.preset.skillid[1] ~= 0 then
                viewskill = csvskill_getfromid(slot.preset.skillid[1])
            end
        end
        if playerattr_skillpresetactive ~= nil and playerattr_skillpresetactive == slot.preset.uuid then
            iconfxvisible = true
        end
    end
    if viewskill ~= nil then
        if playerskill_isactiveqte(viewskill) then
            qteskill = viewskill
        else
            qteskill = playerskill_getqte(viewskill)
            if qteskill == nil then
                qteskill = playerskill_getcounterqte(viewskill)
            end
        end
        local realqte = true
        if qteiconalways and qteskill == nil then
            qteskill = viewskill
            realqte = false
        end
        if qteskill ~= nil then
            cdlength, cdremain = timer_getcdfromskill(qteskill)
            if playerskill_getgcd(qteskill) or not playerskill_spellable(qteskill) then
                busyvisible = true
            elseif realqte then
                qteanim = true
            else
                qteanim = qteanimalways
            end
        elseif viewskill ~= nil then
            local skillid = viewskill.id
            cdlength, cdremain = timer_getcdfromskill(viewskill)
            if playerskill_getgcd(viewskill) then
                busyvisible = true
            elseif not playerskill_spellable(viewskill) and not playerattr_isvehicle() then
                busyvisible = true
            elseif skillid >= skill_logo_start and skillid <= skill_logo_end then
                for i=1,#skill_logo_active do
                    if skill_logo_active[i] == skillid then
                        busyvisible = m_selectactorid == 0
                        break
                    end
                end
                for i=1,#skill_logo_select do
                    if skill_logo_select[i] == skillid then
                        busyvisible = true
                        local actorid = playerattr_logo[i]
                        if actorid ~= nil then
                            local logoactor = actormanager_getfromactorid(actorid)
                            if logoactor ~= nil then
                                busyvisible = false
                                if logoactor.actionmain.buffhidelevel ~= nil and logoactor.actionmain.buffhidelevel > 0 then
                                    if m_me ~= nil and m_me.actionmain.searchlevel ~= nil and m_me.actionmain.searchlevel >= logoactor.actionmain.buffhidelevel then
                                        busyvisible = false
                                    else
                                        busyvisible = true
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    if iconfxvisible ~= slot.iconfxvisible then
        slot.iconfxvisible = iconfxvisible
        slot.image_iconfx:setvisiblenothit(iconfxvisible)
    end
    if busyvisible ~= slot.busyvisible then
        slot.busyvisible = busyvisible
        slot.image_busy:setvisiblenothit(busyvisible)
    end
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
    local qtevisible = qteskill ~= nil
    if qtevisible then
        if slot.config_qte == nil or slot.config_qte.id ~= qteskill.id then
            slot.config_qte = qteskill
            slot.image_qte:seticon(qteskill.icon)
            slot.text_qtecount:settext(qteskill.level)
        end
    end
    if qtevisible ~= slot.qtevisible then
        slot.qtevisible = qtevisible
        if not qtevisible then
            slot.config_qte = nil
        end
        slot.image_qte:setvisiblenothit(qtevisible)
        slot.text_count:setvisiblenothit(not qtevisible)
        slot.text_qtecount:setvisiblenothit(qtevisible)
    end
    if qteanim ~= slot.qteanim then
        slot.qteanim = qteanim
        slot.image_marker:setvisiblenothit(qteanim)
        if qteanim then
            slot.image_qte:playuianim("qtecolor", 1.0)
            slot.image_marker:playuianim("qtemarker", 1.0)
        else
            slot.image_qte:stopuianim()
            slot.image_qte:setcolor(1.0, 1.0, 1.0, 1.0)
            slot.image_marker:stopuianim()
        end
    end
    if slot.presstime ~= nil and time_game - slot.presstime > 0.5 then
        if time_game - slot.presstime < 2.0 then
            local x,y,w,h = slot.image_icon:getabsolute()
            if slot.config_item ~= nil then
                local item = playeritem_getfrombaguuid(slot.uuid)
                if item == nil then
                    item = playeritem_getfromequipuuid(slot.uuid)
                end
                local itemid = slot.config_item.id
                tips_item(itemid, playeritem_getcount(itemid), x, y + h, tipsflag.vleft, item, slot.image_icon._panel)
            elseif viewskill ~= nil then
                tips_skill(viewskill, x, y + h, tipsflag.vleft, slot.image_icon._panel)
            elseif slot.config_social ~= nil then
                tips_social(slot.config_social, x, y + h, tipsflag.vleft, slot.image_icon._panel)
            elseif slot.config_crafting ~= nil then
                local config_skill = csvskill_getfromid(slot.config_crafting.id)
                if config_skill ~= nil then
                    tips_skill(config_skill, x, y + h, tipsflag.vleft, slot.image_icon._panel)
                end
            end
        end
        slot.presstime = nil
    end
end

function skillslot_executeslot(slot)
    if slot.config_skill ~= nil then
        playerbattle_spell(slot.config_skill.id)
    elseif slot.preset ~= nil then
        if slot.preset.type == csvskillpresettype.auto then
            playerattr_skillpresetactive = slot.preset.uuid
            playerbattleauto_startskillpreset(m_selectactorid)
        else
            playerbattle_preset(slot.preset)
        end
    elseif slot.config_social ~= nil then
        if slot.config_social.usetype == socialtarget.any or slot.config_social.usetype == socialtarget.enemy then
            local msg = {messageid="CS_Social"}
            msg.skillid = slot.config_social.id
            msg.target = m_selectactorid
            c_send(msg)
        elseif slot.config_social.usetype == socialtarget.pet then
            local msg = {messageid="CS_PetPlay"}
            msg.socialid = slot.config_social.id
            c_send(msg)
        end
    elseif slot.config_item ~= nil then
        bag_consumeitem(slot.uuid, slot.config_item.id)
    elseif slot.config_crafting ~= nil then
        local skillid = slot.config_crafting.id
        if skillid >= skill_gather_cooking and skillid <= skill_gather_convert then
            crafting_open(nil, skillid)
        elseif skillid == skill_gather_low or skillid == skill_gather_land or skillid == skill_gather_od then
            local actor = actormanager_getfromactorid(m_selectactorid)
            if actor ~= nil and actor:isharvest() then
                npc_startscript(m_selectactorid)
            end
        end
    end
end

function skillslot_delegate_skill(sender, event)
    local slot = sender.slot
    if event.name == "mousedown" then
        slot.presstime = time_game
        tips_close()
	elseif event.name == "mouseup" then
        if slot.presstime == nil then
            return
        end
        slot.presstime = nil
        skillslot_executeslot(slot)
    end
end
