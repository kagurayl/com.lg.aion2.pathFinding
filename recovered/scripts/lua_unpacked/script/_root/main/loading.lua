
local loadingstate = 
{
    downloading = 1,
	loading = 2,
}
local m_loading_uimain = uipanel_createhandle("root/loading", uilayer.loading, uiflag.holdonclear)
local m_loading_scenename = nil
local m_loading_assetloading = false

local function loading_settips(tips)
	local text_tips = m_loading_uimain:getwidget("text_tips")
	if tips then
		local textcount = 1
		while true do
			local key = "LOADING_TIPS_" .. (textcount + 1)
			if not c_textkey(key) then
				break
			end
			textcount = textcount + 1
		end
		text_tips:setvisible(true)
		text_tips:settext("LOADING_TIPS_" .. math.random(1, textcount))	
	else
		text_tips:setvisible(false)
	end
end

function loading_getlevelname()
	return m_loading_scenename
end

function loading_getassetloading()
	return m_loading_assetloading
end

function loading_loadlevel(mapid, name, bg, waitmessage, func)
	m_loading_uimain:open()

	local image_bg = m_loading_uimain:getwidget("image_bg")
	local imagepath = "loading/" .. bg
	local imagewidth, imageheight = c_uigettexturesize(unity_uitexturepath(imagepath))
	if imagewidth > 0.0 and imageheight > 0.0 then
		local screenwidth, screenheight = c_system_screensize()
		local scale = screenwidth / imagewidth
		imageheight = imageheight * scale

		image_bg:setraw(imagepath)
		image_bg:setsize(screenwidth, imageheight)
	end
	m_loading_scenename = name
	m_loading_uimain.levelname = string.format("levels/%s/%s.unity", name, name)
	m_loading_uimain.leveldelegate = func
	m_loading_uimain.levelstate = loadingstate.loading
	m_loading_uimain.levelwaitmessage = waitmessage
	if mapid ~= 0 then
		m_loading_uimain.leveldownloadflag = mapid
		m_loading_uimain.leveldownloadsize = downloading_startflag(mapid)
		if m_loading_uimain.leveldownloadsize > 0 then
			m_loading_uimain.levelstate = loadingstate.downloading
		end
	end
	if m_loading_uimain.levelstate == loadingstate.loading then
		loading_settips(waitmessage)
		c_scene_asyncload(m_loading_uimain.levelname)
	end
	m_loading_assetloading = true
	event_register(eventtype.update, loading_update, m_loading_uimain)
end

function loading_update()
	if m_loading_uimain.levelstate == loadingstate.downloading then
		local remainsize = downloading_queryflag(m_loading_uimain.leveldownloadflag)
		if remainsize > 0 then
			m_loading_uimain.levelstate = loadingstate.downloading
			local downloaded = m_loading_uimain.leveldownloadsize - remainsize
			local text_tips = m_loading_uimain:getwidget("text_tips")
			text_tips:settext("LOADING_DOWNLOADING", downloading_getdesc(downloaded), downloading_getdesc(m_loading_uimain.leveldownloadsize))
		else
			m_loading_uimain.levelstate = loadingstate.loading
			loading_settips(true)
			c_scene_asyncload(m_loading_uimain.levelname)
		end
	elseif m_loading_uimain.levelstate == loadingstate.loading then
		local x = 0
		local y = 0
		local z = 0
		if playerattr_info ~= nil then
			x = playerattr_info.posx
			y = playerattr_info.posy
			z = playerattr_info.posz
		end
		local complete, percentage = c_scene_asyncpercentage(x, y, z)
		if complete and m_loading_uimain.levelwaitmessage and m_me == nil then
			complete = false
		end
		if complete then
			m_loading_assetloading = false
			loadingblack_open(loadingblacktype.loading)
			m_loading_uimain:close()
			m_loading_uimain.leveldelegate()
		else
			local progress = m_loading_uimain:getwidget("progress_loading")
			if progress ~= nil then
				progress:setpercent(percentage)
			end
		end
	end
end
