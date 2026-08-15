
local m_mapview_mapconfig = nil
local m_mapview_maplayer = nil
local m_mapview_image = nil
local m_mapview_view = {colmax = 3, rowmax = 3, scalemax = 5.0}
local m_mapview_drag = {}

function mapview_reset()
    m_mapview_mapconfig = nil
	m_mapview_maplayer = nil
end

function mapview_openformap(config_map)
	if not csvmap_hasmap(config_map) then
		return false
	end
	return true
end

function mapview_setmapid(mapid, maplayer)
	if m_uimap_main:alive() and m_mapview_mapconfig ~= nil and m_mapview_mapconfig.id == mapid then
		maplabel_updateui()
		return true
	else
		local config_map = csvmap_getfromid(mapid)
		if mapview_openformap(config_map) then
			m_uimap_main:open()
			mapview_setmap(config_map, maplayer)
			return true
		end
	end
	return false
end

function mapview_getmap()
	return m_mapview_mapconfig
end

function mapview_getlayer(config_map)
	return m_mapview_maplayer
end

function mapview_setmap(config_map, maplayer)
	m_uimap_main:setwidgetvisible("scene_root/canvas_subui", false)
    m_uimap_main:setwidgetvisible("scene_root/canvas_move", true)
	m_mapview_mapconfig = config_map
	m_mapview_maplayer = maplayer
	if m_mapview_mapconfig == nil then
		m_uimap_main:hideunused("scene_root/image_scene_", 1)
		m_mapview_image = nil
		return
	end

	local text_mapname = m_uimap_main:getwidget("text_mapname")
	text_mapname:settext("STR_ZONE_NAME_" .. string.upper(config_map.scene))

	local scene_root = m_uimap_main:getwidget("scene_root")
	scene_root:setdelegate(mapview_delegate_imageroot)
	m_mapview_view.x = 0.0
	m_mapview_view.y = 0.0
	m_mapview_view.scale = 1.0
	m_mapview_view.rootwidth, m_mapview_view.rootheight = scene_root:getsize()
	m_mapview_view.viewwidth = m_mapview_view.rootwidth
	m_mapview_view.viewheight = m_mapview_view.rootheight
	m_mapview_view.config_map = config_map

	m_mapview_drag = {}
	m_mapview_image = {}
	for i=1,9 do
		local image_scene = m_uimap_main:getwidget("scene_root/canvas_move/canvas_bg/image_scene_" .. i)
		if image_scene == nil then
			local image_scene1 = m_uimap_main:getwidget("scene_root/canvas_move/canvas_bg/image_scene_1")
			image_scene = image_scene1:clone("image_scene_" .. i)
		end
		local row = math.tointegerfloor((i - 1) % m_mapview_view.rowmax)
		local col = math.tointegerfloor((i - 1) / m_mapview_view.colmax)
		local imageindex = (m_mapview_view.rowmax - 1 - row) + m_mapview_view.rowmax * col
        local imagepath = nil
        if maplayer ~= nil then
            imagepath = string.format("map/%s/%s_%d_%03d", config_map.scene, config_map.scene, maplayer, imageindex)
        else
            imagepath = string.format("map/%s/%s_%03d", config_map.scene, config_map.scene, imageindex)
        end
		image_scene:setraw(imagepath)
		m_mapview_image[i] = image_scene
	end
	mapview_updatemask()
	mapview_updateui()
	maplabel_updateui()
end

function mapview_updatemask()
	if m_uimap_main:null() or m_mapview_view.config_map == nil then
		return
	end
	local image_fogmask = m_uimap_main:getwidget("scene_root/canvas_move/image_fogmask")
	if m_mapview_view.config_map.fogmask > 0 then
		playerfogmask_createmasktexture(m_mapview_view.config_map.id)
		image_fogmask:setvisiblenothit(true)
		image_fogmask:applyfogmask(m_mapview_view.config_map.zonex, m_mapview_view.config_map.zoney, m_mapview_view.config_map.zonewidth, m_mapview_view.config_map.zoneheight)
	else
		image_fogmask:setvisiblenothit(false)
	end
end

function mapview_updateui()
	local canvas_move = m_uimap_main:getwidget("scene_root/canvas_move")
	canvas_move:setposition(-m_mapview_view.x, -m_mapview_view.y)
	local image_x = 0.0
	local image_y = 0.0
	local imagewidth = m_mapview_view.viewwidth / m_mapview_view.colmax
	local imageheight = m_mapview_view.viewheight / m_mapview_view.rowmax
	for i=1,#m_mapview_image do
		local row = math.tointegerfloor((i - 1) % m_mapview_view.rowmax)
		local col = math.tointegerfloor((i - 1) / m_mapview_view.colmax)
		local image_scene = m_mapview_image[i]
		local x = col * imagewidth
		local y = row * imageheight
		image_scene:setposition(image_x + imagewidth * col, image_y + imageheight * row)
		image_scene:setsize(imagewidth, imageheight)
	end

	local image_fogmask = m_uimap_main:getwidget("scene_root/canvas_move/image_fogmask")
	image_fogmask:setsize(m_mapview_view.viewwidth, m_mapview_view.viewheight)
