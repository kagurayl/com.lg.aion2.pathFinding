
function npc_staticclickable(entityid)
    local config_npcstatic = csvnpcstatic_getfromid(scene_getmapid(), entityid)
    if config_npcstatic == nil then
        local entityconfig = sceneentity_getconfig(entityid)
        if entityconfig ~= nil and entityconfig.type == sceneentitytype.door then
            return true
        end
        return false
    end
    local type = config_npcstatic.type
    if type == "chair"
    or type == "alchemy"
    or type == "armor_craft"
    or type == "weapon_craft"
    or type == "tailoring"
    or type == "handiwork"
    or type == "cooking" then
        return true
    end
    return false
end

function npc_staticscript(entityid)
    local config_npcstatic = csvnpcstatic_getfromid(scene_getmapid(), entityid)
    if config_npcstatic == nil then
        local entityconfig = sceneentity_getconfig(entityid)
        if entityconfig ~= nil and entityconfig.type == sceneentitytype.door then
            local msg = {messageid="CS_SetDoor"}
            msg.entityid = entityid
            c_send(msg)
        end
        return
    end
    local talkdist = 4.0
    local pos = string.splitnumber(config_npcstatic.position, ",")
    local dist = vector3_distance(pos[1], pos[2], pos[3], m_me.transform.px, m_me.transform.py, m_me.transform.pz)
	if dist < talkdist then
        npc_staticscript_movecomplete(config_npcstatic)
    else
        playerapproach_entity(config_npcstatic, pos, 4.0)
	end
end

function npc_staticscript_movecomplete(config_npcstatic)
    local type = config_npcstatic.type
    if type == "chair" then
        local msg = {messageid="CS_ChairSitDown"}
        msg.staticid = config_npcstatic.staticid
        c_send(msg)
    elseif type == "alchemy" then
        crafting_open(config_npcstatic, skill_gather_alchemy)
    elseif type == "armor_craft" then
        crafting_open(config_npcstatic, skill_gather_armor)
    elseif type == "weapon_craft" then
        crafting_open(config_npcstatic, skill_gather_weapon)
    elseif type == "tailoring" then
        crafting_open(config_npcstatic, skill_gather_tailor)
    elseif type == "handiwork" then
        crafting_open(config_npcstatic, skill_gather_handiwork)
    elseif type == "cooking" then
        crafting_open(config_npcstatic, skill_gather_cooking)
    end
end
