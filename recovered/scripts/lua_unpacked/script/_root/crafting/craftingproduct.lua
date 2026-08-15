
local m_craftingproduct_inst = {recipe = "crafting/inst_recipe", part = "crafting/inst_part"}

function craftingproduct_getbatchinput()
    local edit_batchcount = m_uicrafting_recipe:getwidget("edit_batchcount")
    local text = edit_batchcount:gettext()
    local count = string.tointeger(text) or 0
    return math.max(count, 0)
end

function craftingproduct_setbatchinput(count)
    local edit_batchcount = m_uicrafting_recipe:getwidget("edit_batchcount")
    edit_batchcount:settext(count)
end

function craftingproduct_verifybatchinput()
    local count = craftingproduct_getbatchinput()
    local maxcount = craftingproduct_getmaxcount()
    local mincount = 0
    if maxcount > 0 then
        mincount = 1
    end
    local adjustcount = math.clamp(count, mincount, maxcount)
    if count ~= adjustcount then
        craftingproduct_setbatchinput(adjustcount)
    end
end

function craftingproduct_getmaxcount(config_recipe)
    if config_recipe == nil then
        config_recipe = m_uicrafting_recipe.selectrecipe
    end
    if config_recipe == nil then
        return 0
    end
    local maxcount = 999
    if config_recipe.dp > 0 then
        maxcount = math.tointegerfloor(playerattr_info.dp / config_recipe.dp)
    end
    if config_recipe.component ~= "0" then
        local itemarray = string.split(config_recipe.component, ";")
        for i=1,#itemarray do
            local iteminfo = string.split(itemarray[i], "x")
            local config_item = csvitem_getfromid(string.tointeger(iteminfo[1]))
            if config_item ~= nil then
                local requirecount = string.tointeger(iteminfo[2])
                local playeritemcount = playeritem_getcount(config_item.id)
                maxcount = math.min(maxcount, math.tointegerfloor(playeritemcount / requirecount))
            end
        end
    end
    return maxcount
end

function craftingproduct_setcontentvisible(visible)
    m_uicrafting_recipe:setwidgetvisible("tab_product/image_producticon", visible)
    m_uicrafting_recipe:setwidgetvisiblenothit("tab_product/text_productcount", visible)
    m_uicrafting_recipe:setwidgetvisible("tab_product/text_productname", visible)

    m_uicrafting_recipe:setwidgetvisible("tab_product/text_productex", visible)
    m_uicrafting_recipe:setwidgetvisible("tab_product/image_producticonex", visible)
    m_uicrafting_recipe:setwidgetvisiblenothit("tab_product/text_productcountex", visible)
    m_uicrafting_recipe:setwidgetvisible("tab_product/text_productnameex", visible)

    m_uicrafting_recipe:setwidgetvisible("tab_product/text_dpcost", visible)
end

function craftingproduct_updateselect()
    local list_part = m_uicrafting_recipe:getwidget("tab_product/list_part")
    list_part:clear()

    local config_recipe = m_uicrafting_recipe.selectrecipe
    if config_recipe == nil then
        craftingproduct_setcontentvisible(false)
        return
    end
    craftingproduct_setcontentvisible(true)

    local subproduct = string.split(config_recipe.product, ";")
    local config_item1 = csvitem_getfromid(string.tointeger(subproduct[1]))
    local image_producticon = m_uicrafting_recipe:getwidget("tab_product/image_producticon")
    local text_productcount = m_uicrafting_recipe:getwidget("tab_product/text_productcount")
    local text_productname = m_uicrafting_recipe:getwidget("tab_product/text_productname")
    image_producticon:setdelegate(craftingproduct_delegate_product)
    if config_item1 ~= nil then
        image_producticon.itemid = config_item1.id
        image_producticon.itemcount = config_recipe.count
        image_producticon:setvisible(true)
        image_producticon:seticon(config_item1.icon)
        text_productcount:settext(config_recipe.count)
        text_productname:settext(config_item1.name)
    else
        image_producticon.itemid = nil
        image_producticon:setvisible(false)
        text_productcount:settext("")
        text_productname:settext("")
    end

    local config_item2 = nil
    if #subproduct > 1 then
        config_item2 = csvitem_getfromid(string.tointeger(subproduct[2]))
    end
    local text_productex = m_uicrafting_recipe:getwidget("tab_product/text_productex")
    local image_producticonex = m_uicrafting_recipe:getwidget("tab_product/image_producticonex")
    local text_productcountex = m_uicrafting_recipe:getwidget("tab_product/text_productcountex")
    local text_productnameex = m_uicrafting_recipe:getwidget("tab_product/text_productnameex")
    image_producticonex:setdelegate(craftingproduct_delegate_productex)
    if config_item2 ~= nil then
        image_producticonex.itemid = config_item2.id
        image_producticonex.itemcount = config_recipe.count
        text_productex:setvisible(true)
        image_producticonex:setvisible(true)
        image_producticonex:seticon(config_item2.icon)
        text_productcountex:settext(config_recipe.count)
        text_productnameex:settext(config_item2.name)
    else
        image_producticonex.itemid = nil
        text_productex:setvisible(false)
        image_producticonex:setvisible(false)
        text_productcountex:settext("")
        text_productnameex:settext("")
    end

    local text_dpcost = m_uicrafting_recipe:getwidget("tab_product/text_dpcost")
    if config_recipe.dp > 0 then
        text_dpcost:setvisiblenothit(true)
        text_dpcost:settext("RECIPE_COSTDP", config_recipe.dp)
        if config_recipe.dp <= playerattr_info.dp then
            text_dpcost:setcolor(0, 1, 0, 1)
        else
            text_dpcost:setcolor(1, 0, 0, 1)
        end
    else
        text_dpcost:setvisible(false)
    end

    local itemarray = string.split(config_recipe.component, ";")
    for i=1,#itemarray do
        local iteminfo = string.split(itemarray[i], "x")
        local config_item = csvitem_getfromid(string.tointeger(iteminfo[1]))
        if config_item ~= nil then
            local requirecount = string.tointeger(iteminfo[2])
            local playeritemcount = playeritem_getcount(config_item.id)
            local line = list_part:add(m_craftingproduct_inst.part, config_item.id, config_item.id)
            local image_icon = line:getwidget("image_icon")
            image_icon:seticon(config_item.icon)
            if requirecount > playeritemcount then
                image_icon:setcolor(0.5,0.5,0.5,1.0)
            else
                image_icon:setcolor(1.0,1.0,1.0,1.0)
            end

            local text_count = line:getwidget("text_count")
            text_count:settext(requirecount)

            local text_name = line:getwidget("text_name")
            text_name:settext(config_item.name)

            local text_costitem = line:getwidget("text_costitem")
            text_costitem:settext(string.format("%d/%d", playeritemcount, requirecount))
        end
    end
    craftingproduct_verifybatchinput()
