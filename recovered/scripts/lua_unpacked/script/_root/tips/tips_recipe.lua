
local function tips_getrecipe(config_item)
    local lambda = csvitem_getscript(config_item, "addrecipe")
    if lambda ~= nil then
        return csvcraftingrecipe_getfromid(lambda.variable[1].integer)
    end
end

function tips_addrecipeskill(config_item)
    local config_recipe = tips_getrecipe(config_item)
    if config_recipe == nil then
        return
    end
    local config_skill = csvskill_getfromid(config_recipe.skill)
    if config_skill == nil then
        return
    end
    local desc = c_textformat("TIPS_ITEM_RECIPESKILL", config_skill.name, config_recipe.skilllevel)
    local craftingskill = playerskill_getcraftingskill(config_recipe.skill)
    if craftingskill ~= nil and craftingskill.level >= config_recipe.skilllevel then
        tips_adddesc(desc, TIPS_COLOR_DESC)
    else
        tips_adddesc(desc, TIPS_COLOR_RED)
    end
end

function tips_addrecipe(config_item)
    local config_recipe = tips_getrecipe(config_item)
    if config_recipe == nil then
        return
    end
    if config_recipe.component == "0" then
        return
    end

    tips_addsplit()
    tips_adddesc("TIPS_ITEM_RECIPECOMPONENTTITLE", TIPS_COLOR_TEXT)

    local itemarray = string.split(config_recipe.component, ";")
    for i=1,#itemarray do
        local iteminfo = string.split(itemarray[i], "x")
        local config_item = csvitem_getfromid(string.tointeger(iteminfo[1]))
        if config_item ~= nil then
            local requirecount = string.tointeger(iteminfo[2])
            tips_adddesc(c_textformat("TIPS_ITEM_RECIPECOMPONENT", config_item.name, requirecount), TIPS_COLOR_TEXT)
        end
    end
    
    if config_recipe.limit > 0 then
        tips_addsplit()
        tips_adddesc(c_textformat("TIPS_ITEM_RECIPELIMIT", config_recipe.limit), TIPS_COLOR_TEXT)
    end
end

function tips_addrecipeproduct(config_item, parent)
    local config_recipe = tips_getrecipe(config_item)
    if config_recipe == nil then
        return
    end
    if config_recipe.product == "0" then
        return
    end

    local itemarray = string.split(config_recipe.product, ";")
    local config_item = csvitem_getfromid(string.tointeger(itemarray[1]))
    if config_item ~= nil then
        local flag = tipsflag.compare1
        tips_create(flag, parent)
        tips_adddesc("TIPS_ITEM_RECIPEPRODUCT", TIPS_COLOR_EQUIPMINE)
        tips_additem(config_item, 1, flag, nil)
        tips_complete(0.0, tips_getmainpositiony())
    end

    config_item = csvitem_getfromid(string.tointeger(itemarray[2]))
    if config_item ~= nil then
        local flag = tipsflag.compare2
        tips_create(flag, parent)
        tips_adddesc("TIPS_ITEM_RECIPEPRODUCTEX", TIPS_COLOR_EQUIPMINE)
        tips_additem(config_item, 1, flag, nil)
        tips_complete(0.0, tips_getmainpositiony())
    end

    tips_adjustcompare()
end
