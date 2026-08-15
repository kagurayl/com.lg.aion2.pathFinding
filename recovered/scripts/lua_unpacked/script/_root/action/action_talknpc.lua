
local actiontalkstate =
{
    none = 0,
    chairsitdown = 1,
    chairsitloop = 2,
    chairstandup = 3,
    pickitem = 4,
    teleportout = 5,
    teleportin = 6,
}

local function action_talknpc_sitdown(actor)
    local foot_x,foot_y,foot_z = c_entity_gettransform(actor.actionmain.talknpc, "foot_point")
    if foot_x ~= nil then
        local sit_x,sit_y,sit_z = c_entity_gettransform(actor.actionmain.talknpc, "sit_point")
        if sit_x ~= nil then
            local dx, dy = vector2_normalize(sit_x - foot_x, sit_z - foot_z)
            playerattr_info.rot = vector2_angle3d(-dx, -dy)
            local rot = vector2_angle3d(dx, dy)
            actor:setpositionrotation(foot_x, foot_y, foot_z, 0.0, rot, 0.0)
        end
    end
    local alias = actor:playanimlist(animlist.sitchair)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0.0
    end
    actor.actionmain.actionloadanim = actor:getanimlistname(animlist.standchair)
    actor:loadanim(actor.actionmain.actionloadanim)
end

local function action_talknpc_standup(actor)
    actor.actionmain.rot = 180.0
    actor:setrotation(actor.transform.rx, actor.attr.rot + 180.0, actor.transform.rz)
    local alias = actor:playanimlist(animlist.standchair, 0, 1.0, 0.0)
    if alias ~= nil then
        actor.actionmain.actioncomplete = time_game + alias.length
    else
        actor.actionmain.actioncomplete = 0.0
        actor.actionmain.talknpctype = nil
    end
end

function action_talknpc_enter(actor)
    actor.actionmain.actionstate = actiontalkstate.none
end

function action_talknpc_update(actor)
    if actor.actionmain.talknpctype == npcmotiontype.chairsitdown then
        if actor.actionmain.actionstate ~= actiontalkstate.chairsitdown and actor.actionmain.actionstate ~= actiontalkstate.chairsitloop then
            action_talknpc_sitdown(actor)
            actor.actionmain.actionstate = actiontalkstate.chairsitdown
        elseif actor.actionmain.actionstate == actiontalkstate.chairsitdown then
            if actor.actionmain.actioncomplete > 0.0 and actor.actionmain.actioncomplete <= time_game then
                actor.actionmain.actionstate = actiontalkstate.chairsitloop
                actor:playanimlist(animlist.idlechair)
            end
        end
    elseif actor.actionmain.talknpctype == npcmotiontype.chairstandup then
        if actor.actionmain.actionstate ~= actiontalkstate.chairstandup then
            action_talknpc_standup(actor)
            actor.actionmain.actionstate = actiontalkstate.chairstandup
        else
            if actor.actionmain.actioncomplete > 0.0 and actor.actionmain.actioncomplete <= time_game then
                actor.actionmain.talknpctype = nil
            end
        end
    elseif actor.actionmain.talknpctype == npcmotiontype.pickitem then
        if actor.actionmain.actionstate ~= actiontalkstate.pickitem then
            actor:playanimlist(animlist.loot)
            actor.actionmain.actionstate = actiontalkstate.pickitem
        end
    elseif actor.actionmain.talknpctype == npcmotiontype.teleportout then
        if actor.actionmain.actionstate ~= actiontalkstate.teleportout then
            local alias = actor:playanimlist(animlist.teleportout)
            actor.actionmain.actionstate = actiontalkstate.teleportout
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length * 2
            else
                actor.actionmain.actioncomplete = 0.0
            end
        else
            if actor.actionmain.actioncomplete <= time_game then
                actor.actionmain.talknpctype = nil
            end
        end
    elseif actor.actionmain.talknpctype == npcmotiontype.teleportin then
        if actor.actionmain.actionstate ~= actiontalkstate.teleportin then
            local alias = actor:playanimlist(animlist.teleportin)
            actor.actionmain.actionstate = actiontalkstate.teleportin
            if alias ~= nil then
                actor.actionmain.actioncomplete = time_game + alias.length
            else
                actor.actionmain.actioncomplete = 0.0
            end
        else
            if actor.actionmain.actioncomplete <= time_game then
                actor.actionmain.talknpctype = nil
            end
        end
    end
end

function action_talknpc_move(actor)
    if actor.actionmain.actionstate == actiontalkstate.chairsitloop then
        actor.actionmain.talknpctype = npcmotiontype.chairstandup
        actor.actionmain.actionstate = actiontalkstate.none
        return true
    end
    if actor.actionmain.actionstate == actiontalkstate.pickitem then
        actor.actionmain.talknpctype = nil
        return true
    end
    if actor.actionmain.actionstate == actiontalkstate.chairstandup then
        return true
    end
    return false
end

function action_talknpc_leave(actor)
    actor.actionmain.rot = 0.0
    actor:setrotation(actor.transform.rx, actor.attr.rot, actor.transform.rz)
    if actor.actionmain.actionloadanim ~= nil then
        actor:unloadanim(actor.actionmain.actionloadanim)
        actor.actionmain.actionloadanim = nil
    end
    pickitem_close()
end
