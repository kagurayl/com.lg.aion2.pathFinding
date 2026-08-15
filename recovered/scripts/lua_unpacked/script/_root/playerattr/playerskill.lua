
playerattr_skill = nil
playerattr_rankskill = nil
playerattr_skillslot = nil
playerattr_actionslot = nil
playerattr_qte = nil
playerattr_stigma = nil
playerattr_skillgcd = nil

playerattr_craftingskill = nil
playerattr_craftingrecipe = nil

playerattr_social = nil
playerattr_animcard = nil

function playerskill_clear()
	playerattr_skill = {}
    playerattr_rankskill = nil

	playerattr_qte = {}
	playerattr_craftingskill = {}
	playerattr_craftingrecipe = {}
	playerattr_stigma = {}
	playerattr_animcard = {}

	playerattr_qte.attackskillid = 0
	playerattr_qte.countertype = 0
end

function playerskill_set(msg)
	playerattr_stigma = msg.stigma
end

function playerskill_setgcd(timelength)
	playerattr_skillgcd = time_game + timelength
end

function playerskill_updaterankskill()
	playerattr_rankskill = nil
	local config_pvpscore = c_config_getmetaid(configid.player_pvpscore, playerattr_pvp.title)
    if config_pvpscore ~= nil then
        local skill = nil
        if playerattr_info.civ == playerciv.light then
            skill = config_pvpscore.lightskill
        else
            skill = config_pvpscore.darkskill
        end
        if skill ~= nil then
            playerattr_rankskill = string.splitnumber(skill, ";")
        end
    end
end

function playerskill_getgcd(config_skill)
	if playerattr_skillgcd ~= nil and playerattr_skillgcd > time_game then
		if config_skill ~= nil and csvskill_spellwayactive(config_skill) then
            return true
        end
	end
	return false
end

function playerskill_getcraftingskill(skillid)
    for i=1,#playerattr_craftingskill do
        if playerattr_craftingskill[i].skillid == skillid then
			return playerattr_craftingskill[i]
		end
	end
end

function playerskill_getcraftingskilllevel(skillid)
	if skillid ~= skill_gather_convert then
		for i=1,#playerattr_craftingskill do
			if playerattr_craftingskill[i].skillid == skillid then
				return playerattr_craftingskill[i].level
			end
		end
	end
end

function playerskill_getrecipe(recipeid)
	for i=1,#playerattr_craftingrecipe do
		if playerattr_craftingrecipe[i].recipeid == recipeid then
			return playerattr_craftingrecipe[i]
		end
	end
end

function playerskill_available(skillid)
	if playerattr_skill[skillid] ~= nil then
		return true
	end
	if playerattr_rankskill ~= nil then
		for i=1,#playerattr_rankskill do
			if playerattr_rankskill[i] == skillid then
				return true
			end
		end
	end
	return false
end

function playerskill_gettoplevelavailable(config_skill)
	if config_skill == nil then
		return nil
	end
	if csvskill_issystemskill(config_skill.id) then
		return config_skill
	end

    if config_skill.category == 0 then
		if playerskill_available(config_skill.id) then
			return config_skill
		else
			return nil
		end
    end
	local categoryarray = csvskill_getcategoryarray(config_skill.category)
	if categoryarray == nil then
		if playerskill_available(config_skill.id) then
			return config_skill
		else
			return nil
		end
	end
	local config_toplevel = nil
	for i=1,#categoryarray do
		local config_categoryskill = categoryarray[i]
		if config_toplevel == nil or config_categoryskill.categorylevel > config_toplevel.categorylevel then
			if playerskill_available(config_categoryskill.id) then
				config_toplevel = config_categoryskill
			end
		end
	end
	return config_toplevel
end

function playerskill_getskillbarslot(page, slot)
	for i=1,#playerattr_skillslot do
		local attr = playerattr_skillslot[i]
		if attr.page == page and attr.slot == slot then
			return attr
		end
	end
end

function playerskill_getactionbarslot(slot)
	for i=1,#playerattr_actionslot do
		local attr = playerattr_actionslot[i]
		if attr.slot == slot then
			return attr
		end
	end
end

