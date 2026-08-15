
RenderLayerDefault = 0
RenderLayerScene = 10
RenderLayerTerrain = 11
RenderLayerCollider = 12
RenderLayerCG = 13
RenderLayerMe = 20
RenderLayerPlayer = 21
RenderLayerPlayerIgnoreCollision = 22
RenderLayerNPC = 23
RenderLayerStaticNPC = 24
RenderLayerStaticNPCCollider = 25
RenderLayerVFX = 26

ColliderHit = 1
ColliderSlide = 2
ColliderElevator = 4

maskcollider = bit.bor(bit.lshift(1, RenderLayerTerrain), bit.lshift(1, RenderLayerCollider), bit.lshift(1, RenderLayerStaticNPC), bit.lshift(1, RenderLayerStaticNPCCollider))
maskpickactor = bit.bor(bit.lshift(1, RenderLayerTerrain), bit.lshift(1, RenderLayerCollider), bit.lshift(1, RenderLayerStaticNPC), bit.lshift(1, RenderLayerStaticNPCCollider), bit.lshift(1, RenderLayerPlayer), bit.lshift(1, RenderLayerNPC))
maskcctexclude = bit.lshift(1, RenderLayerScene)
maskcamera = bit.bor(bit.lshift(1, RenderLayerTerrain), bit.lshift(1, RenderLayerCollider), bit.lshift(1, RenderLayerStaticNPC))

rendermaterialparam = 
{
    keyword = 0,
    float = 1,
    vector = 2,
    color = 3,
}

renderslot =
{
    torso = 1,
    pants = 2,
    shoulder = 3,
    glove = 4,
    shoes = 5,
    face = 6,
    hair = 7,
    helmet = 8,
    necklace = 9,
    earring1 = 10,
    earring2 = 11,
    weapon1 = 12,
    weapon2 = 13,
    wing = 14,
    weapontype1 = 15,
    weapontype2 = 16,
    weaponbattle1 = 17,
    weaponbattle2 = 18,
    torsobattle = 19,
    pantsbattle = 20,
    shoulderbattle = 21,
    glovebattle = 22,
    shoesbattle = 23,
    helmetbattle = 26,
    weaponnormalfx1 = 27,
    weaponnormalfx2 = 28,
    weaponbattlefx1 = 29,
    weaponbattlefx2 = 30,
}

actorrenderflag =
{
	additive = 0x1,
	blendout = 0x2,
    hide = 0x4,
    elevator = 0x8,
    mergeparent = 0x10,
    bindinverse = 0x20,
    syncanim = 0x40,
    loopanim = 0x80,
    resetanim = 0x100,
    mixanim = 0x200,
    mixclear = 0x400,
    mixrecursive = 0x800,
    noskin = 0x1000,
    syncstopaudio = 0x2000,
    vfxmovetotarget = 0x4000,
    vfxlinktotarget = 0x8000,
    stopinvalidanim = 0x10000,
    randanim = 0x20000,
    bakemesh = 0x40000,
    disablealiasaudio = 0x80000,
}

actormaterialflag =
{
    loadsync = 0x1,
}

actoranimpart =
{
	career = 0x1,
	weapon = 0x2,
    type = 0x4,
    shop = 0x8,
}

actoranimweapon =
{
    [0] = "noweapon",
	[1011] = "mace",
	[1012] = "dagger",
    [1013] = "1hand",
    [1021] = "2hand",
	[1022] = "polearm",
    [1023] = "staff",
    [1024] = "bow",
	[1025] = "book",
    [1026] = "orb",
}

actoranimcareer =
{
    [playercareer.warrior] = "warrior",
    [playercareer.cleric] = "cleric",
    [playercareer.scout] = "scout",
    [playercareer.mage] = "mage",
    [playercareer.fighter] = "fighter",
    [playercareer.knight] = "knight",
    [playercareer.priest] = "priest",
    [playercareer.chanter] = "chanter",
    [playercareer.assassin] = "assassin",
    [playercareer.ranger] = "ranger",
    [playercareer.wizard] = "wizard",
    [playercareer.elementallist] = "elementalist",
}

RenderDefault_Hair = "001_hair"
RenderDefault_Face = "001_head"
RenderDefault_Torsor = "df_c001_body"
RenderDefault_Pants = "df_c001_leg"
RenderDefault_Glove = "df_c001_hand"
RenderDefault_Shoes = "df_c001_foot"
RenderDefault_Wing = "wing_001"

function csvrender_gethairrender(civ, sex, id)
    return string.format("%03d_hair", morph_getround(id, civ, sex, MorphLimitHair))
end

function csvrender_getcivstr(civ, sex)
    if civ == playerciv.light then
        if sex == playersex.male then
            return "lm"
        else
            return "lf"
        end
    else
        if sex == playersex.male then
            return "dm"
        else
            return "df"
        end
    end
end

function csvrender_getfacetexturepath(civ, sex)
    if civ == playerciv.light then
        if sex == playersex.male then
            return "objects/pc/lm/texture", "lm"
        else
            return "objects/pc/lf/texture", "lf"
        end
    else
        if sex == playersex.male then
            return "objects/pc/dm/texture", "dm"
        else
            return "objects/pc/df/texture", "df"
        end
    end
