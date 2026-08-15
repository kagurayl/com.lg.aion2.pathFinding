
local m_minichat_inst = {chat = "home/inst_minichat"}
m_uiminichat = uipanel_createhandle("home/minichat", uilayer.bottom, uiflag.scale)

function minichat_onopen()
	m_uiminichat.list_chat = m_uiminichat:getwidget("list_chat")
    m_uiminichat.list_chat:init(bit.bor(uilistflag.vertical, uilistflag.async))
    m_uiminichat.list_chat:setasyncdelegate(minichat_delegate_setlist)
	m_uiminichat.text_sizecalc = m_uiminichat:getwidget("text_sizecalc")
	m_uiminichat:setwidgetdelegate("button_openchat", minichat_delegate_openchat)
end

function minichat_addchat(chat, removehistroyid)
	if m_uiminichat:alive() and csvchat_getchannelvisible(0, chat.type) and not playerpal_inblacklist(chat.senderid) then
		local isbottom = m_uiminichat.list_chat:isscrollbottom()
		if removehistroyid ~= 0 then
			for i=1,m_uiminichat.list_chat:getcount() do
				local line = m_uiminichat.list_chat:getlinefromindex(i)
				local data = line:getdata()
				if data.histroyid == removehistroyid then
					m_uiminichat.list_chat:remove(i)
					break
				end
			end
		end
		if chat.presetminichat == nil then
			chat.presetminichat = m_uiminichat.text_sizecalc:presetchat(chat)
		end
        local line = m_uiminichat.list_chat:add(m_minichat_inst.chat, string.format("%d", chat.histroyid), chat)
		line:setsize(chat.presetminichat.viewheight)
		m_uiminichat.list_chat:updatecontentsize()
		if isbottom then
			m_uiminichat.list_chat:setscrollbottom(0.2)
		end
    end
end

function minichat_delegate_openchat()
	m_uichat_chatbox:open()
end

function minichat_delegate_setlist(sender, line, chat)
    local text_chat = line:getwidget("text_chat")
    text_chat:setchat(chat.presetminichat)
end
