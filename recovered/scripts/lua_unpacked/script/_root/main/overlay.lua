
overlaytype = 
{
    hpinc = 1,
	mpinc = 2,
	damage = 3,
	damagecrit = 4,
	dec5 = 5,
	hurt = 6,
	dec7 = 7,
}

overlayanim = 
{
    standard = "standard",
}

overlayprefix = 
{
    block_r = "overlay/block_r",
	block_w = "overlay/block_w",
	critical_r = "overlay/critical_r",
	critical_w = "overlay/critical_w",
	dodge_r = "overlay/dodge_r",
	dodge_w = "overlay/dodge_w",
	parry_r = "overlay/parry_r",
	parry_w = "overlay/parry_w",
	resist_r = "overlay/resist_r",
	resist_w = "overlay/resist_w",
}

local m_overlay_uimain = uipanel_createhandle("overlay/overlay_main", uilayer.overlay, uiflag.holdonclear)
local m_overlay_list = {}
local m_overlay_idle = {}
local m_overlay_count = 1

function overlay_create()
	if m_overlay_uimain:null() then
		m_overlay_uimain:open()
		m_overlay_list = {}
		m_overlay_idle = {}
		m_overlay_idle[1] = m_overlay_uimain:getwidget("inst_1")
		m_overlay_idle[1]:setvisible(false)
		local widgetanim = string.format("%s/animation", m_overlay_idle[1]._widgetpath)
		m_overlay_idle[1].widgetanim = m_overlay_uimain:getwidget(widgetanim)
		m_overlay_count = 1
	end
end

