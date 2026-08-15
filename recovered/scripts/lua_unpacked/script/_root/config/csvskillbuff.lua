
battlebufftype = 
{
    none = 0,
    buff = 1,
    debuff = 2,
    chant = 3,
    item = 4,
    weakened = 5,
    boost = 6,
}

battlebuffdispel = 
{
    none = 0,
    buff = 1,
    debuff = 2,
    debuffmen = 3,
    stun = 4,
    npcbuff = 5,
    npcdebuff = 6,
    all = 7,
}

buffactiontype = 
{
    none = 0,
    immobilize = 1,
    stance = 2,
}

local function csvbuff_parsebuff(config_buff)
    local lambda = config_buff.lambda
    if lambda == nil then
        return
    end
    local arraycount = lambda.arraysize
    for i=1,arraycount do
        local lambda2 = lambda.lambdaarray[i]
        local actioncount = lambda2.actioncount
        for j=1,actioncount do
            local sublambda = lambda2[j]
            if c_isaction(sublambda, "flyoff")
            or c_isaction(sublambda, "pulled")
            or c_isaction(sublambda, "paralyze")
            or c_isaction(sublambda, "petrification")
            or c_isaction(sublambda, "stumble")
            or c_isaction(sublambda, "stun")
            or c_isaction(sublambda, "stagger")
            or c_isaction(sublambda, "spin" )
            or c_isaction(sublambda, "sleep")
            or c_isaction(sublambda, "root") then
                config_buff.buffaction = buffactiontype.immobilize
                config_buff.moveable = 0
            elseif c_isaction(sublambda, "openaerial") then
                config_buff.buffaction = buffactiontype.immobilize
                config_buff.openaerial = 1
                config_buff.moveable = 0
            elseif c_isaction(sublambda, "stance") then
                config_buff.buffaction = buffactiontype.stance
            elseif c_isaction(sublambda, "charm")
            or c_isaction(sublambda, "fear")
            or c_isaction(sublambda, "confuse") then
                config_buff.moveable = 0
            elseif c_isaction(sublambda, "noskill") then
                config_buff.noskill = 1
            elseif c_isaction(sublambda, "vehicle") then
                config_buff.vehicle = 1
            end
            if c_isaction(sublambda, "hide") then
                config_buff.hidelevel = sublambda.variable[1].integer
            elseif c_isaction(sublambda, "search") then
                config_buff.searchlevel = sublambda.variable[1].integer
            elseif c_isaction(sublambda, "deform") or c_isaction(sublambda, "morph") or c_isaction(sublambda, "shape") then
                config_buff.deform = sublambda.variable[1].integer
            end
        end
    end    
end

function csvskillbuff_load()
    local count = c_config_count(configid.skill_buff)
    for i=1,count do
        csvbuff_parsebuff(c_config_getmetaindex(configid.skill_buff, i))
    end
end

function csvskillbuff_isbuff(config_buff)
    if config_buff.type == battlebufftype.buff
    or config_buff.type == battlebufftype.chant
    or config_buff.type == battlebufftype.item
    or config_buff.type == battlebufftype.boost then
        return true
    end
    return false
end

function csvskillbuff_isdebuff(config_buff)
    if config_buff.type == battlebufftype.debuff
    or config_buff.type == battlebufftype.weakened then
        return true
    end
    return false
end

function csvskillbuff_getfromid(id)
    return c_config_getmetaid(configid.skill_buff, id)
end

function csvskillbuff_getscript(config_buff, typename)
    local lambda = config_buff.lambda
    if lambda ~= nil then
        local arraycount = lambda.arraysize
        for arrayindex=1,arraycount do
            local lambda2 = lambda.lambdaarray[arrayindex]
            local actioncount = lambda2.actioncount
            for lambdaindex=1,actioncount do
                local sublambda = lambda2[lambdaindex]
                if c_isaction(sublambda, typename) then
                    return sublambda
                end
            end
        end
    end
    return nil
end
