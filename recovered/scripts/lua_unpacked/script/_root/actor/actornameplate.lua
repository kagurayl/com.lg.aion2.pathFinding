
local m_actornameplate = uipanel_createhandle("root/nameplate", uilayer.nameui, uiflag.holdonclear)
local m_actorname_idle = {}
local m_actorchat_idle = {}
local m_actornpctalk_idle = {}
local m_actorstall_idle = {}
local m_actorname_id = 1

local m_actornameplate_npctitlefontsize = 40
local m_actornameplate_npctitleheight = 38
local m_actornameplate_iccfontsize = 46
local m_actornameplate_iccheight = 48
local m_actornameplate_nameheight = 50
local m_actornameplate_namespace = 0.2

local function actornameplate_getwidget(widget, name)
	local headwidget = m_actornameplate:getwidget(widget._widgetpath .. name)
	headwidget.width, headwidget.height = headwidget:getsize()
	return headwidget
end

local function actornameplate_initname(widget)
	widget.progress_hp = actornameplate_getwidget(widget, "/progress_hp")
	widget.progress_hpanim = actornameplate_getwidget(widget, "/progress_hpanim")
	widget.progress_hpdebuff = actornameplate_getwidget(widget, "/progress_hpdebuff")
	widget.progress_hpdebuffanim = actornameplate_getwidget(widget, "/progress_hpdebuffanim")
	widget.progress_hpbg = actornameplate_getwidget(widget, "/progress_hpbg")

	widget.progress_mp = actornameplate_getwidget(widget, "/progress_mp")
	widget.progress_mpanim = actornameplate_getwidget(widget, "/progress_mpanim")
	widget.progress_mpbg = actornameplate_getwidget(widget, "/progress_mpbg")

	widget.text_name = actornameplate_getwidget(widget, "/text_name")
	widget.text_icc = actornameplate_getwidget(widget, "/text_icc")

	widget.image_logo = actornameplate_getwidget(widget, "/image_logo")
	widget.image_questmain = actornameplate_getwidget(widget, "/image_questmain")
	widget.image_queststd = actornameplate_getwidget(widget, "/image_queststd")
end

local function actornameplate_initchat(widget)
	widget.image_chatbg = actornameplate_getwidget(widget, "/image_chatbg")
	widget.image_chatarrow = actornameplate_getwidget(widget, "/image_chatarrow")
	widget.text_chat = actornameplate_getwidget(widget, "/text_chat")
end

local function actornameplate_initstall(widget)
	widget.image_stallbg = actornameplate_getwidget(widget, "/image_stallbg")
	widget.text_advert = actornameplate_getwidget(widget, "/text_advert")
end

local function actornameplate_openui()
	if m_actornameplate:alive() then
		return
	end
	m_actornameplate:open()
	m_actorname_id = 1

	m_actorname_idle = {}
	m_actorchat_idle = {}
	m_actornpctalk_idle = {}

	local widget = m_actornameplate:getwidget("name_1")
	actornameplate_initname(widget)
	widget:setvisible(false)
	m_actorname_idle[1] = widget

	widget = m_actornameplate:getwidget("chat_1")
	actornameplate_initchat(widget)
	widget:setvisible(false)
	m_actorchat_idle[1] = widget

	widget = m_actornameplate:getwidget("npctalk_1")
	actornameplate_initchat(widget)
	widget:setvisible(false)
	m_actornpctalk_idle[1] = widget

	widget = m_actornameplate:getwidget("stall_1")
	actornameplate_initstall(widget)
	widget:setvisible(false)
	m_actorstall_idle[1] = widget
end

