

function csvshop_getshop(shopid)
    return c_config_getmetaid(configid.shop, shopid)
end

function csvshop_getshoplimit(itemid)
    return c_config_getmetaid(configid.shop_limit, itemid)
end

function csvshop_getresetdesc(reset)
    if reset == "forever" then
        return c_textformat("TIPS_ITEM_RATIONRESETNONE")
    end
    local subreset = string.split(reset, "(")
    subreset[2] = string.sub(subreset[2], 0, #subreset[2] - 1)
    if subreset[1] == "day" then
        local daytime = string.tointeger(subreset[2])
        local dayhour = math.tointegerfloor(daytime / 3600)
        local dayminute = math.tointegerfloor(math.tointegerfloor(daytime / 60) % 60)
        local strtime = c_textformat("TIME_DAYTIME_MINUTE", string.format("%02d", dayhour), string.format("%02d", dayminute))
        return c_textformat("TIPS_ITEM_RATIONRESETDAY", strtime)
    elseif subreset[1] == "week" then
        local timeinsecond = string.tointeger(subreset[2])
        local weekday = math.tointegerfloor(timeinsecond / 86400)
        local dayhour = math.tointegerfloor(math.tointegerfloor(timeinsecond % 86400) / 3600)
        local dayminute = math.tointegerfloor(math.tointegerfloor(timeinsecond % 3600) / 60)
        local strtime = c_textformat("TIME_WEEKTIME_MINUTE", "TIME_W" .. (weekday + 1), string.format("%02d", dayhour), string.format("%02d", dayminute))
        return c_textformat("TIPS_ITEM_RATIONRESETWEEK", strtime)
    end
end
