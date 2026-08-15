
local m_questreward_inst =
{
    text = "quest/inst_text",
    rewardtitle = "quest/inst_rewardtitle",
    rewarditem = "quest/inst_rewarditem",
    buttontask = "quest/inst_buttontask",
}

local rewardtype =
{
	normal = 1,
 	rewardex = 2,
}

local m_questreward_space = 100
local m_questreward_selectable = false
local m_questreward_selectableex = false
local m_questreward_selectindex = 0
local m_questreward_selectindexex = 0

local function questreward_resetrewardline(line)
    local image_item = line:getwidget("image_item")
    image_item:setcolor(1,1,1,1)

    local image_textbg = line:getwidget("image_textbg")
    image_textbg:setcolor(1,1,1,1)
end

local function questreward_addrewardline(list_content, icon, text)
    local line = list_content:add(m_questreward_inst.rewarditem)

    local image_item = line:getwidget("image_item")
    image_item:seticon(icon)

    local text_name = line:getwidget("text_name")
    text_name:settext(text)

    local text_count = line:getwidget("text_count")
    text_count:setvisible(false)

    questreward_resetrewardline(line)
    line:setselectable(false)
end

local function questreward_additemline(list_content, lambda, selectdata)
    for i=1,lambda.variablecount do
        local substr = string.split(lambda.variable[i].str, "x")
        local itemid = string.tointeger(substr[1])
        local config_item = csvitem_getfromid(itemid)
        if config_item ~= nil then
            local line = list_content:add(m_questreward_inst.rewarditem, list_content:getcount(), list_content:getcount())

            local image_item = line:getwidget("image_item")
            image_item:seticon(config_item.icon)

            local text_name = line:getwidget("text_name")
            local text_count = line:getwidget("text_count")
            local itemcount = 1
            if #substr > 1 then
                itemcount = string.tointeger(substr[2])
            end
            if itemcount > 1 then
                text_name:settext(csvitem_getcolorname(config_item) .. "x" .. itemcount)
                text_count:setvisible(true)
                text_count:settext(itemcount)
            else
                text_name:settext(csvitem_getcolorname(config_item))
                text_count:settext("")
            end

            local image_textbg = line:getwidget("image_textbg")
            local available, typetext = equip_getrequireskill(config_item)
            if available then
                image_item:setcolor(1,1,1,1)
                image_textbg:setcolor(1,1,1,1)
            else
                image_item:setcolor(1,0.7,0.7,1)
                image_textbg:setcolor(1,0.5,0.5,1)
            end
            line:setselectable(selectdata ~= nil and lambda.variablecount > 1)
            line.config_item = config_item
            line.itemcount = itemcount
            line.selectdata = selectdata
            line.selectindex = i
        end
    end
end

local function questreward_addtaskrewardtitle(list_content, text)
    local line = list_content:add(m_questreward_inst.rewardtitle)
    local text_reward = line:getwidget("text_reward")
    text_reward:settext(text)
end

local function questreward_addtaskrewarditem(list_content, item)
    local subitem = string.splitnumber(item, "x")
    local config_item = csvitem_getfromid(subitem[1])
    if config_item ~= nil then
        local line = list_content:add(m_questreward_inst.rewarditem)
        local image_item = line:getwidget("image_item")
        image_item:seticon(config_item.icon)

        local text_count = line:getwidget("text_count")
        text_count:setvisible(true)
        text_count:settext(subitem[2])

        local colorname = csvitem_getcolorname(config_item)
        local name = string.format("%s (%d)", colorname, subitem[2])
        local text_name = line:getwidget("text_name")
        text_name:settext(name)

        questreward_resetrewardline(line)
    end
end

local function questdesc_addrewardcareeravailable(action)
    local career = string.tointeger(string.sub(action, string.len("itemc") + 1))
    if playerattr_info.career == playercareer.warrior or playerattr_info.career == playercareer.fighter then
        return career == 0
    elseif playerattr_info.career == playercareer.knight then
        return career == 1
    elseif playerattr_info.career == playercareer.cleric or playerattr_info.career == playercareer.priest then
        return career == 2
    elseif playerattr_info.career == playercareer.chanter then
        return career == 3
    elseif playerattr_info.career == playercareer.scout or playerattr_info.career == playercareer.assassin then
        return career == 4
    elseif playerattr_info.career == playercareer.ranger then
        return career == 5
    elseif playerattr_info.career == playercareer.mage or playerattr_info.career == playercareer.wizard then
        return career == 6
    elseif playerattr_info.career == playercareer.elementallist then
        return career == 7
    end
    return false
end

local function questdesc_rewardtype(lambdareward)
    local item = false
    local select = false
    local actioncount = lambdareward.actioncount
    for i=1,actioncount do
        local sublambda = lambdareward[i]
        if c_isaction(sublambda, "exp")
        or c_isaction(sublambda, "gold")
        or c_isaction(sublambda, "abyss")
        or c_isaction(sublambda, "item")
        or c_isaction(sublambda, "title")
        or c_isaction(sublambda, "gift") then
            item = true
        elseif c_isaction(sublambda, "item2") then
            select = true
        elseif string.startwith(sublambda.action, "itemc") then
            if questdesc_addrewardcareeravailable(sublambda.action) then
                if sublambda.variablecount > 1 then
                    select = true
                else
                    item = true
                end
            end
        end
    end
    return item, select
