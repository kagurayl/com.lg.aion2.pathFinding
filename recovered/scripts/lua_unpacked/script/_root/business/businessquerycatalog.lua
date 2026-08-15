
local m_businessquery_treeinst = {[1] = "business/inst_catalog1", [2] = "business/inst_catalog2", [3] = "business/inst_catalog3"}
local m_businessquery_root = nil

local function business_query_addcatalogchild(parent, text, type)
    local node = {}
    node.text = text
    node.type = type
    node.expand = false
    node.parent = parent
    node.sub = {}
    if parent ~= nil then
        parent.sub[#parent.sub + 1] = node
    else
        m_businessquery_root[#m_businessquery_root + 1] = node
    end
    return node
end

local function business_query_addline(list_category, node, level)
    local line = list_category:add(m_businessquery_treeinst[level], list_category:getcount(), node)
    local text_name = line:getwidget("text_name")
    text_name:settext(node.text)
    if node.expand then
        for i=1,#node.sub do
            business_query_addline(list_category, node.sub[i], level + 1)
        end
    end
end

local function business_query_updatecatalog()
    local list_category = m_uibusiness_main:getwidget("tab_query/list_category")
    list_category:savestate()
    list_category:clear()
    for i=1,#m_businessquery_root do
        business_query_addline(list_category, m_businessquery_root[i], 1)
    end
    list_category:restorestate()
end

function business_query_addcatalog()
    local list_category = m_uibusiness_main:getwidget("tab_query/list_category")
    list_category:init(uilistflag.vertical)
    list_category:setclickdelegate(business_query_catalog)

    m_businessquery_root = {}

    local typeweapon = {csvitemtype.weapon_mace, csvitemtype.weapon_dagger, csvitemtype.weapon_sword1, csvitemtype.weapon_sword2,csvitemtype.weapon_polearm, 
                        csvitemtype.weapon_staff, csvitemtype.weapon_bow, csvitemtype.weapon_book, csvitemtype.weapon_orb}
    local weapon = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_WEAPON", typeweapon)
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_MACE", {csvitemtype.weapon_mace})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_DAGGER", {csvitemtype.weapon_dagger})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_SWORD1", {csvitemtype.weapon_sword1})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_SWORD2", {csvitemtype.weapon_sword2})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_POLEARM", {csvitemtype.weapon_polearm})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_STAFF", {csvitemtype.weapon_staff})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_BOW", {csvitemtype.weapon_bow})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_BOOK", {csvitemtype.weapon_book})
    business_query_addcatalogchild(weapon, "TIPS_ITEM_TYPE_WPN_ORB", {csvitemtype.weapon_orb})

    local armor = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_ARMOR", nil)

    local typecosplay = {csvitemtype.cosplay_torso, csvitemtype.cosplay_shoulder, csvitemtype.cosplay_glove, csvitemtype.cosplay_pants, csvitemtype.cosplay_shoes}
    local armorcosplay = business_query_addcatalogchild(armor, "TIPS_ITEM_CATALOG_ARMOR_COSPLAY", typecosplay)
    business_query_addcatalogchild(armorcosplay, "TIPS_ITEM_TYPE_TORSO", {csvitemtype.cosplay_torso})
    business_query_addcatalogchild(armorcosplay, "TIPS_ITEM_TYPE_SHOULDER", {csvitemtype.cosplay_shoulder})
    business_query_addcatalogchild(armorcosplay, "TIPS_ITEM_TYPE_GLOVE", {csvitemtype.cosplay_glove})
    business_query_addcatalogchild(armorcosplay, "TIPS_ITEM_TYPE_PANTS", {csvitemtype.cosplay_pants})
    business_query_addcatalogchild(armorcosplay, "TIPS_ITEM_TYPE_SHOES", {csvitemtype.cosplay_shoes})

    local typeplate = {csvitemtype.plate_torso, csvitemtype.plate_shoulder, csvitemtype.plate_glove, csvitemtype.plate_pants, csvitemtype.plate_shoes}
    local armorplate = business_query_addcatalogchild(armor, "TIPS_ITEM_CATALOG_ARMOR_PLATE", typeplate)
    business_query_addcatalogchild(armorplate, "TIPS_ITEM_TYPE_TORSO", {csvitemtype.plate_torso})
    business_query_addcatalogchild(armorplate, "TIPS_ITEM_TYPE_SHOULDER", {csvitemtype.plate_shoulder})
    business_query_addcatalogchild(armorplate, "TIPS_ITEM_TYPE_GLOVE", {csvitemtype.plate_glove})
    business_query_addcatalogchild(armorplate, "TIPS_ITEM_TYPE_PANTS", {csvitemtype.plate_pants})
    business_query_addcatalogchild(armorplate, "TIPS_ITEM_TYPE_SHOES", {csvitemtype.plate_shoes})
    
    local typechain = {csvitemtype.chain_torso, csvitemtype.chain_shoulder, csvitemtype.chain_glove, csvitemtype.chain_pants, csvitemtype.chain_shoes}
    local armorchain = business_query_addcatalogchild(armor, "TIPS_ITEM_CATALOG_ARMOR_CHAIN", typechain)
    business_query_addcatalogchild(armorchain, "TIPS_ITEM_TYPE_TORSO", {csvitemtype.chain_torso})
    business_query_addcatalogchild(armorchain, "TIPS_ITEM_TYPE_SHOULDER", {csvitemtype.chain_shoulder})
    business_query_addcatalogchild(armorchain, "TIPS_ITEM_TYPE_GLOVE", {csvitemtype.chain_glove})
    business_query_addcatalogchild(armorchain, "TIPS_ITEM_TYPE_PANTS", {csvitemtype.chain_pants})
    business_query_addcatalogchild(armorchain, "TIPS_ITEM_TYPE_SHOES", {csvitemtype.chain_shoes})
    
    local typeleather = {csvitemtype.leather_torso, csvitemtype.leather_shoulder, csvitemtype.leather_glove, csvitemtype.leather_pants, csvitemtype.leather_shoes}
    local armorleather = business_query_addcatalogchild(armor, "TIPS_ITEM_CATALOG_ARMOR_LEATHER", typeleather)
    business_query_addcatalogchild(armorleather, "TIPS_ITEM_TYPE_TORSO", {csvitemtype.leather_torso})
    business_query_addcatalogchild(armorleather, "TIPS_ITEM_TYPE_SHOULDER", {csvitemtype.leather_shoulder})
    business_query_addcatalogchild(armorleather, "TIPS_ITEM_TYPE_GLOVE", {csvitemtype.leather_glove})
    business_query_addcatalogchild(armorleather, "TIPS_ITEM_TYPE_PANTS", {csvitemtype.leather_pants})
    business_query_addcatalogchild(armorleather, "TIPS_ITEM_TYPE_SHOES", {csvitemtype.leather_shoes})

    local typecloth = {csvitemtype.cloth_torso, csvitemtype.cloth_shoulder, csvitemtype.cloth_glove, csvitemtype.cloth_pants, csvitemtype.cloth_shoes}
    local armorcloth = business_query_addcatalogchild(armor, "TIPS_ITEM_CATALOG_ARMOR_CLOTH", typecloth)
    business_query_addcatalogchild(armorcloth, "TIPS_ITEM_TYPE_TORSO", {csvitemtype.cloth_torso})
    business_query_addcatalogchild(armorcloth, "TIPS_ITEM_TYPE_SHOULDER", {csvitemtype.cloth_shoulder})
    business_query_addcatalogchild(armorcloth, "TIPS_ITEM_TYPE_GLOVE", {csvitemtype.cloth_glove})
    business_query_addcatalogchild(armorcloth, "TIPS_ITEM_TYPE_PANTS", {csvitemtype.cloth_pants})
    business_query_addcatalogchild(armorcloth, "TIPS_ITEM_TYPE_SHOES", {csvitemtype.cloth_shoes})

    business_query_addcatalogchild(armor, "TIPS_ITEM_TYPE_WPN_SHIELD", {csvitemtype.weapon_shield})

    local typeaccessory = {csvitemtype.accessory_helmet, csvitemtype.accessory_necklace, csvitemtype.accessory_earring,
                        csvitemtype.accessory_ring, csvitemtype.accessory_belt, csvitemtype.accessory_wing}
    local accessory = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_ACCESSORY", typeaccessory)
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_HELMET", {csvitemtype.accessory_helmet})
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_NECKLACE", {csvitemtype.accessory_necklace})
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_EARRING", {csvitemtype.accessory_earring})
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_RING", {csvitemtype.accessory_ring})
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_BELT", {csvitemtype.accessory_belt})
    business_query_addcatalogchild(accessory, "TIPS_ITEM_TYPE_WING", {csvitemtype.accessory_wing})

    local typeskill = {csvitemtype.skill_book, csvitemtype.skill_stigma}
    local skill = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_SKILL", typeskill)
    business_query_addcatalogchild(skill, "TIPS_ITEM_CATALOG_SKILLBOOK", {csvitemtype.skill_book})
    business_query_addcatalogchild(skill, "TIPS_ITEM_CATALOG_SKILLSTIGAM", {csvitemtype.skill_stigma})

    local typematerial = {csvitemtype.mat_harvest, csvitemtype.mat_harvestod, csvitemtype.mat_loot, csvitemtype.mat_shop, csvitemtype.mat_part}
    local material = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_MATERIAL", typematerial)
    business_query_addcatalogchild(material, "TIPS_ITEM_CATALOG_HARVEST", {csvitemtype.mat_harvest, csvitemtype.mat_harvestod})
    business_query_addcatalogchild(material, "TIPS_ITEM_CATALOG_LOOT", {csvitemtype.mat_loot})
    business_query_addcatalogchild(material, "TIPS_ITEM_CATALOG_PART", {csvitemtype.mat_shop, csvitemtype.mat_part})
    
    local typerecipe = {csvitemtype.recipe_convert, csvitemtype.recipe_weapon, csvitemtype.recipe_armor, csvitemtype.recipe_tailor,
                        csvitemtype.recipe_handiwork, csvitemtype.recipe_alchemy, csvitemtype.recipe_cook}
    local recipe = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_RECIPE", typerecipe)
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_CONVERT", {csvitemtype.recipe_convert})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_WEAPON", {csvitemtype.recipe_weapon})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_ARMOR", {csvitemtype.recipe_armor})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_TAILOR", {csvitemtype.recipe_tailor})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_HANDIWORK", {csvitemtype.recipe_handiwork})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_ALCHEMY", {csvitemtype.recipe_alchemy})
    business_query_addcatalogchild(recipe, "TIPS_ITEM_CATALOG_RECIPE_COOK", {csvitemtype.recipe_cook})

    local typeconsume = {csvitemtype.consume_food, csvitemtype.consume_drink, csvitemtype.consume_potion, csvitemtype.consume_scroll,
                        csvitemtype.consume_gift, csvitemtype.consume_soul, csvitemtype.consume_gem, csvitemtype.consume_god,
                        csvitemtype.consume_qsk, csvitemtype.consume_battery, csvitemtype.consume_charger}
    local consume = business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_CONSUME", typeconsume)
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_FOOD", {csvitemtype.consume_food, csvitemtype.consume_drink})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_POTION", {csvitemtype.consume_potion})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_SCROLL", {csvitemtype.consume_scroll})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_GIFT", {csvitemtype.consume_gift})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_SOUL", {csvitemtype.consume_soul})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_GEM", {csvitemtype.consume_gem})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_GOD", {csvitemtype.consume_god})
    business_query_addcatalogchild(consume, "TIPS_ITEM_TYPE_OTHER", {csvitemtype.consume_qsk, csvitemtype.consume_battery, csvitemtype.consume_charger})

    local type_other = {csvitemtype.none, csvitemtype.normal, csvitemtype.quest, csvitemtype.matter, csvitemtype.key, csvitemtype.medal, csvitemtype.treasure
                    , csvitemtype.consume_petcard, csvitemtype.consume_titlecard, csvitemtype.consume_socialcard, csvitemtype.consume_animcard
                    , csvitemtype.consume_dye, csvitemtype.consume_cosmetic, csvitemtype.weapon_tool1, csvitemtype.weapon_sub, csvitemtype.weapon_tool2}
    business_query_addcatalogchild(nil, "TIPS_ITEM_TYPE_OTHER", type_other)
    business_query_addcatalogchild(nil, "TIPS_ITEM_CATALOG_COIN", {csvitemtype.coin})

    business_query_updatecatalog()
end

function business_query_catalog(line, event, node)
    if node.type ~= nil then
        business_query_setquerycatalog(node.type)
    else
        business_query_setquerynotselect()
    end
    local updatecatalog = false
    if not node.expand then
        if node.parent ~= nil then
            for i=1,#node.parent.sub do
                if node.parent.sub[i].expand then
                    updatecatalog = true
                    node.parent.sub[i].expand = false
                end
            end
        else
            for i=1,#m_businessquery_root do
                if m_businessquery_root[i].expand then
                    updatecatalog = true
                    m_businessquery_root[i].expand = false
                end
            end
        end
    end
    if #node.sub > 0 then
        node.expand = not node.expand
        updatecatalog = true
    end
    if updatecatalog then
        business_query_updatecatalog()
    end
end
