
local m_uicgvideo = uipanel_createhandle("root/cgvideo", uilayer.cover, uiflag.cgmodevisible)

function cgvideo_start(filename)
    local videopath = string.lower(string.format("sequences/video/%s.mp4", filename))
    local length = c_system_playvideo(videopath)
    if length <= 0.0 then
        return
    end
    m_uicgvideo:open()
    m_uicgvideo:setwidgetdelegate("button_skip", cgvideo_delegate_skip)
    local image_blackup = m_uicgvideo:getwidget("image_blackup")
    local image_blackdown = m_uicgvideo:getwidget("image_blackdown")
    local screenwidth, screenheight = c_system_screensize()
    local fitsize = screenheight - screenwidth * 0.5625
    if fitsize > 0 then
        fitsize = math.floor(fitsize / 2.0) + 10.0
        image_blackup:setsize(screenwidth, fitsize)
        image_blackdown:setsize(screenwidth, fitsize)
        image_blackdown:setposition(0, fitsize)
    else
        image_blackup:setsize(0, 0)
        image_blackdown:setsize(0, 0)
    end

    m_uicgvideo.cgtimeend = time_game + length
    m_uicgvideo:open()
    uimanager_setcgmode(true)
    event_register(eventtype.update, cgvideo_update, m_uicgvideo)
end

function cgvideo_update()
    if m_uicgvideo.cgtimeend <= time_game then
        cgvideo_delegate_skip()
    end
end

function cgvideo_delegate_skip()
    c_system_stopvideo()
    event_deregister(eventtype.update, cgvideo_update)
    m_uicgvideo:close()
    uimanager_setcgmode(false)
end

function cgvideo_alive()
    return m_uicgvideo:alive()
end
