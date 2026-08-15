
local notifystate = 
{
	none = 0,
	matching = 1,
	survey = 2,
}
local flystate = 
{
	none = 0,
	landdisable = 1,
	landenable = 2,
	flynormal = 3,
	flyred = 4,
}
m_uiactionbar = uipanel_createhandle("home/actionbar", uilayer.bottom, uiflag.scale)

function actionbar_onopen()
    m_uiactionbar.button_fly = m_uiactionbar:getwidget("button_fly")
	m_uiactionbar.text_flytime = m_uiactionbar:getwidget("text_flytime")
	m_uiactionbar.image_flytime = m_uiactionbar:getwidget("image_flytime")
	m_uiactionbar.image_flycd = m_uiactionbar:getwidget("image_flycd")
	m_uiactionbar.image_fxin = m_uiactionbar:getwidget("image_fxin")
	m_uiactionbar.image_fxout = m_uiactionbar:getwidget("image_fxout")
	m_uiactionbar.image_fxin:setvisible(false)
	m_uiactionbar.image_fxout:setvisible(false)
	m_uiactionbar:setwidgetdelegate("button_notify", actionbar_delegate_notify)
	m_uiactionbar:setwidgetdelegate("button_fly", actionbar_delegate_fly)

    m_uiactionbar.slot = {}
    for i=1,skill_actionbarslotmax do
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local slotname = string.format("line_%d/slot_%d", lineindex, slotindex)
		local markername = string.format("line_%d/marker_%d", lineindex, slotindex)
		local keyname = string.format("KEY_ACTION_%d_%d", lineindex, slotindex)
		m_uiactionbar.slot[i] = skillslot_createslot(m_uiactionbar, slotname, markername, keyname)
	end

    m_uiactionbar.notifystate = notifystate.none
	m_uiactionbar.movetype = -1
	m_uiactionbar.flystate = flystate.none
	m_uiactionbar.flyablefximage = nil
	m_uiactionbar.flytime = -1
	m_uiactionbar.flycd = false

	actionbar_updateui()
    actionbar_updatenotify()
	actionbar_updateexp()
	event_register(eventtype.update, actionbar_update, m_uiactionbar)
    event_register(eventtype.item, actionbar_updateui, m_uiactionbar)
end

function actionbar_keydown(keyname)
    if m_uiactionbar:alive() then
        for i=1, #m_uiactionbar.slot do
            local slot = m_uiactionbar.slot[i]
            if slot.keyname == keyname then
                skillslot_executeslot(slot)
            end
        end
    end
end

function actionbar_setflyvfx(flyable)
	if m_uiactionbar:null() then
		return
	end
	m_uiactionbar.flyablefxtime = time_game
	m_uiactionbar.image_fxin:setvisiblenothit(flyable)
	m_uiactionbar.image_fxout:setvisiblenothit(not flyable)
	if flyable then
		m_uiactionbar.flyablefximage = m_uiactionbar.image_fxin
	else
		m_uiactionbar.flyablefximage = m_uiactionbar.image_fxout
	end
end

function actionbar_updatenotify()
	if m_uiactionbar:null() then
		return
	end
	local button_notify = m_uiactionbar:getwidget("button_notify")
	local matchingvisible = matching_matching() and not matching_isvisible()
	if matchingvisible then
		button_notify:setvisible(true)
		button_notify:setsprite("sp1/matching")
		m_uiactionbar.notifystate = notifystate.matching
		return
	end
	if playerattr_survey ~= nil then
		button_notify:setvisible(true)
		button_notify:setsprite("sp1/survey")
		m_uiactionbar.notifystate = notifystate.survey
		return
	end
	button_notify:setvisible(false)
end

function actionbar_updateexp()
	if m_uiactionbar:null() then
        return
    end
	local text_exp = m_uiactionbar:getwidget("playerexp/text_exp")
	local ratio = 0
	local config_level = c_config_getmetaid(configid.player_exp, playerattr_info.level)
	if config_level ~= nil then
		ratio = playerattr_info.exp / config_level.exp
		text_exp:settext(string.format("%d/%d", math.tointegerfloor(playerattr_info.exp), math.tointegerfloor(config_level.exp)))
	else
		text_exp:settext("")
	end
	local step = 1.0 / 20.0
	for i=1,20 do
		local progress_exp = m_uiactionbar:getwidget("playerexp/progress_exp_" .. i)
		local percent = math.clamp(ratio / step, 0, 1)
		progress_exp:setpercent(percent)
		ratio = ratio - step
	end
end

