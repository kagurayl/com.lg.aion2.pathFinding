
local m_uinpc_dialog_main_inst =
{
    text = "npc/inst_text",
    large = "npc/inst_buttonlarge",
    option = "npc/inst_buttonoption",
}

m_uinpc_dialogmain = uipanel_createhandle("npc/dialog_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)
local m_uinpc_dialog_textspace = 100

function dialog_main_onopen()
    m_uinpc_dialogmain:setwidgetdelegate("image_bg/button_close", dialog_main_delegate_close)
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    list_content:init(uilistflag.vertical)
    list_content:setclickdelegate(dialog_main_delegate_listselect)
    event_register(eventtype.update, dialog_main_update, m_uinpc_dialogmain)
end

function dialog_main_update()
    if m_uinpc_dialogmain.npc_actorid ~= 0 and not cgmask_playing() then
        local actor = actormanager_getfromactorid(m_uinpc_dialogmain.npc_actorid)
        local closedialog = true
        if actor ~= nil then
            local pt = actor.transform
            local at = m_me.transform
            local dist = vector3_distance(pt.px, pt.py, pt.pz, at.px, at.py, at.pz)
            local talkdist = actor:gettalkdist(5.0)
            if dist < talkdist then
                closedialog = false
            end
        end
        if closedialog then
            npc_closedialog()
        end
    end
end

function dialog_main_openui(npcactorid, config_npc, ackname)
    m_uinpc_dialogmain:open()
    m_uinpc_dialogmain.npc_actorid = npcactorid
    m_uinpc_dialogmain.config_npc = config_npc
    local text_title = m_uinpc_dialogmain:getwidget("image_bg/text_title")
    if config_npc ~= nil then
        text_title:settext(config_npc.name)
    else
        text_title:settext("")
    end
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    list_content:clear()
    if m_uinpc_dialogmain.xmlcontent ~= nil and ackname ~= nil then
        local text = csvxml_gettext(m_uinpc_dialogmain.xmlcontent, ackname)
        if text ~= nil and string.len(text) > 0 then
            local line = list_content:add(m_uinpc_dialog_main_inst.text)
            local text_main = line:getwidget("text_main")
            text_main:setrichtext(text)
            text_main:setdelegate(dialog_main_delegate_maintext)
    
            local width, height = text_main:setheightfromrendersize()
            line:setsize(height)
            line:addspace(m_uinpc_dialog_textspace)
            list_content:updatecontentsize()
            return true
        end
    end
    return false
end

function dialog_main_loadxml(xmlfilename, questid)
    if m_uinpc_dialogmain.xmlfilename ~= xmlfilename then
        m_uinpc_dialogmain.xmlfilename = xmlfilename
        if questid ~= 0 then
            m_uinpc_dialogmain.xmlcontent = playerquest_loadxml(questid)
        else
            m_uinpc_dialogmain.xmlcontent = c_config_loadxml(xmlfilename)
        end
    end
end

function dialog_main_getdialogxml(config_npc)
    local lambda = csvnpc_getscript(config_npc, "dialog")
    if lambda ~= nil then
        return string.format("streamconfig/dialog/%s.html", lambda.variable[1].str)
    end
end

function dialog_main_settalkstart(npcactorid, config_npc)
    local htmlfile = dialog_main_getdialogxml(config_npc)
    if htmlfile == nil then
        return
    end
    dialog_main_loadxml(htmlfile, 0)
    local questlist = csvnpc_getnpcquestlist(config_npc, true)
    if #questlist > 0 then
        dialog_main_openui(npcactorid, config_npc, XML_SelectQuest)
        dialog_main_setdialogoption(0, XML_SelectQuest)
        for i=1, #questlist do
            local quest = questlist[i]
            if quest.config_quest.type ~= questtype.crafting then
                dialog_main_addquest(quest.config_quest, quest.icon.image)
            end
        end
    elseif m_uinpc_dialogmain.xmlcontent ~= nil then
        local selectname = nil
        local npcfuncs = csvxml_getnpcfuncs(m_uinpc_dialogmain.xmlcontent, XML_SelectQuest)
        local option = csvxml_getoption(m_uinpc_dialogmain.xmlcontent, XML_SelectQuest)
        if #npcfuncs > 0 or #option > 0 then
            selectname = XML_SelectQuest
        elseif csvxml_containnode(m_uinpc_dialogmain.xmlcontent, XML_Select1) then
            selectname = XML_Select1
        elseif csvxml_containnode(m_uinpc_dialogmain.xmlcontent, XML_SelectQuest) then
            selectname = XML_SelectQuest
        end
        if selectname ~= nil then
            dialog_main_openui(npcactorid, config_npc, selectname)
            dialog_main_setdialogoption(0, selectname)
        elseif csvxml_containnode(m_uinpc_dialogmain.xmlcontent, XML_BookPage1) then
            quest_doc_setxml(config_npc.name, m_uinpc_dialogmain.xmlcontent)
        end
    end
end

function dialog_main_settalkselect(npcactorid, config_npc, selectname)
    local htmlfile = dialog_main_getdialogxml(config_npc)
    if htmlfile == nil then
        return
    end
    dialog_main_loadxml(htmlfile, 0)
    if m_uinpc_dialogmain.xmlcontent == nil then
        npc_closedialog()
        return
    end
    if not csvxml_containnode(m_uinpc_dialogmain.xmlcontent, selectname) then
        npc_closedialog()
        dialog_scriptoption_execute(selectname, npcactorid)
        return
    end
    dialog_main_openui(npcactorid, config_npc, selectname)
    dialog_main_setdialogoption(0, selectname)
end

function dialog_main_setqueststart(npcactorid, config_npc, questid)
    dialog_main_loadxml(csvquest_getxml(questid), questid)
    if m_uinpc_dialogmain.xmlcontent == nil then
        npc_closedialog()
        return
    end
    local selectname = XML_SelectNone
    local text = csvxml_gettext(m_uinpc_dialogmain.xmlcontent, selectname)
    if text == nil or string.len(text) == 0 then
        selectname = XML_Select1
        text = csvxml_gettext(m_uinpc_dialogmain.xmlcontent, selectname)
    end
    if text == nil or string.len(text) == 0 then
        selectname = XML_AskQuestAccept
        text = csvxml_gettext(m_uinpc_dialogmain.xmlcontent, selectname)
    end
    if text == nil or string.len(text) == 0 then
        npc_closedialog()
        return
    end
    dialog_main_openui(npcactorid, config_npc, selectname)
    dialog_main_setdialogoption(questid, selectname)
end

function dialog_main_setquestselect(npcactorid, config_npc, questid, selectname)
    dialog_main_loadxml(csvquest_getxml(questid), questid)
    if m_uinpc_dialogmain.xmlcontent == nil then
        npc_closedialog()
        return
    end
    local reward = string.startwith(selectname, XML_SelectQuestReward)
    if not csvxml_containnode(m_uinpc_dialogmain.xmlcontent, selectname) then
        if reward then
            if playerreward_prepairsubmit(questid) then
                local msg = {messageid="CS_QuestSubmit"}
                msg.actorid = npcactorid
                msg.questid = questid
                msg.select = 0
                msg.selectex = 0
                c_send(msg)
            end
        end
        npc_closedialog()
        return
    end
    dialog_main_openui(npcactorid, config_npc, selectname)
    if reward then
        local quest = playerquest_getquest(questid)
        if quest ~= nil then
            dialog_main_setdialogsubmit(questid, quest.branch)
        end
    else
        dialog_main_setdialogoption(questid, selectname)
    end
end

function dialog_main_setdialog(type, npcactorid, config_npc, questid, ackname)
    if type == npctalktype.talkstart then
        if questid ~= 0 then
            local config_quest = csvquest_getfromid(questid)
            if config_quest ~= nil then
                if config_quest.type == questtype.crafting then
                    dialogtask_setdialog(npcactorid, config_npc, questid, ackname)
                else
                    dialog_main_setqueststart(npcactorid, config_npc, questid)
                end
            end
        elseif ackname ~= nil and string.len(ackname) > 0 then
            dialog_main_settalkselect(npcactorid, config_npc, ackname)
        else
            dialog_main_settalkstart(npcactorid, config_npc)
        end
    elseif type == npctalktype.talkselect or type == npctalktype.talkfinish then
        if questid ~= 0 then
            local config_quest = csvquest_getfromid(questid)
            if config_quest ~= nil then
                if config_quest.type == questtype.crafting then
                    dialogtask_setdialog(npcactorid, config_npc, questid, ackname)
                else
                    dialog_main_setquestselect(npcactorid, config_npc, questid, ackname)
                end
            else
                npc_closedialog()
            end
        else
            dialog_main_settalkselect(npcactorid, config_npc, ackname)
        end
    elseif type == npctalktype.talkmodule then
        dialog_scriptoption_openscriptdialog(npcactorid, config_npc)
    else
        npc_closedialog()
    end
end

function dialog_main_setdialogaccept(questid, shareactorid)
    local config_quest = csvquest_getfromid(questid)
    if config_quest == nil then
        return
    end
    dialog_main_loadxml(csvquest_getxml(questid), questid)
    dialog_main_openui(0, nil, "ask_quest_accept")
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    questdesc_addrewardview(list_content, config_quest)

    local button_ok1 = m_uinpc_dialogmain:getwidget("button_ok1")
    local button_ok2 = m_uinpc_dialogmain:getwidget("button_ok2")
    button_ok1:setvisible(true)
    button_ok1:setdelegate(dialog_main_delegate_accept)
    button_ok1:settext("NPC_QUEST_ACCEPT")
    button_ok1.questid = questid
    button_ok1.shareactorid = shareactorid

    button_ok2:setvisible(true)
    button_ok2:setdelegate(dialog_main_delegate_close)
    button_ok2:settext("NPC_QUEST_REFUSE")
end

function dialog_main_setdialogsubmit(questid, reward)
    local config_quest = csvquest_getfromid(questid)
    if config_quest == nil then
        return
    end
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    questdesc_addrewardsubmit(list_content, config_quest, reward)

    local button_ok1 = m_uinpc_dialogmain:getwidget("button_ok1")
    local button_ok2 = m_uinpc_dialogmain:getwidget("button_ok2")
    button_ok1:setvisible(true)
    button_ok1:setdelegate(dialog_main_delegate_submit)
    button_ok1:settext("UI_OK")
    button_ok1.questid = questid

    button_ok2:setvisible(true)
    button_ok2:setdelegate(dialog_main_delegate_close)
    button_ok2:settext("UI_CLOSE")
end

function dialog_main_setdialognasubmit(actorid, config_npc, questid, branch)
    local config_quest = csvquest_getfromid(questid)
    if config_quest == nil then
        return
    end
    dialog_main_loadxml(csvquest_getxml(questid), questid)
    dialog_main_openui(actorid, config_npc, XML_SelectQuestReward .. (branch + 1))
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    questdesc_addrewardsubmit(list_content, config_quest, branch)

    local button_ok1 = m_uinpc_dialogmain:getwidget("button_ok1")
    local button_ok2 = m_uinpc_dialogmain:getwidget("button_ok2")
    button_ok1:setvisible(true)
    button_ok1:setdelegate(dialog_main_delegate_nasubmit)
    button_ok1:settext("UI_OK")
    button_ok1.questid = questid
    button_ok1.branch = branch

    button_ok2:setvisible(true)
    button_ok2:setdelegate(dialog_main_delegate_close)
    button_ok2:settext("UI_CLOSE")
end

function dialog_main_setdialogoption(questid, name)
    local button_ok1 = m_uinpc_dialogmain:getwidget("button_ok1")
    local button_ok2 = m_uinpc_dialogmain:getwidget("button_ok2")
    button_ok1:setvisible(false)
    button_ok2:setvisible(true)
    button_ok2:setdelegate(dialog_main_delegate_close)
    button_ok2:settext("UI_CLOSE")
    if m_uinpc_dialogmain.xmlcontent == nil then
        return
    end
    local npcfuncs = csvxml_getnpcfuncs(m_uinpc_dialogmain.xmlcontent, name)
    for i=1,#npcfuncs do
        local type = npcfuncs[i].type
        local text = npcfuncs[i].text
        dialog_main_addbutton(text, type)
    end

    local option = csvxml_getoption(m_uinpc_dialogmain.xmlcontent, name)
    for i=1,#option do
        local type = option[i].type
        local text = option[i].text
        dialog_main_addoption(text, questid, name, type)
    end

    local cutsceneid = csvxml_getcutscene(m_uinpc_dialogmain.xmlcontent, name)
    if cutsceneid ~= 0 then
        local config_cutscene = c_config_getmetaid(configid.cutscene, cutsceneid)
        if config_cutscene ~= nil then
            cgmask_start(config_cutscene.name, config_cutscene.timestart, config_cutscene.timeend - config_cutscene.timestart, false)
        end
    end
end

function dialog_main_delegate_listselect(line, event, data)
    if line.config_item ~= nil then
        local image_bg = m_uinpc_dialogmain:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        tips_item(line.config_item.id, line.itemcount, x, -1, tipsflag.vleft, nil, m_uinpc_dialogmain)
    else
        tips_close()
    end
    questdesc_selectdata(line, event, data)
end

function dialog_main_addbutton(text, type)
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    local line = list_content:add(m_uinpc_dialog_main_inst.large)
    local button_large = line:getwidget("button_large")
    button_large.type = type
    button_large:setdelegate(dialog_main_delegate_button)

    local text_large = line:getwidget("button_large/text_large")
    text_large:settext(text)
end

function dialog_main_addoption(text, questid, select, type)
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    local line = list_content:add(m_uinpc_dialog_main_inst.option)
    local subtype = string.split(type, ";")
    if #subtype > 1 then
        type = subtype[#subtype]
    end
    local button_option = line:getwidget("button_option")
    button_option.questid = questid
    button_option.select = select
    button_option.type = type
    button_option:setdelegate(dialog_main_delegate_option)

    local image_icon = line:getwidget("button_option/image_icon")
    if type == XML_HActionFinishDialog then
        image_icon:setspritesize("sp1/dialogicon_close", 2.0)
    else
        image_icon:setspritesize("sp1/dialogicon_quest", 2.0)
    end

    local text_option = line:getwidget("button_option/text_option")
    text_option:setrichtext(text)
end

function dialog_main_addquest(config_quest, icon)
    local list_content = m_uinpc_dialogmain:getwidget("list_content")
    local line = list_content:add(m_uinpc_dialog_main_inst.option)
    local button_option = line:getwidget("button_option")
    button_option:setdelegate(dialog_main_delegate_quest)
    button_option.config_quest = config_quest

    local image_icon = line:getwidget("button_option/image_icon")
    image_icon:setspritesize(icon, 3.0)

    local text_option = line:getwidget("button_option/text_option")
    local name = config_quest.name
    if config_quest.accept ~= "0" then
        if config_quest.repeatcount == 0 then
            name = c_textformat("NPC_QUEST_REPEATNOLIMIT", name)
        elseif config_quest.repeatcount > 1 then
            local completecount = 1
            local questcomplete = playerattr_questcomplete[config_quest.id]
            if questcomplete ~= nil then
                completecount = questcomplete.count + 1
            end
            name = c_textformat("NPC_QUEST_REPEAT", name, completecount, config_quest.repeatcount)
        end
    end
    text_option:settext(name)
end

function dialog_main_delegate_button(sender)
    if not dialog_scriptoption_execute(sender.type, m_uinpc_dialogmain.npc_actorid) then
        debugerror("failed script:" .. sender.type)
    end
end

function dialog_main_delegate_option(sender)
    if sender.type == XML_HActionFinishDialog then
        local quest = playerquest_getquest(sender.questid)
        if quest ~= nil and quest.config_step ~= nil then
            local steplambda = quest.config_step[quest.step]
            for lambdaindex=1,#steplambda do
                if steplambda[lambdaindex].action == QuestStep_TalkFinish then
                    if steplambda[lambdaindex].variable[1].integer == m_uinpc_dialogmain.config_npc.id then
                        npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkclose, sender.questid, nil)
                        break
                    end
                end
            end
        elseif sender.select == XML_AskQuestAccept then
            local msg = {}
            msg.messageid = "CS_QuestAccept"
            msg.actorid = m_uinpc_dialogmain.npc_actorid
            msg.questid = sender.questid
            c_send(msg)
        end
        npc_closedialog()
        return
    end

    if string.startwith(sender.type, XML_HSetPro) or string.startwith(sender.type, XML_HSetSuccess) then
        local selectname = string.sub(sender.type, string.len(XML_HAction) + 1)
        npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkfinish, sender.questid, selectname)
        return
    end
    if sender.type == XML_HActionQuestAccept then
        if playerquest_prepair(sender.questid) then
            local msg = {}
            msg.messageid = "CS_QuestAccept"
            msg.actorid = m_uinpc_dialogmain.npc_actorid
            msg.questid = sender.questid
            c_send(msg)
        end
        return
    end
    if sender.type == XML_HActionSelectQuestRewrad then
        local quest = playerquest_getquest(sender.questid)
        if quest ~= nil then
            npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkfinish, sender.questid, XML_SelectQuestReward .. (quest.branch + 1))
        end
        return
    end
    if sender.type == XML_HActionCheckUserHasQuestItem then
        local quest = playerquest_getquest(sender.questid)
        if quest ~= nil and quest.config_step ~= nil then
            local checkedtalkscript = nil
            local steplambda = quest.config_step[quest.step]
            if steplambda ~= nil then
                for lambdaindex=1,#steplambda do
                    if csvqueststep_istalklambda(steplambda[lambdaindex].action) then
                        if #steplambda[lambdaindex].variable >= 3 then
                            checkedtalkscript = steplambda[lambdaindex].variable[3].str
                            break
                        end
                    end
                end
            end
            if checkedtalkscript == nil then
                return
            end
            if playerquest_itemchecked(quest) then
                if string.startwith(checkedtalkscript, XML_SelectQuestReward) then
                    npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkfinish, sender.questid, XML_SelectQuestReward .. (quest.branch + 1))
                else
                    npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkselect, sender.questid, checkedtalkscript)
                end
                return
            end
            local msg = {}
            msg.messageid = "CS_QuestCheckItem"
            msg.actorid = m_uinpc_dialogmain.npc_actorid
            msg.questid = sender.questid
            msg.talknpc = 0
            if string.startwith(checkedtalkscript, XML_SelectQuestReward) then
                msg.talknpc = 1
            end
            c_send(msg)
            return
        end
    end

    if string.startwith(sender.type, XML_HAction) then
        local talkname = string.sub(sender.type, string.len(XML_HAction) + 1)
        if dialog_scriptoption_execute(talkname, m_uinpc_dialogmain.npc_actorid) then
            npc_closedialog()
        else
            npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.talkselect, sender.questid, talkname)
        end
        return
    end
    npc_closedialog()