end

local function questdesc_addrewardviewitem(list_content, config_quest, lambdareward)
    local actioncount = lambdareward.actioncount
    for i=1,actioncount do
        local sublambda = lambdareward[i]
        if c_isaction(sublambda, "exp") then
            local exp = sublambda.variable[1].integer
            if config_quest.level <= 50 then
                exp = math.tointegerfloor(exp * playerattr_info.questexp50 / 100)
            elseif config_quest.level <= 55 then
                exp = math.tointegerfloor(exp * playerattr_info.questexp55 / 100)
            end
            questreward_addrewardline(list_content, "items/icon_quest_exp01", c_textformat("QUEST_DESC_EXP", exp))
        elseif c_isaction(sublambda, "gold") then
            questreward_addrewardline(list_content, "items/icon_item_qina01", c_textformat("QUEST_DESC_COIN", sublambda.variable[1].integer))
        elseif c_isaction(sublambda, "abyss") then
            questreward_addrewardline(list_content, "items/icon_quest_ap01", c_textformat("QUEST_DESC_OBS", sublambda.variable[1].integer))
        elseif c_isaction(sublambda, "title") then
            local config_title = csvplayertitle_getfromid(sublambda.variable[1].integer)
            if config_title ~= nil then
                questreward_addrewardline(list_content, "items/icon_quest_title01", c_textformat("QUEST_DESC_TITLE", config_title.name))
            end
        elseif c_isaction(sublambda, "item") then
            questreward_additemline(list_content, sublambda, nil)
        elseif c_isaction(sublambda, "gift") then
            questreward_addrewardline(list_content, "items/icon_quest_undefineable01", c_textformat("QUEST_DESC_UNKNOW"))
        elseif string.startwith(sublambda.action, "itemc") then
            if sublambda.variablecount == 1 and questdesc_addrewardcareeravailable(sublambda.action) then
                questreward_additemline(list_content, sublambda, nil)
            end
        end
    end
end

local function questdesc_addrewardviewitemselect(list_content, lambdareward, selectdata)
    local actioncount = lambdareward.actioncount
    for i=1,actioncount do
        local sublambda = lambdareward[i]
        if c_isaction(sublambda, "item2") then
            questreward_additemline(list_content, sublambda, selectdata)
        elseif string.startwith(sublambda.action, "itemc") then
            if sublambda.variablecount > 1 and questdesc_addrewardcareeravailable(sublambda.action) then
                questreward_additemline(list_content, sublambda, selectdata)
            end
        end
    end
end

local function questdesc_addrewardviewunknow(list_content)
    local line = list_content:add(m_questreward_inst.rewarditem)
    local image_item = line:getwidget("image_item")
    image_item:seticon("items/icon_quest_undefineable01")

    local text_count = line:getwidget("text_count")
    text_count:setvisible(false)

    local text_name = line:getwidget("text_name")
    text_name:settext("QUEST_DESC_UNKNOW")

    questreward_resetrewardline(line)
end

function questdesc_addrewardview(list_content, config_quest)
    if config_quest.reward1 ~= nil then
        if config_quest.reward2 == nil then
            local item, select = questdesc_rewardtype(config_quest.reward1)
            if item then
                questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARD")
                questdesc_addrewardviewitem(list_content, config_quest, config_quest.reward1)
            end
            if select then
                questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDSELECT")
                questdesc_addrewardviewitemselect(list_content, config_quest.reward1, nil)
            end
        else
            questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARD")
            questdesc_addrewardviewunknow(list_content)
        end
    end
    if config_quest.rewardex ~= nil then
        local item, select = questdesc_rewardtype(config_quest.rewardex)
        if item then
            questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDEX")
            questdesc_addrewardviewitem(list_content, config_quest, config_quest.rewardex)
        end
        if select then
            questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDEXSELECT")
            questdesc_addrewardviewitemselect(list_content, config_quest.rewardex, nil)
        end
    end
end

function questdesc_addrewardsubmit(list_content, config_quest, rewardindex)
    m_questreward_selectable = false
    m_questreward_selectableex = false
    m_questreward_selectindex = 0
    m_questreward_selectindexex = 0
    local strreward = config_quest["reward" .. (rewardindex + 1)]
    if strreward ~= nil and strreward ~= "0" then
        local item, select = questdesc_rewardtype(strreward)
        if item then
            questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARD")
            questdesc_addrewardviewitem(list_content, config_quest, strreward)
        end
        if select then
            m_questreward_selectable = true
            questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDSELECT")
            questdesc_addrewardviewitemselect(list_content, strreward, rewardtype.normal)
        end
    end
    if config_quest.rewardex ~= nil then
        local questcomplete = playerattr_questcomplete[config_quest.id]
        local count = 0
        if questcomplete ~= nil then
            count = questcomplete.count
        end
        if count + 1 >= config_quest.repeatcount then
            local item, select = questdesc_rewardtype(config_quest.rewardex)
            if item then
                questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDEX")
                questdesc_addrewardviewitem(list_content, config_quest, config_quest.rewardex)
            end
            if select then
                m_questreward_selectableex = true
                questreward_addtaskrewardtitle(list_content, "QUEST_DESC_REWARDEXSELECT")
                questdesc_addrewardviewitemselect(list_content, config_quest.rewardex, rewardtype.rewardex)
            end
        end
    end
