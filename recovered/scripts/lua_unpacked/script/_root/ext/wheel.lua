
function wheel_reset(state, time, accel)
    state.wheelspeed = time
    state.wheelval = 0.0
    state.wheelaccel = accel
    state.wheeling = false
end

function wheel_stop(state)
    state.wheeling = false
end

function wheel_set(state, start, target, time, accel)
    state.wheeling = true
    state.wheelval = start
    state.wheelspeed = time
    math.setsmooth(state, state.wheelval, time_game, target, state.wheelspeed, accel)
end

function wheel_add(state, val)
    if state.wheeling then
        val = state.targetval + val
    else
        val = state.wheelval + val
        state.wheeling = true
    end
    math.setsmooth(state, state.wheelval, time_game, val, state.wheelspeed)
end

function wheel_getsmooth(state)
    local complete, wheelval = math.getsmooth(state, time_game)
    if complete then
        state.wheeling = false
    end
    state.wheelval = wheelval
    return wheelval
end

function wheel_getsmoothdelta(state)
    local complete, wheelval = math.getsmooth(state, time_game)
    if complete then
        state.wheeling = false
    end
    local delta = wheelval - state.wheelval
    state.wheelval = wheelval
    return delta
end

function wheel_getwheeling(state)
    return state.wheeling
end

function wheel_getwheeltarget(state)
    return state.targetval
end
