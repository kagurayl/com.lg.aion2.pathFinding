
local playerbattle_battlestate = 0

function playerbattle_updatebattlestate()
	playerbattle_battlestate = time_game + 10
end

function playerbattle_getbattlestate()
	return playerbattle_battlestate > time_game
end

function playerbattle_getattackdelay(attr, equip)
	local attackdelay = 1.5
    local weaponmain = equip[equipslot.weapon1]
    if weaponmain ~= nil and weaponmain.itemid ~= 0 then
        local config_item = csvitem_getfromid(weaponmain.itemid)
        if config_item ~= nil then
            attackdelay = config_item.attackdelay
        end
    end
    local weaponsub = equip[equipslot.weapon2]
    if weaponsub ~= nil and weaponsub.itemid ~= 0 then
        local config_item = csvitem_getfromid(weaponsub.itemid)
        if config_item ~= nil and config_item.attackdelay ~= nil then
            if attackdelay > 0.0 then
                attackdelay = attackdelay + config_item.attackdelay * 0.25
            else
                attackdelay = attackdelay + config_item.attackdelay
            end
        end
    end
    attackdelay = attackdelay * attr.attackspeed
	return attackdelay
end

function playerbattle_getnormalattackdelay(time)
	return playerbattle_getattackdelay(playerattr_info, playeritem_getactiveequip()) * 1.1
end

function playerbattle_update()
	if m_me:ismovinginput() then
		playerapproach_clear()
		playerbattleauto_stopattack()
	end
	playerbattleauto_update()
	playerapproach_update()
end

function playerbattle_pickdist(config_skill, skilldist, target)
	if config_skill.weaponrange > 0 then
		skilldist = skilldist + playerattr_info.attackrange
	end
	if target ~= nil then
		skilldist = target:gettalkdist(skilldist)
	end
	return skilldist
end

function playerbattle_spell(skillid)
	if m_me == nil then
		return
	end
	local config_skill = csvskill_getfromid(skillid)
	if not playerattr_isvehicle() then
		config_skill = playerskill_gettoplevelavailable(config_skill)
	end
	if config_skill == nil then
		return
	end
	if config_skill.spellway == csvskillspellway.none then
		systemskill_spell(config_skill)
		return
	end

	local config_qte = playerskill_getqte(config_skill)
	if config_qte ~= nil then
		config_skill = config_qte
	end

	local selectactorid = m_selectactorid
	if config_skill.select ~= nil then
		local sublambda = config_skill.select[1]
		if c_isaction(sublambda, "pick") or c_isaction(sublambda, "pickme") then
			local movein = true
			if c_isaction(sublambda, "pickme") and m_selectactor ~= nil and m_selectactor:isenemy() then
				movein = false
			end
			if movein and gamesetting_getnumber("MANUALMOVEIN") == 0 and m_selectactorid ~= 0 and m_selectactor ~= nil  then
				local lambdadist = playerbattle_pickdist(config_skill, sublambda.variable[1].flt, m_selectactor)
				local movetoactor = 0
				local dist = vector3_distance(m_selectactor.transform.px,m_selectactor.transform.py,m_selectactor.transform.pz, m_me.transform.px,m_me.transform.py,m_me.transform.pz)
				if dist > lambdadist then
					movetoactor = m_selectactorid
				end
				if movetoactor ~= 0 then
					playerapproach_skill(m_selectactorid, lambdadist, skillid)
					return
				end
			end
		elseif c_isaction(sublambda, "invisible") then
			selectactorid = playerattr_teamselect
			if selectactorid == 0 or selectactorid == playerattr_info.actorid then
				return
			end
		end
	end
	playerapproach_clear()
	joystick_stoplockmove()

	local msg = {messageid="CS_SkillSpell"}
	msg.posx = playerattr_info.posx
	msg.posy = playerattr_info.posy
	msg.posz = playerattr_info.posz
	msg.rot = playerattr_info.rot
	msg.skillid = config_skill.id
	msg.skilllevel = config_skill.level
	msg.skilllevel = 1
	msg.target = selectactorid
	msg.mousex = playerattr_info.posx
	msg.mousey = playerattr_info.posy
	msg.mousez = playerattr_info.posz
	c_send(msg)
end

function playerbattle_preset(preset)
	local skillindex = playerskillpreset_getactive(preset)
	if skillindex == 0 then
		skillindex = 1
	end
	if preset.skillid[skillindex] == 0 then
		return		
	end
	playerbattle_spell(preset.skillid[skillindex])
end
