
skill_system_battle = 50000
skill_system_rest = 50001
skill_system_getitem = 50002
skill_system_subactor = 50003
skill_system_equip = 50004
skill_system_run = 50005
skill_system_attack = 50006
skill_system_fly = 50007
skill_system_battery = 50008
skill_system_report = 50009
skill_system_spiritattack = 50046
skill_system_spiritmove = 50047
skill_system_spiritidle = 50048
skill_system_spiritdismiss = 50049
skill_system_tabselect = 50050
skill_system_jump = 50051
skill_system_bug = 50052

skill_sysytem_idstart = 50000
skill_sysytem_idend = 50052

skill_logo_start = 50010
skill_logo_end = 50041
skill_logo_active = {50010, 50012, 50014, 50016, 50018, 50020, 50022, 50024, 50026, 50028, 50030, 50032, 50034, 50036, 50038, 50040}
skill_logo_select = {50011, 50013, 50015, 50017, 50019, 50021, 50023, 50025, 50027, 50029, 50031, 50033, 50035, 50037, 50039, 50041}

skill_pet_list = 50042
skill_pet_gift = 50043
skill_pet_dop = 50044
skill_pet_loot = 50045

local systemskill_delegate = {}

function systemskill_logoactive(data)
    local msg = {messageid="CS_ActorLogo"}
    msg.logo = data.logo
    msg.actorid = m_selectactorid
    c_send(msg)
end

function systemskill_logoselect(data)
	local actorid = playerattr_logo[data.logo]
	if actorid ~= nil then
		local actor = actormanager_getfromactorid(actorid)
		if actor ~= nil then
			actormanager_selectactor(actor)
		end
	end
end

function systemskill_battle(data)
	if playerattr_info.movetype ~= playermovestate.rest then
		local msg = {messageid="CS_SwitchBattle"}
		if m_me:getbattle() then
			msg.battle = 0
		else
			msg.battle = 1
		end
		c_send(msg)	
	end
end

function systemskill_rest(data)
	if playerattr_info.movetype == playermovestate.move then
		local msg = {messageid="CS_SwitchRest"}
		msg.rest = 1
		c_send(msg)
	elseif playerattr_info.movetype == playermovestate.rest then
		local msg = {messageid="CS_SwitchRest"}
		msg.rest = 0
		c_send(msg)
	end
end

function systemskill_getitem(data)
    local npc = actormanager_getfromactorid(m_selectactorid)
    if npc ~= nil and npc:isnpc() and npc:isdead() then
        local msg = {messageid="CS_NPCQueryDrop"}
        msg.actorid = m_selectactorid
        c_send(msg)
    end
end

function systemskill_subactor(data)
    local actor = actormanager_getfromactorid(m_selectactorid)
    if actor ~= nil and actor.attr.selection ~= nil then
		local subactor = actormanager_getfromactorid(actor.attr.selection)
		if subactor ~= nil then
			actormanager_selectactor(subactor)
		end
    end
end

function systemskill_equip(data)
	local msg = {messageid="CS_EquipSwitch"}
	if playerattr_info.equipindex == 0 then
		msg.index = 1
	else
		msg.index = 0
	end
    c_send(msg)
end

function systemskill_run(data)
	local msg = {messageid="CS_SwitchRun"}
	if playerattr_info.moverun == 0 then
		msg.run = 1
	else
		msg.run = 0
	end
    c_send(msg)
end

function systemskill_attack(data)
	local evadeskill = skillqte_getevadeskill()
	if evadeskill ~= nil and gamesetting_getnumber("ATTACKSHOCK") > 0 then
		playerbattle_spell(evadeskill.qteskillid)
		return
	end
	playerskillpreset_updateindex(skill_system_attack)
	local actor = actormanager_getfromactorid(m_selectactorid)
	if actor ~= nil then
		if actor:isplayer() then
			playerbattleauto_startnormalattack(m_selectactorid)
		else
			npc_startscript(m_selectactorid)
		end
	else
		actormanager_autoselectactor(-1)
	end
end

function systemskill_fly(data)
	if playerattr_info.areafly > 0 and (playerattr_info.movetype == playermovestate.move or playerattr_info.movetype == playermovestate.glide) then
		local msg = {messageid="CS_SwitchFly"}
		msg.fly = 1
		c_send(msg)
	elseif playerattr_info.movetype == playermovestate.fly then
		if not timer_getcdcoding(cdtype_motion, cdmotion_movestate) then
			local msg = {messageid="CS_SwitchFly"}
			msg.fly = 0
			c_send(msg)
		end
	end
end

function systemskill_battery(data)
	local msg = {messageid="CS_SwitchBattery"}
	if playerattr_info.battery > 0 then
		msg.boost = 0
	else
		msg.boost = 1
	end
	c_send(msg)
end

function systemskill_report(data)
    bugreport_open()
end

