
local m_charsetting_colorpreset = {0xffffff,0xffb1b1,0xfddaad,0xa0ffa0,0xc4dfff,0xffb1b1,0x05c8d7,0x9ce7dc,0x75a8f4,0x98ed11}
local m_chatsetting_inst = {category = "chat/inst_settingcategory", name = "chat/inst_settingname", setting = "chat/inst_settingcolor"}
local m_uichat_setting = uipanel_createhandle("chat/chatsetting", uilayer.top, bit.bor(uiflag.escapeclose, uiflag.placeall))

function chatsetting_open()
    m_uichat_setting:open()
end

function chatsetting_onopen()
    m_uichat_setting:setwidgetdelegate("button_rename", chatsetting_delegate_rename)
    m_uichat_setting:setwidgetdelegate("button_delete", chatsetting_delegate_delete)
    m_uichat_setting:setwidgetdelegate("button_reset", chatsetting_delegate_reset)
    m_uichat_setting:setwidgetdelegate("button_resetcolor", chatsetting_delegate_resetcolor)
    m_uichat_setting:setwidgetdelegate("image_bg/button_close", chatsetting_delegate_close)
    local list_channel = m_uichat_setting:getwidget("list_channel")
    list_channel:init(uilistflag.vertical)

    local list_setting = m_uichat_setting:getwidget("list_setting")
    list_setting:init(uilistflag.vertical)

    m_uichat_setting.selectnameindex = 0
    chatsetting_updateui()
end

local function chatsetting_addchannelname(list_channel, nameindex)
    local name = csvchat_getchannelname(nameindex)
    if name == nil then
        return
    end
    local line = list_channel:add(m_chatsetting_inst.name)
    local button_channel = line:getwidget("button_channel")
    button_channel.nameindex = nameindex
    button_channel:settext(name)
    button_channel:setenable(m_uichat_setting.selectnameindex ~= nameindex)
    button_channel:setdelegate(chatsetting_delegate_channel)
end

local function chatsetting_addchannelcategory(list_setting, type)
    local line = list_setting:add(m_chatsetting_inst.category)
    local checkbox_category = line:getwidget("checkbox_category")
    checkbox_category:setdelegate(chatsetting_delegate_channeltype)
    checkbox_category.channeltype = type
    local check = csvchat_getchannelvisible(m_uichat_setting.selectnameindex, type)
    checkbox_category:setcheck(check)

    local text_label = line:getwidget("checkbox_category/text_label")
    text_label:settext("CHAT_CHANNELTYPE_" .. type)

    return check
end
local function chatsetting_addchannelcolor(list_setting, widgetindex, channeltype, name)
    widgetindex = math.fmod(widgetindex - 1, 2) + 1
    local line = nil
    if widgetindex == 1 then
        line = list_setting:add(m_chatsetting_inst.setting)
        line:setwidgetvisible("checkbox_2", false)
        line:setwidgetvisible("image_color2", false)
    else
        line = list_setting:getlinefromindex(list_setting:getcount())
    end
    
    local checkboxname = "checkbox_" .. widgetindex
    local checkbox_name = line:getwidget(checkboxname)
    checkbox_name:setvisible(true)
    checkbox_name:setdelegate(chatsetting_delegate_channeltype)
    checkbox_name.channeltype = channeltype
    checkbox_name:setcheck(csvchat_getchannelvisible(m_uichat_setting.selectnameindex, channeltype))

    local text_label = line:getwidget(checkboxname .. "/text_label")
    text_label:settext(name)

    local color = csvchat_getchannelcolor(channeltype)
    local image_color = line:getwidget("image_color" .. widgetindex)
    local r, g, b = HexRGB(color)
    image_color:setvisible(true)
    image_color:setcolor(r, g, b, 1.0)
    image_color:setdelegate(chatsetting_delegate_color)
    image_color.channeltype = channeltype
end
local function chatsetting_addchannelbattle(list_setting, type)
    if chatsetting_addchannelcategory(list_setting, type) then
        for i=chatbattletype.attack,chatbattletype.count do
            chatsetting_addchannelcolor(list_setting, i, type + i, "CHAT_CHANNELTYPE_BATTLE_" .. i)
        end
    end
end
function chatsetting_updateui()
    if m_uichat_setting:null() then
        return
    end
    local list_channel = m_uichat_setting:getwidget("list_channel")
    list_channel:savestate()
    list_channel:clear()
    local namesetting = gamesetting_gettable("CHATSETTING_NAME")
    for i=0,#namesetting do
        chatsetting_addchannelname(list_channel,i)
    end

    local line = list_channel:add(m_chatsetting_inst.name)
    local button_channel = line:getwidget("button_channel")
    button_channel:settext("CHAT_SETTING_CHANNEL_ADD")
    button_channel:setenable(true)
    button_channel:setdelegate(chatsetting_delegate_addchannel)
    list_channel:restorestate()

    m_uichat_setting:setwidgetenable("button_rename", m_uichat_setting.selectnameindex > 0)
    m_uichat_setting:setwidgetenable("button_delete", m_uichat_setting.selectnameindex > 1)

    local list_setting = m_uichat_setting:getwidget("list_setting")
    list_setting:savestate()
    list_setting:clear()

    if chatsetting_addchannelcategory(list_setting, chatchanneltype.categorychat) then
        for i=chatchanneltype.chataoi,chatchanneltype.chathowlall do
            chatsetting_addchannelcolor(list_setting, i, i, "CHAT_CHANNELTYPE_" .. i)
        end
    end
    
    if chatsetting_addchannelcategory(list_setting, chatchanneltype.categorysystem) then
        for i=chatchanneltype.systeminfo,chatchanneltype.systemitem do
            chatsetting_addchannelcolor(list_setting, i - chatchanneltype.categorysystem, i, "CHAT_CHANNELTYPE_" .. i)
        end
    end

    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatattack)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combathurt)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatteamattack)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatteamhurt)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatplayerattack)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatplayerhurt)
    chatsetting_addchannelbattle(list_setting, chatchanneltype.combatnpcattack)
    list_setting:restorestate()
