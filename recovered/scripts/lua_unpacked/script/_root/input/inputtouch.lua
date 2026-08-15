
TouchUseage =
{
    scene = 0,
    camerarotate = 1,
    camerascale = 2,
}

local m_inputtouch_state = {}
local m_inputtouch_scale = {}
local m_inputtouch_variable = {moveoffset = 5, pitchspeed = 0.05, yawspeed = 0.1, scalespeed = 0.05}

local function inputtouch_onbegin(state)
    state.useage = TouchUseage.scene
end

local function inputtouch_onmove(state)
    if state.useage == TouchUseage.scene then
        local ox = state.location_x - state.begin_x
        local oy = state.location_y - state.begin_y
        if math.abs(ox) > m_inputtouch_variable.moveoffset or math.abs(oy) > m_inputtouch_variable.moveoffset then
            for key, val in pairs(m_inputtouch_state) do
                if val.finger ~= state.finger and (val.useage == TouchUseage.scene or val.useage == TouchUseage.camerarotate) then
                    val.useage = TouchUseage.camerascale
                    state.useage = TouchUseage.camerascale
                    local scale = {}
                    scale.state1 = val
                    scale.state2 = state
                    scale.dist = vector2_distance(state.location_x, state.location_y, val.location_x, val.location_y)
                    m_inputtouch_scale[#m_inputtouch_scale + 1] = scale
                    break
                end
            end
            if state.useage == TouchUseage.scene then
                state.useage = TouchUseage.camerarotate
            end
        end
    elseif state.useage == TouchUseage.camerarotate then
        local speedscale = gamesetting_getnumberdata("CAMERASPEED")
        local pitchflip = gamesetting_getnumber("CAMERAFLIPV")
        local yaw = (state.location_x - state.prev_x) * m_inputtouch_variable.yawspeed * speedscale
        local pitch = (state.prev_y - state.location_y) * m_inputtouch_variable.pitchspeed * speedscale
        if pitchflip > 0 then
            pitch = - pitch
        end
        maincamera_rotate(pitch, yaw,  0.0)
    end
end

local function inputtouch_onclickactor(actorid)
    local prevactorid = m_selectactorid
    local actor = actormanager_getfromactorid(actorid)
    actormanager_selectactor(actor)
    if prevactorid ~= nil and m_selectactorid ~= nil and m_selectactorid == prevactorid then
        if actor ~= nil then
            if actor:isnpc() then
                npc_startscript(actor.actorid)
            elseif actor:isplayer() then
                playerbattleauto_startnormalattack(actor.actorid)
            end
        end
    end
end

local function inputtouch_onend(state)
    if state.useage == TouchUseage.scene then
        local focusactor = nil
        if scene_getmapid() ~= 0 and m_me ~= nil then
            focusactor = actormanager_getfocusactor(state.location_x, state.location_y)
        end
        if focusactor ~= nil then
            if focusactor.scriptid ~= 0 then
                if actormanager_ispet(focusactor.scriptid) then
                    if m_me ~= nil then
                        m_me:onclickpet()
                    end
                else
                    local actorid = actormanager_getactoridfromscriptid(focusactor.scriptid)
                    inputtouch_onclickactor(actorid)
                end
            elseif focusactor.entityid ~= 0 then
                local actorid = actormanager_getentityactorid(focusactor.entityid)
                if actorid ~= nil then
                    inputtouch_onclickactor(actorid)
                else
                    npc_staticscript(focusactor.entityid)
                end
            end
        end
    end
end

function inputtouch_getusage(usage)
    for key, val in pairs(m_inputtouch_state) do
        if val.useage == usage then
            return val
        end
    end
    return nil
end

function inputtouch_update()
    for i=1,#m_inputtouch_scale do
        local scalestate = m_inputtouch_scale[i]
        local dist = vector2_distance(scalestate.state1.location_x, scalestate.state1.location_y, scalestate.state2.location_x, scalestate.state2.location_y)
        local scale = (scalestate.dist - dist) * m_inputtouch_variable.scalespeed
        scalestate.dist = dist
        if scale ~= 0.0 then
            maincamera_wheel(scale)
        end
    end
end

function inputdevice_touchdown(finger, x, y)
    local touchstate = m_inputtouch_state[finger]
    if touchstate == nil then
        touchstate = {}
        touchstate.finger = finger
        m_inputtouch_state[finger] = touchstate
    end
    touchstate.begin_x = x
    touchstate.begin_y = y
    touchstate.prev_x = x
    touchstate.prev_y = y
    touchstate.location_x = x
    touchstate.location_y = y
    inputtouch_onbegin(touchstate)
end

function inputdevice_touchup(finger)
    for i=1,#m_inputtouch_scale do
        local scale = m_inputtouch_scale[i]
        if scale.state1.finger == finger or scale.state2.finger == finger then
            table.remove(m_inputtouch_scale, i)
            m_inputtouch_state[scale.state1.finger] = nil
            m_inputtouch_state[scale.state2.finger] = nil
            return
        end
    end
    local touchstate = m_inputtouch_state[finger]
    if touchstate ~= nil then
        inputtouch_onend(touchstate)
        m_inputtouch_state[finger] = nil
    end
end

function inputdevice_touchposition(finger, x, y)
    local touchstate = m_inputtouch_state[finger]
    if touchstate == nil then
        return
    end
    touchstate.location_x = x
    touchstate.location_y = y
    inputtouch_onmove(touchstate)
    touchstate.prev_x = x
    touchstate.prev_y = y
end
