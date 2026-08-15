
m_uimap_teleport = uipanel_createhandle("map/map_teleport", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

local function map_teleport_addpath(image_pathsrc, imageindex, uix, uiy, uix2, uiy2)
    local image_path = nil
    local dist = vector2_distance(uix, uiy, uix2, uiy2)
    local pointsize = 20
    local count = math.floor(dist / pointsize)
    for i=2, count - 2 do
        if imageindex == 1 then
            image_path = image_pathsrc
            image_path:setvisiblenothit(true)
        else
            image_path = image_pathsrc:clone("image_path" .. imageindex)
        end
        imageindex = imageindex + 1
        local t = i / count
        image_path:setposition(math.lerp(uix, uix2, t), -math.lerp(uiy, uiy2, t))
        image_path:setsize(pointsize, pointsize)
    end
    return imageindex
end

function map_teleport_create(id)
    m_uimap_teleport:close()
    m_uimap_teleport.selectnpc = m_selectactorid
    local config_airlinearray = c_config_getmetaarray(configid.map_airline, "airline", id)
	if config_airlinearray == nil then        
        return
    end
    local config_origin = c_config_getmetaid(configid.map_airport, config_airlinearray[1].origin)
    if config_origin == nil then
        local config_dest = c_config_getmetaid(configid.map_airport, config_airlinearray[1].dest)
        if config_dest ~= nil then
            messagebox_confirm(c_textformat("TELEPORT_TIPS", config_dest.name, config_airlinearray[1].price), map_teleport_confirm, config_airlinearray[1].id)
        end
        return
    end
    m_uimap_teleport:open()
    m_uimap_teleport:setwidgetdelegate("image_bg/button_close", map_teleport_delegate_close)

    local config_map = csvmap_getfromid(config_origin.mapid)
    local image_map = m_uimap_teleport:getwidget("image_root/image_map")
    local w,h = image_map:getsize()
    local scale_w = w / 400.0
    local scale_h = h / 480.0

    local image_origin = m_uimap_teleport:getwidget("image_root/image_origin")
    image_origin:setposition(config_origin.uix * scale_w, -config_origin.uiy * scale_h)

    local crossmap = false
    local button_destsrc = m_uimap_teleport:getwidget("image_root/button_dest")
    button_destsrc:setvisible(false)
    local image_disablesrc = m_uimap_teleport:getwidget("image_root/image_disable")
    image_disablesrc:setvisible(false)
    local image_pathsrc = m_uimap_teleport:getwidget("image_root/image_path")
    image_pathsrc:setvisible(false)

    local imagedestindex = 1
    local imagedisableindex = 1
    local imagepathindex = 1
    for i=1,#config_airlinearray do
        local config_airline = config_airlinearray[i]
        local config_dest = c_config_getmetaid(configid.map_airport, config_airline.dest)
        if config_dest ~= nil then
            if config_dest.mapid ~= config_origin.mapid then
                crossmap = true
            end
            local enable = true
            if config_airline.quest ~= 0 and playerattr_questcomplete[config_airline.quest] == nil then
                enable = false
            end
            if config_dest.abyssid ~= 0 then
                local abysscastle = serverattr_abysscastle[config_dest.abyssid]
                if abysscastle ~= nil then
                    if abysscastle.civ ~= playerattr_info.civ or (abysscastle.mist > 0 and abysscastle.teleport == 0) then
                        enable = false
                    end
                end
            end
            if enable then
                local button_dest = nil
                if imagedestindex == 1 then
                    button_dest = button_destsrc
                    button_dest:setvisible(true)
                else
                    button_dest = button_destsrc:clone("button_dest" .. imagedestindex)
                end
                imagedestindex = imagedestindex + 1
                button_dest:setposition(config_dest.uix * scale_w, -config_dest.uiy * scale_h)

                imagepathindex = map_teleport_addpath(image_pathsrc, imagepathindex, config_origin.uix * scale_w, config_origin.uiy * scale_h, config_dest.uix * scale_w, config_dest.uiy * scale_h)
                button_dest:setenable(true)
                button_dest:setdelegate(map_teleport_delegate_dest)
                button_dest.name = config_dest.name
                button_dest.price = config_airline.price
                button_dest.airlineid = config_airline.id
                button_dest.airlineprice = config_airline.price
            else
                local image_disable = nil
                if imagedisableindex == 1 then
                    image_disable = image_disablesrc
                    image_disable:setvisible(true)
                else
                    image_disable = image_disablesrc:clone("image_disable" .. imagedisableindex)
                end
                imagedisableindex = imagedisableindex + 1
                image_disable:setposition(config_dest.uix * scale_w, -config_dest.uiy * scale_h)
            end
        end
    end

    local text_title = m_uimap_teleport:getwidget("image_bg/text_title")
    if crossmap then
        text_title:settext("TELEPORT_MAP2_TITLE")
        if playerattr_info.civ == playerciv.light then
            image_map:setraw("teleport/world_light")
        else
            image_map:setraw("teleport/world_dark")
        end
    else
        text_title:settext("TELEPORT_MAP_TITLE")
        image_map:setraw("teleport/" .. config_map.scene)
    end
    image_map:setrawuv(0, 0.0625, 0.78125, 0.9375)
end

function map_teleport_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_NPCTeleport"}
        msg.actorid = m_uimap_teleport.selectnpc
        msg.id = data
        c_send(msg)
        m_uimap_teleport:close()
    end
end
function map_teleport_delegate_dest(sender)
    local price = sender.price
    if price > 0 and m_me:getbufftypename("hipass") ~= nil then
        price = 1
    end
    messagebox_confirm(c_textformat("TELEPORT_TIPS", sender.name, price), map_teleport_confirm, sender.airlineid)
end

function map_teleport_delegate_close()
    m_uimap_teleport:close()
end