end

function craftingproduct_updatelist()
    if m_uicrafting_recipe:null() then
        return
    end

    local edit_filter = m_uicrafting_recipe:getwidget("edit_filter")
    local filter = edit_filter:gettext()
    if filter ~= nil and string.len(filter) == 0 then
        filter = nil
    end

    local recipearray = {}
    for i=1,#playerattr_craftingrecipe do
        local config_recipe = csvcraftingrecipe_getfromid(playerattr_craftingrecipe[i].recipeid)
        if config_recipe ~= nil then
            if config_recipe.skill == m_uicrafting_recipe.config_skill.id then
                local name = config_recipe.name
                if filter == nil or string.find(name, filter) ~= nil then
                    recipearray[#recipearray + 1] = config_recipe
                end
            end
        end
	end
    table.sort(recipearray, function(p1, p2) return (p1.id > p2.id) end)

    local taskarray = {}
    for i=1,#playerattr_quest do
        local config_quest = playerattr_quest[i].config_quest
		if config_quest.type == questtype.crafting then
            local config_task = csvcraftingtask_getfromid(config_quest.id)
            if config_task ~= nil then
                local config_recipe = csvcraftingrecipe_getfromid(config_task.recipeid)
                if config_recipe ~= nil then
                    if config_recipe.skill == m_uicrafting_recipe.config_skill.id then
                        local name = config_recipe.name
                        if filter == nil or string.find(name, filter) ~= nil then
                            local taskarraydata = {}
                            taskarraydata.recipeid = config_recipe.id
                            taskarraydata.questid = config_quest.id
                            taskarray[#taskarray + 1] = taskarraydata
                        end
                    end
                end
            end
		end
    end
    table.sort(taskarray, function(p1, p2) return (p1.recipeid > p2.recipeid) end)

    local list_recipe = m_uicrafting_recipe:getwidget("list_recipe")
    list_recipe:savestate()
    list_recipe:clear()
    for i=1,#taskarray do
        local recipeid = taskarray[i].recipeid
        local line = list_recipe:add(m_craftingproduct_inst.recipe, recipeid, recipeid)
        line.questid = taskarray[i].questid
    end

    for i=1,#recipearray do
        local config_recipe = recipearray[i]
        list_recipe:add(m_craftingproduct_inst.recipe, config_recipe.id, config_recipe.id)
    end
    list_recipe:restorestate()

    craftingproduct_updateselect()
end

function craftingproduct_updateline()
    local list_recipe = m_uicrafting_recipe:getwidget("list_recipe")
    for i=1,list_recipe:getcount() do
        local line = list_recipe:getlinefromindex(i)
        if line:getasyncvisible() then
            local recipeid = line:getdata()
            local config_recipe = csvcraftingrecipe_getfromid(recipeid)
            local text_count = line:getwidget("text_count")
            text_count:settext("RECIPE_COUNT", craftingproduct_getmaxcount(config_recipe))
        end
    end
end

function craftingproduct_delegate_setlist(sender, line, recipeid)
    local config_recipe = csvcraftingrecipe_getfromid(recipeid)

	local text_level = line:getwidget("text_level")
	text_level:settext("RECIPE_LEVEL", config_recipe.skilllevel)

    local text_name = line:getwidget("text_name")
	text_name:settext(config_recipe.name)

    local text_count = line:getwidget("text_count")
	text_count:settext("RECIPE_COUNT", craftingproduct_getmaxcount(config_recipe))
end

function craftingproduct_delegate_clickrecipe(line, event, recipeid)
    m_uicrafting_recipe.selectrecipe = csvcraftingrecipe_getfromid(recipeid)
    m_uicrafting_recipe.selectrecipequest = line.questid
    local maxcount = craftingproduct_getmaxcount(m_uicrafting_recipe.selectrecipe)
    craftingproduct_setbatchinput(maxcount)
    craftingproduct_updateselect()
end

function craftingproduct_delegate_product(sender, event)
    if sender.itemid ~= nil then
        local x,y,w,h = sender:getabsolute()
        tips_item(sender.itemid, sender.itemcount, x, y + h, tipsflag.vleft, nil, m_uicrafting_recipe)
    end
end

function craftingproduct_delegate_productex(sender, event)
    if sender.itemid ~= nil then
        local x,y,w,h = sender:getabsolute()
        tips_item(sender.itemid, sender.itemcount, x, y + h, tipsflag.vleft, nil, m_uicrafting_recipe)
    end
end

function craftingproduct_delegate_clickpart(line, event, data)

end
