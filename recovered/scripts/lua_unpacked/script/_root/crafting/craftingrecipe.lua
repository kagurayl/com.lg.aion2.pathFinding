
function crafting_recipe_onopen()
    m_uicrafting_recipe:setwidgetdelegate("edit_filter", crafting_recipe_delegate_filter)
	m_uicrafting_recipe:setwidgetdelegate("button_batchmin", crafting_recipe_delegate_batchmin)
	m_uicrafting_recipe:setwidgetdelegate("button_batchdec", crafting_recipe_delegate_batchdec)
	m_uicrafting_recipe:setwidgetdelegate("button_batchinc", crafting_recipe_delegate_batchinc)
	m_uicrafting_recipe:setwidgetdelegate("button_batchmax", crafting_recipe_delegate_batchmax)
	m_uicrafting_recipe:setwidgetdelegate("edit_batchcount", crafting_recipe_delegate_batchinput)
	m_uicrafting_recipe:setwidgetdelegate("tab_product/button_make", crafting_recipe_delegate_make)
	m_uicrafting_recipe:setwidgetdelegate("tab_product/button_makeall", crafting_recipe_delegate_makeall)
	m_uicrafting_recipe:setwidgetdelegate("image_bg/button_close", crafting_recipe_delegate_close)

    local list_recipe = m_uicrafting_recipe:getwidget("list_recipe")
    list_recipe:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_recipe:setasyncdelegate(craftingproduct_delegate_setlist)
    list_recipe:setclickdelegate(craftingproduct_delegate_clickrecipe)

    local list_part = m_uicrafting_recipe:getwidget("tab_product/list_part")
    list_part:init(uilistflag.vertical)
    list_part:setclickdelegate(craftingproduct_delegate_clickpart)

	local image_skillicon = m_uicrafting_recipe:getwidget("image_skillicon")
	image_skillicon:seticon(m_uicrafting_recipe.config_skill.icon)

    crafting_recipe_updateskill()

    craftingproduct_setbatchinput(0)

    event_register(bit.bor(eventtype.item, eventtype.playerinfo), crafting_recipe_updateitem, m_uicrafting_recipe)
end

function crafting_recipe_updateskill()
    if m_uicrafting_recipe:null() then
        return
    end

	local text_skillname = m_uicrafting_recipe:getwidget("text_skillname")
	text_skillname:settext(m_uicrafting_recipe.config_skill.name)

    local text_skilllevel = m_uicrafting_recipe:getwidget("text_skilllevel")
	local progress_skillexp = m_uicrafting_recipe:getwidget("progress_skillexp")
    local craftingskill = playerskill_getcraftingskill(m_uicrafting_recipe.config_skill.id)
	if craftingskill ~= nil then
        text_skilllevel:settext(string.format("%d/%d", craftingskill.level, craftingskill.levelmax))
        if craftingskill.expmax ~= 0 then
    		progress_skillexp:setpercent(craftingskill.exp / craftingskill.expmax)
        else
            progress_skillexp:setpercent(0.0)
        end
    else
        text_skilllevel:settext("-/-")
		progress_skillexp:setpercent(0.0)
    end
end

function crafting_recipe_updateitem()
    craftingproduct_updateline()
    craftingproduct_updateselect()
end

function crafting_recipe_delegate_filter()
    craftingproduct_updatelist()
end

function crafting_recipe_delegate_batchmin()
	craftingproduct_setbatchinput(1)
end

function crafting_recipe_delegate_batchdec()
    local count = craftingproduct_getbatchinput()
    if count > 1 then
        craftingproduct_setbatchinput(count - 1)
    end
end

function crafting_recipe_delegate_batchinc()
    local count = craftingproduct_getbatchinput()
    local maxcount = craftingproduct_getmaxcount()
    if count < maxcount then
        craftingproduct_setbatchinput(count + 1)
    end
end

function crafting_recipe_delegate_batchmax()
    local maxcount = craftingproduct_getmaxcount()
    craftingproduct_setbatchinput(maxcount)
end

function crafting_recipe_delegate_batchinput()
    craftingproduct_verifybatchinput()
end

local function crafting_recipe_send(count)
    if m_uicrafting_recipe.selectrecipe ~= nil then
        if m_uicrafting_recipe.config_skill.id == skill_gather_convert then
            local msg = {messageid="CS_CraftingConvert"}
            msg.recipeid = m_uicrafting_recipe.selectrecipe.id
            msg.batchcount = count
            c_send(msg)
        else
            local msg = {messageid="CS_RecipeMake"}
            msg.entityid = m_uicrafting_recipe.entityid
            msg.recipeid = m_uicrafting_recipe.selectrecipe.id
            msg.batchcount = count
            msg.recipequest = m_uicrafting_recipe.selectrecipequest
            c_send(msg)
        end
    end
end

function crafting_recipe_delegate_make()
    local maxcount = craftingproduct_getmaxcount()
    if maxcount > 0 then
        crafting_recipe_send(1)
    end
end

function crafting_recipe_delegate_makeall()
    local count = craftingproduct_getbatchinput()
    if count > 0 then
        crafting_recipe_send(count)
    end
end

function crafting_recipe_delegate_close()
    m_uicrafting_recipe:close()
end
