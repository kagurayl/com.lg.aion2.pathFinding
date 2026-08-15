
local m_questdesc_inst =
{
    text = "quest/inst_text",
    step = "quest/inst_step",
    button = "quest/inst_button",
}

questdesctype = 
{
    main = 1,
    state = 2,
    all = 3,
    allstate = 4,
}

local function questdesc_convertstateitem(quest, viewstep)
    local itemdesc = {}
    if quest.config_step == nil then
        return itemdesc
    end
    local lambda = quest.config_step[viewstep]
    if lambda == nil then
        return itemdesc
    end
    for lambdaindex=1,#lambda do
        local statelambda = lambda[lambdaindex]
        if statelambda.action == QuestStep_GetItem or statelambda.action == QuestStep_BagItem then
            local itemid = statelambda.variable[1].integer
            local reqcount = statelambda.variable[1].count
            local current = 1
            if quest.state ~= nil and lambdaindex <= #quest.state and quest.state[lambdaindex] < reqcount then
                current = quest.state[lambdaindex]
                if current == -1 then
                    current = reqcount
                end
            else
                current = reqcount
            end
            local config_item = csvitem_getfromid(itemid)
            if config_item ~= nil then
                local itemstr = nil
                if config_item.id == itemid_coin then
                    itemstr = string.format("%s(%d)", config_item.name, reqcount)
                elseif reqcount < 1000 then
                    itemstr = string.format("%s(%d/%d)", config_item.name, current, reqcount)
                else
                    itemstr = config_item.name
                end
                if current >= reqcount then
                    itemstr = itemstr .. c_textformat("QUEST_STEP_COMPLETE")
                end
                itemdesc[#itemdesc + 1] = {str = itemstr, index = lambdaindex}
            end
        end
    end
    return itemdesc
end

local function questdesc_convertstatecount(quest, viewstep, killtypeindex)
    local lambda = quest.config_step[viewstep]
    local index = 0
    for lambdaindex=1,#lambda do
        local statelambda = lambda[lambdaindex]
        if statelambda.action == QuestStep_Kill
        or statelambda.action == QuestStep_Talk
        or statelambda.action == QuestStep_TalkOneOf
        or statelambda.action == QuestStep_TalkBranch
        or statelambda.action == QuestStep_TalkFinish
        or statelambda.action == QuestStep_Zone
        or statelambda.action == QuestStep_Sphere
        or statelambda.action == QuestStep_LureZone
        or statelambda.action == QuestStep_LureSphere
        or statelambda.action == QuestStep_Skill
        or statelambda.action == QuestStep_Consume
        or statelambda.action == QuestStep_ItemArea
        or statelambda.action == QuestStep_ItemSphere
        or statelambda.action == QuestStep_Map
        or statelambda.action == QuestStep_PVPTitle
        or statelambda.action == QuestStep_PVPMap then
            index = index + 1
            if index == killtypeindex then
                local action = statelambda.action
                local reqcount = statelambda.variable[1].integer
                if action ~= QuestStep_Kill and action ~= QuestStep_Skill
                and action ~= QuestStep_PVPTitle and action ~= QuestStep_PVPMap then
                    reqcount = statelambda.variable[1].count
                end
                local statecomplete = true
                local currentcount = reqcount
                if quest.state ~= nil then
                    if viewstep < quest.step then
                        if statelambda.variable ~= nil and reqcount > 0 then
                            currentcount = reqcount
                        else
                            currentcount = 1
                        end
                    elseif lambdaindex <= #quest.state then
                        if quest.state[lambdaindex] ~= -1 then
                            currentcount = quest.state[lambdaindex]
                            statecomplete = false
                        end
                    end
                end
                local state = {}
                state.lambdaindex = lambdaindex
                state.statecomplete = statecomplete
                state.str = string.format("%d/%d", currentcount, reqcount)
                return state
            end
        end
    end
    return nil
end

local function questdesc_getreplace(xmlstate, index)
    local bytebrackets1 = string.byte("[")
	local bytebrackets2 = string.byte("]")
    local bytebrackets3 = string.byte("%")
    local bytebrackets4 = string.byte("/")
    local byte0 = string.byte("0")
    local byte9 = string.byte("9")
    local brackets = 0
    for i = index, #xmlstate do
        local strbyte = string.byte(xmlstate, i, i)
        if strbyte == bytebrackets1 then
            brackets = i
        elseif strbyte == bytebrackets2 and brackets > 0 then
            strbyte = string.byte(xmlstate, brackets + 1, brackets + 1)
            local str = string.sub(xmlstate, brackets + 2, i - 1)
            if strbyte == bytebrackets3 then
                if str == "collectitem" then
                    local data = {}
                    data.str1 = string.sub(xmlstate, 1, brackets - 1)
                    data.str2 = nil
                    data.isitem = true
                    return data
                elseif tonumber(str) ~= nil then
                    if i + 2 <= #xmlstate then
                        local brackets4 = string.byte(xmlstate, i + 1, i + 1)
                        local number = string.byte(xmlstate, i + 2, i + 2)
                        if brackets4 == bytebrackets4 and number >= byte0 and number <= byte9 then
                            local index2 = i + 2
                            for j=i+3, #xmlstate do
                                number = string.byte(xmlstate, j, j)
                                if number >= byte0 and number <= byte9 then
                                    index2 = j
                                else
                                    break
                                end
                            end
                            local data = {}
                            data.str1 = string.sub(xmlstate, 1, brackets - 1)
                            data.str2 = string.sub(xmlstate, index2 + 1, #xmlstate)
                            data.isitem = false
                            return data
                        end
                    end
                    local data = {}
                    data.str1 = string.sub(xmlstate, 1, brackets - 1) .. "("
                    if i + 2 <= #xmlstate then
                        data.str2 = string.sub(xmlstate, i + 2, #xmlstate) .. ")"
                    else
                        data.str2 = ")"
                    end
                    data.isitem = false
                    return data
                end
            end
            brackets = 0
        end
    end
    return nil
end

function questdesc_convertstep(quest, viewstep, summarystep, desctype, viewstate)
    local killtypeindex = 1
    local stepdesc = {}
    local appenditem = false
    for summaryindex = 1,#summarystep do
        local brackets = 1
        local statedesc = summarystep[summaryindex]
        local statecomplete = nil
        local stateindex = 0
        while true do
            local data = questdesc_getreplace(statedesc, brackets)
            if data == nil then
                break
            end
            if data.isitem then
                statedesc = data.str1
                appenditem = true
                break
            end
            local state = questdesc_convertstatecount(quest, viewstep, killtypeindex)
            if state == nil then
                break
            end
            killtypeindex = killtypeindex + 1
            if statecomplete == nil then
                statecomplete = state.statecomplete
            elseif not state.statecomplete then
                statecomplete = false
            end
            stateindex = state.lambdaindex
            statedesc = data.str1 .. state.str
            brackets = #statedesc
            if data.str2 ~= nil and #data.str2 > 0 then
                statedesc = statedesc .. data.str2
            end
        end
        if statecomplete then
            statedesc = statedesc .. c_textformat("QUEST_STEP_COMPLETE")
        end
        if desctype == questdesctype.state and stateindex == viewstate then
            return statedesc
        end
        if string.len(statedesc) > 0 then
            if desctype == questdesctype.allstate then
                if stateindex ~= nil and stateindex > 0 then
                    stepdesc[#stepdesc + 1] = statedesc
                end
            else
                stepdesc[#stepdesc + 1] = statedesc
            end
        end
    end
    local itemdesc = questdesc_convertstateitem(quest, viewstep)
    if desctype == questdesctype.state then
        for i=1, #itemdesc do
            if itemdesc[i].index == viewstate then
                return itemdesc[i].str
            end
        end
        return nil
    end
    if desctype == questdesctype.allstate then
        local desctextallstate = nil
        for i=1,#stepdesc do
            if desctextallstate ~= nil then
                desctextallstate = desctextallstate .. "\n" .. stepdesc[i]
            else
                desctextallstate = stepdesc[i]
            end
        end
        for i=1,#itemdesc do
            if desctextallstate ~= nil then
                desctextallstate = desctextallstate .. "\n" .. itemdesc[i].str
            else
                desctextallstate = itemdesc[i].str
            end
        end
        return desctextallstate
    end
    local desctext = stepdesc[1]
    if desctype == questdesctype.main then
        return desctext
    end
    for i=2,#stepdesc do
        desctext = desctext .. "\n" .. stepdesc[i]
    end
    if appenditem then
        for i=1,#itemdesc do
            desctext = desctext .. "\n" .. itemdesc[i].str
        end
    end
    return desctext
end

function questdesc_add(list_content, quest, detail)
    local xmlcontent = playerquest_loadxml(quest.questid)
    local text, step = csvxml_getsummary(xmlcontent, "quest_summary")
    if step == nil then
        return
    end
    if detail then
        local line = list_content:add(m_questdesc_inst.text)
        local text_content = line:getwidget("text_content")
        text_content:setrichtext(text)
        text_content:setdelegate(questdesc_delegate_content)

        local text_w,text_h = text_content:setheightfromrendersize()
        line:setsize(text_h)
    end

    local addstep = math.min(quest.step, #step)
    local addstart = 1
    if not detail then
        addstart = addstep
    end
    for stepindex=addstart,addstep do
        if playerquest_stepvisible(quest, stepindex) then
            line = list_content:add(m_questdesc_inst.step)
            local image_step = line:getwidget("image_step")
            if stepindex >= quest.step then
                image_step:setsprite("sp1/queststepgrey")
            else
                image_step:setsprite("sp1/queststepcolor")
            end
            local desctype = math.ternary(stepindex < addstep, questdesctype.main, questdesctype.all)
            local steptext = questdesc_convertstep(quest, stepindex, step[stepindex], desctype)
            local text_step = line:getwidget("text_step")
            text_step:setrichtext(steptext)
            text_step:setdelegate(questdesc_delegate_content)

            text_w,text_h = text_step:setheightfromrendersize()
            local size = math.max(text_h + 50, 150)
            local x, y = image_step:getposition()
            image_step:setposition(x, -size / 2)

            x, y = text_step:getposition()
            text_step:setposition(x, -size / 2)

            line:setsize(size)
        end
    end
end

function questdesc_addprequest(list_content, text)
    local line = list_content:add(m_questdesc_inst.text)
    local text_content = line:getwidget("text_content")
    text_content:setrichtext(text)

    local text_w,text_h = text_content:setheightfromrendersize()
    line:setsize(text_h)
end

function questdesc_addbutton(list_content, quest)
    local line = list_content:add(m_questdesc_inst.button)
    local button_share = line:getwidget("button_share")
    if quest.config_quest.abandon > 0 then
        button_share:setenable(true)
        button_share:setdelegate(questdesc_delegate_share)
        button_share.questid = quest.questid
    else
        button_share:setenable(false)
    end

    local button_abandon = line:getwidget("button_abandon")
    if quest.config_quest.abandon > 0 then
        button_abandon:setenable(true)
        button_abandon:setdelegate(questdesc_delegate_abandon)
        button_abandon.questid = quest.questid
    else
        button_abandon:setenable(false)
    end

    local button_desc = line:getwidget("button_desc")
    button_desc:setdelegate(questdesc_delegate_desc)
    button_desc.questid = quest.questid

    local button_map = line:getwidget("button_map")
    button_map:setdelegate(questdesc_delegate_showmap)
    button_map.questid = quest.questid
end

function questdesc_delegate_share(sender)
    local msg = {messageid="CS_QuestShare"}
    msg.questid = sender.questid
    c_send(msg)
end

function questdesc_abandon_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_QuestAbandon"}
        msg.questid = data
        c_send(msg)
    end
end
function questdesc_delegate_abandon(sender)
    local config_quest = csvquest_getfromid(sender.questid)
    local confirmtext = c_textformat("QUEST_MAIN_ABANDON_CONFIRM", config_quest.name)
    messagebox_confirm(confirmtext, questdesc_abandon_confirm, sender.questid)
end

function questdesc_delegate_content(sender, event)
    if event.name == "click" and event.linkid ~= nil then
        local image_bg = m_uiquest_questmain:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        richtext_onclick(event, sender.tagarray, x, tipsflag.vleft)
    end
end

function questdesc_delegate_desc(sender)
    if m_uiquest_questmain.descquestid ~= sender.questid then
        m_uiquest_questmain.descquestid = sender.questid
    else
        m_uiquest_questmain.descquestid = nil
    end
    quest_main_updateui()
    quest_main_scrolltoselect()
end

local function questdesc_delegate_showlambda(questid, queststep, questlambdaindex, lambda, additivelambdaarray)
    if lambda.action == QuestStep_Talk or lambda.action == QuestStep_TalkOneOf or lambda.action == QuestStep_TalkBranch or lambda.action == QuestStep_TalkFinish then
        return maplabel_setnpcflicker(lambda.variable[1].integer)
    elseif lambda.action == QuestStep_Kill then
        local npcarray = {}
        for i=2,#lambda.variable do
            npcarray[#npcarray + 1] = lambda.variable[i].integer
        end
        return maplabel_setquestkill(questid, queststep, questlambdaindex, npcarray)
    elseif lambda.action == QuestStep_GetItem or lambda.action == QuestStep_BagItem then
        local npcarray = {}
        if additivelambdaarray ~= nil then
            for lambdaindex=1,#additivelambdaarray do
                local additivelambda = additivelambdaarray[lambdaindex]
                if additivelambda.action == QuestAddititve_Drop and additivelambda.variable[1].integer == lambda.variable[1].integer then
                    for i=3,#additivelambda.variable do
                        npcarray[#npcarray + 1] = additivelambda.variable[i].integer
                    end
                end
            end
        end
        return maplabel_setquestkill(questid, queststep, questlambdaindex, npcarray)
    elseif lambda.action == QuestStep_ItemArea then
        local config_itemarea = c_config_getmetacol(configid.map_itemarea, "name", lambda.variable[2].str)
        if config_itemarea ~= nil then
            return maplabel_setquestpoly(questid, queststep, questlambdaindex, config_itemarea.id, config_itemarea.poly, 1.0)
        end
    elseif lambda.action == QuestStep_Zone then
        local config_zone = c_config_getmetaarray(configid.map_zone, "mapid", lambda.variable[1].integer, "name", lambda.variable[2].str)
        if config_zone ~= nil then
            config_zone = config_zone[1]
            return maplabel_setquestpoly(questid, queststep, questlambdaindex, lambda.variable[1].integer, config_zone.poly, 1.0)
        end
    elseif lambda.action == QuestStep_Sphere then
        return maplabel_setquestzone(questid, queststep, questlambdaindex, lambda.variable[1].integer, lambda.variable[2].flt, lambda.variable[3].flt, lambda.variable[4].flt, lambda.variable[5].flt)
    elseif lambda.action == QuestStep_LureSphere then
        return maplabel_setquestzone(questid, queststep, questlambdaindex, lambda.variable[1].integer, lambda.variable[2].flt, lambda.variable[3].flt, lambda.variable[4].flt, lambda.variable[5].flt)
    elseif lambda.action == QuestStep_Escort then
        if lambda.variable[2].flt ~= 0.0 then
            return maplabel_setquestzone(questid, queststep, questlambdaindex, scene_getmapid(), lambda.variable[2].flt, lambda.variable[3].flt, lambda.variable[4].flt, lambda.variable[5].flt)
        end
    end
     if additivelambdaarray ~= nil then
        for lambdaindex=1,#additivelambdaarray do
            local additivelambda = additivelambdaarray[lambdaindex]
            if additivelambda.action == QuestAddititve_View then
                local viewarray = {}
                local viewcount = math.tointegerfloor(#additivelambda.variable / 3)
                for i=1,viewcount do
                    local n = (i - 1) * 3 + 3
                    local view = {}
                    view.x = additivelambda.variable[n].flt
                    view.y = additivelambda.variable[n + 1].flt
                    view.z = additivelambda.variable[n + 2].flt
                    viewarray[#viewarray + 1] = view
                end
                maplabel_setquestzonearray(questid, queststep, questlambdaindex, additivelambda.variable[1].integer, additivelambda.variable[2].flt, viewarray)
                break
            end
        end
    end
    return false
end

function questdesc_delegate_showmap(sender)
    local quest = playerquest_getquest(sender.questid)
    if quest == nil or quest.state == nil or quest.config_step == nil or quest.step > #quest.config_step then
        return
    end
    local lambdaarray = quest.config_step[quest.step]
    if lambdaarray == nil then
        return
    end
    local additivelambdaarray = quest.config_additive[quest.step]
    for lambdaindex=1,#lambdaarray do
        local lambda = lambdaarray[lambdaindex]
        local reqcount = csvqueststep_getreqcount(lambda)
        if quest.state[lambdaindex] >= 0 and quest.state[lambdaindex] < reqcount then
            if lambda.action ~= QuestStep_CheckItem then
                local success = questdesc_delegate_showlambda(quest.questid, quest.step, lambdaindex, lambda, additivelambdaarray)
                if not success then
                    local trace = csvqueststep_gettrace(quest.questid, quest.step)
                    if trace ~= nil and trace ~= "0" then
                        local subtrace = string.splitnumber(trace, ",")
                        maplabel_setquestzone(quest.questid, quest.step, lambdaindex, math.tointegerfloor(subtrace[1]), subtrace[2], subtrace[3], subtrace[4], subtrace[5])
                    end
                end
                break
            end
        end
    end
end
