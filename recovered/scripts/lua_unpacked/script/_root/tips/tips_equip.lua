
local function tips_equip_getattr(attrarray, name)
    for i=1,#attrarray do
        if attrarray[i].name == name then
            return attrarray[i].val
        end
    end
    return nil
end

local function tips_equip_getextra(attrextra, name, remove)
    for i=1,#attrextra do
        if attrextra[i].name == name then
            local val = attrextra[i].val
            if remove then
                table.remove(attrextra, i)
            end
            return val
        end
    end
    return nil
end

local function tips_equip_getnumberval(str)
    local valnumber = 0
    local ispercent, valstr = string.endwith2(str, "%")
    if ispercent then
        valnumber = tonumber(valstr)
    else
        valnumber = tonumber(str)
    end
    if valnumber == nil then
        valnumber = 0
    end
    return valnumber
end

local function tips_equip_weapondamage(config_item, attrarray, attrextra, attrcompondmain)
    local damagemin = tips_equip_getattr(attrarray, "damagemin")
    local damagemax = tips_equip_getattr(attrarray, "damagemax")
    if damagemin ~= nil and damagemax ~= nil then
        local additivedamage = 0
        local attr = damagemin .. "-" .. damagemax
        if attrextra ~= nil then
            local soulweapondamagemin = tips_equip_getextra(attrextra, "damagemin", true)
            local soulweapondamagemax = tips_equip_getextra(attrextra, "damagemax", true)
            if soulweapondamagemin ~= nil then
                additivedamage = soulweapondamagemin
            end
        end
        if attrcompondmain ~= nil then
            local componddamagemin = tips_equip_getextra(attrcompondmain, "damagemin", true)
            local componddamagemax = tips_equip_getextra(attrcompondmain, "damagemax", true)
            if componddamagemin ~= nil then
                additivedamage = additivedamage + (componddamagemin + componddamagemax) * 0.05
            end
        end
        additivedamage = math.tointegerfloor(additivedamage)
        if additivedamage > 0 then
            attr = attr .. string.format(" (+%d)", additivedamage)
        end
        tips_addattr1("TIPS_ATTR_WEAPONDAMAGE", attr, TIPS_COLOR_WHITE, 0)
    end
    local accuracy = tips_equip_getattr(attrarray, "accuracy")
    if accuracy ~= nil then
        tips_addattr1("TIPS_ATTR_ACCURACY", accuracy, TIPS_COLOR_WHITE, 0)
    end
    if config_item.attackdelay ~= nil then
        tips_addattr1("TIPS_ATTR_ATTACKDELAY", string.format("%.1f", config_item.attackdelay), TIPS_COLOR_WHITE, 0)
    end
end

local function tips_equip_attr(attrarray, availablecolor, flag)
    local name1, val1
    local setattr2 = false
    local color = math.ternary(bit.band(flag, tipsflag.available) ~= 0, availablecolor, TIPS_COLOR_GREY)
    if attrarray ~= nil then
        for tipsattrindex=1,#attrarray do
            local attrval = attrarray[tipsattrindex]
            if attrval.text ~= nil then
                if setattr2 then
                    tips_addattr2(name1, val1, attrval.text, attrval.val, color, color, flag)
                    setattr2 = false
                else
                    name1 = attrval.text
                    val1 = attrval.val
                    setattr2 = true
                end
            end
        end
    end
    if setattr2 then
        tips_addattr2(name1, val1, nil, nil, color, color, flag)
    end
end

