
local m_playerpetdop_updatetime = 0

local function playerpetdop_skilluseable(skillid)
    local config_skill = csvskill_getfromid(skillid)
    if config_skill == nil then
        return false
    end
    local lambda = config_skill.lambda
    if lambda == nil then
        return false
    end
    local actioncount = lambda.actioncount
    local useable = false
    for i=1,actioncount do
        local sublambda = lambda[i]
        if c_isaction(sublambda, "buff") or c_isaction(sublambda, "filterbuff") then
            useable = true
            local buffid = sublambda.variable[1].integer
            if m_me.buff ~= nil and #m_me.buff > 0 then
                for i=1,#m_me.buff do
                    if m_me.buff[i].buffid == buffid then
                        return false
                    end
                end
            end
        end
    end
    return useable
end

local function playerpetdop_itemuseable(itemid)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return false
    end
    local cdlength, cdremain = timer_getcdfromid(cdtype_itemcd, config_item.cdid)
    if cdremain > 0 then
        return false
    end
    local lambda = csvitem_getscript(config_item, "skill")
    if lambda ~= nil then
        if playerpetdop_skilluseable(lambda.variable[1].integer) then
            return true
        end
    end
    return false
end

function playerpetattr_updatedop()
    if m_playerpetdop_updatetime > time_game then
        return
    end
    m_playerpetdop_updatetime = time_game + 1
	if playerattr_info.petuuid == 0 then
		return
	end
    local pet = playerattr_getpet(playerattr_info.petuuid)
    if pet == nil then
        return
    end
    for i=1,#pet.dopitem do
        if pet.dopactive[i] > 0 and playerpetdop_itemuseable(pet.dopitem[i]) then
            local item = playeritem_getitem(pet.dopitem[i])
            if item ~= nil then
                local msg = {messageid="CS_ItemConsume"}
                msg.uuid = item.uuid
                msg.target = m_selectactorid
                c_send(msg)
            end
        end
    end
end
