
local m_debugasset_full
local m_debugasset_fulltable
local m_debugasset_name
local m_debugasset_nametable
local m_debugasset_maptable
local m_debugasset_skeletonarray
local m_debugasset_vfx

function debugasset_addfull(filename)
    if m_debugasset_fulltable[filename] ~= nil then
        return
    end
    m_debugasset_fulltable[filename] = #m_debugasset_full + 1
    m_debugasset_full[#m_debugasset_full + 1] = filename
end

function debugasset_addname(filename, allskeleton)
    if filename == nil or filename == "0" or m_debugasset_nametable[filename] ~= nil then
        return
    end
    if allskeleton then
        for i=1,#m_debugasset_skeletonarray do
            local config_skeleton = m_debugasset_skeletonarray[i]
            local fullname = string.format("%s%s", config_skeleton.filename, filename)
            if m_debugasset_nametable[fullname] == nil then
                m_debugasset_nametable[fullname] = #m_debugasset_name + 1
                m_debugasset_name[#m_debugasset_name + 1] = fullname
            end
        end
    else
        m_debugasset_nametable[filename] = #m_debugasset_name + 1
        m_debugasset_name[#m_debugasset_name + 1] = filename
    end
end

function debugasset_addmap(mapid, filename)
    local prevmapid = m_debugasset_maptable[filename]
    if prevmapid ~= nil then
        if prevmapid ~= mapid then
            m_debugasset_maptable[filename] = nil
        end
        return
    end
    local mapasset = {}
    mapasset.mapid = mapid
    mapasset.filename = filename
    m_debugasset_maptable[filename] = mapasset
end

function debugasset_save(assetarray, filename)
    local str = ""
    for i=1,#assetarray do
        str = str .. assetarray[i] .. "\r\n"
    end
    c_config_writetext("../../" .. filename, str)
end

function debugasset_collectfxc(fxcname)
    if fxcname == nil then
        return
    end
    if string.startwith(fxcname, "fc_") then
        local skillfxc = csvskillfxc_getfromname(fxcname)
        if skillfxc ~= nil then
            for i=1, #skillfxc do
                local node = skillfxc[i]
                if node.particle ~= nil then
                    m_debugasset_vfx[node.particle] = node.particle
                end
            end
        end
    else
        m_debugasset_vfx[fxcname] = fxcname
    end
end

function debugasset_collectskillfxc(lambda)
    if lambda ~= "0" then
        local fxname = csvconfig_getsubvalue(lambda, 1, configsubtype.str)
        debugasset_collectfxc(fxname)
    end
end

function debugasset_addaliasattachmesh(meshtitle)
    local markerarray = csvanimmarker_load(meshtitle)
    for key, marker in pairs(markerarray) do
        if marker.attachmesh ~= nil then
            for i=1,#marker.attachmesh do
                local attachmesh = marker.attachmesh[i]
                if string.endwith(attachmesh.mesh, ".cgf") then
                    debugasset_addfull(attachmesh.mesh)
                end
            end
        end
	end
end

function debugasset_collect()
    m_debugasset_full = {}
    m_debugasset_fulltable = {}
    m_debugasset_name = {}
    m_debugasset_nametable = {}
    m_debugasset_maptable = {}
    m_debugasset_vfx = {}

    m_debugasset_skeletonarray = c_config_loadscriptarray(csvconfig_filename("render_skeleton"))
    for i=1,#m_debugasset_skeletonarray do
        local config_skeleton = m_debugasset_skeletonarray[i]
        debugasset_addfull(string.format("%s/%s.cgf", config_skeleton.meshroot, config_skeleton.filename))
        debugasset_addaliasattachmesh(config_skeleton.filename)
    end

    debugasset_addname(RenderDefault_Torsor, true)
    debugasset_addname(RenderDefault_Pants, true)
    debugasset_addname(RenderDefault_Glove, true)
    debugasset_addname(RenderDefault_Shoes, true)
    debugasset_addname(RenderDefault_Wing, true)

    local weaponarray = c_config_loadscriptarray(csvconfig_filename("equip_weapon"))
    for i=1,#weaponarray do
        local config_weapon = weaponarray[i]
        debugasset_addfull(string.format("objects/items/%s.cgf", config_weapon.mesh))
        if config_weapon.meshbattle ~= nil and config_weapon.meshbattle ~= "0" then
            debugasset_addfull(string.format("objects/items/%s.cgf", config_weapon.meshbattle))
        end
    end
    debugasset_addfull("objects/items/702_testarrow.cgf")
    debugasset_addfull("objects/pc/lm/mesh/lm001_emblem.cgf")
    debugasset_addfull("objects/pc/lf/mesh/lf001_emblem.cgf")
    debugasset_addfull("objects/pc/df/mesh/df001_emblem.cgf")
    debugasset_addfull("objects/pc/dm/mesh/dm001_emblem.cgf")

    local armorarray = c_config_loadscriptarray(csvconfig_filename("equip_armor"))
    for i=1,#armorarray do
        local config_armor = armorarray[i]
        if config_armor.itemtype == csvitemtype.weapon_sub
        or config_armor.itemtype == csvitemtype.weapon_shield then
            debugasset_addname(config_armor.mesh, false)
            debugasset_addname(config_armor.meshbattle, false)
        else
            debugasset_addname(config_armor.mesh, true)
            debugasset_addname(config_armor.meshbattle, true)
        end
    end

    -- local armorarray = c_config_loadscriptarray(csvconfig_filename("item_category"))
    -- for i=1,#armorarray do
    --     local config_item = armorarray[i]
    --     if config_item.itemtype == csvitemtype.consume_god then
    --         local lambda = csvitem_getscript(config_item, "godstone")
    --         local godvfx = lambda.variable[4].str
    --         if godvfx ~= "0" then
    --             m_debugasset_vfx[godvfx] = godvfx
    --         end
    --     end
    -- end

    local npcarray = c_config_loadscriptarray(csvconfig_filename("npc"))
    for i=1,#npcarray do
        local config_npc = npcarray[i]
        local render = string.split(config_npc.mesh, ";")
        for i=1, #render do
            local subrender = string.split(render[i], ":")
            if subrender[1] == "mesh" then
                local npcmesh = subrender[2]
                if string.startwith(npcmesh, "monster/pc_polymorph") then
                    debugasset_addfull(string.format("objects/%sf.cgf", npcmesh))
                    debugasset_addfull(string.format("objects/%sm.cgf", npcmesh))
                else
                    debugasset_addfull(string.format("objects/%s.cgf", npcmesh))
                end
                local index = string.reversefind(npcmesh, "/")
                if index ~= nil then
                    debugasset_addaliasattachmesh(string.sub(npcmesh, index + 1))
                end
            end
        end
    end
    
    local petarray = c_config_loadscriptarray(csvconfig_filename("pet_main"))
    for i=1,#petarray do
        local config_pet = petarray[i]
        local filename = config_pet.mesh
        debugasset_addfull(string.format("objects/%s.cgf", filename))
        local index = string.reversefind(filename, "/")
        if index ~= nil then
            debugasset_addaliasattachmesh(string.sub(filename, index + 1))
        end
    end

    local bgmarray = c_config_loadscriptarray(csvconfig_filename("map_bgm"))
    for i=1,#bgmarray do
        local bgm = bgmarray[i]
        debugasset_addmap(bgm.id, bgm.filename)
    end

    debugasset_collectfxc(FXCLevelUp)
    debugasset_collectskillfxc(EffectSkillMageBow)
    debugasset_collectfxc(EffectSkillDimensiondoor)
    debugasset_collectfxc("skill_dmgshield/dmgshield/hit_protect_a")
    debugasset_collectfxc("skill_dmgshield/dmgshield/hit_protect_b")
    debugasset_collectfxc("skill_dmgshield/dmgshield/hit_transfer_b")
    debugasset_collectfxc("skill_dmgshield/dmgshield/hit_transfer_c")
    debugasset_collectfxc("env_foot_dust/foot_dust/dust")
    debugasset_collectfxc("env_foot_dust/foot_dust/sand")
    debugasset_collectfxc("env_foot_dust/foot_dust/snow")

    local skillarray = c_config_getmetaall(configid.skill)
    for i=1,#skillarray do
		local config_skill = skillarray[i]
        debugasset_collectskillfxc(config_skill.fxspell)
        debugasset_collectskillfxc(config_skill.fxcast)
        debugasset_collectskillfxc(config_skill.fxammo)
        debugasset_collectskillfxc(config_skill.fxprehit)
        debugasset_collectskillfxc(config_skill.fxhit)
        debugasset_collectskillfxc(config_skill.fxhitinterval)
	end
    skillarray = c_config_getmetaall(configid.skill_buff)
    for i=1,#skillarray do
		local config_skill = skillarray[i]
        debugasset_collectskillfxc(config_skill.render)
	end

    debugasset_save(m_debugasset_full, "assetfull.txt")
    debugasset_save(m_debugasset_name, "assetname.txt")

    local str = ""
    for key, val in pairs(m_debugasset_maptable) do
		str = str .. val.filename .. "\t" .. val.mapid .. "\r\n"
	end
    c_config_writetext("../../assetmap.txt", str)

    str = ""
    for key, val in pairs(m_debugasset_vfx) do
		str = str .. val .. "\r\n"
	end
    c_config_writetext("../../assetvfx.txt", str)
end
