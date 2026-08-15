
function SC_RedeemList(msg)
	playerattr_redeem = msg.redeem
	shop_updateshop()
end

function SC_StoreLimit(msg)
	store_setlimit(msg.limit)
end

function SC_ItemLimit(msg)
	shop_setlimit(msg.limit)
end

function SC_ShopOpen(msg)
	shop_setshop(msg.actorid, msg.buy, msg.price, msg.shopid, msg.shoptype)
end

function SC_ShopBuy(msg)
	shop_updateshop()
end

function SC_ShopSell(msg)
	shop_updateshop()
end

function SC_StoreBuy(msg)
	store_updateui()
end

function SC_StorePayRequest(msg)
	messagealert_addalert("STORE_PAYMENT_CREATEORDER")
end

function SC_StorePayURL(msg)
	c_httpurl(msg.payurl)
end

function SC_StallPut(msg)
	local bagitem = playerattr_bag[msg.bagslot + 1]
	local stallitem = playerattr_stall[msg.stallslot + 1]
	playeritem_copy(stallitem, bagitem)
	stallitem.price = msg.price
	stallitem.count = msg.count
	stallitem.uuid = msg.uuid
	bagitem.count = bagitem.count - msg.count
	if bagitem.count == 0 then
		bagitem.itemid = 0
	end
	shop_updatestall()
	event_active(eventtype.item)
end

function SC_StallTake(msg)
	local stallitem = playerattr_stall[msg.stallslot + 1]
	local bagitem = playerattr_bag[msg.bagslot + 1]
	playeritem_copy(bagitem, stallitem)
	stallitem.itemid = 0
	shop_updatestall()
	event_active(eventtype.item)
end

function SC_StallMove(msg)
	local stall = playerattr_stall[msg.slot1 + 1]
	playerattr_stall[msg.slot1 + 1] = playerattr_stall[msg.slot2 + 1]
	playerattr_stall[msg.slot2 + 1] = stall
	shop_updatestall()
end

