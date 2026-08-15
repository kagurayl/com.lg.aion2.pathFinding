
local cgmaskstate =
{
    downloading = 1,
    startfadeout = 2,
    startfadein = 3,
    playing = 4,
    stopfadein = 5,
}
local cgcamerafadestate =
{
    none = 0,
    fadein = 1,
    fadeout = 2,
}
local m_uicgmask = uipanel_createhandle("root/cgmask", uilayer.cover, uiflag.cgmodevisible)

function cgmask_start(name, timeskip, timelength, syncstop)
    m_uicgmask.state = cgmaskstate.startfadeout

    local filename = string.lower(string.format("sequences/cutscene/%s.prefab", name))
    local location, completesize, totalsize = downloading_queryfile(filename)
    if location == assetlocation.remote then
        downloading_startfile(filename)
        m_uicgmask.state = cgmaskstate.downloading
    elseif location == assetlocation.downloading then
        m_uicgmask.state = cgmaskstate.downloading
    end
    if m_uicgmask.state ~= cgmaskstate.downloading then
        local success = c_scene_cgload(filename)
        if not success then
            return
        end
    end
    m_uicgmask:open()
    m_uicgmask.statetimestart = time_game
    m_uicgmask.statetimeend = m_uicgmask.statetimestart + 0.5
    m_uicgmask.cgfilename = filename
    m_uicgmask.cgtimeskip = timeskip
    m_uicgmask.cgtimelength = timelength
    m_uicgmask.cgcamerafade = cgcamerafadestate.none
    m_uicgmask.resetposx = m_me.attr.posx
    m_uicgmask.resetposy = m_me.attr.posy
    m_uicgmask.resetposz = m_me.attr.posz
    m_uicgmask.resetrot = m_me.attr.rot
    m_uicgmask.syncstop = syncstop
    m_uicgmask:setwidgetvisible("button_skip", false)
    m_uicgmask:setwidgetvisible("text_message", false)
    m_uicgmask:setwidgetvisible("image_blackup", false)
    m_uicgmask:setwidgetvisible("image_blackdown", false)
    m_uicgmask:setwidgetdelegate("button_skip", cgmask_delegate_skip)
    local image_black = m_uicgmask:getwidget("image_black")
    image_black:setcolor(1.0, 1.0, 1.0, 0.0)
    uimanager_setcgmode(true)
    event_register(eventtype.update, cgmask_update, m_uicgmask)
end

function cgmask_onclose()
    cgmask_stop()
end

function cgmask_stop()
    if m_uicgmask:alive() then
        if m_uicgmask.resetrot ~= nil then
            m_me.attr.posx = m_uicgmask.resetposx
            m_me.attr.posy = m_uicgmask.resetposy
            m_me.attr.posz = m_uicgmask.resetposz
            m_me.attr.rot = m_uicgmask.resetrot
            m_me:updateactorposition()
            m_uicgmask.resetrot = nil
        end
    end
    m_uicgmask:close()
    event_deregister(eventtype.update, cgmask_update)
    c_scene_cgstop()
    uimanager_setcgmode(false)
    if m_me ~= nil then
        m_me.actordata.sequencetimestart = nil
    end
    if m_uicgmask.syncstop then
        m_uicgmask.syncstop = false
        local msg = {messageid="CS_StopMovie"}
        c_send(msg)
    end
    scene_updatezone()
end

function cgmask_playing()
    return m_uicgmask:alive()
end