function systemskill_spiritattack(data)
	if m_selectactorid ~= 0 then
		local msg = {messageid="CS_SpiritAttack"}
		msg.actorid = m_selectactorid
		c_send(msg)
	end
end

function systemskill_spiritmove(data)
	local msg = {messageid="CS_SpiritMove"}
	c_send(msg)
end

function systemskill_spiritidle(data)
	local msg = {messageid="CS_SpiritIdle"}
	c_send(msg)
end

function systemskill_spiritdismiss(data)
	local msg = {messageid="CS_SpiritDismiss"}
	c_send(msg)
end

function systemskill_tabselect(data)
    local flag = 0
    if gamesetting_getnumber("TABENEMYNPC") > 0 then
        flag = bit.bor(flag, actorautoselect.enemynpc)
    end
    if gamesetting_getnumber("TABENEMYPLAYER") > 0 then
        flag = bit.bor(flag, actorautoselect.enemyplayer)
    end
    if gamesetting_getnumber("TABSIPIDNPC") > 0 then
        flag = bit.bor(flag, actorautoselect.sipidnpc)
    end
    if gamesetting_getnumber("TABSIPIDPLAYER") > 0 then
        flag = bit.bor(flag, actorautoselect.sipidplayer)
    end
    if gamesetting_getnumber("TABENEMYNPCDEAD") > 0 then
        flag = bit.bor(flag, actorautoselect.enemynpcdead)
    end
    if gamesetting_getnumber("TABSIPIDPLAYERDEAD") > 0 then
        flag = bit.bor(flag, actorautoselect.sipidplayerdead)
    end
    if gamesetting_getnumber("TABHARVEST") > 0 then
        flag = bit.bor(flag, actorautoselect.harvest)
    end
    if flag ~= 0 then
        actormanager_autoselectactor(flag)
    end
end

function systemskill_jump(data)
	inputkey_jump()
end

function systemskill_bugconfirm(ok, data)
    if ok then
        local msg = {messageid="CS_BugQsk"}
        c_send(msg)
    end
end
function systemskill_bug(data)
	if not timer_getcdcoding(cdtype_skillid, skill_system_bug) then
		messagebox_confirm("NPC_QSK_BUG", systemskill_bugconfirm)
	end
end

function systemskill_petlist(data)
	pet_main_open()
end

function systemskill_petgift(data)
	pet_menu_opengift()
end

function systemskill_petdop(data)
	pet_menu_opendop()
end

function systemskill_petloot(data)
	pet_menu_openloot()
end

function systemskill_init()
	for i=1,#skill_logo_active do
		systemskill_delegate[skill_logo_active[i]] = {delegate = systemskill_logoactive, logo = i}
	end

	for i=1,#skill_logo_select do
		systemskill_delegate[skill_logo_select[i]] = {delegate = systemskill_logoselect, logo = i}
	end

	systemskill_delegate[skill_system_battle] = {delegate = systemskill_battle}
	systemskill_delegate[skill_system_rest] = {delegate = systemskill_rest}
	systemskill_delegate[skill_system_getitem] = {delegate = systemskill_getitem}
	systemskill_delegate[skill_system_subactor] = {delegate = systemskill_subactor}
	systemskill_delegate[skill_system_equip] = {delegate = systemskill_equip}
	systemskill_delegate[skill_system_run] = {delegate = systemskill_run}
	systemskill_delegate[skill_system_attack] = {delegate = systemskill_attack}
	systemskill_delegate[skill_system_fly] = {delegate = systemskill_fly}
	systemskill_delegate[skill_system_battery] = {delegate = systemskill_battery}
	systemskill_delegate[skill_system_report] = {delegate = systemskill_report}
	systemskill_delegate[skill_system_spiritattack] = {delegate = systemskill_spiritattack}
	systemskill_delegate[skill_system_spiritmove] = {delegate = systemskill_spiritmove}
	systemskill_delegate[skill_system_spiritidle] = {delegate = systemskill_spiritidle}
	systemskill_delegate[skill_system_spiritdismiss] = {delegate = systemskill_spiritdismiss}
	systemskill_delegate[skill_system_tabselect] = {delegate = systemskill_tabselect}
	systemskill_delegate[skill_system_jump] = {delegate = systemskill_jump}
	systemskill_delegate[skill_system_bug] = {delegate = systemskill_bug}
	systemskill_delegate[skill_pet_list] = {delegate = systemskill_petlist}
	systemskill_delegate[skill_pet_gift] = {delegate = systemskill_petgift}
	systemskill_delegate[skill_pet_dop] = {delegate = systemskill_petdop}
	systemskill_delegate[skill_pet_loot] = {delegate = systemskill_petloot}
end

function systemskill_verify(config_skill)
	local data = systemskill_delegate[config_skill.id]
	if data ~= nil and data.verify ~= nil then
		return data.verify(data)
	end
	return true
end

function systemskill_spell(config_skill)
	local data = systemskill_delegate[config_skill.id]
	if data ~= nil then
		data.delegate(data)
	end
end