local function tips_equip_attrextra(attrarray, attrextra, attrcompond, availablecolor, flag)
    local name1, val1
    local setattr2 = false
    local color = math.ternary(bit.band(flag, tipsflag.available) ~= 0, availablecolor, TIPS_COLOR_GREY)
    local color1 = color
    local color2 = color
    if attrarray ~= nil then
        for tipsattrindex=1,#attrarray do
            local attrval = attrarray[tipsattrindex]
            if attrval.text ~= nil then
                if attrextra ~= nil then
                    local extraval = tips_equip_getextra(attrextra, attrval.name, true)
                    if extraval ~= nil then
                        attrval.val = attrval.val .. string.format("(+%s)", extraval)
                    end
                end
                if attrcompond ~= nil then
                    if bit.band(flag, tipsflag.attrmain) ~= 0 then
                        if attrval.name == "magboost" then
                            local compondmagboost = tips_equip_getextra(attrcompond, "magboost", true)
                            if compondmagboost ~= nil then
                                compondmagboost = math.tointegerfloor(compondmagboost * 0.1)
                                if compondmagboost > 0 then
                                    attrval.val = attrval.val .. string.format("(+%d)", compondmagboost)
                                end
                            end
                        end
                    elseif bit.band(flag, tipsflag.attrbonus) ~= 0 or bit.band(flag, tipsflag.attrcompond) ~= 0 then
                        if attrval.name == "attackspeed" or attrval.name == "magspeed" or attrval.name == "pvpdamage" or attrval.name == "pvpdefense" then
                            local compondattr = tips_equip_getextra(attrcompond, attrval.name, false)
                            if compondattr ~= nil then
                                local enable = true
                                if bit.band(flag, tipsflag.attrbonus) ~= 0 then
                                    enable = tips_equip_getnumberval(attrval.val) >= tips_equip_getnumberval(compondattr)
                                else
                                    enable = tips_equip_getnumberval(attrval.val) > tips_equip_getnumberval(compondattr)
                                end
                                if not enable then
                                    if setattr2 then
                                        color2 = TIPS_COLOR_GREY
                                    else
                                        color1 = TIPS_COLOR_GREY
                                    end
                                end
                            end
                        end
                    end
                end
                if setattr2 then
                    tips_addattr2(name1, val1, attrval.text, attrval.val, color1, color2, flag)
                    setattr2 = false
                    color1 = color
                    color2 = color
                else
                    name1 = attrval.text
                    val1 = attrval.val
                    setattr2 = true
                end
            end
        end
    end
    if attrextra ~= nil then
        for tipsattrindex=1,#attrextra do
            local extraval = attrextra[tipsattrindex]
            if extraval.text ~= nil then
                if setattr2 then
                    tips_addattr2(name1, val1, extraval.text, extraval.val, color, color, flag)
                    setattr2 = false
                else
                    name1 = extraval.text
                    val1 = extraval.val
                    setattr2 = true
                end
            end
        end
        table.cleararray(attrextra)
    end
    if setattr2 then
        tips_addattr2(name1, val1, nil, nil, color, color, flag)
    end
end

local function tips_equip_gem(gem)
    local gem1 = nil
    for i=1,#gem do
        local gemid = gem[i]
        if gem1 ~= nil then
            tips_addgem(gem1, gemid)
            gem1 = nil
        else
            gem1 = gemid
        end
    end
    if gem1 ~= nil then
        tips_addgem(gem1, nil)
    end
end

local function tips_equip_compound(config_item, extra, attrcompondbonus)
    local config_compound = csvitem_getfromid(extra.compound)
    if config_compound == nil then
        return
    end
    tips_addsplit()
    tips_adddesc(c_textformat("TIPS_ITEM_COMPOSE", config_compound.name), TIPS_COLOR_DESC)
    local attrarray = equip_parseattr(config_item.attrbonus)
    if attrcompondbonus ~= nil then
        tips_equip_attrextra(attrcompondbonus, nil, attrarray, TIPS_COLOR_WHITE, bit.bor(tipsflag.available, tipsflag.attrcompond))
    end
    if config_compound.gem ~= nil and config_compound.gem > 0 then
        tips_adddesc(c_textformat("TIPS_ITEM_EQUIPGEMLEVEL", math.tointegerfloor(config_compound.itemlevel / 10) * 10 + 10), TIPS_COLOR_DESC)
    end
    if extra.subgem ~= nil and #extra.subgem > 0 then
        tips_equip_gem(extra.subgem)
    end
end

local function tips_equip_gemhole(config_item)
    local gem1 = nil
    local holecount = config_item.gem or 0
    for i=1,holecount do
        if gem1 ~= nil then
            tips_addgem(0, 0)
            gem1 = nil
        else
            gem1 = 0
        end
    end
    if gem1 ~= nil then
        tips_addgem(0, nil)
    end
end

local function tips_equip_requireskill(config_item)
    local available, typetext = equip_getrequireskill(config_item)
    if typetext ~= nil then
        local text = c_textformat("TIPS_ITEM_EQUIPSKILL", typetext)
        if available then
            tips_adddesc(text, TIPS_COLOR_DESC)
        else
            tips_adddesc(text, TIPS_COLOR_RED)
        end
    end
end

