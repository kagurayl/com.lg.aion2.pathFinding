
local questtracetype = 
{
    main = 1,
    quest = 2,
}

local m_questtrace_inst = { questname = "sidebar/inst_questname", queststep = "sidebar/inst_queststep" }
local m_questtrace_type = questtracetype.main
local m_questtrace_blinkquest = {}
local m_questtrace_stepspace = 10

function questtrace_open()
    m_uisidebar_main:setwidgetvisible("tab_quest", true)
end

function questtrace_close()
    m_uisidebar_main:setwidgetvisible("tab_quest", false)
end

function questtrace_onopen()
    local list_quest = m_uisidebar_main:getwidget("tab_quest/list_quest")
    list_quest:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_quest:setclickdelegate(questtrace_delegate_quest)
    list_quest:setasyncdelegate(questtrace_delegate_setlist)

    m_uisidebar_main:setwidgetdelegate("tab_quest/button_typemain", questtrace_delegate_typemain)
    m_uisidebar_main:setwidgetdelegate("tab_quest/button_typequest", questtrace_delegate_typequest)
    m_uisidebar_main.text_stepcalc = m_uisidebar_main:getwidget("tab_quest/text_stepcalc")
    m_uisidebar_main.list_quest = list_quest
end

local function questtrace_addquest(list_quest, quest)
    local line = list_quest:add(m_questtrace_inst.questname, list_quest:getcount(), quest)
    line.steptext = nil
    line.isstepline = false

    local xmlcontent = playerquest_loadxml(quest.questid)
    local text, step = csvxml_getsummary(xmlcontent, "quest_summary")
    if step ~= nil then
        local viewstep = math.min(quest.step, #step)
        local steptext = questdesc_convertstep(quest, viewstep, step[viewstep], questdesctype.all)
        if steptext ~= nil then
            line = list_quest:add(m_questtrace_inst.queststep, list_quest:getcount(), quest)
            line.steptext = steptext
            line.isstepline = true
            m_uisidebar_main.text_stepcalc:setrichtextex(steptext, bit.bor(richtextflag.removeunstable, richtextflag.removecolor))
            local renderwidth, renderheight = m_uisidebar_main.text_stepcalc:getrendersize()
            line:setsize(renderheight + m_questtrace_stepspace * 2)
        end
    end
end

function questtrace_updateui()
    local button_typemain = m_uisidebar_main:getwidget("tab_quest/button_typemain")
    button_typemain:setenable(m_questtrace_type ~= questtracetype.main)

    local button_typequest = m_uisidebar_main:getwidget("tab_quest/button_typequest")
    button_typequest:setenable(m_questtrace_type ~= questtracetype.quest)

    local list_quest = m_uisidebar_main.list_quest
    list_quest:savestate()
    list_quest:clear()

    local questarray = {}
    for i=1,#playerattr_quest do
        local quest = playerattr_quest[i]
        if quest.trace > 0 then
            if m_questtrace_type == questtracetype.main then
                if quest.config_quest.type == questtype.main then
                    if playerquest_prequestcomplete(quest.config_quest) and playerquest_premissioncomplete(quest.config_quest) then
                        questarray[#questarray + 1] = quest
                    end
                end
            elseif m_questtrace_type == questtracetype.quest then
                if quest.config_quest.type ~= questtype.main then
                    questarray[#questarray + 1] = quest
                end
            end
        end
    end
    table.sort(questarray, function(a, b) return (a.config_quest.id < b.config_quest.id) end)
    for i=1,#questarray do
        local quest = questarray[i]
        questtrace_addquest(list_quest, quest)
    end

    list_quest:restorestate()
    list_quest:updatecontentsize()
end

function questtrace_updateblink()
    local blinkremove = 0
    local list_quest = m_uisidebar_main.list_quest
    for i=1,list_quest:getcount() do
        local line = list_quest:getlinefromindex(i)
        local data = line:getdata()
        local blinktimestart = m_questtrace_blinkquest[data.questid]
        if blinktimestart ~= nil then
            local blinktime = (time_game - blinktimestart) * 1.5
            local opacity = math.fmod(blinktime, 1.0)
            if opacity > 0.5 then
                opacity = 1.0 - opacity
            end
            opacity = opacity + 0.5
            if blinktime > 5 then
                opacity = 1.0
                blinkremove = data.questid
            end
            if line:getasyncvisible() then
                if line.isstepline then
                    local text_step = line:getwidget("text_step")
                    text_step:setopacity(opacity)
                else
                    local image_icon = line:getwidget("image_icon")
                    local text_name = line:getwidget("text_name")
                    image_icon:setopacity(opacity)
                    text_name:setopacity(opacity)
                end
            end
        end
    end
    if blinkremove ~= 0 then
        m_questtrace_blinkquest[blinkremove] = nil
        if table.valcount(m_questtrace_blinkquest) == 0 then
            event_deregister(eventtype.update, questtrace_updateblink)
        end
    end
end

function questtrace_activequestid(questid)
    local quest = playerquest_getquest(questid)
	if quest == nil then
        return
    end
    if quest.config_quest.type == questtype.main then
        m_questtrace_type = questtracetype.main
    else
        m_questtrace_type = questtracetype.quest
    end
    questtrace_updateui()
    local list_quest = m_uisidebar_main.list_quest
    for i=1,list_quest:getcount() do
        local line = list_quest:getlinefromindex(i)
        local data = line:getdata()
        if data.questid == quest.questid then
            line:scrolltoview()
            m_questtrace_blinkquest[questid] = time_game
            event_register(eventtype.update, questtrace_updateblink, m_uisidebar_main)
            break
        end
    end
end

function questtrace_delegate_typemain()
    m_questtrace_type = questtracetype.main
    questtrace_updateui()
end

function questtrace_delegate_typequest()
    m_questtrace_type = questtracetype.quest
    questtrace_updateui()
end

function questtrace_delegate_quest(line, event, quest)
    quest_main_showquest(quest.questid, true)
end

function questtrace_delegate_setlist(sender, line, quest)
    if line.isstepline then
        local image_event = line:getwidget("image_event")
        local w,h = image_event:getsize()
        image_event:setsize(w, line:getsize())

        local text_step = line:getwidget("text_step")
        text_step:setopacity(1.0)
        text_step:setrichtextex(line.steptext, bit.bor(richtextflag.removeunstable, richtextflag.removecolor))
        text_step:setsize(w, line:getsize() - m_questtrace_stepspace * 2)
    else
        local image_icon = line:getwidget("image_icon")
        image_icon:setopacity(1.0)

        local text_name = line:getwidget("text_name")
        text_name:setopacity(1.0)
        text_name:settext(quest.config_quest.name)
        if quest.config_quest.type == questtype.main then
            text_name:sethexcolor(Color_QuestMission)
            if quest.config_step ~= nil and quest.step > #quest.config_step then
                image_icon:setsprite(csvlabelimage.quest_mainquestcomplete.image)
            else
                image_icon:setsprite(csvlabelimage.quest_mainquesting.image)
            end
        else
            text_name:sethexcolor(Color_QuestCommon)
            if quest.config_step ~= nil and quest.step > #quest.config_step then
                image_icon:setsprite(csvlabelimage.quest_stdquestcomplete.image)
            else
                image_icon:setsprite(csvlabelimage.quest_stdquesting.image)
            end
        end
    end
end
