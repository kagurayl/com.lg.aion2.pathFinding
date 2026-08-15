

currency_coin = -1
currency_cash = -2
currency_abyss = -3
currency_cashback = -4

itemid_coin = 182400001
itemid_shard = 141000001
itemid_pincer = 165000001
itemid_abyssrepair = 188030000
itemid_howlciv = 200000002
itemid_howlall = 200000003

charge_level1 = 500000
charge_level2 = 1000000

shopsell_ratio = 5.0

equipslot =
{
    weapon1 = 1,
    weapon2 = 2,
    battery1 = 3,
    battery2 = 4,
    helmet = 5,
    torso = 6,
    pants = 7,
    shoulder = 8,
    glove = 9,
    shoes = 10,
    wing = 11,
    necklace = 12,
    earring1 = 13,
    earring2 = 14,
    ring1 = 15,
    ring2 = 16,
    belt = 17,
}

csvitemdeal =
{
    nodeal = 0,
    deak = 1,
    bindonuse = 2,
    bindontrade = 3,
}

csvitemstorage =
{
    none = 0,
    storage = 1,
    allstorage = 2,
}

csvitemtype =
{
    none = 0,
    coin = 99,

    catalog_other_begin = 100,
    normal = 101,
    quest = 102,
    matter = 103,
    key = 104,
    medal = 105,
    treasure = 106,
    catalog_other_end = 199,

    catalog_consume_begin = 200,
    consume_potion = 201,
    consume_scroll = 202,
    consume_food = 203,
    consume_drink = 204,
    consume_gift = 211,
    consume_soul = 212,
    consume_gem = 213,
    consume_god = 214,
    consume_qsk = 215,
    consume_battery = 216,
    consume_charger = 217,

    consume_petcard = 231,
    consume_titlecard = 232,
    consume_socialcard = 233,
    consume_animcard = 234,

    consume_dye = 241,
    consume_cosmetic = 242,

    catalog_consume_end = 299,

    catalog_skill_begin = 300,
    skill_book = 301,
    skill_stigma = 302,
    catalog_skill_bend = 309,

    catalog_recipe_begin = 310,
    recipe_cook = 311,
    recipe_weapon = 312,
    recipe_armor = 313,
    recipe_tailor = 314,
    recipe_alchemy = 317,
    recipe_handiwork = 318,
    recipe_convert = 319,
    catalog_recipe_end = 399,

    catalog_mat_begin = 400,
    mat_harvest = 401,
    mat_harvestod = 402,
    mat_loot = 411,
    mat_shop = 412,
    mat_part = 413,
    catalog_mat_end = 499,

    isequip = 1000,
    catalog_weapon_begin = 1000,
    weapon_tool1 = 1010,
    weapon_mace = 1011,
    weapon_dagger = 1012,
    weapon_sword1 = 1013,
    weapon_shield = 1014,
    weapon_sub = 1015,
    weapon_tool2 = 1020,
    weapon_sword2 = 1021,
    weapon_polearm = 1022,
    weapon_staff = 1023,
    weapon_bow = 1024,
    weapon_book = 1025,
    weapon_orb = 1026,
    catalog_weapon_end = 1099,

    catalog_accessory_begin = 1100,
    accessory_helmet = 1101,
    accessory_necklace = 1102,
    accessory_earring = 1103,
    accessory_ring = 1104,
    accessory_belt = 1105,
    accessory_wing = 1106,
    catalog_accessory_end = 1199,

    catalog_cosplay_begin = 1200,
    cosplay_torso = 1201,
    cosplay_pants = 1202,
    cosplay_shoulder = 1203,
    cosplay_glove = 1204,
    cosplay_shoes = 1205,
    catalog_cosplay_end = 1299,

    catalog_plate_begin = 1300,
    plate_torso = 1301,
    plate_pants = 1302,
    plate_shoulder = 1303,
    plate_glove = 1304,
    plate_shoes = 1305,
    catalog_plate_end = 1399,

    catalog_chain_begin = 1400,
    chain_torso = 1401,
    chain_pants = 1402,
    chain_shoulder = 1403,
    chain_glove = 1404,
    chain_shoes = 1405,
    catalog_chain_end = 1499,

    catalog_leather_begin = 1500,
    leather_torso = 1501,
    leather_pants = 1502,
    leather_shoulder = 1503,
    leather_glove = 1504,
    leather_shoes = 1505,
    catalog_leather_end = 1599,

    catalog_cloth_begin = 1600,
    cloth_torso = 1601,
    cloth_pants = 1602,
    cloth_shoulder = 1603,
    cloth_glove = 1604,
    cloth_shoes = 1605,
    catalog_cloth_end = 1699,
}

