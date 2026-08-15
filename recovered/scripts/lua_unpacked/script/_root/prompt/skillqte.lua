
local m_uiskillqte = uipanel_createhandle("prompt/skillqte", uilayer.bottomtop, uiflag.scale)
local m_uiskillqte_iconlist = {}
local m_uiskillqte_skill = {}
local m_uiskillqte_evadeskill = nil

function skillqte_onopen()
	m_uiskillqte_iconlist = {}
	local iconindex = 1
	while true do
		local skillqteicon = m_uiskillqte:getwidget(string.format("skillqteicon_%d", iconindex))
		if skillqteicon == nil then
			break
		end
		local iconslot = {}
		iconslot.skillqteicon = skillqteicon
		iconslot.image_icon = m_uiskillqte:getwidget(string.format("skillqteicon_%d/image_icon", iconindex))
		iconslot.image_skillcd = m_uiskillqte:getwidget(string.format("skillqteicon_%d/image_skillcd", iconindex))
		iconslot.text_qtecd = m_uiskillqte:getwidget(string.format("skillqteicon_%d/text_qtecd", iconindex))
		iconslot.skillid = 0
		iconslot.skillqteicon:setvisible(false)
		m_uiskillqte_iconlist[#m_uiskillqte_iconlist + 1] = iconslot
		iconindex = iconindex + 1
	end
end

local function skillqte_setskillicon(skillslot)
	m_uiskillqte:open()
	local iconslot = nil
	for i=1,#m_uiskillqte_iconlist do
		if m_uiskillqte_iconlist[i].skillid == skillslot.qteskillid then
			iconslot = m_uiskillqte_iconlist[i]
			break
		end
	end
	if iconslot == nil then
		for i=1,#m_uiskillqte_iconlist do
			if m_uiskillqte_iconlist[i].skillid == 0 then
				iconslot = m_uiskillqte_iconlist[i]
				break
			end
		end
		if iconslot == nil then
			return
		end
	end
	if iconslot.skillid == 0 then
		iconslot.skillid = skillslot.qteskillid
		iconslot.skillqteicon:setvisible(true)
		iconslot.image_icon:setvisible(true)
		iconslot.image_icon:seticon(skillslot.icon)
		iconslot.image_icon:setdelegate(skillqte_delegate_shortcut)
		iconslot.image_icon.skillid = skillslot.qteskillid
	end

	if skillslot.cdlength > 0 and skillslot.cdremain > 0 then
		iconslot.image_skillcd:setvisiblenothit(true)
		iconslot.image_skillcd:setpercent(skillslot.cdremain / skillslot.cdlength)
	else
		iconslot.image_skillcd:setvisiblenothit(false)
	end

	if skillslot.timeout ~= nil then
		iconslot.text_qtecd:setvisiblenothit(true)
		iconslot.text_qtecd:settextraw(string.format("%.1f", math.max(0.0, skillslot.timeout - time_game)))
	else
		iconslot.text_qtecd:setvisiblenothit(false)
	end
end

local function skillqte_addskill(icon, cdlength, cdremain, timeout, config_skill)
	local qteskillid = -1
	if config_skill ~= nil then
		qteskillid = config_skill.id
	end
	for i=1,#m_uiskillqte_skill do
		local skill = m_uiskillqte_skill[i]
		if skill.qteskillid == qteskillid then
			skill.cdlength = cdlength
			skill.cdremain = cdremain
			skill.timeout = timeout
			skill.inuse = true
			return skill
		end
	end
	local skill = {}
	skill.icon = icon
	skill.cdlength = cdlength
	skill.cdremain = cdremain
	skill.timeout = timeout
	skill.qteskillid = qteskillid
	skill.config_skill = config_skill
	skill.inuse = true
	m_uiskillqte_skill[#m_uiskillqte_skill + 1] = skill
	return skill
end

local function skillqte_addbuffentry(skillid, bufftimeout)
	local qtesublink = csvskill_getqtesublinkadjustpriority(skillid)
	if qtesublink ~= nil then
		for i=1,#qtesublink do
			local config_qteskill = playerskill_gettoplevelavailable(qtesublink[i])
			if config_qteskill ~= nil then
				local cdlength, cdremain = timer_getcdfromskill(config_qteskill)
				if playerskill_getgcd(config_qteskill) or not playerskill_spellable(config_qteskill) then
					skillqte_addskill(config_qteskill.icon, 1.0, 1.0, bufftimeout, config_qteskill)
				else
					skillqte_addskill(config_qteskill.icon, cdlength, cdremain, bufftimeout, config_qteskill)
				end
			end
		end
	end
end

function skillqte_update()
	for i=1,#m_uiskillqte_skill do
		m_uiskillqte_skill[i].inuse = false
	end
	m_uiskillqte_evadeskill = nil

	if playerattr_qte ~= nil and playerattr_qte.attackskillid ~= 0 then
		local remove = true
		local qtesublink = csvskill_getqtesublinkadjustpriority(playerattr_qte.attackskillid)
		if qtesublink ~= nil then
			for i=1,#qtesublink do
				local config_qteskill = qtesublink[i]
				local qtetimeout = playerattr_qte.attacktimestart + csvskill_getqtetimeout(config_qteskill)
				if qtetimeout >= time_game then
					config_qteskill = playerskill_gettoplevelavailable(config_qteskill)
					if config_qteskill ~= nil and playerskill_weaponverify(config_qteskill) then
						remove = false
						local cdlength, cdremain = timer_getcdfromskill(config_qteskill)
						if playerskill_getgcd(config_qteskill) or not playerskill_spellable(config_qteskill) then
							skillqte_addskill(config_qteskill.icon, 1.0, 1.0, qtetimeout, config_qteskill)
						else
							skillqte_addskill(config_qteskill.icon, cdlength, cdremain, qtetimeout, config_qteskill)
						end
					end
				end
			end
		end
		if remove then
			playerattr_qte.attackskillid = 0
		end
	end

	if m_me ~= nil and not m_me.actionmain.buffmoveable then
		local config_avadeskill = nil
		local qtesublink = csvskill_getqtesublinkadjustpriority(skill_counter_evade)
		if qtesublink ~= nil then
			for i=1,#qtesublink do
				local config_qteskill = playerskill_gettoplevelavailable(qtesublink[i])
				if config_qteskill ~= nil and playerskill_weaponverify(config_qteskill) then
					config_avadeskill = config_qteskill
					break
				end
			end
		end
		if config_avadeskill ~= nil then
			local bufftimeout = 0
			for buffindex=1, #m_me.buff do
				local buff = m_me.buff[buffindex]
				local lambda = buff.config_buff.lambda
				if lambda ~= nil then
					local arraycount = lambda.arraysize
					for arrayindex=1,arraycount do
						local lambda2 = lambda.lambdaarray[arrayindex]
						local actioncount = lambda2.actioncount
						for lambdaindex=1,actioncount do
							local sublambda = lambda2[lambdaindex]
							if c_isaction(sublambda, "openaerial")
							or c_isaction(sublambda, "spin")
							or c_isaction(sublambda, "stagger")
							or c_isaction(sublambda, "stumble")
							or c_isaction(sublambda, "stun") then
								bufftimeout = buff.timeout
								break
							end
						end
					end
					if bufftimeout > 0 then
						break
					end
				end
			end
			if bufftimeout > 0 then
				local cdlength, cdremain = timer_getcdfromskill(config_avadeskill)
				if playerskill_getgcd(config_avadeskill) or not playerskill_spellable(config_avadeskill) then
					skillqte_addskill(config_avadeskill.icon, 1.0, 1.0, bufftimeout, config_avadeskill)
				else
					m_uiskillqte_evadeskill = skillqte_addskill(config_avadeskill.icon, cdlength, cdremain, bufftimeout, config_avadeskill)
				end
			end
		end
	end
	if m_selectactor ~= nil and not m_selectactor.actionmain.buffmoveable and m_selectactor:isenemy() then
		local openaerial = 0
		local spin = 0
		local stagger = 0
		local stumble = 0
		local stun = 0
		for buffindex=1, #m_selectactor.buff do
			local buff = m_selectactor.buff[buffindex]
			local lambda = buff.config_buff.lambda
			if lambda ~= nil then
				local arraycount = lambda.arraysize
				for arrayindex=1,arraycount do
					local lambda2 = lambda.lambdaarray[arrayindex]
					local actioncount = lambda2.actioncount
					for lambdaindex=1,actioncount do
						local sublambda = lambda2[lambdaindex]
						if c_isaction(sublambda, "openaerial") then
							openaerial = math.max(openaerial, buff.timeout)
						elseif c_isaction(sublambda, "spin") then
							spin = math.max(spin, buff.timeout)
						elseif c_isaction(sublambda, "stagger") then
							stagger = math.max(stagger, buff.timeout)
						elseif c_isaction(sublambda, "stumble") then
							stumble = math.max(stumble, buff.timeout)
						elseif c_isaction(sublambda, "stun") then
							stun = math.max(stun, buff.timeout)
						end
					end
				end
			end
		end
		if openaerial > 0 then
			skillqte_addbuffentry(skill_counter_openaerial, openaerial)
		end
		if spin > 0 then
			skillqte_addbuffentry(skill_counter_spin, spin)
		end
		if stagger > 0 then
			skillqte_addbuffentry(skill_counter_stagger, stagger)
		end
		if stumble > 0 then
			skillqte_addbuffentry(skill_counter_stumble, stumble)
		end
		if stun > 0 then
			skillqte_addbuffentry(skill_counter_stun, stun)
		end
	end

	if playerattr_qte ~= nil and playerattr_qte.countertype ~= 0 then
		local qtetimeout = playerattr_qte.countertimestart + skill_counter_timeout
		if qtetimeout >= time_game then
			local remove = true
			local skill = csvskill_getqtesublinkadjustpriority(playerattr_qte.countertype)
			if skill ~= nil then
				for i=1,#skill do
					local config_qteskill = skill[i]
					local config_toplevel = playerskill_gettoplevelavailable(config_qteskill)
					if config_toplevel ~= nil and playerskill_weaponverify(config_toplevel) then
						remove = false
						local cdlength, cdremain = timer_getcdfromskill(config_toplevel)
						local gcd = playerskill_getgcd(config_toplevel)
						if gcd then
							skillqte_addskill(config_toplevel.icon, 1.0, 1.0, qtetimeout, config_toplevel)
						else
							skillqte_addskill(config_toplevel.icon, cdlength, cdremain, qtetimeout, config_toplevel)
						end
					end
				end
			end
		end
		if remove then
			playerattr_qte.countertype = 0
		end
	end

	if playerattr_info ~= nil and playerattr_info.movewindpathid ~= nil then
		local cdlength, cdremain = timer_getcdfromid(cdtype_motion, cdmotion_windpathdash)
		skillqte_addskill("skills/icon_windpath_boost_01", cdlength, cdremain, nil, nil)
	end

	for i=#m_uiskillqte_skill,1,-1 do
		if not m_uiskillqte_skill[i].inuse then
			table.remove(m_uiskillqte_skill, i)
		end
	end
	if m_uiskillqte:alive() then
		for i=1,#m_uiskillqte_iconlist do
			local iconslot = m_uiskillqte_iconlist[i]
			if iconslot.skillid ~= 0 then
				local inuse = false
				for j=1,#m_uiskillqte_skill do
					if m_uiskillqte_skill[j].qteskillid == iconslot.skillid then
						inuse = true
						break
					end
				end
				if not inuse then
					iconslot.skillid = 0
					iconslot.skillqteicon:setvisible(false)
				end
			end
		end
	end
	for i=1,#m_uiskillqte_skill do
		skillqte_setskillicon(m_uiskillqte_skill[i])
	end
	if #m_uiskillqte_skill == 0 then
		m_uiskillqte:close()
	end
end

function skillqte_getevadeskill()
	return m_uiskillqte_evadeskill
end

function skillqte_delegate_shortcut(sender, event)
    if sender.skillid > 0 then
		playerbattle_spell(sender.skillid)
	elseif sender.skillid == -1 then
		local msg = {messageid="CS_DashWindPath"}
		c_send(msg)
	end
end
