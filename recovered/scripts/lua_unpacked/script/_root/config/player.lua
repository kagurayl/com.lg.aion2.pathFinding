
playerlevel_max = 55
playerlevel_strong = 5
playerlevel_weak = -5
playerlevel_npcverystrong = 2
playerlevel_npcstrong = 0
playerlevel_npcweak = -1
playerlevel_npcveryweak = -3

max_logo = 19

playerspellstate =
{
    spellskill = 1,
    spellcast = 2,
    spellitem = 3,
    spellitembind = 4,
    spellitembindend = 5,
    spellquest = 6,
    spellconvert = 7,
    spellgather = 8,
    spellgathercomplete = 9,
    spellcrafting = 10,
    spellcraftingcomplete = 11,
    spellsocial = 12,
    petplay = 13,
    enchantspell = 14,
    enchantsuccess = 15,
    enchantfail = 16,
}


playerciv =
{
    light = 0,
    dark = 1,
    pc = 2,
    npc = 3,
    tricolight = 4,
    tricodark = 5,
    lycan = 6,
    construct = 7,
    carrier = 8,
    drakan = 9,
    lizardman = 10,
    teleporter = 11,
    naga = 12,
    brownie = 13,
    krall = 14,
    shulack = 15,
    barrier = 16,
    pc_light_castle_door = 17,
    pc_dark_castle_door = 18,
    dragon_castle_door = 19,
    gchief_light = 20,
    gchief_dark = 21,
    dragon = 22,
    outsider = 23,
    ratman = 24,
    demihumanoid = 25,
    undead = 26,
    beast = 27,
    magicalmonster = 28,
    elemental = 29,
    neut = 30,
    livingwater = 31,
    goblin = 32,
    ghenchman_light = 33,
    ghenchman_dark = 34,
    ghenchman_dragon = 35,
}

playercareer =
{
    warrior = 1,
    cleric = 2,
    scout = 3,
    mage = 4,
    fighter = 5,
    knight = 6,
    priest = 7,
    chanter = 8,
    assassin = 9,
    ranger = 10,
    wizard = 11,
    elementallist = 12,
    count = 12,
}

playermovestate =
{
    move = 0,
    glide = 1,
    fly = 2,
    rest = 3,
}

playermoveflag =
{
    falling = 0x1,
    glidedown = 0x2,
}

playersex =
{
    male = 1,
    female = 2,
}

playercivtext =
{
    [playerciv.light] = "UI_CIVNAME_ELF",
    [playerciv.dark] = "UI_CIVNAME_DARK",
    [playerciv.dragon] = "UI_CIVNAME_DRAGON",
}

playercareertext =
{
    "UI_CAREER_WARRIOR",
    "UI_CAREER_CLERIC",
    "UI_CAREER_SCOUT",
    "UI_CAREER_MAGE",
    "UI_CAREER_FIGHTER",
    "UI_CAREER_KNIGHT",
    "UI_CAREER_PRIEST",
    "UI_CAREER_CHANTER",
    "UI_CAREER_ASSASSIN",
    "UI_CAREER_RANGER",
    "UI_CAREER_WIZARD",
    "UI_CAREER_ELEMENTALIST",
}

playercareericon =
{
    "emblem/icon_emblem_warrior",
    "emblem/icon_emblem_cleric",
    "emblem/icon_emblem_scout",
    "emblem/icon_emblem_mage",
    "emblem/icon_emblem_fighter",
    "emblem/icon_emblem_knight",
    "emblem/icon_emblem_priest",
    "emblem/icon_emblem_chanter",
    "emblem/icon_emblem_assassin",
    "emblem/icon_emblem_ranger",
    "emblem/icon_emblem_wizard",
    "emblem/icon_emblem_elementalist",
}

function getplayercivtext(civ)
    return playercivtext[civ]
end

function playercareeravailable(filter, career)
    if filter == 0 then
        return true
    end
    local playercareerbit = bit.lshift(1, career - 1)
    return bit.band(filter, playercareerbit) ~= 0
end

function playercareeradvance(career)
    return career > playercareer.mage
end

function playercareerbase(career)
    if career == playercareer.fighter or career == playercareer.knight then
        return playercareer.warrior
    elseif career == playercareer.priest or career == playercareer.chanter then
        return playercareer.cleric
    elseif career == playercareer.assassin or career == playercareer.ranger then
        return playercareer.scout
    elseif career == playercareer.wizard or career == playercareer.elementallist then
        return playercareer.mage
    end
    return career
end

function playercivavailable(filter, civ)
    if filter == 1 and civ == playerciv.light then
        return true
    end
    if filter == 2 and civ == playerciv.dark then
        return true
    end
    if filter == 3 then
        return true
    end
    return false
end

function actoridisplayer(actorid)
    return actorid > 0
end
