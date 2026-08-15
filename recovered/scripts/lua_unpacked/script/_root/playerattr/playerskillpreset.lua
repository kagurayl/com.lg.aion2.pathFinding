
playerattr_skillpreset = nil
playerattr_skillqtepriority = nil
playerattr_skillpresetactive = nil

function playerskillpreset_getpreset(uuid)
	for i=1,#playerattr_skillpreset do
        if playerattr_skillpreset[i].uuid == uuid then
            return playerattr_skillpreset[i]
        end
    end
end

function playerskillpreset_getqtepriority(skillid)
	for i=1,#playerattr_skillqtepriority do
        local priority = playerattr_skillqtepriority[i]
        if priority.skillid == skillid then
            return playerattr_skillqtepriority[i]
        end
    end
end

function playerskillpreset_adjustqtepriority(skillid, skillarray)
    local serverpriority = playerskillpreset_getqtepriority(skillid)
	if serverpriority == nil then
		return
	end
	if #serverpriority.qtelink == #skillarray then
		local same = true
		for i=1,#serverpriority.qtelink do
			local config_skill = skillarray[i]
			if config_skill.id ~= serverpriority.qtelink[i] then
				same = false
				break
			end
		end
		if same then
			return
		end
	end

	local srcarray = table.clonearray(skillarray)
	table.cleararray(skillarray)
	for i=1,#serverpriority.qtelink do
		for j=1, #srcarray do
			local config_skill = srcarray[j]
			if config_skill.id == serverpriority.qtelink[i] then
				skillarray[#skillarray + 1] = config_skill
				table.remove(srcarray, j)
				break
			end
		end 
	end
	for i=1, #srcarray do
		local config_skill = srcarray[i]
		skillarray[#skillarray + 1] = config_skill
	end
end

function playerskillpreset_geticon(iconindex)
	return "skills/macro_icon" .. (math.fmod(iconindex, 6) + 1)
end

function playerskillpreset_isqteactive(preset)
	return preset.activeindex ~= nil and preset.activeindex > 0 and time_game - preset.prevskilltime < 5
end

local function playerskillpreset_skillavailable(config_skill)
	local cdlength, cdremain = timer_getcdfromskill(config_skill)
	if cdremain == 0 and not playerattr_isvehicle() and playerskill_spellable(config_skill) then
		return true
	end
	return false
end

function playerskillpreset_getactive(preset)
	if preset.type == csvskillpresettype.qte then
		if playerskillpreset_isqteactive(preset) then
			return preset.activeindex, true
		else
			local config_qte = playerskill_getqte(csvskill_getfromid(preset.skillid[1]))
			if config_qte ~= nil then
				return 1, true
			end
		end
	else
		for i=1,#preset.skillid do
			local config_skill = csvskill_getfromid(preset.skillid[i])
			if config_skill ~= nil then
				local config_qte = playerskill_getqte(config_skill)
				if config_qte ~= nil and playerskillpreset_skillavailable(config_qte) then
					return i, true
				end
				config_qte = playerskill_getcounterqte(config_skill)
				if config_qte ~= nil and playerskillpreset_skillavailable(config_qte) then
					return i, true
				end
			end
		end
		for i=1,#preset.skillid do
			local config_skill = csvskill_getfromid(preset.skillid[i])
			if config_skill ~= nil and playerskillpreset_skillavailable(config_skill) then
				return i, false
			end
		end
	end
	return 0
end

local function playerskillpreset_issublink(config_parent, config_sub)
	if config_parent == nil or config_sub == nil then
        return false
    end
    if config_parent.category ~= 0 then
        config_parent = csvskill_getfromid(config_parent.category)
		if config_parent == nil then
        	return false
    	end
    end
    if config_sub.category ~= 0 then
        config_sub = csvskill_getfromid(config_sub.category)
		if config_sub == nil then
        	return false
    	end
    end
    if config_parent.id == config_sub.id then
        return true
    end
    local qtesublink = csvskill_getqtesublink(config_parent)
    if qtesublink == nil then
        return false
    end
    for i=1,#qtesublink do
        if playerskillpreset_issublink(qtesublink[i], config_sub) then
            return true
        end
    end
    return false
end

function playerskillpreset_updateindex(skillid)
	local config_skill = csvskill_getfromid(skillid)
	if config_skill == nil then
		return
	end
	for i=1,#playerattr_skillpreset do
		local preset = playerattr_skillpreset[i]
		if preset.type == csvskillpresettype.qte then
			local skillindex = 1
			if playerskillpreset_isqteactive(preset) then
				skillindex = preset.activeindex
			end
			local config_presetskill = csvskill_getfromid(preset.skillid[skillindex])
			if playerskillpreset_issublink(config_presetskill, config_skill) then
				local config_qte = playerskill_getqte(config_skill)
				if config_qte == nil then
					preset.activeindex = skillindex + 1
					if preset.activeindex > #preset.skillid or preset.skillid[preset.activeindex] == 0 then
						preset.activeindex = 0
					end
				else
					preset.activeindex = skillindex
				end
				preset.prevskilltime = time_game
			else
				preset.activeindex = 0
			end
		end
	end
end
