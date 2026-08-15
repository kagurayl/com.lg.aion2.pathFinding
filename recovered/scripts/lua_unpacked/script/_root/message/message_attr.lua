
local attroverlaytype = 
{
    hp = 0,
    mp = 1,
    dp = 2,
    fp = 3,
}

function SC_PlayerSetting(msg)
	local json = {}
	for i=1,#msg.setting do
		local setting = msg.setting[i]
		json[setting.name] = setting.data
	end
	gamesetting_loadplayer(json)
end

function SC_ModifySetting(msg)
	local json = {}
	for i=1,#msg.setting do
		local setting = msg.setting[i]
		json[setting.name] = setting.data
	end
	gamesetting_saved(json)
end

function SC_RenderHelmet(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.renderhelmet = msg.render
		actor:setreloadasset(false)
	end
end

function SC_RenderEmblem(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.renderemblem = msg.render
		actor:setreloadasset(false)
	end
end

function SC_Exp(msg)
	if msg.addexp > 0 then
		chat_addsimple(chatchanneltype.systemexp, textformat_args("STR_GET_EXP2", msg.addexp))
	end
	playerattr_info.exp = msg.playerexp
	actionbar_updateexp()
end

function SC_Level(msg)
	playerquest_updatenpcicon()
	local player = actormanager_getfromactorid(msg.playerid)
	if player ~= nil then
		player.attr.level = msg.level
		vfxmanager_createfxc(FXCLevelUp, player, nil, bit.bor(vfxflag.free, vfxflag.spawnposition), 0, 0)
		if player:isme() then
			playerinfo_updateui()
			actormanager_updatehead()
			actormanager_updateharvesticon()
			actormanager_updatenameplate()
		else
			player:updatenameuilayout()
		end
		selection_updateui()
	end
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.playerid then
			playerattr_pal[i].level = msg.level
			pallist_updateui()
			break
		end
	end
	actionbar_updateexp()
	if m_uimap_main:alive() then
		maplabel_updateui()
	end
end

function SC_Coin(msg)
	if msg.coin == playerattr_info.coin then
		return
	end
	local text = nil
	if msg.coin > playerattr_info.coin then
		text = textformat_args("STR_MSG_GETMONEY", msg.coin - playerattr_info.coin)
	else
		text = textformat_args("STR_MSG_USEMONEY", playerattr_info.coin - msg.coin)
	end
	chat_addsimple(chatchanneltype.systemmoney, text)
	messagealert_addalert(text)
	
	playerattr_info.coin = msg.coin
	audiomanager_playaudioui(AudioItemGetGold)
	event_active(eventtype.item)
end

function SC_Cash(msg)
	if msg.cash == playerattr_info.cash then
		return
	end
	local text = nil
	if msg.cash > playerattr_info.cash then
		text = c_textformat("BAG_PROMPT_ADDCASH", msg.cash - playerattr_info.cash)
	else
		text = c_textformat("BAG_PROMPT_COSTCASH", playerattr_info.cash - msg.cash)
	end
	chat_addsimple(chatchanneltype.systemmoney, text)
	messagealert_addalert(text)

	playerattr_info.cash = msg.cash
	store_updateui()
	event_active(eventtype.item)
end

function SC_CashBack(msg)
	if msg.cashback == playerattr_info.cashback then
		return
	end
	local text = nil
	if msg.cashback > playerattr_info.cashback then
		text = c_textformat("BAG_PROMPT_ADDCASHBACK", msg.cashback - playerattr_info.cashback)
	else
		text = c_textformat("BAG_PROMPT_COSTCASHBACK", playerattr_info.cashback - msg.cashback)
	end
	chat_addsimple(chatchanneltype.systemmoney, text)
	messagealert_addalert(text)

	playerattr_info.cashback = msg.cashback
	event_active(eventtype.item)
end

function SC_Attr(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		for i=1,#msg.attr do
			local attr = msg.attr[i]
			local valname = table.valname(attrservertype, attr.type)
			if valname ~= nil and actor.attr[valname] ~= nil then
				actor.attr[valname] = attr.val
			end
		end
		event_active(eventtype.playerinfo)
	end
end

function SC_AttrHP(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.hp = msg.hp
		event_active_me(actor, eventtype.playerinfo)
	end
end

function SC_AttrMP(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.mp = msg.mp
		event_active_me(actor, eventtype.playerinfo)
	end
end

function SC_AttrDP(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme()  then
			local prev = actor.attr.dp / actor.attr.dpmax
			local current = msg.dp / actor.attr.dpmax
			if prev < 0.5 and current >= 0.5 then
				audiomanager_playaudioui(AudioDP50)
			elseif prev < 1.0 and current >= 1.0 then
				audiomanager_playaudioui(AudioDP100)
			end
		end
		actor.attr.dp = msg.dp
		event_active_me(actor, eventtype.playerinfo)
	end
end

function SC_AttrFP(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() and not actor:isdead() then
			local prev = actor.attr.fp
			local current = msg.fp
			if prev > 15 and current <= 15 then
				audiomanager_playaudioui(AudioFly15)
			elseif prev >=5 and current <= 5 then
				audiomanager_playaudioui(AudioFly5)
			end
		end
		actor.attr.fp = msg.fp
		event_active_me(actor, eventtype.playerinfo)
	end
end

function SC_AttrOverlay(msg)
	local type = nil
	if msg.type == attroverlaytype.hp then
		if msg.number > 0 then
			type = lambdapointtype.hpinc
		elseif msg.number < 0 then
			type = lambdapointtype.hpdec
		end
	elseif msg.type == attroverlaytype.mp then
		if msg.number > 0 then
			type = lambdapointtype.mpinc
		elseif msg.number < 0 then
			type = lambdapointtype.mpdec
		end
	elseif msg.type == attroverlaytype.fp then
		if msg.number > 0 then
			type = lambdapointtype.fpinc
		elseif msg.number < 0 then
			type = lambdapointtype.fpdec
		end
	end
	if type ~= nil then
		overlay_addpoint(m_me, type, nil, math.abs(msg.number))
	end
end

function SC_AttrCareer(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.career = msg.career
	end
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.actorid then
			playerattr_pal[i].career = msg.career
			pallist_updateui()
			break
		end
	end
end

function SC_Tutorial(msg)
	tutorial_setfinish(msg.id)
end
