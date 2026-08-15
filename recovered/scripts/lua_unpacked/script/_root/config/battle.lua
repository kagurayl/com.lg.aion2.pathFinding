
lambdaaccuracytype =
{
    normal = 0,
    crit = 1,
    dodge = 2,
    parry = 3,
    block = 4,
    resist = 5,
	shield = 6,
	protect = 7,
}

lambdapointtype =
{
    hpinc = 0,
    hpdec = 1,
    mpinc = 2,
    mpdec = 3,
    dpinc = 4,
    dpdec = 5,
	fpinc = 6,
	fpdec = 7,
	heal = 8,
	mpheal = 9,
	mpatk = 10,
	dpheal = 11,
	fpheal = 12,
	fpatk = 13,
	procheal = 14,
	procmpheal = 15,
	procdpheal = 16,
	procfpheal = 17,
	dashatk = 18,
	backdashatk = 19,
	dashbehindatk = 20,
	signetcarve = 21,
	signetburst = 22,
	fall = 23,
	spellatknodefense = 24,
	deathblow = 25,
	dispelbuffatk = 26,
	procatk = 27,
	skillatk = 28,
	skillatkdrain = 29,
	spellatk = 30,
	spellatkdrain = 31,
	pull = 32,
}

buffpointtype =
{
    hpinc = 0,
    hpdec = 1,
    mpinc = 2,
    mpdec = 3,
    dpinc = 4,
    dpdec = 5,
	fpinc = 6,
    fpdec = 7,
	heal = 8,
	mpheal = 9,
	mpatk = 10,
	dpheal = 11,
	fpheal = 12,
	fpatk = 13,
	reflector = 14,
	counteratk = 15,
	spellatk = 16,
	delayspellatk = 17,
	delayfpatk = 18,
	spellatkdrain = 19,
	healcasterteamonhurt = 20,
	healcasterondead = 21,
	convertheal = 22,
	convertmpheal = 23,
}

dispeltype =
{
	normal = 0,
	normaltype = 1,
	normalid = 2,
    buff = 3,
    bufftype = 4,
    buffid = 5,
    debuff = 6,
    debuffphy = 7,
    debuffmag = 8,
	npcbuff = 9,
    npcdebuff = 10,
}

function pointtype_ishp(type)
	if type == lambdapointtype.hpinc
	or type == lambdapointtype.hpdec then
		return true
	end
	return false
end

function pointtype_ismp(type)
	if type == lambdapointtype.mpinc
	or type == lambdapointtype.mpdec then
		return true
	end
	return false
end

function pointtype_isdp(type)
	if type == lambdapointtype.dpinc
	or type == lambdapointtype.dpdec then
		return true
	end
	return false
end

function pointtype_isfp(type)
	if type == lambdapointtype.fpinc
	or type == lambdapointtype.fpdec then
		return true
	end
	return false
end

function pointtype_ishurt(type)
	if type == lambdapointtype.hpdec
	or type == lambdapointtype.mpdec
    or type == lambdapointtype.dpdec then
		return true
	end
	return false
end
