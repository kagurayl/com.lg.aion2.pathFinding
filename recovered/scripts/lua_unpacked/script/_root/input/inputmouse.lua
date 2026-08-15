
mouseclickstate =
{
	none = 0,
    clickscene = 1,
    clickactor = 2,
    rotatecamera = 3,
    rotateplayer = 4,
    moveplayer = 5,
}
mousewheelscale = (1.0 / 120.0)

local m_inputmouse_state = {mouseavailable = false, mousex = 0.0, mousey = 0.0, movex = 0.0, movey = 0.0, movesinceclick = 0.0}
local m_inputmouse_variable = {clickoffset = 5, pitchspeed = 0.2, yawspeed = 0.2}
local m_inputmouse_forcusobject = nil
local m_inputmouse_clickstate = mouseclickstate.none
local m_inputmouse_hoverpanel = nil

local function inputmouse_onclickscene()
    if m_inputmouse_forcusobject ~= nil then
        inputmouse_onclickactor()
        return
    end
    inputmove_setpath(nil)
    if m_me ~= nil and gamesetting_getnumber("MOUSELEFTMOVE") ~= 0 then
        local x,y,z = c_scene_pickscene()
        if x ~= nil then
            local path = c_scene_path(m_me.transform.px,m_me.transform.py,m_me.transform.pz,x,y,z)
            if #path > 0 then
                inputmove_setpath(path)
            end
        end
	end
end

local function inputmouse_clickactor(actor)
    if actor ~= nil then
        if actor:isnpc() then
            npc_startscript(actor.actorid)
        elseif actor:isplayer() then
            playerbattleauto_startnormalattack(actor.actorid)
        end
    end
end

local function inputmouse_onclickactor()
    if m_inputmouse_forcusobject ~= nil then
        if m_inputmouse_forcusobject.scriptid ~= 0 then
            if actormanager_ispet(m_inputmouse_forcusobject.scriptid) then
                if m_me ~= nil then
                    m_me:onclickpet()
                end
            else
                local actorid = actormanager_getactoridfromscriptid(m_inputmouse_forcusobject.scriptid)
                local prevactorid = m_selectactorid
                local actor = actormanager_getfromactorid(actorid)
                actormanager_selectactor(actor)
                if prevactorid ~= nil and m_selectactorid ~= nil and m_selectactorid == prevactorid then
                    inputmouse_clickactor(actor)
                end
            end
        elseif m_inputmouse_forcusobject.entityid ~= 0 then
            local actorid = actormanager_getentityactorid(m_inputmouse_forcusobject.entityid)
            if actorid ~= nil then
                local prevactorid = m_selectactorid
                local actor = actormanager_getfromactorid(actorid)
                actormanager_selectactor(actor)
                if prevactorid ~= nil and m_selectactorid ~= nil and m_selectactorid == prevactorid then
                    inputmouse_clickactor(actor)
                end
            else
                npc_staticscript(m_inputmouse_forcusobject.entityid)
            end
        end
    end
end

local function inputmouse_setfocusactor(focusactor)
    if m_inputmouse_forcusobject ~= nil then
        if m_inputmouse_forcusobject.scriptid ~= 0 then
            if focusactor ~= nil then
                if m_inputmouse_forcusobject.scriptid ~= focusactor.scriptid then
                    c_actor_sethighlight(m_inputmouse_forcusobject.scriptid, false)
                    if focusactor.scriptid ~= 0 then
                        c_actor_sethighlight(focusactor.scriptid, true)
                    end
                end
            else
                c_actor_sethighlight(m_inputmouse_forcusobject.scriptid, false)
            end
        end
    else
        if focusactor ~= nil then
            if focusactor.scriptid ~= 0 then
                c_actor_sethighlight(focusactor.scriptid, true)
            end
        end
    end
    m_inputmouse_forcusobject = focusactor
end

