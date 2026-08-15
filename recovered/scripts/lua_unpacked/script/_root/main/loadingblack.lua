

loadingblacktype =
{
	loading = 1,
    teleport = 2,
}

local m_loading_black = uipanel_createhandle("root/loadingblack", uilayer.loadingbg, uiflag.holdonclear)
local m_loading_black_type = loadingblacktype.loading
local m_loading_black_timestart = 0
local m_loading_black_framestart = 0

function loadingblack_open(type)
	m_loading_black:open()
	m_loading_black_type = type
	m_loading_black_timestart = time_game
	m_loading_black_framestart = time_framecount
	event_register(eventtype.update, loadingblack_update, m_loading_black)		
	loadingblack_update()
end

function loadingblack_update()
	if m_loading_black_type == loadingblacktype.loading then
		local opacity = 1.0
		if time_framecount - m_loading_black_framestart > 1 then
			local fadetime = 0.5
			opacity = 1.0 - (time_game - m_loading_black_timestart) / fadetime
		else
			m_loading_black_timestart = time_game
		end
		if opacity <= 0.0 then
			m_loading_black:close()
			return
		end
		local image_black = m_loading_black:getwidget("image_black")
		image_black:setcolor(0.0,0.0,0.0,opacity)
	elseif m_loading_black_type == loadingblacktype.teleport then
		local opacity = 1.0
		if time_framecount - m_loading_black_framestart > 3 then
			local fadetime = 0.5
			opacity = 1.0 - (time_game - m_loading_black_timestart) / fadetime
		else
			m_loading_black_timestart = time_game
		end
		if opacity <= 0.0 then
			m_loading_black:close()
			return
		end
		local image_black = m_loading_black:getwidget("image_black")
		image_black:setcolor(0.0,0.0,0.0,opacity)
	end
end
