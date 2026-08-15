
local m_quest_main_inst =
{
    category = "quest/inst_category",
    name = "quest/inst_name",
}

m_uiquest_questmain = uipanel_createhandle("quest/quest_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenParchment, AudioCloseParchment)

local function quest_main_addcategory(list_quest, category)
    local line = list_quest:add(m_quest_main_inst.category)
    local text_name = line:getwidget("text_name")
    text_name:settext(category)
end

local function quest_main_setquestcolor(config_quest, text_level, text_name)
    local leveldiff = config_quest.colorlevel - playerattr_info.level
    local color = Color_QuestEasy
    if leveldiff >= 5 then
        color = Color_QuestVeryHard
    elseif leveldiff >= 3 then
        color = Color_QuestHard
    elseif leveldiff >= 1 then
        color = Color_QuestNormal
    end
    text_level:sethexcolor(color)
    text_name:sethexcolor(color)
end

local function quest_main_getname(config_quest, name)
    return c_textformat("QUEST_TYPE_" .. config_quest.type) .. name
end

local function quest_main_addquest(list_quest, quest)
    local line = list_quest:add(m_quest_main_inst.name, quest.config_quest.id, quest.config_quest)
    line.config_quest = quest.config_quest
    local text_level = line:getwidget("text_level")
    text_level:settext("QUEST_MAIN_LEVEL", quest.config_quest.level)

    local text_name = line:getwidget("text_name")
    text_name:settextscale(quest_main_getname(quest.config_quest, c_textformat(quest.config_quest.name)))

    local checkbox_trace = line:getwidget("checkbox_trace")
    checkbox_trace:setvisible(true)
    checkbox_trace:setcheck(quest.trace > 0)
    checkbox_trace:setdelegate(quest_main_delegate_trace)
    checkbox_trace.questid = quest.questid

    quest_main_setquestcolor(quest.config_quest, text_level, text_name)
end

local function quest_main_addprequest(list_quest, quest)
    local csvprequestgroup = csvquest_getprequestgroup(quest.config_quest.id)
    if csvprequestgroup == nil then
        return
    end

    local config_prequest = nil
    for prequestgroupindex=1,#csvprequestgroup do
        local prequestgroup = csvprequestgroup[prequestgroupindex]
        for i=1,#prequestgroup.prequest do
            local prequestinfo = playerattr_questcomplete[prequestgroup.prequest[i]]
            if prequestinfo == nil then
                config_prequest = prequestgroup.config_prequest[i]
                break
            end
        end
        if config_prequest ~= nil then
            break
        end
    end
    if config_prequest == nil then
        return
    end
    local line = list_quest:add(m_quest_main_inst.name, quest.config_quest.id, quest.config_quest)
    line.config_quest = quest.config_quest
    local text_level = line:getwidget("text_level")
    text_level:settext("QUEST_MAIN_LEVEL", "?")

    local text_name = line:getwidget("text_name")
    text_name:settext(quest_main_getname(quest.config_quest, "??????????"))

    local checkbox_trace = line:getwidget("checkbox_trace")
    checkbox_trace:setvisible(false)

    quest_main_setquestcolor(quest.config_quest, text_level, text_name)
    if m_uiquest_questmain.selectquestid == quest.questid then
        questdesc_addprequest(list_quest, c_textformat("QUEST_MISSION_PREQUEST", config_prequest.name))
    end
end

local function quest_main_addpremission(list_quest, quest)
    local line = list_quest:add(m_quest_main_inst.name, quest.config_quest.id, quest.config_quest)
    line.config_quest = quest.config_quest
    local text_level = line:getwidget("text_level")
    text_level:settext("QUEST_MAIN_LEVEL", "?")

    local text_name = line:getwidget("text_name")
    text_name:settext(quest_main_getname(quest.config_quest, "??????????"))

    local checkbox_trace = line:getwidget("checkbox_trace")
    checkbox_trace:setvisible(false)

    quest_main_setquestcolor(quest.config_quest, text_level, text_name)
    if m_uiquest_questmain.selectquestid == quest.questid then
        questdesc_addprequest(list_quest, c_textformat("QUEST_MISSION_PREALL", quest.config_quest.category))
    end
end

function quest_main_onopen()
    m_uiquest_questmain:setwidgetdelegate("button_close", quest_main_delegate_close)
    local list_quest = m_uiquest_questmain:getwidget("list_quest")
    list_quest:init(uilistflag.vertical)
    list_quest:setclickdelegate(quest_main_delegate_quest)
end

function quest_main_showquest(questid, openui)
    m_uiquest_questmain.selectquestid = questid
    m_uiquest_questmain.descquestid = nil
    if openui then
        m_uiquest_questmain:open()
    end
    if m_uiquest_questmain:alive() then
        quest_main_updateui()
        if questid ~= 0 then
            quest_main_scrolltoselect()
        end
    end
end

function quest_main_scrolltoselect()
    if m_uiquest_questmain:null() then
        return
	end
    local list_quest = m_uiquest_questmain:getwidget("list_quest")
    local line = list_quest:getlinefromname(m_uiquest_questmain.selectquestid)
    if line ~= nil then
        line:scrolltoview()
    end
end

function quest_main_updateui()
    if m_uiquest_questmain:null() then
        return
	end
	local list_quest = m_uiquest_questmain:getwidget("list_quest")
    list_quest:savestate()
    list_quest:clear()
    local questarray = {}
    local categoryarray = {}
    for i=1,#playerattr_quest do
        local quest = playerattr_quest[i]
        if quest.config_quest.type ~= questtype.crafting then
            if quest.config_quest.category ~= "0" and not table.containvalue(categoryarray, quest.config_quest.category) then
                categoryarray[#categoryarray + 1] = quest.config_quest.category
            end
            questarray[#questarray + 1] = quest
        end
    end
    table.sort(questarray, function(a, b) return (a.config_quest.id < b.config_quest.id) end)
    for i=1,#categoryarray do
        local category = categoryarray[i]
        quest_main_addcategory(list_quest, category)
        for j=1,#questarray do
            local quest = questarray[j]
            if quest.config_quest.category == category and quest.config_quest.type == questtype.main then
                if not playerquest_prequestcomplete(quest.config_quest) then
                    quest_main_addprequest(list_quest, quest)
                elseif not playerquest_premissioncomplete(quest.config_quest) then
                    quest_main_addpremission(list_quest, quest)
                else
                    quest_main_addquest(list_quest, quest)
                    if m_uiquest_questmain.selectquestid == quest.questid then
                        if m_uiquest_questmain.descquestid == quest.questid then
                            questdesc_add(list_quest, quest, true)
                            questdesc_addrewardview(list_quest, quest.config_quest)
                        else
                            questdesc_add(list_quest, quest, false)
                        end
                        questdesc_addbutton(list_quest, quest)
                    end
                end
            end
        end
        for j=1,#questarray do
            local quest = questarray[j]
            if quest.config_quest.category == category and quest.config_quest.type ~= questtype.main then
                quest_main_addquest(list_quest, quest)
                if m_uiquest_questmain.selectquestid == quest.questid then
                    if m_uiquest_questmain.descquestid == quest.questid then
                        questdesc_add(list_quest, quest, true)
                        questdesc_addrewardview(list_quest, quest.config_quest)
                    else
                        questdesc_add(list_quest, quest, false)
                    end
                    questdesc_addbutton(list_quest, quest)
                end
            end
        end
    end

    questarray = {}
    categoryarray = {}
    for i=1,#playerattr_quest do
        local quest = playerattr_quest[i]
        if quest.config_quest.type == questtype.crafting then
            local config_task = csvcraftingtask_getfromid(quest.config_quest.id)
            if config_task ~= nil then
                local config_skill = csvcraftingtask_getskill(config_task)
                if config_skill ~= nil and not table.containvalue(categoryarray, config_skill.name) then
                    categoryarray[#categoryarray + 1] = config_skill.name
                end
                questarray[#questarray + 1] = quest
            end
        end
    end
    table.sort(questarray, function(a, b) return (a.config_quest.id < b.config_quest.id) end)
    for i=1,#categoryarray do
        local category = categoryarray[i]
        quest_main_addcategory(list_quest, category)
        for j=1,#questarray do
            local quest = questarray[j]
            local config_task = csvcraftingtask_getfromid(quest.config_quest.id)
            if config_task ~= nil then
                local config_skill = csvcraftingtask_getskill(config_task)
                if config_skill ~= nil and config_skill.name == category then
                    quest_main_addquest(list_quest, quest)
                    if m_uiquest_questmain.selectquestid == quest.questid then
                        questdesc_settask(list_quest, quest)
                    end
                end
            end
        end
    end
    list_quest:updatecontentsize()
    list_quest:restorestate()
end

function quest_main_delegate_quest(line, event, data)
    if line.config_quest ~= nil then
        if m_uiquest_questmain.selectquestid == line.config_quest.id then
            m_uiquest_questmain.selectquestid = nil
            quest_main_updateui()
        else
            m_uiquest_questmain.selectquestid = line.config_quest.id
            m_uiquest_questmain.descquestid = nil
            quest_main_updateui()
            quest_main_scrolltoselect()
        end
    elseif line.config_item ~= nil then
        local image_bg = m_uiquest_questmain:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        tips_item(line.config_item.id, line.itemcount, x, -1, tipsflag.vleft, nil, m_uiquest_questmain)
    else
        tips_close()
    end
end

function quest_main_delegate_trace(sender, event)
    local msg = {messageid="CS_QuestTrace"}
    msg.questid = sender.questid
    msg.trace = math.ternary(sender:getcheck(), 1, 0)
    c_send(msg)
	local quest = playerquest_getquest(sender.questid)
	if quest ~= nil then
        quest.trace = msg.trace
        if msg.trace > 0 then
            sidebar_activequest(quest.questid)
        else
            sidebar_updatequest()
        end
    end
end

function quest_main_delegate_close()
    m_uiquest_questmain:close()
end
