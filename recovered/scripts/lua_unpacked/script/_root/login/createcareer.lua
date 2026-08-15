

local m_career_actor = nil
local m_career_face = "001_head"
local m_career_hair = "001_hair"
local m_career_count = 4
local m_career_render =
{
	{itemsetid = 17, idleanim = "nidle_warrior_lobby_001", selectanim = "nselect_warrior_lobby_001"},
	{itemsetid = 14, idleanim = "nidle_cleric_lobby_001", selectanim = "nselect_cleric_lobby_001"},
	{itemsetid = 16, idleanim = "nidle_scout_lobby_001", selectanim = "nselect_scout_lobby_001"},
	{itemsetid = 15, idleanim = "nidle_mage_lobby_001", selectanim = "nselect_mage_lobby_001"},
}
local m_career_iconnormal = {"login/warrior1", "login/cleric1", "login/scout1", "login/mage1"}
local m_career_iconselect = {"login/warrior2", "login/cleric2", "login/scout2", "login/mage2"}

local function createcareer_updateselect()
	for i=1, m_career_count do
		local button_male = m_uilogin_createcareer:getwidget(string.format("career_%d/button_male", i))
		local maleenable = button_male.career ~= m_login_create_career or button_male.sex ~= m_login_create_sex
		button_male:setvisible(maleenable)

		local image_maleselect = m_uilogin_createcareer:getwidget(string.format("career_%d/image_maleselect", i))
		image_maleselect:setvisible(not maleenable)

		local button_female = m_uilogin_createcareer:getwidget(string.format("career_%d/button_female", i))
		local femaleenable = button_female.career ~= m_login_create_career or button_female.sex ~= m_login_create_sex
		button_female:setvisible(femaleenable)

		local image_femaleselect = m_uilogin_createcareer:getwidget(string.format("career_%d/image_femaleselect", i))
		image_femaleselect:setvisible(not femaleenable)

		local image_select = m_uilogin_createcareer:getwidget(string.format("career_%d/image_select", i))
		image_select:setvisible(m_login_create_career == i)

		local image_icon = m_uilogin_createcareer:getwidget(string.format("career_%d/image_icon", i))
		if m_login_create_career ~= i then
			image_icon:setsprite(m_career_iconnormal[i])
		else
			image_icon:setsprite(m_career_iconselect[i])
		end
	end
	login_createcareer_setcamera(0.2)
end

local function login_createcareer_getcareerindex(career, sex)
	if sex == playersex.male then
		return career * 2 - 1
	else
		return career * 2
	end
end

local function createcareer_createactor(career, sex)
	local dummyname
	if m_login_create_civ == playerciv.light then
		dummyname = string.format("Position_Light%02d", login_createcareer_getcareerindex(career, sex))
	else
		dummyname = string.format("Position_Dark%02d", login_createcareer_getcareerindex(career, sex))
	end
	local success,px,py,pz,rx,ry,rz,sx,sy,sz = c_scene_dummy(dummyname)
	local actor = _actorclass.new()
	actor:initactor(RenderLayerDefault)
	actor:settransform(px, py, pz, rx, ry, rz, sx, sy, sz)
	actor:createactor(0, string.format("createcareer_%d_%d", career, sex))
	actor:loadskeleton(csvrender_getskeletonid(m_login_create_civ, sex))
	actor:loadskin(renderslot.face, false, m_career_face, nil)
	actor:loadhair(m_career_hair)
	actor:sethairmode(subrenderhairmode.hair)
	actor.actorid = 0
	actor.attr = {}
	actor.attr.sex = sex
	actor.attr.civ = m_login_create_civ
	actor.attr.career = career
	local config_itemset = csvitemset_getfromid(m_career_render[career].itemsetid)
	if config_itemset ~= nil then
		local itemsetitem = string.splitinterger(config_itemset.item, ",")
		for i=1, #itemsetitem do
			local config_item = csvitem_getfromid(itemsetitem[i])
			if config_item ~= nil then
				local part, file = csvrender_getitemrender(config_item)
				if part ~= nil and csvrender_partisskin(part) and part ~= renderslot.face then
					actor:loadskin(part, false, file, nil)
				end
			end
		end
	end
	
	if m_login_create_career == career and m_login_create_sex == sex then
		local alias = actor:playanim(m_career_render[career].selectanim)
		actor.idleendtime = time_game + alias.length
	else
		actor:playanim(m_career_render[career].idleanim, 0, 1, 0)
	end
	return actor
end

