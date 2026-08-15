
animlist = nil
animblendin = 0.3
animblendout = 0.3

local m_animlist_weapon = {"noweapon", "2weapon", "mace", "dagger", "1hand", "2hand", "polearm", "staff", "bow", "book", "orb"}
local m_animlistid = 0

function animlist_init()
    animlist = {}
    animlist_addsimple("cattack1", "cattack", actoranimpart.weapon, 1)
    animlist_addsimple("xattack1", "xattack", actoranimpart.weapon, 1)
    animlist_addsimple("cattack2", "cattack", actoranimpart.weapon, 2)
    animlist_addsimple("xattack2", "xattack", actoranimpart.weapon, 2)
    animlist_addsimple("cattack3", "cattack", actoranimpart.weapon, 3)
    animlist_addsimple("xattack3", "xattack", actoranimpart.weapon, 3)

    animlist_addsimple("windpath", "fwindpath", 0)
    animlist_addsimple("windpathdash", "fwindpathdash", 0)
    animlist_addsimple("ridle", "ridle", 0)
    animlist_addsimple("stall", "ridle", bit.bor(actoranimpart.career, actoranimpart.shop))
    animlist_addsimple("rsit", "rsit", 0)
    animlist_addsimple("nstand", "nstand", 0)
    animlist_addsimple("sitchair", "rsitdown_chair", 0)
    animlist_addsimple("standchair", "nstandup_chair", 0)
    animlist_addsimple("idlechair", "ridle_chair", 0)
    animlist_addsimple("loot", "nloot", 0)
    animlist_addsimple("nalive", "nresurrection", 0)
    animlist_addsimple("falive", "fresurrection", 0)
    animlist_addsimple("teleportin", "nteleport_in_city", 0)
    animlist_addsimple("teleportout", "nteleport_out_city", 0)
    animlist_addsimple("teleportreturn", "nteleport_return", 0)
    
    animlist_addsimple("npcdead1", "cdie", actoranimpart.weapon)
    animlist_addsimple("npcdead2", "ndie", 0)
    animlist_addsimple("npcspawn", "nspawn", 0)
    animlist_addsimple("npcdespawn", "ndespawn", 0)
    animlist_add("npcidle", "nidle", 0, "cidle", actoranimpart.weapon)
    animlist_add("fidle", "fidle", 0, "fidle", 0)
    animlist_add("nidle", "nidle", 0, "cidle", bit.bor(actoranimpart.career, actoranimpart.weapon))
    animlist_add("ndead", "ndie", 0, "cdie", actoranimpart.weapon)
    animlist_add("fdead", "fdie", 0, "xdie", actoranimpart.weapon)
    animlist_add("ndodge", "ndodge", 0, "cdodge", actoranimpart.weapon)
    animlist_add("nparry", "nparray", 0, "cparry", actoranimpart.weapon)
    animlist_add("ndamage", "ndamage", 0, "cdamage", actoranimpart.weapon)
    animlist_add("fdodge", "fdodge", 0, "xdodge", actoranimpart.weapon)
    animlist_add("fparry", "fparry", 0, "xparry", actoranimpart.weapon)
    animlist_add("fdamage", "fdamage", 0, "xdamage", actoranimpart.weapon)
    animlist_add("nstun", "nstun", 0, "cstun", actoranimpart.weapon)
    animlist_add("fstun", "fstun", 0, "xstun", actoranimpart.weapon)
    animlist_add("stumblestart", "nstumble_start", 0, "cstumble_start", actoranimpart.weapon)
    animlist_add("stumbleloop", "nstumble", 0, "cstumble", actoranimpart.weapon)
    animlist_add("stumbleend", "nstumble_end", 0, "cstumble_end", actoranimpart.weapon)
    animlist_add("aerialstart", "naerial_start", 0, "caerial_start", actoranimpart.weapon)
    animlist_add("aerialloop", "naerial", 0, "caerial", actoranimpart.weapon)
    animlist_add("aerialend", "naerial_end", 0, "caerial_end", actoranimpart.weapon)
    animlist_add("weapon", "nputin", actoranimpart.weapon, "cdraw", actoranimpart.weapon)
    animlist_add("weaponmove", "nputin", bit.bor(actoranimpart.weapon, actoranimpart.type), "cdraw", bit.bor(actoranimpart.weapon, actoranimpart.type), 1, 1, "run", "run")
    animlist_add("flyf", "fflyf", 0, "xflyf", actoranimpart.weapon)
    animlist_add("flyb", "fflyb", 0, "xflyb", actoranimpart.weapon)
    animlist_add("flyl", "fflyl", 0, "xflyl", actoranimpart.weapon)
    animlist_add("flyr", "fflyr", 0, "xflyr", actoranimpart.weapon)
    animlist_add("flyu", "fflyu", 0, "xflyu", actoranimpart.weapon)
    animlist_add("flyd", "fflyd", 0, "xflyd", actoranimpart.weapon)
    animlist_add("glide", "fglide", 0, "xglide", actoranimpart.weapon)
    animlist_addsimple("glidedown", "fglidedown", 0)
    animlist_add("run", "nrun", 0, "crun", actoranimpart.weapon)
    animlist_add("runb", "nrunb", 0, "crunb", actoranimpart.weapon)
    animlist_add("runl", "nrunl", 0, "crunl", actoranimpart.weapon)
    animlist_add("runr", "nrunr", 0, "crunr", actoranimpart.weapon)
    animlist_add("hiderun", "nrun", actoranimpart.type, "crun", bit.bor(actoranimpart.weapon, actoranimpart.type), 1, 1, "hide", "hide")
    animlist_add("hiderunb", "nrunb", actoranimpart.type, "crunb", bit.bor(actoranimpart.weapon, actoranimpart.type), 1, 1, "hide", "hide")
    animlist_add("hiderunl", "nrunl", actoranimpart.type, "crunl", bit.bor(actoranimpart.weapon, actoranimpart.type), 1, 1, "hide", "hide")
    animlist_add("hiderunr", "nrunr", actoranimpart.type, "crunr", bit.bor(actoranimpart.weapon, actoranimpart.type), 1, 1, "hide", "hide")
    animlist_addsimple("walk", "nwalk", 0)
    animlist_addsimple("walkb", "nwalkb", 0)
    animlist_addsimple("walkl", "nwalkl", 0)
    animlist_addsimple("walkr", "nwalkr", 0)
    animlist_addsimple("hideidle", "nidle_hide", 0)
    animlist_addsimple("hidewalk", "nwalk_hide", 0)
    animlist_addsimple("hidewalkb", "nwalkb_hide", 0)
    animlist_addsimple("hidewalkl", "nwalkl_hide", 0)
    animlist_addsimple("hidewalkr", "nwalkr_hide", 0)
    animlist_add("jumpstart", "njump_start", 0, "cjump_start", actoranimpart.weapon)
    animlist_add("jumpair", "njump_air", 0, "cjump_air", actoranimpart.weapon)
    animlist_add("jumpend", "njump_end", 0, "cjump_end", actoranimpart.weapon)

    animlist_addsimple("gatheringstart_gathering_a", "ngatheringstart_gathering_a", 0)
    animlist_addsimple("gatheringstart_gathering_b", "ngatheringstart_gathering_b", 0)
    animlist_addsimple("gathering_gathering_a", "ngathering_gathering_a", 0)
    animlist_addsimple("gathering_gathering_b", "ngathering_gathering_b", 0)
    animlist_addsimple("gathering_succ_gathering_a", "ngathering_succ_gathering_a", 0)
    animlist_addsimple("gathering_succ_gathering_b", "ngathering_succ_gathering_b", 0)
    animlist_addsimple("gathering_fail_gathering_a", "ngathering_fail_gathering_a", 0)
    animlist_addsimple("gathering_fail_gathering_b", "ngathering_fail_gathering_b", 0)
    animlist_addsimple("convert", "ncraftstart_convert", 0)
    animlist_addsimple("cookingloop", "ncraft_cooking", 0)
    animlist_addsimple("cooking", "ncraftstart_cooking", 0)
    animlist_addsimple("cookingloop", "ncraft_cooking", 0)
    animlist_addsimple("cookingsucc", "ncraft_succ_cooking", 0)
    animlist_addsimple("cookingfail", "ncraft_fail_cooking", 0)
    animlist_addsimple("wsmith", "ncraftstart_wsmith", 0)
    animlist_addsimple("wsmithloop", "ncraft_wsmith", 0)
    animlist_addsimple("wsmithsucc", "ncraft_succ_wsmith", 0)
    animlist_addsimple("wsmithfail", "ncraft_fail_wsmith", 0)
    animlist_addsimple("asmith", "ncraftstart_asmith", 0)
    animlist_addsimple("asmithloop", "ncraft_asmith", 0)
    animlist_addsimple("asmithsucc", "ncraft_succ_asmith", 0)
    animlist_addsimple("asmithfail", "ncraft_fail_asmith", 0)
    animlist_addsimple("tailoring", "ncraftstart_tailoring", 0)
    animlist_addsimple("tailoringloop", "ncraft_tailoring", 0)
    animlist_addsimple("tailoringsucc", "ncraft_succ_tailoring", 0)
    animlist_addsimple("tailoringfail", "ncraft_fail_tailoring", 0)
    animlist_addsimple("alchemy", "ncraftstart_alchemy", 0)
    animlist_addsimple("alchemyloop", "ncraft_alchemy", 0)
    animlist_addsimple("alchemysucc", "ncraft_succ_alchemy", 0)
    animlist_addsimple("alchemyfail", "ncraft_fail_alchemy", 0)
    animlist_addsimple("handiwork", "ncraftstart_handiwork", 0)
    animlist_addsimple("handiworkloop", "ncraft_handiwork", 0)
    animlist_addsimple("handiworksucc", "ncraft_succ_handiwork", 0)
    animlist_addsimple("handiworkfail", "ncraft_fail_handiwork", 0)
    animlist_addsimple("soulbind_start", "nsoulbind_start", 0)
    animlist_addsimple("soulbind", "nsoulbind", 0)
    animlist_addsimple("soulbind_end", "nsoulbind_end", 0)

    animlist_add("subfidle", "fidle", 0, "xidle", actoranimpart.weapon)
    animlist_add("subnidle", "nidle", 0, "cidle", actoranimpart.weapon)
