
include("mail/mailmain")
include("mail/mailread")
include("mail/mailrecv")
include("mail/mailsend")
include("mail/bugreport")

mailtab = 
{
    recv = 1,
    send = 2,
}

mailtype = 
{
    player = 0,
    system = 1,
    abyss = 2,
}

m_uimail_main = uipanel_createhandle("mail/mail_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
m_uimail_tab = mailtab.recv
m_uimail_openid = 0