function login_createcareer_createpreview()
	if m_career_actor == nil then
		m_career_actor = {}
		for i=1, m_career_count do
			local actor = {}
			actor[playersex.male] = createcareer_createactor(i, playersex.male)
			actor[playersex.female] = createcareer_createactor(i, playersex.female)
			m_career_actor[i] = actor
		end
	end
end

function login_createcareer_setcamera(time)
	if m_login_create_civ == playerciv.light then
		if m_login_create_career == 0 then
			maincamera_moveto("Camera_LightAll", time)
		else
			maincamera_moveto(string.format("Camera_Light%02d", login_createcareer_getcareerindex(m_login_create_career, m_login_create_sex)), time)
		end
	elseif m_login_create_civ == playerciv.dark then
		if m_login_create_career == 0 then
			maincamera_moveto("Camera_DarkAll", time)
		else
			maincamera_moveto(string.format("Camera_Dark%02d", login_createcareer_getcareerindex(m_login_create_career, m_login_create_sex)), time)
		end
	end
end

function login_createcareer_onopen()
	if m_login_create_civ == playerciv.light then
		maincamera_moveto("Camera_LightAll", 0.0)
	else
		maincamera_moveto("Camera_DarkAll", 0.0)
	end
	m_uilogin_createcareer:setwidgetdelegate("button_prev", login_createcareer_delegate_prev)
	m_uilogin_createcareer:setwidgetdelegate("button_next", login_createcareer_delegate_next)

	m_login_create_career = 0
	for i=1, m_career_count do
		local text_male = m_uilogin_createcareer:getwidget(string.format("career_%d/text_male", i))
		text_male:settext(string.format("%s(%s)", c_textformat(playercareertext[i]), c_textformat("UI_SEX_MALE")))

		local text_female = m_uilogin_createcareer:getwidget(string.format("career_%d/text_female", i))
		text_female:settext(string.format("%s(%s)", c_textformat(playercareertext[i]), c_textformat("UI_SEX_FEMALE")))

		local button_male = m_uilogin_createcareer:getwidget(string.format("career_%d/button_male", i))
		button_male:setdelegate(login_createcareer_delegate_career)
		button_male.career = i
		button_male.sex = playersex.male

		local button_female = m_uilogin_createcareer:getwidget(string.format("career_%d/button_female", i))
		button_female:setdelegate(login_createcareer_delegate_career)
		button_female.career = i
		button_female.sex = playersex.female

		local image_icon = m_uilogin_createcareer:getwidget(string.format("career_%d/image_icon", i))
		image_icon:setsprite(m_career_iconnormal[i])
	end
	
	createcareer_updateselect()
	login_createcareer_createpreview()
	login_createcareer_setcamera(0.0)
	event_register(eventtype.update, login_createcareer_update, m_uilogin_createcareer)
end

function login_createcareer_onclose()
	if m_career_actor ~= nil then
		for i=1, #m_career_actor do
			local actor = m_career_actor[i]
			actor[playersex.male]:destroyactor()
			actor[playersex.female]:destroyactor()
		end
		m_career_actor = nil
	end
end

function login_createcareer_update()
	if m_career_actor ~= nil then
		for i=1, #m_career_actor do
			local actor = m_career_actor[i]
			local actormale = actor[playersex.male]
			local actorfemale = actor[playersex.female]
			if actormale.idleendtime ~= nil and actormale.idleendtime < time_game then
				actormale.idleendtime = nil
				actormale:playanim(m_career_render[i].idleanim)
			end
			if actorfemale.idleendtime ~= nil and actorfemale.idleendtime < time_game then
				actorfemale.idleendtime = nil
				actorfemale:playanim(m_career_render[i].idleanim)
			end
			actormale:updateanim()
			actorfemale:updateanim()
		end
	end
end

function login_createcareer_delegate_career(sender)
	m_login_create_career = sender.career
	m_login_create_sex = sender.sex
	createcareer_updateselect()
	local actorcareer = m_career_actor[m_login_create_career]
	local actor = actorcareer[m_login_create_sex]
	local alias = actor:playanim(m_career_render[m_login_create_career].selectanim)
	actor.idleendtime = time_game + alias.length
	audiomanager_playaudioui(AudioLoginSelect)
end

function login_createcareer_delegate_prev()
	m_uilogin_createcareer:close()
	m_uilogin_createciv:open()
end

function login_createcareer_delegate_next()
	if m_login_create_career == 0 then
		m_login_create_career = playercareer.warrior
	end
	m_uilogin_createcareer:close()
	appearance_setdata(m_login_create_career, m_login_create_civ, m_login_create_sex, 0, true)
	appearance_create()
end
