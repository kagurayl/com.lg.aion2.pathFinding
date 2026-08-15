
include("setting/settingmain")
include("setting/settinglocal")
include("setting/settingapply")
include("setting/downloader")
include("setting/inputmapping")

m_settingui_inst =
{
    label = "setting/inst_label",
    inst_checkbox = "setting/inst_checkbox",
    inst_slider = "setting/inst_slider",
    inst_radio = "setting/inst_radio",
}

uisetting_uitype =
{
	checkbox = 1,
 	slider = 2,
    radio = 3,
}

m_uisetting_settingmain = uipanel_createhandle("setting/setting_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
m_uisetting_settinglocal = uipanel_createhandle("setting/setting_local", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
m_uisetting_ui = nil
local m_uisetting_linespace = 50

function settingui_addlabel(list_setting, labeltext)
    list_setting:addspace(m_uisetting_linespace)
    local line = list_setting:add(m_settingui_inst.label)
    local text_label = line:getwidget("text_label")
    text_label:settext(labeltext)
end

function settingui_addcheckbox(list_setting, textheader, key1, key2)
    list_setting:addspace(m_uisetting_linespace)
    local line = list_setting:add(m_settingui_inst.inst_checkbox)
    local text_label1 = line:getwidget("checkbox_1/text_label")
    text_label1:settext(textheader .. key1)
    local checkbox1 = line:getwidget("checkbox_1")
    checkbox1:setdelegate(settingui_delegate_checkbox)
    checkbox1.keyname = key1
    m_uisetting_ui[#m_uisetting_ui + 1] = {uitype = uisetting_uitype.checkbox, widget = checkbox1, keyname = key1}

    local checkbox2 = line:getwidget("checkbox_2")
    if key2 ~= nil then
        local text_label2 = line:getwidget("checkbox_2/text_label")
        text_label2:settext(textheader .. key2)
        checkbox2:setdelegate(settingui_delegate_checkbox)
        checkbox2.keyname = key2
        m_uisetting_ui[#m_uisetting_ui + 1] = {uitype = uisetting_uitype.checkbox, widget = checkbox2, keyname = key2}
    else
        checkbox2:setvisible(false)
    end
end

function settingui_addslider(list_setting, text, key)
    list_setting:addspace(m_uisetting_linespace)
    local line = list_setting:add(m_settingui_inst.inst_slider)
    local text_label = line:getwidget("text_label")
    text_label:settext(text)

    local slider_value = line:getwidget("slider_value")
    slider_value:setdelegate(settingui_delegate_slider)
    slider_value.keyname = key
    slider_value.valwidget = line:getwidget("text_value")

    local ui = {}
    ui.uitype = uisetting_uitype.slider
    ui.widget = slider_value
    ui.keyname = key
    m_uisetting_ui[#m_uisetting_ui + 1] = ui
end

function settingui_addradiobox(list_setting, text, key)
    list_setting:addspace(m_uisetting_linespace)
    local line = list_setting:add(m_settingui_inst.inst_radio)
    local text_label = line:getwidget("text_label")
    text_label:settext(text)
    local checkboxarray = {}
    for i=1,3 do
        checkboxarray[i] = line:getwidget("checkbox_" .. i)
        checkboxarray[i]:setdelegate(settingui_delegate_radio)
        checkboxarray[i].keyname = key
        checkboxarray[i].index = i
        checkboxarray[i].checkboxarray = checkboxarray
    end
    checkboxarray[2]:setdelegate(settingui_delegate_radio)
    checkboxarray[3]:setdelegate(settingui_delegate_radio)
    m_uisetting_ui[#m_uisetting_ui + 1] = {uitype = uisetting_uitype.radio, widget = checkboxarray, keyname = key}
end

function settingui_delegate_apply(setting)
    gamesetting_savesetting(setting)
    local func = _G["settingapply_" .. string.lower(setting.name)]
    if func ~= nil then
        func(setting, true)
    end
end

function settingui_delegate_checkbox(sender, event)
    local gamesetting = gamesetting_get()
    local setting = gamesetting[sender.keyname]
    if setting ~= nil then
        if event.name == "check" then
            setting.current = 1
        else
            setting.current = 0
        end
        settingui_delegate_apply(setting)
    end
end

function settingui_delegate_slider(sender, event)
    local gamesetting = gamesetting_get()
    local setting = gamesetting[sender.keyname]
    if setting ~= nil then
        local val = math.lerp(setting.data.min, setting.data.max, event.val)
        if setting.data.perc ~= nil then
            sender.valwidget:settext(string.format("%d%%", math.tointegerfloor(val * 100)))
        else
            sender.valwidget:settext(string.format("%d", math.tointegerfloor(val)))
        end
        setting.current = event.val
        settingui_delegate_apply(setting)
    end
end

function settingui_delegate_radio(sender, event)
    local gamesetting = gamesetting_get()
    for i=1,#sender.checkboxarray do
        sender.checkboxarray[i]:setcheck(sender.checkboxarray[i].index == sender.index)
    end
    local setting = gamesetting[sender.keyname]
    if setting ~= nil then
        setting.current = sender.index
        settingui_delegate_apply(setting)
    end
end

function settingui_setdefault()
    local gamesetting = gamesetting_get()
    for i=1,#m_uisetting_ui do
        local ui = m_uisetting_ui[i]
        local setting = gamesetting[ui.keyname]
        if setting ~= nil then
            setting.current = setting.default
            settingui_delegate_apply(setting)
        end
    end
end

function settingui_setui()
    local gamesetting = gamesetting_get()
    for i=1,#m_uisetting_ui do
        local ui = m_uisetting_ui[i]
        local setting = gamesetting[ui.keyname]
        if setting ~= nil then
            if ui.uitype == uisetting_uitype.checkbox then
                ui.widget:setcheck(setting.current ~= "0")
            elseif ui.uitype == uisetting_uitype.slider then
                local current = tonumber(setting.current)
                if current ~= nil then
                    local val = math.lerp(setting.data.min, setting.data.max, current)
                    if setting.data.perc ~= nil then
                        ui.widget.valwidget:settext(string.format("%d%%", math.tointegerfloor(val * 100)))
                    else
                        ui.widget.valwidget:settext(string.format("%d", math.tointegerfloor(val)))
                    end
                    ui.widget:setslider(current)
                end
            elseif ui.uitype == uisetting_uitype.radio then
                local current = tonumber(setting.current)
                if current ~= nil then
                    current = math.tointegerfloor(current)
                    for j=1,#ui.widget do
                        ui.widget[j]:setcheck(j == current)
                    end
                end
            end
        end
    end
    local systemfps = gamesetting["SYSTEMFPS"]
    for i=1,#m_uisetting_ui do
        local ui = m_uisetting_ui[i]
        if ui.keyname == "FPSLIMIT" then
            ui.widget:setenable(systemfps.current == "0")
            break
        end
    end
end