csvitemwaytype =
{
    gift = 1,
    loot = 2,
    shop = 3,
}

csvitemquality =
{
    grey = 0,
    white = 1,
    green = 2,
    blue = 3,
    yellow = 4,
    red = 5,
    purple = 6,
}

local CsvItemColor =
{
    0xadadadff,
    0xf1f1f1ff,
    0x69e15eff,
    0x4ccfffff,
    0xffc103ff,
    0xff8033ff,
    0x800080ff,
}

local equipskinable =
{
    [csvitemtype.cosplay_torso]  = csvitemtype.cosplay_torso,
    [csvitemtype.plate_torso]    = csvitemtype.cosplay_torso,
    [csvitemtype.chain_torso]    = csvitemtype.cosplay_torso,
    [csvitemtype.leather_torso]  = csvitemtype.cosplay_torso,
    [csvitemtype.cloth_torso]    = csvitemtype.cosplay_torso,

    [csvitemtype.cosplay_pants]  = csvitemtype.cosplay_pants,
    [csvitemtype.plate_pants]    = csvitemtype.cosplay_pants,
    [csvitemtype.chain_pants]    = csvitemtype.cosplay_pants,
    [csvitemtype.leather_pants]  = csvitemtype.cosplay_pants,
    [csvitemtype.cloth_pants]    = csvitemtype.cosplay_pants,

    [csvitemtype.cosplay_shoulder] = csvitemtype.cosplay_shoulder,
    [csvitemtype.plate_shoulder]   = csvitemtype.cosplay_shoulder,
    [csvitemtype.chain_shoulder]   = csvitemtype.cosplay_shoulder,
    [csvitemtype.leather_shoulder] = csvitemtype.cosplay_shoulder,
    [csvitemtype.cloth_shoulder]   = csvitemtype.cosplay_shoulder,

    [csvitemtype.cosplay_glove] = csvitemtype.cosplay_glove,
    [csvitemtype.plate_glove]   = csvitemtype.cosplay_glove,
    [csvitemtype.chain_glove]   = csvitemtype.cosplay_glove,
    [csvitemtype.leather_glove] = csvitemtype.cosplay_glove,
    [csvitemtype.cloth_glove]   = csvitemtype.cosplay_glove,

    [csvitemtype.cosplay_shoes] = csvitemtype.cosplay_shoes,
    [csvitemtype.plate_shoes]   = csvitemtype.cosplay_shoes,
    [csvitemtype.chain_shoes]   = csvitemtype.cosplay_shoes,
    [csvitemtype.leather_shoes] = csvitemtype.cosplay_shoes,
    [csvitemtype.cloth_shoes]   = csvitemtype.cosplay_shoes,
}

function csvitem_getfromid(id)
    local config_item = c_config_getmetaid(configid.item_normal, id)
    if config_item == nil then
        config_item = c_config_getmetaid(configid.item_category, id)
        if config_item == nil then
            config_item = c_config_getmetaid(configid.equip_weapon, id)
            if config_item == nil then
                config_item = c_config_getmetaid(configid.equip_armor, id)
            end
        end
    end
    return config_item
end

function csvitem_getallfromsubname(name)
    local item_normal = c_config_getmetasubstring(configid.item_normal, "name", name, 0)
    local item_category = c_config_getmetasubstring(configid.item_category, "name", name, 0)
    local equip_weapon = c_config_getmetasubstring(configid.equip_weapon, "name", name, 0)
    local equip_armor = c_config_getmetasubstring(configid.equip_armor, "name", name, 0)
    item_normal = table.mergearray(item_normal, item_category)
    item_normal = table.mergearray(item_normal, equip_weapon)
    item_normal = table.mergearray(item_normal, equip_armor)
    return item_normal
end

function csvitem_getallfromtype(itemtype)
    local item_normal = c_config_getmetaarray(configid.item_normal, "itemtype", itemtype)
    local item_category = c_config_getmetaarray(configid.item_category, "itemtype", itemtype)
    local equip_weapon = c_config_getmetaarray(configid.equip_weapon, "itemtype", itemtype)
    local equip_armor = c_config_getmetaarray(configid.equip_armor, "itemtype", itemtype)
    item_normal = table.mergearray(item_normal, item_category)
    item_normal = table.mergearray(item_normal, equip_weapon)
    item_normal = table.mergearray(item_normal, equip_armor)
    return item_normal
