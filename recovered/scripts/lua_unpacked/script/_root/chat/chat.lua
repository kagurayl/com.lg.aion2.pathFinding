
include("chat/chatbox")
include("chat/chatinput")
include("chat/chatsetting")
include("chat/chatreceiver")

function chat_openinput()
    m_uichat_chatbox:open()
end

function chat_whisperto(whisperid, whispername)
    m_uichat_chatbox:open()
    chatinput_setchannel(chatchanneltype.chatsendwhisper, whisperid, whispername)
end