function cgmask_update()
    local maskopacity = 0.0
    if m_uicgmask.state == cgmaskstate.downloading then
        local image_black = m_uicgmask:getwidget("image_black")
        local fadeout = time_game < m_uicgmask.statetimeend
        if fadeout then
            local opacity = (time_game - m_uicgmask.statetimestart) / (m_uicgmask.statetimeend - m_uicgmask.statetimestart)
            image_black:setcolor(1.0, 1.0, 1.0, opacity)
        else
            image_black:setcolor(1.0, 1.0, 1.0, 1.0)
        end
        
        local text_message = m_uicgmask:getwidget("text_message")
        local location, completesize, totalsize = downloading_queryfile(m_uicgmask.cgfilename)
        if location == assetlocation.downloading then
            if not fadeout then
                m_uicgmask:setwidgetvisible("button_skip", true)
                text_message:settext("DOWNLOADER_CGDOWNLOADING", downloading_getdesc(completesize), downloading_getdesc(totalsize))
                text_message:setvisible(true)
            end
        else
            m_uicgmask.state = cgmaskstate.startfadeout
            text_message:setvisible(false)
            local success = c_scene_cgload(m_uicgmask.cgfilename)
            if not success then
                cgmask_stop()
            end
        end
        return
    elseif m_uicgmask.state == cgmaskstate.startfadeout then
        if time_game < m_uicgmask.statetimeend then
            local opacity = (time_game - m_uicgmask.statetimestart) / (m_uicgmask.statetimeend - m_uicgmask.statetimestart)
            local image_black = m_uicgmask:getwidget("image_black")
            image_black:setcolor(1.0, 1.0, 1.0, opacity)
            return
        end
        maskopacity = 1.0
        local success = c_scene_cgstart(m_me.id, m_me:getcgvoice(), m_uicgmask.cgtimeskip)
        if success then
            local mask = bit.lshift(1, RenderLayerScene)
            mask = bit.bor(mask, bit.lshift(1, RenderLayerTerrain))
            mask = bit.bor(mask, bit.lshift(1, RenderLayerCG))
            mask = bit.bor(mask, bit.lshift(1, RenderLayerMe))
            mask = bit.bor(mask, bit.lshift(1, RenderLayerStaticNPC))

            c_scene_cgcull(mask)
            m_uicgmask:setwidgetvisible("image_blackup", true)
            m_uicgmask:setwidgetvisible("image_blackdown", true)
            m_uicgmask:setwidgetvisible("button_skip", true)
            m_uicgmask.state = cgmaskstate.startfadein
            m_uicgmask.statetimeend = time_game + 0.5
            m_uicgmask.timeend = time_game + m_uicgmask.cgtimelength
            if m_me ~= nil then
                m_me.actordata.sequencetimestart = time_game
                m_me.actordata.sequencecg = true
            end
        end
    elseif m_uicgmask.state == cgmaskstate.startfadein then
        if time_game < m_uicgmask.statetimeend then
            maskopacity = (time_game - m_uicgmask.statetimestart) / (m_uicgmask.statetimeend - m_uicgmask.statetimestart)
            maskopacity = 1.0 - maskopacity ^ 5
        else
            m_uicgmask.state = cgmaskstate.playing
        end
    elseif m_uicgmask.state == cgmaskstate.playing then
        if m_uicgmask.timeend <= time_game then
            m_uicgmask.cgcamerafade = cgcamerafadestate.none
            m_uicgmask.state = cgmaskstate.stopfadein
            m_uicgmask.statetimestart = m_uicgmask.timeend
            m_uicgmask.statetimeend =  m_uicgmask.statetimestart + 0.75
            m_uicgmask:setwidgetvisible("button_skip", false)
            m_uicgmask:setwidgetvisible("text_message", false)
            m_uicgmask:setwidgetvisible("image_blackup", false)
            m_uicgmask:setwidgetvisible("image_blackdown", false)
            c_scene_cgstop()
            uimanager_setcgmode(false)
            maskopacity = 1.0
        end
    elseif m_uicgmask.state == cgmaskstate.stopfadein then
        if time_game < m_uicgmask.statetimeend then
            maskopacity = (time_game - m_uicgmask.statetimestart) / (m_uicgmask.statetimeend - m_uicgmask.statetimestart)
            maskopacity = 1.0 - maskopacity ^ 5
        else
            cgmask_stop()
            return
        end
    end

    if m_uicgmask.cgcamerafade == cgcamerafadestate.fadein or m_uicgmask.cgcamerafade == cgcamerafadestate.fadeout then
        local timepos = time_game - m_uicgmask.masktimestart
        if timepos < m_uicgmask.masktimeprefade then
            if m_uicgmask.cgcamerafade == cgcamerafadestate.fadein then
                maskopacity = 1.0
            end
        elseif timepos < m_uicgmask.masktimefade then
            local opacity = timepos / m_uicgmask.masktimefade
            if m_uicgmask.cgcamerafade == cgcamerafadestate.fadein then
                opacity = 1.0 - opacity ^ 5
            end
            maskopacity = math.max(maskopacity, opacity)
        else
            if m_uicgmask.cgcamerafade == cgcamerafadestate.fadein then
                m_uicgmask.cgcamerafade = cgcamerafadestate.none
            else
                maskopacity = 1.0
            end
        end
    end
    local image_black = m_uicgmask:getwidget("image_black")
    image_black:setcolor(1.0, 1.0, 1.0, maskopacity)
