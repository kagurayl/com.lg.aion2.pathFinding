
function SC_MatchSync(msg)
	if msg.type > 0 then
		if msg.timeenter > 0 then
			matching_setenter(msg.type, msg.timeenter)
			actionbar_updatenotify()
		else
			matching_set(msg.type)
			actionbar_updatenotify()
		end
	end
end

function SC_MatchStart(msg)
	matching_set(msg.type)
	matching_open()
	actionbar_updatenotify()
end

function SC_MatchAbort(msg)
	if msg.type == matching_type.arena50solo or msg.type == matching_type.arena55solo then
		chat_addsystemalert("MATCHING_ARENA_SOLO_ABORT")
	elseif msg.type == matching_type.arena50free or msg.type == matching_type.arena55free then
		chat_addsystemalert("MATCHING_ARENA_FREE_ABORT")
	elseif msg.type == matching_type.dredgion50random or msg.type == matching_type.dredgion55random then
		chat_addsystemalert("MATCHING_DREDGION_RANDOM_ABORT")
	elseif msg.type == matching_type.dredgion50team or msg.type == matching_type.dredgion55team then
		chat_addsystemalert("MATCHING_DREDGION_TEAM_ABORT")
	end
	matching_close()
end

function SC_MatchSuccess(msg)
	matching_setenter(msg.type, msg.time)
	audiomanager_playaudioui(AudioMatchNotice)
end

function SC_MatchEnter(msg)
	matching_close()
end

function SC_MatchCancel(msg)
	matching_close()
end
