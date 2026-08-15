
camerastate = 
{
    static = 1,
    move = 2,
    free = 3,
    fpp = 4,
    lookat = 5,
}

local m_camera_fix = {x = 0.0, y = 0.0, z = 0.0, pitch = 0.0, yaw = 0.0, roll = 0.0, dx = 1.0, dy = 0.0, dz = 0.0, fov = 45.0}
local m_camera_shake = {timestart = 0.0, timeend = 0.0, timeround = 0.05, amplitude = 2.0}
local m_camera_move = nil
local m_camera_free = nil
local m_camera_fpp = nil
local m_camera_lookat = nil
local m_camera_follow = nil
local m_camera_fov = 30.0
local m_camera_rangescale = 1.0
local m_camera_savetime = 0
local m_camera_savedelta = 3
local m_camera_state = camerastate.static

function maincamera_getstate()
    return m_camera_state
end

function maincamera_getposition()
    return m_camera_fix.x, m_camera_fix.y, m_camera_fix.z
end

function maincamera_getrotation()
    return m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll
end

function maincamera_getdir()
    return m_camera_fix.dx, m_camera_fix.dy, m_camera_fix.dz
end

function maincamera_setposition(px, py, pz)
    m_camera_fix.x = px
    m_camera_fix.y = py
    m_camera_fix.z = pz
    maincamera_apply()
end

function maincamera_setrotation(pitch, yaw, roll)
    m_camera_fix.pitch = pitch
    m_camera_fix.yaw = yaw
    m_camera_fix.roll = roll
    maincamera_apply()
end

function maincamera_setfov(fov)
    m_camera_fov = fov
    maincamera_apply()
end

function maincamera_setrangescale(rangescale)
    m_camera_rangescale = rangescale
    if m_camera_lookat ~= nil then
        local distmax = m_camera_lookat.distmax * m_camera_rangescale
        m_camera_lookat.dist = math.clamp(m_camera_lookat.dist, m_camera_lookat.distmin, distmax)
    end
    maincamera_apply()
end

function maincamera_shake(timelength)
    m_camera_shake.timestart = time_game
    m_camera_shake.timeend = m_camera_shake.timestart + timelength
    m_camera_shake.randindex = -1
    m_camera_shake.offsetx = 0.0
    m_camera_shake.offsety = 0.0
    m_camera_shake.offsetz = 0.0
end

function maincamera_move(x, y, z)
    if m_camera_state == camerastate.free then
        m_camera_fix.x = math.clamp(m_camera_fix.x + x, m_camera_free.xmin, m_camera_free.xmax)
        m_camera_fix.y = math.clamp(m_camera_fix.y + y, m_camera_free.ymin, m_camera_free.ymax)
        m_camera_fix.z = math.clamp(m_camera_fix.z + z, m_camera_free.zmin, m_camera_free.zmax)
        maincamera_apply()
    end
end

function maincamera_rotate(pitch, yaw, roll)
    if m_camera_state == camerastate.free then
        m_camera_fix.pitch = math.clamp(m_camera_fix.pitch + pitch, m_camera_free.pitchmin, m_camera_free.pitchmax)
        m_camera_fix.yaw = m_camera_fix.yaw + yaw
        m_camera_fix.roll = m_camera_fix.roll + roll
        maincamera_apply()
    elseif m_camera_state == camerastate.lookat then
        m_camera_fix.pitch = math.clamp(m_camera_fix.pitch + pitch, m_camera_lookat.pitchmin, m_camera_lookat.pitchmax)
        m_camera_fix.yaw = m_camera_fix.yaw + yaw
        m_camera_fix.roll = m_camera_fix.roll + roll
        maincamera_apply()
    end
end

function maincamera_wheel(wheel)
    if m_camera_state == camerastate.free then
        wheel_add(m_camera_free.wheel, wheel)
    elseif m_camera_state == camerastate.lookat then
        wheel_add(m_camera_lookat.wheel, wheel)
    end
end

