
local m_tabsocial_inst = {inst = "skill/inst_social"}
local m_tabsocial_select = nil

function skill_tabsocial_init()
    local list_social = m_uiskill_main:getwidget("tab_social/list_social")
    list_social:init(uilistflag.vertical)

    local button_setskillbar = m_uiskill_main:getwidget("tab_social/button_setskillbar")
    button_setskillbar:setenable(false)
    button_setskillbar:setdelegate(skill_tabsocial_delegate_setskillbar)
    
    m_tabsocial_select = nil
end

function skill_tabsocial_updateui()
    local list_social = m_uiskill_main:getwidget("tab_social/list_social")
    list_social:savestate()
    list_social:clear()

    local config_socialarray = csvskillsocial_getall()
    table.sort(config_socialarray, function(p1, p2) return (p1.id < p2.id) end)

    local line = nil
    local colcount = 3
    for i=1,#config_socialarray do
        local config_social = config_socialarray[i]
        local index = math.fmod(i - 1, colcount) + 1
        if index == 1 then
            line = list_social:add(m_tabsocial_inst.inst)
        end

        local image_icon = line:getwidget("image_icon_" .. index)
        image_icon:setvisible(true)
        image_icon:seticon(config_social.icon)
        image_icon:setdelegate(skill_tabsocial_delegate_social)
        image_icon.config_social = config_social

        local text_name = line:getwidget("text_name_" .. index)
        text_name:setvisible(true)
        text_name:settext(config_social.name)
        text_name:setdelegate(skill_tabsocial_delegate_social)
        text_name.config_social = config_social
    end
    local hidestart = math.fmod(#config_socialarray, colcount) + 1
    if hidestart > 1 then
        for i=hidestart,colcount do
            line:setwidgetvisible("image_icon_" .. i, false)
            line:setwidgetvisible("text_name_" .. i, false)
        end
    end
    list_social:restorestate()
end

function skill_tabsocial_delegate_social(sender, event)
    skill_main_setsocialdesc("tab_social", sender.config_social)
    m_tabsocial_select = sender.config_social
    local button_setskillbar = m_uiskill_main:getwidget("tab_social/button_setskillbar")
    button_setskillbar:setenable(true)
end

function skill_tabsocial_delegate_setskillbar()
    if m_tabsocial_select ~= nil then
        skill_setting_opensetting(csvskillslottype.social, m_tabsocial_select.id)
    end
end
