
local SortType =
{
    name = 1,
    nameinv = 2,
    level = 3,
    levelinv = 4,
    learn = 5,
    learninv = 6,
}

local m_skill_tabpassive_inst = {skill = "skill/inst_passive"}
local m_skill_tabpassive_sort = SortType.name
local m_skill_tabpassive_sortfunc = {}
local m_skill_tabpassive_lowlevel = false
local m_skill_tabpassive_unlearn = false

function skill_tabpassive_sortskill(p1, p2)
    for i=1,#m_skill_tabpassive_sortfunc do
        local compare = m_skill_tabpassive_sortfunc[i](p1, p2)
        if compare ~= 0 then
            return compare < 0
        end
    end
    return false
end

function skill_tabpassive_init()
    local list_skill = m_uiskill_main:getwidget("tab_passive/list_skill")
    list_skill:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_skill:setclickdelegate(skill_tabpassive_delegate_clicklistitem)
    list_skill:setasyncdelegate(skill_tabpassive_delegate_listitem)

    local checkbox_lowlevel = m_uiskill_main:getwidget("tab_passive/checkbox_lowlevel")
    checkbox_lowlevel:setcheck(m_skill_tabpassive_lowlevel)
    checkbox_lowlevel:setdelegate(skill_tabpassive_delegate_lowlevel)

    local checkbox_unlearn = m_uiskill_main:getwidget("tab_passive/checkbox_unlearn")
    checkbox_unlearn:setcheck(m_skill_tabpassive_unlearn)
    checkbox_unlearn:setdelegate(skill_tabpassive_delegate_unlearn)

    m_uiskill_main:setwidgetdelegate("tab_passive/button_name", skill_tabpassive_delegate_sortname)
    m_uiskill_main:setwidgetdelegate("tab_passive/button_level", skill_tabpassive_delegate_sortlevel)
    m_uiskill_main:setwidgetdelegate("tab_passive/button_learn", skill_tabpassive_delegate_sortlearn)
end

local function skill_tabpassive_skillavailable(config_skilllearn)
    if config_skilllearn.learntype == csvskilllearntype.auto or config_skilllearn.learntype == csvskilllearntype.skillbook then
        local spellwaytype = config_skilllearn.config_skill.spellway
        if spellwaytype == csvskillspellway.passive then
            if m_skill_tabpassive_unlearn or playerskill_available(config_skilllearn.id) then
                if playercivavailable(config_skilllearn.civ, playerattr_info.civ) then
                    return true
                end
            end
        end
    end
    return false
end
function skill_tabpassive_updateui()
    if #m_skill_tabpassive_sortfunc == 0 then
        m_skill_tabpassive_sortfunc = {skillsort_name, skillsort_level, skillsort_learn}
    end

    local config_skillarray = {}
    local config_skilltable = {}
    local config_skilllearnall = csvskilllearn_getfromcivcareer(playerattr_info.civ, playerattr_info.career)
    for key, val in pairs(config_skilllearnall) do
        local config_skilllearn = val
        if skill_tabpassive_skillavailable(config_skilllearn) then
            if m_skill_tabpassive_lowlevel or config_skilllearn.config_skill.category == 0 then
                config_skillarray[#config_skillarray + 1] = config_skilllearn
            else
                local index = config_skilltable[config_skilllearn.config_skill.category]
                if index == nil then
                    config_skillarray[#config_skillarray + 1] = config_skilllearn
                    config_skilltable[config_skilllearn.config_skill.category] = #config_skillarray
                else
                    local prev_learn = config_skillarray[index]
                    if prev_learn.config_skill.categorylevel < config_skilllearn.config_skill.categorylevel then
                        config_skillarray[index] = config_skilllearn
                    end
                end
            end
        end
	end
    table.sort(config_skillarray, skill_tabpassive_sortskill)

    local list_skill = m_uiskill_main:getwidget("tab_passive/list_skill")
    list_skill:savestate()
    list_skill:clear()
    for i=1,#config_skillarray do
        local config_skilllearn = config_skillarray[i]
        list_skill:add(m_skill_tabpassive_inst.skill, config_skilllearn.id, config_skilllearn)
    end
    list_skill:restorestate()
end

function skill_tabpassive_delegate_clicklistitem(sender, line, config_skilllearn)
    skill_main_setskilldesc("tab_passive", config_skilllearn.config_skill, false)
end

function skill_tabpassive_delegate_listitem(sender, line, config_skilllearn)
    local text_name = line:getwidget("text_name")
    text_name:settextraw(config_skilllearn.config_skill.name)

    local text_level = line:getwidget("text_level")
    text_level:settextraw(config_skilllearn.playerlevel)

    local text_learn = line:getwidget("text_learn")
    if config_skilllearn.learntype == csvskilllearntype.auto then
        text_learn:settext("SKILL_LEARN_AUTO")
    elseif config_skilllearn.learntype == csvskilllearntype.skillbook then
        text_learn:settext("SKILL_LEARN_SKILLBOOK")
    end

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_skilllearn.config_skill.icon)
    image_icon:setavailablecolor(playerskill_available(config_skilllearn.id))

    local text_count = line:getwidget("text_count")
    local skilllevel = playerskill_getdeltalevel(config_skilllearn.id)
    if skilllevel > 0 then
        text_count:settext(skilllevel)
    else
        text_count:settext("")
    end
end

function skill_tabpassive_delegate_lowlevel(sender, event)
    m_skill_tabpassive_lowlevel = event.name == "check"
    skill_tabpassive_updateui()
end

function skill_tabpassive_delegate_unlearn(sender, event)
    m_skill_tabpassive_unlearn = event.name == "check"
    skill_tabpassive_updateui()
end

function skill_tabpassive_delegate_sortname()
    if m_skill_tabpassive_sort == SortType.name then
        m_skill_tabpassive_sort = SortType.nameinv
        m_skill_tabpassive_sortfunc = {skillsort_name_inv, skillsort_level, skillsort_learn, skillsort_spell}
    else
        m_skill_tabpassive_sort = SortType.name
        m_skill_tabpassive_sortfunc = {skillsort_name, skillsort_level, skillsort_learn, skillsort_spell}
    end
    skill_tabpassive_updateui()
end

function skill_tabpassive_delegate_sortlevel()
    if m_skill_tabpassive_sort == SortType.level then
        m_skill_tabpassive_sort = SortType.levelinv
        m_skill_tabpassive_sortfunc = {skillsort_level_inv, skillsort_name, skillsort_learn, skillsort_spell}
    else
        m_skill_tabpassive_sort = SortType.level
        m_skill_tabpassive_sortfunc = {skillsort_level, skillsort_name, skillsort_learn, skillsort_spell}
    end
    skill_tabpassive_updateui()
end

function skill_tabpassive_delegate_sortlearn()
    if m_skill_tabpassive_sort == SortType.learn then
        m_skill_tabpassive_sort = SortType.learninv
        m_skill_tabpassive_sortfunc = {skillsort_learn_inv, skillsort_level, skillsort_name, skillsort_spell}
    else
        m_skill_tabpassive_sort = SortType.learn
        m_skill_tabpassive_sortfunc = {skillsort_learn, skillsort_level, skillsort_name, skillsort_spell}
    end
    skill_tabpassive_updateui()
end
