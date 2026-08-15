
local m_uiabysscastle_main = uipanel_createhandle("rank/abysscastle", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_abysscastle_inst = {inst = "rank/inst_abysscastle"}

function abysscastle_open()
    m_uiabysscastle_main:open()
end

local function abysscastle_addtime(strtime, linecount, strweek, configtime)
    if configtime == "-1" then
        return strtime, linecount
    end
    local strhour = ""
    local subtime = string.split(configtime, ",")
    for i=1,#subtime do
        local hour = c_textformat("TIME_DAYTIME_HOUR", subtime[i])
        if #strhour > 0 then
            strhour = strhour .. c_textformat("UI_SPLIT")
        end
        strhour = strhour .. hour
    end
    if #strtime > 0 then
        strtime = strtime .. "\n"
    end
    strtime = strtime .. c_textformat("ABYSSCASTLE_TIMEDESC", c_textformat(strweek), strhour)
    return strtime, linecount + 1
end

local function abysscastle_settextrect(text, size)
    local w,h = text:getsize()
    text:setsize(w, size)

    local x,y = text:getposition()
    text:setposition(x, -size / 2)
end

function abysscastle_onopen()
    m_uiabysscastle_main:setwidgetdelegate("image_bg/button_close", abysscastle_delegate_close)
    local list_castle = m_uiabysscastle_main:getwidget("list_castle")
    list_castle:init(uilistflag.vertical)

    local count = c_config_count(configid.abyss_castle)
    for i=1,count do
        local config_abysscastle = c_config_getmetaindex(configid.abyss_castle, i)
        local servercastle = serverattr_abysscastle[config_abysscastle.id]
        if servercastle ~= nil then
            local line = list_castle:add(m_abysscastle_inst.inst)
            local text_name = line:getwidget("text_name")
            local name = config_abysscastle.name
            local subname = string.split(name, "\n")
            name = subname[1]
            if servercastle.mist > 0 then
                text_name:settext(name .. c_textformat("ABYSSCASTLE_MIST"))
            else
                text_name:settext(name)
            end

            local text_civ = line:getwidget("text_civ")
            if servercastle.civ == playerciv.light then
                text_civ:settext("UI_CIVNAME_ELF")
            elseif servercastle.civ == playerciv.dark then
                text_civ:settext("UI_CIVNAME_DARK")
            else
                text_civ:settext("UI_CIVNAME_DRAGON")
            end

            local text_time = line:getwidget("text_time")
            local time = ""
            local linecount = 0
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W1", config_abysscastle.mon)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W2", config_abysscastle.tue)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W3", config_abysscastle.wed)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W4", config_abysscastle.thu)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W5", config_abysscastle.fri)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W6", config_abysscastle.sat)
            time, linecount = abysscastle_addtime(time, linecount, "TIME_W7", config_abysscastle.sun)
            text_time:settext(time)

            local size = linecount * 100
            abysscastle_settextrect(text_name, size)
            abysscastle_settextrect(text_civ, size)
            abysscastle_settextrect(text_time, size)

            local image_name = line:getwidget("image_name")
            local image_civ = line:getwidget("image_civ")
            local image_time = line:getwidget("image_time")
            abysscastle_settextrect(image_name, size)
            abysscastle_settextrect(image_civ, size)
            abysscastle_settextrect(image_time, size)

            line:setsize(size)
        end
    end
    list_castle:updatecontentsize()
end

function abysscastle_delegate_close()
    m_uiabysscastle_main:close()
end