local function playerskill_skillidinshortcut(skillid)
	for i=1,#playerattr_skillslot do
		local attr = playerattr_skillslot[i]
		if attr.skillid == skillid then
			return true
		end
	end
	for i=1,#playerattr_actionslot do
		local attr = playerattr_actionslot[i]
		if attr.skillid == skillid then
			return true
		end
	end
	return false
end
function playerskill_skillinshortcut(skillid)
	local config_skill = csvskill_getfromid(skillid)
	if config_skill == nil then
		return false
	end
	if config_skill.category == 0 then
		return playerskill_skillidinshortcut(skillid)
    end
	local categoryarray = csvskill_getcategoryarray(config_skill.category)
	if categoryarray == nil then
		return playerskill_skillidinshortcut(skillid)
	end
	for i=1,#categoryarray do
		local config_categoryskill = categoryarray[i]
		if playerskill_skillidinshortcut(config_categoryskill.id) then
			return true
		end
	end
	return false
end

function playerskill_getdeltalevel(skillid)
    local skilllearn = csvskilllearn_getfromcivcareer(playerattr_info.civ, playerattr_info.career)
    local config_skilllearn = skilllearn[skillid]
    if config_skilllearn == nil then
        return 1
    end
    return math.clamp(playerattr_info.level - config_skilllearn.playerlevel, 1, 9)
end

function playerskill_selectrotate(config_skill)
	local lambdaselect = config_skill.select
	if lambdaselect == nil then
		return false
	end
	local sublambda = lambdaselect[1]
	if c_isaction(sublambda, "pick") or c_isaction(sublambda, "pickme") or c_isaction(sublambda, "spirit") then
		return true
	end
	return false
end

local function playerskill_selectverifytargetlambda(target, sublambda)
	if c_isaction(sublambda, "team") or c_isaction(sublambda, "teamspirit") or c_isaction(sublambda, "sipid") or c_isaction(sublambda, "sipidplayer") then
		return true
	elseif c_isaction(sublambda, "sipidnpc") then
		if not target:isenemy() and target:isnpc() then
			return true
		end
	elseif c_isaction(sublambda, "enemy") then
		if target:isenemy() then
			return true
		end
	elseif c_isaction(sublambda, "enemyplayer") then
		if target:isenemy() and target:isplayer() then
			return true
		end
	elseif c_isaction(sublambda, "enemynpc") then
		if target:isenemy() and target:isnpc() then
			return true
		end
	elseif c_isaction(sublambda, "buff") then
		for i=1,sublambda.variablecount do
			if target:getbufftypename(sublambda.variable[i].str) ~= nil then
				return true
			end
		end
	elseif c_isaction(sublambda, "dead") then
		if target:isdead() then
			return true
		end
	end
	return false
end
local function playerskill_selectverifytarget(target, config_skill)
	local selectstate = config_skill.selectstate
	if selectstate == nil then
		return true
	end
	if target == nil then
		return false
	end
	if target:isharvest() then
		return false
	end
	local actioncount = selectstate.actioncount
	for i=1,actioncount do
		local sublambda = selectstate[i]
		if not playerskill_selectverifytargetlambda(target, sublambda) then
			return false
		end
	end
	return true
end
local function playerskill_selectverify(config_skill)
	local lambdaselect = config_skill.select
	local onlyone = config_skill.subselect == nil
	if lambdaselect == nil then
		if onlyone and m_me ~= nil then
			return playerskill_selectverifytarget(m_me, config_skill)
		end
		return true
	end
	local sublambda = lambdaselect[1]
	if c_isaction(sublambda, "pick") then
		if m_selectactor == nil then
			return false
		end
		if onlyone then
			if not playerskill_selectverifytarget(m_selectactor, config_skill) then
				return false
			end
		end
		local lambdadist = playerbattle_pickdist(config_skill, sublambda.variable[1].flt, m_selectactor)
		local dist = vector3_distance(m_selectactor.attr.posx, m_selectactor.attr.posy, m_selectactor.attr.posz, m_me.attr.posx, m_me.attr.posy, m_me.attr.posz)
		if dist <= lambdadist then
			return true
		end
	elseif c_isaction(sublambda, "pickme") or c_isaction(sublambda, "mouse") then
		if m_selectactor == nil or m_selectactor:isme() then
			return true
		end
		if onlyone then
			if not playerskill_selectverifytarget(m_selectactor, config_skill) then
				return false
			end
		end
		local lambdadist = playerbattle_pickdist(config_skill, sublambda.variable[1].flt, m_selectactor)
		local dist = vector3_distance(m_selectactor.attr.posx, m_selectactor.attr.posy, m_selectactor.attr.posz, m_me.attr.posx, m_me.attr.posy, m_me.attr.posz)
		if dist <= lambdadist then
			return true
		end
	elseif c_isaction(sublambda, "spirit") then
		local spirit = actormanager_getfromactorid(playerattr_info.spiritid)
		if spirit ~= nil then
			if onlyone then
				if not playerskill_selectverifytarget(spirit, config_skill) then
					return false
				end
			end
			local lambdadist = playerbattle_pickdist(config_skill, sublambda.variable[1].flt, m_selectactor)
			local dist = vector3_distance(spirit.attr.posx, spirit.attr.posy, spirit.attr.posz, m_me.attr.posx, m_me.attr.posy, m_me.attr.posz)
			if dist <= lambdadist then
				return true
			end
		end
	elseif c_isaction(sublambda, "invisible") and playerattr_teamselect ~= 0 then
		return true
	end
	return false
