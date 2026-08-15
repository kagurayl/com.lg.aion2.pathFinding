
local actionwindpathstate = 
{
    enter = 1,
    normal = 2,
}

local function action_windpath_updateanim(actor)
    if actor.actordata.windpathdash then
        actor:playanimlist(animlist.windpath)
    else
        actor:playanimlist(animlist.windpathdash)
    end
end

local function action_windpath_getrot(actor, pointindex)
    local pos1, pos2
    if pointindex > 1 then
        pos1 = actor.actordata.windpathconfig.position[pointindex - 1]
        pos2 = actor.actordata.windpathconfig.position[pointindex]
    else
        pos1 = actor.actordata.windpathconfig.position[pointindex]
        pos2 = actor.actordata.windpathconfig.position[pointindex + 1]
    end
    local dx,dy,dz = vector3_normalize(pos2[1] - pos1[1], pos2[2] - pos1[2], pos2[3] - pos1[3])
    local rx,ry,rz = vector3_fromtovector(0, 0, -1, dx, dy, dz)
    return rx,ry,rz
end

local function action_windpath_updatepath(actor, movelength)
    while movelength > 0 and actor.attr.movewindpoint < #actor.actordata.windpathconfig.position do
        local pos1 = actor.actordata.windpathconfig.position[actor.attr.movewindpoint]
        local pos2 = actor.actordata.windpathconfig.position[actor.attr.movewindpoint + 1]
        local rx1,ry1,rz1 = action_windpath_getrot(actor, actor.attr.movewindpoint)
        local rx2,ry2,rz2 = action_windpath_getrot(actor, actor.attr.movewindpoint + 1)
        local dist = vector3_distance(actor.attr.posx, actor.attr.posy, actor.attr.posz, pos2[1], pos2[2], pos2[3])
        if movelength < dist then
            local t = movelength / dist
            local px = math.lerp(actor.attr.posx, pos2[1], t)
            local py = math.lerp(actor.attr.posy, pos2[2], t)
            local pz = math.lerp(actor.attr.posz, pos2[3], t)
            t = 1.0 - dist / vector3_distance(pos1[1], pos1[2], pos1[3], pos2[1], pos2[2], pos2[3])
            local rx = math.lerpdegree(rx1, rx2, t)
            local ry = math.lerpdegree(ry1, ry2, t)
            actor:setpositionrotation(px, py, pz, rx, ry, 0.0)
            actor.attr.posx = px
            actor.attr.posy = py
            actor.attr.posz = pz
            actor.attr.rot = ry	
            movelength = 0
        else
            movelength = movelength - dist
            actor.attr.movewindpoint = actor.attr.movewindpoint + 1
            actor:setpositionrotation(pos2[1], pos2[2], pos2[3], rx2, ry2, 0.0)
            actor.attr.posx = pos2[1]
            actor.attr.posy = pos2[2]
            actor.attr.posz = pos2[3]
            actor.attr.rot = ry2
        end
    end
end

function action_windpath_enter(actor)
    actor.actordata.windpathconfig = csvmapwindpath_getfromid(actor.attr.movewindpathid)
    actor.actordata.windpathdash = false
    actor.actordata.windpathtime = time_game
    actor.actordata.windpathstate = actionwindpathstate.enter
    action_windpath_updateanim(actor)
end

function action_windpath_leave(actor)
    actor:setpositionrotation(actor.attr.posx, actor.attr.posy, actor.attr.posz, 0.0, actor.attr.rot, 0.0)
end

function action_windpath_update(actor)
    local dash = actor.attr.movewinddashtime > time_game
    if actor.actordata.windpathdash ~= dash then
        actor.actordata.windpathdash = dash
        action_windpath_updateanim(actor)
    end
    local movelength = 0.0
    if actor.actordata.windpathdash then
        movelength = actor.attr.movewinddashspeed * time_frame
    else
        movelength = actor.attr.movewindspeed * time_frame
    end
    
    if actor.actordata.windpathstate == actionwindpathstate.enter then
        local pos = actor.actordata.windpathconfig.position[actor.attr.movewindpoint]
        local dist = vector3_distance(pos[1], pos[2], pos[3], actor.attr.posx, actor.attr.posy, actor.attr.posz)
        if dist > 0.0 then
            local t = movelength / dist
            if t >= 1.0 then
                t = 1.0
                actor.actordata.windpathstate = actionwindpathstate.normal
            end
            local px = math.lerp(actor.attr.posx, pos[1], t)
            local py = math.lerp(actor.attr.posy, pos[2], t)
            local pz = math.lerp(actor.attr.posz, pos[3], t)
            actor:setposition(px, py, pz)
            actor.attr.posx = px
            actor.attr.posy = py
            actor.attr.posz = pz
        else
            actor.actordata.windpathstate = actionwindpathstate.normal
        end
    end
    if actor.actordata.windpathstate == actionwindpathstate.normal then
        action_windpath_updatepath(actor, movelength)
    end
    local leavewindpath = false
    if actor:isme() and actor:ismoving() and time_game - actor.attr.movewindentertime > 4 then
        if actor.actionmain.windpathleavesynctime == nil or time_game - actor.actionmain.windpathleavesynctime > 1 then
            leavewindpath = true
        end
    end
    if actor.attr.movewindpoint >= #actor.actordata.windpathconfig.position then
        leavewindpath = true
    end
    if leavewindpath then
        actor.actionmain.windpathleavesynctime = time_game
        if actor:isme() then
            local msg = {messageid="CS_LeaveWindPath"}
            msg.posx = playerattr_info.posx
            msg.posy = playerattr_info.posy
            msg.posz = playerattr_info.posz
            c_send(msg)
        end
    end
end
