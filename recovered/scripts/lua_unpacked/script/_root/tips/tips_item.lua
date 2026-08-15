
local function tips_addration(config_item, extra)
    if extra == nil or extra.limit == nil then
        return
    end
    local limit = nil
    for i=1,#extra.limit do
        if extra.limit[i].itemid == config_item.id then
            limit = extra.limit[i]
            break
        end
    end
    if limit == nil then
        return
    end
    local playerlimit = 0
    local playerreset = nil
    local serverlimit = 0
    local serverreset = nil
    local config_shoplimit = csvshop_getshoplimit(config_item.id)
    if config_shoplimit ~= nil then
        playerlimit = config_shoplimit.playerlimit
        playerreset = config_shoplimit.playerreset
        serverlimit = config_shoplimit.serverlimit
        serverreset = config_shoplimit.serverreset
    end
    local config_storelimit = c_config_getmetaid(configid.store, config_item.id)
    if config_storelimit ~= nil then
        playerlimit = config_storelimit.playerlimit
        playerreset = config_storelimit.playerreset
    end
    if playerlimit == 0 and serverlimit == 0 then
        return
    end
    local availablecount = math.max(limit.playeravailable, limit.serveravailable)
    if playerlimit > 0 then
        local text = c_textformat("TIPS_ITEM_RATIONPLAYER", limit.playeravailable, playerlimit)
        tips_adddesc(text, math.ternary(limit.playeravailable > 0, TIPS_COLOR_DESC, TIPS_COLOR_RED))

        local textreset = csvshop_getresetdesc(playerreset)
        tips_adddesc(c_textformat("TIPS_ITEM_RATIONPLAYERRESET", textreset), TIPS_COLOR_DESC)

        availablecount = math.min(availablecount, limit.playeravailable)
    end
    if serverlimit > 0 then
        local text = c_textformat("TIPS_ITEM_RATIONSERVER", limit.serveravailable, serverlimit)
        tips_adddesc(text, math.ternary(limit.serveravailable > 0, TIPS_COLOR_DESC, TIPS_COLOR_RED))

        local textreset = csvshop_getresetdesc(serverreset)
        tips_adddesc(c_textformat("TIPS_ITEM_RATIONSERVERRESET", textreset), TIPS_COLOR_DESC)

        availablecount = math.min(availablecount, limit.serveravailable)
    end

    local textavailable = c_textformat("TIPS_ITEM_RATIONAVAILABLE", availablecount)
    tips_adddesc(text, math.ternary(availablecount > 0, TIPS_COLOR_DESC, TIPS_COLOR_RED))
end

local function tips_addstandard(config_item, extra)
    local itemtypetext = csvitem_gettypetext(config_item.itemtype)
    tips_addattr1("TIPS_ITEM_TYPE", itemtypetext, TIPS_COLOR_TEXT, 0)
    if config_item.itemtype == csvitemtype.consume_gem then
        tips_addattr1("TIPS_ITEM_GEMLEVELNAME", c_textformat("TIPS_ITEM_GEMLEVELDESC", config_item.itemlevel), TIPS_COLOR_TEXT, 0)
    end
    tips_addration(config_item, extra)

    local exchange = nil
    if config_item.price <= 0 or config_item.sellnpc <= 0 then
        exchange = c_textformat("TIPS_ITEM_DISABLENPC")
    end
    if config_item.deal == csvitemdeal.nodeal then
        exchange = string.append(exchange, c_textformat("TIPS_ITEM_DISABLEPLAYER"), ",")
    end
    if exchange ~= nil then
        tips_adddesc(exchange, TIPS_COLOR_DESC)
    end
end

function tips_additem(config_item, count, flag, extra)
    if bit.band(flag, tipsflag.equip) > 0 then
        tips_adddesc("TIPS_ITEM_EQUIPMINE", TIPS_COLOR_EQUIPMINE)
    end

    local rgbhex = TIPS_COLOR_WHITE
    if config_item ~= nil then
        rgbhex = csvitem_gethexcolor(config_item)
    end
    local isequip = csvitem_isequip(config_item)
    local extend = isequip or csvitem_isrecipe(config_item)
    if not isequip and count > 1 then
        tips_addtitle(string.format("%s(%d)", config_item.name, count), rgbhex, extend)
    elseif extra ~= nil and extra.soul ~= nil and extra.soul > 0 then
        tips_addtitle(string.format("+%d %s", extra.soul, config_item.name), rgbhex, extend)
    else
        tips_addtitle(config_item.name, rgbhex, extend)
    end

    tips_addstandard(config_item, extra)
    tips_itemaddplayerlevel(config_item.playerlevel)
    tips_itemaddplayerciv(config_item.civ)
    tips_itemaddplayersex(config_item.sex)

    if isequip then
        tips_addequip(config_item, extra)
    end
    if csvitem_isrecipe(config_item) then
        tips_addrecipeskill(config_item)
    end

    local itemdesc, itemspell = csvitem_getdesc(config_item)
    if itemdesc ~= nil then
        tips_addsplit()
        tips_adddesc(itemdesc, TIPS_COLOR_TEXT)
        if #itemspell > 0 then
            tips_addsplit()
            tips_adddesc(itemspell, TIPS_COLOR_TEXT)
        end
    end

    if csvitem_isrecipe(config_item) then
        tips_addrecipe(config_item)
    end

    if config_item.itemtype == csvitemtype.consume_gift then
        tips_addgiftspace(config_item)
    end

    if extra ~= nil and extra.expire ~= nil and extra.expire ~= 0 then
        tips_addexpire(extra.expire)
    end

    tips_itemaddwarning(config_item)
