
npchpquality =
{
    junk = 1,
    normal = 2,
    elite = 3,
    hero = 4,
    legendary = 5,
    mythic = 6,
}

npcclientstate =
{
    none = 0,
    attack = 1,
    cast = 2,
    despawn = 3,
    interact = 4,
}

npcsyncstate =
{
	idle = 0,
    movewalk = 1,
	moverun = 2,
	dead = 3,
	spell = 4,
    spawn = 5,
    artifact = 6,
    teleport = 7,
    deadanim = 8,
}

npcmotiontype =
{
    chairsitdown = 1,
    chairstandup = 2,
    pickitem = 3,
    teleportout = 4,
    teleportin = 5,
}

npctalktype =
{
    talkstart = 0,
    talkselect = 1,
    talkfinish = 2,
    talkclose = 3,
    talkmodule = 4,
    interactstart = 5,
    interacttalk = 6,
}

npcdropstate =
{
    none = 0,
    owner = 1,
    team = 2,
    share = 3,
}

csvnpcuitype =
{
    none = 0,
    attackable_obj = 1,
    book = 2,
    binding_stone = 3,
    craft = 4,
    craft_ui_always = 5,
    carrier_notitle_nohp = 6,
    groupgate = 7,
    general = 8,
    general_act = 9,
    general_no_ui_radar = 10,
    general_no_marker = 11,
    general_norotate = 12,
    general_norotate_notalk = 13,
    general_norotate_notitle = 14,
    general_path_expanded = 15,
    hidden_monster = 16,
    monster = 17,
    monster_namedisplay = 18,
    monster_notitle = 19,
    monster_raid = 20,
    monster_subordinate = 21,
    only_over_ui_title = 22,
    only_always_ui_title = 23,
    polymorph_ride = 24,
    summoned = 25,
    seiren = 26,
    trap = 27,
}

local m_csvnpc_labelimage = {}
local m_csvnpc_tribe = {}
local m_csvnpc_attackable = {}

function csvnpc_getlabelimage(config_npc)
    if config_npc ~= nil then
        return m_csvnpc_labelimage[config_npc.id]
    end
end

function csvnpc_gettribe(config_npc)
    return m_csvnpc_tribe[config_npc.id]
end

function csvnpc_getattackable(config_npc)
    return m_csvnpc_attackable[config_npc.id]
end

function csvnpc_getfromid(id)
    local config_npc = c_config_getmetaid(configid.npc, id)
    if config_npc == nil then
        return
    end
    if m_csvnpc_attackable[id] ~= nil then
        return config_npc
    end

    local npcscript = config_npc.script
    local attackable = true
    local labelimage = nil
    if npcscript ~= nil then
        local actioncount = npcscript.actioncount
        for i=1,actioncount do
		    local sublambda = npcscript[i]
            if c_isaction(sublambda, "shop") then
                labelimage = csvlabelimage.npc_shop
            elseif c_isaction(sublambda, "mail") then
                labelimage = csvlabelimage.npc_mail
            elseif c_isaction(sublambda, "resurrect") then
                labelimage = csvlabelimage.npc_bind
            elseif c_isaction(sublambda, "vendor") then
                labelimage = csvlabelimage.npc_business
            elseif c_isaction(sublambda, "airport") then
                labelimage = csvlabelimage.npc_transfer
            elseif c_isaction(sublambda, "storage") or c_isaction(sublambda, "iccstorage") then
                labelimage = csvlabelimage.npc_storage
            elseif c_isaction(sublambda, "abyssartifact") then
                attackable = false
            end
        end
    end
    m_csvnpc_labelimage[config_npc.id] = labelimage
    m_csvnpc_tribe[config_npc.id] = csvnpctribe_gettribe(config_npc.tribe)
    m_csvnpc_attackable[config_npc.id] = attackable
    return config_npc
end

function csvnpc_getfromdict(key)
    local config_npcdict = c_config_getmetacol(configid.npc_dict, "key", key)
    if config_npcdict ~= nil then
        local subnpcid = string.splitnumber(config_npcdict.npcid, ",")
        return subnpcid
    end
