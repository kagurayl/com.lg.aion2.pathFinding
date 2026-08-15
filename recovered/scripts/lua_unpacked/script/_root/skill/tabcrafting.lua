
local m_tabcrafting_inst = {crafting = "skill/inst_crafting", convert = "skill/inst_convert"}

function skill_tabcrafting_init()
    local list_skill = m_uiskill_main:getwidget("tab_crafting/list_skill")
    list_skill:init(uilistflag.vertical)
    list_skill:setclickdelegate(skill_tabcrafting_delegate_clicklistitem)

    local button_setskillbar = m_uiskill_main:getwidget("tab_crafting/button_setskillbar")
    button_setskillbar:setenable(false)
    button_setskillbar:setdelegate(skill_tabcrafting_delegate_setskillbar)
end

function skill_tabcrafting_updateui()
    local list_skill = m_uiskill_main:getwidget("tab_crafting/list_skill")
    list_skill:savestate()
    list_skill:clear()

    local config_skillarray = {}
    for i=1,#playerattr_craftingskill do
        local config_skill = csvskill_getfromid(playerattr_craftingskill[i].skillid)
        if config_skill ~= nil then
            config_skillarray[#config_skillarray + 1] = config_skill
        end
	end

    table.sort(config_skillarray, function(p1, p2) return (p1.id < p2.id) end)

    for i=1,#config_skillarray do
        local config_skill = config_skillarray[i]
        if config_skill.id ~= skill_gather_convert then
            local line = list_skill:add(m_tabcrafting_inst.crafting, config_skill.id, config_skill)

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_skill.icon)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_skill.name)

            local craftingskill = playerskill_getcraftingskill(config_skill.id)
            local text_skillexp = line:getwidget("text_skillexp")
            text_skillexp:settext(string.format("%d/%d", craftingskill.level, craftingskill.levelmax))

            local progress_skillexp = line:getwidget("progress_skillexp")
            if craftingskill.expmax ~= 0 then
                progress_skillexp:setpercent(craftingskill.exp / craftingskill.expmax)
            else
                progress_skillexp:setpercent(0.0)
            end
        else
            local line = list_skill:add(m_tabcrafting_inst.convert, config_skill.id, config_skill)

            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_skill.icon)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_skill.name)
        end
    end
    list_skill:restorestate()
end

function skill_tabcrafting_delegate_clicklistitem(sender, line, config_skill)
    skill_main_setskilldesc("tab_crafting", config_skill, false)

    local button_setskillbar = m_uiskill_main:getwidget("tab_crafting/button_setskillbar")
    button_setskillbar:setenable(true)
end

function skill_tabcrafting_delegate_setskillbar()
    local list_skill = m_uiskill_main:getwidget("tab_crafting/list_skill")
    local config_skill = list_skill:getfirstselect()
    if config_skill ~= nil then
        skill_setting_opensetting(csvskillslottype.crafting, config_skill.id)
    end
end