end

function mapview_setscale(scale, screenx, screeny)
	local scene_root = m_uimap_main:getwidget("scene_root")
	local x,y,w,h = scene_root:getabsolute()
	local focusx = (screenx - x) / m_mapview_view.rootwidth / m_mapview_view.scale * m_mapview_view.viewwidth + m_mapview_view.x
	local focusy = (screeny - y) / m_mapview_view.rootheight / m_mapview_view.scale * m_mapview_view.viewheight + m_mapview_view.y
	focusx = focusx / m_mapview_view.viewwidth
	focusy = focusy / m_mapview_view.viewheight
	m_mapview_view.scale = math.clamp(m_mapview_view.scale + scale, 1.0, m_mapview_view.scalemax)
	m_mapview_view.viewwidth = m_mapview_view.rootwidth * m_mapview_view.scale
	m_mapview_view.viewheight = m_mapview_view.rootheight * m_mapview_view.scale
	focusx = focusx * m_mapview_view.viewwidth
	focusy = focusy * m_mapview_view.viewheight
	m_mapview_view.x = focusx - (screenx - x) / m_mapview_view.rootwidth / m_mapview_view.scale * m_mapview_view.viewwidth
	m_mapview_view.y = focusy - (screeny - y) / m_mapview_view.rootheight / m_mapview_view.scale * m_mapview_view.viewheight
	m_mapview_view.x = math.clamp(m_mapview_view.x, 0.0, m_mapview_view.viewwidth - m_mapview_view.rootwidth)
	m_mapview_view.y = math.clamp(m_mapview_view.y, 0.0, m_mapview_view.viewheight - m_mapview_view.rootheight)
	mapview_updateui()
	maplabel_updatetypevisible()
end

function mapview_getmapconfig()
	return m_mapview_view.config_map
end

function mapview_getvisiblesize()
	local w = m_mapview_view.rootwidth / m_mapview_view.viewwidth * m_mapview_view.config_map.zonewidth
	local h = m_mapview_view.rootheight / m_mapview_view.viewheight * m_mapview_view.config_map.zoneheight
	return w, h
end

function mapview_getscale()
	return m_mapview_view.scale
end

function mapview_worldtoui(worldx, worldy)
	local config_map = m_mapview_view.config_map
	local x = (worldx - config_map.zonex) / config_map.zonewidth * m_mapview_view.viewwidth
	local y = (worldy - config_map.zoney) / config_map.zoneheight * m_mapview_view.viewheight
	if config_map.flipui > 0 then
		return m_mapview_view.viewheight - y, x
	else
		return y, m_mapview_view.viewheight - x
	end
end

function mapview_delegate_imageroot(sender, event)
    if event.name == "mousewheel" then
		mapview_setscale(event.wheely * mousewheelscale / 10.0, event.mousex, event.mousey)
	elseif event.name == "dragstart" then
		local exist = false
		for i=1,#m_mapview_drag do
			if m_mapview_drag[i].finger == event.finger then
				exist = true
				break
			end
		end
		if not exist then
			local drag = {}
			drag.finger = event.finger
			drag.mousex = event.mousex
			drag.mousey = event.mousey
			m_mapview_drag[#m_mapview_drag + 1] = drag
		end
	elseif event.name == "drag" then
		if #m_mapview_drag > 1 then
			local centerx = 0
			local centery = 0
			local dragdata = nil
			for i=1,#m_mapview_drag do
				if m_mapview_drag[i].finger == event.finger then
					dragdata = m_mapview_drag[i]
				end
				centerx = centerx + m_mapview_drag[i].mousex
				centery = centery + m_mapview_drag[i].mousey
			end
			centerx = centerx / #m_mapview_drag
			centery = centery / #m_mapview_drag
			if dragdata ~= nil then
				local distprev = vector2_distance(centerx, centery, dragdata.mousex, dragdata.mousey)
				local dist = vector2_distance(centerx, centery, event.mousex, event.mousey)
				dragdata.mousex = event.mousex
				dragdata.mousey = event.mousey
				mapview_setscale((dist - distprev) / 200.0, centerx, centery)
			end
		elseif #m_mapview_drag > 0 then
			local offsetx = event.mousex - m_mapview_drag[1].mousex
			local offsety = event.mousey - m_mapview_drag[1].mousey
			m_mapview_view.x = math.clamp(m_mapview_view.x - offsetx, 0.0, m_mapview_view.viewwidth - m_mapview_view.rootwidth)
			m_mapview_view.y = math.clamp(m_mapview_view.y - offsety, 0.0, m_mapview_view.viewheight - m_mapview_view.rootheight)
			local canvas_move = m_uimap_main:getwidget("scene_root/canvas_move")
			canvas_move:setposition(-m_mapview_view.x, -m_mapview_view.y)
			m_mapview_drag[1].mousex = event.mousex
			m_mapview_drag[1].mousey = event.mousey
		end
	elseif event.name == "dragend" then
		for i=1,#m_mapview_drag do
			if m_mapview_drag[i].finger == event.finger then
				table.remove(m_mapview_drag, i)
				break
			end
		end
    end
end
