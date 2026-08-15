
local m_chat_list = {}
local m_chat_chatcount = 0
local m_chat_systemcount = 0
local m_chat_histroyid = 0

function chat_reset()
	m_chat_list = {}
	m_chat_chatcount = 0
	m_chat_systemcount = 0
end

function chat_getchatlist()
	return m_chat_list
end

function chat_addchat(senderid, sendername, whisperid, whispername, type, text, equip)
	m_chat_histroyid = m_chat_histroyid + 1
	local chat = {}
	chat.histroyid = m_chat_histroyid
	chat.senderid = senderid
	chat.sendername = sendername
	chat.whisperid = whisperid
	chat.whispername = whispername
	chat.type = type
	chat.text = text
	chat.equip = equip
	m_chat_list[#m_chat_list + 1] = chat
	local removehistroyid = 0
	if type < chatchanneltype.categorysystem then
		m_chat_chatcount = m_chat_chatcount + 1
		if m_chat_chatcount > chathistroy_chat then
			for i=1,#m_chat_list do
				if m_chat_list[i].type < chatchanneltype.categorysystem then
					removehistroyid = m_chat_list[i].histroyid
					table.remove(m_chat_list, i)
					m_chat_chatcount = m_chat_chatcount - 1
					break
				end
			end
		end
	else
		m_chat_systemcount = m_chat_systemcount + 1
		if m_chat_systemcount > chathistroy_system then
			for i=1,#m_chat_list do
				if m_chat_list[i].type >= chatchanneltype.categorysystem then
					removehistroyid = m_chat_list[i].histroyid
					table.remove(m_chat_list, i)
					m_chat_systemcount = m_chat_systemcount - 1
					break
				end
			end
		end
	end
	chatbox_addchat(chat, removehistroyid)
	minichat_addchat(chat, removehistroyid)
	if type == chatchanneltype.chathowlciv or type == chatchanneltype.chathowlall then
		messagealert_showhowl(chat)
	end
end

function chat_addsimple(channel, text)
	chat_addchat(0, nil, 0, nil, channel, text, nil)
end

function chat_addsystem(text)
	chat_addchat(0, nil, 0, nil, chatchanneltype.systeminfo, text, nil)
end

function chat_addsystemalert(text)
	chat_addchat(0, nil, 0, nil, chatchanneltype.systeminfo, text, nil)
	messagealert_addalert(text)
end

function SC_Chat(msg)
	if not playerpal_inblacklist(msg.senderid) then
		local actor = actormanager_getfromactorid(msg.senderid)
		if actor ~= nil and actor:nameplatevisible() then
			actor:createchatbubble(msg.text, msg.equip)
		end
	end
	if msg.type == chatchanneltype.chatsendwhisper and msg.senderid ~= playerattr_info.actorid then
		msg.type = chatchanneltype.chatrecvwhisper
		audiomanager_playaudioui(AudioWhisper)
	end
	chat_addchat(msg.senderid, msg.sendername, msg.whisperid, msg.whispername, msg.type, msg.text, msg.equip)
	chatinput_updateui()
end

function SC_Alert(msg)
	local str = c_textformat("SERVER_" .. msg.id)
	chat_addsystemalert(str)
end

function SC_NPCSay(msg)
	if c_textkey(msg.key) then
		local actor = actormanager_getfromactorid(msg.actorid)
		if actor ~= nil then
			local channeltype = chatchanneltype.chatnpcsidpid
			if actor:isenemy() then
				channeltype = chatchanneltype.chatnpcenemy
			end
			local text = c_textformat(msg.key)
			actor:createchatbubble(text)
			chat_addchat(msg.actorid, actor.attr.name, 0, nil, channeltype, text, nil)
		end
	end
end