end

function dialog_main_delegate_quest(sender)
    local config_npc = m_uinpc_dialogmain.config_npc
    local config_quest = sender.config_quest
    local questlist = csvnpc_getnpcquestlist(config_npc, true)
    local state = queststate.none
    if questlist ~= nil then
        for i=1, #questlist do
            if questlist[i].config_quest.id == config_quest.id then
                state = questlist[i].state
                break
            end
        end
    end
    local talktype = npctalktype.talkselect
    local talkname = nil
    if state == queststate.acceptable then
        talktype = npctalktype.talkstart
        talkname = XML_Select1
    elseif state == queststate.talkable then
        local quest = playerquest_getquest(config_quest.id)
        if quest ~= nil and quest.config_step ~= nil and quest.step <= #quest.config_step then
            local steplambdaarray = quest.config_step[quest.step]
            for i=1,#steplambdaarray do
                local lambda = steplambdaarray[i]
                if csvqueststep_istalklambda(lambda.action) and lambda.variable[1].integer == config_npc.id then
                    if #lambda.variable >= 3 and playerquest_itemchecked(quest) then
                        talkname = lambda.variable[3].str
                        break
                    end
                    if #lambda.variable >= 2 then
                        talkname = lambda.variable[2].str
                        break
                    end
                end
            end
            if talkname == nil then
                local additivelambdaarray = quest.config_additive[quest.step]
                if additivelambdaarray ~= nil then
                    for lambdaindex=1,#additivelambdaarray do
                        local additivelambda = additivelambdaarray[lambdaindex]
                        if additivelambda.action == QuestAddititve_Talk then
                            if additivelambda.variable[1].integer == config_npc.id and #additivelambda.variable >= 2 then
                                talkname = additivelambda.variable[2].str
                                break
                            end
                        end
                    end
                end
            end
        end
    elseif state == queststate.finish then
        local quest = playerquest_getquest(config_quest.id)
        if quest ~= nil then
            talkname = XML_SelectQuestReward .. (quest.branch + 1)
            talktype = npctalktype.talkfinish
        end
    end
    if talkname ~= nil then
        npc_sendtalk(m_uinpc_dialogmain.npc_actorid, talktype, config_quest.id, talkname)
    else
        npc_sendtalk(m_uinpc_dialogmain.npc_actorid, npctalktype.interacttalk, config_quest.id, nil)
    end
