
function settingapply_updatename()
    local actorlist = actormanager_getactorlist()
    for key, actor in pairs(actorlist) do
        actor:createnameplate()
        if actor.namewidget ~= nil then
            actor:updatenameuilayout()
        end
    end
end

function settingapply_updateactor()
    local actorlist = actormanager_getactorlist()
    for key, actor in pairs(actorlist) do
        actor:updateactorvisible()
    end
end

function settingapply_sendprivacy()
    local msg = {messageid="CS_SetPrivacy"}
    msg.query = gamesetting_getnumber("REFUSEQUERY")
    msg.deal = gamesetting_getnumber("REFUSEDEAL")
    msg.team = gamesetting_getnumber("REFUSETEAM")
    msg.icc = gamesetting_getnumber("REFUSEICC")
    msg.pal = gamesetting_getnumber("REFUSEPAL")
    msg.pk = gamesetting_getnumber("REFUSEPK")
    c_send(msg)
end

function settingapply_playername()
    settingapply_updatename()
end

function settingapply_teamname()
    settingapply_updatename()
end

function settingapply_raidname()
    settingapply_updatename()
end

function settingapply_flockname()
    settingapply_updatename()
end

function settingapply_sipidname()
    settingapply_updatename()
end

function settingapply_enemyname()
    settingapply_updatename()
end

function settingapply_npcname()
    settingapply_updatename()
end

function settingapply_monstername()
    settingapply_updatename()
end

function settingapply_title()
    settingapply_updatename()
end

function settingapply_pvptitle()
    settingapply_updatename()
end

function settingapply_iccname()
    settingapply_updatename()
end

function settingapply_teamme()
    sidebar_updateteam()
end

function settingapply_normalquest()
    playerquest_updatenpcicon()
    actormanager_updatehead()
    mapopacity_updateui()
end

function settingapply_lowlevelquest()
    playerquest_updatenpcicon()
    actormanager_updatehead()
end

function settingapply_renderhelmet()
    local msg = {messageid="CS_RenderHelmet"}
    msg.render = gamesetting_getnumber("RENDERHELMET")
    c_send(msg)
    if m_me ~= nil then
        m_me:setreloadasset(false)
    end
end

function settingapply_renderemblem()
    local msg = {messageid="CS_RenderEmblem"}
    msg.render = gamesetting_getnumber("RENDEREMBLEM")
    c_send(msg)
    if m_me ~= nil then
        m_me:setreloadasset(false)
    end
end

function settingapply_enemyplayeractor()
    settingapply_updateactor()
end

function settingapply_enemynpcactor()
    settingapply_updateactor()
end

function settingapply_sipidplayeractor()
    settingapply_updateactor()
end

function settingapply_sipidnpcactor()
    settingapply_updateactor()
end

function settingapply_teamactor()
    settingapply_updateactor()
end

function settingapply_refusequery()
    settingapply_sendprivacy()
end

function settingapply_refusedeal()
    settingapply_sendprivacy()
end

function settingapply_refuseteam()
    settingapply_sendprivacy()
end

function settingapply_refuseicc()
    settingapply_sendprivacy()
end

function settingapply_refusepal()
    settingapply_sendprivacy()
end

function settingapply_refusepk()
    settingapply_sendprivacy()
end

function settingapply_camerarange(setting, fromui)
    local dist = tonumber(setting.current)
    if dist ~= nil then
        dist = math.lerp(setting.data.min, setting.data.max, dist)
        maincamera_setrangescale(dist)
    end
end

function settingapply_orientation(setting, fromui)
    if setting.current == "0" then
        c_system_setengine("orientation", 3)
    else
        c_system_setengine("orientation", 4)
    end
end

function settingapply_uiscale(setting, fromui)
    local scale = tonumber(setting.current)
    if scale ~= nil then
        scale = math.lerp(setting.data.min, setting.data.max, scale)
        uimanager_setscale(scale)
    end
end

function settingapply_mapopacity(setting, fromui)
    local opacity = tonumber(setting.current)
    if opacity ~= nil then
        opacity = math.lerp(setting.data.min, setting.data.max, opacity)
        map_opacity_setopacity(opacity)
    end
end

function settingapply_manualmovein()

end

function settingapply_moveback()

end

function settingapply_actionline2(setting, fromui)
    if setting.current == "0" then
        local gamesetting = gamesetting_get()
        local line3 = gamesetting["ACTIONLINE3"]
        line3.current = "0"
        local line4 = gamesetting["ACTIONLINE4"]
        line4.current = "0"
        gamesetting_savesetting(line3)
        gamesetting_savesetting(line4)
        settingui_setui()
    end
    actionbar_updateui()
end

function settingapply_actionline3(setting, fromui)
    local gamesetting = gamesetting_get()
    if setting.current == "1" then
        local line2 = gamesetting["ACTIONLINE2"]
        line2.current = "1"
        gamesetting_savesetting(line2)
    else
        local line4 = gamesetting["ACTIONLINE4"]
        line4.current = "0"
        gamesetting_savesetting(line4)
    end
    settingui_setui()
    actionbar_updateui()
end

function settingapply_actionline4(setting, fromui)
    if setting.current == "1" then
        local gamesetting = gamesetting_get()
        local line2 = gamesetting["ACTIONLINE2"]
        line2.current = "1"
        local line3 = gamesetting["ACTIONLINE3"]
        line3.current = "1"
        gamesetting_savesetting(line2)
        gamesetting_savesetting(line3)
        settingui_setui()
    end
    actionbar_updateui()
