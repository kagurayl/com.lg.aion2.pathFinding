
function setting_local_onopen()
    m_uisetting_settinglocal:setwidgetdelegate("button_reset", setting_local_delegate_reset)
    m_uisetting_settinglocal:setwidgetdelegate("image_bg/button_close", setting_local_delegate_close)

    m_uisetting_settinglocal.tabmain = uitabcreate(m_uisetting_settinglocal)
    m_uisetting_settinglocal.tabmain:add("button_graphic", "tab_graphic")
    m_uisetting_settinglocal.tabmain:add("button_audio", "tab_audio")
    m_uisetting_settinglocal.tabmain:add("button_downloader", "tab_downloader")
    m_uisetting_settinglocal.tabmain:settab(1)

    m_uisetting_ui = {}

    local list_setting = m_uisetting_settinglocal:getwidget("tab_graphic/list_setting")
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
        checkboxarray[i] = m_uisetting_settinglocal:getwidget("tab_graphic/checkbox_quality_" .. i)
        checkboxarray[i]:setdelegate(settingui_delegate_radio)
        checkboxarray[i].keyname = "OVERALL"
        checkboxarray[i].index = i
        checkboxarray[i].checkboxarray = checkboxarray
    end
    m_uisetting_ui[#m_uisetting_ui + 1] = {uitype = uisetting_uitype.radio, widget = checkboxarray, keyname = "OVERALL"}
    
    list_setting = m_uisetting_settinglocal:getwidget("tab_audio/list_setting")
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

    settingui_setui()
    setting_downloader_onopen(m_uisetting_settinglocal)
    event_register(eventtype.update, setting_local_update, m_uisetting_settinglocal)
end

function setting_local_update()
    setting_downloader_update(m_uisetting_settinglocal)
end

function setting_local_delegate_reset()
    settingui_setdefault()
    settingui_setui()
end

function setting_local_delegate_close()
    m_uisetting_settinglocal:close()
end
