
cdtype_skillcdid = 100000000
cdtype_skillid = 200000000
cdtype_itemcd = 300000000
cdtype_motion = 400000000

cdmotion_fly = 1
cdmotion_movestate = 2
cdmotion_windpathdash = 3
cdmotion_petplay = 4

time_abysscarrier_spawn = 180.0

local m_servertime_creation = 0
local m_servertime_second = 0
local m_servertime_timezone_second = 0
local m_servertime_cd = {}
local m_timer_performancestart = 0

function timer_performancereset(print)
    if print then
        debugerror((c_time_performancetime() - m_timer_performancestart))
    end
    m_timer_performancestart = c_time_performancetime()
end

function timer_setservertime(servertime)
    m_servertime_creation = c_time_date2secondlocal(2025,2,22,22,22,22)
    c_time_servertime(servertime / 1000.0 - m_servertime_creation)
end

function timer_gettimesecond()
    return m_servertime_second
end

function timer_update()
    m_servertime_second = c_time_datesecond() - m_servertime_creation
end

function timer_daytime(servertime)
    local year,month,yday,mday,wday,hour,minute,second = c_time_second2datelocal(m_servertime_creation + servertime)
    return c_textformat("TIME_DAYTIME_MINUTE", string.format("%02d", hour), string.format("%02d", minute))
end

function timer_serverdate(servertime, hourtext, minutetext, secondtext)
    local year,month,yday,mday,wday,hour,minute,second = c_time_second2datelocal(m_servertime_creation + servertime)
    if hourtext then
        if minutetext then
            if secondtext then
                return c_textformat("TIME_PRECISE_SECOND", year, month, mday, hour, minute, second)
            else
                return c_textformat("TIME_PRECISE_MINUTE", year, month, mday, hour, minute)
            end
        else
            return c_textformat("TIME_PRECISE_HOUR", year, month, mday, hour)
        end
    else
        return c_textformat("TIME_PRECISE_DAY", year, month, mday)
    end
end

function timer_servercountdown(servertime, hourtext, minutetext, secondtext)
    servertime = servertime - m_servertime_second
    if servertime > 0 then
        return timerdesc_getdesc(servertime, hourtext, minutetext, secondtext)
    else
        return nil
    end
end

function timer_setcd(id, length, remain)
    if id > 0 then
        local cd = m_servertime_cd[id]
        if cd == nil then
            cd = {}
            m_servertime_cd[id] = cd
        end
        cd.length = length
        cd.complete = time_game + remain
    end
end

function timer_getcdfromid(type, id)
    local length = 0
    local remain = 0
    if id ~= nil then
        local cd = m_servertime_cd[type + id]
        if cd ~= nil and cd.complete > time_game then
            length = cd.length
            remain = cd.complete - time_game
        end
    end
    return length, remain
end

function timer_getcdfromskill(config_skill)
    if config_skill.cdid > 0 then
        return timer_getcdfromid(cdtype_skillcdid, config_skill.cdid)
    elseif config_skill.category > 0 then
        return timer_getcdfromid(cdtype_skillid, config_skill.category)
    else
        return timer_getcdfromid(cdtype_skillid, config_skill.id)
    end
end

function timer_getcdcoding(type, id)
    local length, remain = timer_getcdfromid(type, id)
    return remain > 0.0
end

function timerdesc_getafter(timeinsecond)
    return timerdesc_getdesc(timeinsecond, true, true, true)
end

function timerdesc_getfloatdesc(timeinsecond)
    local day = timeinsecond / 86400.0
    if day > 1.0 then
        return c_textformat("TIME_COUNT_DAY", string.format("%.1f", day))
    end
    local hour = timeinsecond / 3600.0
    if hour > 1.0 then
        return c_textformat("TIME_COUNT_HOUR", string.format("%.1f", hour))
    end
    local minute = timeinsecond / 60.0
    if minute > 1.0 then
        return c_textformat("TIME_SHORT_MINUTE", string.format("%.1f", minute))
    end
    return string.format("%.1f", timeinsecond)
end

function timerdesc_getdesc(timeinsecond, hourtext, minutetext, secondtext)
    local day = math.tointegerfloor(timeinsecond / 86400)
    local hour = math.tointegerfloor(math.tointegerfloor(timeinsecond % 86400) / 3600)
    local minute = math.tointegerfloor(math.tointegerfloor(timeinsecond % 3600) / 60)
    local second = math.tointegerfloor(timeinsecond % 60)
    if day > 0 then
        if hourtext and hour > 0 then
            return c_textformat("TIME_COUNT_DH", day, hour)
        else
            return c_textformat("TIME_COUNT_DAY", day)
        end
    end
    if not hourtext then
        return c_textformat("TIME_COUNT_DAY", day)
    end

    if hour > 0 then
        if minutetext and minute > 0 then
            return c_textformat("TIME_COUNT_HM", hour, minute)
        else
            return c_textformat("TIME_COUNT_HOUR", hour)
        end
    end
    if not minutetext then
        return c_textformat("TIME_COUNT_HOUR", hour)
    end

    if minute > 0 then
        if secondtext and second > 0 then
            return c_textformat("TIME_COUNT_MS", minute, second)
        else
            return c_textformat("TIME_COUNT_MINUTE", minute)
        end
    end
    if not secondtext then
        return c_textformat("TIME_COUNT_MINUTE", minute)
    end
    
    return c_textformat("TIME_COUNT_SECOND", second)
end

function timerdesc_getdescshort(timeinsecond)
    local day = math.tointegerfloor(timeinsecond / 86400)
    local hour = math.tointegerfloor(math.tointegerfloor(timeinsecond % 86400) / 3600)
    local minute = math.tointegerfloor(math.tointegerfloor(timeinsecond % 3600) / 60)
    local second = math.tointegerfloor(timeinsecond % 60)
    if day > 0 then
        return c_textformat("TIME_SHORT_DAY", day)
    end
    if hour > 0 then
        return c_textformat("TIME_SHORT_HOUR", hour)
    end
    if minute > 0 then
        return c_textformat("TIME_SHORT_MINUTE", minute)
    end
    return c_textformat("TIME_SHORT_SECOND", second)
end

function timerdesc_countdown(servertime)
    local counttime = servertime - m_servertime_second
    if counttime > 0 then
        return timerdesc_getafter(counttime)
    else
        return ""
    end
end

function timerdesc_early(servertime)
    local earlytime = m_servertime_second - servertime
    if earlytime < 86400 then
        return c_textformat("TIME_BEFORE_INDAY")
    else
        return c_textformat("TIME_BEFORE_OTHERDAY", math.tointegerfloor(earlytime / 86400))
    end
end
