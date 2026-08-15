
function SC_PalList(msg)
	playerattr_pal = msg.pal
	playerattr_black = msg.black
	pallist_updateui()
end

function SC_PalSearch(msg)
	onpalsearchresult(msg)
end

function SC_PalRequestSend(msg)
	chat_addsystemalert(c_textformat("PAL_REQUEST_SEND", msg.name))
end

function pal_requestrecv_confirm(ok, data)
	local msg = {messageid="CS_PalResponse"}
	msg.playerid = data
	msg.accept = math.ternary(ok, 1, 0)
	c_send(msg)
end
function SC_PalRequestRecv(msg)
	local confirmtext = c_textformat("PAL_REQUEST_TEXT", msg.name)
	messagebox_confirm(confirmtext, pal_requestrecv_confirm, msg.playerid, "PAL_REQUEST_ACCEPT", "PAL_REQUEST_REFUSE")
end

function SC_PalSuccess(msg)
	chat_addsystemalert(c_textformat("PAL_RESPONSE_SUCCESS", msg.name))
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.playerid then
			return
		end
	end
	msg.online = 1
	playerattr_pal[#playerattr_pal + 1] = msg
	pallist_updateui()
end

function SC_PalFailed(msg)
	chat_addsystemalert(c_textformat("PAL_RESPONSE_REFUSE", msg.name))
end

function SC_PalDelete(msg)
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.playerid then
			--chat_addsystemalert(c_textformat("PAL_DELETE_SUCCESS", playerattr_pal[i].name))
			table.remove(playerattr_pal, i)
			pallist_updateui()
			break
		end
	end
end

function SC_PalNote(msg)
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.playerid then
			playerattr_pal[i].note = msg.note
			pallist_updateui()
			break
		end
	end
	for i=1,#playerattr_black do
		if playerattr_black[i].playerid == msg.playerid then
			playerattr_black[i].note = msg.note
			palblacklist_updateui()
			break
		end
	end
end

function SC_PalAddBlackList(msg)
	chat_addsystemalert(c_textformat("PAL_BLACKLIST_SUCCESS", msg.name))
	for i=1,#playerattr_black do
		if playerattr_black[i].playerid == msg.playerid then
			return
		end
	end
	playerattr_black[#playerattr_black + 1] = msg
	palblacklist_updateui()
end

function SC_PalDelBlackList(msg)
	for i=1,#playerattr_black do
		if playerattr_black[i].playerid == msg.playerid then
			chat_addsystemalert(c_textformat("PAL_BLACKLIST_DELSUCCESS", playerattr_black[i].name))
			table.remove(playerattr_black, i)
			palblacklist_updateui()
			break
		end
	end
end

function SC_ReferralSetPlayer(msg)
	playerattr_referralplayername = msg.referralplayername
	chat_addsystemalert(c_textformat("PAL_REFERRALPLAYER_SETINVITESUCCESS", playerattr_referralplayername))
	palreferralplayer_updateui()
end

function SC_ReferralSetMe(msg)
	chat_addsystemalert(c_textformat("PAL_REFERRALPLAYER_SETINVITEME", msg.playername))
end

function SC_ReferralList(msg)
	playerattr_referrallist = msg.referrallist
	if msg.referralplayername ~= nil and #msg.referralplayername > 0 then
		playerattr_referralplayername = msg.referralplayername
	else
		playerattr_referralplayername = nil
	end
	palreferralplayer_updateui()
end
