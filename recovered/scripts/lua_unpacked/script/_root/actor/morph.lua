
MorphBodyRange = 
{
    {108, 45},
    {68,  20},
    {78,  20},
    {28,  80},
    {108, 30},
    {80,  30},
    {68,  20},
    {68,  40},
    {88,  30},
    {28,  30},
    {38,  40},
    {38,  40},
    {103, 10},
    {58,  70},
    {58,  70},
    {83,  30},
    {83,  30},
    {78,  30},
    {28,  40},
}
MorphFaceRange = {100, 100}
MorphFaceShapeRange = {58, 70}
MorphBodySizeRange = {0.65, 1.2}

MorphLimitHair = {1, 49, 59, 50, 60}
MorphLimitFace = {1, 31, 36, 29, 38}
MorphLimitFeat1 = {0, 18, 6, 18, 6}
MorphLimitFeat2 = {0, 13, 17, 15, 17}
MorphLimitBump = {0, 5, 5, 5, 5}
MorphLimitExpression = {0, 6, 6, 6, 6}

MorphSelect =
{
    hair = 1,
    face = 2,
    feat1 = 3,
    feat2 = 4,
    bump = 5,
    expression = 6,
    faceshape = 7,
    haircolor = 8,
    eyecolor = 9,
    lipcolor = 10,
    skincolor = 11,
    bodysize = 12,
}

FaceMorph =
{
    morph1 = 1,
    morph2 = 2,
    morph3 = 3,
    morph4 = 4,
    morph5 = 5,
    morph6 = 6,
    morph7 = 7,
    morph8 = 8,
    morph9 = 9,
    morph10 = 10,
    morph11 = 11,
    morph12 = 12,
    morph13 = 13,
    morph14 = 14,
    morph15 = 15,
    morph16 = 16,
    morph17 = 17,
    morph18 = 18,
    morph19 = 19,
    morph20 = 20,
    morph21 = 21,
    morph22 = 22,
    morph23 = 23,
    morph24 = 24,
    morph25 = 25,
}
FaceMorphCount = table.valcount(FaceMorph)

