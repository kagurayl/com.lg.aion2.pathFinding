
local SortType =
{
    name = 1,
    nameinv = 2,
    level = 3,
    levelinv = 4,
    learn = 5,
    learninv = 6,
    spell = 7,
    spellinv = 8,
}

local m_skill_tabnormal_inst = {skill = "skill/inst_normal"}
local m_skill_tabnormal_sort = SortType.name
local m_skill_tabnormal_sortfunc = {}
local m_skill_tabnormal_lowlevel = false
local m_skill_tabnormal_unlearn = false

function skill_tabnormal_sortskill(p1, p2)
    for i=1,#m_skill_tabnormal_sortfunc do
        local compare = m_skill_tabnormal_sortfunc[i](p1, p2)
        if compare ~= 0 then
            return compare < 0
        end
    end
    return false
end

function skill_tabnormal_init()
    local list_skill = m_uiskill_main:getwidget("tab_normal/list_skill")
    list_skill:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_skill:setclickdelegate(skill_tabnormal_delegate_clicklistitem)
    list_skill:setasyncdelegate(skill_tabnormal_delegate_listitem)

    local checkbox_lowlevel = m_uiskill_main:getwidget("tab_normal/checkbox_lowlevel")
    checkbox_lowlevel:setcheck(m_skill_tabnormal_lowlevel)
    checkbox_lowlevel:setdelegate(skill_tabnormal_delegate_lowlevel)

    local checkbox_unlearn = m_uiskill_main:getwidget("tab_normal/checkbox_unlearn")
    checkbox_unlearn:setcheck(m_skill_tabnormal_unlearn)
    checkbox_unlearn:setdelegate(skill_tabnormal_delegate_unlearn)

    local button_setskillbar = m_uiskill_main:getwidget("tab_normal/button_setskillbar")
    button_setskillbar:setenable(false)
    button_setskillbar:setdelegate(skill_tabnormal_delegate_setskillbar)

    m_uiskill_main:setwidgetdelegate("tab_normal/button_name", skill_tabnormal_delegate_sortname)
    m_uiskill_main:setwidgetdelegate("tab_normal/button_level", skill_tabnormal_delegate_sortlevel)
    m_uiskill_main:setwidgetdelegate("tab_normal/button_learn", skill_tabnormal_delegate_sortlearn)
    m_uiskill_main:setwidgetdelegate("tab_normal/button_spell", skill_tabnormal_delegate_sortspell)
end

local function skill_tabnormal_skillavailable(config_skilllearn)
    if config_skilllearn.learntype == csvskilllearntype.auto or config_skilllearn.learntype == csvskilllearntype.skillbook then
        local spellwaytype = config_skilllearn.config_skill.spellway
        if csvskill_spellwayactive(config_skilllearn.config_skill) then
            if playercivavailable(config_skilllearn.civ, playerattr_info.civ) then
                return true
            end
        end
    end
    return false