end

function csvrender_getitemviewpath(filename)
    local fullname = string.format("objects/items/%s", filename)
    return string.format("%s.cgf.prefab", fullname), fullname, filename
end

function csvrender_getwingpath(civ, sex, filename)
    local civstr = csvrender_getcivstr(civ, sex)
    filename = civstr .. filename
    local fullname = string.format("objects/pc/wing/%s", filename)
    return string.format("%s.cgf.prefab", fullname), fullname, filename
end

function csvrender_getdefaultrender()
    local render = {}
    render[renderslot.torso] = RenderDefault_Torsor
    render[renderslot.pants] = RenderDefault_Pants
    render[renderslot.glove] = RenderDefault_Glove
    render[renderslot.shoes] = RenderDefault_Shoes
    render[renderslot.face] = RenderDefault_Face
    render[renderslot.hair] = RenderDefault_Hair
    return render
end

function csvrender_partisskin(part)
    return part >= renderslot.torso and part <= renderslot.face
end

function csvrender_getitemrender(config_item)
    if config_item == nil then
        return
    end
    local part = nil
    if config_item.itemtype == csvitemtype.cosplay_torso
    or config_item.itemtype == csvitemtype.plate_torso
    or config_item.itemtype == csvitemtype.chain_torso
    or config_item.itemtype == csvitemtype.leather_torso
    or config_item.itemtype == csvitemtype.cloth_torso then
        part = renderslot.torso
    elseif config_item.itemtype == csvitemtype.cosplay_pants
    or config_item.itemtype == csvitemtype.plate_pants
    or config_item.itemtype == csvitemtype.chain_pants
    or config_item.itemtype == csvitemtype.leather_pants
    or config_item.itemtype == csvitemtype.cloth_pants then
        part = renderslot.pants
    elseif config_item.itemtype == csvitemtype.cosplay_shoulder
    or config_item.itemtype == csvitemtype.plate_shoulder
    or config_item.itemtype == csvitemtype.chain_shoulder
    or config_item.itemtype == csvitemtype.leather_shoulder
    or config_item.itemtype == csvitemtype.cloth_shoulder then
        part = renderslot.shoulder
    elseif config_item.itemtype == csvitemtype.cosplay_glove
    or config_item.itemtype == csvitemtype.plate_glove
    or config_item.itemtype == csvitemtype.chain_glove
    or config_item.itemtype == csvitemtype.leather_glove
    or config_item.itemtype == csvitemtype.cloth_glove then
        part = renderslot.glove
    elseif config_item.itemtype == csvitemtype.cosplay_shoes
    or config_item.itemtype == csvitemtype.plate_shoes
    or config_item.itemtype == csvitemtype.chain_shoes
    or config_item.itemtype == csvitemtype.leather_shoes
    or config_item.itemtype == csvitemtype.cloth_shoes then
        part = renderslot.shoes
    elseif config_item.itemtype == csvitemtype.accessory_helmet then
        part = renderslot.helmet
    elseif config_item.itemtype == csvitemtype.accessory_necklace then
        part = renderslot.necklace
    elseif config_item.itemtype == csvitemtype.accessory_earring then
        part = renderslot.earring1
    elseif config_item.itemtype == csvitemtype.accessory_wing then
        part = renderslot.wing
    elseif config_item.itemtype == csvitemtype.weapon_tool1
    or config_item.itemtype == csvitemtype.weapon_mace
    or config_item.itemtype == csvitemtype.weapon_dagger
    or config_item.itemtype == csvitemtype.weapon_sword1 then
        part = renderslot.weapon1
    elseif config_item.itemtype == csvitemtype.weapon_shield then
        part = renderslot.weapon2
    elseif config_item.itemtype == csvitemtype.weapon_tool2
    or config_item.itemtype == csvitemtype.weapon_sword2
    or config_item.itemtype == csvitemtype.weapon_polearm
    or config_item.itemtype == csvitemtype.weapon_staff
    or config_item.itemtype == csvitemtype.weapon_bow
    or config_item.itemtype == csvitemtype.weapon_book
    or config_item.itemtype == csvitemtype.weapon_orb then
        part = renderslot.weapon1
    end

    if part == nil then
        return
    end
    if config_item.mesh ~= nil and config_item.mesh ~= "0" then
        local meshbattle = config_item.meshbattle
        if meshbattle ~= nil and meshbattle == "0" then
            meshbattle = nil
        end
        local fxnormal = config_item.fxidle
        if fxnormal ~= nil and fxnormal == "0" then
            fxnormal = nil
        end
        local fxbattle = config_item.fxbattle
        if fxbattle ~= nil and fxbattle == "0" then
            fxbattle = nil
        end
        return part, config_item.mesh, meshbattle, fxnormal, fxbattle, config_item.itemtype
    end
    if part == renderslot.torso then
        return part, RenderDefault_Torsor
    elseif part == renderslot.pants then
        return part, RenderDefault_Pants
    elseif part == renderslot.glove then
        return part, RenderDefault_Glove
    elseif part == renderslot.shoes then
        return part, RenderDefault_Shoes
    end
