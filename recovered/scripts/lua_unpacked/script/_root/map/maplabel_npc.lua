
local m_maplabel_npcflicker = 0
local m_maplabel_npctop = 0
local m_maplabel_modnpcpath = "scene_root/canvas_move/canvas_modnpc/image_npc_"
local m_maplabel_modnpctemplate = nil
local m_maplabel_modnpccount = 0
local m_maplabel_questnpcpath = "scene_root/canvas_move/canvas_questnpc/image_npc_"
local m_maplabel_questnpctemplate = nil
local m_maplabel_questnpccount = 0
local m_maplabel_othernpcpath = "scene_root/canvas_move/canvas_othernpc/image_npc_"
local m_maplabel_othernpctemplate = nil
local m_maplabel_othernpccount = 0

function maplabel_npcreset()
	m_maplabel_npcflicker = 0
	m_maplabel_npctop = 0
end

function maplabel_setnpcflicker(npcid)
	local config_spawn = csvnpcspawn_getmapspawnnpc(npcid)
	if config_spawn ~= nil and #config_spawn > 0 then
		local spawnposition = csvspawn_parsepoint(config_spawn[1])
		if spawnposition == nil or #spawnposition == 0 then
			return false
		end
		m_maplabel_npcflicker = npcid
		m_maplabel_npctop = npcid
		mapview_setmapid(config_spawn[1].mapid, csvmap_getlayer(csvmap_getfromid(config_spawn[1].mapid), spawnposition[1].y))
		m_maplabel_npcflicker = 0
		return true
	end

	local config_spawnstatic = csvnpcstatic_getfromnpcid(npcid)
	if config_spawnstatic ~= nil and #config_spawnstatic > 0 then
		local spawnposition = csvspawn_parsepoint(config_spawnstatic[1])
		if spawnposition == nil or #spawnposition == 0 then
			return false
		end
		m_maplabel_npcflicker = npcid
		m_maplabel_npctop = npcid
		mapview_setmapid(config_spawnstatic[1].id, csvmap_getlayer(csvmap_getfromid(config_spawnstatic[1].id), spawnposition[1].y))
		m_maplabel_npcflicker = 0
		return true
	end
	return false
end