function _actorclass:nameplatevisible()
	if not self:isvisible() then
		return false
	end
	if self:isdynamicnpc() then
		if self.config_npc.hidenpc > 0 then
			return false
		end
		if self.attr.isdead > 0 then
			return false
		end
		if self.config_npc.uitype == csvnpcuitype.none
		or self.config_npc.uitype == csvnpcuitype.hidden_monster
		or self.config_npc.uitype == csvnpcuitype.trap then
			return false
		end
		if self.config_npc.uitype == csvnpcuitype.craft
		or self.config_npc.uitype == csvnpcuitype.craft_ui_always then
			local npcquesttype = playerattr_questnpcnameplate[self.config_npc.id]
			return npcquesttype ~= nil
		end
	elseif self:isstaticnpc() then
		if entitymanager_getactorvisible(self.config_npcstatic.staticid) then
			local npcquesttype = playerattr_questnpcnameplate[self.config_npc.id]
			return npcquesttype ~= nil	
		end
		return false
	elseif not self:isplayer() then
		return false
	end

	if self:isme() then
		return gamesetting_getnumber("PLAYERNAME") > 0
	end

	if self:isplayer() then
		if self:isenemy() then
			return gamesetting_getnumber("ENEMYNAME") > 0
		elseif self:isteam() then
			return gamesetting_getnumber("TEAMNAME") > 0
		elseif self:israid() then
			return gamesetting_getnumber("RAIDNAME") > 0
		elseif self:isflock() then
			return gamesetting_getnumber("FLOCKNAME") > 0
		else
			return gamesetting_getnumber("SIPIDNAME") > 0
		end
	else
		if self:isenemy() then
			return gamesetting_getnumber("MONSTERNAME") > 0
		else
			return gamesetting_getnumber("NPCNAME") > 0
		end
	end
	return false
end

function _actorclass:nameplateisvisible()
	return self.namewidget ~= nil
end

function _actorclass:destroyallplate()
	self:destroynameplate()
	self:destroychatbubble()
	self:destroystall()
end