function actionbar_updateui()
    if m_uiactionbar:null() then
        return
    end
    for i=1,#playerattr_actionslot do
		local attr = playerattr_actionslot[i]
		if attr.slot > 0 and attr.slot <= #m_uiactionbar.slot then
			m_uiactionbar.slot[attr.slot].attr = attr
		end
	end
    for i=1, #m_uiactionbar.slot do
        local slot = m_uiactionbar.slot[i]
        local attr = slot.attr
        slot.attr = nil
        skillslot_updateslot(slot, attr, false)
	end

	local linecount = 1
	if gamesetting_getnumber("ACTIONLINE2") > 0 then
		linecount = 2
	end
	if gamesetting_getnumber("ACTIONLINE3") > 0 then
		linecount = 3
	end
	if gamesetting_getnumber("ACTIONLINE4") > 0 then
		linecount = 4
	end
	m_uiactionbar:setwidgetvisible("line_1", true)
	m_uiactionbar:setwidgetvisible("line_2", linecount > 1)
	m_uiactionbar:setwidgetvisible("line_3", linecount > 2)
	m_uiactionbar:setwidgetvisible("line_4", linecount > 3)
end

local function actionbar_updateflytimeopacity()
	local opacity = 1.0
	if playerattr_info.movetype ~= playermovestate.fly and playerattr_info.movetype ~= playermovestate.glide then
		if m_uiactionbar.flystate == flystate.landdisable then
			opacity = 0.3
		else
			opacity = 0.6
		end
	end
	m_uiactionbar.text_flytime:setopacity(opacity)
end

local function actionbar_updatefly()
	if m_uiactionbar.flyablefximage ~= nil then
		local fxanim = (time_game - m_uiactionbar.flyablefxtime)
		if fxanim > 1.0 then
			m_uiactionbar.flyablefximage = nil
			m_uiactionbar.image_fxin:setvisible(false)
			m_uiactionbar.image_fxout:setvisible(false)
		else
			m_uiactionbar.flyablefximage:setcolor(1.0, 1.0, 1.0, fxanim)
		end
	end
	local state = flystate.none
	if playerattr_info.movetype == playermovestate.fly then
		if playerattr_info.fp > 15 then
			state = flystate.flynormal
		else
			state = flystate.flyred
		end
	else
		if playerattr_info.areafly > 0 then
			state = flystate.landenable
		else
			state = flystate.landdisable
		end
    end
	if m_uiactionbar.flystate ~= state then
		m_uiactionbar.flystate = state
		local button_fly = m_uiactionbar.button_fly
		local image_flytime = m_uiactionbar.image_flytime
		if state == flystate.landdisable then
			button_fly:setsprite("sp1/flystateland")
			button_fly:setenable(false)
			image_flytime:setsprite("sp1/flytimenormal")
		elseif state == flystate.landenable then
			button_fly:setsprite("sp1/flystateland")
			button_fly:setenable(true)
			image_flytime:setsprite("sp1/flytimenormal")
		elseif state == flystate.flynormal then
			button_fly:setsprite("sp1/flystatenormal")
			button_fly:setenable(true)
			image_flytime:setsprite("sp1/flytimenormal")
		elseif state == flystate.flyred then
			button_fly:setsprite("sp1/flystatered")
			button_fly:setenable(true)
			image_flytime:setsprite("sp1/flytimered")
		end
		actionbar_updateflytimeopacity()
	end
	if m_uiactionbar.movetype ~= playerattr_info.movetype then
		m_uiactionbar.movetype = playerattr_info.movetype
		if playerattr_info.movetype == playermovestate.fly or playerattr_info.movetype == playermovestate.glide then
			m_uiactionbar.image_flytime:setcolor(1.0, 1.0, 1.0, 1.0)
		else
			m_uiactionbar.image_flytime:setcolor(0.4, 0.4, 0.4, 1.0)
		end
		actionbar_updateflytimeopacity()
	end
	if m_uiactionbar.flytime ~= playerattr_info.fp then
		m_uiactionbar.flytime = playerattr_info.fp
		m_uiactionbar.image_flytime:setpercent(playerattr_info.fp / playerattr_info.fpmax)
		m_uiactionbar.text_flytime:settext(math.tointegerfloor(playerattr_info.fp))
	end
	local flycdlength, flycdremain = timer_getcdfromid(cdtype_motion, cdmotion_fly)
	if flycdremain > 0 then
		m_uiactionbar.image_flycd:setvisiblenothit(true)
		m_uiactionbar.image_flycd:setpercent(flycdremain / flycdlength)
		m_uiactionbar.flycd = true
	else
		m_uiactionbar.image_flycd:setvisiblenothit(false)
		if m_uiactionbar.flycd then
			m_uiactionbar.flycd = false
			audiomanager_playaudioui(AudioFlyCDTimeOver)
		end
	end
end
function actionbar_update()
	for i=1, #m_uiactionbar.slot do
		skillslot_updatecd(m_uiactionbar.slot[i])
	end
    actionbar_updatefly()
end

function actionbar_delegate_notify(sender, event)
	if m_uiactionbar.notifystate == notifystate.matching then
		matching_open()
	elseif m_uiactionbar.notifystate == notifystate.survey then
		if playerattr_survey ~= nil then
			survey_main_open()
		end
	end
end

function actionbar_delegate_fly(sender, event)
	systemskill_fly(nil)
end
