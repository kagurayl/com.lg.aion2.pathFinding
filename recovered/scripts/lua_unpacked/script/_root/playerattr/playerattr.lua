include("playerattr/playeritem")
include("playerattr/playerskill")
include("playerattr/playerskillpreset")
include("playerattr/playerpal")
include("playerattr/playerquest")
include("playerattr/systemskill")
include("playerattr/playerbattle")
include("playerattr/playerbattleauto")
include("playerattr/playerapproach")
include("playerattr/playerpetattr")
include("playerattr/playerfogmask")

attrservertype =
{
	str = 0,
	vit = 1,
	agi = 2,
	dex = 3,
	kno = 4,
	wil = 5,
	aurarange = 6,
	magtime = 7,
	debuffconcent = 8,
	attackspeed = 9,
	attackrange = 10,
	damagemin = 11,
	damagemax = 12,
	accuracy = 13,
	hpmax = 14,
	hpregen = 15,
	mpmax = 16,
	mpregen = 17,
	mpcost = 18,
	dpmax = 19,
	fpmax = 20,
	fpregen = 21,
	movespeed = 22,
	flyspeed = 23,
	heal = 24,
	threat = 25,
	stability = 26,
	pvpdamage = 27,
	pvpdefense = 28,
	phydamage = 29,
	phyaccuracy = 30,
	phycritrate = 31,
	phycritcoef = 32,
	phycritresist = 33,
	phycritdefense = 34,
	phydefense = 35,
	phydodge = 36,
	phyparry = 37,
	phyblock = 38,
	phyblockreduce = 39,
	phyblockmax = 40,
	magspeed = 41,
	magboost = 42,
	magconcent = 43,
	magdamage = 44,
	magaccuracy = 45,
	magcritrate = 46,
	magcritcoef = 47,
	magcritresist = 48,
	magcritdefense = 49,
	magdefense = 50,
	magresist = 51,
	magearthdefense = 52,
	magwaterdefense = 53,
	magfiredefense = 54,
	magwinddefense = 55,
	all_ar = 56,
	all_arp = 57,
	all_immunity = 58,
	paralyze_ar = 59,
	paralyze_arp = 60,
	paralyze_immunity = 61,
	petrification_ar = 62,
	petrification_arp = 63,
	petrification_immunity = 64,
	stumble_ar = 65,
	stumble_arp = 66,
	stumble_immunity = 67,
	stun_ar = 68,
	stun_arp = 69,
	stun_immunity = 70,
	stagger_ar = 71,
	stagger_arp = 72,
	stagger_immunity = 73,
	spin_ar = 74,
	spin_arp = 75,
	spin_immunity = 76,
	openaerial_ar = 77,
	openaerial_arp = 78,
	openaerial_immunity = 79,
	pull_ar = 80,
	pull_arp = 81,
	pull_immunity = 82,
	deform_ar = 83,
	deform_arp = 84,
	deform_immunity = 85,
	charm_ar = 86,
	charm_arp = 87,
	charm_immunity = 88,
	fear_ar = 89,
	fear_arp = 90,
	fear_immunity = 91,
	confuse_ar = 92,
	confuse_arp = 93,
	confuse_immunity = 94,
	sleep_ar = 95,
	sleep_arp = 96,
	sleep_immunity = 97,
	silence_ar = 98,
	silence_arp = 99,
	silence_immunity = 100,
	bind_ar = 101,
	bind_arp = 102,
	bind_immunity = 103,
	root_ar = 104,
	root_arp = 105,
	root_immunity = 106,
	snare_ar = 107,
	snare_arp = 108,
	snare_immunity = 109,
	slow_ar = 110,
	slow_arp = 111,
	slow_immunity = 112,
	blind_ar = 113,
	blind_arp = 114,
	blind_immunity = 115,
	poison_ar = 116,
	poison_arp = 117,
	poison_immunity = 118,
	bleed_ar = 119,
	bleed_arp = 120,
	bleed_immunity = 121,
	disease_ar = 122,
	disease_arp = 123,
	disease_immunity = 124,
	curse_ar = 125,
	curse_arp = 126,
	curse_immunity = 127,
}

playerattr_info = nil
playerattr_pvp = nil
playerattr_titlelist = nil
playerattr_petlist = nil
playerattr_dungeon = nil
playerattr_logo = nil

function playerattr_clear()
    playerattr_info = {}
	playerattr_pvp = {}
	playerattr_titlelist = {}
	playerattr_petlist = {}
	playerattr_dungeon = {}
	playerattr_logo = {}
    playerattr_set({})
end