local function inputmouse_updatestate()
    local leftbuttondown = input_getkeydown(KeyName_LeftMouseButton)
    local rightbuttondown = input_getkeydown(KeyName_RightMouseButton)
    if m_inputmouse_clickstate == mouseclickstate.none then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif leftbuttondown then
            if m_inputmouse_forcusobject ~= nil and (m_inputmouse_forcusobject.scriptid ~= 0 or m_inputmouse_forcusobject.entityid ~= 0) then
                m_inputmouse_clickstate = mouseclickstate.clickactor
            else
                m_inputmouse_clickstate = mouseclickstate.clickscene
            end
            m_inputmouse_state.movesinceclick = 0.0
        elseif rightbuttondown then
            if gamesetting_getnumber("MOUSERIGHTATTACK") > 0 then
                m_inputmouse_clickstate = mouseclickstate.clickactor
            else
                m_inputmouse_clickstate = mouseclickstate.rotateplayer
            end
            m_inputmouse_state.movesinceclick = 0.0
        end
    elseif m_inputmouse_clickstate == mouseclickstate.clickscene then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif leftbuttondown then
            m_inputmouse_clickstate = mouseclickstate.clickscene
        elseif rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotateplayer
        else
            m_inputmouse_clickstate = mouseclickstate.none
            inputmouse_onclickscene()
        end
    elseif m_inputmouse_clickstate == mouseclickstate.clickactor then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif not leftbuttondown and not rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.none
            inputmouse_onclickactor()
        end
    elseif m_inputmouse_clickstate == mouseclickstate.rotatecamera then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif leftbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotatecamera
        elseif rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotateplayer
        else
            m_inputmouse_clickstate = mouseclickstate.none
        end
    elseif m_inputmouse_clickstate == mouseclickstate.rotateplayer then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif leftbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotatecamera
        elseif rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotateplayer
        else
            m_inputmouse_clickstate = mouseclickstate.none
        end
    elseif m_inputmouse_clickstate == mouseclickstate.moveplayer then
        if leftbuttondown and rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.moveplayer
        elseif leftbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotatecamera
        elseif rightbuttondown then
            m_inputmouse_clickstate = mouseclickstate.rotateplayer
        else
            m_inputmouse_clickstate = mouseclickstate.none
        end
    end

    if m_inputmouse_forcusobject ~= nil then
        if m_inputmouse_forcusobject.scriptid ~= 0 or m_inputmouse_forcusobject.entityid ~= 0 then
            if m_inputmouse_clickstate == mouseclickstate.rotatecamera
            or m_inputmouse_clickstate == mouseclickstate.rotateplayer
            or m_inputmouse_clickstate == mouseclickstate.moveplayer then
                inputmouse_setfocusactor(nil)
            end
        end
    end
end

function inputmouse_getcursorvisible()
    return m_inputmouse_clickstate == mouseclickstate.none or m_inputmouse_clickstate == mouseclickstate.clickscene or m_inputmouse_clickstate == mouseclickstate.clickactor
end

function inputmouse_update()
    inputmouse_updatestate()
    if m_inputmouse_state.mouseavailable and inputmouse_getcursorvisible() then
        m_inputmouse_hoverpanel = c_uigethover(m_inputmouse_state.mousex, m_inputmouse_state.mousey)
    else
        m_inputmouse_hoverpanel = nil
    end
    if m_inputmouse_clickstate == mouseclickstate.none then
        local focusactor = nil
        if m_inputmouse_hoverpanel == nil and scene_getmapid() ~= 0 and m_me ~= nil then
            focusactor = actormanager_getfocusactor(m_inputmouse_state.mousex, m_inputmouse_state.mousey)
        end
        inputmouse_setfocusactor(focusactor)
    elseif m_inputmouse_clickstate == mouseclickstate.clickscene or m_inputmouse_clickstate == mouseclickstate.clickactor then
        if m_inputmouse_state.movesinceclick >= m_inputmouse_variable.clickoffset then
            if m_inputmouse_clickstate == mouseclickstate.clickscene then
                m_inputmouse_clickstate = mouseclickstate.rotatecamera
            elseif m_inputmouse_clickstate == mouseclickstate.clickactor then
                m_inputmouse_clickstate = mouseclickstate.rotateplayer
            end
            inputmouse_setfocusactor(nil)
        end
    elseif m_inputmouse_clickstate == mouseclickstate.rotatecamera then
        if m_inputmouse_state.mouseavailable and not inputmouse_getcursorvisible() then
            local speedscale = gamesetting_getnumberdata("CAMERASPEED")
            local pitchflip = gamesetting_getnumber("CAMERAFLIPV")
            local yaw = m_inputmouse_state.movex * m_inputmouse_variable.yawspeed * speedscale
            local pitch = m_inputmouse_state.movey * m_inputmouse_variable.pitchspeed * speedscale
            if pitchflip > 0 then
                pitch = - pitch
            end
            maincamera_rotate(pitch, yaw,  0.0)
        end
    end
end

function inputmouse_getclickstate()
    return m_inputmouse_clickstate
end

function inputmouse_gethoverpanel()
    return m_inputmouse_hoverpanel
end

function inputmouse_getposition()
    return m_inputmouse_state.mouseavailable, m_inputmouse_state.mousex, m_inputmouse_state.mousey
end

function inputmouse_getmoved()
    return m_inputmouse_state.moved
end

function inputmouse_getmove()
    return m_inputmouse_state.movex, m_inputmouse_state.movey
end

function inputmouse_reset()
    m_inputmouse_state.movex = 0.0
    m_inputmouse_state.movey = 0.0
    m_inputmouse_state.moved = false
end

function inputdevice_mouseposition(x, y)
    m_inputmouse_state.moved = true
    m_inputmouse_state.mouseavailable = true
    m_inputmouse_state.mousex = x
    m_inputmouse_state.mousey = y
end

function inputdevice_mousemove(x, y)
    if game_focus then
        m_inputmouse_state.movex = m_inputmouse_state.movex + x
        m_inputmouse_state.movey = m_inputmouse_state.movey - y
        m_inputmouse_state.movesinceclick = m_inputmouse_state.movesinceclick + vector2_length(x, y)
    end
end

function inputdevice_mousescroll(x, y)
    maincamera_wheel(-y * mousewheelscale)
end
