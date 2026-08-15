
local m_skill_tabpreset_inst = {inst = "skill/inst_preset", title = "skill/inst_slottitle", skill = "skill/inst_slotskill", empty = "skill/inst_slotempty"}
local m_skill_tabpreset_maxcount = 10
local m_skill_tabpreset_selectuuid = 0
local m_skill_tabpreset_selecticon = 0
local m_skill_tabpreset_selectskill = false
local m_skill_tabpreset_preselecttime = 0

function skill_tabpreset_init()
    m_uiskill_main:setwidgetdelegate("tab_preset/button_add", skill_tabpreset_delegate_addpreset)

    local list_preset = m_uiskill_main:getwidget("tab_preset/list_preset")
    list_preset:init(uilistflag.vertical)

    local list_skill = m_uiskill_main:getwidget("tab_preset/list_skill")
    list_skill:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_skill:setasyncdelegate(skill_tabpreset_delegate_setlist)
    m_skill_tabpreset_selectuuid = 0
    m_skill_tabpreset_selecticon = 0
    m_skill_tabpreset_selectskill = false
    m_skill_tabpreset_preselecttime = 0

    event_register(eventtype.update, skill_tabpreset_update, m_uiskill_main)
end

local function skill_tabpreset_initpreseticon(line, preset)
    local iconcount = 1
    while true do
        local image_iconbg = line:getwidget("image_icon_" .. iconcount .. "/image_iconbg")
        if image_iconbg == nil then
            break
        end
        image_iconbg:setdelegate(skill_tabpreset_delegate_preseticon)
        image_iconbg.uuid = preset.uuid
        image_iconbg.iconindex = iconcount
        
        local image_icon = line:getwidget("image_icon_" .. iconcount .. "/image_icon")
        image_icon:seticon(playerskillpreset_geticon(iconcount - 1))

        local image_iconselect = line:getwidget("image_icon_" .. iconcount .. "/image_iconselect")
        image_iconselect:setvisiblenothit(preset.icon == (iconcount - 1))

        iconcount = iconcount + 1
    end
end

local function skill_tabpreset_initskillicon(line, preset)
    local iconcount = 1
    while true do
        local image_iconbg = line:getwidget("image_skill_" .. iconcount .. "/image_iconbg")
        if image_iconbg == nil then
            break
        end
        image_iconbg:setdelegate(skill_tabpreset_delegate_skillicon)
        image_iconbg.uuid = preset.uuid
        image_iconbg.index = iconcount
        
        local image_icon = line:getwidget("image_skill_" .. iconcount .. "/image_icon")
        image_icon:setvisible(false)
        
        local skillid = preset.skillid[iconcount]
        if skillid ~= nil and skillid > 0 then
            local config_skill = csvskill_getfromid(skillid)
            if config_skill ~= nil then
                local config_toplevel = playerskill_gettoplevelavailable(config_skill)
                if config_toplevel ~= nil then
                    config_skill = config_toplevel
                end
                image_icon:seticon(config_skill.icon)
                image_icon:setvisiblenothit(true)
            end
        end

        local select = preset.uuid == m_skill_tabpreset_selectuuid and m_skill_tabpreset_selecticon == iconcount
        local image_iconselect = line:getwidget("image_skill_" .. iconcount .. "/image_iconselect")
        image_iconselect:setvisiblenothit(select)

        iconcount = iconcount + 1
    end
end

local function skill_tabpreset_addskilllisttitle(list_skill, title)
    local linedata = {}
    linedata.title = title
    list_skill:add(m_skill_tabpreset_inst.title, list_skill:getcount(), linedata)
end

local function skill_tabpreset_addskilllisticon(list_skill, inst, config_skill, delegate)
    local linedata = {}
    linedata.config_skill = config_skill
    linedata.delegate = delegate
    list_skill:add(inst, list_skill:getcount(), linedata)
end