local function maplabel_addnpc(npcspawn, npcid, labelwidget, flickerwidget, shownpc, showquest)
	local labeltype = nil
	local imagelabel = nil
	local npcpath = nil
	local image_npc_template = nil
	local npccount = 0
	if showquest then
		imagelabel = playerattr_questnpcicon[npcid]
		labeltype = maplabeltype.quest
		npcpath = m_maplabel_questnpcpath
		image_npc_template = m_maplabel_questnpctemplate
		npccount = m_maplabel_questnpccount
	end
	if imagelabel == nil and shownpc then
		local config_npc = csvnpc_getfromid(npcid)
		imagelabel = csvnpc_getlabelimage(config_npc)
		if imagelabel ~= nil then
			labeltype = maplabeltype.modnpc
			npcpath = m_maplabel_modnpcpath
			image_npc_template = m_maplabel_modnpctemplate
			npccount = m_maplabel_modnpccount
		end
	end
	if imagelabel == nil then
		return
	end
	local spawnposition = csvspawn_parsepoint(npcspawn)
	if spawnposition == nil or #spawnposition == 0 then
		return
	end
	for positionindex=1,#spawnposition do
		local worldpos = spawnposition[positionindex]
		if maplabel_layervisible(worldpos.y) then
			local image_npc = m_uimap_main:getwidget(npcpath .. npccount)
			if image_npc == nil then
				image_npc = image_npc_template:clone("image_npc_" .. npccount)
			end
			if image_npc.sprite == nil or image_npc.sprite ~= imagelabel.image then
				image_npc.sprite = imagelabel.image
				image_npc:setsprite(imagelabel.image)
			end
			image_npc:setsize(imagelabel.width * 2, imagelabel.height * 2)
			image_npc.labeltype = labeltype
			image_npc.worldx = worldpos.x
			image_npc.worldz = worldpos.z
			npccount = npccount + 1
			if m_maplabel_npcflicker == npcid then
				image_npc.flickertime = time_game
				flickerwidget[#flickerwidget + 1] = image_npc
			end
			labelwidget[#labelwidget + 1] = image_npc
		end
	end
	if labeltype == maplabeltype.quest then
		m_maplabel_questnpccount = npccount
	else
		m_maplabel_modnpccount = npccount
	end
end

local function maplabel_addotherlabel(imagelabel, labeltype, posx, posz, scale, labelwidget)
	local image_npc = m_uimap_main:getwidget(m_maplabel_othernpcpath .. m_maplabel_othernpccount)
	if image_npc == nil then
		image_npc = m_maplabel_othernpctemplate:clone("image_npc_" .. m_maplabel_othernpccount)
	end
	if image_npc.sprite == nil or image_npc.sprite ~= imagelabel.image then
		image_npc:setsprite(imagelabel.image)
		image_npc:setcolor(1, 1, 1, 1)
	end
	image_npc:setsize(imagelabel.width * scale, imagelabel.height * scale)
	image_npc.labeltype = labeltype
	image_npc.worldx = posx
	image_npc.worldz = posz
	m_maplabel_othernpccount = m_maplabel_othernpccount + 1
	labelwidget[#labelwidget + 1] = image_npc
	return image_npc
end

local function maplabel_adddungeon(mapid, labelwidget)
	local imagelabel = csvlabelimage.npc_dungeon
    local dungeonarray = c_config_getmetaarray(configid.map_dungeon, "portalicon", 1)
	if dungeonarray ~= nil then
		for dungeonindex=1,#dungeonarray do
			local config_dungeon = dungeonarray[dungeonindex]
			local portal = math.ternary(playerattr_info.civ == playerciv.light, config_dungeon.lightportal, config_dungeon.darkportal) 
			if portal ~= "0" then
				local portalarray = string.split(portal, ";")
				for portalindex=1,#portalarray do
					local subportal = string.splitnumber(portalarray[portalindex], ",")
					if subportal[1] == mapid and maplabel_layervisible(subportal[3]) then
						maplabel_addotherlabel(imagelabel, maplabeltype.dungeon, subportal[2], subportal[4], 3.0, labelwidget)
					end
				end
			end
		end
	end
end

local function maplabel_addabyss(mapid, flickerwidget, labelwidget)
    local castlearray = c_config_getmetaarray(configid.abyss_castle, "mapid", mapid)
	if castlearray ~= nil then
		for castleindex=1,#castlearray do
			local config_castle = castlearray[castleindex]
			local position = string.splitnumber(config_castle.position, ",")
			if maplabel_layervisible(position[2]) then
				local image_castle = maplabel_addotherlabel(csvlabelimage.abyss_castle, maplabeltype.abysscastle, position[1], position[3], 3.0, labelwidget)
				local civ = playerciv.dragon
				local servercastle = serverattr_abysscastle[config_castle.id]
				if servercastle ~= nil then
					civ = servercastle.civ
					if servercastle.mist > 0 then
						maplabel_addotherlabel(csvlabelimage.abyss_castlebattle, maplabeltype.abysscastle, position[1], position[3], 3.0, labelwidget)
					end
				end
				if civ == playerciv.light then
					image_castle:setcolor(0.46, 1.0, 0.40, 1)
				elseif civ == playerciv.dark then
					image_castle:setcolor(0.37, 0.58, 1.0, 1)			
				else
					image_castle:setcolor(1.0, 0.70, 0.70, 1)
				end
				local abyss = serverattr_abysscastle[config_castle.id]
				if abyss ~= nil and abyss.carrier > 0 then
					local timestart = abyss.carrier - time_abysscarrier_spawn
					local timeend = abyss.carrier
					local time = (time_game - timestart) / (timeend - timestart)
					if time < 1.0 then
						position = string.splitnumber(config_castle.carrierpath, ",")
						local posx = math.lerp(position[1], position[3], time)
						local posz = math.lerp(position[2], position[4], time)
						local image_carrier = maplabel_addotherlabel(csvlabelimage.abyss_carrier, maplabeltype.abysscarrier, posx, posz, 3.0, labelwidget)
						image_carrier.posstartx = position[1]
						image_carrier.posstartz = position[2]
						image_carrier.posendx = position[3]
						image_carrier.posendz = position[4]
						image_carrier.timestart = timestart
						image_carrier.timeend = timeend
						image_carrier.flickertime = nil
						flickerwidget[#flickerwidget + 1] = image_carrier
					end
				end
			end
		end
	end
	local artifactarray = c_config_getmetaarray(configid.abyss_artifact, "mapid", mapid)
	if artifactarray ~= nil then
		for artifactindex=1,#artifactarray do
			local config_artifact = artifactarray[artifactindex]
			if config_artifact.abyss ~= 0 then
				local position = string.splitnumber(config_artifact.position, ",")
				if maplabel_layervisible(position[2]) then
					local image_artifact = maplabel_addotherlabel(csvlabelimage.abyss_artifact, maplabeltype.abyssartifact, position[1], position[3], 1.5, labelwidget)
					local civ = playerciv.dragon
					local servercastle = serverattr_abyssartifact[config_artifact.id]
					if servercastle ~= nil then
						civ = servercastle.civ
					end
					if civ == playerciv.light then
						image_artifact:setcolor(0.46, 1.0, 0.40, 1)
					elseif civ == playerciv.dark then
						image_artifact:setcolor(0.37, 0.58, 1.0, 1)			
					else
						image_artifact:setcolor(1.0, 0.70, 0.70, 1)
					end
				end
			end
		end
	end
end

local function maplabel_adddirectportal(mapid, labelwidget)
	local imagelabel = csvlabelimage.abyss_civgate
    local portalarray = c_config_getmetaarray(configid.npc_directportal, "startmapid", mapid)
	if portalarray ~= nil then
		for portalindex=1,#portalarray do
			local config_portal = portalarray[portalindex]
			local position = string.splitnumber(config_portal.startposition, ",")
			maplabel_addotherlabel(imagelabel, maplabeltype.portal, position[1], position[3], 3.0, labelwidget)
		end
	end
end

function maplabel_updatenpc(labelwidget, flickerwidget, config_map)
	local shownpc = gamesetting_getnumber("MAPSHOWNPC") == 1
	local showquest = gamesetting_getnumber("MAPSHOWQUEST") == 1
	if not shownpc and not showquest and m_maplabel_npctop == 0 then
		m_uimap_main:hideunused(m_maplabel_modnpcpath, 1)
		m_uimap_main:hideunused(m_maplabel_questnpcpath, 1)
		m_uimap_main:hideunused(m_maplabel_othernpcpath, 1)
		return
	end
	local npcspawntop = nil
	m_maplabel_modnpccount = 1
	m_maplabel_questnpccount = 1
	m_maplabel_othernpccount = 1
	m_maplabel_modnpctemplate = m_uimap_main:getwidget(m_maplabel_modnpcpath .. 1)
	m_maplabel_questnpctemplate = m_uimap_main:getwidget(m_maplabel_questnpcpath .. 1)
	m_maplabel_othernpctemplate = m_uimap_main:getwidget(m_maplabel_othernpcpath .. 1)
	
	maplabel_adddungeon(config_map.id, labelwidget)
	maplabel_addabyss(config_map.id, flickerwidget, labelwidget)
	--maplabel_adddirectportal(config_map.id, labelwidget)

	local config_spawntable = csvnpcspawn_getmapspawn(config_map.id)
	if config_spawntable ~= nil then
		for i=1,#config_spawntable do
			local npcspawn = config_spawntable[i]
			if npcspawn.id ~= m_maplabel_npctop then
				if shownpc or showquest then
					maplabel_addnpc(npcspawn, npcspawn.id, labelwidget, flickerwidget, shownpc, showquest)
				end
			else
				npcspawntop = npcspawn
			end
		end
	end
	local config_spawnstatic = csvnpcstatic_getfrommapid(config_map.id)
	if config_spawnstatic ~= nil then
		for i=1,#config_spawnstatic do
			local npcspawn = config_spawnstatic[i]
			if npcspawn.npcid ~= 0 then
				if npcspawn.npcid ~= m_maplabel_npctop then
					if shownpc or showquest then
						maplabel_addnpc(npcspawn, npcspawn.npcid, labelwidget, flickerwidget, shownpc, showquest)
					end
				else
					npcspawntop = npcspawn
				end
			end
		end
	end
	if npcspawntop ~= nil then
		maplabel_addnpc(npcspawntop, m_maplabel_npctop, labelwidget, flickerwidget, shownpc, true)
	end
	m_uimap_main:hideunused(m_maplabel_modnpcpath, m_maplabel_modnpccount)
	m_uimap_main:hideunused(m_maplabel_questnpcpath, m_maplabel_questnpccount)
	m_uimap_main:hideunused(m_maplabel_othernpcpath, m_maplabel_othernpccount)
	m_maplabel_modnpctemplate = nil
	m_maplabel_questnpctemplate = nil
	m_maplabel_othernpctemplate = nil
end
