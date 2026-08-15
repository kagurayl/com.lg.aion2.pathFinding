
_uitextclass = _inheritclass("_uitextclass", _uiwidgetclass)

function _uitextclass:settext(val,...)
	c_uitext_settext(self._panel._uiname, self._widgetpath, val, ...)
end

function _uitextclass:setrichtext(val,equip,...)
	local viewtext, tagarray = richtext_parse(val, equip, 0)
	c_uitext_settext(self._panel._uiname, self._widgetpath, viewtext, ...)
	self.tagarray = tagarray
end

function _uitextclass:setrichtextex(val,flag,equip,...)
	local viewtext, tagarray = richtext_parse(val, equip, flag)
	c_uitext_settext(self._panel._uiname, self._widgetpath, viewtext, ...)
	self.tagarray = tagarray
end

function _uitextclass:settextscale(val,...)
	self:settext(val, ...)
	local dw,dh,rw,rh = self:getsize()
	local text_w,text_h = self:getrendersize()
	local scale = math.min(1.0, rw / text_w)
	self:setscale(scale, scale)
end

function _uitextclass:settextrawscale(val,...)
	self:settextraw(val, ...)
	local dw,dh,rw,rh = self:getsize()
	local text_w,text_h = self:getrendersize()
	local scale = math.min(1.0, rw / text_w)
	self:setscale(scale, scale)
end

function _uitextclass:updatescale(renderwidth, maxwidth)
	if renderwidth > maxwidth then
		local scale = math.min(1.0, maxwidth / renderwidth)
		self:setscale(scale, scale)
	else
		self:setscale(1.0, 1.0)
	end
end

function _uitextclass:settextraw(val)
	c_uitext_settextraw(self._panel._uiname, self._widgetpath, val)
end

function _uitextclass:settextrawverify(val)
	if self._verifytext ~= val then
        self._verifytext = val
    	c_uitext_settextraw(self._panel._uiname, self._widgetpath, val)
    end
end

function _uitextclass:setfontsize(fontsize)
	c_uitext_setfontsize(self._panel._uiname, self._widgetpath, fontsize)
end

function _uitextclass:gettext()
	return c_uitext_gettext(self._panel._uiname, self._widgetpath)
end

function _uitextclass:getrendersize()
    return c_uitext_getrendersize(self._panel._uiname, self._widgetpath)
end

function _uitextclass:getcharposition(index)
    return c_uitext_getcharposition(self._panel._uiname, self._widgetpath, index)
end

function _uitextclass:setheightfromrendersize()
	local width, height = self:getsize()
	local renderwidth, renderheight = self:getrendersize()
	self:setsize(width, renderheight)
	return width, renderheight
end

function _uitextclass:setavailablecolor(enable)
	if enable then
		self:setcolor(0.93,0.93,0.86, 1.0)
	else
		self:setcolor(0.6, 0.6, 0.6, 1.0)
	end
end

function _uitextclass:setwarningcolor(warning)
    if warning then
        self:setcolor(0.93, 0.5, 0.5, 1.0)
    else
        self:setcolor(0.93,0.93,0.86, 1.0)
    end
end

function _uitextclass:setmoney(val)
	if val == 0 then
		self:settext("0")
		return
	end
	
	local str = ""
	while val ~= 0 do
		if string.len(str) > 0 then
			str = ", " .. str
		end
		local valcurrent =  math.floor(math.fmod(val, 1000))
		val = math.floor(val / 1000)
		if val ~= 0 then
			str = string.format("%03d%s", valcurrent, str)
		else
			str = valcurrent .. str
		end
	end
	self:settext(str)
end

function _uitextclass:presetchat(chat)
	local channeltext = chat.text
	if chat.type == chatchanneltype.chatrecvwhisper then
		channeltext = c_textformat("CHAT_FORMAT_" .. chat.type, chat.sendername, channeltext)
	elseif chat.type == chatchanneltype.chatsendwhisper then
		channeltext = c_textformat("CHAT_FORMAT_" .. chat.type, chat.whispername, channeltext)
	elseif chat.type == chatchanneltype.chatrumor and chat.senderid == 0 then
		channeltext = c_textformat("CHAT_FORMAT_" .. chat.type, c_textformat("CHAT_FORMAT_RUMORPLAYER"), channeltext)
	elseif chat.type <= chatchanneltype.chathowlall then
		channeltext = c_textformat("CHAT_FORMAT_" .. chat.type, chat.sendername, channeltext)
	elseif chat.type <= chatchanneltype.systemitem then
		channeltext = c_textformat("CHAT_FORMAT_SYSTEM", channeltext)
	elseif chat.type <= chatchanneltype.combatnpcattack then
		channeltext = c_textformat("CHAT_FORMAT_COMBAT", channeltext)
	end
	local viewtext, tagarray = richtext_parse(channeltext, chat.equip, richtextflag.removeunstable)
	local channelcolor = csvchat_getchannelcolor(chat.type)
	local r, g, b = HexRGB(channelcolor)
	local preset = {}
	preset.histroyid = chat.histroyid
	preset.viewtext = viewtext
	preset.viewtagarray = tagarray
	preset.viewcolor_r = r
	preset.viewcolor_g = g
	preset.viewcolor_b = b
	self:settext(viewtext)
	local width, height = self:getsize()
	local renderwidth, renderheight = self:getrendersize()
	preset.viewwidth = width
	preset.viewheight = renderheight
	return preset
end

function _uitextclass:setchat(chat)
	self:setcolor(chat.viewcolor_r, chat.viewcolor_g, chat.viewcolor_b, 1.0)
	self:settext(chat.viewtext)
    self:setsize(chat.viewwidth, chat.viewheight)
	self.tagarray = chat.viewtagarray
end
