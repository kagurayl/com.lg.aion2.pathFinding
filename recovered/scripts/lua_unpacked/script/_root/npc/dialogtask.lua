
local m_uinpc_dialog_task_inst =
{
    text = "npc/inst_text",
    rewardtitle = "npc/inst_rewardtitle",
    rewarditem = "npc/inst_rewarditem",
}
local m_uinpc_dialog_taskspace = 100

local function dialogtask_addrewardtitle(list_content, text)
    local line = list_content:add(m_uinpc_dialog_task_inst.rewardtitle)
    local text_reward = line:getwidget("text_reward")
    text_reward:settext(text)
end

local function dialogtask_addrewarditem(list_content, item)
    local subitem = string.splitnumber(item, "x")
    local config_item = csvitem_getfromid(subitem[1])
    if config_item ~= nil then
        local line = list_content:add(m_uinpc_dialog_task_inst.rewarditem)
        local image_item = line:getwidget("image_item")
        image_item:seticon(config_item.icon)

        local text_count = line:getwidget("text_count")
        text_count:settext(subitem[2])

        local colorname = csvitem_getcolorname(config_item)
        local name = string.format("%s (%d)", colorname, subitem[2])
        local text_name = line:getwidget("text_name")
        text_name:settext(name)
    end
end

function dialogtask_settaskmain(npcactorid, config_npc)
    local htmlfile = dialog_main_getdialogxml(config_npc)
    dialog_main_loadxml(htmlfile, 0)
    local skillid = crafting_getnpccraftingskill(config_npc)
    local craftingskill = playerskill_getcraftingskill(skillid)
    if craftingskill == nil then
        if csvxml_containnode(m_uinpc_dialogmain.xmlcontent, "no_right") then
            dialog_main_openui(npcactorid, config_npc, "no_right")
            dialog_main_setdialogoption(0, "no_right")
        end
        return
    end
    local questlist = csvnpc_getnpcquestlist(config_npc, false)
    for i=#questlist,1,-1 do
        local quest = questlist[i]
        if quest.config_quest.type ~= questtype.crafting then
            table.remove(questlist, i)
        else
            if quest.state ~= queststate.finish then
                local config_task = csvcraftingtask_getfromid(quest.config_quest.id)
                if config_task == nil then
                    table.remove(questlist, i)
                else
                    local lambdapre = quest.config_quest.prerequisite
                    if lambdapre ~= nil then
                        local remove = true
                        local actioncount = lambdapre.actioncount
                        for lambdaindex=1,actioncount do
                            local sublambda = lambdapre[lambdaindex]
                            if c_isaction(sublambda, QuestAccept_preskill) then
                                if skillid == sublambda.variable[1].integer
                                and craftingskill.level >= sublambda.variable[1].count
                                and craftingskill.level <= sublambda.variable[1].count + 20 then
                                    remove = false
                                end
                            end
                        end
                        if remove then
                            table.remove(questlist, i)
                        end
                    end
                end
            end
        end
    end
    if csvxml_containnode(m_uinpc_dialogmain.xmlcontent, "select_task") then
        dialog_main_openui(npcactorid, config_npc, "select_task")
        dialog_main_setdialogoption(0, "select_task")
    end
    for i=1, #questlist do
        local quest = questlist[i]
        dialog_main_addquest(quest.config_quest, quest.icon.image)
    end
end

function dialogtask_setdialog(npcactorid, config_npc, questid, ackname)
    local config_task = csvcraftingtask_getfromid(questid)
    if config_task == nil then
        return
    end
    local config_recipe = csvcraftingrecipe_getfromid(config_task.recipeid)
    if config_recipe == nil then
        return
    end

    dialog_main_openui(npcactorid, config_npc, nil)
    local list_content = m_uinpc_dialogmain:getwidget("list_content")

    dialogtask_addrewardtitle(list_content, "QUEST_TASK_RECIPE")
    list_content:addspace(m_uinpc_dialog_taskspace / 2)

    local line = list_content:add(m_uinpc_dialog_task_inst.text)
    local text_main = line:getwidget("text_main")
    text_main:settext(config_recipe.name)
    list_content:addspace(m_uinpc_dialog_taskspace)

    dialogtask_addrewardtitle(list_content, "QUEST_TASK_COMPONENT")
    dialogtask_addrewarditem(list_content, config_task.component1)
    if config_task.component2 ~= "0" then
        dialogtask_addrewarditem(list_content, config_task.component2)
    end
    list_content:addspace(m_uinpc_dialog_taskspace)

    dialogtask_addrewardtitle(list_content, "QUEST_TASK_PRODUCT")
    dialogtask_addrewarditem(list_content, config_task.product)
    list_content:addspace(m_uinpc_dialog_taskspace)

    dialogtask_addrewardtitle(list_content, "QUEST_TASK_REWARD")
    line = list_content:add(m_uinpc_dialog_task_inst.rewarditem)
    local image_item = line:getwidget("image_item")
    image_item:seticon("items/icon_quest_undefineable01")

    local text_count = line:getwidget("text_count")
    text_count:setvisible(false)

    local text_name = line:getwidget("text_name")
    text_name:settext("QUEST_DESC_UNKNOW")

    local button_ok1 = m_uinpc_dialogmain:getwidget("button_ok1")
    local button_ok2 = m_uinpc_dialogmain:getwidget("button_ok2")
    button_ok1:setvisible(true)
    button_ok2:setvisible(true)
    if string.len(ackname) == 0 or ackname == XML_Select1 then
        button_ok1:setdelegate(dialogtask_delegate_accept)
        button_ok1:settext("NPC_QUEST_ACCEPT")
        button_ok1.questid = questid

        button_ok2:setdelegate(dialogtask_delegate_refuse)
        button_ok2:settext("NPC_QUEST_REFUSE")
        button_ok2.npcactorid = npcactorid
    elseif string.startwith(ackname, XML_SelectQuestReward) then
        button_ok1:setdelegate(dialog_main_delegate_submit)
        button_ok1:settext("UI_OK")
        button_ok1.questid = questid
    
        button_ok2:setdelegate(dialog_main_delegate_close)
        button_ok2:settext("UI_CLOSE")
    else
        npc_closedialog()
    end
end

function dialogtask_delegate_accept(sender)
    if playerquest_prepair(sender.questid) then
        local msg = {}
        msg.messageid = "CS_QuestAccept"
        msg.actorid = m_uinpc_dialogmain.npc_actorid
        msg.questid = sender.questid
        c_send(msg)
    end
end

function dialogtask_delegate_refuse(sender)
    npc_startscript(sender.npcactorid)
end