end

local function tips_itemcareervisible(levelarray, career, careerlevel)
    local careerbase = playercareerbase(career)
    if careerbase ~= career and levelarray[playercareerbase(career)] == careerlevel then
        return false
    end
    return true
end

function tips_itemaddplayerciv(civ)
    if civ ~= 3 then
        local color = TIPS_COLOR_DESC
        if civ ~= playerattr_info.civ + 1 then
            color = TIPS_COLOR_RED
        end
        tips_adddesc(c_textformat("TIPS_ITEM_PLAYERCIV", getplayercivtext(civ - 1)), color)
    end
end
function tips_itemaddplayersex(sex)
    if sex ~= 0 then
        local color = TIPS_COLOR_DESC
        if sex ~= playerattr_info.sex then
            color = TIPS_COLOR_RED
        end
        if sex == playersex.male then
            tips_adddesc(c_textformat("TIPS_ITEM_PLAYERSEX",c_textformat("UI_SEX_MALE")), color)
        else
            tips_adddesc(c_textformat("TIPS_ITEM_PLAYERSEX",c_textformat("UI_SEX_FEMALE")), color)
        end
    end
end
function tips_itemaddplayerlevel(playerlevel)
    if string.find(playerlevel, ",") then
        local sub = string.split(playerlevel, ",")
        local addtips = false
        local same = true
        local firstlevel = nil
        for i=1,#sub do
            sub[i] = string.tointeger(sub[i])
            if sub[i] > 0 then
                addtips = true
                if firstlevel == nil then
                    firstlevel = sub[i]
                end
                if sub[i] ~= firstlevel then
                    same = false
                end
            end
        end
        if addtips then
            if same then
                local level = 0
                local career = nil
                local color = TIPS_COLOR_RED
                for i=1,#sub do
                    if sub[i] > 0 then
                        level = sub[i]
                        if tips_itemcareervisible(sub, i, level) then
                            if career ~= nil then
                                career = career .. "," .. c_textformat(playercareertext[i])
                            else
                                career = c_textformat(playercareertext[i])
                            end
                        end
                        if playerattr_info.career == i and playerattr_info.level >= level then
                            color = TIPS_COLOR_DESC
                        end
                    end
                end
                tips_adddesc(c_textformat("TIPS_ITEM_PLAYERLEVEL_CAREER", career, level), color)
            else
                local desc = nil
                local color = TIPS_COLOR_RED
                for i=1,#sub do
                    local level = sub[i]
                    if level > 0 then
                        if tips_itemcareervisible(sub, i, level) then
                            if desc ~= nil then
                                desc = desc .. "," .. c_textformat("TIPS_ITEM_PLAYERLEVEL_CAREER", playercareertext[i], level)
                            else
                                desc = c_textformat("TIPS_ITEM_PLAYERLEVEL_CAREER",  playercareertext[i], level)
                            end
                        end
                        if playerattr_info.career == i and playerattr_info.level >= level then
                            color = TIPS_COLOR_DESC
                        end
                    end
                end
                tips_adddesc(desc, color)
            end
        end
    else
        local level = string.tointeger(playerlevel)
        if level > 1 then
            if level > playerattr_info.level then
                tips_adddesc(c_textformat("TIPS_ITEM_PLAYERLEVEL", level), TIPS_COLOR_RED)
            else
                tips_adddesc(c_textformat("TIPS_ITEM_PLAYERLEVEL", level), TIPS_COLOR_DESC)
            end
        end
    end
end

