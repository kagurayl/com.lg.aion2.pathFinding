
local m_uisetting_inputmapping_inst = {key = "setting/inst_input"}
local m_uisetting_inputmapping_list = nil
local m_uisetting_inputmapping_active = nil

local function setting_inputmapping_addkey(name)
    local line = m_uisetting_inputmapping_list:add(m_uisetting_inputmapping_inst.key, name, name)
    local text_label = line:getwidget("text_label")
    local image_logo = line:getwidget("image_logo")
    if string.startwith(name, "SETLOGO_") then
        local logo = string.tointeger(string.sub(name, string.len("SETLOGO_") + 1))
        text_label:settext("SETTING_KEYNAME_SETLOGO")
        image_logo:setspritesize("name/logo" .. logo, 0.5)
    elseif string.startwith(name, "SELECTELOGO_") then
        local logo = string.tointeger(string.sub(name, string.len("SELECTELOGO_") + 1))
        text_label:settext("SETTING_KEYNAME_SELECTELOGO")
        image_logo:setspritesize("name/logo" .. logo, 0.5)
    else
        text_label:settext("SETTING_KEYNAME_" .. name)
        image_logo:setvisible(false)
    end

    local text_key = line:getwidget("text_key")
    text_key:setdelegate(setting_inputmapping_delegate_line)
    text_key.inputname = name
end

function setting_inputmapping_onopen(panel)
    m_uisetting_inputmapping_list = panel:getwidget("tab_input/list_key")
    m_uisetting_inputmapping_list:init(uilistflag.vertical)
    m_uisetting_inputmapping_active = nil
    setting_inputmapping_addkey("MOVEFORWARD")
    setting_inputmapping_addkey("MOVEBACKWARD")
    setting_inputmapping_addkey("MOVELEFT")
    setting_inputmapping_addkey("MOVERIGHT")
    setting_inputmapping_addkey("FLYUP")
    setting_inputmapping_addkey("FLYDOWN")
    setting_inputmapping_addkey("JUMP")
    setting_inputmapping_addkey("REST")
    setting_inputmapping_addkey("ATTACK")
    setting_inputmapping_addkey("SWITCHBATTLE")
    setting_inputmapping_addkey("SWITCHEQUIP")
    setting_inputmapping_addkey("BATTERY")
    setting_inputmapping_addkey("SELECTENEMY")
    setting_inputmapping_addkey("SELECTSIPID")
    setting_inputmapping_addkey("SELECTPVPENEMY")
    setting_inputmapping_addkey("SELECTANY")
    setting_inputmapping_addkey("SELECTSUBTARGET")
    setting_inputmapping_addkey("SPIRITATTACK")
    setting_inputmapping_addkey("SPIRITMOVE")
    setting_inputmapping_addkey("SPIRITIDLE")
    setting_inputmapping_addkey("SPIRITDISMISS")
    setting_inputmapping_addkey("SELECTME")
    setting_inputmapping_addkey("SELECTMATE1")
    setting_inputmapping_addkey("SELECTMATE2")
    setting_inputmapping_addkey("SELECTMATE3")
    setting_inputmapping_addkey("SELECTMATE4")
    setting_inputmapping_addkey("SELECTMATE5")
    setting_inputmapping_addkey("CHATBOX")
    setting_inputmapping_addkey("ESCAPE")
    setting_inputmapping_addkey("UIOVERVIEW")
    setting_inputmapping_addkey("UIBAG")
    setting_inputmapping_addkey("UIQUEST")
    setting_inputmapping_addkey("UISKILL")
    setting_inputmapping_addkey("UIMAP")
    setting_inputmapping_addkey("UIMAPOPACITY")
    setting_inputmapping_addkey("UISTALL")
    setting_inputmapping_addkey("UIPETLIST")
    setting_inputmapping_addkey("UIPET")
    setting_inputmapping_addkey("UIPAL")
    setting_inputmapping_addkey("UITEAM")
    setting_inputmapping_addkey("UIRAID")
    setting_inputmapping_addkey("UIICC")
    setting_inputmapping_addkey("UIRANK")
    setting_inputmapping_addkey("UIDUNGEON")
    for i=1,max_logo do
        setting_inputmapping_addkey("SETLOGO_" .. i)
    end
    for i=1,max_logo do
        setting_inputmapping_addkey("SELECTELOGO_" .. i)
    end
    for i=1,skill_skillbarslotmax do
        local keyname = string.format("SKILL_%d", i)
        setting_inputmapping_addkey(keyname)
	end
    for i=1,skill_actionbarslotmax do
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local keyname = string.format("ACTION_%d_%d", lineindex, slotindex)
    	setting_inputmapping_addkey(keyname)
	end
    setting_inputmapping_updateui()
end

function setting_inputmapping_updateui()
    for i=1,m_uisetting_inputmapping_list:getcount() do
        local line = m_uisetting_inputmapping_list:getlinefromindex(i)
        local name = line:getdata()
        local text_key = line:getwidget("text_key")
        local key = gamesetting_getkeyval("KEY_" .. name)
        if key ~= nil and #key > 0 then
            text_key:settext(key)
        else
            text_key:settext("SETTING_KEYINPUT_NONE")
        end
        if m_uisetting_inputmapping_active == name then
            text_key:setcolor(1,0,0,1)
        else
            text_key:setcolor(1,1,1,1)
        end
    end
end

function setting_inputmapping_isinputactive()
    if m_uisetting_settingmain:null() then
        return false
    end
    if m_uisetting_inputmapping_active == nil then
        return false
    end
    return true
end

function setting_inputmapping_onkeyinput(key)
    if m_uisetting_settingmain:alive() and m_uisetting_inputmapping_active ~= nil then
        local setting = gamesetting_get()
        for settingname, settingval in pairs(setting) do
            if string.startwith(settingname, "KEY_") and settingval.current == key then
                gamesetting_modify(settingname, nil)
            end
        end
        if key ~= "Backspace" then
            gamesetting_modify("KEY_" .. m_uisetting_inputmapping_active, key)
        else
            gamesetting_modify("KEY_" .. m_uisetting_inputmapping_active, nil)
        end
        m_uisetting_inputmapping_active = nil
        setting_inputmapping_updateui()
        skillbar_updateui()
        actionbar_updateui()
    end
end

function setting_inputmapping_delegate_line(sender, event)
    m_uisetting_inputmapping_active = sender.inputname
    setting_inputmapping_updateui()
end
