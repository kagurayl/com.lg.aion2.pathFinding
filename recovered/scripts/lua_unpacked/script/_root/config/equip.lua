
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

local EquipAttrText = 
{
    {name = "attackspeed", text = "TIPS_ATTR_ATTACKSPEED"},
    {name = "hpmax", text = "TIPS_ATTR_HPMAX"},
    {name = "hpregen", text = "TIPS_ATTR_HPREGEN"},
    {name = "mpmax", text = "TIPS_ATTR_MPMAX"},
    {name = "mpregen", text = "TIPS_ATTR_MPREGEN"},
    {name = "mpcost", text = "TIPS_ATTR_MPCOST"},
    {name = "fpmax", text = "TIPS_ATTR_FPMAX"},
    {name = "dpmax", text = "TIPS_ATTR_DPMAX"},
    {name = "movespeed", text = "TIPS_ATTR_MOVESPEED"},
    {name = "flyspeed", text = "TIPS_ATTR_FLYSPEED"},
    {name = "heal", text = "TIPS_ATTR_HEAL"},
    {name = "threat", text = "TIPS_ATTR_THREAT"},
    {name = "stability", text = "TIPS_ATTR_STABILITY"},
    {name = "pvpdamage", text = "TIPS_ATTR_PVPDAMAGE"},
    {name = "pvpdefense", text = "TIPS_ATTR_PVPDEFENSE"},
    
    {name = "phydamage", text = "TIPS_ATTR_PHYDAMAGE"},
    {name = "phyaccuracy", text = "TIPS_ATTR_PHYACCURACY"},
    {name = "phycritrate", text = "TIPS_ATTR_PHYCRITRATE"},
    {name = "phycritresist", text = "TIPS_ATTR_PHYCRITRESIST"},
    {name = "phycritdefense", text = "TIPS_ATTR_PHYCRITDEFENSE"},
    {name = "phydefense", text = "TIPS_ATTR_PHYDEFENSE"},
    {name = "phydodge", text = "TIPS_ATTR_PHYDODGE"},
    {name = "phyparry", text = "TIPS_ATTR_PHYPARRY"},
    {name = "phyblock", text = "TIPS_ATTR_PHYBLOCK"},
    {name = "phyblockreduce", text = "TIPS_ATTR_PHYBLOCKREDUCE"},

    {name = "magspeed", text = "TIPS_ATTR_MAGSPEED"},
    {name = "magconcent", text = "TIPS_ATTR_MAGCONCENT"},
    {name = "magdamage", text = "TIPS_ATTR_MAGDAMAGE"},
    {name = "magboost", text = "TIPS_ATTR_MAGBOOST"},
    {name = "magaccuracy", text = "TIPS_ATTR_MAGACCURACY"},
    {name = "magcritrate", text = "TIPS_ATTR_MAGCRITRATE"},
    {name = "magcritresist", text = "TIPS_ATTR_MAGCRITRESIST"},
    {name = "magcritdefense", text = "TIPS_ATTR_MAGCRITDEFENSE"},
    {name = "magresist", text = "TIPS_ATTR_MAGRESIST"},
    {name = "magdefense", text = "TIPS_ATTR_MAGDEFENSE"},
    {name = "magearthdefense", text = "TIPS_ATTR_MAGEARTHDEFENSE"},
    {name = "magwaterdefense", text = "TIPS_ATTR_MAGWATERDEFENSE"},
    {name = "magfiredefense", text = "TIPS_ATTR_MAGFIREDEFENSE"},
    {name = "magwinddefense", text = "TIPS_ATTR_MAGWINDDEFENSE"},

    {name = "all_ar", text = "TIPS_ATTR_ALL_AR"},
    {name = "all_arp", text = "TIPS_ATTR_ALL_ARP"},
    {name = "stunlike_ar", text = "TIPS_ATTR_STUNLIKE_AR"},
    {name = "stunlike_ar", text = "TIPS_ATTR_STUNLIKE_ARP"},
    {name = "paralyze_ar", text = "TIPS_ATTR_PARALYZE_AR"},
    {name = "paralyze_arp", text = "TIPS_ATTR_PARALYZE_ARP"},
    {name = "petrification_ar", text = "TIPS_ATTR_PETRIFICATION_AR"},
    {name = "petrification_arp", text = "TIPS_ATTR_PETRIFICATION_ARP"},
    {name = "stumble_ar", text = "TIPS_ATTR_STUMBLE_AR"},
    {name = "stumble_arp", text = "TIPS_ATTR_STUMBLE_ARP"},
    {name = "stun_ar", text = "TIPS_ATTR_STUN_AR"},
    {name = "stun_arp", text = "TIPS_ATTR_STUN_ARP"},
    {name = "stagger_ar", text = "TIPS_ATTR_STAGGER_AR"},
    {name = "stagger_arp", text = "TIPS_ATTR_STAGGER_ARP"},
    {name = "spin_ar", text = "TIPS_ATTR_SPIN_AR"},
    {name = "spin_arp", text = "TIPS_ATTR_SPIN_ARP"},
    {name = "openaerial_ar", text = "TIPS_ATTR_OPENAERIAL_AR"},
    {name = "openaerial_arp", text = "TIPS_ATTR_OPENAERIAL_ARP"},
    {name = "deform_ar", text = "TIPS_ATTR_DEFORM_AR"},
    {name = "deform_arp", text = "TIPS_ATTR_DEFORM_ARP"},
    {name = "charm_ar", text = "TIPS_ATTR_CHARM_AR"},
    {name = "charm_arp", text = "TIPS_ATTR_CHARM_ARP"},
    {name = "fear_ar", text = "TIPS_ATTR_FEAR_AR"},
    {name = "fear_arp", text = "TIPS_ATTR_FEAR_ARP"},
    {name = "confuse_ar", text = "TIPS_ATTR_CONFUSE_AR"},
    {name = "confuse_arp", text = "TIPS_ATTR_CONFUSE_ARP"},
    {name = "sleep_ar", text = "TIPS_ATTR_SLEEP_AR"},
    {name = "sleep_arp", text = "TIPS_ATTR_SLEEP_ARP"},
    {name = "silence_ar", text = "TIPS_ATTR_SILENCE_AR"},
    {name = "silence_arp", text = "TIPS_ATTR_SILENCE_ARP"},
    {name = "bind_ar", text = "TIPS_ATTR_BIND_AR"},
    {name = "bind_arp", text = "TIPS_ATTR_BIND_ARP"},
    {name = "root_ar", text = "TIPS_ATTR_ROOT_AR"},
    {name = "root_arp", text = "TIPS_ATTR_ROOT_ARP"},
    {name = "snare_ar", text = "TIPS_ATTR_SNARE_AR"},
    {name = "snare_arp", text = "TIPS_ATTR_SNARE_ARP"},
    {name = "slow_ar", text = "TIPS_ATTR_SLOW_AR"},
    {name = "slow_arp", text = "TIPS_ATTR_SLOW_ARP"},
    {name = "blind_ar", text = "TIPS_ATTR_BLIND_AR"},
    {name = "blind_arp", text = "TIPS_ATTR_BLIND_ARP"},
    {name = "poison_ar", text = "TIPS_ATTR_POISON_AR"},
    {name = "poison_arp", text = "TIPS_ATTR_POISON_ARP"},
    {name = "bleed_ar", text = "TIPS_ATTR_BLEED_AR"},
    {name = "bleed_arp", text = "TIPS_ATTR_BLEED_ARP"},
    {name = "disease_ar", text = "TIPS_ATTR_DISEASE_AR"},
    {name = "disease_arp", text = "TIPS_ATTR_DISEASE_ARP"},
    {name = "curse_ar", text = "TIPS_ATTR_CURSE_AR"},
    {name = "curse_arp", text = "TIPS_ATTR_CURSE_ARP"},
}

