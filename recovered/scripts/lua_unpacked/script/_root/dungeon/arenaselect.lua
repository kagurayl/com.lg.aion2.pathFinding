
function arenaselect_solo_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_MatchStart"}
		if playerattr_info.level > 50 then
    	    msg.type = matching_type.arena55solo
		else
	        msg.type = matching_type.arena50solo
		end
        c_send(msg)
    end
end

function arenaselect_free_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_MatchStart"}
		if playerattr_info.level > 50 then
    	    msg.type = matching_type.arena55free
		else
	        msg.type = matching_type.arena50free
		end
        c_send(msg)
    end
end

function arenaselect(actorid)
	local npc = actormanager_getfromactorid(actorid)
	if npc == nil then
		return false
	end
    local script = csvnpc_getscript(npc.config_npc, "pattern")
    if script == nil then
		return false
    end
	local name = script.variable[1].str
	if name == "idarena_pvp02_door" then
		messagebox_confirm("ARENAPVP_SOLOCONFIRM", arenaselect_solo_confirm)
		return true
	elseif name == "idarena_pvp01_door" then
		messagebox_confirm("ARENAPVP_FREECONFIRM", arenaselect_free_confirm)
		return true
	end
	return false
end
