
minimapiconlayer =
{
	npcnormal = 1,
    npcfriend = 2,
    npcenemy = 3,
    npclabel = 4,
    npcquest = 5,
    playerteam = 6,
    playerenemy = 7,
}

m_uiminimap = uipanel_createhandle("home/minimap", uilayer.bottom, uiflag.scale)

local m_minimap_viewrangestandard = 50
local m_minimap_radar = {}
local m_minimap_layer = {}
local m_minimap_tracenpcid = nil
local m_minimap_traceharvest = 0

local function minimap_setwidgetvisible(widget, visible)
    if widget.visible ~= visible then
        widget:setvisiblenothit(visible)
        widget.visible = visible
    end
end

local function minimap_getactorimage(labelimage, labellayer, labelsize)
    local radar_layer = m_minimap_layer[labellayer]
    local image_type = radar_layer.image_type[labelimage.image]
    if image_type == nil then
        image_type = {}
        image_type.image_radar = {}
        image_type.image_viewcount = 0
        radar_layer.image_type[labelimage.image] = image_type
    end
    image_type.image_viewcount = image_type.image_viewcount + 1
    if image_type.image_viewcount > #image_type.image_radar then
        radar_layer.image_count = radar_layer.image_count + 1
        local path = string.format("%s_clone%d", radar_layer.image_name, radar_layer.image_count)
        local image_radar = radar_layer.image_src:clone(path)
        if labelsize ~= nil then
            image_radar:setsize(labelsize, labelsize)
        else
            image_radar:setsize(labelimage.width, labelimage.height)
        end
        image_radar:setsprite(labelimage.image)
        image_radar:setvisiblenothit(true)
        image_radar.visible = true
        image_radar.cacheid = image_radar:cache()
        image_type.image_radar[#image_type.image_radar + 1] = image_radar
        return image_radar
    else
        return image_type.image_radar[image_type.image_viewcount]
    end
end

local function minimap_getradarpos(actorposx, actorposz, xmin, xmax, ymin, ymax)
    local posx = actorposx - m_minimap_radar.zonex
    local posy = actorposz - m_minimap_radar.zoney
    if m_minimap_radar.flipui > 0 then
        posx = m_minimap_radar.zonewidth - posx
        posy = m_minimap_radar.zoneheight - posy
    end
    if posx < xmin or posx > xmax or posy < ymin or posy > ymax then
        return
    end
    return posx, posy
end

local function minimap_setradarimage(image_radar, posx, posy, scale, rot, xmin, xmax, ymin, ymax)
    local cx = (posx - xmin) / (xmax - xmin)
    local cy = (posy - ymin) / (ymax - ymin)
    local image_x = cx * m_minimap_radar.minimapwidth
    local image_y = cy * m_minimap_radar.minimapheight
    image_radar:settransform(0.5, 0.5, image_y, -image_x, scale, scale, 0.0, 0.0, rot)
    minimap_setwidgetvisible(image_radar, true)
    return true
end

local function minimap_setradarimagebatch(batchid, batchdata, image_radar, posx, posy, scale, rot, xmin, xmax, ymin, ymax)
    local cx = (posx - xmin) / (xmax - xmin)
    local cy = (posy - ymin) / (ymax - ymin)
    local image_x = cx * m_minimap_radar.minimapwidth
    local image_y = cy * m_minimap_radar.minimapheight
    batchid[#batchid + 1] = image_radar.cacheid
    batchdata[#batchdata + 1] = 0.5
    batchdata[#batchdata + 1] = 0.5
    batchdata[#batchdata + 1] = image_y
    batchdata[#batchdata + 1] = -image_x
    batchdata[#batchdata + 1] = scale
    batchdata[#batchdata + 1] = scale
    batchdata[#batchdata + 1] = 0.0
    batchdata[#batchdata + 1] = 0.0
    batchdata[#batchdata + 1] = rot
    minimap_setwidgetvisible(image_radar, true)
    return true
end

local function minimap_setradarselectanim(r, g, b, posx, posy, xmin, xmax, ymin, ymax)
    minimap_setwidgetvisible(m_minimap_radar.radar_layer_selectradar, false)
    m_minimap_radar.radar_layer_select1:setcolor(r, g, b, 1.0)
    m_minimap_radar.radar_layer_select2:setcolor(r, g, b, 1.0)
    m_minimap_radar.radar_time = m_minimap_radar.radar_time + time_frame * 2
    local animindex = math.tointegerfloor(math.fmod(m_minimap_radar.radar_time, 3))
    if animindex == 1 then
        minimap_setradarimage(m_minimap_radar.radar_layer_select1, posx, posy, 1.0, 0.0, xmin, xmax, ymin, ymax)
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select2, false)
    elseif animindex == 2 then
        minimap_setradarimage(m_minimap_radar.radar_layer_select2, posx, posy, 1.0, 0.0, xmin, xmax, ymin, ymax)
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select1, false)
    else
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select1, animindex == 1)
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select2, animindex == 2)
    end
end
local function minimap_setradarselect(actor, posx, posy, xmin, xmax, ymin, ymax)
    if actor.actordata.labellayer == minimapiconlayer.npcenemy then
        local leveldiff = playerattr_info.level - actor.attr.level
        if leveldiff < 10 then
            leveldiff = math.max(0.0, leveldiff)
            local sensoryscale = leveldiff / 10.0
            local sensory = math.max(0.0, actor.config_npc.sensory - actor.config_npc.sensoryshort * sensoryscale)
            if actor.boundboxsensorysize ~= nil then
                sensory = sensory + actor.boundboxsensorysize
            end
            local scale = sensory / (xmax - xmin) * m_minimap_radar.minimapwidth / m_minimap_radar.radar_selectradarradius
            m_minimap_radar.radar_time = math.fmod(m_minimap_radar.radar_time + time_frame * 180, 360)
            minimap_setradarimage(m_minimap_radar.radar_layer_selectradar, posx, posy, scale, -m_minimap_radar.radar_time, xmin, xmax, ymin, ymax)
            minimap_setwidgetvisible(m_minimap_radar.radar_layer_select1, false)
            minimap_setwidgetvisible(m_minimap_radar.radar_layer_select2, false)
        else
            minimap_setwidgetvisible(m_minimap_radar.radar_layer_selectradar, false)
            minimap_setradarselectanim(1.0, 0.0, 0.0, posx, posy, xmin, xmax, ymin, ymax)
        end
    else
        minimap_setradarselectanim(1.0, 1.0, 1.0, posx, posy, xmin, xmax, ymin, ymax)
    end
end


local function minimap_addteammate(mate, mateimagelabel, batchid, batchdata, xmin, xmax, ymin, ymax)
    local actor = actormanager_getfromactorid(mate.playerid)
    local matex = nil
    local matey = nil
    local matez = nil
    local mapid = 0
    if actor ~= nil then	
        matex = actor.attr.posx
        matey = actor.attr.posy
        matez = actor.attr.posz
        mapid = scene_getmapid()
        if actor:isdead() then
            mateimagelabel = csvlabelimage.map_teamdead
        end
    else
        matex = mate.posx
        matey = mate.posy
        matez = mate.posz
        mapid = mate.mapid
        if mate.hp <= 0.0 then
            mateimagelabel = csvlabelimage.map_teamdead
        end
    end
    if mapid == scene_getmapid() then
        local posx, posy = minimap_getradarpos(matex, matez, xmin, xmax, ymin, ymax)
        if posx ~= nil then
            local image_radar = minimap_getactorimage(mateimagelabel, minimapiconlayer.playerteam, 16)
            minimap_setradarimagebatch(batchid, batchdata, image_radar, posx, posy, 1.0, 0.0, xmin, xmax, ymin, ymax)
            batchdata[#batchdata + 1] = 1.0
            batchdata[#batchdata + 1] = 1.0
            batchdata[#batchdata + 1] = 1.0
            batchdata[#batchdata + 1] = 1.0
        end
    end
end

local function minimap_updateradar(xmin, xmax, ymin, ymax)
    for i=1,#m_minimap_layer do
        local radar_layer = m_minimap_layer[i]
        for key, val in pairs(radar_layer.image_type) do
            val.image_viewcount = 0
        end
	end

    local actorlist = actormanager_getactorlist()
    local selectvisible = false
    local batchid = {}
    local batchdata = {}
    for key, actor in pairs(actorlist) do
        local labelimage = actor.actordata.labelimage
        local labellayer = actor.actordata.labellayer
        local labelsize = actor.actordata.labelsize
        local color_r = actor.actordata.labelcolor_r or 1.0
        local color_g = actor.actordata.labelcolor_g or 1.0
        local color_b = actor.actordata.labelcolor_b or 1.0
        if m_minimap_tracenpcid ~= nil and actor:isnpc() then
            for i=1,#m_minimap_tracenpcid do
                if actor.config_npc.id == m_minimap_tracenpcid[i] then
                    labelimage = csvlabelimage.hint_system
                    labellayer = minimapiconlayer.npcquest
                    labelsize = nil
                    color_r = 1.0
                    color_g = 1.0
                    color_b = 1.0
                    break
                end
            end
        end
        if actor.actionmain.buffopacity ~= nil and actor.actionmain.buffopacity == 0.0 then
            labelimage = nil
        end
        if labelimage ~= nil then
            local posx, posy = minimap_getradarpos(actor.attr.posx, actor.attr.posz, xmin, xmax, ymin, ymax)
            if posx ~= nil then
                local image_radar = minimap_getactorimage(labelimage, labellayer, labelsize)
                minimap_setradarimagebatch(batchid, batchdata, image_radar, posx, posy, 1.0, 0.0, xmin, xmax, ymin, ymax)
                if actor:isdead() then
                    batchdata[#batchdata + 1] = color_r * 0.5
                    batchdata[#batchdata + 1] = color_g * 0.5
                    batchdata[#batchdata + 1] = color_b * 0.5
                    batchdata[#batchdata + 1] = 1.0
                else
                    batchdata[#batchdata + 1] = color_r
                    batchdata[#batchdata + 1] = color_g
                    batchdata[#batchdata + 1] = color_b
                    batchdata[#batchdata + 1] = 1.0
                end
                if actor.actorid == m_selectactorid and m_me ~= nil and actor:isdynamicnpc() then
                    minimap_setradarselect(actor, posx, posy, xmin, xmax, ymin, ymax)
                    selectvisible = true
                end
            end
        end
    end
    if playerattr_team ~= nil then
        for i=1,#playerattr_team.mate do
            local mate = playerattr_team.mate[i]
            minimap_addteammate(mate, csvlabelimage.map_team, batchid, batchdata, xmin, xmax, ymin, ymax)
        end
    end
    if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            local mate = playerattr_raid.mate[i]
            minimap_addteammate(mate, csvlabelimage.map_raid, batchid, batchdata, xmin, xmax, ymin, ymax)
        end
    end
    if #batchid > 0 then
        m_uiminimap:batch(batchid, batchdata)
    end
    if not selectvisible then
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_selectradar, false)
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select1, false)
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_select2, false)
    end
    local adjustrot = 90
    if m_minimap_radar.flipui > 0 then
        adjustrot = 270
    end
    local mevisible = false
    if m_me ~= nil then
        local posx, posy = minimap_getradarpos(m_me.attr.posx, m_me.attr.posz, xmin, xmax, ymin, ymax)
        if posx ~= nil then
            minimap_setradarimage(m_minimap_radar.radar_layer_me, posx, posy, 1.0, adjustrot - playerattr_info.rot, xmin, xmax, ymin, ymax)
            mevisible = true
        end
    end
    if not mevisible then
        minimap_setwidgetvisible(m_minimap_radar.radar_layer_me, false)
    end

    for i=1,#m_minimap_layer do
        local radar_layer = m_minimap_layer[i]
        for key, val in pairs(radar_layer.image_type) do
            for j=val.image_viewcount + 1,#val.image_radar do
                minimap_setwidgetvisible(val.image_radar[j], false)
            end 
        end
    end
end

local function minimap_updatemap(xmin, xmax, ymin, ymax)
    local totalu = (xmax - xmin) / m_minimap_radar.tilewidth
    local totalv = (ymax - ymin) / m_minimap_radar.tileheight

    local tilestartx = math.tointegerfloor(xmin / m_minimap_radar.tilewidth)
    local tilex = tilestartx
    local tiley = math.tointegerfloor(ymin / m_minimap_radar.tileheight)
    local widgetindex = 1
    local widgetx = 0
    local widgety = 0
    for i=1,9 do
        local u1 = 0.0
        local u2 = 1.0
        local v1 = 0.0
        local v2 = 1.0
        local pos = tilex * m_minimap_radar.tilewidth
        if pos < xmin then
            u1 = (xmin - pos) / m_minimap_radar.tilewidth
        end
        pos = pos + m_minimap_radar.tilewidth
        if pos > xmax then
            u2 = 1.0 - (pos - xmax) / m_minimap_radar.tilewidth
        end
        
        pos = tiley * m_minimap_radar.tileheight
        if pos < ymin then
            v1 = (ymin - pos) / m_minimap_radar.tileheight
        end
        pos = pos + m_minimap_radar.tileheight
        if pos > ymax then
            v2 = 1.0 - (pos - ymax) / m_minimap_radar.tileheight
        end

        if widgetindex > #m_minimap_radar.image_map then
            m_minimap_radar.image_map[widgetindex] = m_minimap_radar.image_map[1]:clone("image_map_" .. widgetindex)
        end
        local aiontilex = tiley
        local aiontiley = tilex
        local imagelayer = csvmap_getlayer(scene_getmapconfig(), playerattr_info.posy)
        local imagepath = nil
        local iamgeindex = aiontilex * m_minimap_radar.imagecountx + aiontiley
        if imagelayer ~= nil then
            imagepath = string.format("%s%d_%03d", m_minimap_radar.path, imagelayer, iamgeindex)
        else
            imagepath = string.format("%s%03d", m_minimap_radar.path, iamgeindex)
        end
        local widget = m_minimap_radar.image_map[widgetindex]
        if widget.path ~= imagepath then
            widget.path = imagepath
            widget:setraw(imagepath)
        end
        local imagew = (u2 - u1) / totalu * m_minimap_radar.minimapwidth
        local imageh = (v2 - v1) / totalv * m_minimap_radar.minimapheight
        local imagex = widgetx
        local imagey = widgety
        widgetx = widgetx + imagew

        local aionimagex = imagey
        local aionimagey = -imagex
        local aionimagew = imageh
        local aionimageh = imagew
        widget:setrect(aionimagex, aionimagey, aionimagew, aionimageh)

        local aionu = v1
        local aionv = u1
        local aionw = v2 - v1
        local aionh = u2 - u1
        widget:setrawuv(aionu, 1.0 - (aionv + aionh), aionw, aionh)
        minimap_setwidgetvisible(widget, true)

        widgetindex = widgetindex + 1
        tilex = tilex + 1
        if u2 < 1.0 or tilex >= m_minimap_radar.imagecountx then
            if v2 < 1.0 or tiley >= m_minimap_radar.imagecounty then
                break
            end
            tilex = tilestartx
            tiley = tiley + 1
            widgetx = 0.0
            widgety = widgety + imageh
        end
    end
    for i=widgetindex,#m_minimap_radar.image_map do
        minimap_setwidgetvisible(m_minimap_radar.image_map[i], false)
    end
end

local function minmap_initradar(name)
    radarlayer = {}
    radarlayer.image_name = name
    radarlayer.image_src = m_uiminimap:getwidget(string.format("minimap/%s/%s_1", name, name))
    radarlayer.image_src:setvisiblenothit(false)
    radarlayer.image_src.visible = false
    radarlayer.image_count = 0
    radarlayer.image_type = {}
    return radarlayer;
end

function minimap_onopen()
    local minimap = m_uiminimap:getwidget("minimap")
    m_minimap_radar.minimapwidth, m_minimap_radar.minimapheight = minimap:getsize()
    m_minimap_radar.image_map = {}
    m_minimap_radar.image_map[1] = m_uiminimap:getwidget("minimap/image_map/image_map_1")
    m_minimap_radar.image_map[1].visible = true

    m_minimap_layer = {}
    m_minimap_layer[minimapiconlayer.npcnormal] = minmap_initradar("image_npcnormal")
    m_minimap_layer[minimapiconlayer.npcfriend] = minmap_initradar("image_npcfriend")
    m_minimap_layer[minimapiconlayer.npcenemy] = minmap_initradar("image_npcenemy")
    m_minimap_layer[minimapiconlayer.npclabel] = minmap_initradar("image_npclabel")
    m_minimap_layer[minimapiconlayer.npcquest] = minmap_initradar("image_npcquest")
    m_minimap_layer[minimapiconlayer.playerteam] = minmap_initradar("image_playerteam")
    m_minimap_layer[minimapiconlayer.playerenemy] = minmap_initradar("image_playerenemy")
    
    m_minimap_radar.radar_layer_me = m_uiminimap:getwidget("minimap/image_me")
    m_minimap_radar.radar_layer_selectradar = m_uiminimap:getwidget("minimap/image_selectradar")
    m_minimap_radar.radar_layer_select1 = m_uiminimap:getwidget("minimap/image_select1")
    m_minimap_radar.radar_layer_select2 = m_uiminimap:getwidget("minimap/image_select2")
    m_minimap_radar.radar_time = 0
    local w, h = m_minimap_radar.radar_layer_selectradar:getsize()
    m_minimap_radar.radar_selectradarradius = w / 2

    minimapadditive_init()
    event_register(eventtype.update, minimap_update, m_uiminimap)
end

function minimap_update()
    if m_uiminimap:null() then
        return
    end
    minimapadditive_update()
    if m_minimap_radar.scenename == nil or m_minimap_radar.path == nil then
        return
    end
    local scale = gamesetting_getnumber("MINIMAPSCALE")
    local viewrange = m_minimap_viewrangestandard * scale
    local centerx = playerattr_info.posx - m_minimap_radar.zonex
    local centery = playerattr_info.posz - m_minimap_radar.zoney
    if m_minimap_radar.flipui > 0 then
        centerx = m_minimap_radar.zonewidth - centerx
        centery = m_minimap_radar.zoneheight - centery
    end
    local xmin = centerx - viewrange
    local xmax = centerx + viewrange
    local ymin = centery - viewrange
    local ymax = centery + viewrange
    if xmin < 0 then
        xmax = xmax - xmin
    end
    if xmax > m_minimap_radar.zonewidth then
        xmin = xmin - (xmax - m_minimap_radar.zonewidth)
    end
    if ymin < 0 then
        ymax = ymax - ymin
    end
    if ymax > m_minimap_radar.zoneheight then
        ymin = ymin - (ymax - m_minimap_radar.zoneheight)
    end
    xmin = math.clamp(xmin, 0.0, m_minimap_radar.zonewidth)
    xmax = math.clamp(xmax, 0.0, m_minimap_radar.zonewidth)
    ymin = math.clamp(ymin, 0.0, m_minimap_radar.zoneheight)
    ymax = math.clamp(ymax, 0.0, m_minimap_radar.zoneheight)

    minimap_updatemap(xmin, xmax, ymin, ymax)
    minimap_updateradar(xmin, xmax, ymin, ymax)
end

function minimap_settracenpc(npcid)
    m_minimap_tracenpcid = npcid
end

function minimap_settraceharvest(point)
    m_minimap_traceharvest = point
end

function minimap_gettraceharvest(point)
    return m_minimap_traceharvest
end

function minimap_setempty()
    if m_uiminimap:null() then
        return
    end
    local widget = m_minimap_radar.image_map[1]
    widget.path = "map/none_minimap"
    widget:setraw(widget.path)
    widget:setrect(0, 0, m_minimap_radar.minimapwidth, m_minimap_radar.minimapheight)
    widget:setrawuv(0.0, 0.0, 1.0, 1.0)

    widget.visible = true
    widget:setvisiblenothit(true)

    for i=2,#m_minimap_radar.image_map do
        minimap_setwidgetvisible(m_minimap_radar.image_map[i], false)
    end
    minimap_setwidgetvisible(m_minimap_radar.radar_layer_me, false)
    minimap_setwidgetvisible(m_minimap_radar.radar_layer_selectradar, false)
    minimap_setwidgetvisible(m_minimap_radar.radar_layer_select1, false)
    minimap_setwidgetvisible(m_minimap_radar.radar_layer_select2, false)

    for i=1,#m_minimap_layer do
        local radar_layer = m_minimap_layer[i]
        for key, val in pairs(radar_layer.image_type) do
            for j=1,#val.image_radar do
                minimap_setwidgetvisible(val.image_radar[j], false)
            end 
        end
    end
end
function minimap_setradar(config_map, radarname)
    local scenename = config_map.scene
    if m_minimap_radar.scenename == scenename then
        return
    end
    m_minimap_radar.scenename = scenename
    m_minimap_radar.path = string.format("map/%s/%s_", scenename, scenename)
    if scene_getmapconfig().layer1 == 0 then
        local imagepath = string.format("%s000", m_minimap_radar.path)
        local imagewidth, imageheight = c_uigettexturesize(unity_uitexturepath(imagepath))
        if imagewidth == 0.0 or imageheight == 0.0 then
            m_minimap_radar.path = nil
            minimap_setempty()
            return
        end
    end
    m_minimap_radar.zonex = config_map.zonex
    m_minimap_radar.zoney = config_map.zoney
    m_minimap_radar.zonewidth = config_map.zonewidth
    m_minimap_radar.zoneheight = config_map.zoneheight
    m_minimap_radar.flipui = config_map.flipui
    m_minimap_radar.imagecountx = 3
    m_minimap_radar.imagecounty = 3
    m_minimap_radar.tilewidth = config_map.zonewidth / m_minimap_radar.imagecountx
    m_minimap_radar.tileheight = config_map.zoneheight / m_minimap_radar.imagecounty
    minimap_update()
end
