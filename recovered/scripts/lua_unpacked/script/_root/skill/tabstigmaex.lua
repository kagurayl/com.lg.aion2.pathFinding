
local m_skill_tabstigmaex_inst = {inst = "skill/inst_stigmaex"}
local m_link_size_col = 400
local m_link_size_row = 200
local m_link_size_headerx = 96
local m_link_size_headery = 96
local m_link_size_linkspace = 15

function skill_tabstigmaex_init()
    local list_qte = m_uiskill_main:getwidget("tab_stigmaex/list_stigmaex")
    list_qte:init(uilistflag.vertical)
end

local function skill_tabstigmaex_addskilllink(state, posx, icontable, stigma)
    local subicontable = {}
    local childposmin = nil
    local childposmax = nil
    for i=1, #stigma.depend do
        childposmax = skill_tabstigmaex_addskilllink(state, posx - 1.0, subicontable, stigma.depend[i])
        if childposmin == nil then
            childposmin = childposmax
        end
    end

    local iconx = m_link_size_headerx + posx * m_link_size_col
    local icony = nil
    if childposmin ~= nil then
        icony = (childposmin + childposmax) / 2.0
    else
        icony = -m_link_size_headery - state.iconlinecount * m_link_size_row
        state.iconlinecount = state.iconlinecount + 1
    end

    local image_root = state.line:getwidget("image_icon/image_icon_1")
    if state.iconindex == nil then
        state.iconindex = 1
    else
        state.iconindex = state.iconindex + 1
        local image_clone = state.line:getwidget("image_icon/image_icon_" .. state.iconindex)
        if image_clone == nil then
            image_clone = image_root:clone("image_icon_" .. state.iconindex)
            image_clone:setposition(0, 0)
        end
        image_root = image_clone
    end
    image_root:setvisible(true)

    local image_icon = image_root:getwidget("image_icon")
    local image_normal = image_root:getwidget("image_normal")
    local image_advance = image_root:getwidget("image_advance")
    image_normal:setvisiblenothit(stigma.config_skilllearn.learntype == csvskilllearntype.stigma)
    image_advance:setvisiblenothit(stigma.config_skilllearn.learntype == csvskilllearntype.stigmaadvance)
    image_normal:setposition(iconx, icony)
    image_advance:setposition(iconx, icony)

    image_icon:setvisible(true)
    image_icon:setposition(iconx, icony)
    image_icon:seticon(stigma.config_skill.icon)
    image_icon:setdelegate(skill_tabstigmaex_delegate_skillicon)
    image_icon.config_skill = stigma.config_skill
    local w,h = image_icon:getsize()
    if icontable ~= nil then
        local iconpos = {}
        iconpos.left = iconx - w / 2 - m_link_size_linkspace
        iconpos.top = icony + h / 2 + m_link_size_linkspace
        iconpos.right = iconx + w / 2 + m_link_size_linkspace
        iconpos.bottom = icony - h / 2 - m_link_size_linkspace
        iconpos.centerx = iconx
        iconpos.centery = icony
        iconpos.prob = 100
        icontable[#icontable + 1] = iconpos
    end
    if #subicontable > 0 then
        iconlink_array_to_single(subicontable, iconx - w / 2 - m_link_size_linkspace, icony, state.line)
    end
    return icony
end

function skill_tabstigmaex_updateui()
    local list_stigmaex = m_uiskill_main:getwidget("tab_stigmaex/list_stigmaex")
    list_stigmaex:savestate()
    list_stigmaex:clear()

    local itemarray = csvitem_getallfromtype(csvitemtype.skill_stigma)
    local itemstigma = {}
    local itemstigmatable = {}
    for key, val in pairs(itemarray) do
        local config_item = val
        local itemname = config_item.name
        local level = csvitem_getplayerlevel(config_item, playerattr_info.career)
        if level > 0 then
            local sublambda = csvitem_getscript(config_item, "stigma")
            if sublambda ~= nil then
                local skillid = sublambda.variable[1].integer
                local config_skill = csvskill_getfromid(skillid)
                local config_skilllearn = csvskilllearn_getfromid(skillid)
                if config_skill ~= nil and config_skilllearn ~= nil and playercivavailable(config_skilllearn.civ, playerattr_info.civ) then
                    if config_skill.category ~= 0 then
                        config_skill = csvskill_getfromid(config_skill.category)
                    end
                    if itemstigmatable[config_skill.id] == nil then
                        itemstigmatable[config_skill.id] = config_skill
                        local stigma = {}
                        stigma.config_item = config_item
                        stigma.config_skill = config_skill
                        stigma.config_skilllearn = config_skilllearn
                        stigma.depend = {}
                        stigma.depended = false
                        itemstigma[config_skill.id] = stigma
                    end
                end
            end
        end
    end

	for key, val in pairs(itemstigma) do
		local config_item = val.config_item
        local sublambda = csvitem_getscript(config_item, "stigma")
        if sublambda ~= nil then
            local skill1requirecount = sublambda.variable[4].integer
            local skill2requirecount = sublambda.variable[5].integer
            if skill1requirecount > 0 then
                local index = 5
                for i=1,skill1requirecount do
                    local dependskill = sublambda.variable[index + i].integer
                    local config_skill = csvskill_getfromid(dependskill)
                    local config_skilllearn = csvskilllearn_getfromid(dependskill)
                    if config_skill ~= nil and config_skilllearn ~= nil and playercivavailable(config_skilllearn.civ, playerattr_info.civ) then
                        if config_skill.category ~= 0 then
                            config_skill = csvskill_getfromid(config_skill.category)
                        end
                        local stigma = itemstigma[config_skill.id]
                        if stigma ~= nil then
                            stigma.depended = true
                            val.depend[#val.depend + 1] = stigma
                        end
                        break
                    end
                end
            end
            if skill2requirecount > 0 then
                local index = skill1requirecount + 5
                for i=1,skill2requirecount do
                    local dependskill = sublambda.variable[index + i].integer
                    local config_skill = csvskill_getfromid(dependskill)
                    local config_skilllearn = csvskilllearn_getfromid(dependskill)
                    if config_skill ~= nil and config_skilllearn ~= nil and playercivavailable(config_skilllearn.civ, playerattr_info.civ) then
                        if config_skill.category ~= 0 then
                            config_skill = csvskill_getfromid(config_skill.category)
                        end
                        local stigma = itemstigma[config_skill.id]
                        if stigma ~= nil then
                            stigma.depended = true
                            val.depend[#val.depend + 1] = stigma
                        end
                        break
                    end
                end
            end
        end
	end

    local stigmafinal = {}
    for key, val in pairs(itemstigma) do
		local stigma = val
        local config_skilllearn = csvskilllearn_getfromid(stigma.config_skill.id)
        if config_skilllearn ~= nil and config_skilllearn.learntype == csvskilllearntype.stigmaadvance then
            if not stigma.depended then
                stigmafinal[#stigmafinal + 1] = stigma
            end
        end
	end
    table.sort(stigmafinal, function(p1, p2) return (p1.config_skill.id < p2.config_skill.id) end)

    local stigmadepend = {}
    for i=1,#stigmafinal do
		stigmadepend[i] = stigmafinal[i]
	end
    local stigmadependnext = {}
    local dependlevel = 0
    while dependlevel < 10 and #stigmadepend > 0 do
        for i=1,#stigmadepend do
            local stigma = stigmadepend[i]
            for i=1,#stigma.depend do
                stigmadependnext[#stigmadependnext + 1] = stigma.depend[i]
            end
        end
        stigmadepend = stigmadependnext
        stigmadependnext = {}
        dependlevel = dependlevel + 1
    end

    local state = {}
    for i=1,#stigmafinal do
        state.line = list_stigmaex:add(m_skill_tabstigmaex_inst.inst)
        state.line:hidewidget()
        state.iconindex = nil
        state.iconlinecount = 0
        skill_tabstigmaex_addskilllink(state, dependlevel - 1.0, nil, stigmafinal[i])
        state.line:setsize(state.iconlinecount * m_link_size_row + m_link_size_headery * 2.0)
    end

    list_stigmaex:updatecontentsize()
    list_stigmaex:restorestate()
end

function skill_tabstigmaex_delegate_skillicon(sender, event)
    skill_main_setskilldesc("tab_stigmaex", sender.config_skill, false)
end
