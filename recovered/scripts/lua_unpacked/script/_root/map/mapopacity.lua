
local m_uimap_opacity = uipanel_createhandle("map/map_opacity", uilayer.top, 0, AudioOpenUI, AudioCloseUI)
local m_uimap_opaicty_npcpath = "mapicon/image_npc/image_npc_"
local m_uimap_opaicty_teampath = "mapicon/image_team/image_team_"
local m_uimap_opaicty_locationpath = "mapicon/image_location/image_location_"

function map_opacity_onopen()
    m_uimap_opacity.mapid = 0
    m_uimap_opacity.maplayer = 1
    m_uimap_opacity.npctemplate = m_uimap_opacity:getwidget(m_uimap_opaicty_npcpath .. 1)
    m_uimap_opacity.teamtemplate = m_uimap_opacity:getwidget(m_uimap_opaicty_teampath .. 1)
    m_uimap_opacity.locationtemplate = m_uimap_opacity:getwidget(m_uimap_opaicty_locationpath .. 1)

    map_opacity_setopacity(gamesetting_getnumberdata("MAPOPACITY"))
    event_register(eventtype.update, map_opacity_update, m_uimap_opacity)
end

function map_opacity_openui()
    if m_uimap_opacity:alive() then
        m_uimap_opacity:close()
    else
        map_main_delegate_close()
        m_uimap_opacity:open()
        map_opacity_loadmap()
    end
end

function map_opacity_close()
    m_uimap_opacity:close()
end

function map_opacity_setopacity(opacity)
    m_uimap_opacity:setopacity(opacity)
end

function map_opacity_loadmap()
    local config_map = scene_getmapconfig()
    if config_map == nil then
        m_uimap_opacity:close()
        return
    end
    local imagelayer = csvmap_getlayer(config_map, playerattr_info.posy)
    if config_map.id == m_uimap_opacity.mapid and imagelayer == m_uimap_opacity.maplayer then
        return
    end
    m_uimap_opacity.mapid = config_map.id
    m_uimap_opacity.maplayer = imagelayer

    local scenename = config_map.scene
    local imagepath = nil
    if imagelayer ~= nil then
        imagepath = string.format("map/%s/%s_%d_a", scenename, scenename, imagelayer)
    else
        imagepath = string.format("map/%s/%s_a", scenename, scenename)
    end
    local imagewidth, imageheight = c_uigettexturesize(unity_uitexturepath(imagepath))
    if imagewidth == 0.0 or imageheight == 0.0 then
        m_uimap_opacity:close()
        return
    end
    local image_map = m_uimap_opacity:getwidget("image_map")
    image_map:setraw(imagepath)
    m_uimap_opacity.viewwidth, m_uimap_opacity.viewheight = image_map:getsize()
    m_uimap_opacity.image_me = m_uimap_opacity:getwidget("mapicon/image_me")
    mapopacity_updateui()
end

local function mapopacity_addnpcpositionicon(npcicon, config_map, worldpos)
    local visible = true
    if visible then
        local layer = csvmap_getlayer(config_map, worldpos.y)
        if layer ~= nil and layer ~= m_uimap_opacity.maplayer then
            visible = false
        end
    end
    if visible then
        local image_npc = m_uimap_opacity:getwidget(m_uimap_opaicty_npcpath .. m_uimap_opacity.npccount)
        if image_npc == nil then
            image_npc = m_uimap_opacity.npctemplate:clone("image_npc_" .. m_uimap_opacity.npccount)
        end
        image_npc:setvisiblenothit(true)
        if image_npc.sprite == nil or image_npc.sprite ~= npcicon.image then
            image_npc.sprite = npcicon.image
            image_npc:setsprite(npcicon.image)
        end
        image_npc:setsize(npcicon.width * 2, npcicon.height * 2)
        local uix, uiy = mapopacity_worldtoui(worldpos.x, worldpos.z)
        image_npc:setposition(uix, uiy)
        m_uimap_opacity.npccount = m_uimap_opacity.npccount + 1
    end
end
local function mapopacity_addnpcicon(npcid, npcicon)
    local config_map = scene_getmapconfig()
    local config_spawn = csvnpcspawn_getmapspawnnpc(npcid)
    if config_spawn ~= nil and #config_spawn > 0 and (config_map.id == config_spawn[1].mapid) then
        for spawnindex=1,#config_spawn do
            local spawnposition = csvspawn_parsepoint(config_spawn[spawnindex])
            if spawnposition ~= nil and #spawnposition > 0 then
                for positionindex=1,#spawnposition do
                    mapopacity_addnpcpositionicon(npcicon, config_map, spawnposition[positionindex])
                end
            end
        end
    end
    local config_spawnstatic = csvnpcstatic_getfromnpcid(npcid)
	if config_spawnstatic ~= nil and #config_spawnstatic > 0 and (config_map.id == config_spawnstatic[1].id) then
        for spawnindex=1,#config_spawnstatic do
            local spawnposition = csvspawn_parsepoint(config_spawnstatic[spawnindex])
            if spawnposition ~= nil and #spawnposition > 0 then
                for positionindex=1,#spawnposition do
                    mapopacity_addnpcpositionicon(npcicon, config_map, spawnposition[positionindex])
                end
            end
        end
	end