function playerattr_set(msg)
	playerattr_info.actorid = msg.playerid
	playerattr_info.spiritid = msg.spiritid
	playerattr_info.spiritstate = msg.spiritstate
	playerattr_info.tutorial = msg.tutorial or 0
	playerattr_info.viptime = time_game + (msg.viptime or 0)
	playerattr_info.areafly = msg.areafly or 0
	playerattr_info.areapvp = msg.areapvp or 0

	playerattr_info.posx = msg.posx or 0
	playerattr_info.posy = msg.posy or 0
	playerattr_info.posz = msg.posz or 0
	playerattr_info.rot = msg.rot or 0

	playerattr_info.resurrectid = msg.resurrectid or 0
    playerattr_info.mapid = msg.mapid or 0
    playerattr_info.name = msg.name or ""
	playerattr_info.coin = msg.coin or 0
	playerattr_info.cash = msg.cash or 0
	playerattr_info.cashback = msg.cashback or 0
	playerattr_info.moverun = msg.moverun or 0
	playerattr_info.movetype = msg.movetype or 0
	playerattr_info.movespeed = msg.movespeed or 0
	playerattr_info.flyspeed = msg.flyspeed or playerattr_info.movespeed
	playerattr_info.battery = msg.battery or 0
	playerattr_info.equipindex = msg.equipindex or 0

	playerattr_info.civ = msg.civ or playerciv.light
	playerattr_info.tribe = csvnpctribe_getfromid(msg.tribe)
	playerattr_info.sex = msg.sex or playersex.male
	playerattr_info.voice = msg.voice or 0
	playerattr_info.career = msg.career or playercareer.warrior

	if msg.skin ~= nil then
		csvrender_skintoattr(playerattr_info, msg.skin)
	end

	playerattr_info.qskactorid = msg.qskactorid or 0
	playerattr_info.qskmember = msg.qskmember or 0
	playerattr_info.qskremain = msg.qskremain or 0
	playerattr_info.qsktime = time_game + (msg.qsktime or 0)

	playerattr_info.animidle = msg.animidle
	playerattr_info.animrun = msg.animrun
	playerattr_info.animjump = msg.animjump
	playerattr_info.animrest = msg.animrest
	playerattr_info.animidlekey = csvanimcard_getkey(playerattr_info.animidle)
	playerattr_info.animrunkey = csvanimcard_getkey(playerattr_info.animrun)
	playerattr_info.animjumpkey = csvanimcard_getkey(playerattr_info.animjump)
	playerattr_info.animrestkey = csvanimcard_getkey(playerattr_info.animrest)

	playerattr_info.questresetday = msg.questresetday or 0
	playerattr_info.questresetweek = msg.questresetweek or 0
	playerattr_info.faction = msg.faction or 0
	playerattr_info.fatigue = msg.fatigue or 0
	playerattr_info.exp = msg.exp or 0
	playerattr_info.explost = msg.explost or 0
	playerattr_info.level = msg.level or 1
	playerattr_info.hp = msg.hp or 1
	playerattr_info.mp = msg.mp or 1
	playerattr_info.dp = msg.dp or 1
	playerattr_info.fp = msg.fp or 1

	playerattr_info.hpmax = msg.hpmax or 1
	playerattr_info.hpregen = msg.hpregen or 0
	playerattr_info.mpmax = msg.mpmax or 1
	playerattr_info.mpregen = msg.mpregen or 0
	playerattr_info.mpcost = msg.mpcost or 0
	playerattr_info.dpmax = msg.dpmax or 1
	playerattr_info.fpmax = msg.fpmax or 1
	playerattr_info.stability = msg.stability or 0
	playerattr_info.heal = msg.heal or 0
	playerattr_info.threat = msg.threat or 0
	playerattr_info.pvpdamage = msg.pvpdamage or 0
	playerattr_info.pvpdefense = msg.pvpdefense or 0

	playerattr_info.attackspeed = msg.attackspeed or 0
	playerattr_info.attackrange = msg.attackrange or 0
	playerattr_info.damagemin = msg.damagemin or 0
	playerattr_info.damagemax = msg.damagemax or 0
	playerattr_info.accuracy = msg.accuracy or 0
	playerattr_info.phydamage = msg.phydamage or 0
	playerattr_info.phyaccuracy = msg.phyaccuracy or 0
	playerattr_info.phycritrate = msg.phycritrate or 0
	playerattr_info.phycritresist = msg.phycritresist or 0
	playerattr_info.phycritdefense = msg.phycritdefense or 0
	playerattr_info.phydefense = msg.phydefense or 0
	playerattr_info.phydodge = msg.phydodge or 0
	playerattr_info.phyparry = msg.phyparry or 0
	playerattr_info.phyblock = msg.phyblock or 0

	playerattr_info.magspeed = msg.magspeed or 0
	playerattr_info.magboost = msg.magboost or 0
	playerattr_info.magconcent = msg.magconcent or 0
	playerattr_info.magdamage = msg.magdamage or 0
	playerattr_info.magaccuracy = msg.magaccuracy or 0
	playerattr_info.magcritrate = msg.magcritrate or 0
	playerattr_info.magcritresist = msg.magcritresist or 0
	playerattr_info.magcritdefense = msg.magcritdefense or 0
	playerattr_info.magresist = msg.magresist or 0
	playerattr_info.magdefense = msg.magdefense or 0
	playerattr_info.magearthdefense = msg.magearthdefense or 0
	playerattr_info.magwaterdefense = msg.magwaterdefense or 0
	playerattr_info.magfiredefense = msg.magfiredefense or 0
	playerattr_info.magwinddefense = msg.magwinddefense or 0
end

function playerattr_getpet(uuid)
	for i=1,#playerattr_petlist do
		if playerattr_petlist[i].uuid == uuid then
			return playerattr_petlist[i]
		end
	end
end

function playerattr_isvehicle()
	return m_me ~= nil and m_me.actionmain.buffvehicle ~= nil
end

function playerattr_getpvptitlename(civ, pvptitle)
	if civ == playerciv.light then
		return c_textformat("PLAYER_PVPLEVEL_LIGHT" .. pvptitle)
	else
		return c_textformat("PLAYER_PVPLEVEL_DARK" .. pvptitle)
	end
end
