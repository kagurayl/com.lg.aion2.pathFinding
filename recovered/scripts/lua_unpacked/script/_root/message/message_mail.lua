
local function mail_updateui()
	mail_main_updateui()
	minimapadditive_updatemail()
end

function SC_MailList(msg)
	playerattr_mail = msg.info
	mail_updateui()
end

function SC_MailRecv(msg)
	if playerattr_mail == nil then
		playerattr_mail = {}
	end
	msg.readstate = 0
	playerattr_mail[#playerattr_mail + 1] = msg
	mail_updateui()
	audiomanager_playaudioui(AudioMail)
end

function SC_MailOverload(msg)
	chat_addsystemalert("MAIL_OVERLOAD")
end

function SC_MailRead(msg)
	for i=1,#playerattr_mail do
		if playerattr_mail[i].mailid == msg.mailid then
			local mail = playerattr_mail[i]
			mail.date = msg.date
			mail.text = msg.text
			mail.readstate = 1
			mail.coin = msg.coin
			mail.cash = msg.cash
			mail.item = msg.item
			mail_updateui()
			break
		end
	end	
end

function SC_MailGet(msg)
	for i=1,#msg.mailid do
		for j=1,#playerattr_mail do
			if playerattr_mail[j].mailid == msg.mailid[i] then
				local mail = playerattr_mail[j]
				mail.readstate = 1
				mail.coin = 0
				mail.cash = 0
				mail.hascoin = 0
				break
			end
		end
	end
	for i=1,#msg.itemtake do
		for j=1,#playerattr_mail do
			if playerattr_mail[j].mailid == msg.itemtake[i] then
				local mail = playerattr_mail[j]
				mail.item = nil
				mail.hasitem = 0
				break
			end
		end
	end
	mail_updateui()
end

function SC_MailDelete(msg)
	for i=1,#msg.mailid do
		for j=1,#playerattr_mail do
			if playerattr_mail[j].mailid == msg.mailid[i] then
				table.remove(playerattr_mail, j)
				break
			end
		end
	end
	mail_updateui()
end

function SC_MailSend(msg)
	chat_addsystemalert(c_textformat("MAIL_SEND_SUCCESS", msg.mailtitle, msg.playername))
end

function SC_Survey(msg)
	if msg.id ~= 0 then
		chat_addsystemalert("STR_GMPOLL_GOT_POLL")
		playerattr_survey = msg
		audiomanager_playaudioui(AudioHelpIndicator)
	else
		playerattr_survey = nil
	end
	actionbar_updatenotify()
end

function SC_BugReport(msg)
	chat_addsystemalert(c_textformat("BUGREPORT_SUCCESS"))
	bugreport_clear()
end
