
local m_skill_tabqte_inst = {inst = "skill/inst_qte"}
local m_skill_tabqte_selectentry = 0
local m_skill_tabqte_selectskill = 0
local m_skill_tabqte_selecttriggerid = 0
local m_link_size_col = 400
local m_link_size_row = 200
local m_link_size_headerx = 96
local m_link_size_headery = 96
local m_link_size_linkspace = 10
local m_link_state_line = nil

function skill_tabqte_init()
    m_uiskill_main:setwidgetdelegate("tab_qte/button_moveup", skill_tabqte_delegate_moveup)
    m_uiskill_main:setwidgetdelegate("tab_qte/button_movedown", skill_tabqte_delegate_movedown)
    m_uiskill_main.skilllearnall = csvskilllearn_getfromcivcareer(playerattr_info.civ, playerattr_info.career)
    local list_qte = m_uiskill_main:getwidget("tab_qte/list_qte")
    list_qte:init(uilistflag.vertical)
    m_skill_tabqte_selectentry = 0
    m_skill_tabqte_selectskill = 0
    m_skill_tabqte_selecttriggerid = 0

    local button_moveup = m_uiskill_main:getwidget("tab_qte/button_moveup")
    local button_movedown = m_uiskill_main:getwidget("tab_qte/button_movedown")
    button_moveup:setenablenofade(moveable)
    button_movedown:setenablenofade(moveable)
end

local function skill_tabqte_available(skillid)
    return m_uiskill_main.skilllearnall[skillid] ~= nil or playerskill_available(skillid)
end

local function skill_tabqte_updateselect()
    local list_qte = m_uiskill_main:getwidget("tab_qte/list_qte")
    local moveable = false
    for i=1,list_qte:getcount() do
        local line = list_qte:getlinefromindex(i)
        local iconindex = 1
        while true do
            local image_iconroot = line:getwidget("image_icon/image_icon_" .. iconindex)
            if image_iconroot == nil then
                break
            end
            local image_iconselect = image_iconroot:getwidget("image_iconselect")
            if image_iconroot.skillid == m_skill_tabqte_selectskill
            and image_iconroot.entryid == m_skill_tabqte_selectentry
            and image_iconroot.triggerid == m_skill_tabqte_selecttriggerid then
                local subqte = csvskill_getqtesublinkadjustpriority(m_skill_tabqte_selecttriggerid)
                if subqte ~= nil then
                    local subqtecount = 0
                    for i=1,#subqte do
                        local config_skill = subqte[i]
                        if skill_tabqte_available(config_skill.id) then
                            subqtecount = subqtecount + 1
                        end
                    end
                    if subqtecount > 1 then
                        moveable = true
                    end
                end
                image_iconselect:setvisiblenothit(true)
            else
                image_iconselect:setvisiblenothit(false)
            end
            iconindex = iconindex + 1
        end
    end
    local button_moveup = m_uiskill_main:getwidget("tab_qte/button_moveup")
    local button_movedown = m_uiskill_main:getwidget("tab_qte/button_movedown")
    button_moveup:setenable(moveable)
    button_movedown:setenable(moveable)
end

local function skill_tabqte_addicon(iconx, icony, iconpath, triggerid, skillid)
    local image_iconroot = m_link_state_line:getwidget("image_icon/image_icon_1")
    m_link_state_line.iconindex = m_link_state_line.iconindex + 1
    if m_link_state_line.iconindex > 1 then
        local image_clone = m_link_state_line:getwidget("image_icon/image_icon_" .. m_link_state_line.iconindex)
        if image_clone == nil then
            image_clone = image_iconroot:clone("image_icon_" .. m_link_state_line.iconindex)
        end
        image_iconroot = image_clone
    end
    image_iconroot:setvisible(true)
    image_iconroot:setposition(iconx, icony)
    image_iconroot.entryid = m_link_state_line.entryid
    image_iconroot.triggerid = triggerid
    image_iconroot.skillid = skillid

    local image_icon = image_iconroot:getwidget("image_icon")
    image_icon:setvisible(true)
    image_icon:seticon(iconpath)
    image_icon:setdelegate(skill_tabqte_delegate_skillicon)
    image_icon.entryid = m_link_state_line.entryid
    image_icon.triggerid = triggerid
    image_icon.skillid = skillid

    local w,h = image_iconroot:getsize()
    local iconpos = {}
    iconpos.left = iconx - w / 2 - m_link_size_linkspace
    iconpos.top = icony + h / 2 + m_link_size_linkspace
    iconpos.right = iconx + w / 2 + m_link_size_linkspace
    iconpos.bottom = icony - h / 2 - m_link_size_linkspace
    iconpos.centerx = iconx
    iconpos.centery = icony
    iconpos.width = w
    iconpos.height = h
    iconpos.prob = 100
    return iconpos
