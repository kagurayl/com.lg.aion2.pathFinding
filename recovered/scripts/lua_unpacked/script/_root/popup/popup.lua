
include("popup/bufflist")
include("popup/debufflist")
include("popup/selectionbufflist")
include("popup/itemmenu")
include("popup/selectitem")

updatebufflisttype = 
{
    buff = 1,
    debuff = 2,
    all = 3,
}

function popup_updatebufflist(panel, inst, actor, type, linewidth, lineheight, removedelegate)
	if actor == nil or actor.buff == nil or #actor.buff == 0 then
		panel:close()
		return
	end
	local list_buff = panel:getwidget("list_buff")
	local viewindex = 1
	for i=1, #actor.buff do
		local buff = actor.buff[i]
		local view = buff.iconview
		if view then
			if type == updatebufflisttype.buff then
				if not csvskillbuff_isbuff(buff.config_buff) then
					view = false
				end
			elseif type == updatebufflisttype.debuff then
				if not csvskillbuff_isdebuff(buff.config_buff) then
					view = false
				end
			end
		end
		if view then
			local line = nil
			if viewindex <= list_buff:getcount() then
				line = list_buff:getlinefromindex(viewindex)
			else
				line = list_buff:add(inst, viewindex, viewindex)
				line.buffid = 0
			end
			viewindex = viewindex + 1
			if line.buffid ~= buff.buffid then
				line.buffid = buff.buffid
				line:setselect(false)
				local image_icon = line:getwidget("image_icon")
				local text_name = line:getwidget("text_name")
				if removedelegate ~= nil then
					local button_remove = line:getwidget("button_remove")
					button_remove:setdelegate(bufflist_delegate_remove)
					button_remove.buffinstid = buff.buffinstid
					line.removeable = false
					local buffdesc = nil
					if buff.config_buff.type == battlebufftype.buff or buff.config_buff.type == battlebufftype.item then
						line.removeable = true
					end
				end
				image_icon:seticon(buff.config_skill.icon)
				text_name:settext(buff.config_skill.name)
				if buff.config_buff.desc ~= "0" then
					buffdesc = buff.config_buff.desc
				else
					buffdesc = buff.config_skill.desc
				end
				local image_select = line:getwidget("image_select")
				local image_event = line:getwidget("image_event")
				local text_desc = line:getwidget("text_desc")
				local linewidthdefault = linewidth
				local lineheightdefault = lineheight
				if buffdesc ~= nil and buffdesc ~= "0" then
					buffdesc = skilltext_getdesc(buffdesc, buff.config_skill, buff.skilllevel, 0)
				end
				if buffdesc ~= nil and string.len(buffdesc) > 0 then
					text_desc:setvisible(true)
					text_desc:settext(buffdesc)
					local text_w, text_h = text_desc:setheightfromrendersize()
					lineheightdefault = lineheightdefault + text_h
				else
					text_desc:setvisiblenothit(false)
				end
				image_select:setsize(linewidthdefault, lineheightdefault)
				image_event:setsize(linewidthdefault, lineheightdefault)
				line:setsize(lineheightdefault)
			end
			if removedelegate ~= nil then
				line:setwidgetvisible("button_remove", line.removeable and panel.selectbuffid == line.buffid)
			end
			local text_time = line:getwidget("text_time")
			if buff.timeview then
				local time = math.max(0, buff.timeout - time_game)
				text_time:settext(timerdesc_getafter(math.ceil(time)))
			else
				text_time:settext("∞")
			end
		end
	end
	if viewindex == 1 then
		panel:close()
		return
	end
	for i=list_buff:getcount(), viewindex, -1 do
		list_buff:remove(i)
	end
	list_buff:updatecontentsize()
end