function skill_tabpreset_updateskilllist()
    local list_skill = m_uiskill_main:getwidget("tab_preset/list_skill")
    list_skill:savestate()
    list_skill:clear()

    local config_skillstigma = {}
    local config_skillarray = {}
    local config_skilltable = {}
    for key, val in pairs(playerattr_skill) do
        local config_skill = csvskill_getfromid(key)
        if config_skill ~= nil then
            if csvskill_spellwayactive(config_skill) then
                local config_skilllearn = csvskilllearn_getfromid(config_skill.id)
                if config_skilllearn ~= nil and (config_skilllearn.learntype == csvskilllearntype.stigma or config_skilllearn.learntype == csvskilllearntype.stigmaadvance) then
                    config_skillstigma[#config_skillstigma + 1] = config_skill
                elseif config_skill.category == 0 then
                    config_skillarray[#config_skillarray + 1] = config_skill
                else
                    local index = config_skilltable[config_skill.category]
                    if index == nil then
                        config_skillarray[#config_skillarray + 1] = config_skill
                        config_skilltable[config_skill.category] = #config_skillarray
                    else
                        local prev_learn = config_skillarray[index]
                        if prev_learn.categorylevel < config_skill.categorylevel then
                            config_skillarray[index] = config_skill
                        end
                    end
                end
            end
        end
	end
    table.sort(config_skillstigma, function(p1, p2) return c_textcompare(p1.name, p2.name) < 0 end)
    table.sort(config_skillarray, function(p1, p2) return c_textcompare(p1.name, p2.name) < 0 end)
    if playerattr_rankskill ~= nil then
        for i=1,#playerattr_rankskill do
            local config_skill = csvskill_getfromid(playerattr_rankskill[i])
			if config_skill ~= nil then
				config_skillarray[#config_skillarray + 1] = config_skill
			end
		end
    end
    
    skill_tabpreset_addskilllisttitle(list_skill, "SKILL_TAB_NORMAL")
    skill_tabpreset_addskilllisticon(list_skill, m_skill_tabpreset_inst.empty, nil, skill_tabpreset_delegate_skilllist)
    local config_skill = csvskill_getfromid(skill_system_attack)
    skill_tabpreset_addskilllisticon(list_skill, m_skill_tabpreset_inst.skill, config_skill, skill_tabpreset_delegate_skilllist)
    
    for i=1,#config_skillarray do
        local config_skill = config_skillarray[i]
        skill_tabpreset_addskilllisticon(list_skill, m_skill_tabpreset_inst.skill, config_skill, skill_tabpreset_delegate_skilllist)
    end
    
    if #config_skillstigma > 0 then
        skill_tabpreset_addskilllisttitle(list_skill, "SKILL_TAB_STIGMA")
        for i=1,#config_skillstigma do
            local config_skill = config_skillstigma[i]
            skill_tabpreset_addskilllisticon(list_skill, m_skill_tabpreset_inst.skill, config_skill, skill_tabpreset_delegate_skilllist)
        end    
    end

    list_skill:restorestate()
end

function skill_tabpreset_addpreset(list_preset, preset)
    local line = list_preset:add(m_skill_tabpreset_inst.inst)
    line.uuid = preset.uuid

    local edit_name = line:getwidget("edit_name")
    edit_name:settext(preset.name)
    edit_name:setdelegate(skill_tabpreset_delegate_presetname)
    edit_name.uuid = preset.uuid

    local text_type = line:getwidget("text_type")
    text_type:settext("SKILL_PLAYERQTE_CURRENTTYPE", c_textformat("SKILL_PLAYERQTE_TYPE" .. (preset.type + 1)))

    local button_settype = line:getwidget("button_settype")
    button_settype:setdelegate(skill_tabpreset_delegate_settype)
    button_settype.uuid = preset.uuid

    local button_delete = line:getwidget("button_delete")
    button_delete:setdelegate(skill_tabpreset_delegate_delpreset)
    button_delete.uuid = preset.uuid

    local button_setskillbar = line:getwidget("button_setskillbar")
    button_setskillbar:setdelegate(skill_tabpreset_delegate_setskillbar)
    button_setskillbar.uuid = preset.uuid

    skill_tabpreset_initpreseticon(line, preset)
    skill_tabpreset_initskillicon(line, preset)
end

function skill_tabpreset_updateui()
    if m_uiskill_main:null() then
        return
    end
    skill_main_setdesctext("tab_preset", nil, nil)
    m_uiskill_main:setwidgetvisible("tab_preset/list_skill", m_skill_tabpreset_selectskill)
    m_uiskill_main:setwidgetenable("tab_preset/button_add", #playerattr_skillpreset < m_skill_tabpreset_maxcount)

    local text_count = m_uiskill_main:getwidget("tab_preset/text_count")
    text_count:settext(string.format("(%d/%d)", #playerattr_skillpreset, m_skill_tabpreset_maxcount))

    local list_preset = m_uiskill_main:getwidget("tab_preset/list_preset")
    list_preset:savestate()
    list_preset:clear()

    for i=1,#playerattr_skillpreset do
        skill_tabpreset_addpreset(list_preset, playerattr_skillpreset[i])
    end

    if not m_skill_tabpreset_selectskill and m_skill_tabpreset_selectuuid ~= 0 and m_skill_tabpreset_selecticon ~= 0 then
        local skillid = 0
        local preset = playerskillpreset_getpreset(m_skill_tabpreset_selectuuid)
        if preset ~= nil then
            local presetskillid = preset.skillid[m_skill_tabpreset_selecticon]
            if presetskillid ~= nil then
                skillid = presetskillid
            end
        end
        if skillid ~= 0 then
            skill_main_setskilldesc("tab_preset", csvskill_getfromid(skillid), true)
        else
            skill_main_setdesctext("tab_preset", "SKILL_PLAYERQTE_NOSKILL", "SKILL_PLAYERQTE_SELECTSKILL")
        end
    end

    list_preset:restorestate()
end

function skill_tabpreset_update()
    if m_skill_tabpreset_preselecttime > 0 and time_game - m_skill_tabpreset_preselecttime > 0.5 then
        m_skill_tabpreset_preselecttime = 0
        m_skill_tabpreset_selectskill = true
        skill_tabpreset_updateskilllist()
        skill_tabpreset_updateui()
    end
end

local function skill_tabpreset_getline(uuid)
    if m_uiskill_main:alive() then
        local list_preset = m_uiskill_main:getwidget("tab_preset/list_preset")
        for i=1,list_preset:getcount() do
            local line = list_preset:getlinefromindex(i)
            if line.uuid == uuid then
                return line
            end
        end
    end
end

function skill_tabpreset_setname(uuid, name)
    local line = skill_tabpreset_getline(uuid)
    if line ~= nil then
        local edit_name = line:getwidget("edit_name")
        edit_name:settext(name)
    end
end

function skill_tabpreset_settype(uuid, type)
    local line = skill_tabpreset_getline(uuid)
    if line ~= nil then
        local text_type = line:getwidget("text_type")
        text_type:settext("SKILL_PLAYERQTE_CURRENTTYPE", c_textformat("SKILL_PLAYERQTE_TYPE" .. (type + 1)))
    end
end

function skill_tabpreset_seticon(uuid, icon)
    local line = skill_tabpreset_getline(uuid)
    if line ~= nil then
        local iconcount = 1
        while true do
            local image_iconselect = line:getwidget("image_icon_" .. iconcount .. "/image_iconselect")
            if image_iconselect == nil then
                break
            end
            image_iconselect:setvisiblenothit(icon == (iconcount - 1))
            iconcount = iconcount + 1
        end
    end
end

function skill_tabpreset_setskill(uuid, slot, skillid)
    if m_uiskill_main:null() then
        return
    end
    local line = skill_tabpreset_getline(uuid)
    if line ~= nil then
        local image_icon = line:getwidget("image_skill_" .. slot .. "/image_icon")
        if skillid > 0 then
            local config_skill = csvskill_getfromid(skillid)
            if config_skill ~= nil then
                local config_toplevel = playerskill_gettoplevelavailable(config_skill)
                if config_toplevel ~= nil then
                    config_skill = config_toplevel
                end
                image_icon:setvisiblenothit(true)
                image_icon:seticon(config_skill.icon)
                if not m_skill_tabpreset_selectskill and m_skill_tabpreset_selectuuid == uuid and m_skill_tabpreset_selecticon == slot then
                    skill_main_setskilldesc("tab_preset", config_skill, true)
                end
            end
        else
            image_icon:setvisible(false)
        end
    end
end

function skill_tabpreset_delegate_setlist(sender, line, linedata)
    if linedata.title ~= nil then
        local text_name = line:getwidget("text_name")
        text_name:settext(linedata.title)
    elseif linedata.config_skill ~= nil then
        local image_event = line:getwidget("image_event")
        image_event:setdelegate(linedata.delegate)
        image_event.config_skill = linedata.config_skill

        local image_icon = line:getwidget("image_icon")
        image_icon:seticon(linedata.config_skill.icon)

        local text_name = line:getwidget("text_name")
        text_name:settext(linedata.config_skill.name)

        local text_level = line:getwidget("text_level")
        if linedata.config_skill.categorylevel > 0 then
            text_level:setvisiblenothit(true)
            text_level:settext(linedata.config_skill.categorylevel)
        else
            text_level:setvisible(false)
        end
    else
        local image_event = line:getwidget("image_event")
        image_event:setdelegate(linedata.delegate)
        image_event.config_skill = nil

        local text_name = line:getwidget("text_name")
        text_name:settext("SKILL_PLAYERQTE_EMPTY")
    end
end

function skill_tabpreset_delegate_preseticon(sender, event)
    if event.name == "mousedown" then
        local msg = {messageid="CS_SkillPresetSetIcon"}
        msg.uuid = sender.uuid
        msg.icon = sender.iconindex - 1
        c_send(msg)
    end
end

function skill_tabpreset_delegate_presetname(sender, event)
    local msg = {messageid="CS_SkillPresetSetName"}
    msg.uuid = sender.uuid
    msg.name = sender:gettext()
    c_send(msg)
end

function skill_tabpreset_delegate_addpreset(sender, event)
    local msg = {messageid="CS_SkillPresetCreate"}
    msg.name = c_textformat("SKILL_PLAYERQTE_DEFAULTNAME", #playerattr_skillpreset + 1)
    c_send(msg)
end

function skill_tabpreset_delegate_delete_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_SkillPresetDelete"}
        msg.uuid = data
        c_send(msg)
    end
end
function skill_tabpreset_delegate_delpreset(sender, event)
    local preset = playerskillpreset_getpreset(sender.uuid)
    if preset ~= nil then
        local text = c_textformat("SKILL_PLAYERQTE_DELCONFIRM", preset.name)
        messagebox_confirm(text, skill_tabpreset_delegate_delete_confirm, sender.uuid)
    end
end

function skill_tabpreset_delegate_setskillbar(sender, event)
    skill_setting_opensetting(csvskillslottype.preset, 0, sender.uuid)
end

function skill_tabpreset_delegate_settype(sender, event)
    local preset = playerskillpreset_getpreset(sender.uuid)
    if preset ~= nil then
        presetsetting_open(preset.uuid, preset.type)
    end
end

function skill_tabpreset_delegate_skillicon(sender, event)
    if event.name == "mousedown" then
        m_skill_tabpreset_preselecttime = time_game
        m_skill_tabpreset_selectuuid = sender.uuid
        m_skill_tabpreset_selecticon = sender.index
        m_skill_tabpreset_selectskill = false
        skill_tabpreset_updateui()
    elseif event.name == "mouseup" then
        m_skill_tabpreset_preselecttime = 0
    end
end

function skill_tabpreset_delegate_skilllist(sender, event)
    local msg = {messageid="CS_SkillPresetSetSkill"}
    msg.uuid = m_skill_tabpreset_selectuuid
    msg.slot = m_skill_tabpreset_selecticon - 1
    if sender.config_skill ~= nil then
        msg.skillid = sender.config_skill.id
    else
        msg.skillid = 0
    end
    c_send(msg)
    m_skill_tabpreset_selectskill = false
    skill_tabpreset_updateui()
end
