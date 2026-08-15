
include("crafting/craftingrecipe")
include("crafting/craftingproduct")
include("crafting/craftingprogress")

m_uicrafting_recipe = uipanel_createhandle("crafting/crafting_recipe", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.fullscreen, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_crafting_levelup_cost = { [0] = 3500, [99] = 17000, [199] = 115000, [299] = 460000, [399] = 0, [449] = 6004900, [499] = 12000000 };

function crafting_open(config_npcstatic, skillid)
	local config_skill = csvskill_getfromid(skillid)
	if config_skill == nil then
		return
	end
	m_uicrafting_recipe.config_skill = config_skill
	m_uicrafting_recipe.selectrecipe = nil
	m_uicrafting_recipe.entityid = 0
	m_uicrafting_recipe.entityposition = nil
	if config_npcstatic ~= nil then
		m_uicrafting_recipe.entityid = config_npcstatic.staticid
		m_uicrafting_recipe.entityposition = string.splitnumber(config_npcstatic.position, ",")
	end
	m_uicrafting_recipe:open()
	crafting_recipe_updateskill()
	craftingproduct_updatelist()
	event_register(eventtype.update, crafting_update, m_uicrafting_recipe)
end

function crafting_update()
	if m_uicrafting_recipe.config_skill.id ~= skill_gather_convert then
		local makeable = false
		if m_uicrafting_recipe.entityid ~= 0 and m_me ~= nil then
			local dist = vector3_distance(m_uicrafting_recipe.entityposition[1], m_uicrafting_recipe.entityposition[2], m_uicrafting_recipe.entityposition[3], m_me.transform.px, m_me.transform.py, m_me.transform.pz)
			makeable = dist < 4.0
		end
		m_uicrafting_recipe:setwidgetenable("tab_product/button_makeall", makeable)
		m_uicrafting_recipe:setwidgetenable("tab_product/button_make", makeable)
	end
end

function crafting_gatherskilllevelup_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_CraftingSkillLevelUp"}
		msg.skillid = data.levelupskillid
        msg.actorid = data.npcactorid
        c_send(msg)
    end
end

function crafting_getnpccraftingskill(config_npc)
	local npcscript = config_npc.script
    if npcscript == nil then
		return 0
    end
    local actioncount = npcscript.actioncount
    for i=1,actioncount do
		local sublambda = npcscript[i]
		if c_isaction(sublambda, "levelupgather") then
			return skill_gather_land
		elseif c_isaction(sublambda, "levelupaerial") then
			return skill_gather_od
		elseif c_isaction(sublambda, "levelupcooking") then
			return skill_gather_cooking
		elseif c_isaction(sublambda, "levelupweapon") then
			return skill_gather_weapon
		elseif c_isaction(sublambda, "leveluparmor") then
			return skill_gather_armor
		elseif c_isaction(sublambda, "leveluptailor") then
			return skill_gather_tailor
		elseif c_isaction(sublambda, "levelupalchemy") then
			return skill_gather_alchemy
		elseif c_isaction(sublambda, "leveluphandiwork") then
			return skill_gather_handiwork
		end
	end
	return 0
end

function crafting_skilllevelup(actorid)
	local npc = actormanager_getfromactorid(actorid)
    if npc == nil or not npc:isdynamicnpc() then
		return
    end
	local skillid = crafting_getnpccraftingskill(npc.config_npc)
	if skillid == 0 then
		return
	end
	local config_skill = csvskill_getfromid(skillid)
	if config_skill == nil then
		return
	end
	local craftingskill = playerskill_getcraftingskill(skillid)
	if craftingskill == nil then
		local learntext = c_textformat("CRAFTING_SKILL_LEARN", config_skill.name, m_crafting_levelup_cost[0])
		messagebox_confirm(learntext, crafting_gatherskilllevelup_confirm, {npcactorid = actorid, levelupskillid = skillid})
		return
	end
	local price = m_crafting_levelup_cost[craftingskill.level]
	if price == nil or craftingskill.level < craftingskill.levelmax then
		chat_addsystemalert("CRAFTING_SKILL_LEVELNOTENOUGH")
		return
	end
	local leveluptext = c_textformat("CRAFTING_SKILL_LEVELUPCOST", config_skill.name, price)
	if price > 0 then
		messagebox_confirm(leveluptext, crafting_gatherskilllevelup_confirm, {npcactorid = actorid, levelupskillid = skillid})
	else
		local msg = {messageid="CS_CraftingSkillLevelUp"}
		msg.skillid = skillid
        msg.actorid = actorid
        c_send(msg)
	end
end
