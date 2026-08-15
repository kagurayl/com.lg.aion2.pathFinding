
local crafting_animtype =
{
	normal = 0,
    blue = 1,
	purple = 2,
}

local m_uicrafting_progress = uipanel_createhandle("crafting/crafting_progress", uilayer.top, 0)

function crafting_progress_onopen()
	m_uicrafting_progress:setwidgetdelegate("button_stop", crafting_progress_delegate_stop)
	m_uicrafting_progress.batch = 0
	event_register(eventtype.update, crafting_progress_update, m_uicrafting_progress)
end

function crafting_progress_close()
	m_uicrafting_progress:close()
end

function crafting_progress_create(skillid, itemid, batch, critical)
    m_uicrafting_progress:open()
	m_uicrafting_progress.animtype = nil
	m_uicrafting_progress.valsuccess = 0.0
	m_uicrafting_progress.valfail = 0.0
	if critical == 0 then
		m_uicrafting_progress.batch = batch
	end

	m_uicrafting_progress:setwidgetvisible("image_batchbg", batch > 1)
	m_uicrafting_progress:setwidgetvisible("button_stop", batch > 1)
	m_uicrafting_progress:setwidgetvisible("image_simplebg", batch == 1)

	local craftingskill = playerskill_getcraftingskill(skillid)
	if craftingskill ~= nil then
		local config_skill = csvskill_getfromid(skillid)
		if config_skill ~= nil then
			local text = c_textformat("CRAFTING_PROGRESS_SKILL", config_skill.name, craftingskill.level)
			local text_skill = m_uicrafting_progress:getwidget("text_skill")
			text_skill:settext(text)
		end
	end

	local config_product = csvitem_getfromid(itemid)
	if config_product ~= nil then
		local text_name = m_uicrafting_progress:getwidget("text_name")
		text_name:setcolor(csvitem_getfloatcolor(config_product))
		if critical == 0 and batch > 1 then
			text_name:settext(string.format("%s(%d)", config_product.name, batch))
		else
			text_name:settext(config_product.name)
		end
		local image_icon = m_uicrafting_progress:getwidget("image_icon")
		image_icon:seticon(config_product.icon)
	end

	local progress_success = m_uicrafting_progress:getwidget("progress_success")
	progress_success:setpercent(0.0)

	local progress_purple = m_uicrafting_progress:getwidget("progress_purple")
	progress_purple:setpercent(0.0)

	local progress_fail = m_uicrafting_progress:getwidget("progress_fail")
	progress_fail:setpercent(0.0)
end

function crafting_progress_setprogress(color, success, fail)
	if m_uicrafting_progress:null() then
		return
	end
	m_uicrafting_progress.animtype = color
	m_uicrafting_progress.animtimestart = time_game
	m_uicrafting_progress.valsuccessstart = m_uicrafting_progress.valsuccess
	m_uicrafting_progress.valfailstart = m_uicrafting_progress.valfail
	m_uicrafting_progress.valsuccess = success
	m_uicrafting_progress.valfail = fail
	if color == 1 then
		audiomanager_playaudioui(AudioSocialCritical1)
	elseif color == 2 then
		audiomanager_playaudioui(AudioSocialCritical2)
	end
end

local function crafting_progress_setimagefx(image_fx, progress, t)
	image_fx:setvisiblenothit(true)
	local x,y,w,h = progress:getabsolute()
	local fx_x = x + w * t
	local fx_y = y + h / 2
	image_fx:setposition(fx_x, fx_y)
end

function crafting_progress_update()
	if m_uicrafting_progress:null() then
		return
	end
	local image_fx = m_uicrafting_progress:getwidget("image_fx")
	image_fx:setvisible(false)
	if m_uicrafting_progress.animtype == nil then
		return
	end
	local progress_success = m_uicrafting_progress:getwidget("progress_success")
	local progress_purple = m_uicrafting_progress:getwidget("progress_purple")
	local progress_fail = m_uicrafting_progress:getwidget("progress_fail")
	if m_uicrafting_progress.animtype == crafting_animtype.normal then
		local animtimelength = 1.5
		local t = (time_game - m_uicrafting_progress.animtimestart) / animtimelength
		if t >= 1.0 then
			t = 1.0
			m_uicrafting_progress.animtype = nil
		end
		local success = math.lerp(m_uicrafting_progress.valsuccessstart, m_uicrafting_progress.valsuccess, t)
		local fail = math.lerp(m_uicrafting_progress.valfailstart, m_uicrafting_progress.valfail, t)
		progress_success:setpercent(success)
		progress_purple:setvisible(false)
		progress_fail:setpercent(fail)
	elseif m_uicrafting_progress.animtype == crafting_animtype.blue then
		local animtimelength = 1.5
		local vfxtimepercent = 0.5
		local t = (time_game - m_uicrafting_progress.animtimestart) / animtimelength
		if t >= 1.0 then
			t = 1.0
			m_uicrafting_progress.animtype = nil
		end
		t = math.clamp(t - vfxtimepercent, 0.0, 1.0)  / (1.0 - vfxtimepercent)
		local success = math.lerp(m_uicrafting_progress.valsuccessstart, m_uicrafting_progress.valsuccess, t)
		progress_success:setpercent(success)
		progress_purple:setvisible(false)
		progress_fail:setpercent(m_uicrafting_progress.valfail)
		crafting_progress_setimagefx(image_fx, progress_success, success)
	elseif m_uicrafting_progress.animtype == crafting_animtype.purple then
		local animtimelength = 1.5
		local vfxtimepercent = 0.5
		local t = (time_game - m_uicrafting_progress.animtimestart) / animtimelength
		if t >= 1.0 then
			t = 1.0
			m_uicrafting_progress.animtype = nil
		end
		t = math.clamp(t - vfxtimepercent, 0.0, 1.0)  / (1.0 - vfxtimepercent)
		local success = math.lerp(m_uicrafting_progress.valsuccessstart, m_uicrafting_progress.valsuccess, t)
		progress_success:setpercent(success)
		progress_purple:setpercent(success)
		progress_purple:setvisible(true)
		progress_fail:setpercent(m_uicrafting_progress.valfail)
		crafting_progress_setimagefx(image_fx, progress_purple, success)
	end
end

function crafting_progress_delegate_stop()
	m_uicrafting_progress:setwidgetenable("button_stop", false)
	m_uicrafting_progress.batch = 0
end

function crafting_progress_getbatch()
	if m_uicrafting_progress:alive() and m_uicrafting_progress.batch ~= nil then
		return m_uicrafting_progress.batch
	else
		return 0
	end
end