end
function playerskill_weaponverify(config_skill)
	local strweapon = config_skill.weapon
	if strweapon == "0" then
		return true
	end
	local weapontype1 = 0
	local weapontype2 = 0
	local config_weapon1 = csvitem_getfromid(playeritem_getspareequip(equipslot.weapon1).itemid)
	if config_weapon1 ~= nil then
		weapontype1 = config_weapon1.itemtype
	end
	local config_weapon2 = csvitem_getfromid(playeritem_getspareequip(equipslot.weapon2).itemid)
	if config_weapon2 ~= nil then
		weapontype2 = config_weapon2.itemtype
	end
	local weaponequiped = false
	local weaponcount = csvconfig_getsubcount(strweapon)
	for i=1,weaponcount do
		local weapontype = csvconfig_getsubvalue(strweapon, i, configsubtype.int)
		if weapontype == csvitemtype.weapon_shield then
			if weapontype2 ~= csvitemtype.weapon_shield then
				return false
			end
			if weaponcount == 1 then
				weaponequiped = true
			end
		else
			if weapontype == weapontype1 or weapontype == weapontype2 then
				weaponequiped = true
			end
		end
	end
	if not weaponequiped then
		return false
	end
	return true
end

function playerskill_spellable(config_skill)
	if m_me == nil then
		return false
	end
	if m_me.actionmain.buffnoskill ~= nil and m_me.actionmain.buffvehicle == nil then
		return false
	end
	if config_skill.nobattle > 0 and playerbattle_getbattlestate() then
		return false
	end
	if config_skill.spellway == csvskillspellway.none then
		return systemskill_verify(config_skill)
	end
	local strbuff = config_skill.buff
	if strbuff ~= "0" then
		local buffsuccess = false
		local buffcount = csvconfig_getsubcount(strbuff)
		for i=1,buffcount do
			local buffid = csvconfig_getsubvalue(strbuff, i, configsubtype.int)
			if m_me:getbufffromid(buffid) ~= nil then
				buffsuccess = true
				break
			end
		end
		if not buffsuccess then
			return false
		end
	end
	if not playerskill_weaponverify(config_skill) then
		return false
	end
	if not playerskill_selectverify(config_skill) then
		return false
	end
	local lambdaskill = config_skill.lambda
	if lambdaskill ~= nil then
		local actioncount = lambdaskill.actioncount
		for i=1,actioncount do
			local sublambda = lambdaskill[i]
			if c_isaction(sublambda, "spiritskill") or c_isaction(sublambda, "threatswitch") then
				if playerattr_info.spiritid == 0 or actormanager_getfromactorid(playerattr_info.spiritid) == nil then
					return false
				end
			end
		end
	end
	local lambdacost = config_skill.cost
	if lambdacost ~= nil then
		local actioncount = lambdacost.actioncount
		for i=1,actioncount do
			local sublambda = lambdacost[i]
			if c_isaction(sublambda, "hp") then
				local flt = sublambda.variable[1].flt
				if flt ~= nil and flt > playerattr_info.hp then
					return false
				end
			elseif c_isaction(sublambda, "mp") then
				local flt = sublambda.variable[1].flt
				if flt ~= nil and flt > playerattr_info.mp then
					return false
				end
			elseif c_isaction(sublambda, "dp") then
				local flt = sublambda.variable[1].flt
				if flt ~= nil and flt > playerattr_info.dp then
					return false
				end
			elseif c_isaction(sublambda, "item") then
				local itemid = sublambda.variable[1].integer
				local itemcount = sublambda.variable[1].count
				if itemid ~= nil and itemcount ~= nil and itemcount > playeritem_getcount(itemid) then
					return false
				end
			end
		end
	end
    return true
