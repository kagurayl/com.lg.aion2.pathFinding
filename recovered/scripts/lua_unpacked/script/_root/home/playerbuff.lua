
local function playerbuff_loadslot(buffui)
	buffui.buffslot = {}
	local lineindex = 1
	while true do
		local line = buffui:getwidget(string.format("buff_line_%d", lineindex))
		if line == nil then
			break
		end
		local lineslot = 1
		while true do
			local name = string.format("buff_line_%d/buff_slot_%d", lineindex, lineslot)
			local slot = buffui:getwidget(name)
			if slot == nil then
				break
			end
			buffui.buffslot[#buffui.buffslot + 1] = name
			lineslot = lineslot + 1
		end
		lineslot = 1
		local debuffslot = nil
		while true do
			local name = string.format("debuff_line_%d/buff_slot_%d", lineindex, lineslot)
			local slot = buffui:getwidget(name)
			if slot == nil then
				break
			end
			if debuffslot == nil then
				debuffslot = {}
			end
			debuffslot[#debuffslot + 1] = name
			lineslot = lineslot + 1
		end
		if debuffslot ~= nil then
			if buffui.debuffslot == nil then
				buffui.debuffslot = {}
			end
			for i=#debuffslot,1,-1 do
				buffui.debuffslot[#buffui.debuffslot + 1] = debuffslot[i]
			end
		end
		lineindex = lineindex + 1
	end
end

local function playerbuff_hideunused(buffui, buffindex, debuffindex)
	for i=buffindex,#buffui.buffslot do
		local widget = buffui:getwidget(buffui.buffslot[i])
		if widget ~= nil and widget.buffid ~= 0 then
			widget.buffid = 0
			widget:setvisible(false)
		end
	end
	if buffui.debuffslot ~= nil then
		for i=debuffindex,#buffui.debuffslot do
			local widget = buffui:getwidget(buffui.debuffslot[i])
			if widget ~= nil and widget.buffid ~= 0 then
				widget.buffid = 0
				widget:setvisible(false)
			end
		end
	end
end

function playerbuff_initview(buff)
	buff.iconview = false
	buff.timeview = false
	if buff.config_skill == nil or buff.config_buff == nil or buff.config_buff.type == battlebufftype.none then
		return
	end
	buff.iconview = true
	buff.timeview = buff.timelength > 0
	if buff.config_buff.type == battlebufftype.chant then
		buff.timeview = false
	end
end

function playerbuff_addbufficon(widgetroot, buff)
	if widgetroot.buffid == nil or widgetroot.buffid == 0 then
		widgetroot:setvisiblenothit(true)
	end
	local text_time = widgetroot:getwidget("text_time")
	if widgetroot.buffid ~= buff.buffid then
		if buff.config_skill ~= nil then
			local image_icon = widgetroot:getwidget("/image_icon")
			image_icon:seticon(buff.config_skill.icon)
			image_icon:setcolor(1.0, 1.0, 1.0, 1.0)
			text_time:setcolor(1.0, 1.0, 1.0, 1.0)
		end
		widgetroot:stopuianim()
		widgetroot.buffid = buff.buffid
		widgetroot.animplaying = false
	end
	local time = nil
	if buff.timeview then
		time = math.max(0, buff.timeout - time_game)
		text_time:settextrawverify(timerdesc_getdescshort(math.ceil(time)))
	else
		text_time:settextrawverify("")
	end
	if time ~= nil and time < 10 then
		local animspeed = math.lerp(10.0, 1.0, time / 10)
		if not widgetroot.animplaying then
			widgetroot.animplaying = true
			widgetroot:playuianim("buff", animspeed)
		else
			widgetroot:setuianimspeed("buff", animspeed)
		end
	elseif widgetroot.animplaying then
		widgetroot.animplaying = false
		widgetroot:stopuianim()
		local image_icon = widgetroot:getwidget("image_icon")
		image_icon:setcolor(1.0, 1.0, 1.0, 1.0)
		text_time:setcolor(1.0, 1.0, 1.0, 1.0)
	end
end
function playerbuff_updateactorui(actor, buffui)
	if buffui.buffslot == nil then
		playerbuff_loadslot(buffui)
	end
	if actor == nil or actor.buff == nil then
		playerbuff_hideunused(buffui, 1, 1)
		return
	end
	local buffindex = 1
	local debuffindex = 1
	for i=1, #actor.buff do
		local buff = actor.buff[i]
		if buff.iconview then
			local duplicate = false
			for j=i-1,1,-1 do
				if actor.buff[j].config_buff.id == buff.config_buff.id then
					duplicate = true
					break
				end
			end
			if not duplicate then
				local widgetroot = nil
				if csvskillbuff_isbuff(buff.config_buff) then
					if buffindex <= #buffui.buffslot then
						widgetroot = buffui:getwidget(buffui.buffslot[buffindex])
						buffindex = buffindex + 1
					end
				elseif csvskillbuff_isdebuff(buff.config_buff) then
					if buffui.debuffslot ~= nil then
						if debuffindex <= #buffui.debuffslot then
							widgetroot = buffui:getwidget(buffui.debuffslot[debuffindex])
							debuffindex = debuffindex + 1
						end
					elseif buffindex <= #buffui.buffslot then
						widgetroot = buffui:getwidget(buffui.buffslot[buffindex])
						buffindex = buffindex + 1
					end
				end
				if widgetroot ~= nil then
					playerbuff_addbufficon(widgetroot, buff)
				end
			end
		end
	end
	playerbuff_hideunused(buffui, buffindex, debuffindex)
end