local function overlay_createnumber(overlay)
	local totalwidth = 0
	local totalheight = 0
	local widgetlist = {}
	local widgetprefix = m_overlay_uimain:getwidget(string.format("%s/animation/image_prefix", overlay.widget._widgetpath))
	if overlay.prefix ~= nil then
		widgetprefix:setsprite(overlay.prefix)
		widgetprefix:setvisible(true)
		widgetprefix.width, widgetprefix.height = c_uigetspritesize(unity_spritepath(overlay.prefix))
		widgetprefix:setsize(widgetprefix.width, widgetprefix.height)
		totalwidth = totalwidth + widgetprefix.width
		totalheight = math.max(totalheight, widgetprefix.height)
		widgetlist[#widgetlist + 1] = widgetprefix
	else
		widgetprefix:setvisible(false)
	end
	
	local widgetsign = m_overlay_uimain:getwidget(string.format("%s/animation/image_sign", overlay.widget._widgetpath))
	if overlay.sign ~= 0 then
		local spritename = nil
		if overlay.sign > 0 then
			spritename = string.format("overlay/%d_inc", overlay.type)
		else
			spritename = string.format("overlay/%d_dec", overlay.type)
		end
		widgetsign:setsprite(spritename)
		widgetsign:setvisible(true)
		widgetsign.width, widgetsign.height = c_uigetspritesize(unity_spritepath(spritename))
		widgetsign:setsize(widgetsign.width, widgetsign.height)
		totalwidth = totalwidth + widgetsign.width
		totalheight = math.max(totalheight, widgetsign.height)
		widgetlist[#widgetlist + 1] = widgetsign
	else
		widgetsign:setvisible(false)
	end
	
	local numbercount = 0
	if overlay.number ~= nil then
		local number = math.abs(overlay.number)
		local insertindex = #widgetlist + 1
		while numbercount < 100 do
			numbercount = numbercount + 1
			local widgetname = string.format("%s/animation/image_%d", overlay.widget._widgetpath, numbercount)
			local widgetnumber = m_overlay_uimain:getwidget(widgetname)
			if widgetnumber == nil then
				local widgetsource = m_overlay_uimain:getwidget(string.format("%s/animation/image_1", overlay.widget._widgetpath))
				widgetnumber = widgetsource:clone("image_" .. numbercount)
			end
			local spritename = string.format("overlay/%d_%d", overlay.type, number % 10)
			widgetnumber:setsprite(spritename)
			widgetnumber:setvisible(true)
			widgetnumber.width, widgetnumber.height = c_uigetspritesize(unity_spritepath(spritename))
			widgetnumber:setsize(widgetnumber.width, widgetnumber.height)
			totalwidth = totalwidth + widgetnumber.width
			totalheight = math.max(totalheight, widgetnumber.height)
			table.insert(widgetlist, insertindex, widgetnumber)
			if number >= 10 then
				number = math.tointegerfloor(number / 10)
			else
				break
			end
		end
	end

	local px = math.random(-math.tointegerfloor(totalwidth), 0)
	local py = math.random(math.tointegerfloor(totalheight), 0) + totalheight
	for i=1, #widgetlist do
		local widget = widgetlist[i]
		widget:setposition(px, py - widget.height / 2)
		px = px + widget.width
	end
	m_overlay_uimain:hideunused(overlay.widget._widgetpath .. "/animation/image_", numbercount + 1)	
end

local function overlay_createinst(overlay)
	local bindobject = actormanager_getfromactorid(overlay.bind)
	if bindobject == nil then
		return false
	end
	local px,py,pz = bindobject:gethitpoint()
	local screen_x, screen_y = c_scene_worldtoscreen(px, py, pz)
	if screen_x < 0 and screen_y < 0 then
		return false
	end
	if #m_overlay_idle == 0 then
		m_overlay_count = m_overlay_count + 1
		local widgetsource = m_overlay_uimain:getwidget("inst_1")
		overlay.widget = widgetsource:clone("inst_" .. m_overlay_count)
		local widgetanim = string.format("%s/animation", overlay.widget._widgetpath)
		overlay.widget.widgetanim = m_overlay_uimain:getwidget(widgetanim)
	else
		overlay.widget = m_overlay_idle[#m_overlay_idle]
		table.remove(m_overlay_idle, #m_overlay_idle)
	end
	overlay_createnumber(overlay)
	overlay.widget:setvisible(true)
	overlay.widget:setposition(screen_x, screen_y)
	local time = overlay.widget.widgetanim:playuianim(overlay.anim, 1.0)
	if time < 0 then
		time = overlay.widget.widgetanim:playuianim("standard", 1.0)
	end
	overlay.complete = time_game + time
	return true
end

local function overlay_hideinst(overlay)
	overlay.widget:setvisible(false)
	m_overlay_idle[#m_overlay_idle + 1] = overlay.widget
end

function overlay_add(bindactorid, type, anim, prefix, sign, number)
	local overlay = {}
	overlay.bind = bindactorid
	overlay.type = type
	overlay.anim = anim or "standard"
	overlay.prefix = prefix
	overlay.sign = sign
	if number ~= nil then
		overlay.number = math.tointegerfloor(number)
	else
		overlay.number = nil
	end	
	if overlay_createinst(overlay) then
		m_overlay_list[#m_overlay_list + 1] = overlay
	end
end

function overlay_update()
	for i=#m_overlay_list, 1, -1 do	
        local overlay = m_overlay_list[i]
		if overlay.complete ~= nil and overlay.complete <= time_game then
			overlay_hideinst(overlay)
            table.remove(m_overlay_list, i)
		end
    end
end

function overlay_addpoint(actor, type, accuracy, val)
	if math.abs(val) < 1 and accuracy ~= lambdaaccuracytype.dodge and accuracy ~= lambdaaccuracytype.resist then
		return
	end

	local pointtype = nil
    local pointanim = nil
    local pointprefix = nil
    local pointsign = 0
    local pointnumber = val
	if type == lambdapointtype.hpinc then
        pointtype = overlaytype.hpinc
		pointanim = overlayanim.standard
    elseif type == lambdapointtype.hpdec then
		if actor:isme() or actor:ismyspirit() then
        	pointtype = overlaytype.hurt
		else
		    pointtype = overlaytype.damage
		end
		pointanim = overlayanim.standard
    elseif type == lambdapointtype.mpinc then
        pointtype = overlaytype.mpinc
		pointanim = overlayanim.standard
		pointsign = 1
    elseif type == lambdapointtype.mpdec then
        pointtype = overlaytype.mpinc
		pointanim = overlayanim.standard
		pointsign = -1
	elseif type == lambdapointtype.fpinc then
        pointtype = overlaytype.damagecrit
		pointanim = overlayanim.standard
		pointsign = 1
    elseif type == lambdapointtype.fpdec then
        pointtype = overlaytype.damagecrit
		pointanim = overlayanim.standard
		pointsign = -1
    end
	if accuracy ~= nil then
		if accuracy == lambdaaccuracytype.crit then
			if actor:isme() then
				pointprefix = overlayprefix.critical_r
			else
				pointprefix = overlayprefix.critical_w
			end
		elseif accuracy == lambdaaccuracytype.dodge then
			if actor:isme() then
				pointprefix = overlayprefix.dodge_r
			else
				pointprefix = overlayprefix.dodge_w
			end
			pointnumber = nil
		elseif accuracy == lambdaaccuracytype.parry then
			if actor:isme() then
				pointprefix = overlayprefix.parry_r
			else
				pointprefix = overlayprefix.parry_w
			end
		elseif accuracy == lambdaaccuracytype.block then
			if actor:isme() then
				pointprefix = overlayprefix.block_r
			else
				pointprefix = overlayprefix.block_w
			end
		elseif accuracy == lambdaaccuracytype.resist then
			if actor:isme() then
				pointprefix = overlayprefix.resist_r
			else
				pointprefix = overlayprefix.resist_w
			end
			pointnumber = nil
		end
	end
    if pointtype ~= nil then
        overlay_add(actor.actorid, pointtype, pointanim, pointprefix, pointsign, pointnumber)
    end
end