FaceShapeMorph =
{
    { name = "faceshape", min = 0.8, max = 1.4},
    { bone = "bip01 head", sy = 0.3 },
    { bone = "leye_bone", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "reye_bone", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "mouth_bone", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "lear_bone", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "rear_bone", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "fx_h01", py = 0.3, pz = 1.0, sx = 1.0, sy = 0.3 },
    { bone = "l_sup", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    -- { bone = "l_eye_upper", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    -- { bone = "l_eye_under", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    { bone = "r_sup", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    -- { bone = "r_eye_upper", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    -- { bone = "r_eye_under", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    { bone = "l_mouth_side", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    { bone = "r_mouth_side", py = 0.3, pz = 1.0, sx = 0.3, sy = 1.0 },
    { bone = "mouth", py = 0.3, pz = 1.0, sx = 0.3, sz = 1.0 },
}

BodyMorph =
{
	[1] =
    {
        { name = "headsize", min = 0.8, max = 1.4},
        { bone = "bip01 head", sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "leye_bone", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "reye_bone", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "mouth_bone", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "lear_bone", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "rear_bone", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "fx_h01", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "l_sup", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "l_eye_upper", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "l_eye_under", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "r_sup", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "r_eye_upper", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "r_eye_under", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "l_mouth_side", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "r_mouth_side", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "mouth", px = 1.0, py = 1.0, pz = 1.0, sx = 1.0, sy = 1.0, sz = 1.0 },
    },
	[2] =
    {
        { name = "necksize", min = 0.1, max = 1.3 },
        { bone = "bip01 neck", sy = 0.2, sz = 1.0 },
    },
	[3] =
    {
        { name = "necklength", min = 0.1, max = 2.0 },
        { bone = "bip01 neck", sx = 1.0 },
        { bone = "bip01 head", px = 1.0 },
    },
	[4] =
    {
        { name = "shoulder", min = 0.1, max = 2.0 },
        { bone = "l_shcustom", px = 0.0, py = 0.0, pz = 0.8, sx = 0.5, sy = 0.5, sz = 0.5 },
        { bone = "r_shcustom", px = 0.0, py = 0.0, pz = 0.8, sx = 0.5, sy = 0.5, sz = 0.5 },
        { bone = "l_sbone", px = 0.0, py = 0.0, pz = 0.5, sx = 0.08, sy = 0.08, sz = 0.08 },
        { bone = "r_sbone", px = 0.0, py = 0.0, pz = 0.5, sx = 0.08, sy = 0.08, sz = 0.08 },
    },
    [5] =
    {
        { name = "shoulderwidth", min = 0.1, max = 2.0 },
        { bone = "bip01 l clavicle", pz = 1.0 },
        { bone = "bip01 r clavicle", pz = 1.0 },
    },
    [6] =
    {
        { name = "torsolength", min = 0.85, max = 1.11 },
        { bone = "bip01 spine", sx = 3.0 },
        { bone = "bip01 spine1", px = 4.0, sx = 1.0 },
        { bone = "bip01 neck", px = 1.0 },
    },
    [7] =
    {
        { name = "breast", min = 0.1, max = 2.0 },
        { bone = "bip01 spine1", sy = 0.7, sz = 0.4 },
        { bone = "fx_hit", py = 1.0 },
        { bone = "wing_bone", py = 1.0, miny = 1.05 },
        { bone = "back_bone", py = 0.4 },
        { bone = "lback_bone", py = 0.4 },
        { bone = "rback_bone", py = 1.0 },
        { bone = "lhip_bone", py = 1.0 },
        { bone = "rhip_bone", py = 0.2 },
        { bone = "l_bust", py = 1.0, pz = 0.7 },
        { bone = "r_bust", py = 0.2, pz = 0.7 },
    },
    [8] =
    {
        { name = "bust", min = 0.1, max = 2.0 },
        { bone = "l_bust", px = -0.2, py = 0.4, pz = 0.4, sx = 1.0, sy = 1.0, sz = 1.0 },
        { bone = "r_bust", px = -0.2, py = 0.4, pz = 0.4, sx = 1.0, sy = 1.0, sz = 1.0 },
    },
    [9] =
    {
        { name = "waist", min = 0.1, max = 2.0 },
        { bone = "bip01 spine", sy = 1.0, sz = 0.6 },
        { bone = "bone_l1_00", px = 0.72, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l2_00", px = 0.3, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l3_00", px = 0.72, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r1_00", px = 0.72, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r2_00", px = 0.3, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r3_00", px = 0.72, py = 0.336, minx = 0.95, miny = 0.95, minz = 0.95 },
    },
    [10] =
    {
        { name = "pelvis", min = 0.1, max = 2.0 },
        { bone = "bip01 pelvis", sy = 0.5, sz = 0.5 },
        { bone = "lwaist_bone", py = 0.3, minx = 1.0, miny = 1.0, minz = 1.0 },
        { bone = "bone_l1_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l2_00", px = 0.5, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l3_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r1_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r2_00", px = 0.5, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r3_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
    },
    [11] =
    {
        { name = "upperarmsize", min = 0.6, max = 2.0 },
        { bone = "bip01 l upperarm", sy = 1.0, sz = 0.9 },
        { bone = "bip01 l clavicle", sy = 0.4, sz = 0.4 },
        { bone = "bip01 r upperarm", sy = 1.0, sz = 0.9 },
        { bone = "bip01 r clavicle", sy = 0.4, sz = 0.4 },
        { bone = "l_sbone", sx = 0.4, sy = 0.4, sz = 0.4, minx = 1.0, miny = 1.0, minz = 1.0 },
        { bone = "r_sbone", sx = 0.4, sy = 0.4, sz = 0.4, minx = 1.0, miny = 1.0, minz = 1.0 },
        { bone = "l_sbone", pz = 1.6 },
        { bone = "r_sbone", pz = 1.6 },
        { bone = "l_shcustom", px = 0.4, pz = 0.4 },
        { bone = "r_shcustom", px = 0.4, pz = 0.4 },
    },
    [12] =
    {
        { name = "lowerarmsize", min = 0.6, max = 2.0 },
        { bone = "bip01 l forearm", sy = 0.6, sz = 0.8 },
        { bone = "bip01 r forearm", sy = 0.6, sz = 0.8 },
    },
    [13] =
    {
        { name = "armlength", min = 0.6, max = 2.0 },
        { bone = "bip01 l forearm", px = 0.2 },
        { bone = "bip01 l hand", px = 0.2 },
        { bone = "bip01 r forearm", px = 0.2 },
        { bone = "bip01 r hand", px = 0.2 },
    },
    [14] =
    {
        { name = "handlength", min = 0.75, max = 1.29 },
        { bone = "bip01 l hand", sx = 0.5 },
        { bone = "lhand_bone", px = 0.8 },
        { bone = "bip01 l finger0", px = 0.8, sx = 0.7 },
        { bone = "bip01 l finger01", px = 0.8, sx = 0.7 },
        { bone = "bip01 l finger1", px = 0.8, sx = 0.5 },
        { bone = "bip01 l finger11", px = 0.6, sx = 0.5 },
        { bone = "bip01 l finger2", px = 0.8, sx = 0.5 },
        { bone = "bip01 l finger21", px = 0.6, sx = 0.5 },
        { bone = "bip01 r hand", sx = 0.5 },
        { bone = "rhand_bone", px = 0.8 },
        { bone = "bip01 r finger0", px = 0.8, sx = 0.7 },
        { bone = "bip01 r finger01", px = 0.8, sx = 0.7 },
        { bone = "bip01 r finger1", px = 0.8, sx = 0.5 },
        { bone = "bip01 r finger11", px = 0.6, sx = 0.5 },
        { bone = "bip01 r finger2", px = 0.8, sx = 0.5 },
        { bone = "bip01 r finger21", px = 0.6, sx = 0.5 },
    },
    [15] =
    {
        { name = "handsize", min = 0.1, max = 2.0 },
        { bone = "bip01 l hand", sy = 0.5, sz = 0.3 },
        { bone = "bip01 l finger0", sy = 1.0, sz = 0.3 },
        { bone = "bip01 l finger01", sy = 1.0, sz = 0.3 },
        { bone = "bip01 l finger11", sy = 1.0, sz = 0.3 },
        { bone = "bip01 l finger2", sy = 1.0, sz = 0.3 },
        { bone = "bip01 l finger21", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r hand", sy = 0.5, sz = 0.3 },
        { bone = "bip01 r finger0", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r finger01", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r finger1", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r finger11", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r finger2", sy = 1.0, sz = 0.3 },
        { bone = "bip01 r finger21", sy = 1.0, sz = 0.3 },
    },
    [16] =
    {
        { name = "thighsize", min = 0.1, max = 2.0 },
        { bone = "bip01 l thigh", sy = 0.8, sz = 0.7 },
        { bone = "bip01 r thigh", sy = 0.8, sz = 0.7 },
        { bone = "bone_l1_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l2_00", px = 0.5, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_l3_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r1_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r2_00", px = 0.5, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "bone_r3_00", px = 1.2, py = 0.7, minx = 0.95, miny = 0.95, minz = 0.95 },
        { bone = "lwaist_bone", py = 0.3, minx = 1.0, miny = 1.0, minz = 1.0 },
    },
    [17] =
    {
        { name = "calfsize", min = 0.1, max = 2.0 },
        { bone = "bip01 l calf", sy = 0.6, sz = 0.7 },
        { bone = "bip01 r calf", sy = 0.6, sz = 0.7 },
    },
    [18] =
    {
        { name = "leglength", min = 0.1, max = 2.0 },
        { bone = "bip01 l calf", px = 0.25 },
        { bone = "bip01 l foot", px = 0.25 },
        { bone = "bip01 r calf", px = 0.25 },
        { bone = "bip01 r foot", px = 0.25 },
    },
    [19] =
    {
        { name = "footsize", min = 0.1, max = 2.0 },
        { bone = "bip01 l foot", sy = 0.6, sz = 0.6 },
        { bone = "bip01 l toe0", sy = 0.6, sz = 0.6, py = 1.0 },
        { bone = "bip01 r foot", sy = 0.6, sz = 0.6 },
        { bone = "bip01 r toe0", sy = 0.6, sz = 0.6, py = 1.0 },
    },
}

BodyMorphCount = table.valcount(BodyMorph)

function morph_getminmax(civ, sex, type)
    local min = type[1]
    local max = type[1]
    if civ == playerciv.light then
        if sex == playersex.male then
            max = type[2]
        else
            max = type[3]
        end
    else
        if sex == playersex.male then
            max = type[4]
        else
            max = type[5]
        end
    end
    return min, max
end

function morph_getlimit(val, civ, sex, type)
    local min, max = morph_getminmax(civ, sex, type)
    if val < min then
        val = max
    elseif val > max then
        val = min
    end
    return math.clamp(val, min, max)
end

function morph_getround(val, civ, sex, type)
    local min, max = morph_getminmax(civ, sex, type)
    if val < min then
        val = max
    elseif val > max then
        val = min
    end
    return val
end

function morph_slidertoval(slider, range)
    if slider < 0 then
        return slider * range[1]
    elseif slider > 0 then
        return slider * range[2]
    else
        return 0
    end
end

function morph_valtoslider(val, range)
    local slider = 0.0
    if val < 0 then
        slider = val / range[1]
    elseif val > 0 then
        slider = val / range[2]
    end
    return math.clamp(slider, -1.0, 1.0)
end

local function bodymorph_setbones(info, submorph, bone, vartype, slider)
    if submorph[vartype] == nil or slider == 0.0 then
        return
    end
    local valscale = submorph[vartype]
    local val = 1.0
    if slider < 0.0 then
        val = math.lerp(info.min, 1.0, slider * valscale + 1.0)
    else
        val = math.lerp(1.0, info.max, slider * valscale)
    end
    if bone[vartype] ~= nil then
        bone[vartype] = bone[vartype] * val
    else
        bone[vartype] = val
    end
end

function bodymorph_apply(listapply, bodymorph, slider, range)
    local info = bodymorph[1]
    slider = math.clamp(slider, -range[1], range[2])
    slider = slider / 128.0
    for i=2,#bodymorph do
        local submorph = bodymorph[i]
        local bone = listapply[submorph.bone]
        if bone == nil then
            bone = {}
            bone.name = submorph.bone
            listapply[submorph.bone] = bone
        end
        bodymorph_setbones(info, submorph, bone, "px", slider)
        bodymorph_setbones(info, submorph, bone, "py", slider)
        bodymorph_setbones(info, submorph, bone, "pz", slider)
        bodymorph_setbones(info, submorph, bone, "sx", slider)
        bodymorph_setbones(info, submorph, bone, "sy", slider)
        bodymorph_setbones(info, submorph, bone, "sz", slider)
    end
end

function facemorph_set_1(actor, val)
    actor:setfacemorph2("facetype_face_round", "facetype_face_sharp", val)
end

function facemorph_set_2(actor, val)
    actor:setfacemorph2("facetype_face_narrow", "facetype_face_squared", val)
end

function facemorph_set_3(actor, val)
    actor:setfacemorph2("facetype_forehead_smooth", "facetype_forehead_bumpy", val)
end

function facemorph_set_4(actor, val)
    actor:setfacemorph2("facetype_eye_lower", "facetype_eye_upper", val)
end

function facemorph_set_5(actor, val)
    actor:setfacemorph2("facetype_eye_closeset", "facetype_eye_wideset", val)
end

function facemorph_set_6(actor, val)
    actor:setfacemorph2("facetype_eye_round", "facetype_eye_slant", val)
end

function facemorph_set_7(actor, val)
    actor:setfacemorph2("facetype_eye_close", "facetype_eye_open", val)
end

function facemorph_set_8(actor, val)
    actor:setfacemorph2("facetype_eye_arch", "facetype_eye_flat", val)
end

function facemorph_set_9(actor, val)
    actor:setfacemorph2("facetype_eye_drooping", "facetype_eye_almond", val)
end

function facemorph_set_10(actor, val)
    actor:setfacemorph2("facetype_eyebrow_lower", "facetype_eyebrow_upper", val)
end

function facemorph_set_11(actor, val)
    actor:setfacemorph2("facetype_eyebrow_drooping", "facetype_eyebrow_angry", val)
end

function facemorph_set_12(actor, val)
    actor:setfacemorph2("facetype_eyebrow_winding", "facetype_eyebrow_crescent", val)
end

function facemorph_set_13(actor, val)
    actor:setfacemorph2("facetype_nose_upper", "facetype_nose_lower", val)
end

function facemorph_set_14(actor, val)
    actor:setfacemorph2("facetype_nose_low", "facetype_nose_high", val)
end

function facemorph_set_15(actor, val)
    actor:setfacemorph2("facetype_nose_slim", "facetype_nose_fat", val)
end

function facemorph_set_16(actor, val)
    actor:setfacemorph2("facetype_nose_hooked", "facetype_nose_upturned", val)
end

function facemorph_set_17(actor, val)
    actor:setfacemorph2("facetype_cheek_high", "facetype_cheek_fat", val)
end

function facemorph_set_18(actor, val)
    actor:setfacemorph2("facetype_mouth_lower", "facetype_mouth_upper", val)
end

function facemorph_set_19(actor, val)
    actor:setfacemorph2("facetype_lip_small", "facetype_lip_big", val)
end

function facemorph_set_20(actor, val)
    actor:setfacemorph2("facetype_lip_thin", "facetype_lip_thick", val)
end

function facemorph_set_21(actor, val)
    actor:setfacemorph2("facetype_lip_angry", "facetype_lip_smile", val)
end

function facemorph_set_22(actor, val)
    actor:setfacemorph2("facetype_lip_flat", "facetype_lip_winding", val)
end

function facemorph_set_23(actor, val)
    actor:setfacemorph2("facetype_jaw_higher", "facetype_jaw_lower", val)
end

function facemorph_set_24(actor, val)
    actor:setfacemorph2("facetype_jaw_tough", "facetype_jaw_sharp", val)
end

function facemorph_set_25(actor, val)
    actor:setfacemorph2("facetype_ear_human", "facetype_ear_elf", val)
end