end

local function skill_tabqte_getbufficon(config_buff)
    local lambda = config_buff.lambda
    if lambda == nil then
        return
    end
    local arraycount = lambda.arraysize
    for i=1,arraycount do
        local lambda2 = lambda.lambdaarray[i]
        local actioncount = lambda2.actioncount
        for j=1,actioncount do
            local sublambda = lambda2[j]
            if c_isaction(sublambda, "openaerial") then
                return "skills/cond_openaerial", skill_counter_openaerial
            elseif c_isaction(sublambda, "spin") then
                return "skills/cond_spin", skill_counter_spin
            elseif c_isaction(sublambda, "stagger") then
                return "skills/cond_stagger", skill_counter_stagger
            elseif c_isaction(sublambda, "stumble") then
                return "skills/cond_stumble", skill_counter_stumble
            elseif c_isaction(sublambda, "stun") then
                return "skills/cond_stun", skill_counter_stun
            end
        end
    end 
end

local function skill_tabqte_getskillicon(skillid)
    if skillid >0 then
        local config_skill = csvskill_getfromid(skillid)
        if config_skill ~= nil then
            local config_toplevel = playerskill_gettoplevelavailable(config_skill)
            if config_toplevel ~= nil then
                config_skill = config_toplevel
            end
            return config_skill.icon
        end
    elseif skillid == skill_counter_openaerial then
        return "skills/cond_openaerial"
    elseif skillid == skill_counter_spin then
        return "skills/cond_spin"
    elseif skillid == skill_counter_stagger then
        return "skills/cond_stagger"
    elseif skillid == skill_counter_stumble then
        return "skills/cond_stumble"
    elseif skillid == skill_counter_stun then
        return "skills/cond_stun"
    elseif skillid == skill_counter_evade then
        return "skills/evade_impactstate"
    elseif skillid == skill_counter_dodge then
        return "skills/counter_dodge"
    elseif skillid == skill_counter_parry then
        return "skills/counter_parry"
    elseif skillid == skill_counter_block then
        return "skills/counter_block"
    end
end

local function skill_tabqte_getposx(colindex)
    return m_link_size_headerx + colindex * m_link_size_col
end

local function skill_tabqte_getposy(rowindex, subcount)
    subcount = math.max(1, subcount)
    return -m_link_size_headery - rowindex * m_link_size_row - subcount * m_link_size_row / 2
end

local function skill_tabqte_subcount(skillid)
    local linkarray = csvskill_getqtesublinkadjustpriority(skillid)
    local count = 0
    if linkarray ~= nil then
        for i=1,#linkarray do
            local config_skill = linkarray[i]
            if skill_tabqte_available(config_skill.id) then
                count = count + math.max(1, skill_tabqte_subcount(config_skill.id))
            end
        end
    end
    return count
end

local function skill_tabqte_addline(list_qte, entryid)
    m_link_state_line = list_qte:add(m_skill_tabqte_inst.inst)
    m_link_state_line:hidewidget()
    m_link_state_line.entryid = entryid
    m_link_state_line.iconindex = 0
end