end
function skill_tabnormal_updateui()
    if #m_skill_tabnormal_sortfunc == 0 then
        m_skill_tabnormal_sortfunc = {skillsort_name, skillsort_level, skillsort_learn, skillsort_spell}
    end

    local config_skillarray = {}
    local config_skilltable = {}
    local config_skilllearnall = csvskilllearn_getfromcivcareer(playerattr_info.civ, playerattr_info.career)
    for key, val in pairs(config_skilllearnall) do
        local config_skilllearn = val
        if (m_skill_tabnormal_unlearn or playerskill_available(config_skilllearn.id)) and skill_tabnormal_skillavailable(config_skilllearn) then
            if m_skill_tabnormal_lowlevel or config_skilllearn.config_skill.category == 0 then
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
    table.sort(config_skillarray, skill_tabnormal_sortskill)
    if playerattr_rankskill ~= nil then
        for i=1,#playerattr_rankskill do
            local config_skill = csvskill_getfromid(playerattr_rankskill[i])
			if config_skill ~= nil then
				config_skillarray[#config_skillarray + 1] = config_skill
			end
		end
    end
    
    local list_skill = m_uiskill_main:getwidget("tab_normal/list_skill")
    list_skill:savestate()
    list_skill:clear()
    for i=1,#config_skillarray do
        local config_skilllearn = config_skillarray[i]
        list_skill:add(m_skill_tabnormal_inst.skill, config_skilllearn.id, config_skilllearn)
    end
    for key, val in pairs(playerattr_skill) do
		if config_skilllearnall[key] == nil then
            local config_skilladditive = csvskill_getfromid(key)
            if config_skilladditive ~= nil then
                list_skill:add(m_skill_tabnormal_inst.skill, config_skilladditive.id, config_skilladditive)
            end
        end
	end
    list_skill:restorestate()
end

function skill_tabnormal_delegate_clicklistitem(sender, line, config_skilllearn)
    if config_skilllearn.config_skill ~= nil then
        skill_main_setskilldesc("tab_normal", config_skilllearn.config_skill, false)
    else
        skill_main_setskilldesc("tab_normal", config_skilllearn, false)
    end

    local button_setskillbar = m_uiskill_main:getwidget("tab_normal/button_setskillbar")
    button_setskillbar:setenable(true)
end

function skill_tabnormal_delegate_listitem(sender, line, config_skilllearn)
    local text_name = line:getwidget("text_name")
    local text_level = line:getwidget("text_level")
    local text_learn = line:getwidget("text_learn")
    local config_skill = nil
    if config_skilllearn.config_skill ~= nil then
        config_skill = config_skilllearn.config_skill
        text_name:settextraw(config_skilllearn.config_skill.name)
        text_level:settextraw(config_skilllearn.playerlevel)
        if config_skilllearn.learntype == csvskilllearntype.auto then
            text_learn:settext("SKILL_LEARN_AUTO")
        elseif config_skilllearn.learntype == csvskilllearntype.skillbook then
            text_learn:settext("SKILL_LEARN_SKILLBOOK")
        end
    else
        config_skill = config_skilllearn
        text_name:settext(config_skill.name)
        text_level:settextraw("")
        text_learn:settext("")
    end
    
    local image_shortcut = line:getwidget("image_shortcut")
    image_shortcut:setavailablecolor(playerskill_skillinshortcut(config_skill.id))

    local text_spell = line:getwidget("text_spell")
    local spellwaytype = config_skill.spellway
    if spellwaytype == csvskillspellway.passive then
        text_spell:settext("SKILL_SPELLWAY_PASSIVE")
    elseif spellwaytype == csvskillspellway.active or spellwaytype == csvskillspellway.maintain then
        text_spell:settext("SKILL_SPELLWAY_ACTIVE")
    elseif spellwaytype == csvskillspellway.toggle then
        text_spell:settext("SKILL_SPELLWAY_TOGGLE")
    elseif spellwaytype == csvskillspellway.qte
        or spellwaytype == csvskillspellway.dodge
        or spellwaytype == csvskillspellway.parry
        or spellwaytype == csvskillspellway.block then
        text_spell:settext("SKILL_SPELLWAY_QTE")
    else
        text_spell:settext("")
    end

    local image_icon = line:getwidget("image_icon")
    image_icon:seticon(config_skill.icon)
    image_icon:setavailablecolor(playerskill_available(config_skill.id))

    local text_count = line:getwidget("text_count")
    local skilllevel = playerskill_getdeltalevel(config_skill.id)
    if skilllevel > 0 then
        text_count:settext(skilllevel)
    else
        text_count:settext("")
    end
end

function skill_tabnormal_delegate_lowlevel(sender, event)
    m_skill_tabnormal_lowlevel = event.name == "check"
    skill_tabnormal_updateui()
end

function skill_tabnormal_delegate_unlearn(sender, event)
    m_skill_tabnormal_unlearn = event.name == "check"
    skill_tabnormal_updateui()
end

function skill_tabnormal_delegate_setskillbar()
    local list_skill = m_uiskill_main:getwidget("tab_normal/list_skill")
    local config_skill = list_skill:getfirstselect()
    if config_skill ~= nil then
        skill_setting_opensetting(csvskillslottype.skill, config_skill.id)
    end
end

function skill_tabnormal_delegate_sortname()
    if m_skill_tabnormal_sort == SortType.name then
        m_skill_tabnormal_sort = SortType.nameinv
        m_skill_tabnormal_sortfunc = {skillsort_name_inv, skillsort_level, skillsort_learn, skillsort_spell}
    else
        m_skill_tabnormal_sort = SortType.name
        m_skill_tabnormal_sortfunc = {skillsort_name, skillsort_level, skillsort_learn, skillsort_spell}
    end
    skill_tabnormal_updateui()
end

function skill_tabnormal_delegate_sortlevel()
    if m_skill_tabnormal_sort == SortType.level then
        m_skill_tabnormal_sort = SortType.levelinv
        m_skill_tabnormal_sortfunc = {skillsort_level_inv, skillsort_name, skillsort_learn, skillsort_spell}
    else
        m_skill_tabnormal_sort = SortType.level
        m_skill_tabnormal_sortfunc = {skillsort_level, skillsort_name, skillsort_learn, skillsort_spell}
    end
    skill_tabnormal_updateui()
end

function skill_tabnormal_delegate_sortlearn()
    if m_skill_tabnormal_sort == SortType.learn then
        m_skill_tabnormal_sort = SortType.learninv
        m_skill_tabnormal_sortfunc = {skillsort_learn_inv, skillsort_level, skillsort_name, skillsort_spell}
    else
        m_skill_tabnormal_sort = SortType.learn
        m_skill_tabnormal_sortfunc = {skillsort_learn, skillsort_level, skillsort_name, skillsort_spell}
    end
    skill_tabnormal_updateui()
end

function skill_tabnormal_delegate_sortspell()
    if m_skill_tabnormal_sort == SortType.spell then
        m_skill_tabnormal_sort = SortType.spellinv
        m_skill_tabnormal_sortfunc = {skillsort_spell_inv, skillsort_learn, skillsort_level, skillsort_name}
    else
        m_skill_tabnormal_sort = SortType.spell
        m_skill_tabnormal_sortfunc = {skillsort_spell, skillsort_learn, skillsort_level, skillsort_name}
    end
    skill_tabnormal_updateui()
end
