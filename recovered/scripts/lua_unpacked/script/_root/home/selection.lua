
local m_selection_uiarray = nil
local m_selection_uiindex = 0
local m_selection_actorid = 0
local m_selection_actorfly = false
local m_selection_spellid = nil
local m_selection_subactorid = 0
local m_selection_vfx = nil

function selection_create()
	if m_selection_uiarray == nil then
		m_selection_uiarray = {}
		for i=1,4 do
			m_selection_uiarray[i] = uipanel_createhandle("selection/selection" .. i, uilayer.bottom, bit.bor(uiflag.escapeclose, uiflag.scale))
			m_selection_uiarray[i]._delegatetitle = "selection"
		end
	end
end

function selection_onopen()
	m_selection_actorid = 0
	m_selection_actorfly = false
	m_selection_spellid = nil
	m_selection_subactorid = 0

	local uiselection = m_selection_uiarray[m_selection_uiindex]
	uiselection:setwidgetdelegate("image_bg", selection_delegate_bg)
	uiselection:setwidgetdelegate("selection_sub", selection_delegate_subbg)
	uiselection:setwidgetdelegate("button_close", selection_delegate_close)
	uiselection:setwidgetdelegate("image_buffclick", selection_delegate_bufflist)

	uiselection.mainwidget = {}
	uiselection.mainwidget.text_height = uiselection:getwidget("text_height")
	uiselection.mainwidget.text_dist = uiselection:getwidget("text_dist")
	uiselection.mainwidget.progress_hp = uiselection:getwidget("progress_hp")
	uiselection.mainwidget.progress_hpanim = uiselection:getwidget("progress_hpanim")
	uiselection.mainwidget.progress_hpdebuff = uiselection:getwidget("progress_hpdebuff")
	uiselection.mainwidget.progress_hpdebuffanim = uiselection:getwidget("progress_hpdebuffanim")
	uiselection.mainwidget.text_hp = uiselection:getwidget("text_hp")
	uiselection.mainwidget.progress_mp = uiselection:getwidget("progress_mp")
	uiselection.mainwidget.progress_mpanim = uiselection:getwidget("progress_mpanim")
	uiselection.mainwidget.text_mp = uiselection:getwidget("text_mp")

	uiselection.subwidget = {}
	uiselection.subwidget.progress_hp = uiselection:getwidget("selection_sub/progress_hp")
	uiselection.subwidget.progress_hpanim = uiselection:getwidget("selection_sub/progress_hpanim")
end

function selection_onclose()
	selection_clearvfx()
	selectionmenu_button_close()
end

function selection_onescape()
	actormanager_selectactor(nil)
end

function selection_clearvfx()
	if m_selection_vfx ~= nil then
		m_selection_vfx:destroy()
		m_selection_vfx = nil
	end
end

local function selection_createvfx(actor)
	if actor:isenemy() then
		if m_selection_actorfly then
			m_selection_vfx = vfxmanager_createvfx(EffectSelectEnemySky)
		else
			m_selection_vfx = vfxmanager_createvfx(EffectSelectEnemy)
		end
	else
		if m_selection_actorfly then
			m_selection_vfx = vfxmanager_createvfx(EffectSelectFriendSky)
		else
			m_selection_vfx = vfxmanager_createvfx(EffectSelectFriend)
		end
	end
	local bodysize = 1.0
	if actor.boundboxtalksize ~= nil then
		bodysize = actor.boundboxtalksize
	end
	local scale = math.min(3.0, bodysize / 2.0)
	m_selection_vfx:setbind(actor, vfx_bind_ground, vfxflag.followposition)
	m_selection_vfx:setscale(scale, scale, scale)