end

function csvnpc_getboundbox(strboundbox, scale)
    if strboundbox ~= nil and strboundbox ~= "0" then
        local box = string.splitnumber(strboundbox, ",")
        local sx = box[4] - box[1]
        local sy = box[5] - box[2]
        local sz = box[6] - box[3]
        local cx = box[1] + sx / 2
        local cy = box[2] + sy / 2
        local cz = box[3] + sz / 2
        return cx * scale, cy * scale, cz * scale, sx * scale, sy * scale, sz * scale, cy + sy / 2
    else
        return 0,0,0,0,0,0,0
    end
end

function csvnpc_getscript(config_npc, type)
	local npcscript = config_npc.script
    if npcscript ~= nil then
        local actioncount = npcscript.actioncount
        for i=1,actioncount do
		    local sublambda = npcscript[i]
            if c_isaction(sublambda, type) then
                return sublambda
            end
        end
    end
    return nil
end

function csvnpc_gettalkrotate(config_npc)
    if config_npc.uitype == csvnpcuitype.general_norotate
    or config_npc.uitype == csvnpcuitype.general_norotate_notalk
    or config_npc.uitype == csvnpcuitype.general_norotate_notitle then
        return false
    end
    return true
end

function csvnpc_getnpcquestlist(config_npc, talkwithuncomplete)
    local npcquestlist = {}
    for questindex=1,#playerattr_quest do
        local attrquest = playerattr_quest[questindex]
        if playerquest_talkable(attrquest, config_npc, talkwithuncomplete) then
            local npcicon = csvquest_getimagefromtypestate(attrquest.config_quest.type, queststate.talkable)
            if npcicon ~= nil then
                npcquestlist[#npcquestlist + 1] = {config_quest = attrquest.config_quest, state = queststate.talkable, icon = npcicon}
            end
        end
    end

    local submitlist = csvquest_getnpcsubmitlist(config_npc.id)
    if submitlist ~= nil then
        for questindex=1,#playerattr_quest do
            local attrquest = playerattr_quest[questindex]
            if playerquest_submitable(attrquest, config_npc, submitlist) then
                local npcicon = csvquest_getimagefromtypestate(attrquest.config_quest.type, queststate.finish)
                if npcicon ~= nil then
                    npcquestlist[#npcquestlist + 1] = {config_quest = attrquest.config_quest, state = queststate.finish, icon = npcicon}
                end
            end
        end
    end

    local questlist = csvquest_getnpcquestlist(config_npc.id)
    if questlist ~= nil then
        for i=1,#questlist do
            local config_acceptquest = questlist[i]
            if playerquest_acceptable(config_acceptquest) then
                local npcicon = csvquest_getimagefromtypestate(config_acceptquest.type, queststate.acceptable)
                if npcicon ~= nil then
                    npcquestlist[#npcquestlist + 1] = {config_quest = config_acceptquest, state = queststate.acceptable, icon = npcicon}
                end
            end
        end
    end
    return npcquestlist
end

function csvnpc_getlinkname(npcid)
    return string.format("<n i=%d>", npcid)
end

function csvnpcfaction_getfromid(id)
    return c_config_getmetaid(configid.npc_faction, id)
end

function csvnpc_gethpquality(hpgauge)
    if hpgauge <= 1 then
        return npchpquality.junk
    elseif hpgauge <= 5 then
        return npchpquality.normal
    elseif hpgauge <= 9 then
        return npchpquality.elite
    elseif hpgauge <= 13 then
        return npchpquality.hero
    elseif hpgauge <= 15 then
        return npchpquality.legendary
    else
        return npchpquality.mythic
    end
end

function csvnpc_getheadicon(config_npc)
    local icon = config_npc.icon
    if icon == "d1" then
        return "monster_n_1"
    elseif icon == "d2" then
        return "monster_n_2"
    elseif icon == "d3" then
        return "monster_n_3"
    elseif icon == "d4" then
        return "monster_r_1"
    elseif icon == "d5" or icon == "d6" or icon == "d7" then
        return "monster_r_3"
    end
    return icon;
end