end

function dialog_main_delegate_maintext(sender, event)
    if event.name == "click" and event.linkid ~= nil then
        local image_bg = m_uinpc_dialogmain:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        richtext_onclick(event, sender.tagarray, x, tipsflag.vleft)
    end
end

function dialog_main_delegate_accept(sender)
    if playerquest_prepair(sender.questid) then
        if sender.shareactorid ~= 0 then
            local msg = {}
            msg.messageid = "CS_QuestShareAccept"
            msg.actorid = sender.shareactorid
            msg.questid = sender.questid
            c_send(msg)
        else
            local msg = {}
            msg.messageid = "CS_QuestAccept"
            msg.actorid = 0
            msg.questid = sender.questid
            c_send(msg)
        end
    end
end

function dialog_main_delegate_submit(sender)
    if playerreward_prepairsubmit(sender.questid) then
        local select, selectex = questdesc_getrewardselect()
        if select == nil then
            chat_addsystemalert("QUEST_SUBMIT_SELECTREWARD")
            return
        end
        local msg = {messageid="CS_QuestSubmit"}
        msg.actorid = m_uinpc_dialogmain.npc_actorid
        msg.questid = sender.questid
        msg.select = select - 1
        msg.selectex = selectex - 1
        c_send(msg)
    end
end

function dialog_main_delegate_nasubmit(sender)
    local config_quest = csvquest_getfromid(sender.questid)
    if config_quest ~= nil and playerreward_prepairsubmitconfig(config_quest, sender.branch) then
        local select, selectex = questdesc_getrewardselect()
        if select == nil then
            chat_addsystemalert("QUEST_SUBMIT_SELECTREWARD")
            return
        end
        local msg = {messageid="CS_QuestNASubmit"}
        msg.actorid = m_uinpc_dialogmain.npc_actorid
        msg.questid = sender.questid
        msg.select = select - 1
        msg.selectex = selectex - 1
        c_send(msg)
    end
end

function dialog_main_delegate_close()
    npc_closedialog()
end