function maincamera_lookat(x, y, z, immediately)
    local state = nil
    if m_camera_state == camerastate.lookat then
        state = m_camera_lookat
    end
    if state == nil then
        return
    end
    state.x = x
    state.z = z
    if immediately then
        state.y = y
    else
        local cushion = math.abs(y - state.y)
        local cushionadd = state.cushionspeed * time_frame
        if cushion - cushionadd > state.cushionmax then
            cushionadd = cushion - state.cushionmax
        end
        if cushionadd < cushion then
            if y > state.y then
                state.y = state.y + cushionadd
            else
                state.y = state.y - cushionadd
            end
        else
            state.y = y
        end
    end
    maincamera_apply()
end

function maincamera_update()
    if m_camera_shake.timestart > 0.0 then
        if m_camera_shake.timestart <= time_game then
            if m_camera_shake.timeend >= time_game then
                local randindex = math.floor((time_game - m_camera_shake.timestart) / m_camera_shake.timeround)
                if randindex ~= m_camera_shake.randindex then
                    m_camera_shake.randindex = randindex
                    m_camera_shake.amplitudex = (math.random() * 2.0 - 1.0) * m_camera_shake.amplitude
                    m_camera_shake.amplitudey = (math.random() * 2.0 - 1.0) * m_camera_shake.amplitude
                    m_camera_shake.amplitudez = (math.random() * 2.0 - 1.0) * m_camera_shake.amplitude
                end
                local t = math.fmod(time_game - m_camera_shake.timestart, m_camera_shake.timeround)
                if t < 0.5 then
                    t = t * 2.0
                else
                    t = (1.0 - t) * 2.0
                end
                local amplitudeamount = 1.0 - (time_game - m_camera_shake.timestart) / (m_camera_shake.timeend - m_camera_shake.timestart)
                m_camera_shake.offsetx = m_camera_shake.amplitudex * t * amplitudeamount
                m_camera_shake.offsety = m_camera_shake.amplitudey * t * amplitudeamount
                m_camera_shake.offsetz = m_camera_shake.amplitudez * t * amplitudeamount
            else
                m_camera_shake.timestart = 0.0
            end
        end
    end
    if m_camera_state == camerastate.move then
        if m_camera_move ~= nil then
            local t = (time_game - m_camera_move.time_start) / m_camera_move.time_length
            if t > 1.0 then
                t = 1.0
            end
            m_camera_fix.x = math.lerp(m_camera_move.px_start, m_camera_move.px_target, t)
            m_camera_fix.y = math.lerp(m_camera_move.py_start, m_camera_move.py_target, t)
            m_camera_fix.z = math.lerp(m_camera_move.pz_start, m_camera_move.pz_target, t)
            m_camera_fix.pitch = math.lerpdegree(m_camera_move.pitch_start, m_camera_move.pitch_target, t)
            m_camera_fix.yaw = math.lerpdegree(m_camera_move.yaw_start, m_camera_move.yaw_target, t)
            m_camera_fix.roll = math.lerpdegree(m_camera_move.roll_start, m_camera_move.roll_target, t)
            m_camera_fix.fov = math.lerpdegree(m_camera_move.fov_start, m_camera_move.fov_target, t)
            m_camera_fix.dx, m_camera_fix.dy, m_camera_fix.dz = vector3_angletovector(m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll)
            if t >= 1.0 then
                m_camera_move = nil
                m_camera_state = camerastate.static
            end
            c_camera_setstatic(m_camera_fix.x, m_camera_fix.y, m_camera_fix.z, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
        end
    elseif m_camera_state == camerastate.free then
        if wheel_getwheeling(m_camera_free.wheel) then
            local adddist = -wheel_getsmoothdelta(m_camera_free.wheel)
            m_camera_fix.x = m_camera_fix.x + m_camera_fix.dx * adddist
            m_camera_fix.y = m_camera_fix.y + m_camera_fix.dy * adddist
            m_camera_fix.z = m_camera_fix.z + m_camera_fix.dz * adddist
            maincamera_apply()
        end
    elseif m_camera_state == camerastate.lookat then
        if wheel_getwheeling(m_camera_lookat.wheel) then
            local adddist = wheel_getsmoothdelta(m_camera_lookat.wheel)
            local distmax = m_camera_lookat.distmax * m_camera_rangescale
            m_camera_lookat.dist = math.clamp(m_camera_lookat.dist + adddist, m_camera_lookat.distmin, distmax)
        end
        if m_camera_lookat.distfix < m_camera_lookat.dist then
            m_camera_lookat.distfix = math.min(m_camera_lookat.distfix + m_camera_lookat.distspeed * time_frame, m_camera_lookat.dist)
        end
        maincamera_apply()
        if m_camera_savetime < time_game then
            m_camera_savetime = time_game + m_camera_savedelta
            local setting = gamesetting_get()
            if setting ~= nil then
                setting["CAMERADIST"].current = m_camera_lookat.dist
                setting["CAMERAPITCH"].current = m_camera_fix.pitch
                setting["CAMERAYAW"].current = m_camera_fix.yaw
                gamesetting_savelocal()
            end
        end
    end
end

function maincamera_apply()
    local shakex = 0.0
    local shakey = 0.0
    local shakez = 0.0
    if m_camera_shake.timestart > 0.0 and m_camera_shake.timestart <= time_game then
        shakex = m_camera_shake.offsetx
        shakey = m_camera_shake.offsety
        shakez = m_camera_shake.offsetz
    end
    if m_camera_state == camerastate.free then
        m_camera_fix.fov = m_camera_fov
        m_camera_fix.dx, m_camera_fix.dy, m_camera_fix.dz = vector3_angletovector(m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll)
        c_camera_setstatic(m_camera_fix.x + shakex, m_camera_fix.y + shakey, m_camera_fix.z + shakez, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
    elseif m_camera_state == camerastate.fpp then
        m_camera_fix.fov = m_camera_fov
        m_camera_fix.dx, m_camera_fix.dy, m_camera_fix.dz = vector3_angletovector(m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll)
        c_camera_setstatic(m_camera_fix.x + shakex, m_camera_fix.y + shakey, m_camera_fix.z + shakez, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
    elseif m_camera_state == camerastate.lookat then
        m_camera_fix.fov = m_camera_fov
        local radius = 0.5
        local lookat_px = m_camera_lookat.x + shakex
        local lookat_py = m_camera_lookat.y + shakey
        local lookat_pz = m_camera_lookat.z + shakez
        local dx, dy, dz = vector3_angletovector(m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll)
        local dist = math.min(m_camera_lookat.dist, m_camera_lookat.distfix)
        local px,py,pz,nx,ny,nz,d = c_scene_spherecast(maskcamera, lookat_px, lookat_py, lookat_pz, radius, -dx, -dy, -dz, dist, false)
        if px ~= nil then
            m_camera_fix.x = px + nx * radius
            m_camera_fix.y = py + ny * radius
            m_camera_fix.z = pz + nz * radius
        else
            m_camera_fix.x = lookat_px - dx * dist
            m_camera_fix.y = lookat_py - dy * dist
            m_camera_fix.z = lookat_pz - dz * dist
        end
        m_camera_fix.dx = dx
        m_camera_fix.dy = dy
        m_camera_fix.dz = dz
        c_camera_setstatic(m_camera_fix.x, m_camera_fix.y, m_camera_fix.z, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
        local distfix = vector3_distance(m_camera_lookat.x, m_camera_lookat.y, m_camera_lookat.z, m_camera_fix.x, m_camera_fix.y, m_camera_fix.z)
        if distfix < dist then
            m_camera_lookat.distfix = distfix
        end
    end
end

function maincamera_setstate(state)
    m_camera_state = state
    maincamera_apply()
end

function maincamera_movetoposition(px, py, pz, pitch, yaw, roll, fov, time)
    if time > 0.0 then
        m_camera_move = {}
        m_camera_move.time_start = time_game
        m_camera_move.time_length = time
        m_camera_move.px_start = m_camera_fix.x
        m_camera_move.py_start = m_camera_fix.y
        m_camera_move.pz_start = m_camera_fix.z
        m_camera_move.pitch_start = m_camera_fix.pitch
        m_camera_move.yaw_start = m_camera_fix.yaw
        m_camera_move.roll_start = m_camera_fix.roll
        m_camera_move.fov_start = m_camera_fix.fov
        m_camera_move.px_target = px
        m_camera_move.py_target = py
        m_camera_move.pz_target = pz
        m_camera_move.pitch_target = pitch
        m_camera_move.yaw_target = yaw
        m_camera_move.roll_target = roll
        m_camera_move.fov_target = fov
        maincamera_setstate(camerastate.move)
    else
        m_camera_move = nil
        m_camera_fix.x = px
        m_camera_fix.y = py
        m_camera_fix.z = pz
        m_camera_fix.pitch = pitch
        m_camera_fix.yaw = yaw
        m_camera_fix.roll = roll
        m_camera_fix.fov = fov
        c_camera_setstatic(m_camera_fix.x, m_camera_fix.y, m_camera_fix.z, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
        maincamera_setstate(camerastate.static)
    end
end

function maincamera_moveto(name, time, forcefov)
    local px, py, pz, pitch, yaw, roll, fov = c_camera_getcamera(name)
    if forcefov ~= nil then
        fov = forcefov
    end
    maincamera_movetoposition(px, py, pz, pitch, yaw, roll, fov, time)
end

function maincamera_setstatic(px, py, pz, pitch, yaw, roll, fov)
    m_camera_fix.x = px
    m_camera_fix.y = py
    m_camera_fix.z = pz
    m_camera_fix.pitch = pitch
    m_camera_fix.yaw = yaw
    m_camera_fix.roll = roll
    m_camera_fix.fov = fov
    c_camera_setstatic(m_camera_fix.x, m_camera_fix.y, m_camera_fix.z, m_camera_fix.pitch, m_camera_fix.yaw, m_camera_fix.roll, m_camera_fix.fov)
    maincamera_setstate(camerastate.static)
end

function maincamera_setfree(xmin, ymin, zmin, xmax, ymax, zmax, px, py, pz, pitch, yaw, roll, pitchmin, pitchmax)
    if m_camera_free == nil then
        m_camera_free = {}
        m_camera_free.wheel = {}
    end
    m_camera_free.xmin = xmin
    m_camera_free.ymin = ymin
    m_camera_free.zmin = zmin
    m_camera_free.xmax = xmax
    m_camera_free.ymax = ymax
    m_camera_free.zmax = zmax
    m_camera_free.pitchmin = pitchmin
    m_camera_free.pitchmax = pitchmax
    wheel_reset(m_camera_free.wheel, wheeltime, true)

    m_camera_fix.x = px
    m_camera_fix.y = py
    m_camera_fix.z = pz
    m_camera_fix.pitch = pitch
    m_camera_fix.yaw = yaw
    m_camera_fix.roll = roll
    maincamera_setstate(camerastate.free)
end

function maincamera_setfpp(x, y, z, pitch, yaw, roll, pitchmin, pitchmax)
    if m_camera_fpp == nil then
        m_camera_fpp = {}
    end
    m_camera_fpp.pitchmin = pitchmin
    m_camera_fpp.pitchmax = pitchmax

    m_camera_fix.x = x
    m_camera_fix.y = y
    m_camera_fix.z = z
    m_camera_fix.pitch = pitch
    m_camera_fix.yaw = yaw
    m_camera_fix.roll = roll
    maincamera_setstate(camerastate.fpp)
end

function maincamera_setlookat(x, y, z, dist, distmin, distmax, pitch, yaw, roll, pitchmin, pitchmax, wheeltime)
    if m_camera_lookat == nil then
        m_camera_lookat = {}
        m_camera_lookat.wheel = {}
    end
    m_camera_lookat.pitchmin = pitchmin
    m_camera_lookat.pitchmax = pitchmax
    wheel_reset(m_camera_lookat.wheel, wheeltime, true)

    m_camera_lookat.x = x
    m_camera_lookat.y = y
    m_camera_lookat.z = z
    m_camera_lookat.cushionspeed = 10
    m_camera_lookat.cushionmax = 1.0
    m_camera_lookat.distmin = distmin
    m_camera_lookat.distmax = distmax
    m_camera_lookat.dist = dist
    m_camera_lookat.distfix = dist
    m_camera_lookat.distspeed = distmax

    m_camera_fix.pitch = pitch
    m_camera_fix.yaw = yaw
    m_camera_fix.roll = roll
    maincamera_setstate(camerastate.lookat)
end