end

function csvitem_getscript(config_item, type)
    local itemlambda = config_item.lambda
    if itemlambda ~= nil then
        local actioncount = itemlambda.actioncount
        for i=1,actioncount do
            local sublambda = itemlambda[i]
            if c_isaction(sublambda, type) then
                return sublambda
            end
        end
    end
    return nil
end

function csvitem_getdesc(config_item)
    if config_item.desc == "0" then
        return nil
    end
    local itemdesc = ""
    local itemspell = ""
    if string.find(config_item.desc, ";") ~= nil then
        local subdesc = string.split(config_item.desc, ";")
        itemdesc = subdesc[1]
    else
        itemdesc = config_item.desc
    end
    itemdesc = c_textformat(itemdesc)
    local sublambda = csvitem_getscript(config_item, "skill")
    if sublambda ~= nil then
        local config_skill = csvskill_getfromid(sublambda.variable[1].integer)
        if config_skill ~= nil then
            local skilllevel = 1
            if sublambda.variablecount > 1 then
                skilllevel = sublambda.variable[2].integer
            end
            itemdesc = skilltext_getdesc(itemdesc, config_skill, skilllevel, 0)
            if config_item.spell ~= nil and config_item.spell > 0 then
                itemspell = c_textformat("TIPS_SPELLTIME", timerdesc_getdesc(config_item.spell, true, true, true))
            end
            if config_item.cd ~= nil and config_item.cd > 0 then
                itemspell = itemspell .. "\n" .. c_textformat("TIPS_COLDTIME", timerdesc_getdesc(config_item.cd, true, true, true))
            end
        end
    else
        itemdesc = textformat_gettext(itemdesc, textformat_emptydelegate)
    end
    return itemdesc, itemspell
end

function csvitem_getgemlevel(config_item)
    return math.tointegerfloor(config_item.itemlevel / 10) * 10 + 10
end

function csvitem_getgoddesc(config_item)
    if string.find(config_item.desc, ";") ~= nil then
        local subdesc = string.split(config_item.desc, ";")
        return c_textformat(subdesc[2])
    else
        return c_textformat(config_item.desc)
    end
end

function csvitem_gethexcolor(config_item)
    return CsvItemColor[config_item.quality + 1]
end

function csvitem_getqualityfloatcolor(quality)
    return HexRGBA(CsvItemColor[quality + 1])
end

function csvitem_getfloatcolor(config_item)
    return HexRGBA(CsvItemColor[config_item.quality + 1])
end

function csvitem_getcolorname(config_item)
    return string.format("<color=#%08x><%s></color>", csvitem_gethexcolor(config_item), config_item.name)
end

function csvitem_getcolornamefromid(itemid)
    local config_item = csvitem_getfromid(itemid)
    if config_item ~= nil then
        return string.format("<color=#%08x><%s></color>", csvitem_gethexcolor(config_item), config_item.name)
    else
        return string.format("<color=#ffffffff><ITEM_></color>", itemid)
    end
end

function csvitem_isequip(config_item)
    return config_item.itemtype >= csvitemtype.isequip
end

function csvitem_requirebindonuse(item, config_item)
    if csvitem_isequip(config_item) then
        if config_item.deal == csvitemdeal.bindonuse or config_item.deal == csvitemdeal.bindontrade then
            return not equip_isbindonuse(item)
        end
    end
    return false
end

function csvitem_isweapon(config_item)
    return config_item.itemtype >= csvitemtype.catalog_weapon_begin and config_item.itemtype <= csvitemtype.catalog_weapon_end
    and config_item.itemtype ~= csvitemtype.weapon_shield and config_item.itemtype ~= csvitemtype.weapon_sub
end

function csvitem_isshield(config_item)
    return config_item.itemtype == csvitemtype.weapon_shield
end

function csvitem_isaccessory(config_item)
    return config_item.itemtype >= csvitemtype.accessory_necklace and config_item.itemtype <= csvitemtype.accessory_wing
end

function csvitem_isarmor(config_item)
    return config_item.itemtype >= csvitemtype.catalog_cosplay_begin and config_item.itemtype <= csvitemtype.catalog_cloth_end
end

