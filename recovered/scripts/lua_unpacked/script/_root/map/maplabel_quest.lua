
local m_maplabel_questid = 0
local m_maplabel_queststep = 0
local m_maplabel_questlambdaindex = 0
local m_maplabel_questmapid = 0
local m_maplabel_questflicker = 0
local m_maplabel_questzone = nil
local m_maplabel_questlocatecount = 0

function maplabel_questreset()
	m_maplabel_questid = 0
	m_maplabel_queststep = 0
	m_maplabel_questlambdaindex = 0
	m_maplabel_questmapid = 0
	m_maplabel_questflicker = 0
	m_maplabel_questzone = nil
	m_maplabel_questlocatecount = 0
end

local function maplabel_addquestkill(position, rectarray)
	local range = 50.0
	local left = position.x - range
	local top = position.z - range
	local right = position.x + range
	local bottom = position.z + range
	local rc = {}
	rc.left = left
	rc.top = top
	rc.right = right
	rc.bottom = bottom
	rc.height = position.y
	rectarray[#rectarray + 1] = rc
end
function maplabel_setquestkill(questid, queststep, questlambdaindex, npcidarray)
	maplabel_questreset()
	if npcidarray == nil or #npcidarray == 0 then
		if m_uimap_main:alive() then
			maplabel_updateui()
		end
		return false
	end
	local rectarray = {}
	local mapid = nil
	for i=1,#npcidarray do
		local npcid = npcidarray[i]
		local config_spawn = csvnpcspawn_getmapspawnnpc(npcid)
		if config_spawn ~= nil and #config_spawn > 0 and (mapid == nil or mapid == config_spawn[1].mapid) then
			local spawnposition = csvspawn_parsepoint(config_spawn[1])
			if spawnposition ~= nil and #spawnposition > 0 then
				if mapid == nil then
					mapid = config_spawn[1].mapid
				end
				for j=1,#spawnposition do
					maplabel_addquestkill(spawnposition[j], rectarray)
				end
			end
		end
		local config_spawnstatic = csvnpcstatic_getfromnpcid(npcid)
		if config_spawnstatic ~= nil and #config_spawnstatic > 0 and (mapid == nil or mapid == config_spawnstatic[1].id) then
			local spawnposition = csvspawn_parsepoint(config_spawnstatic[1])
			if spawnposition ~= nil and #spawnposition > 0 then
				if mapid == nil then
					mapid = config_spawnstatic[1].id
				end
				for j=1,#spawnposition do
					maplabel_addquestkill(spawnposition[j], rectarray)
				end
			end
		end
	end
	if mapid == nil then
		return false
	end
	while true do
		local combine = false
		for index1=1,#rectarray do
			local rc1 = rectarray[index1]
			for index2=index1 + 1,#rectarray do
				local rc2 = rectarray[index2]
				if math.boxintersect(rc1.left, rc1.top, rc1.right, rc1.bottom, rc2.left, rc2.top, rc2.right, rc2.bottom) then
					rc1.left = math.min(rc1.left, rc2.left)
					rc1.top = math.min(rc1.top, rc2.top)
					rc1.right = math.max(rc1.right, rc2.right)
					rc1.bottom = math.max(rc1.bottom, rc2.bottom)
					table.remove(rectarray, index2)
					combine = true
					break
				end
			end
			if combine then
				break
			end
		end
		if not combine then
			break
		end
	end
	m_maplabel_questid = questid
	m_maplabel_queststep = queststep
	m_maplabel_questlambdaindex = questlambdaindex
	m_maplabel_questmapid = mapid
	local config_map = csvmap_getfromid(mapid)
	if mapview_openformap(config_map) then
		m_uimap_main:open()
		m_maplabel_questzone = rectarray
		m_maplabel_questflicker = time_game
		mapview_setmapid(mapid, csvmap_getlayer(config_map, rectarray[1].height))
		return true
	end
	return false
end

function maplabel_setquestzone(questid, queststep, questlambdaindex, mapid, x, y, z, radius)
	local config_map = csvmap_getfromid(mapid)
	if not mapview_openformap(config_map) then
		return false
	end
	local rc = {}
	rc.left = x - radius
	rc.top = z - radius
	rc.right = x + radius
	rc.bottom = z + radius
	rc.height = y
	m_maplabel_questid = questid
	m_maplabel_queststep = queststep
	m_maplabel_questlambdaindex = questlambdaindex
	m_maplabel_questmapid = mapid
	m_uimap_main:open()
	m_maplabel_questzone = {}
	m_maplabel_questzone[1] = rc
	m_maplabel_questflicker = time_game
	mapview_setmapid(mapid, csvmap_getlayer(config_map, y))
	return true
end

function maplabel_setquestzonearray(questid, queststep, questlambdaindex, mapid, radius, viewarray)
	local config_map = csvmap_getfromid(mapid)
	if not mapview_openformap(config_map) then
		return false
	end
	m_maplabel_questid = questid
	m_maplabel_queststep = queststep
	m_maplabel_questlambdaindex = questlambdaindex
	m_maplabel_questmapid = mapid
	m_uimap_main:open()
	m_maplabel_questzone = {}
	for i=1,#viewarray do
		local view = viewarray[i]
		local rc = {}
		rc.left = view.x - radius
		rc.top = view.z - radius
		rc.right = view.x + radius
		rc.bottom = view.z + radius
		rc.height = y
		m_maplabel_questzone[i] = rc
	end
	m_maplabel_questflicker = time_game
	mapview_setmapid(mapid, csvmap_getlayer(config_map, y))
	return true
end

function maplabel_setquestpoly(questid, queststep, questlambdaindex, mapid, poly, scale)
    local pointarray = string.split(poly, ";")
    local x1, y1, x2, y2
    local heightrange = string.splitnumber(pointarray[1], ",")
    local height = (heightrange[1] + heightrange[2]) / 2
    for i=2,#pointarray do
        local point = string.splitnumber(pointarray[i], ",")
        if x1 == nil then
            x1 = point[1]
            y1 = point[2]
            x2 = point[1]
            y2 = point[2]
        else
            x1 = math.min(x1, point[1])
            y1 = math.min(y1, point[2])
            x2 = math.max(x2, point[1])
            y2 = math.max(y2, point[2])
        end
    end
    local radius = vector2_distance(x1, y1, x2, y2) / 2 * scale
    return maplabel_setquestzone(questid, queststep, questlambdaindex, mapid, (x1 + x2) / 2, height, (y1 + y2) / 2, radius)
end

local function maplabel_addquestzone(rc, labelwidget, flickerwidget, locatepath)
	local image_locate = m_uimap_main:getwidget(locatepath .. m_maplabel_questlocatecount)
	if image_locate == nil then
		local image_locate_template = m_uimap_main:getwidget(locatepath .. 1)
		image_locate = image_locate_template:clone("image_locate_" .. m_maplabel_questlocatecount)
	end
	m_maplabel_questlocatecount = m_maplabel_questlocatecount + 1
	local uil, uit = mapview_worldtoui(rc.left, rc.top)
	local uir, uib = mapview_worldtoui(rc.right, rc.bottom)
	image_locate.labeltype = maplabeltype.questzone
	image_locate.worldx = (rc.left + rc.right) / 2
	image_locate.worldz = (rc.top + rc.bottom) / 2
	image_locate.width = math.abs(uir - uil)
	image_locate.height = math.abs(uib - uit)
	image_locate.flickertime = m_maplabel_questflicker
	labelwidget[#labelwidget + 1] = image_locate
	flickerwidget[#flickerwidget + 1] = image_locate
end

function maplabel_updatequestlocate(labelwidget, flickerwidget, config_map)
	m_maplabel_questlocatecount = 1
	local locatepath = "scene_root/canvas_move/canvas_locate/image_locate_"
	if m_maplabel_questid > 0 and m_maplabel_questmapid == config_map.id and m_maplabel_questzone ~= nil then
		local quest = playerquest_getquest(m_maplabel_questid)
		if quest ~= nil and quest.step == m_maplabel_queststep and quest.state[m_maplabel_questlambdaindex] ~= -1 then
			for i=1,#m_maplabel_questzone do
				maplabel_addquestzone(m_maplabel_questzone[i], labelwidget, flickerwidget, locatepath)
			end
		end
	elseif m_maplabel_questid == -1 and m_maplabel_questmapid == config_map.id then
		for i=1,#m_maplabel_questzone do
			maplabel_addquestzone(m_maplabel_questzone[i], labelwidget, flickerwidget, locatepath)
		end
	end
	m_uimap_main:hideunused(locatepath, m_maplabel_questlocatecount)
end
