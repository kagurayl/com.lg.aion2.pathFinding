
maplabeltype =
{
	none = 0,
	zonename = 1,
    modnpc = 2,
    quest = 3,
	dungeon = 4,
	abysscastle = 5,
	abyssartifact = 6,
	abysscarrier = 7,
	team = 8,
	location = 9,
	questzone = 10,
	systemlocation = 11,
	playerlocation = 12,
	portal = 13,
}

local m_maplabel_widgetid = 0
local m_maplabel_widget = {}
local m_maplabel_widgetflicker = {}

function maplabel_flickerme()
	local image_me = m_uimap_main:getwidget("scene_root/canvas_move/image_me")
	image_me.flickertime = time_game
end

function maplabel_updateui()
	m_maplabel_widget = {}
	m_maplabel_widgetflicker = {}
	local config_map = mapview_getmapconfig()
	maplabel_updatezonename(m_maplabel_widget, config_map)
	maplabel_updatenpc(m_maplabel_widget, m_maplabel_widgetflicker, config_map)
	maplabel_updatequestlocate(m_maplabel_widget, m_maplabel_widgetflicker, config_map)
	maplabel_updatelocation(m_maplabel_widget, m_maplabel_widgetflicker, config_map)
	maplabel_updatetypevisible()
end

function maplabel_updatetypevisible()
	local visiblewidth, visibleheight = mapview_getvisiblesize()
	local visiblesize = math.max(visiblewidth, visibleheight)
	local modnpcvisible = visiblesize < 1500
	local zonenamevisiblesize = math.max(visiblewidth, visibleheight) * 0.15
	for i=1,#m_maplabel_widget do
		local widget = m_maplabel_widget[i]
		if widget.labeltype == maplabeltype.zonename then
			if (widget.x2 - widget.x1) > zonenamevisiblesize or (widget.y2 - widget.y1) > zonenamevisiblesize then
				local uix, uiy = mapview_worldtoui((widget.x2 + widget.x1) / 2, (widget.y2 + widget.y1) / 2)
				widget:setposition(uix, uiy)
				widget:setvisiblenothit(true)
			else
				widget:setvisiblenothit(false)
			end
		elseif widget.labeltype == maplabeltype.modnpc then
			widget:setvisiblenothit(modnpcvisible)
			local uix, uiy = mapview_worldtoui(widget.worldx, widget.worldz)
			widget:setposition(uix, uiy)
		elseif widget.labeltype ~= maplabeltype.none then
			widget:setvisiblenothit(true)
			local uix, uiy = mapview_worldtoui(widget.worldx, widget.worldz)
			widget:setposition(uix, uiy)
		end
		if widget.width ~= nil then
			widget:setsize(widget.width * mapview_getscale(), widget.height * mapview_getscale())
		end
	end
end

local function maplabel_addteam(mate, teamcount, imagelabel, imageteampath, image_team_template)
	local matex = nil
	local matey = nil
	local matez = nil
	local config_map = mapview_getmapconfig()
	local actor = actormanager_getfromactorid(mate.playerid)
	if actor ~= nil then	
		if scene_getmapid() == config_map.id then
			matex = actor.attr.posx
			matey = actor.attr.posy
			matez = actor.attr.posz
			if actor:isdead() then
				imagelabel = csvlabelimage.map_teamdead
			end
		end
	elseif mate.mapid == config_map.id then
		matex = mate.posx
		matey = mate.posy
		matez = mate.posz
		if mate.hp <= 0.0 then
			imagelabel = csvlabelimage.map_teamdead
		end
	end
	if matex ~= nil and maplabel_layervisible(matey) then
		local image_team = m_uimap_main:getwidget(imageteampath .. teamcount)
		if image_team == nil then
			image_team = image_team_template:clone("image_team_" .. teamcount)
		end
		if image_team.sprite == nil or image_team.sprite ~= imagelabel.image then
			image_team.sprite = imagelabel.image
			image_team:setsprite(imagelabel.image)
		end
		image_team:setsize(imagelabel.width * 2, imagelabel.height * 2)
		image_team.worldx = matex
		image_team.worldz = matez
		image_team.labeltype = maplabeltype.team
		image_team:setvisiblenothit(true)
		local uix, uiy = mapview_worldtoui(image_team.worldx, image_team.worldz)
		image_team:setposition(uix, uiy)
		return true
	end
	return false
