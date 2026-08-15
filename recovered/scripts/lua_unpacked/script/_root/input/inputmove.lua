
movedirection =
{
	forward = 1,
 	backward = 2,
    left = 3,
    right = 4,
    up = 5,
    down = 6,
}

local m_inputmove_moveforward = false
local m_inputmove_movebackward = false
local m_inputmove_moveleft = false
local m_inputmove_moveright = false
local m_inputmove_flyup = false
local m_inputmove_flydown = false
local m_inputmove_path = nil
local m_hermes_direct_target = nil
local m_hermes_packetwalk_target = nil
local m_hermes_packetwalk_lastsend = 0

function inputmove_sethermesdirect(x, y, z)
    m_hermes_packetwalk_target = nil
    m_hermes_direct_target = {x = x, y = y, z = z}
end

function inputmove_sethermespacketwalk(x, y, z)
    inputmove_setpath(nil)
    m_hermes_direct_target = nil
    m_hermes_packetwalk_target = {x = x, y = y, z = z}
    m_hermes_packetwalk_lastsend = time_game - 1
end

function inputmove_stophermespacketwalk()
    m_hermes_packetwalk_target = nil
    inputmove_reset()
    if m_me ~= nil then
        m_me:movesendsync(true)
    end
end

function inputmove_forward()
    m_inputmove_moveforward = true
end

function inputmove_forwardstop()
    m_inputmove_moveforward = false
end

function inputmove_backward()
    m_inputmove_movebackward = true
end

function inputmove_backwardstop()
    m_inputmove_movebackward = false
end

function inputmove_left()
    m_inputmove_moveleft = true
end

function inputmove_leftstop()
    m_inputmove_moveleft = false
end

function inputmove_right()
    m_inputmove_moveright = true
end

function inputmove_rightstop()
    m_inputmove_moveright = false
end

function inputmove_flyup()
    m_inputmove_flyup = true
end

function inputmove_flyupstop()
    m_inputmove_flyup = false
end

function inputmove_flydown()
    m_inputmove_flydown = true
end

function inputmove_flydownstop()
    m_inputmove_flydown = false
end

function inputmove_setpath(path)
    m_inputmove_path = path
end

function inputmove_stop()
    m_inputmove_moveforward = false
    m_inputmove_movebackward = false
    m_inputmove_moveleft = false
    m_inputmove_moveright = false
    inputmove_setpath(nil)
end

function inputmove_ismoving()
    if m_inputmove_moveforward
    or m_inputmove_movebackward
    or m_inputmove_moveleft
    or m_inputmove_moveright
    or inputmouse_getclickstate() == mouseclickstate.rotateplayer
    or inputmouse_getclickstate() == mouseclickstate.moveplayer then
        return true
    end
    if m_me:getfly() then
        if m_inputmove_flyup or m_inputmove_flydown then
            return true
        end
    end
    return false
end

local function inputmove_updateinputmove()
    local forward_x, forward_y, forward_z = maincamera_getdir()
    if m_me.transform.onfloor then
        forward_x, forward_z = vector2_normalize(forward_x, forward_z)
        forward_y = 0.0
    end

    local cross_x, cross_y, cross_z = vector3_cross(forward_x, forward_y, forward_z, 0.0, 1.0, 0.0)
    local move_x = 0.0
    local move_y = 0.0
    local move_z = 0.0
    local move_dir = movedirection.forward
    if m_inputmove_moveforward then
        move_x = move_x + forward_x
        move_y = move_y + forward_y
        move_z = move_z + forward_z
        move_dir = movedirection.forward
    end
    if m_inputmove_movebackward then
        move_x = move_x - forward_x
        move_y = move_y - forward_y
        move_z = move_z - forward_z
        move_dir = movedirection.backward
    end
    if m_inputmove_moveleft then
        move_x = move_x + cross_x
        move_y = move_y + cross_y
        move_z = move_z + cross_z
        move_dir = math.ternary(m_inputmove_movebackward, movedirection.backward, movedirection.left)
    end
    if m_inputmove_moveright then
        move_x = move_x - cross_x
        move_y = move_y - cross_y
        move_z = move_z - cross_z
        move_dir = math.ternary(m_inputmove_movebackward, movedirection.backward, movedirection.right)
    end
    if m_me:getfly() then
        if m_inputmove_flyup then
            move_y = move_y + 1.0
        end
        if m_inputmove_flydown then
            move_y = move_y - 1.0
        end
    end
    if move_x ~= 0.0 or move_z ~= 0.0 then
        m_me.move.inputrot = vector2_angle3d(vector2_normalize(move_x, move_z))
        if move_dir == movedirection.backward then
            m_me.move.inputrot = m_me.move.inputrot + 180
        end
    end
    local inputmove_x, inputmove_y, inputmove_z = vector3_normalize(move_x, move_y, move_z)
    m_me.move.inputmove_x = inputmove_x
    m_me.move.inputmove_y = inputmove_y
    m_me.move.inputmove_z = inputmove_z
    m_me.move.inputdirection = move_dir