end

function playerreward_prepairsubmitconfig(config_quest, branch)
    local lambdareward = config_quest["reward" .. (branch + 1)]
    if lambdareward == nil then
        return true
    end
    local itemcount = 0
    local actioncount = lambdareward.actioncount
    local itemc = false
    for i=1,actioncount do
        local sublambda = lambdareward[i]
        if c_isaction(sublambda, "item") then
            itemcount = itemcount + sublambda.variablecount
        elseif c_isaction(sublambda, "item2") then
            itemcount = itemcount + 1
        elseif string.startwith(sublambda.action, "itemc") then
            if not itemc then
                itemc = true
                itemcount = itemcount + 1
            end
        end
    end
    if itemcount > 0 then
        local space = playerattr_bagspace - playeritem_getfillcount()
        if space < itemcount then
            chat_addsystemalert("QUEST_SUBMIT_BAGFULL")
            return false
        end
    end
    return true
end

function playerreward_prepairsubmit(questid)
    local quest = playerquest_getquest(questid)
    if quest == nil then
        return false
    end
    return playerreward_prepairsubmitconfig(quest.config_quest, quest.branch)
end

function questdesc_getrewardselect()
    if m_questreward_selectable and m_questreward_selectindex == 0 then
        return
    end
    if m_questreward_selectableex and m_questreward_selectindexex == 0 then
        return
    end
    return m_questreward_selectindex, m_questreward_selectindexex
end

function questdesc_selectdata(line, event, data)
    if line.selectdata ~= nil then
        if line.selectdata == rewardtype.normal then
            m_questreward_selectindex = line.selectindex
        elseif line.selectdata == rewardtype.rewardex then
            m_questreward_selectindexex = line.selectindex
        end
    end
end

function questdesc_settask(list_content, quest)
    local config_task = csvcraftingtask_getfromid(quest.config_quest.id)
    if config_task == nil then
        return
    end
    local config_recipe = csvcraftingrecipe_getfromid(config_task.recipeid)
    if config_recipe == nil then
        return
    end

    local textdesc = nil
    local lambdaaccept = quest.config_quest.accept
    if lambdaaccept ~= nil then
        local actioncount = lambdaaccept.actioncount
        for lambdaindex=1,actioncount do
            local sublambda = lambdaaccept[lambdaindex]
            if c_isaction(sublambda, "npc") then
                textdesc = c_textformat("QUEST_TASK_SUMMARY", csvnpc_getlinkname(sublambda.variable[1].integer))
                break
            end
        end
    end

    local line = list_content:add(m_questreward_inst.text)
    local text_content = line:getwidget("text_content")
    text_content:setrichtext(textdesc)
    text_content:setdelegate(questdesc_delegate_content)
    list_content:addspace(m_questreward_space / 2)

    questreward_addtaskrewardtitle(list_content, "QUEST_TASK_RECIPE")
    list_content:addspace(m_questreward_space / 4)

    line = list_content:add(m_questreward_inst.text)
    text_content = line:getwidget("text_content")
    text_content:settext(config_recipe.name)
    list_content:addspace(m_questreward_space)

    questreward_addtaskrewardtitle(list_content, "QUEST_TASK_COMPONENT")
    questreward_addtaskrewarditem(list_content, config_task.component1)
    if config_task.component2 ~= "0" then
        questreward_addtaskrewarditem(list_content, config_task.component2)
    end
    list_content:addspace(m_questreward_space)

    questreward_addtaskrewardtitle(list_content, "QUEST_TASK_PRODUCT")
    questreward_addtaskrewarditem(list_content, config_task.product)
    list_content:addspace(m_questreward_space)

    questreward_addtaskrewardtitle(list_content, "QUEST_TASK_REWARD")
    line = list_content:add(m_questreward_inst.rewarditem)
    local image_item = line:getwidget("image_item")
    image_item:seticon("items/icon_quest_undefineable01")

    local text_count = line:getwidget("text_count")
    text_count:setvisible(false)

    local text_name = line:getwidget("text_name")
    text_name:settext("QUEST_DESC_UNKNOW")

    questreward_resetrewardline(line)

    line = list_content:add(m_questreward_inst.buttontask)
    local button_abandon = line:getwidget("button_abandon")
    button_abandon:setdelegate(questdesc_delegate_abandon)
    button_abandon.questid = quest.questid
end
