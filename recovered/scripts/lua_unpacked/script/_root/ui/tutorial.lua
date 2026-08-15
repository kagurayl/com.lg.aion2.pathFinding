

tutorialid =
{
	skill = 1,
    quest = 2,
    spirit = 3,
    opacitymap = 4,
    playerinfo = 5,
    tipsfly = 64,
}

local m_uitutorial = uipanel_createhandle("root/tutorial", uilayer.tutorial, 0)

function tutorial_onopen()
    event_register(eventtype.update, tutorial_update, m_uitutorial)
end

function tutorial_open(config_tutorial, panel)
    local uiwidget = panel:getwidget(config_tutorial.focus)
    if uiwidget == nil then
        return
    end
    if m_uitutorial:alive() and m_uitutorial.config_tutorial.id == config_tutorial.id then
        return
    end
    local screenwidth, screenheight = c_system_screensize()
    local x,y,w,h = uiwidget:getabsolute()
    local size = string.splitnumber(config_tutorial.size, "x")
    local focuswidth = size[1]
    local focusheight = size[2]
    m_uitutorial.config_tutorial = config_tutorial
    m_uitutorial.timestart = time_game
    m_uitutorial.focusx = (x + w / 2)
    m_uitutorial.focusy = (y + h / 2)
    m_uitutorial.focuswidth = focuswidth
    m_uitutorial.focusheight = focusheight
    m_uitutorial:open()
    local image_bg = m_uitutorial:getwidget("image_bg")
    image_bg:setmaterialvector("_MaskRadius", m_uitutorial.focusx / screenwidth, m_uitutorial.focusy / screenheight, focuswidth / screenwidth, focusheight / screenheight)
    image_bg:setdelegate(tutorial_delegate_bg)

    local text_desc = m_uitutorial:getwidget("text_desc")
    text_desc:settext(config_tutorial.desc)
    local renderwidth, renderheight = text_desc:getrendersize()
    local text_x = m_uitutorial.focusx - renderwidth / 2
    local text_y = m_uitutorial.focusy - focusheight
    text_x = math.clamp(text_x, 200, screenwidth - renderwidth)
    text_y = math.clamp(text_y, renderheight, screenheight)
    text_desc:setposition(text_x, text_y)
end

function tutorial_close()
    m_uitutorial.substep = nil
    m_uitutorial:close()
end

function tutorial_prescript()
    local config_tutorial = m_uitutorial.config_tutorialarray[m_uitutorial.substep]
    if config_tutorial.prescript ~= "0" then
        local func = _G[config_tutorial.prescript]
        if func ~= nil then
            func()
        end
    end
end

function tutorial_start(groupid)
    if not tutorial_getfinish(groupid) then
        local config_tutorialarray = c_config_getmetaarray(configid.tutorial, "groupid", groupid)
        if config_tutorialarray ~= nil and #config_tutorialarray > 0 then
            m_uitutorial.config_tutorialarray = config_tutorialarray
            m_uitutorial.substep = 1
            tutorial_prescript()
            tutorial_check()
        else
            tutorial_close()
        end
    else
        tutorial_close()
    end
end

function tutorial_check()
    if m_uitutorial.substep ~= nil then
        local config_tutorial = m_uitutorial.config_tutorialarray[m_uitutorial.substep]
        local panel = uimanager_getpanel(config_tutorial.uiname)
        if panel ~= nil and panel:alive() and not uimanager_covered(panel) then
            tutorial_open(config_tutorial, panel)
        else
            m_uitutorial:close()
        end
    end
end

function tutorial_getfinish(id)
    if id == 0 or playerattr_info == nil then
        return true
    end
    local bitstep = bit.lshift(1, id - 1)
    local finish = bit.band(playerattr_info.tutorial, bitstep)
    return finish ~= 0
end

function tutorial_setfinish(groupid)
    local bitstep = bit.lshift(1, groupid - 1)
    playerattr_info.tutorial = bit.bor(playerattr_info.tutorial, bitstep)
    if m_uitutorial.config_tutorial ~= nil and m_uitutorial.config_tutorial.groupid == groupid then
        tutorial_close()
    end
end

function tutorial_gettimefade()
    local time = time_game - m_uitutorial.timestart
    local t = time * 2.0
    return t
end

function tutorial_update()
    local image_bg = m_uitutorial:getwidget("image_bg")
    local t = tutorial_gettimefade()
    local screenwidth, screenheight = c_system_screensize()
    local focusx = m_uitutorial.focusx
    local focusy = m_uitutorial.focusy
    local focuswidth = m_uitutorial.focuswidth
    local focusheight = m_uitutorial.focusheight
    if t < 1.0 then
        local startwidth = m_uitutorial.focuswidth * 5
        local startheight = m_uitutorial.focusheight * 5
        focuswidth = math.lerp(startwidth, focuswidth, t)
        focusheight = math.lerp(startheight, focusheight, t)
    end
    image_bg:setmaterialvector("_MaskRadius", focusx / screenwidth, focusy / screenheight, focuswidth / screenwidth, focusheight / screenheight)
end

function tutorial_delegate_bg(sender, event)
    if tutorial_gettimefade() >= 1.0 then
        if m_uitutorial.config_tutorial.script ~= "0" then
            local func = _G[m_uitutorial.config_tutorial.script]
            if func ~= nil then
                func()
            end
        end
        if m_uitutorial.substep < #m_uitutorial.config_tutorialarray then
            m_uitutorial.substep = m_uitutorial.substep + 1
            tutorial_prescript()
            tutorial_check()
        else
            local msg = {messageid="CS_Tutorial"}
            msg.id = m_uitutorial.config_tutorial.groupid
            c_send(msg)
        end
    end
end

function tutorial_openhomemenu()
    homemenu_create()
end

function tutorial_openskillmain()
    m_uiskill_main:open()
    skill_main_delegate_normal()
end

function tutorial_closeskillmain()
    m_uiskill_main:close()
end

function tutorial_openquest()
    quest_main_showquest(0, true)
end

function tutorial_openteam()
    sidebar_openteam()
end