end

function animlist_addsimple(name, anim, flag, index)
    animlist_add(name, anim, flag, anim, flag, index, index)
end

function animlist_add(name, anim, flag, battleanim, battleflag, index, battleindex, type, battletype)
    m_animlistid = m_animlistid + 1
    local animname = {}
    animname.id = m_animlistid
    animname.anim = anim
    animname.flag = flag
    animname.battleanim = battleanim
    animname.battleflag = battleflag
    animname.index = index
    animname.battleindex = battleindex
    animname.type = type
    animname.battletype = battletype
    animlist[name] = animname
end

function animlist_getanim(name, flag, career, weapon, type, index)
    c_textclearbuffer()
    c_textappendbuffer(name)
    if career ~= nil then
        c_textappendbuffer("_")
        c_textappendbuffer(career)
    end
    if weapon ~= nil then
        c_textappendbuffer("_")
        c_textappendbuffer(weapon)
    end
    if type ~= nil then
        c_textappendbuffer("_")
        c_textappendbuffer(type)
    end
    if bit.band(flag, actoranimpart.shop) ~= 0 then
        c_textappendbuffer("_shop")
    end
    if index == 1 then
        c_textappendbuffer("_001")
    else
        c_textappendbuffer(string.format("_%03d", index))
    end
    return c_textgetbuffer()
end
