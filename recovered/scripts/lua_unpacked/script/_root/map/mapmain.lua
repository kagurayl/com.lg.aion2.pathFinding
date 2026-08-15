
include("map/mapteleport")
include("map/mapview")
include("map/maplabel")
include("map/maplabel_quest")
include("map/maplabel_npc")
include("map/maplabel_simple")
include("map/mapopacity")

m_uimap_main = uipanel_createhandle("map/map_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function map_main_onopen()
    map_opacity_close()
    local checkbox_shownpc = m_uimap_main:getwidget("checkbox_shownpc")
    checkbox_shownpc:setdelegate(map_main_delegate_shownpc)
    checkbox_shownpc:setcheck(gamesetting_getnumber("MAPSHOWNPC") == 1)
    
    local checkbox_showquest = m_uimap_main:getwidget("checkbox_showquest")
    checkbox_showquest:setdelegate(map_main_delegate_showquest)
    checkbox_showquest:setcheck(gamesetting_getnumber("MAPSHOWQUEST") == 1)

    m_uimap_main:setwidgetdelegate("button_me", map_main_delegate_me)
    m_uimap_main:setwidgetdelegate("button_top", map_main_delegate_top)
    m_uimap_main:setwidgetdelegate("button_sendposition", map_main_delegate_sendposition)
    m_uimap_main:setwidgetdelegate("button_clearlabel", map_main_delegate_clearlabel)
    m_uimap_main:setwidgetdelegate("button_uplevel", map_main_delegate_uplevel)
    m_uimap_main:setwidgetdelegate("image_bg/button_close", map_main_delegate_close)
    m_uimap_main.subui = nil

    mapview_reset()
    event_register(eventtype.update, map_main_update, m_uimap_main)
end

function map_main_loadsubui(filename)
    mapview_reset()
    m_uimap_main:setwidgetvisible("scene_root/canvas_move", false)
    local canvas_subui = m_uimap_main:getwidget("scene_root/canvas_subui")
    canvas_subui:setvisible(true)
    if m_uimap_main.subui ~= nil then
        local prevsubui = m_uimap_main:getwidget(m_uimap_main.subui)
        if prevsubui ~= nil then
            prevsubui:unloadsubui()
        end
    end

    local canvaswidth, canvasheight = canvas_subui:getsize()
    local subpath, subtitle = string.getpathtitle(filename)
    canvas_subui:loadsubui(filename, subtitle)

    local text_mapname = m_uimap_main:getwidget("text_mapname")
	text_mapname:settext("WORLDMAP_" .. string.upper(subtitle))

    local subui = canvas_subui:getwidget(subtitle)
    m_uimap_main.subui = subui._widgetpath

    local subuibg = subui:getwidget("image_bg")
    local subuiwidth, subuiheight = subuibg:getsize()
    local scale = math.min(canvaswidth / subuiwidth, canvasheight / subuiheight)
    local posx = (canvaswidth - subuiwidth * scale) / 2
    local posy = canvasheight - (canvasheight - subuiheight * scale) / 2
    subui:settransform(0.5, 0.5, posx, posy, scale, scale, 0, 0, 0)

    local subwidgetlist = subui:getwidgetlist(true)
    for i=1,#subwidgetlist do
        local widgetpath = subwidgetlist[i]
        subpath, subtitle = string.getpathtitle(widgetpath)
        if string.startwith(subtitle, "linkui_") then
            local linkname = string.sub(subtitle, string.len("linkui_") + 1)
            local button_sub = m_uimap_main:getwidget(widgetpath)
            button_sub:setthreshold(0.01)
            button_sub:setdelegate(map_main_delegate_linkui)
            button_sub.linkname = linkname
        elseif string.startwith(subtitle, "linkmap_") then
            local linkmap = string.sub(subtitle, string.len("linkmap_") + 1)
            local button_sub = m_uimap_main:getwidget(widgetpath)
            button_sub:setthreshold(0.01)
            button_sub:setdelegate(map_main_delegate_linkmap)
            button_sub.linkmap = linkmap
        end
    end
end

function map_main_update()
    maplabel_updateteam()
    maplabel_update()
end

function map_main_delegate_shownpc(sender, event)
    local show = sender:getcheck()
    gamesetting_modify("MAPSHOWNPC", math.ternary(show, 1, 0))
    maplabel_updateui()
end

function map_main_delegate_showquest(sender, event)
    local show = sender:getcheck()
    gamesetting_modify("MAPSHOWQUEST", math.ternary(show, 1, 0))
    maplabel_updateui()
end

function map_main_delegate_me(sender)
    mapview_setmap(scene_getmapconfig(), csvmap_getlayer(scene_getmapconfig(), playerattr_info.posy))
    maplabel_flickerme()
end

function map_main_delegate_top(sender)
    map_main_loadsubui("map/map_level1")
end

function map_main_delegate_sendposition(sender)
    chat_openinput()
    local text = richtext_makelocation(scene_getmapid(), playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
    chatinput_addtext(text)
end

function map_main_delegate_clearlabel(sender)
    maplabel_simplereset()
    maplabel_npcreset()
    maplabel_questreset()
    maplabel_updateui()
    minimap_settracenpc(nil)
end

function map_main_delegate_uplevel(sender)
    local config_map = mapview_getmap()
    if config_map ~= nil then
        if config_map.uplevel ~= "0" then
            map_main_loadsubui("map/" .. config_map.uplevel)
        end
    else
        map_main_loadsubui("map/map_level1")
    end
end

function map_main_delegate_linkui(sender)
    map_main_loadsubui("map/" .. sender.linkname)
end

function map_main_delegate_linkmap(sender)
    local linkmap = string.split(sender.linkmap, "_")
    local mapid = string.tointeger(linkmap[1])
    local maplayer = nil
    if #linkmap > 1 then
        maplayer = string.tointeger(linkmap[2])
    end
    if not mapview_setmapid(mapid, maplayer) then
        messagealert_addalert("WORLDMAP_DESTNOMAP")
    end
end

function map_main_delegate_close()
    m_uimap_main:close()
    tutorial_start(tutorialid.opacitymap)
end