function tips_itemaddwarning(config_item)
    if config_item.itemtype == csvitemtype.skill_book then
        local lambda = csvitem_getscript(config_item, "addskill")
        if lambda ~= nil and playerskill_available(lambda.variable[1].integer) then
            tips_adddesc(c_textformat("TIPS_ITEM_SKILLBOOK_LEARNED"), TIPS_COLOR_RED)
        end
    elseif csvitem_isrecipe(config_item) then
        local lambda = csvitem_getscript(config_item, "addrecipe")
        if lambda ~= nil and playerskill_getrecipe(lambda.variable[1].integer) ~= nil then
            tips_adddesc(c_textformat("TIPS_ITEM_RECIPE_LEARNED"), TIPS_COLOR_RED)
        end
    end
end

function tips_addgiftspace(config_item)
    local itemlambda = config_item.lambda
    if itemlambda == nil then
        return
    end
    local space = 0
    local actioncount = itemlambda.actioncount
    for i=1,actioncount do
        local sublambda = itemlambda[i]
        if c_isaction(sublambda, "gift") then
            local civ = sublambda.variable[2].integer
            local career = sublambda.variable[3].integer
            if playercivavailable(civ, playerattr_info.civ) and playercareeravailable(career, playerattr_info.career) then
                local levelmin = sublambda.variable[4].integer
                local levelmax = sublambda.variable[5].integer
                if levelmax == 0 or (playerattr_info.level >= levelmin and playerattr_info.level <= levelmax) then
                    space = space + 1
                end
            end
        end
    end
    if space > 0 then
        tips_adddesc(c_textformat("TIPS_ITEM_GIFTSPACE", space), TIPS_COLOR_DESC)
    end
end

function tips_item(itemid, count, x, y, flag, extra, parent)
    tips_close()
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    tips_create(flag, parent)
    tips_additem(config_item, count, flag, extra)
    tips_complete(x, y)
    if csvitem_isequip(config_item) then
        local activeequip = playeritem_getactiveequip()
        local slot = csvitem_getequipslot(config_item)
        if slot ~= nil and activeequip[slot].itemid ~= 0 then
            local slot1 = slot
            local slot2 = nil
            if slot1 == equipslot.earring1 then
                slot2 = equipslot.earring2
            elseif slot1 == equipslot.ring1 then
                slot2 = equipslot.ring2
            elseif slot1 == equipslot.weapon1 then
                slot2 = equipslot.weapon2
            end
            if slot1 ~= nil then
                if bit.band(flag, tipsflag.opencompare) > 0 then
                    tips_itemcompare(slot1, slot2, parent)
                else
                    local data = {}
                    data.type = tipsextendtype.equip
                    data.slot1 = slot1
                    data.slot2 = slot2
                    tips_setextend(data)
                end
            end
        end
    elseif csvitem_isrecipe(config_item) then
        local data = {}
        data.type = tipsextendtype.recipe
        data.config_item = config_item
        tips_setextend(data)
    elseif config_item.itemtype == csvitemtype.skill_book then
        local itemlambda = csvitem_getscript(config_item, "addskill")
        if itemlambda ~= nil then
            tips_itemskill(itemlambda.variable[1].integer, parent)
        end
    elseif config_item.itemtype == csvitemtype.skill_stigma then
        local itemlambda = csvitem_getscript(config_item, "stigma")
        if itemlambda ~= nil then
            tips_itemskill(itemlambda.variable[1].integer, parent)
        end
    end
end

function tips_itemskill(skillid, parent)
    local config_skill = csvskill_getfromid(skillid)
    if config_skill ~= nil then
        local flag = bit.bor(tipsflag.compare1, tipsflag.equip)
        tips_create(flag, parent)
        tips_addtitle(config_skill.name, TIPS_COLOR_WHITE)
        local skilldesc = skilltext_getdesc(config_skill.desc, config_skill, nil, skilltextflag.spellcost)
        tips_adddesc(skilldesc, TIPS_COLOR_DESC)
        tips_complete(0.0, tips_getmainpositiony())
        tips_adjustcompare()
    end
end

function tips_itemcompare(slot1, slot2, parent)
    local activeequip = playeritem_getactiveequip()
    local item1 = activeequip[slot1]
    if item1.itemid ~= 0 then
        local config_item = csvitem_getfromid(item1.itemid)
        if config_item ~= nil then
            local flag = bit.bor(tipsflag.compare1, tipsflag.equip)
            tips_create(flag, parent)
            tips_additem(config_item, 1, flag, item1)
            tips_complete(0.0, tips_getmainpositiony())
        end
    end
    if slot2 ~= nil then
        local item2 = activeequip[slot2]
        if item2.itemid ~= 0 then
            local config_item = csvitem_getfromid(item2.itemid)
            if config_item ~= nil then
                local flag = bit.bor(tipsflag.compare2, tipsflag.equip)
                tips_create(flag, parent)
                tips_additem(config_item, 1, flag, item2)
                tips_complete(0.0, tips_getmainpositiony())    
            end
        end    
    end
    tips_adjustcompare()
end