local function tips_addequipchargeattr(config_item, capacity, iscompond)
    local chargelevel = csvconfig_getsubvalue(config_item.charge, 1, configsubtype.int)
    local currentlevel = 0
    if capacity > charge_level1 then
        currentlevel = 2
    elseif capacity > 0 then
        currentlevel = 1
    end
    local textkeylevel = math.ternary(iscompond, "TIPS_ITEM_CHARGE_COMPONDLEVEL", "TIPS_ITEM_CHARGE_LEVEL")
    local textkeyattr = math.ternary(iscompond, "TIPS_ITEM_CHARGE_COMPONDATTR", "TIPS_ITEM_CHARGE_ATTR")
    local textlevel = c_textformat(textkeylevel, currentlevel, chargelevel)
    tips_adddesc(textlevel, TIPS_COLOR_DESC)
    tips_addchargeprogress(capacity)

    local attrcharge1 = equip_parseattr(config_item.attrcharge1)
    if attrcharge1 ~= nil then
        local available = capacity > 0
        local flag = 0
        if available then
            flag = tipsflag.available
            tips_adddesc(c_textformat(textkeyattr, 1), TIPS_COLOR_DESC)
        else
            tips_adddesc(c_textformat(textkeyattr, 1), TIPS_COLOR_GREY)
        end
        tips_equip_attr(attrcharge1, TIPS_COLOR_WHITE, flag)
    end

    if chargelevel > 1 then
        local attrcharge2 = equip_parseattr(config_item.attrcharge2)
        if attrcharge2 ~= nil then
            local available = capacity > charge_level1
            local flag = 0
            if available then
                flag = tipsflag.available
                tips_adddesc(c_textformat(textkeyattr, 2), TIPS_COLOR_DESC)
            else
                tips_adddesc(c_textformat(textkeyattr, 2), TIPS_COLOR_GREY)
            end
            tips_equip_attr(attrcharge2, TIPS_COLOR_WHITE, flag)
        end
    end
end
local function tips_addequipcharge(config_item, extra)
    local addsplit = true
    local capacity = 0
    local subcapacity = 0
    if extra ~= nil and extra.capacity ~= nil then
        capacity = extra.capacity
        subcapacity = extra.subcapacity
    end
    if config_item.charge ~= nil and config_item.charge ~= "0" then
        addsplit = false
        tips_addsplit()
        tips_addequipchargeattr(config_item, capacity, false)
    end
    if extra ~= nil and extra.compound ~= nil and extra.compound > 0 then
        local config_compound = csvitem_getfromid(extra.compound)
        if config_compound ~= nil and config_compound.charge ~= nil and config_compound.charge ~= "0" then
            if addsplit then
                tips_addsplit()
            end
            tips_addequipchargeattr(config_compound, subcapacity, true)
        end
    end
end

local function tips_addequipitemsetattr(strdesc, strattr, equipsubcount, requirecount, coloritem)
    if strattr ~= "0" then
        local attrarray = equip_parseattr(strattr)
        if attrarray ~= nil then
            tips_adddesc(strdesc, math.ternary(equipsubcount >= requirecount, coloritem, TIPS_COLOR_GREY))
            local flag = 0
            if equipsubcount >= requirecount then
                flag = tipsflag.available
            end
            tips_equip_attr(attrarray, coloritem, bit.bor(flag, tipsflag.addspace))
        end
    end