end

local function inputmove_updatepath()
    if m_inputmove_path == nil or #m_inputmove_path == 0 then
        return
    end

    local pt = m_inputmove_path[1]
    local px = m_me.transform.px
    local py = m_me.transform.py
    local pz = m_me.transform.pz
    local d = vector2_distance(px, py, pt.x, pt.y)
    while d < 0.1 and math.abs(pz - pt.z) < 200 do
        table.remove(m_inputmove_path, 1)
        if #m_inputmove_path == 0 then
            return
        end
        pt = m_inputmove_path[1]
        d = vector2_distance(px, py, pt.x, pt.y)
    end
    local dx, dy, dz = vector3_normalize(pt.x - px, pt.y - py, pt.z - pz)
    local movestep = playerattr_info.movestatespeed * time_frame
    if d < movestep then
        movestep = d
        table.remove(m_inputmove_path, 1)
    end
    m_me.move.inputmove_x = dx * movestep
    m_me.move.inputmove_y = dy * movestep
    m_me.move.inputmove_z = dz * movestep
    m_me.move.inputrot = vector2_angle3d(vector2_normalize(dx, dy))
end

function inputmove_update()
    if m_me == nil then
        return
    end
    if m_hermes_packetwalk_target ~= nil then
        inputmove_reset()
        local arrived = m_me:movemeauto(
            m_hermes_packetwalk_target.x,
            m_hermes_packetwalk_target.y,
            m_hermes_packetwalk_target.z,
            0.1
        )
        if arrived then
            m_me:movesendsync(true)
            debugerror(string.format(
                "HERMES_PACKETWALK ARRIVED %.9f %.9f %.9f",
                m_me.transform.px,
                m_me.transform.py,
                m_me.transform.pz
            ))
            m_hermes_packetwalk_target = nil
        elseif time_game - m_hermes_packetwalk_lastsend >= 0.2 then
            local msg = {messageid = "CS_Move"}
            msg.posx = playerattr_info.posx
            msg.posy = playerattr_info.posy
            msg.posz = playerattr_info.posz
            msg.rot = playerattr_info.rot
            msg.time = time_game
            msg.flag = 0
            c_send(msg)
            m_hermes_packetwalk_lastsend = time_game

            debugerror(string.format(
                "HERMES_PACKETWALK SEND %.9f %.9f %.9f %.3f",
                playerattr_info.posx,
                playerattr_info.posy,
                playerattr_info.posz,
                playerattr_info.rot
            ))
        end

        m_me.move.inputsync_px = playerattr_info.posx
        m_me.move.inputsync_py = playerattr_info.posy
        m_me.move.inputsync_pz = playerattr_info.posz
        m_me.move.inputsync_rot = playerattr_info.rot
        m_me.move.inputsync_time = time_game
        m_me.move.inputsync_floor = m_me.transform.onfloor
        m_me.move.inputsync_movetype = m_me.attr.movetype
        m_me.move.inputsync_moving = false
        return
    end
    if m_hermes_direct_target ~= nil then
        inputmove_reset()
        if m_me:movemeauto(m_hermes_direct_target.x, m_hermes_direct_target.y, m_hermes_direct_target.z, 0.1) then
            debugerror(string.format("HERMES_DIRECT ARRIVED %.9f %.9f %.9f", m_me.transform.px, m_me.transform.py, m_me.transform.pz))
            m_hermes_direct_target = nil
        end
        return
    end
    inputmove_reset()
    if inputmove_ismoving() then
        inputmove_setpath(nil)
        inputmove_updateinputmove()
    else
        inputmove_updatepath()
    end
end

function inputmove_reset()
    m_me.move.inputmove_x = 0.0
    m_me.move.inputmove_y = 0.0
    m_me.move.inputmove_z = 0.0
    m_me.move.inputrot = 0.0
    m_me.move.inputmove_outerui = false
end