function csvitem_isrecipe(config_item)
    return config_item.itemtype >= csvitemtype.catalog_recipe_begin and config_item.itemtype <= csvitemtype.catalog_recipe_end
end

function csvitem_getplayerlevel(config_item, career)
    if string.find(config_item.playerlevel, ",") then
        local sub = string.split(config_item.playerlevel, ",")
        return string.tointeger(sub[career])
    else
        return string.tointeger(config_item.playerlevel)
    end
end

function csvitem_getsellprice(config_item)
    return math.max(1, math.tointegerfloor(config_item.price / 5))
end

function csvitem_gettypetext(itemtype)
    if itemtype == csvitemtype.normal then
        return "TIPS_ITEM_TYPE_NORMAL"
    elseif itemtype == csvitemtype.quest then
        return "TIPS_ITEM_TYPE_QUEST"
    elseif itemtype == csvitemtype.matter then
        return "TIPS_ITEM_TYPE_ADJUVANT"
    elseif itemtype == csvitemtype.key then
        return "TIPS_ITEM_TYPE_KEY"
    elseif itemtype == csvitemtype.treasure then
        return "TIPS_ITEM_TYPE_TREASURE"
    elseif itemtype == csvitemtype.consume_potion then
        return "TIPS_ITEM_TYPE_POTION"
    elseif itemtype == csvitemtype.consume_scroll then
        return "TIPS_ITEM_TYPE_SCROLL"
    elseif itemtype == csvitemtype.consume_food then
        return "TIPS_ITEM_TYPE_FOOD"
    elseif itemtype == csvitemtype.consume_drink then
        return "TIPS_ITEM_TYPE_DRINK"
    elseif itemtype == csvitemtype.consume_gift then
        return "TIPS_ITEM_TYPE_GIFT"
    elseif itemtype == csvitemtype.consume_soul then
        return "TIPS_ITEM_TYPE_SOUL"
    elseif itemtype == csvitemtype.consume_gem then
        return "TIPS_ITEM_TYPE_GEM"
    elseif itemtype == csvitemtype.consume_god then
        return "TIPS_ITEM_TYPE_GOD"
    elseif itemtype == csvitemtype.consume_qsk then
        return "TIPS_ITEM_TYPE_QSK"
    elseif itemtype == csvitemtype.consume_battery then
        return "TIPS_ITEM_TYPE_BATTERY"
    elseif itemtype == csvitemtype.consume_titlecard or itemtype == csvitemtype.consume_socialcard or itemtype == csvitemtype.consume_animcard then
        return "TIPS_ITEM_TYPE_CARD"
    elseif itemtype == csvitemtype.consume_petcard then
        return "TIPS_ITEM_TYPE_PETCARD"
    elseif itemtype == csvitemtype.consume_dye then
        return "TIPS_ITEM_TYPE_DYE"
    elseif itemtype == csvitemtype.skill_book then
        return "TIPS_ITEM_TYPE_SKILLBOOK"
    elseif itemtype == csvitemtype.skill_stigma then
        return "TIPS_ITEM_TYPE_SKILLSTIGAM"
    elseif itemtype == csvitemtype.recipe_cook or itemtype == csvitemtype.recipe_weapon or itemtype == csvitemtype.recipe_armor
            or itemtype == csvitemtype.recipe_tailor or itemtype == csvitemtype.recipe_alchemy or itemtype == csvitemtype.recipe_handiwork then
        return "TIPS_ITEM_TYPE_RECIPE"
    elseif itemtype == csvitemtype.recipe_convert then
        return "TIPS_ITEM_TYPE_CONVERT"
    elseif itemtype == csvitemtype.mat_harvest or itemtype == csvitemtype.mat_harvestod then
        return "TIPS_ITEM_TYPE_MATHARVEST"
    elseif itemtype == csvitemtype.mat_loot or itemtype == csvitemtype.mat_shop or itemtype == csvitemtype.mat_part then
        return "TIPS_ITEM_TYPE_MATPART"
    elseif itemtype == csvitemtype.weapon_mace then
        return "TIPS_ITEM_TYPE_WPN_MACE"
    elseif itemtype == csvitemtype.weapon_dagger then
        return "TIPS_ITEM_TYPE_WPN_DAGGER"
    elseif itemtype == csvitemtype.weapon_sword1 then
        return "TIPS_ITEM_TYPE_WPN_SWORD1"
    elseif itemtype == csvitemtype.weapon_sword2 then
        return "TIPS_ITEM_TYPE_WPN_SWORD2"
    elseif itemtype == csvitemtype.weapon_shield then
        return "TIPS_ITEM_TYPE_WPN_SHIELD"
    elseif itemtype == csvitemtype.weapon_polearm then
        return "TIPS_ITEM_TYPE_WPN_POLEARM"
    elseif itemtype == csvitemtype.weapon_staff then
        return "TIPS_ITEM_TYPE_WPN_STAFF"
    elseif itemtype == csvitemtype.weapon_bow then
        return "TIPS_ITEM_TYPE_WPN_BOW"
    elseif itemtype == csvitemtype.weapon_book then
        return "TIPS_ITEM_TYPE_WPN_BOOK"
    elseif itemtype == csvitemtype.weapon_orb then
        return "TIPS_ITEM_TYPE_WPN_ORB"
    elseif itemtype == csvitemtype.accessory_helmet then
        return "TIPS_ITEM_TYPE_HELMET"
    elseif itemtype == csvitemtype.accessory_necklace then
        return "TIPS_ITEM_TYPE_NECKLACE"
    elseif itemtype == csvitemtype.accessory_earring then
        return "TIPS_ITEM_TYPE_EARRING"
    elseif itemtype == csvitemtype.accessory_ring then
        return "TIPS_ITEM_TYPE_RING"
    elseif itemtype == csvitemtype.accessory_belt then
        return "TIPS_ITEM_TYPE_BELT"
    elseif itemtype == csvitemtype.accessory_wing then
        return "TIPS_ITEM_TYPE_WING"
    elseif itemtype == csvitemtype.cosplay_torso
        or itemtype == csvitemtype.plate_torso
        or itemtype == csvitemtype.chain_torso
        or itemtype == csvitemtype.leather_torso
        or itemtype == csvitemtype.cloth_torso then
            return "TIPS_ITEM_TYPE_TORSO"
    elseif itemtype == csvitemtype.cosplay_pants
        or itemtype == csvitemtype.plate_pants
        or itemtype == csvitemtype.chain_pants
        or itemtype == csvitemtype.leather_pants
        or itemtype == csvitemtype.cloth_pants then
            return "TIPS_ITEM_TYPE_PANTS"
    elseif itemtype == csvitemtype.cosplay_shoulder
        or itemtype == csvitemtype.plate_shoulder
        or itemtype == csvitemtype.chain_shoulder
        or itemtype == csvitemtype.leather_shoulder
        or itemtype == csvitemtype.cloth_shoulder then
            return "TIPS_ITEM_TYPE_SHOULDER"
    elseif itemtype == csvitemtype.cosplay_glove
        or itemtype == csvitemtype.plate_glove
        or itemtype == csvitemtype.chain_glove
        or itemtype == csvitemtype.leather_glove
        or itemtype == csvitemtype.cloth_glove then
            return "TIPS_ITEM_TYPE_GLOVE"
    elseif itemtype == csvitemtype.cosplay_shoes
        or itemtype == csvitemtype.plate_shoes
        or itemtype == csvitemtype.chain_shoes
        or itemtype == csvitemtype.leather_shoes
        or itemtype == csvitemtype.cloth_shoes then
            return "TIPS_ITEM_TYPE_SHOES"
    end
    return "TIPS_ITEM_TYPE_NORMAL"