end

local function playerskill_getsublinkqte(qtesublink)
	for i=1,#qtesublink do
		local config_qte = playerskill_gettoplevelavailable(qtesublink[i])
		if config_qte ~= nil then
			local cdlength, cdremain = timer_getcdfromskill(config_qte)
			if cdremain == 0 then
				local qtetimeout = csvskill_getqtetimeout(config_qte)
				if playerattr_qte.attacktimestart + qtetimeout >= time_game then
					return config_qte
				end
			end	
		end
	end
end
function playerskill_getqte(config_skill)
	if playerattr_qte.attackskillid ~= 0 and config_skill ~= nil then
		local qtesublink = csvskill_getqtesublinkadjustpriority(config_skill.id)
		if qtesublink == nil then
			return nil
		end
		if config_skill.id == playerattr_qte.attackskillid or config_skill.category == playerattr_qte.attackskillid then
			return playerskill_getsublinkqte(qtesublink)
		end
		for i=1,#qtesublink do
			local config_qte = playerskill_gettoplevelavailable(qtesublink[i])
			if config_qte ~= nil then
				local config_subqte = playerskill_getqte(config_qte)
				if config_subqte ~= nil then
					local cdlength, cdremain = timer_getcdfromskill(config_subqte)
					if cdremain == 0 then
						return config_subqte
					end
				end
			end
		end
	end
end

function playerskill_isactiveqte(config_skill)
	if playerattr_qte.attackskillid ~= 0 and config_skill ~= nil then
		local qtesublink = csvskill_getqtesublinkadjustpriority(playerattr_qte.attackskillid)
		if qtesublink ~= nil then
			for i=1,#qtesublink do
				local config_qteskill = qtesublink[i]
				if config_qteskill.id == config_skill.id or config_qteskill.id == config_skill.category then
					local qtetimeout = playerattr_qte.attacktimestart + csvskill_getqtetimeout(config_qteskill)
					if qtetimeout >= time_game then
						config_qteskill = playerskill_gettoplevelavailable(config_qteskill)
						if config_qteskill ~= nil and playerskill_weaponverify(config_qteskill) then
							local cdlength, cdremain = timer_getcdfromskill(config_qteskill)
							if cdremain == 0 then
								return true
							end
						end
					end
					break
				end
			end
		end
	end
	return false
end

function playerskill_getcounterqte(config_skill)
	if config_skill.id == skill_system_attack then
		local evadeskill = skillqte_getevadeskill()
		if evadeskill ~= nil and gamesetting_getnumber("ATTACKSHOCK") > 0 then
			return evadeskill.config_skill
		end
		return nil
	end
	if playerattr_qte.countertype ~= 0 and playerattr_qte.countertimestart + skill_counter_timeout >= time_game then
		local qtesublink = csvskill_getqtesublinkadjustpriority(playerattr_qte.countertype)
		if qtesublink == nil then
			return nil
		end
		for i=1,#qtesublink do
			local config_qte = playerskill_gettoplevelavailable(qtesublink[i])
			if config_qte ~= nil and config_qte.id == config_skill.id then
				local cdlength, cdremain = timer_getcdfromskill(config_qte)
				if cdremain == 0 then
					return config_qte
				end
			end
		end
	end
end

function playerskill_getitemcount(config_skill)
    local lambdacost = config_skill.cost
    if lambdacost ~= nil then
        local spellcost = nil
        local actioncount = lambdacost.actioncount
        for i=1,actioncount do
            local sublambda = lambdacost[i]
            local subcost = nil
            if c_isaction(sublambda, "item") then
                local itemid = sublambda.variable[1].integer
                local itemcount = sublambda.variable[1].count
                local bagitemcount = playeritem_getcount(itemid)
                return math.tointegerfloor(bagitemcount / itemcount)
            end
        end
    end
end
