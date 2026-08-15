
m_uiplayerinfo = uipanel_createhandle("home/playerinfo", uilayer.bottom, uiflag.scale)

function playerinfo_onopen()
	m_uiplayerinfo:setwidgetdelegate("image_bg", playerinfo_delegate_selectme)
	m_uiplayerinfo:setwidgetdelegate("image_playerinfo", playerinfo_delegate_overview)
	m_uiplayerinfo:setwidgetdelegate("image_buffclick", playerinfo_delegate_bufflist)
	m_uiplayerinfo:setwidgetdelegate("image_debuffclick", playerinfo_delegate_debufflist)
	m_uiplayerinfo:setwidgetdelegate("spirit/image_head", playerinfo_delegate_spirite)
	m_uiplayerinfo.progress_hp = m_uiplayerinfo:getwidget("progress_hp")
	m_uiplayerinfo.progress_mp = m_uiplayerinfo:getwidget("progress_mp")
	m_uiplayerinfo.progress_dp = m_uiplayerinfo:getwidget("progress_dp")
	m_uiplayerinfo.text_hp = m_uiplayerinfo:getwidget("text_hp")
	m_uiplayerinfo.text_mp = m_uiplayerinfo:getwidget("text_mp")
	m_uiplayerinfo.text_dp = m_uiplayerinfo:getwidget("text_dp")
	m_uiplayerinfo.progress_hpanim = m_uiplayerinfo:getwidget("progress_hpanim")
	m_uiplayerinfo.progress_mpanim = m_uiplayerinfo:getwidget("progress_mpanim")
	m_uiplayerinfo.progress_dpanim = m_uiplayerinfo:getwidget("progress_dpanim")
	m_uiplayerinfo.progress_hpdebuff = m_uiplayerinfo:getwidget("progress_hpdebuff")
	m_uiplayerinfo.progress_hpdebuffanim = m_uiplayerinfo:getwidget("progress_hpdebuffanim")
	m_uiplayerinfo.spirit_root = m_uiplayerinfo:getwidget("spirit")
	m_uiplayerinfo.spirit_hp = m_uiplayerinfo:getwidget("spirit/progress_hp")
	m_uiplayerinfo.spirit_hpanim = m_uiplayerinfo:getwidget("spirit/progress_hpanim")
	m_uiplayerinfo.spirit_visible = true

	playerinfo_updateui()
	playerinfo_updatehp()
	playerinfo_updatespirit()
	event_register(eventtype.update, playerinfo_updatehp, m_uiplayerinfo)
end

function playerinfo_updatehp()
	local hppercent = m_me.attrdisplay.hp / m_me.attrdisplay.hpmax
	local hpanimpercent = m_me.attrdisplay.hpanim / m_me.attrdisplay.hpmax
	if m_me.actionmain.buffhasdebuff then
		m_uiplayerinfo.progress_hp:setpercentverify(0.0)
		m_uiplayerinfo.progress_hpanim:setpercentverify(0.0)
		m_uiplayerinfo.progress_hpdebuff:setpercentverify(hppercent)
		m_uiplayerinfo.progress_hpdebuffanim:setpercentverify(hpanimpercent)
	else
		m_uiplayerinfo.progress_hp:setpercentverify(hppercent)
		m_uiplayerinfo.progress_hpanim:setpercentverify(hpanimpercent)
		m_uiplayerinfo.progress_hpdebuff:setpercentverify(0.0)
		m_uiplayerinfo.progress_hpdebuffanim:setpercentverify(0.0)
	end
	m_uiplayerinfo.progress_mp:setpercentverify(m_me.attrdisplay.mp / m_me.attrdisplay.mpmax)
	m_uiplayerinfo.progress_dp:setpercentverify(m_me.attrdisplay.dp / m_me.attrdisplay.dpmax)
	m_uiplayerinfo.text_hp:settextrawverify(string.format("%d/%d", math.tointegerfloor(m_me.attrdisplay.hpscroll), math.tointegerfloor(m_me.attrdisplay.hpmax)))
	m_uiplayerinfo.text_mp:settextrawverify(string.format("%d/%d", math.tointegerfloor(m_me.attrdisplay.mpscroll), math.tointegerfloor(m_me.attrdisplay.mpmax)))
	m_uiplayerinfo.text_dp:settextrawverify(string.format("%d/%d", math.tointegerfloor(m_me.attrdisplay.dpscroll), math.tointegerfloor(m_me.attrdisplay.dpmax)))
	m_uiplayerinfo.progress_mpanim:setpercentverify(m_me.attrdisplay.mpanim / m_me.attrdisplay.mpmax)
	m_uiplayerinfo.progress_dpanim:setpercentverify(m_me.attrdisplay.dpanim / m_me.attrdisplay.dpmax)
	playerbuff_updateactorui(m_me, m_uiplayerinfo)

	if playerattr_info.spiritid ~= 0 then
		local spirit = actormanager_getfromactorid(playerattr_info.spiritid)
		if spirit ~= nil then
			m_uiplayerinfo.spirit_hp:setpercent(spirit.attrdisplay.hp / spirit.attrdisplay.hpmax)
			m_uiplayerinfo.spirit_hpanim:setpercent(spirit.attrdisplay.hpanim / spirit.attrdisplay.hpmax)
			playerbuff_updateactorui(spirit, m_uiplayerinfo.spirit_root)
		else
			m_uiplayerinfo.spirit_hp:setpercent(0.0)
			m_uiplayerinfo.spirit_hpanim:setpercent(0.0)
		end
	elseif m_uiplayerinfo.spirit_visible then
		m_uiplayerinfo.spirit_visible = false
		m_uiplayerinfo.spirit_root:setvisible(false)
	end
end

function playerinfo_updateui()
	if m_uiplayerinfo:null() then
		return
	end
	local image_head = m_uiplayerinfo:getwidget("image_head")
	image_head:seticon(playercareericon[playerattr_info.career])

	local text_level = m_uiplayerinfo:getwidget("text_level")
	text_level:settext(playerattr_info.level)
end

function playerinfo_updatespirit()
	if m_uiplayerinfo:null() then
		return
	end
	if playerattr_info.spiritid ~= 0 then
		m_uiplayerinfo.spirit_visible = true
		m_uiplayerinfo.spirit_root:setvisible(true)
		local actor = actormanager_getfromactorid(playerattr_info.spiritid)
		if actor ~= nil then
			local image_head = m_uiplayerinfo:getwidget("spirit/image_head")
			image_head:seticon(actor:getheadicon())

			local text_level = m_uiplayerinfo:getwidget("spirit/text_level")
			text_level:settext(actor.attr.level)
		end
	else
		m_uiplayerinfo.spirit_visible = false
		m_uiplayerinfo.spirit_root:setvisible(false)
	end
end

function playerinfo_delegate_selectme(sender, event)
    inputkey_selectme()
end

function playerinfo_delegate_overview(sender, event)
    inputkey_openoverview()
end

function playerinfo_delegate_bufflist(sender, event)
	bufflist_create()
end

function playerinfo_delegate_debufflist(sender, event)
	debufflist_create()
end

function playerinfo_delegate_spirite(sender, event)
    local actor = actormanager_getfromactorid(playerattr_info.spiritid)
    if actor ~= nil then
        actormanager_selectactor(actor)
    end
end