end

function settingapply_hideemptyskillbar()
    skillbar_updateui()
end

function settingapply_musicvolume()
    audiomanager_updatevolume()
end

function settingapply_envmusicvolume()
    audiomanager_updatevolume()
end

function settingapply_envsoundvolume()
    audiomanager_updatevolume()
end

function settingapply_uivolume()
    audiomanager_updatevolume()
end

function settingapply_skillvolume()
    audiomanager_updatevolume()
end

function settingapply_voicevolume()
    audiomanager_updatevolume()
end

function settingapply_alertvolume()
    audiomanager_updatevolume()
end

function settingapply_devicevolume()
    audiomanager_updatevolume()
end

function settingapply_battlemusic()

end

function settingapply_petaudio(setting, fromui)
    if m_me ~= nil and m_me.pet.config_pet ~= nil and m_me.petactor ~= nil then
        m_me:updatepet_playalarmanim()
    end
end

function settingapply_overall(setting, fromui)
    if setting.current == "4" then
        return false
    end
    local gamesetting = gamesetting_get()
    local antialiasing = gamesetting["ANTIALIASING"]
    local shadow = gamesetting["SHADOW"]
    local texture = gamesetting["TEXTURE"]
    local camerafov = gamesetting["CAMERAFOV"]
    local current = string.tointeger(setting.current)
    if current == 1 then
        antialiasing.current = 1
        shadow.current = 1
        texture.current = 1
        camerafov.current = 0
    elseif current == 2 then
        antialiasing.current = 2
        shadow.current = 2
        texture.current = 2
        camerafov.current = 0
    elseif current == 3 then
        antialiasing.current = 3
        shadow.current = 3
        texture.current = 3
        camerafov.current = 0
    end
    gamesetting_savesetting(antialiasing)
    settingapply_antialiasing(antialiasing, false)

    gamesetting_savesetting(shadow)
    settingapply_shadow(shadow, false)

    gamesetting_savesetting(texture)
    settingapply_texture(texture, false)

    gamesetting_savesetting(camerafov)
    settingapply_camerafov(camerafov, false)

    if fromui then
        settingui_setui()
    end
    return true
end

local function settingapply_setoverallcustom()
    local gamesetting = gamesetting_get()
    local overall = gamesetting["OVERALL"]
    overall.current = 4
    gamesetting_savesetting(overall)
    settingui_setui()
end

function settingapply_antialiasing(setting, fromui)
    local index = string.tointeger(setting.current)
    local antialiasingvalue = {0, 2, 4}
    if index ~= nil and index > 0 and index <= #antialiasingvalue then
        c_system_setengine("antialiasing", antialiasingvalue[index])
    else
        c_system_setengine("antialiasing", antialiasingvalue[#antialiasingvalue])
    end
    if fromui then
        settingapply_setoverallcustom()
    end
end

function settingapply_shadow(setting, fromui)
    local index = string.tointeger(setting.current) or 0
    if index == 1 then
        c_system_setengine("shadowquality", -1)
    elseif index == 2 then
        c_system_setengine("shadowquality", 1)
        c_system_setengine("shadowdistance", 20)
    else
        c_system_setengine("shadowquality", 3)
        c_system_setengine("shadowdistance", 40)
    end
    if fromui then
        settingapply_setoverallcustom()
    end
end

function settingapply_texture(setting, fromui)
    local index = string.tointeger(setting.current)
    local mipmapvalue = {2, 1, 0}
    if index ~= nil and index > 0 and index <= #mipmapvalue then
        c_system_setengine("mipmap", mipmapvalue[index])
    else
        c_system_setengine("mipmap", mipmapvalue[#mipmapvalue])
    end
    if fromui then
        settingapply_setoverallcustom()
    end
end

function settingapply_systemfps(setting, fromui)
    if setting.current == "1" then
        c_system_setengine("fpslimit", 0)
    else
        local gamesetting = gamesetting_get()
        local fpslimit = gamesetting["FPSLIMIT"]
        local fps = tonumber(fpslimit.current)
        if fps ~= nil then
            fps = math.lerp(fpslimit.data.min, fpslimit.data.max, fps)
            fps = math.tointegerfloor(fps)
            c_system_setengine("fpslimit", fps)
        else
            c_system_setengine("fpslimit", 0)
        end
    end
    if fromui then
        settingui_setui()
    end
end

function settingapply_fpslimit(setting, fromui)
    local gamesetting = gamesetting_get()
    local systemfps = gamesetting["SYSTEMFPS"]
    if systemfps.current == "0" then
        local fps = tonumber(setting.current)
        if fps ~= nil then
            fps = math.lerp(setting.data.min, setting.data.max, fps)
            fps = math.tointegerfloor(fps)
            c_system_setengine("fpslimit", fps)
        else
            c_system_setengine("fpslimit", 0)
        end
    end
    if fromui then
        settingui_setui()
    end
end

function settingapply_camerafov(setting, fromui)
    local fov = tonumber(setting.current)
    if fov ~= nil then
        fov = math.lerp(setting.data.min, setting.data.max, fov)
        maincamera_setfov(fov)
    end
    if fromui then
        settingui_setui()
    end
end
