
function dealrequest_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_DealAccept"}
        msg.playerid = data
        c_send(msg)
    end
end
function SC_DealRequest(msg)
	messagebox_confirm(c_textformat("PLAYER_DEAL_REQUEST", msg.name), dealrequest_confirm, msg.playerid, "UI_ACCEPT", "UI_REFUSE")
end

function SC_DealAccept(msg)
	playerdeal_opendeal(msg)
end

function SC_DealPut(msg)
	playerdeal_onput(msg)
end

function SC_DealLock(msg)
	playerdeal_onlock(msg)
end

function SC_DealSubmit(msg)
	playerdeal_onsubmit(msg)
end

function SC_DealComplete(msg)
	playerdeal_oncomplete(msg)
end

function SC_DealCancel(msg)
	playerdeal_oncancel(msg)
end