end
local function selection_updateactor(actor)
	local uiselection = m_selection_uiarray[m_selection_uiindex]
	local flying = actor:getfly()
	if m_selection_actorid ~= actor.actorid then
		m_selection_actorid = actor.actorid
		m_selection_actorfly = flying
		audiomanager_playaudioui(AudioTargetOpen)
		selection_updateui()

		local image_icon = uiselection:getwidget("image_icon")
		image_icon:seticon(actor:getheadicon())

		local text_level = uiselection:getwidget("text_level")
		text_level:settextraw(actor.attr.level)

		local text_name = uiselection:getwidget("text_name")
		text_name:settextrawscale(actor.attr.name)
		text_name:sethexcolor(actor:getnamecolor())

		selection_clearvfx()
		selection_createvfx(actor)
	end
	if m_selection_actorfly ~= flying then
		m_selection_actorfly = flying
		selection_clearvfx()
		selection_createvfx(actor)
	end

	local mainwidget = uiselection.mainwidget
	local height = math.abs((actor.transform.py - m_me.transform.py))
	if height < 1.0 then
		height = 0
	end
	mainwidget.text_height:settext("HOME_SELECTION_HEIGHT", math.tointegerfloor(height + 0.5))
	local dist = vector3_distance(actor.attr.posx, actor.attr.posy, actor.attr.posz, playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
	if actor:isnpc() and actor.boundboxsensorysize ~= nil then
		dist = math.max(0.0, dist - actor.boundboxsensorysize)
	end
	mainwidget.text_dist:settext("HOME_SELECTION_DIST", math.tointegerfloor(dist + 0.5))
	if actor:isplayer() or actor:isdynamicnpc() or actor:isstaticnpc() then
		local hppercent = actor.attrdisplay.hp / actor.attrdisplay.hpmax
		local hpanimpercent = actor.attrdisplay.hpanim / actor.attrdisplay.hpmax
		if actor.actionmain.buffhasdebuff then
			mainwidget.progress_hp:setpercent(0.0)
			mainwidget.progress_hpanim:setpercent(0.0)
			mainwidget.progress_hpdebuff:setpercent(hppercent)
			mainwidget.progress_hpdebuffanim:setpercent(hpanimpercent)
		else
			mainwidget.progress_hp:setpercent(hppercent)
			mainwidget.progress_hpanim:setpercent(hpanimpercent)
			mainwidget.progress_hpdebuff:setpercent(0.0)
			mainwidget.progress_hpdebuffanim:setpercent(0.0)
		end
		
		mainwidget.text_hp:settextrawscale(string.format("%d/%d", math.ceil(actor.attrdisplay.hpscroll), math.ceil(actor.attrdisplay.hpmax)))
		if mainwidget.progress_mp ~= nil then
			mainwidget.progress_mp:setpercent(actor.attrdisplay.mp / actor.attrdisplay.mpmax)
			mainwidget.progress_mpanim:setpercent(actor.attrdisplay.mpanim / actor.attrdisplay.mpmax)
			mainwidget.text_mp:settextrawscale(string.format("%d/%d", math.ceil(actor.attrdisplay.mpscroll), math.ceil(actor.attrdisplay.mpmax)))
		end
	else
		mainwidget.progress_hp:setpercent(1.0)
		mainwidget.progress_hpanim:setpercent(1.0)
		mainwidget.progress_hpdebuff:setpercent(0.0)
		mainwidget.progress_hpdebuffanim:setpercent(0.0)
		mainwidget.text_hp:settextraw("")
		if mainwidget.progress_mp ~= nil then
			mainwidget.progress_mp:setpercent(1.0)
			mainwidget.progress_mpanim:setpercent(1.0)
			mainwidget.text_mp:settextraw("")
		end
	end
	playerbuff_updateactorui(actor, uiselection)
end

local function selection_updatespell(actor)
	local spellid = 0
	if actor:isplayer() then
		if actor.actionmain.spelltype == playerspellstate.spellskill and actor.actionmain.config_skill ~= nil then
			spellid = actor.actionmain.config_skill.id
		end
	else
		if actor.attr.npcstate == npcsyncstate.spell and actor.actionmain.config_skill ~= nil then
			spellid = actor.actionmain.config_skill.id
		end
	end
	local uiselection = m_selection_uiarray[m_selection_uiindex]
	if m_selection_spellid ~= spellid then
		m_selection_spellid = spellid
		uiselection:setwidgetvisible("selection_spell", spellid ~= 0)
		if spellid ~= 0 then
			local text_name = uiselection:getwidget("selection_spell/text_name")
			text_name:settext(actor.actionmain.config_skill.name)
		end
	end
	if spellid ~= 0 then
		local progress_normal = uiselection:getwidget("selection_spell/progress_normal")
		local time = math.min(1.0, (time_game - actor.battle.spelltimestart) / actor.battle.spelltime)
		progress_normal:setpercent(time)
	end
end

local function selection_updatesubactor(mainactor)
	local uiselection = m_selection_uiarray[m_selection_uiindex]
	local actor = nil
	if mainactor.attr.selection ~= nil and not mainactor:isdead() then
		actor = actormanager_getfromactorid(mainactor.attr.selection)
	end
	if actor == nil then
		m_selection_subactorid = 0
		uiselection:setwidgetvisible("selection_sub", false)		
		return
	end

	if m_selection_subactorid ~= actor.actorid then
		m_selection_subactorid = actor.actorid
		uiselection:setwidgetvisible("selection_sub", true)
		local image_icon = uiselection:getwidget("selection_sub/image_icon")
		image_icon:seticon(actor:getheadicon())
	
		local text_name = uiselection:getwidget("selection_sub/text_name")
		text_name:settextrawscale(actor.attr.name)
		text_name:sethexcolor(actor:getnamecolor())

		local text_level = uiselection:getwidget("selection_sub/text_level")
		text_level:settextraw(actor.attr.level)
	end

	local subwidget = uiselection.subwidget
	subwidget.progress_hp:setpercent(actor.attrdisplay.hp / actor.attrdisplay.hpmax)
	subwidget.progress_hpanim:setpercent(actor.attrdisplay.hpanim / actor.attrdisplay.hpmax)
end

function selection_updateui()
	if m_selection_uiindex ~= 0 and m_selectactor ~= nil then
		local uiselection = m_selection_uiarray[m_selection_uiindex]
		if uiselection:alive() then
			local text_name = uiselection:getwidget("text_name")
			text_name:sethexcolor(m_selectactor:getnamecolor())

			if m_selectactor.attr.selection ~= nil and not m_selectactor:isdead() then
				local actorselection = actormanager_getfromactorid(m_selectactor.attr.selection)
				if actorselection ~= nil then
					text_name = uiselection:getwidget("selection_sub/text_name")
					text_name:sethexcolor(actorselection:getnamecolor())
				end
			end
		end
	end
end

function selection_update()
	if m_selection_uiarray == nil then
		return
	end
	if m_selectactor == nil or not m_selectactor:isvisible() then
		if m_selection_uiindex ~= 0 then
			m_selection_uiarray[m_selection_uiindex]:close()
			m_selection_uiindex = 0
			audiomanager_playaudioui(AudioTargetClose)
			selection_clearvfx()
		end
		return
	end
	local hpbar = 1
	if m_selectactor:isdynamicnpc() then
		if m_selectactor.config_npc.hpgauge <= 12 then
			hpbar = 1
		elseif m_selectactor.config_npc.hpgauge <= 19 then
			hpbar = 2
		elseif m_selectactor.config_npc.hpgauge <= 25 then
			hpbar = 3
		else
			hpbar = 4
		end
	end
	if hpbar ~= m_selection_uiindex then
		if m_selection_uiindex ~= 0 then
			m_selection_uiarray[m_selection_uiindex]:close()
		end
		m_selection_uiindex = hpbar
	end
	local panel = m_selection_uiarray[m_selection_uiindex]
	if panel:null() then
		panel:open()
	end
	selection_updateactor(m_selectactor)
	selection_updatespell(m_selectactor)
	selection_updatesubactor(m_selectactor)
end

function selection_updatecolor(actor)
	if m_selection_uiarray == nil or m_selection_uiindex == 0 then
		return
	end
	local uiselection = m_selection_uiarray[m_selection_uiindex]
	if not uiselection:alive() then
		return
	end
	if m_selection_actorid == actor.actorid then
		local text_name = uiselection:getwidget("text_name")
		text_name:sethexcolor(actor:getnamecolor())
	end
	if m_selection_subactorid == actor.actorid then
		local text_name = uiselection:getwidget("selection_sub/text_name")
		text_name:sethexcolor(actor:getnamecolor())
	end
end

function selection_delegate_subbg()
	actormanager_picksubactor()
end

function selection_delegate_bg(sender, event)
    selectionmenu_popmenu(m_selectactorid)
end

function selection_delegate_close(sender, event)
    actormanager_selectactor(nil)
end

function selection_delegate_bufflist(sender, event)
    selectionbufflist_create(m_selection_actorid)
end