function _actorclass:createnameplate()
	self:destroynameplate()
	if not self:nameplatevisible() then
		return
	end
	actornameplate_openui()
	local widget = nil
	if #m_actorname_idle > 0 then
		widget = m_actorname_idle[#m_actorname_idle]
		table.remove(m_actorname_idle, #m_actorname_idle)
		widget:setvisiblenothit(true)
	else
		m_actorname_id = m_actorname_id + 1
		local source = m_actornameplate:getwidget("name_1")
		widget = source:clone("name_" .. m_actorname_id)
		actornameplate_initname(widget)
	end
	widget.height = 0
	self.namewidget = widget
	self:updatenameuilayout()
	if self:isstaticnpc() then
		c_entity_addnameplate(self.config_npcstatic.staticid, self.namewidget._panel._uiname, self.namewidget._widgetpath, 0, 0)
		c_entity_setnameplateposition(self.config_npcstatic.staticid, 0, self.actordata.nameheight * self.transform.sy + m_actornameplate_namespace, 0, 50, 80)
	else
		c_actor_addnameplate(self.id, self.namewidget._panel._uiname, self.namewidget._widgetpath, 0, 0)
		c_actor_setnameplateposition(self.id, 0, self.actordata.nameheight * self.transform.sy + m_actornameplate_namespace, 0, 50, 80)
	end
end

function _actorclass:destroynameplate()
	if self.namewidget ~= nil then
		if self:isstaticnpc() then
			c_entity_removenameplate(self.config_npcstatic.staticid, self.namewidget._widgetpath)
		else
			c_actor_removenameplate(self.id, self.namewidget._widgetpath)
		end
		self.namewidget:setvisible(false)
		m_actorname_idle[#m_actorname_idle + 1] = self.namewidget
		self.namewidget = nil
	end
end

function _actorclass:createchatbubble(text, equip)
	if self:isstaticnpc() then
		return
	end
	actornameplate_openui()
	self:destroychatbubble()

	local widget = nil
	if self:isplayer() then
		if #m_actorchat_idle > 0 then
			widget = m_actorchat_idle[#m_actorchat_idle]
			table.remove(m_actorchat_idle, #m_actorchat_idle)
			widget:setvisiblenothit(true)
		else
			m_actorname_id = m_actorname_id + 1
			local source = m_actornameplate:getwidget("chat_1")
			widget = source:clone("chat_" .. m_actorname_id)
			actornameplate_initchat(widget)
		end
	else
		if #m_actornpctalk_idle > 0 then
			widget = m_actornpctalk_idle[#m_actornpctalk_idle]
			table.remove(m_actornpctalk_idle, #m_actornpctalk_idle)
			widget:setvisiblenothit(true)
		else
			m_actorname_id = m_actorname_id + 1
			local source = m_actornameplate:getwidget("npctalk_1")
			widget = source:clone("npctalk_" .. m_actorname_id)
			actornameplate_initchat(widget)
		end
	end

	self.chatwidget = widget
	widget.text_chat:setrichtext(text, equip)
	local tw, th = widget.text_chat:getsize() 
	local textw, texth = widget.text_chat:getrendersize()
	textw = math.min(tw, textw)
	local textspace = 25
	local bgw = textw + textspace * 2
	local bgh = texth + textspace * 2
	local position = 140 + bgh / 2
	widget.image_chatbg:setsize(bgw, bgh)
	widget.image_chatbg:setposition(-bgw / 2, position + bgh / 2)
	widget.image_chatarrow:setposition(0, position - bgh / 2 + 5)
	widget.text_chat:setposition(-textw / 2, position + texth / 2)
	widget.timeend = time_game + 5

	c_actor_addnameplate(self.id, self.chatwidget._panel._uiname, self.chatwidget._widgetpath, 0, 0)
	c_actor_setnameplateposition(self.id, 0, self.actordata.nameheight * self.transform.sy + m_actornameplate_namespace, 0, 50, 80)
end

function _actorclass:destroychatbubble()
	if self.chatwidget ~= nil then
		c_actor_removenameplate(self.id, self.chatwidget._widgetpath)
		self.chatwidget:setvisible(false)
		if self:isplayer() then
			m_actorchat_idle[#m_actorchat_idle + 1] = self.chatwidget
		else
			m_actornpctalk_idle[#m_actornpctalk_idle + 1] = self.chatwidget
		end
		self.chatwidget = nil
	end
end

function _actorclass:createstall(advert)
	actornameplate_openui()
	self:destroystall()
	local widget = nil
	if #m_actorstall_idle > 0 then
		widget = m_actorstall_idle[#m_actorstall_idle]
		table.remove(m_actorstall_idle, #m_actorstall_idle)
		widget:setvisiblenothit(true)
	else
		m_actorname_id = m_actorname_id + 1
		local source = m_actornameplate:getwidget("stall_1")
		widget = source:clone("stall_" .. m_actorname_id)
		actornameplate_initstall(widget)
	end
	self.stallwidget = widget
	widget.text_advert:settext(advert)
	local textw, texth = widget.text_advert:getrendersize()
	textw = math.min(textw, widget.text_advert.width)
	local posy = texth + 200
	widget.text_advert:setposition(-textw / 2, posy + texth / 2)
	widget.image_stallbg:setrect(0, posy, textw + 80, texth + 80)
	c_actor_addnameplate(self.id, widget._panel._uiname, widget._widgetpath, 0, 0)
	c_actor_setnameplateposition(self.id, 0, self.actordata.nameheight * self.transform.sy + m_actornameplate_namespace, 0, 50, 80)
end

function _actorclass:destroystall()
	if self.stallwidget ~= nil then
		c_actor_removenameplate(self.id, self.stallwidget._widgetpath)
		self.stallwidget:setvisible(false)
		m_actorstall_idle[#m_actorstall_idle + 1] = self.stallwidget
		self.stallwidget = nil
	end
end

function _actorclass:getnamecolor()
	local namecolor = 0xffffffff
	local titlecolor = 0xffffffff
	if self:isme() then
		namecolor = Color_TitlePCMyPlayer
		titlecolor = Color_TitlePCMyPlayer
	elseif self:isplayer() then
		if self:isdead() then
			namecolor = Color_TitlePCDead
			titlecolor = Color_TitlePCDead
		elseif self:isenemy() then
			local level = self.attr.level - playerattr_info.level
			if level > playerlevel_strong then
				namecolor = Color_TitlePCEnemyPlayerStrong
				titlecolor = Color_TitlePCEnemyPlayerStrong
			elseif level < playerlevel_weak then
				namecolor = Color_TitlePCEnemyPlayerWeak
				titlecolor = Color_TitlePCEnemyPlayerWeak
			else
				namecolor = Color_TitlePCEnemyPlayer
				titlecolor = Color_TitlePCEnemyPlayer
			end
		elseif self:isteam() then
			namecolor = Color_TitlePCPartyPlayer
			titlecolor = Color_TitlePCPartyPlayer
		elseif self:israid() then
			if self:israidteam() then
				namecolor = Color_TitlePCPartyPlayer
				titlecolor = Color_TitlePCPartyPlayer
			else
				namecolor = Color_TitlePCForcePlayer
				titlecolor = Color_TitlePCForcePlayer
			end
		elseif self:isflock() then
			namecolor = Color_TitlePCUnionPlayer
			titlecolor = Color_TitlePCUnionPlayer
		elseif self:isiccmember() then
			namecolor = Color_TitlePCPartyPlayer
			titlecolor = Color_TitlePCPartyPlayer
		else
			namecolor = Color_TitlePCOtherPlayer
			titlecolor = Color_TitlePCOtherPlayer
		end
	elseif self:isdynamicnpc() or self:isstaticnpc() then
		namecolor = Color_TitleNPCUnattackable
		titlecolor = Color_TitleNPCTitleColor
		if self:ismyspirit() then
			namecolor = Color_TitlePCPartyPlayer
			titlecolor = Color_TitlePCPartyPlayer
		elseif self:isenemy() then
			local level = self.attr.level - playerattr_info.level
			if level > playerlevel_npcverystrong then
				namecolor = Color_TitleNPCVeryStrong
			elseif level > playerlevel_npcstrong then
				namecolor = Color_TitleNPCStrong
			elseif level > playerlevel_npcweak then
				namecolor = Color_TitleNPCNormal
			elseif level > playerlevel_npcveryweak then
				namecolor = Color_TitleNPCWeak
			else
				namecolor = Color_TitleNPCVeryWeak
			end
		end
	end
	return namecolor, titlecolor
end

function _actorclass:updatenameuilayout()
	self:updateallplateposition()
	local namewidget = self.namewidget
	if namewidget == nil then
		return
	end

	local position = 12
	local hpvisible = false
	local mpvisible = false
	if self:isme() then
		hpvisible = true
		mpvisible = true
	elseif self.actorid == m_selectactorid then
		hpvisible = true
	end
	namewidget.progress_hp:setvisible(hpvisible)
	namewidget.progress_hpanim:setvisible(hpvisible)
	namewidget.progress_hpdebuff:setvisible(hpvisible)
	namewidget.progress_hpdebuffanim:setvisible(hpvisible)
	namewidget.progress_hpbg:setvisible(hpvisible)
	namewidget.progress_mp:setvisible(mpvisible)
	namewidget.progress_mpanim:setvisible(mpvisible)
	namewidget.progress_mpbg:setvisible(mpvisible)

	if mpvisible then
		local mpcenter = position + namewidget.progress_mpbg.height / 2
		namewidget.progress_mp:setposition(-namewidget.progress_mp.width / 2, mpcenter - namewidget.progress_mp.height / 2)
		namewidget.progress_mpanim:setposition(-namewidget.progress_mpanim.width / 2, mpcenter - namewidget.progress_mpanim.height / 2)
		namewidget.progress_mpbg:setposition(-namewidget.progress_mpbg.width / 2, mpcenter - namewidget.progress_mpbg.height / 2)
	end
	position = position + namewidget.progress_mpbg.height
	if hpvisible then
		local hpcenter = position + namewidget.progress_hpbg.height / 2
		namewidget.progress_hp:setposition(-namewidget.progress_hp.width / 2, hpcenter - namewidget.progress_hp.height / 2)
		namewidget.progress_hpanim:setposition(-namewidget.progress_hpanim.width / 2, hpcenter - namewidget.progress_hpanim.height / 2)
		namewidget.progress_hpdebuff:setposition(-namewidget.progress_hpdebuff.width / 2, hpcenter - namewidget.progress_hpdebuff.height / 2)
		namewidget.progress_hpdebuffanim:setposition(-namewidget.progress_hpdebuffanim.width / 2, hpcenter - namewidget.progress_hpdebuffanim.height / 2)
		namewidget.progress_hpbg:setposition(-namewidget.progress_hpbg.width / 2, hpcenter - namewidget.progress_hpbg.height / 2)
	end
	position = position + namewidget.progress_hpbg.height + 5

	local namecolor, titlecolor = self:getnamecolor()
	if self:isplayer() then
		if self.attr.iccname ~= nil and string.len(self.attr.iccname) > 0 and gamesetting_getnumber("ICCNAME") > 0 then
			position = position + m_actornameplate_iccheight
			namewidget.text_icc:setfontsize(m_actornameplate_iccfontsize)
			namewidget.text_icc:setvisiblenothit(true)
			if self.attr.iccname == playerattr_info.iccname then
				namewidget.text_icc:sethexcolor(Color_TitlePCMyPlayer)
			else
				namewidget.text_icc:sethexcolor(namecolor)
			end
			if self.icc ~= nil then
				namewidget.text_icc:settext(string.format("<%s>", self.icc.name))
			else
				namewidget.text_icc:settext(string.format("<%s>", self.attr.iccname))
			end
			namewidget.text_icc:setposition(0, position)
		else
			namewidget.text_icc:setvisiblenothit(false)
		end
	else
		local npctitle = nil
		if self:isdynamicnpc() then
			if self:isspirit() and self.attr.spiritownername ~= nil then
				npctitle = string.format("<%s>", self.attr.spiritownername)
			else
				npctitle = self.config_npc.title
			end
		end
		if npctitle ~= nil and npctitle ~= "0" and #npctitle > 0 then
			position = position + m_actornameplate_npctitleheight
			namewidget.text_icc:setfontsize(m_actornameplate_npctitlefontsize)
			namewidget.text_icc:setvisiblenothit(true)
			namewidget.text_icc:sethexcolor(titlecolor)
			namewidget.text_icc:settext(npctitle)
			namewidget.text_icc:setposition(0, position)
		else
			namewidget.text_icc:setvisiblenothit(false)
		end
	end

	position = position + m_actornameplate_nameheight
	local name = self.attr.name
	if self:isplayer() and gamesetting_getnumber("TITLE") > 0 then
		if gamesetting_getnumber("PVPTITLE") > 0 or self.attr.civ ~= playerattr_info.civ then
			local pvptitle = 0
			if self:isme() then
				pvptitle = playerattr_pvp.title
			else
				pvptitle = self.attr.pvptitle
			end
			pvptitle = math.max(1, pvptitle)
			if self.attr.civ == playerciv.light then
				name = string.format("%s %s", c_textformat("PLAYER_PVPLEVEL_LIGHT" .. pvptitle), self.attr.name)
			else
				name = string.format("%s %s", c_textformat("PLAYER_PVPLEVEL_DARK" .. pvptitle), self.attr.name)
			end
		else
			if self.attr.title ~= nil and self.attr.title ~= 0 then
				local config_title = csvplayertitle_getfromid(self.attr.title)
				if config_title ~= nil then
					name = string.format("%s %s", config_title.name, self.attr.name)
				end
			end
		end
	end

	namewidget.text_name:settext(name)
	namewidget.text_name:sethexcolor(namecolor)
	namewidget.text_name:setposition(0, position)
	local questvisible = false
	if self:isdynamicnpc() then
		local npcquesttype = playerattr_questnpcnameplate[self.config_npc.id]
		if npcquesttype ~= nil then
			questvisible = true
			local name_w,name_h = namewidget.text_name:getrendersize()
			local questwidget = nil
			if npcquesttype == questtype.main then
				namewidget.image_questmain:setvisible(true)
				namewidget.image_queststd:setvisible(false)
				questwidget = namewidget.image_questmain
			else
				namewidget.image_questmain:setvisible(false)
				namewidget.image_queststd:setvisible(true)
				questwidget = namewidget.image_queststd
			end
			questwidget:setposition(-name_w / 2, position - 8)
		end
	end
	if not questvisible then
		namewidget.image_questmain:setvisible(false)
		namewidget.image_queststd:setvisible(false)
	end

	if self.actordata.logo ~= nil then
		local spritename = "name/logo" .. self.actordata.logo
		local width, height = c_uigetspritesize(unity_spritepath(spritename))
		position = position + height
		namewidget.image_logo:setvisiblenothit(true)
		namewidget.image_logo:setsprite(spritename)
		namewidget.image_logo:setrect(-width / 2, position, width, height)
	else
		namewidget.image_logo:setvisiblenothit(false)
	end
end

function _actorclass:updateallplateposition()
	local nameposition = self.actordata.nameheight * self.transform.sy + m_actornameplate_namespace
	if self:isstaticnpc() then
		if self.namewidget ~= nil then
			c_entity_updatenameplate(self.config_npcstatic.staticid, nameposition, self.namewidget._widgetpath)
		end
		if self.chatwidget ~= nil then
			c_entity_updatenameplate(self.config_npcstatic.staticid, nameposition, self.chatwidget._widgetpath)
		end
		if self.stallwidget ~= nil then
			c_entity_updatenameplate(self.config_npcstatic.staticid, nameposition, self.stallwidget._widgetpath)
		end
	else
		if self.namewidget ~= nil then
			c_actor_updatenameplate(self.id, self.namewidget._widgetpath, nameposition)
		end
		if self.chatwidget ~= nil then
			c_actor_updatenameplate(self.id, self.chatwidget._widgetpath, nameposition)
		end
		if self.stallwidget ~= nil then
			c_actor_updatenameplate(self.id, self.stallwidget._widgetpath, nameposition)
		end
	end
end

function _actorclass:updatenamewidget()
	if self.namewidget == nil then
		return
	end

	local hpratio = self.attrdisplay.hp / self.attrdisplay.hpmax
	local hpanimratio = self.attrdisplay.hpanim / self.attrdisplay.hpmax
	local debuffupdate = self.namewidget.hphasdebuff ~= self.actionmain.buffhasdebuff
	self.namewidget.hphasdebuff = self.actionmain.buffhasdebuff
	if self.namewidget.hpratio ~= hpratio or debuffupdate then
		self.namewidget.hpratio = hpratio
		if self.namewidget.hphasdebuff then
			self.namewidget.progress_hp:setpercent(0.0)
			self.namewidget.progress_hpdebuff:setpercent(hpratio)
		else
			self.namewidget.progress_hp:setpercent(hpratio)
			self.namewidget.progress_hpdebuff:setpercent(0.0)
		end
	end
	if self.namewidget.hpanimratio ~= hpanimratio or debuffupdate then
		self.namewidget.hpanimratio = hpanimratio
		if self.namewidget.hphasdebuff then
			self.namewidget.progress_hpanim:setpercent(0.0)
			self.namewidget.progress_hpdebuffanim:setpercent(hpanimratio)
		else
			self.namewidget.progress_hpanim:setpercent(hpanimratio)
			self.namewidget.progress_hpdebuffanim:setpercent(0.0)
		end
	end

	if self:isplayer() then
		local mpratio = self.attrdisplay.mp / self.attrdisplay.mpmax
		local mpanimratio = self.attrdisplay.mpanim / self.attrdisplay.mpmax
		if self.namewidget.mpratio ~= mpratio then
			self.namewidget.mpratio = mpratio
			self.namewidget.progress_mp:setpercent(mpratio)
		end
		if self.namewidget.mpanimratio ~= mpanimratio then
			self.namewidget.mpanimratio = mpanimratio
			self.namewidget.progress_mpanim:setpercent(mpanimratio)
		end
	end
end

function _actorclass:updatechatwidget()
	if self.chatwidget ~= nil and self.chatwidget.timeend < time_game then
		self:destroychatbubble()
	end
end