end

function csvrender_getequipview(sex, render, color, equip, equipdye, isplayerequip)
    if isplayerequip then
        render[renderslot.wing] = RenderDefault_Wing
    end
    local visualslot = nil
    for i=1, #equip do
        local config_item = csvitem_getfromid(equip[i])
        local part, file, filebattle, fxnormal, fxbattle, itemtype = csvrender_getitemrender(config_item)
        if part ~= nil then
            if visualslot ~= nil then
                if visualslot[part] ~= nil then
                    part = nil
                end
            elseif config_item.visualslot ~= nil and config_item.visualslot ~= 0 then
                if visualslot == nil then
                    visualslot = {}
                end
                for j=renderslot.torso,renderslot.helmet do
                    local vslot = bit.lshift(1, j)
                    if bit.band(config_item.visualslot, vslot) ~= 0 then
                        visualslot[j] = config_item
                        render[j] = nil
                        if color ~= nil then
                            color[j] = nil
                        end
                    end
                end
            end
        end
        if part ~= nil then            
            if color ~= nil then
                if equipdye ~= nil and equipdye[i] ~= nil then
                    color[part] = equipdye[i]
                elseif sex == playersex.male then
                    color[part] = config_item.colormale
                else
                    color[part] = config_item.colorfemale
                end
            end
            if part == renderslot.weapon1 then
                if isplayerequip then
                    if i == equipslot.weapon1 then
                        render[renderslot.weapon1] = file
                        render[renderslot.weapontype1] = itemtype
                        render[renderslot.weaponbattle1] = filebattle
                        render[renderslot.weaponnormalfx1] = fxnormal
                        render[renderslot.weaponbattlefx1] = fxbattle
                    else
                        render[renderslot.weapon2] = file
                        render[renderslot.weapontype2] = itemtype
                        render[renderslot.weaponbattle2] = filebattle
                        render[renderslot.weaponnormalfx2] = fxnormal
                        render[renderslot.weaponbattlefx2] = fxbattle
                    end
                else
                    if render[renderslot.weapon1] == nil then
                        render[renderslot.weapon1] = file
                        render[renderslot.weapontype1] = itemtype
                    else
                        render[renderslot.weapon2] = file
                        render[renderslot.weapontype2] = itemtype
                    end
                end
            elseif part == renderslot.weapon2 then
                render[part] = file
                render[renderslot.weapontype2] = itemtype
            elseif part == renderslot.earring1 then
                if isplayerequip then
                    if i == equipslot.earring1 then
                        render[renderslot.earring1] = file
                    else
                        render[renderslot.earring2] = file
                    end
                else
                    if render[renderslot.earring1] == nil then
                        render[renderslot.earring1] = file
                    else
                        render[renderslot.earring2] = file
                    end
                end
            else
                render[part] = file
                if filebattle ~= nil then
                    if part == renderslot.torso then
                        render[renderslot.torsobattle] = filebattle
                    elseif part == renderslot.pants then
                        render[renderslot.pantsbattle] = filebattle
                    elseif part == renderslot.shoulder then
                        render[renderslot.shoulderbattle] = filebattle
                    elseif part == renderslot.glove then
                        render[renderslot.glovebattle] = filebattle
                    elseif part == renderslot.shoes then
                        render[renderslot.shoesbattle] = filebattle
                    elseif part == renderslot.helmet then
                        render[renderslot.helmetbattle] = filebattle
                    end
                end
            end
        end
    end
    if isplayerequip then
        if render[renderslot.weapon1] == nil and render[renderslot.weapon2] ~= nil and render[renderslot.weapontype2] ~= csvitemtype.weapon_shield then
            render[renderslot.weapon1] = render[renderslot.weapon2]
            render[renderslot.weapontype1] = render[renderslot.weapontype2]
            render[renderslot.weapon2] = nil
            render[renderslot.weapontype2] = nil
        end
    end
end

function csvrender_getskeletonid(civ, sex)
    if civ == playerciv.light then
        if sex == playersex.male then
            return 1
        else
            return 2
        end
    else
        if sex == playersex.male then
            return 3
        else
            return 4
        end
    end
end

function csvrender_skintoattr(attr, msg)
	attr.hair = msg.hair
	attr.face = msg.face
	attr.feat1 = msg.feat1
	attr.feat2 = msg.feat2
	attr.bump = msg.bump
	attr.expression = msg.expression
	attr.faceshape = msg.faceshape
	attr.haircolor = msg.haircolor
	attr.eyecolor = msg.eyecolor
	attr.lipcolor = msg.lipcolor
	attr.skincolor = msg.skincolor
	attr.bodysize = math.clamp(msg.bodysize, MorphBodySizeRange[1], MorphBodySizeRange[2])
	attr.facemorph = msg.facemorph or {}
	attr.bodymorph = msg.bodymorph or {}
end
