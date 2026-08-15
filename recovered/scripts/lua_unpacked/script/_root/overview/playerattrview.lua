
local m_playerattrview_inst = {attr = "overview/inst_attr"}

local function playerattrview_addstr(list_attr, text, str)
    local line = list_attr:add(m_playerattrview_inst.attr)
    local text_name = line:getwidget("text_name")
    text_name:setvisiblenothit(true)
    text_name:settext(text)

    local text_val = line:getwidget("text_val")
    text_val:setvisiblenothit(true)
    text_val:settext(str)
end

local function playerattrview_addflt(list_attr, text, val)
    if val ~= nil then
        local v1, v2 = math.modf(val)
        if v2 > 0 then
            playerattrview_addstr(list_attr, text, string.format("%.1f", val + 0.05))
        else
            playerattrview_addstr(list_attr, text, math.tointegerfloor(val))
        end
    end
end

local function playerattrview_addinteger(list_attr, text, val, isinteger)
    if val ~= nil then
        playerattrview_addstr(list_attr, text, math.tointegerfloor(val + 0.5))
    end
end

local function playerattrview_addattrpercent(list_attr, text, val, isinteger)
    if val ~= nil then
        val = val * 100
        local v1, v2 = math.modf(val)
        if v2 > 0 and (isinteger == nil or not isinteger) then
            playerattrview_addstr(list_attr, text, string.format("%.1f%%", val + 0.05))
        else
            playerattrview_addstr(list_attr, text, math.tointegerfloor(val + 0.5) .. "%")
        end
    end
end

function playerattrview_setattr(list_attr, attr, equip)
    list_attr:savestate()
    list_attr:clear()

    playerattrview_addinteger(list_attr, "TIPS_ATTR_HPMAX", attr.hpmax)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MPMAX", attr.mpmax)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_FPMAX", attr.fpmax)
    playerattrview_addflt(list_attr, "TIPS_ATTR_MOVESPEED", attr.movespeed)
    playerattrview_addflt(list_attr, "TIPS_ATTR_FLYSPEED", attr.flyspeed)
    playerattrview_addattrpercent(list_attr, "TIPS_ATTR_HEAL", attr.heal)
    playerattrview_addattrpercent(list_attr, "TIPS_ATTR_THREAT", attr.threat)
    playerattrview_addattrpercent(list_attr, "TIPS_ATTR_PVPDAMAGE", attr.pvpdamage)
    playerattrview_addattrpercent(list_attr, "TIPS_ATTR_PVPDEFENSE", attr.pvpdefense)
    playerattrview_addflt(list_attr, "TIPS_ATTR_ATTACKSPEED", playerbattle_getattackdelay(attr, equip))

    if attr.career == playercareer.warrior
    or attr.career == playercareer.scout
    or attr.career == playercareer.fighter
    or attr.career == playercareer.knight
    or attr.career == playercareer.chanter
    or attr.career == playercareer.assassin
    or attr.career == playercareer.ranger then
        playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYDAMAGEMIN", attr.phydamage - (attr.damagemax - attr.damagemin) / 2.0)
        playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYDAMAGEMAX", attr.phydamage + (attr.damagemax - attr.damagemin) / 2.0)
        playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYACCURACY", attr.phyaccuracy + attr.accuracy)
        playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYCRITRATE", attr.phycritrate)
    end

    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYCRITRESIST", attr.phycritresist)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYCRITDEFENSE", attr.phycritdefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYDEFENSE", attr.phydefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYDODGE", attr.phydodge)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYPARRY", attr.phyparry)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_PHYBLOCK", attr.phyblock)

    playerattrview_addattrpercent(list_attr, "TIPS_ATTR_MAGSPEED", attr.magspeed)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGBOOST", attr.magboost)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGCONCENT", attr.magconcent)

    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGDAMAGEMIN", attr.magdamage - (attr.damagemax - attr.damagemin) / 2.0)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGDAMAGEMAX", attr.magdamage + (attr.damagemax - attr.damagemin) / 2.0)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGACCURACY", attr.magaccuracy)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGCRITRATE", attr.magcritrate)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGCRITRESIST", attr.magcritresist)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGCRITDEFENSE", attr.magcritdefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGRESIST", attr.magresist)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGDEFENSE", attr.magdefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGEARTHDEFENSE", attr.magearthdefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGWATERDEFENSE", attr.magwaterdefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGFIREDEFENSE", attr.magfiredefense)
    playerattrview_addinteger(list_attr, "TIPS_ATTR_MAGWINDDEFENSE", attr.magwinddefense)

    list_attr:restorestate()
end