local function skill_tabqte_addsublink(colindex, rowindex, triggerid, skillid, iconarray)
    local subcount = skill_tabqte_subcount(skillid)
    local subiconarray = {}
    if subcount > 0 then
        local qtesublink = csvskill_getqtesublinkadjustpriority(skillid)
        if qtesublink ~= nil then
            local subrowindex = rowindex
            for i=1, #qtesublink do
                local config_skill = qtesublink[i]
                if skill_tabqte_available(config_skill.id) then
                    skill_tabqte_addsublink(colindex + 1, subrowindex, skillid, config_skill.id, subiconarray)
                    local subcount2 = skill_tabqte_subcount(config_skill.id)
                    subrowindex = subrowindex + math.max(1, subcount2)
                end
            end
        end
    else
        local config_skill = csvskill_getfromid(skillid)
        if config_skill ~= nil then
            local lambda = config_skill.lambda
            if lambda ~= nil then
                local actioncount = lambda.actioncount
                for i=1,actioncount do
                    local sublambda = lambda[i]
                    if c_isaction(sublambda, "buff") or c_isaction(sublambda, "filterbuff") then
                        local buffid = sublambda.variable[1].integer
                        local config_buff = csvskillbuff_getfromid(buffid)
                        if config_buff ~= nil then
                            local bufficon, buffskillid = skill_tabqte_getbufficon(config_buff)
                            if bufficon ~= nil then
                                local buffposx = skill_tabqte_getposx(colindex + 1)
                                local buffposy = skill_tabqte_getposy(rowindex, 0)
                                local bufficonpos = skill_tabqte_addicon(buffposx, buffposy, bufficon, skillid, buffskillid)
                                subiconarray[#subiconarray + 1] = bufficonpos
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    local posx = skill_tabqte_getposx(colindex)
    local posy = skill_tabqte_getposy(rowindex, subcount)
    if #subiconarray > 0 then
        posy = math.lerp(subiconarray[1].centery, subiconarray[#subiconarray].centery, 0.5)
    end
    local icon = skill_tabqte_getskillicon(skillid)
    local iconpos = skill_tabqte_addicon(posx, posy, icon, triggerid, skillid)
    if iconarray ~= nil then
        iconarray[#iconarray + 1] = iconpos
    end
    if #subiconarray > 0 then
        local linkstartx = posx + iconpos.width / 2 + m_link_size_linkspace
        iconlink_single_to_array(linkstartx, posy, subiconarray, m_link_state_line)
    end
end

local function skill_tabqte_addentry(list_qte, entryid)
    local subcount = skill_tabqte_subcount(entryid)
    if subcount == 0 then
        return
    end
    skill_tabqte_addline(list_qte, entryid)
    skill_tabqte_addsublink(0, 0, 0, entryid, nil)
    m_link_state_line:setsize(subcount * m_link_size_row + m_link_size_headery * 2.0)
    m_link_state_line = nil
end

function skill_tabqte_updateui()
    local list_qte = m_uiskill_main:getwidget("tab_qte/list_qte")
    list_qte:savestate()
    list_qte:clear()

    local allqte = csvskill_getallqte()
    local entryarray = {}
    for skillid, val in pairs(allqte) do
        if skillid > 0 then
            if skill_tabqte_available(skillid) then
                local config_skill = csvskill_getfromid(skillid)
                if config_skill.spellway == csvskillspellway.active then
                    local selectstate = config_skill.selectstate
                    if selectstate ~= nil then
                        local buffactive = false
                        local actioncount = selectstate.actioncount
                        for i=1,actioncount do
                            local sublambda = selectstate[i]
                            if c_isaction(sublambda, "buff") then
                                buffactive = true
                                break
                            end
                        end
                        if not buffactive then
                            entryarray[#entryarray + 1] = skillid
                        end
                    end
                end
            end
        end
	end
    table.sort(entryarray, function(a, b) return (a < b) end)
    entryarray[#entryarray + 1] = skill_counter_stumble
    entryarray[#entryarray + 1] = skill_counter_stun
    entryarray[#entryarray + 1] = skill_counter_stagger
    entryarray[#entryarray + 1] = skill_counter_spin
    entryarray[#entryarray + 1] = skill_counter_openaerial
    entryarray[#entryarray + 1] = skill_counter_evade
    entryarray[#entryarray + 1] = skill_counter_dodge
    entryarray[#entryarray + 1] = skill_counter_parry
    entryarray[#entryarray + 1] = skill_counter_block

    for i=1,#entryarray do
        skill_tabqte_addentry(list_qte, entryarray[i])
    end

    skill_tabqte_updateselect()

    list_qte:updatecontentsize()
    list_qte:restorestate()
end

function skill_tabqte_delegate_skillicon(sender, event)
    m_skill_tabqte_selectentry = sender.entryid
    m_skill_tabqte_selectskill = sender.skillid
    m_skill_tabqte_selecttriggerid = sender.triggerid
    skill_tabqte_updateselect()

    local config_skill = csvskill_getfromid(sender.skillid)
    if config_skill ~= nil then
        skill_main_setskilldesc("tab_qte", config_skill, true)
    elseif sender.skillid == skill_counter_dodge then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_DODGE")
    elseif sender.skillid == skill_counter_parry then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_PARRY")
    elseif sender.skillid == skill_counter_block then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_BLOCK")
    elseif sender.skillid == skill_counter_evade then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_EVADE")
    elseif sender.skillid == skill_counter_stumble then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_STUMBLE")
    elseif sender.skillid == skill_counter_stun then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_STUN")
    elseif sender.skillid == skill_counter_stagger then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_STAGGER")
    elseif sender.skillid == skill_counter_spin then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_SPIN")
    elseif sender.skillid == skill_counter_openaerial then
        skill_main_setskilldescsplit("tab_qte", "SKILL_QTE_COUNTER_OPENAERIAL")
    end
end

local function skill_tabqte_verifypriorityskillid(skillid)
    if not skill_tabqte_available(skillid) then
        if skillid ~= skill_counter_dodge
        and skillid ~= skill_counter_parry
        and skillid ~= skill_counter_block
        and skillid ~= skill_counter_evade
        and skillid ~= skill_counter_stumble
        and skillid ~= skill_counter_stun
        and skillid ~= skill_counter_stagger
        and skillid ~= skill_counter_spin
        and skillid ~= skill_counter_openaerial then
            return false
        end
    end
    return true
end

local function skill_tabqte_sendpriority(qtelink)
    local add = true
    for i=1,#playerattr_skillqtepriority do
        if playerattr_skillqtepriority[i].skillid == m_skill_tabqte_selecttriggerid then
            playerattr_skillqtepriority[i].qtelink = qtelink
            add = false
            break
        end
    end
    if add then
        local addqte = {}
        addqte.skillid = m_skill_tabqte_selecttriggerid
        addqte.qtelink = qtelink
        playerattr_skillqtepriority[#playerattr_skillqtepriority + 1] = addqte
    end
    
    for i=#playerattr_skillqtepriority,1,-1 do
        local priority = playerattr_skillqtepriority[i]
        if not skill_tabqte_verifypriorityskillid(priority.skillid) then
            playerattr_skillqtepriority[i].qtelink = qtelink
            table.remove(playerattr_skillqtepriority, i)
        end
    end
    local msg = {messageid="CS_SkillQtePriority"}
    msg.priority = playerattr_skillqtepriority
    c_send(msg)
end

local function skill_tabqte_getpriority()
    local priority = {}
    local sublink = csvskill_getqtesublinkadjustpriority(m_skill_tabqte_selecttriggerid)
    if sublink ~= nil then
        for i=1,#sublink do
            if skill_tabqte_available(sublink[i].id) then
                priority[#priority + 1] = sublink[i].id
            end
        end
    end
    return priority
end

function skill_tabqte_delegate_moveup(sender, event)
    local priority = skill_tabqte_getpriority()
    if #priority > 0 then
        for i=1,#priority do
            if priority[i] == m_skill_tabqte_selectskill then
                if i > 1 then
                    priority[i] = priority[i - 1]
                    priority[i - 1] = m_skill_tabqte_selectskill
                end
                break
            end
        end
        skill_tabqte_sendpriority(priority)
    end
end

function skill_tabqte_delegate_movedown(sender, event)
    local priority = skill_tabqte_getpriority()
    if #priority > 0 then
        for i=1,#priority do
            if priority[i] == m_skill_tabqte_selectskill then
                if i < #priority then
                    priority[i] = priority[i + 1]
                    priority[i + 1] = m_skill_tabqte_selectskill
                end
                break
            end
        end
        skill_tabqte_sendpriority(priority)
    end
end