end
function maplabel_updateteam()
	local teamcount = 1
	local imageteampath = "scene_root/canvas_move/canvas_team/image_team_"
	if playerattr_team ~= nil then
		local image_team_template = m_uimap_main:getwidget(imageteampath .. 1)
		for i=1,#playerattr_team.mate do
			local mate = playerattr_team.mate[i]
			if maplabel_addteam(mate, teamcount, csvlabelimage.map_team, imageteampath, image_team_template) then
				teamcount = teamcount + 1
			end
		end
	elseif playerattr_raid ~= nil then
		local image_team_template = m_uimap_main:getwidget(imageteampath .. 1)
		for i=1,#playerattr_raid.mate do
			local mate = playerattr_raid.mate[i]
			if mate.playerid ~= playerattr_info.actorid then
				if maplabel_addteam(mate, teamcount, csvlabelimage.map_raid, imageteampath, image_team_template) then
					teamcount = teamcount + 1
				end
			end
		end
	end
	m_uimap_main:hideunused(imageteampath, teamcount)
end

function maplabel_layervisible(posy)
	local layer = mapview_getlayer()
	if layer ~= nil and csvmap_getlayer(mapview_getmap(), posy) ~= layer then
		return false
	end
	return true
end

function maplabel_rangelayervisible(bottom, top)
	local layer = mapview_getlayer()
	if layer ~= nil and csvmap_getrangelayer(mapview_getmap(), bottom, top) ~= layer then
		return false
	end
	return true
end

function maplabel_update()
	for i=#m_maplabel_widgetflicker,1,-1 do
		local widget = m_maplabel_widgetflicker[i]
		if widget.flickertime ~= nil then
			local flickertime = (time_game - widget.flickertime) * 2
			local flickervisible = true
			if flickertime <= 6 then
				if flickertime - math.floor(flickertime) < 0.5 then
					flickervisible = false
				end
			else
				flickervisible = true
				widget.flickertime = nil
				table.remove(m_maplabel_widgetflicker, i)
			end
			widget:setvisiblenothit(flickervisible)
		elseif widget.labeltype == maplabeltype.abysscarrier then
			local time = (time_game - widget.timestart) / (widget.timeend - widget.timestart)
			if time < 1.0 then
				widget.worldx = math.lerp(widget.posstartx, widget.posendx, time)
				widget.worldz = math.lerp(widget.posstartz, widget.posendz, time)
				local uix, uiy = mapview_worldtoui(widget.worldx, widget.worldz)
				widget:setposition(uix, uiy)
			else
				widget.labeltype = maplabeltype.none
				widget:setvisiblenothit(false)
				table.remove(m_maplabel_widgetflicker, i)
			end
		end
	end
	local mapconfig = mapview_getmapconfig()
	local minevisible = mapconfig ~= nil and mapconfig.id == playerattr_info.mapid and maplabel_layervisible(playerattr_info.posy)
	local image_me = m_uimap_main:getwidget("scene_root/canvas_move/image_me")
	if minevisible and image_me.flickertime ~= nil then
		local flickertime = (time_game - image_me.flickertime) * 2
		if flickertime <= 6 then
			if flickertime - math.floor(flickertime) < 0.5 then
				minevisible = false
			end
		else
			image_me.flickertime = nil
		end
	end
	image_me:setvisiblenothit(minevisible)
	if minevisible then
		local x, y = mapview_worldtoui(playerattr_info.posx, playerattr_info.posz)
		image_me:setvisiblenothit(true)
		local adjustrot = 90
		if mapconfig ~= nil and mapconfig.flipui > 0 then
			adjustrot = 270
		end
		image_me:settransform(0.5, 0.5, x, y, 1.0, 1.0, 0.0, 0.0, adjustrot - playerattr_info.rot)
	end
end
