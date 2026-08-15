
local m_tabsystem_inst = {inst = "skill/inst_system"}
local m_tabsystem_select = nil

function skill_tabsystem_init()
    local list_skill = m_uiskill_main:getwidget("tab_system/list_skill")
    list_skill:init(uilistflag.vertical)

    local button_setskillbar = m_uiskill_main:getwidget("tab_system/button_setskillbar")
    button_setskillbar:setenable(false)
    button_setskillbar:setdelegate(skill_tabsystem_delegate_setskillbar)
    
    m_tabsystem_select = nil
end

function skill_tabsystem_updateui()
    local list_skill = m_uiskill_main:getwidget("tab_system/list_skill")
    list_skill:savestate()
    list_skill:clear()

    local config_skillarray = {}
	for i=skill_sysytem_idstart,skill_sysytem_idend do
        local config_skill = csvskill_getfromid(i)
        if config_skill ~= nil then
            config_skillarray[#config_skillarray + 1] = config_skill
        end
	end

    local line = nil
    local colcount = 3
    for i=1,#config_skillarray do
        local config_skill = config_skillarray[i]
        local index = math.fmod(i - 1, colcount) + 1
        if index == 1 then
            line = list_skill:add(m_tabsystem_inst.inst)
        end

        local image_icon = line:getwidget("image_icon_" .. index)
        image_icon:setvisible(true)
        image_icon:seticon(config_skill.icon)
        image_icon:setdelegate(skill_tabsystem_delegate_skill)
        image_icon.config_skill = config_skill

        local text_name = line:getwidget("text_name_" .. index)
        text_name:setvisible(true)
        text_name:settext(config_skill.name)
        text_name:setdelegate(skill_tabsystem_delegate_skill)
        text_name.config_skill = config_skill
    end
    local hidestart = math.fmod(#config_skillarray, colcount) + 1
    if hidestart > 1 then
        for i=hidestart,colcount do
            line:setwidgetvisible("image_icon_" .. i, false)
            line:setwidgetvisible("text_name_" .. i, false)
        end
    end
    list_skill:restorestate()
end

function skill_tabsystem_delegate_skill(sender, event)
    skill_main_setskilldesc("tab_system", sender.config_skill, false)
    m_tabsystem_select = sender.config_skill
    local button_setskillbar = m_uiskill_main:getwidget("tab_system/button_setskillbar")
    button_setskillbar:setenable(true)
end

function skill_tabsystem_delegate_setskillbar()
    if m_tabsystem_select ~= nil then
        skill_setting_opensetting(csvskillslottype.skill, m_tabsystem_select.id)
    end
end