end

function cgmask_event(actorid, str)
    local substr = string.split(str, ":")
    if #substr ~= 2 then
        return
    end
    local type = substr[1]
    local val = substr[2]
    if type == "command" then
        if val == "labelclear" then
            if m_uicgmask:alive() then
                m_uicgmask:setwidgetvisible("text_message", false)
            end
        end
    elseif type == "camerafadein" then
        if m_uicgmask:alive() then
            local parm = string.split(val, ",")
            m_uicgmask.cgcamerafade = cgcamerafadestate.fadein
            m_uicgmask.masktimestart = time_game
            m_uicgmask.masktimeprefade = tonumber(parm[1])
            m_uicgmask.masktimefade = tonumber(parm[2])
            if m_uicgmask.state == cgmaskstate.startfadein then
                m_uicgmask.state = cgmaskstate.playing
                local image_black = m_uicgmask:getwidget("image_black")
                image_black:setcolor(1.0, 1.0, 1.0, 1.0)
            end
        end
    elseif type == "camerafadeout" then
        if m_uicgmask:alive() then
            local parm = string.split(val, ",")
            m_uicgmask.cgcamerafade = cgcamerafadestate.fadeout
            m_uicgmask.masktimestart = time_game
            m_uicgmask.masktimeprefade = tonumber(parm[1])
            m_uicgmask.masktimefade = tonumber(parm[2])
        end
    elseif type == "label" then
        if m_uicgmask:alive() then
            if c_textkey(val) then
                local text_message = m_uicgmask:getwidget("text_message")
                text_message:settext(val)
                text_message:setvisible(true)
            end
        end
    elseif type == "anim" then
        local parm = string.split(val, ",")
        local actor = actormanager_getfromscriptid(actorid)
        if actor ~= nil and actor.actordata.sequencetimestart ~= nil then
            actor.actordata.sequenceanim = parm[1]
            actor.actordata.sequenceanimblend = tonumber(parm[2])
            actor.actordata.sequenceanimskip = tonumber(parm[3])
            actor.actordata.sequenceanimspeed = tonumber(parm[4])
        end
    elseif type == "wing" then
        local actor = actormanager_getfromscriptid(actorid)
        if actor ~= nil and actor.actordata.sequencetimestart ~= nil then
            actor.actordata.sequencewingvisible = val == "1"
        end
    elseif type == "replace" then
        local actor = actormanager_getfromscriptid(actorid)
        if actor ~= nil and actor.actordata.sequencetimestart ~= nil then
            local pos = string.split(val, ",")
            actor.attr.posx = tonumber(pos[1])
            actor.attr.posy = tonumber(pos[2])
            actor.attr.posz = tonumber(pos[3])
            actor.attr.rot = tonumber(pos[4])
            actor.transform.px = actor.attr.posx
            actor.transform.py = actor.attr.posy
            actor.transform.pz = actor.attr.posz
            actor.transform.ry = actor.attr.rot
            if actor:isme() then
                maincamera_lookat(actor.attr.posx, actor.attr.posy + actor.actordata.cameraheight * actor:getscale(), actor.attr.posz, true)
            end
        end
    elseif type == "vfx" then
        local actor = actormanager_getfromscriptid(actorid)
        if actor ~= nil then
            local vfxparm = string.split(val, ",")
            local time = tonumber(vfxparm[1])
            local scale = tonumber(vfxparm[2])
            local bonename = vfxparm[3]
            local effectpath = vfxparm[4]
            local vfx = vfxmanager_createvfx(effectpath)
            vfx:setposition(actor.attr.posx, actor.attr.posy, actor.attr.posz)
            vfx:setscale(scale, scale, scale)
            vfx:setbind(actor, bonename, vfxflag.bindposition)
            vfx:setfree()
        end
    end
end

function cgmask_delegate_skip()
    cgmask_stop()
end