end

function csvitem_getequipslot(config_item)
    if config_item == nil then
        return
    end
    
    if config_item.itemtype == csvitemtype.cosplay_torso
    or config_item.itemtype == csvitemtype.plate_torso
    or config_item.itemtype == csvitemtype.chain_torso
    or config_item.itemtype == csvitemtype.leather_torso
    or config_item.itemtype == csvitemtype.cloth_torso then
        return equipslot.torso
    elseif config_item.itemtype == csvitemtype.cosplay_pants
    or config_item.itemtype == csvitemtype.plate_pants
    or config_item.itemtype == csvitemtype.chain_pants
    or config_item.itemtype == csvitemtype.leather_pants
    or config_item.itemtype == csvitemtype.cloth_pants then
        return equipslot.pants
    elseif config_item.itemtype == csvitemtype.cosplay_shoulder
    or config_item.itemtype == csvitemtype.plate_shoulder
    or config_item.itemtype == csvitemtype.chain_shoulder
    or config_item.itemtype == csvitemtype.leather_shoulder
    or config_item.itemtype == csvitemtype.cloth_shoulder then
        return equipslot.shoulder
    elseif config_item.itemtype == csvitemtype.cosplay_glove
    or config_item.itemtype == csvitemtype.plate_glove
    or config_item.itemtype == csvitemtype.chain_glove
    or config_item.itemtype == csvitemtype.leather_glove
    or config_item.itemtype == csvitemtype.cloth_glove then
        return equipslot.glove
    elseif config_item.itemtype == csvitemtype.cosplay_shoes
    or config_item.itemtype == csvitemtype.plate_shoes
    or config_item.itemtype == csvitemtype.chain_shoes
    or config_item.itemtype == csvitemtype.leather_shoes
    or config_item.itemtype == csvitemtype.cloth_shoes then
        return equipslot.shoes
    elseif config_item.itemtype == csvitemtype.accessory_wing then
        return equipslot.wing
    elseif config_item.itemtype == csvitemtype.accessory_helmet then
        return equipslot.helmet
    elseif config_item.itemtype == csvitemtype.accessory_necklace then
        return equipslot.necklace
    elseif config_item.itemtype == csvitemtype.accessory_earring then
        return equipslot.earring1
    elseif config_item.itemtype == csvitemtype.accessory_ring then
        return equipslot.ring1
    elseif config_item.itemtype == csvitemtype.accessory_belt then
        return equipslot.belt
    elseif config_item.itemtype == csvitemtype.weapon_tool1
    or config_item.itemtype == csvitemtype.weapon_mace
    or config_item.itemtype == csvitemtype.weapon_dagger
    or config_item.itemtype == csvitemtype.weapon_sword1 then
        return equipslot.weapon1
    elseif config_item.itemtype == csvitemtype.weapon_shield then
        return equipslot.weapon2
    elseif config_item.itemtype == csvitemtype.weapon_tool2
    or config_item.itemtype == csvitemtype.weapon_sword2
    or config_item.itemtype == csvitemtype.weapon_polearm
    or config_item.itemtype == csvitemtype.weapon_staff
    or config_item.itemtype == csvitemtype.weapon_bow
    or config_item.itemtype == csvitemtype.weapon_book
    or config_item.itemtype == csvitemtype.weapon_orb then
        return equipslot.weapon1
    end