end
function chatsetting_rename_confirm(text, nameindex)
    local namesetting = gamesetting_gettable("CHATSETTING_NAME")
    if namesetting ~= nil and nameindex <= #namesetting then
        namesetting[nameindex] = text
        gamesetting_modify("CHATSETTING_NAME", namesetting)
        chatsetting_updateui()
    end
end
function chatsetting_delegate_rename()
    local visiblename = csvchat_getchannelname(m_uichat_setting.selectnameindex)
    if visiblename ~= nil then
        inputline_show(uiedittype.default, "CHAT_SETTING_CHANNEL_RENAMEINPUT", visiblename, chatsetting_rename_confirm, m_uichat_setting.selectnameindex)
    end
end

function chatsetting_delete_confirm(ok, nameindex)
    if ok then
        local namesetting = gamesetting_gettable("CHATSETTING_NAME")
        if namesetting ~= nil and nameindex <= #namesetting then
            table.remove(namesetting, nameindex)
            gamesetting_modify("CHATSETTING_NAME", namesetting)
            m_uichat_setting.selectnameindex = 0
            chatsetting_updateui()
        end
    end
end
function chatsetting_delegate_delete()
    if m_uichat_setting.selectnameindex > 1 then
        local visiblename = csvchat_getchannelname(m_uichat_setting.selectnameindex)
        if visiblename ~= nil then
            local text = c_textformat("CHAT_SETTING_CHANNEL_DELETECONFIRM", visiblename)
            messagebox_confirm(text, chatsetting_delete_confirm, m_uichat_setting.selectnameindex)
        end
    end
end

function chatsetting_reset_confirm(ok, nameindex)
    if ok then
        gamesetting_modify("CHATSETTING_" .. nameindex, nil)
        csvchat_loadsetting()
        chatsetting_updateui()
    end
end
function chatsetting_delegate_reset()
    local visiblename = csvchat_getchannelname(m_uichat_setting.selectnameindex)
    if visiblename ~= nil then
        local text = c_textformat("CHAT_SETTING_CHANNEL_RESETCONFIRM", visiblename)
        messagebox_confirm(text, chatsetting_reset_confirm, m_uichat_setting.selectnameindex)
    end
end

function chatsetting_resetcolor_confirm(ok, data)
    if ok then
        gamesetting_modify("CHATSETTING_COLOR", nil)
        csvchat_loadcolor()
        chatsetting_updateui()
    end
end
function chatsetting_delegate_resetcolor()
    messagebox_confirm("CHAT_SETTING_CHANNEL_RESETCOLORCONFIRM", chatsetting_resetcolor_confirm)
end

function chatsetting_delegate_close()
    m_uichat_setting:close()
    chatbox_updateui()
end

function chatsetting_delegate_channel(sender, event)
    m_uichat_setting.selectnameindex = sender.nameindex
    chatsetting_updateui()
end

function chatsetting_delegate_addchannel(sender, event)
    local namesetting = gamesetting_gettable("CHATSETTING_NAME")
    if namesetting == nil then
        namesetting = {}
    end
    if #namesetting < chatsetting_maxchannel then
        namesetting[#namesetting + 1] = ""
        m_uichat_setting.selectnameindex = #namesetting
        gamesetting_modify("CHATSETTING_NAME", namesetting)
        chatsetting_updateui()
    else
        messagealert_addalert("CHAT_SETTING_CHANNEL_LIMIT")
    end
end

function chatsetting_delegate_channeltype(sender, event)
    local settingkey = "CHATSETTING_" .. m_uichat_setting.selectnameindex
    local channeltypesetting = gamesetting_gettable(settingkey)
    if channeltypesetting == nil then
        channeltypesetting = {}
    end
    local check = sender:getcheck()
    if check then
        local add = true
        for i=1,#channeltypesetting do
            if channeltypesetting[i] == sender.channeltype then
                add = false
                break
            end
        end
        if add then
            channeltypesetting[#channeltypesetting + 1] = sender.channeltype
            gamesetting_modify(settingkey, channeltypesetting)
        end
    else
        for i=1,#channeltypesetting do
            if channeltypesetting[i] == sender.channeltype then
                table.remove(channeltypesetting, i)
                gamesetting_modify(settingkey, channeltypesetting)
                break
            end
        end
    end
    csvchat_loadsetting()
    chatsetting_updateui()
end

function chatsetting_delegate_colorpick(r, g, b, data)
    local colorsetting = csvchat_getchannelcolorsetting()
    colorsetting[data] = ToHex(r, g, b)
    gamesetting_modify("CHATSETTING_COLOR", colorsetting)
    chatsetting_updateui()
end

function chatsetting_delegate_color(sender, event)
    local currentcolor = csvchat_getchannelcolor(sender.channeltype)
    colorpicker_create(currentcolor, m_charsetting_colorpreset, chatsetting_delegate_colorpick, sender.channeltype)
end
