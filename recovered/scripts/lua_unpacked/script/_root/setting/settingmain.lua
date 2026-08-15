
function setting_main_onopen()
    m_uisetting_settingmain:setwidgetdelegate("button_reset", setting_main_delegate_reset)
    m_uisetting_settingmain:setwidgetdelegate("image_bg/button_close", setting_main_delegate_close)

    m_uisetting_settingmain.tabmain = uitabcreate(m_uisetting_settingmain)
    m_uisetting_settingmain.tabmain:add("button_game", "tab_game")
    m_uisetting_settingmain.tabmain:add("button_graphic", "tab_graphic")
    m_uisetting_settingmain.tabmain:add("button_audio", "tab_audio")
    m_uisetting_settingmain.tabmain:add("button_control", "tab_control")
    m_uisetting_settingmain.tabmain:add("button_downloader", "tab_downloader")
    if system_ispc() then
        m_uisetting_settingmain.tabmain:add("button_input", "tab_input")
    else
        m_uisetting_settingmain:setwidgetvisible("button_input", false)
        m_uisetting_settingmain:setwidgetvisible("tab_input", false)
    end

    m_uisetting_settingmain.tabmain:settab(1)

    m_uisetting_ui = {}

    local list_setting = m_uisetting_settingmain:getwidget("tab_game/list_setting")
    list_setting:init(uilistflag.vertical)
    settingui_addlabel(list_setting, "SETTING_LABEL_INFO")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "PLAYERNAME", "TEAMNAME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "RAIDNAME", "FLOCKNAME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "SIPIDNAME", "ENEMYNAME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "NPCNAME", "MONSTERNAME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "TITLE", "ICCNAME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "PVPTITLE", "TEAMME")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "NORMALQUEST", "LOWLEVELQUEST")
    settingui_addcheckbox(list_setting, "SETTING_INFO_", "RENDERHELMET", "RENDEREMBLEM")

    settingui_addlabel(list_setting, "SETTING_LABEL_CHARACTER")
    settingui_addcheckbox(list_setting, "SETTING_CHARACTER_", "ENEMYPLAYERACTOR", "ENEMYNPCACTOR")
    settingui_addcheckbox(list_setting, "SETTING_CHARACTER_", "SIPIDPLAYERACTOR", "SIPIDNPCACTOR")
    settingui_addcheckbox(list_setting, "SETTING_CHARACTER_", "TEAMACTOR", nil)

    settingui_addlabel(list_setting, "SETTING_LABEL_PRIVACY")
    settingui_addcheckbox(list_setting, "SETTING_PRIVACY_", "REFUSEQUERY", "REFUSEDEAL")
    settingui_addcheckbox(list_setting, "SETTING_PRIVACY_", "REFUSETEAM", "REFUSEICC")
    settingui_addcheckbox(list_setting, "SETTING_PRIVACY_", "REFUSEPAL", "REFUSEPK")

    list_setting = m_uisetting_settingmain:getwidget("tab_graphic/list_setting")
    list_setting:init(uilistflag.vertical)
    settingui_addlabel(list_setting, "SETTING_GRAPHIC_QUALITY_DETAIL")
    settingui_addradiobox(list_setting, "SETTING_GRAPHIC_QUALITY_ANTIALIASING", "ANTIALIASING")
    settingui_addradiobox(list_setting, "SETTING_GRAPHIC_QUALITY_SHADOW", "SHADOW")
    settingui_addradiobox(list_setting, "SETTING_GRAPHIC_QUALITY_TEXTURE", "TEXTURE")
    settingui_addcheckbox(list_setting, "SETTING_GRAPHIC_", "ORIENTATION", "SYSTEMFPS")
    settingui_addcheckbox(list_setting, "SETTING_GRAPHIC_", "CAMERASHAKE", nil)
    settingui_addslider(list_setting, "SETTING_GRAPHIC_FPSLIMIT", "FPSLIMIT")
    settingui_addslider(list_setting, "SETTING_GRAPHIC_CAMERAFOV", "CAMERAFOV")
    settingui_addslider(list_setting, "SETTING_GRAPHIC_UISCALE", "UISCALE")
    settingui_addslider(list_setting, "SETTING_GRAPHIC_MAPOPACITY", "MAPOPACITY")

    local checkboxarray = {}
    for i=1,4 do
        checkboxarray[i] = m_uisetting_settingmain:getwidget("tab_graphic/checkbox_quality_" .. i)
        checkboxarray[i]:setdelegate(settingui_delegate_radio)
        checkboxarray[i].keyname = "OVERALL"
        checkboxarray[i].index = i
        checkboxarray[i].checkboxarray = checkboxarray
    end
    m_uisetting_ui[#m_uisetting_ui + 1] = {uitype = uisetting_uitype.radio, widget = checkboxarray, keyname = "OVERALL"}
    
    list_setting = m_uisetting_settingmain:getwidget("tab_audio/list_setting")
    list_setting:init(uilistflag.vertical)
    settingui_addslider(list_setting, "SETTING_AUDIO_DEVICEVOLUME", "DEVICEVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_MUSICVOLUME", "MUSICVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_ENVMUSICVOLUME", "ENVMUSICVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_ENVSOUNDVOLUME", "ENVSOUNDVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_UIVOLUME", "UIVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_SKILLVOLUME", "SKILLVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_VOICEVOLUME", "VOICEVOLUME")
    settingui_addslider(list_setting, "SETTING_AUDIO_ALERTVOLUME", "ALERTVOLUME")
    settingui_addcheckbox(list_setting, "SETTING_AUDIO_", "BATTLEMUSIC", "PETAUDIO")

    list_setting = m_uisetting_settingmain:getwidget("tab_control/list_setting")
    list_setting:init(uilistflag.vertical)
    settingui_addslider(list_setting, "SETTING_CONTROL_CAMERARANGE", "CAMERARANGE")
    settingui_addslider(list_setting, "SETTING_CONTROL_CAMERASPEED", "CAMERASPEED")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "MOVEBACK", "MANUALMOVEIN")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "CAMERAFLIPV", "ATTACKSHOCK")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "ACTIONLINE2", "ACTIONLINE3")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "ACTIONLINE4", "HIDEEMPTYSKILLBAR")

    settingui_addlabel(list_setting, "SETTING_CONTROL_TABTYPE")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "TABENEMYNPC", "TABENEMYPLAYER")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "TABSIPIDNPC", "TABSIPIDPLAYER")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "TABENEMYNPCDEAD", "TABSIPIDPLAYERDEAD")
    settingui_addcheckbox(list_setting, "SETTING_CONTROL_", "TABHARVEST", nil)

    settingui_setui()
    setting_downloader_onopen(m_uisetting_settingmain)

    if system_ispc() then
        setting_inputmapping_onopen(m_uisetting_settingmain)
    end
    event_register(eventtype.update, setting_main_update, m_uisetting_settingmain)
end

function setting_main_update()
    setting_downloader_update(m_uisetting_settingmain)
end

function setting_main_delegate_reset_confirm(ok, data)
    if ok then
        settingui_setdefault()
        settingui_setui()
    end
end
function setting_main_delegate_reset()
    messagebox_confirm(c_textformat("SETTING_RESET_CONFIRM"), setting_main_delegate_reset_confirm, nil)
end

function setting_main_delegate_close()
    m_uisetting_settingmain:close()
end