function equip_getattrtext(name)
    for i=1,#EquipAttrText do
        if EquipAttrText[i].name == name then
            return EquipAttrText[i].text
        end
    end
    return nil
end

function equip_parseattr(strattr)
    if strattr == "0" then
        return nil
    end
    local strsubattr = string.split(strattr, ";")
    local attrarray = {}
    for i=1, #strsubattr do
        local str = string.split(strsubattr[i], "=")
        attrarray[i] = {name = str[1], val = str[2]}
    end
    
    local sortarray = {}
    for attrindex=1,#EquipAttrText do
        local attrtext = EquipAttrText[attrindex]
        for i=1, #attrarray do
            if attrarray[i].name == attrtext.name then
                attrarray[i].text = attrtext.text
                sortarray[#sortarray + 1] = attrarray[i]
                table.remove(attrarray, i)
                break
            end
        end
    end
    for i=1, #attrarray do
        sortarray[#sortarray + 1] = attrarray[i]
    end
    return sortarray
end

function equip_getrequireskill(config_item)
    local requireaction = nil
    local typetext = nil
    if config_item.itemtype == csvitemtype.weapon_mace then
        requireaction = "wpn_mace"
        typetext = "TIPS_ITEM_TYPE_WPN_MACE"
    elseif config_item.itemtype == csvitemtype.weapon_dagger then
        requireaction = "wpn_dagger"
        typetext = "TIPS_ITEM_TYPE_WPN_DAGGER"
    elseif config_item.itemtype == csvitemtype.weapon_sword1 then
        requireaction = "wpn_sword1"
        typetext = "TIPS_ITEM_TYPE_WPN_SWORD1"
    elseif config_item.itemtype == csvitemtype.weapon_shield then
        requireaction = "wpn_shield"
        typetext = "TIPS_ITEM_TYPE_WPN_SHIELD"
    elseif config_item.itemtype == csvitemtype.weapon_sword2 then
        requireaction = "wpn_sword2"
        typetext = "TIPS_ITEM_TYPE_WPN_SWORD2"
    elseif config_item.itemtype == csvitemtype.weapon_polearm then
        requireaction = "wpn_polearm"
        typetext = "TIPS_ITEM_TYPE_WPN_POLEARM"
    elseif config_item.itemtype == csvitemtype.weapon_staff then
        requireaction = "wpn_staff"
        typetext = "TIPS_ITEM_TYPE_WPN_STAFF"
    elseif config_item.itemtype == csvitemtype.weapon_bow then
        requireaction = "wpn_bow"
        typetext = "TIPS_ITEM_TYPE_WPN_BOW"
    elseif config_item.itemtype == csvitemtype.weapon_book then
        requireaction = "wpn_book"
        typetext = "TIPS_ITEM_TYPE_WPN_BOOK"
    elseif config_item.itemtype == csvitemtype.weapon_orb then
        requireaction = "wpn_orb"
        typetext = "TIPS_ITEM_TYPE_WPN_ORB"
    elseif config_item.itemtype >= csvitemtype.catalog_plate_begin and config_item.itemtype <= csvitemtype.catalog_plate_end then
        requireaction = "amr_plate"
        typetext = "TIPS_ITEM_TYPE_AMR_PLATE"
    elseif config_item.itemtype >= csvitemtype.catalog_chain_begin and config_item.itemtype <= csvitemtype.catalog_chain_end then
        requireaction = "amr_chain"
        typetext = "TIPS_ITEM_TYPE_AMR_CHAIN"
    elseif config_item.itemtype >= csvitemtype.catalog_leather_begin and config_item.itemtype <= csvitemtype.catalog_leather_end then
        requireaction = "amr_leather"
        typetext = "TIPS_ITEM_TYPE_AMR_LEATHER"
    elseif config_item.itemtype >= csvitemtype.catalog_cloth_begin and config_item.itemtype <= csvitemtype.catalog_cloth_end then
        requireaction = "amr_cloth"
        typetext = "TIPS_ITEM_TYPE_AMR_CLOTH"
    elseif config_item.itemtype >= csvitemtype.catalog_cosplay_begin and config_item.itemtype <= csvitemtype.catalog_cosplay_end then
        requireaction = "amr_cosplay"
        typetext = "TIPS_ITEM_TYPE_AMR_COSPLAY"
    end
    if requireaction == nil then
        return true, nil
    end
    local available = false
    for key, val in pairs(playerattr_skill) do
        local config_skill = csvskill_getfromid(key)
        if config_skill ~= nil and config_skill.spellway == csvskillspellway.passive then
            local config_skillbuff = csvskillbuff_getfromid(config_skill.id)
            if config_skillbuff ~= nil and config_skillbuff.lambda ~= nil then
                local lambda = config_skillbuff.lambda
                local arraycount = lambda.arraysize
                for i=1,arraycount do
                    local lambda2 = lambda.lambdaarray[i]
                    local actioncount = lambda2.actioncount
                    for j=1,actioncount do
                        local sublambda = lambda2[j]
                        if c_isaction(sublambda, requireaction) then
                            available = true
                            break
                        end
                    end
                    if available then
                        break
                    end
                end
            end
        end
        if available then
            break
        end
	end
    return available, typetext
end

local function equip_updateequipscript(itemid)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    local script = config_item.lambda
    if script == nil then
        return
    end
    local actioncount = script.actioncount
    for i=1,actioncount do
        local sublambda = script[i]
        if c_isaction(sublambda, "harvest") then
            local currentlevel = minimap_gettraceharvest()
            minimap_settraceharvest(math.max(currentlevel, sublambda.variable[1].integer))
        end
    end
end
function equip_updatescript()
    minimap_settraceharvest(0)
    local equipactive, equipsecondard = playeritem_getactiveequip()
	for i=1, #equipactive do
        if equipactive[i].itemid ~= 0 then
            equip_updateequipscript(equipactive[i].itemid)
        end
        if equipsecondard[i].itemid ~= 0 then
            equip_updateequipscript(equipsecondard[i].itemid)
        end
	end
    actormanager_updateharvesticon()
end

function equip_isbindonuse(equip)
    return equip.bindtime ~= nil and equip.bindtime > 0
end

function equip_isbindontrade(equip)
    return equip.bindtime ~= nil and equip.bindtime < 0
end

function equip_getgemcount(gem)
    local gemcount = 0
    local gemmmax = 0
    if gem ~= nil then
        gemmmax = #gem
        for i=1,gemmmax do
            if gem[i] ~= 0 then
                gemcount = gemcount + 1
            end
        end
    end
    return gemcount, gemmmax
end

function equip_setchargeprogress(progress_level1, progress_level2, capacity)
    local percent1 = 0
    local percent2 = 0
    if capacity > 0 then
        percent1 = math.clamp(capacity / charge_level1, 0.0, 1.0)
        percent2 = math.clamp((capacity - charge_level1) / (charge_level2 - charge_level1), 0.0, 1.0)
    end
    progress_level1:setpercent(percent1)
    progress_level2:setpercent(percent2)
end