end

function csvitem_getequipslotex(config_item)
    local weapontype = config_item.itemtype
    if weapontype == csvitemtype.weapon_tool2
    or weapontype == csvitemtype.weapon_sword2
    or weapontype == csvitemtype.weapon_polearm
    or weapontype == csvitemtype.weapon_staff
    or weapontype == csvitemtype.weapon_bow
    or weapontype == csvitemtype.weapon_book
    or weapontype == csvitemtype.weapon_orb then
        return true
    end
    return false
end

function csvitem_consumeable(sublambda)
     if c_isaction(sublambda, "skill") or c_isaction(sublambda, "qsk")
        or c_isaction(sublambda, "addquest") or c_isaction(sublambda, "addskill")
        or c_isaction(sublambda, "addrecipe") or c_isaction(sublambda, "script")
        or c_isaction(sublambda, "addsocial") or c_isaction(sublambda, "animcard")
        or c_isaction(sublambda, "bagspace") or c_isaction(sublambda, "storagespace")
        or c_isaction(sublambda, "vfx") or c_isaction(sublambda, "addtitle")
        or c_isaction(sublambda, "resetdungeon") then
            return true
    end
    if c_isaction(sublambda, "charge") and sublambda.variable[1].integer == 1 then
        return true
    end
    return false
end

function csvitem_getdyecolor(itemid)
    if itemid == 0 then
        return nil
    end
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return nil
    end
    return csvitem_getdyecolorfromconfig(config_item)
end

function csvitem_getdyecolorfromconfig(config_item)
    local lambda = csvitem_getscript(config_item, "dye")
    if lambda ~= nil then
        local dyecolor = lambda.variable[1].hex
        if dyecolor ~= nil then
            return dyecolor
        end
        return 0xffffff
    end
    return 0xffffff
end

function csvitem_getskinable(equiptype, skintype)
    if equiptype ~= skintype then
        local skintypedesc = equipskinable[skintype]
        local equiptypedesc = equipskinable[equiptype]
        return skintypedesc ~= nil and equiptypedesc ~= nil and skintypedesc == equiptypedesc
    end
    return true
end