end
local function tips_addequipitemset(config_item, extra)
    local config_itemset = csvitemset_getfromitemid(config_item.id)
    if config_itemset == nil or #config_itemset == 0 then
        return
    end
    config_itemset = config_itemset[1]
    
    local subid = string.splitnumber(config_itemset.item, ",")
    local equipsubcount = 0
    local activeequip = playeritem_getactiveequip()
    for i=1,#subid do
        for j=1, #activeequip do
            if activeequip[j].itemid == subid[i] then
                equipsubcount = equipsubcount + 1
                break
            end
        end
    end
    local descall = string.format("%s(%d/%d)", config_itemset.name, equipsubcount, #subid)
    local coloritem = csvitem_gethexcolor(config_item)
    tips_adddesc(descall, math.ternary(equipsubcount >= #subid, coloritem, TIPS_COLOR_GREY))
    for i=1,#subid do
        local config_subitem = csvitem_getfromid(subid[i])
        if config_subitem ~= nil then
            local color = TIPS_COLOR_GREY
            for j=1, #activeequip do
                if activeequip[j].itemid == subid[i] then
                    color = coloritem
                    break
                end
            end
            tips_adddesc(TipsAttrSpace .. config_subitem.name, color)
        end
    end

    tips_addequipitemsetattr(c_textformat("TIPS_ITEMSET_ATTRSUB", 2), config_itemset.attr2, equipsubcount, 2, coloritem)
    tips_addequipitemsetattr(c_textformat("TIPS_ITEMSET_ATTRSUB", 3), config_itemset.attr3, equipsubcount, 3, coloritem)
    tips_addequipitemsetattr(c_textformat("TIPS_ITEMSET_ATTRSUB", 4), config_itemset.attr4, equipsubcount, 4, coloritem)
    tips_addequipitemsetattr(c_textformat("TIPS_ITEMSET_ATTRSUB", 5), config_itemset.attr5, equipsubcount, 5, coloritem)
    tips_addequipitemsetattr(c_textformat("TIPS_ITEMSET_ATTRALL"), config_itemset.attrset, equipsubcount, #subid, coloritem)
end

local function tips_addequipextra(config_item, extra, attrcompondbonus)
    if config_item.gem ~= nil and config_item.gem > 0 then
        tips_addsplit()
        tips_adddesc(c_textformat("TIPS_ITEM_EQUIPGEMLEVEL", csvitem_getgemlevel(config_item)), TIPS_COLOR_DESC)
    end
    if extra == nil then
        tips_equip_gemhole(config_item)
        return
    end
    if extra.gem ~= nil and #extra.gem > 0 then
        tips_equip_gem(extra.gem)
    end
    if extra.compound ~= nil and extra.compound > 0 then
        tips_equip_compound(config_item, extra, attrcompondbonus)
    end
    if extra.god ~= nil and extra.god > 0 then
        local config_god = csvitem_getfromid(extra.god)
        if config_god ~= nil then
            tips_adddesc(csvitem_getgoddesc(config_god), TIPS_COLOR_DESC)
        end
    end
    if extra.skin ~= nil and extra.skin ~= 0 then
        local config_skin = csvitem_getfromid(extra.skin)
        if config_skin ~= nil then
            tips_adddesc(c_textformat("TIPS_ITEM_SKIN", config_skin.name), TIPS_COLOR_DESC)
        end
    end
end

function tips_addequip(config_item, extra)
    tips_equip_requireskill(config_item)

    local attrextra = nil
    local attrcompondmain = nil
    local attrcompondbonus = nil
    if extra ~= nil then
        if extra.soul ~= nil and extra.soul > 0 then
            local config_soularray = c_config_getmetaarray(configid.equip_soulattr, "itemtype", config_item.itemtype, "soullevel", extra.soul)
            if config_soularray ~= nil and #config_soularray > 0 then
                attrextra = equip_parseattr(config_soularray[1].attr)
            end
        end
        if extra.compound ~= nil and extra.compound > 0 then
            local config_item = csvitem_getfromid(extra.compound)
            if config_item ~= nil then
                attrcompondmain = equip_parseattr(config_item.attrmain)
                attrcompondbonus = equip_parseattr(config_item.attrbonus)
            end
        end
    end

    local attrarray = equip_parseattr(config_item.attrmain)
    if attrarray ~= nil then
        tips_equip_weapondamage(config_item, attrarray, attrextra, attrcompondmain)
        tips_equip_attrextra(attrarray, attrextra, attrcompondmain, TIPS_COLOR_WHITE, bit.bor(tipsflag.available, tipsflag.attrmain))
    end

    if attrextra ~= nil and #attrextra > 0 then
        tips_equip_attr(attrextra, TIPS_COLOR_WHITE, tipsflag.available)
    end

    attrarray = equip_parseattr(config_item.attrbonus)
    if attrarray ~= nil then
        tips_addsplit()
        tips_equip_attrextra(attrarray, nil, attrcompondbonus, TIPS_COLOR_WHITE, bit.bor(tipsflag.available, tipsflag.attrbonus))
    end

    tips_addequipcharge(config_item, extra)
    tips_addequipitemset(config_item, extra)
    tips_addequipextra(config_item, extra, attrcompondbonus)

    if config_item.deal == csvitemdeal.bindonuse or config_item.deal == csvitemdeal.bindontrade then
        if extra ~= nil and equip_isbindonuse(extra) then
            tips_adddesc("TIPS_ITEM_BOUND", TIPS_COLOR_DESC)
        elseif config_item.deal == csvitemdeal.bindonuse then
            tips_adddesc("TIPS_ITEM_BINDABLE", TIPS_COLOR_DESC)
        elseif config_item.deal == csvitemdeal.bindontrade then
            if extra ~= nil and equip_isbindontrade(extra) then
                tips_adddesc("TIPS_ITEM_TRADEBOUND", TIPS_COLOR_DESC)
            else
                tips_adddesc("TIPS_ITEM_TRADEBINDABLE", TIPS_COLOR_DESC)
            end
            tips_adddesc("TIPS_ITEM_BINDABLE", TIPS_COLOR_DESC)
        end
    end
end