function SC_StallStart(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.posx = msg.x
		actor.attr.posy = msg.y
		actor.attr.posz = msg.z
		actor.attr.rot = msg.rot
		actor.attr.stalladvert = msg.advert
		actor:createstall(msg.advert)
		shop_updatestall()
	end
end

function SC_StallStop(msg)
	local actor = actormanager_getfromactorid(msg.playerid)
	if actor ~= nil then
		actor.attr.stalladvert = nil
		actor:destroystall()
		shop_updatestall()
	end
end

function SC_StallQuery(msg)
	stall_buy_openstall(msg)
end

function SC_StallList(msg)
	playeritem_setstall(msg)
	shop_updatestall()
	if msg.stalltitle ~= nil and #msg.stalltitle > 0 then
		playerattr_info.stalladvert = msg.stalltitle
	end
end

function SC_StallSell(msg)
	local config_item = csvitem_getfromid(msg.itemid)
	if config_item ~= nil then
		local text = textformat_args("STR_MSG_PERSONAL_SHOP_SELL_ITEM_MULTI", config_item.name, msg.count)
		chat_addsystemalert(text)
		stall_mine_addlog(text)
	end
end

function SC_BusinessOpen(msg)
	m_uibusiness_main:open()
	m_uibusiness_main.npcactorid = msg.npcactorid
	m_uibusiness_main.saletax1 = msg.saletax1
	m_uibusiness_main.saletax2 = msg.saletax2
end

function SC_BusinessSellList(msg)
	playerattr_business = msg.item
	business_sell_updateui()
end

function SC_BusinessBillList(msg)
	playerattr_businessbill = msg
	if playerattr_businessbill.item == nil then
		playerattr_businessbill.item = {}
	end
	business_settle_updateui()
	minimapadditive_updateaudit()
end

function SC_BusinessPut(msg)
	local putitem = {}
	putitem.attr = msg.attr
	putitem.date = msg.date
	putitem.price = msg.price
	playerattr_business[#playerattr_business + 1] = putitem
	business_main_updateui()
end

function SC_BusinessPutCoin(msg)
	local putitem = {}
	putitem.attr = {}
	putitem.attr.itemid = itemid_coin
	putitem.attr.count = msg.count
	putitem.attr.uuid = msg.putuuid
	putitem.attr.soul = 0
	putitem.attr.gem = {}
	putitem.attr.subgem = {}
	putitem.date = msg.date
	putitem.price = msg.price
	playerattr_business[#playerattr_business + 1] = putitem
	business_main_updateui()
end

function SC_BusinessTake(msg)
	for i=1,#playerattr_business do
        local item = playerattr_business[i]
        if item.attr.uuid == msg.uuid then
			table.remove(playerattr_business, i)
			business_main_updateui()
			audiomanager_playaudioui(AudioItemDecreased)
            break
        end
    end
end

function SC_BusinessQuery(msg)
	business_query_setitem(msg)
end

function SC_BusinessBuySuccess(msg)
	business_query_buysuccess(msg)
end

function SC_BusinessBuyFailed(msg)
	chat_addsystemalert("BUSINESS_BUY_FAILED")
end

local function business_sellitem(uuid, count)
	for i=1,#playerattr_business do
        local item = playerattr_business[i]
        if item.attr.uuid == uuid then
			local alert = nil
			local itemname = csvitem_getcolornamefromid(item.attr.itemid)
			if item.attr.count <= count then
				alert = c_textformat("BUSINESS_SETTLE_ITEMSELL", itemname)
				table.remove(playerattr_business, i)
			else
				alert = c_textformat("BUSINESS_SETTLE_ITEMSELLCOUNT", itemname, count)
				item.attr.count = item.attr.count - count
			end
			chat_addsystemalert(alert)
			audiomanager_playaudioui(AudioAuctionComplete)
			business_main_updateui()
            break
        end
    end
end
function SC_BusinessSellItem(msg)
	playerattr_businessbill.item[#playerattr_businessbill.item + 1] = msg.item
	if msg.item.attr.itemid == itemid_coin then
		playerattr_businessbill.billcash = playerattr_businessbill.billcash + msg.item.price
	else
		playerattr_businessbill.billcoin = playerattr_businessbill.billcoin + msg.item.price * msg.item.attr.count
	end
	business_sellitem(msg.item.attr.uuid, msg.item.attr.count)
	minimapadditive_updateaudit()
end

function SC_BusinessSellMini(msg)
	if msg.itemid == itemid_coin then
		playerattr_businessbill.billcash = playerattr_businessbill.billcash + msg.price
	else
		playerattr_businessbill.billcoin = playerattr_businessbill.billcoin + msg.price * msg.count
	end
	business_sellitem(msg.uuid, msg.count)
	minimapadditive_updateaudit()
end

function SC_BusinessSellTimeout(msg)
	for i=1,#playerattr_business do
        local item = playerattr_business[i]
        if item.attr.uuid == msg.uuid then
			playerattr_businessbill.item[#playerattr_businessbill.item + 1] = item
			table.remove(playerattr_business, i)
			business_main_updateui()
            break
        end
    end
end

function SC_BusinessSettle(msg)
	
end

function SC_ObsExchangeOpen(msg)
	obs_open(msg.actorid, msg.fullobs)
end

function SC_ObsExchange(msg)
	local text = c_textformat("OBS_TIPS_SUCCESS", msg.obs)
	chat_addsystemalert(text)
	obs_reset()
end

function SC_VIPBuySuccess(msg)
	local text = c_textformat("PLAYER_INFO_VIPSUCCESS", math.tointegerfloor((msg.vipadd + 0.5) / (3600 * 24)))
	chat_addsystemalert(text)
	playerattr_info.viptime = msg.viptime + time_game
	player_main_updateui()
end

function SC_StorePayQueryList(msg)
	store_setorderlist(msg.paylist)
end

function SC_RouletteOpen(msg)
	roulette_open(msg)
end

function SC_RouletteGacha(msg)
	roulette_additem(msg)
end

function SC_RouletteLog(msg)
	roulette_setlog(msg)
end

function SC_RouletteNotify(msg)
	local text = c_textformat("ROULETTE_LOG_PLAYER", msg.playername, csvitem_getcolornamefromid(msg.itemid))
	chat_addsystemalert(text)
end