end

local function mapopacity_addlocation(location)
    local config_map = scene_getmapconfig()
    if config_map.id ~= location.mapid then
        return
    end
    local layer = csvmap_getlayer(config_map, location.worldy)
    if layer ~= nil and layer ~= m_uimap_opacity.maplayer then
        return
    end
    local imagelabel = nil
    if location.type == maplabeltype.systemlocation then
        imagelabel = csvlabelimage.hint_system
    else
        imagelabel = csvlabelimage.hint_player
    end
    local image_location = m_uimap_opacity.locationtemplate
    m_uimap_opacity.locationcount = m_uimap_opacity.locationcount + 1
    image_location:setvisiblenothit(true)
    if image_location.sprite == nil or image_location.sprite ~= imagelabel.image then
        image_location.sprite = imagelabel.image
        image_location:setsprite(imagelabel.image)
    end
    image_location:setsize(imagelabel.width * 2, imagelabel.height * 2)
    local uix, uiy = mapopacity_worldtoui(location.worldx, location.worldz)
    image_location:setposition(uix, uiy)
end

function mapopacity_updateui()
    if m_uimap_opacity:null() then
        return
    end
    m_uimap_opacity.npccount = 1
    m_uimap_opacity.locationcount = 1
    for npcid, npcicon in pairs(playerattr_questnpcicon) do
        mapopacity_addnpcicon(npcid, npcicon)
    end

    local location = maplabel_getlocation()
    if location ~= nil then
        mapopacity_addlocation(location)
    end

    m_uimap_opacity:hideunused(m_uimap_opaicty_npcpath, m_uimap_opacity.npccount)
    m_uimap_opacity:hideunused(m_uimap_opaicty_teampath, 1)
    m_uimap_opacity:hideunused(m_uimap_opaicty_locationpath, m_uimap_opacity.locationcount)
end

function mapopacity_worldtoui(worldx, worldy)
	local config_map = scene_getmapconfig()
	local x = (worldx - config_map.zonex) / config_map.zonewidth * m_uimap_opacity.viewwidth
	local y = (worldy - config_map.zoney) / config_map.zoneheight * m_uimap_opacity.viewheight
	if config_map.flipui > 0 then
		return m_uimap_opacity.viewheight - y, x
	else
		return y, m_uimap_opacity.viewheight - x
	end
end

local function mapopacity_updateteammate(mate, imagelabel)
    local matex = nil
    local matey = nil
    local matez = nil
    local mapid = 0
    local actor = actormanager_getfromactorid(mate.playerid)
    if actor ~= nil then	
        matex = actor.attr.posx
        matey = actor.attr.posy
        matez = actor.attr.posz
        mapid = scene_getmapid()
        if actor:isdead() then
            imagelabel = csvlabelimage.map_teamdead
        end
    else
        matex = mate.posx
        matey = mate.posy
        matez = mate.posz
        mapid = mate.mapid
        if mate.hp <= 0.0 then
            imagelabel = csvlabelimage.map_teamdead
        end
    end
    local config_map = scene_getmapconfig()
    if config_map.id ~= mapid then
        return
    end
    local layer = csvmap_getlayer(config_map, matey)
    if layer ~= nil and layer ~= m_uimap_opacity.maplayer then
        return
    end
    local image_team = m_uimap_opacity.teamtemplate
    m_uimap_opacity.teamcount = m_uimap_opacity.teamcount + 1
    image_team:setvisiblenothit(true)
    if image_team.sprite == nil or image_team.sprite ~= imagelabel.image then
        image_team.sprite = imagelabel.image
        image_team:setsprite(imagelabel.image)
    end
    image_team:setsize(imagelabel.width * 2, imagelabel.height * 2)
    local uix, uiy = mapopacity_worldtoui(matex, matez)
    image_team:setposition(uix, uiy)
end

function map_opacity_update()
    if m_uimap_opacity:null() then
        return
    end
    map_opacity_loadmap()
    if m_uimap_opacity:null() then
        return
    end
    local config_map = scene_getmapconfig()
    local x, y = mapopacity_worldtoui(playerattr_info.posx, playerattr_info.posz)
    local adjustrot = 90
    if config_map.flipui > 0 then
        adjustrot = 270
    end
    m_uimap_opacity.image_me:settransform(0.5, 0.5, x, y, 1.0, 1.0, 0.0, 0.0, adjustrot - playerattr_info.rot)

    m_uimap_opacity.teamcount = 1
    if playerattr_team ~= nil then
        for i=1,#playerattr_team.mate do
			mapopacity_updateteammate(playerattr_team.mate[i], csvlabelimage.map_team)
        end
    elseif playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            if playerattr_raid.mate[i].playerid ~= playerattr_info.actorid then
                mapopacity_updateteammate(playerattr_raid.mate[i], csvlabelimage.map_raid)
            end
        end
    end
    m_uimap_opacity:hideunused(m_uimap_opaicty_teampath, m_uimap_opacity.teamcount)
end
