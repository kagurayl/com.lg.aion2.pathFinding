
XML_Space = "    "
XML_SelectNone = "select_none"
XML_Select1 = "select1"
XML_AskQuestAccept = "ask_quest_accept"
XML_SelectQuest = "select_quest"
XML_SelectQuestReward = "select_quest_reward"
XML_AcceptQuest = "quest_accept_1"
XML_QuestItemFailed = "select6"
XML_BookPage1 = "page_1"
XML_SetPro = "setpro"
XML_SetSuccess = "set_succeed"

XML_HAction = "haction_"
XML_HSetPro = "haction_setpro"
XML_HSetSuccess = "haction_set_succeed"
XML_HActionQuestAccept = "haction_quest_accept_1"
XML_HActionSelectQuestRewrad = "haction_select_quest_reward"
XML_HActionCheckUserHasQuestItem = "haction_check_user_has_quest_item"
XML_HActionFinishDialog = "haction_finish_dialog"

local function csvxml_getnodefromtype(xmlnode, nodetype)
    if xmlnode ~= nil then
        for i=1, #xmlnode do
            if xmlnode[i].name == nodetype then
                return xmlnode[i]
            end
        end
    end
end

local function csvxml_getnodefromattr(xmlnode, nodetype, attrname, attrvalue)
    if xmlnode ~= nil then
        for i=1, #xmlnode do
            if xmlnode[i].name == nodetype and xmlnode[i].attr[attrname] == attrvalue then
                return xmlnode[i]
            end
        end
    end
end

local function csvxml_getnodetext(xmlnode, breakline)
    local text = ""
    if xmlnode.child ~= nil then
        for i=1, #xmlnode.child do
            local node = xmlnode.child[i]
            if node.name == "#text" and node.innertext ~= nil then
                text = text .. node.innertext
            else
                text = text .. csvxml_getnodetext(xmlnode.child[i], false)
            end
        end
    end
    if xmlnode.innertext ~= nil then
        if text ~= nil and breakline and string.len(text) > 0 then
            text = text .. "\n" .. XML_Space
        end
        if text ~= nil then
            text = text .. xmlnode.innertext
        else
            text = xmlnode.innertext
        end
    end
    return text
end

function csvxml_containnode(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    return node_htmlpage ~= nil
end

function csvxml_gettext(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return nil
    end
    local node_contents = csvxml_getnodefromtype(node_htmlpage.child, "contents")
    if node_contents == nil then
        return nil
    end
    local node_html = csvxml_getnodefromtype(node_contents.child, "html")
    if node_html == nil then
        return nil
    end
    local node_body = csvxml_getnodefromtype(node_html.child, "body")
    if node_body == nil then
        return nil
    end
    local text = ""
    for i=1, #node_body.child do
        local node_p = node_body.child[i]
        if node_p.child ~= nil then
            local nodetext = csvxml_getnodetext(node_p, true)
            if string.len(nodetext) > 0 then
                if string.len(text) > 0 then
                    text = text .. "\n"
                end
                text = text .. nodetext
            end
        else
            text = text .. "\n"
        end
    end
    return text
end

function csvxml_getsummary(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return nil
    end
    local node_contents = csvxml_getnodefromtype(node_htmlpage.child, "contents")
    if node_contents == nil then
        return nil
    end
    local node_html = csvxml_getnodefromtype(node_contents.child, "html")
    if node_html == nil then
        return nil
    end
    local node_body = csvxml_getnodefromtype(node_html.child, "body")
    if node_body == nil then
        return nil
    end
    local text = ""
    local step = {}
    for i=1, #node_body.child do
        local node = node_body.child[i]
        if node.name == "steps" then
            for j=1, #node.child do
                local nodestep = node.child[j]
                local state = {}
                for k=1, #nodestep.child do
                    local nodetext = csvxml_getnodetext(nodestep.child[k], false)
                    if k == 1 and nodestep.innertext ~= nil then
                        nodetext = nodetext .. xmlnode.innertext
                    end
                    state[#state + 1] = nodetext
                end
                step[#step + 1] = state
            end
        elseif node.name == "p" then
            local nodetext = csvxml_getnodetext(node, false)
            if string.len(nodetext) > 0 then
                if string.len(text) > 0 then
                    text = text .. "\n"
                end
                text = text .. nodetext
            end
        end
    end
    return text, step
end

function csvxml_getoption(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return {}
    end
    local option = {}
    local node_selects = csvxml_getnodefromtype(node_htmlpage.child, "selects")
    if node_selects ~= nil then
        for i=1, #node_selects.child do
            local node_act = node_selects.child[i]
            if node_act.attr.href ~= nil then
                local nodetext = csvxml_getnodetext(node_act, false)
                if string.len(nodetext) > 0 then
                    local href = {}
                    href.type = node_act.attr.href
                    href.text = nodetext
                    option[#option + 1] = href
                end
            end
        end
    end
    return option
end

function csvxml_getcutscene(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return 0
    end
    local cutscene = csvxml_getnodefromtype(node_htmlpage.child, "cutscene")
    if cutscene ~= nil and cutscene.attr.id ~= nil then
        return string.tointeger(cutscene.attr.id)
    end
    return 0
end

function csvxml_getnotify(xmlroot, nodename, progress)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return nil
    end
    local node_notifies = csvxml_getnodefromtype(node_htmlpage.child, "notifies")
    if node_notifies == nil then
        return nil
    end
    local node = csvxml_getnodefromattr(node_notifies.child, "notify", "progress", tostring(progress))
    if node ~= nil and node.child ~= nil then
        local nodetext = csvxml_getnodetext(node, false)
        return nodetext
    end
    return nil
end

function csvxml_funcavailable(name)
    if name == "create_pcguild" then
        return playerattr_icc == nil
    elseif name == "delete_pcguild" then
        return playerattr_icc ~= nil and playerattr_icc.disband == 0
    elseif name == "recreate_pcguild" then
        return playerattr_icc ~= nil and playerattr_icc.disband > 0
    elseif name == "guild_levelup" then
        return playerattr_icc ~= nil
    end
    return true
end

function csvxml_getnpcfuncs(xmlroot, nodename)
    local node_htmlpage = csvxml_getnodefromattr(xmlroot, "htmlpage", "name", nodename)
    if node_htmlpage == nil then
        return {}
    end
    local option = {}
    local npcfuncs = csvxml_getnodefromtype(node_htmlpage.child, "npcfuncs")
    if npcfuncs ~= nil then
        for i=1, #npcfuncs.child do
            local node_func = npcfuncs.child[i]
            if csvxml_funcavailable(node_func.name) then
                local href = {}
                href.type = node_func.name
                href.text = csvxml_getnodetext(node_func, false)
                option[#option + 1] = href
            end
        end
    end
    return option
end

function csvxml_getfromhref(xmlnode, href)
    if xmlnode ~= nil then
        for nodeindex=1, #xmlnode do
            local node_selects = csvxml_getnodefromtype(xmlnode[nodeindex].child, "selects")
            if node_selects ~= nil then
                for i=1, #node_selects.child do
                    local node_act = node_selects.child[i]
                    if node_act.attr ~= nil and node_act.attr.href == href then
                        return xmlnode[nodeindex].attr.name
                    end
                end
            end
        end
    end
end
