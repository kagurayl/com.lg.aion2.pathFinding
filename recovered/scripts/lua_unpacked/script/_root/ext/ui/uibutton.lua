
_uibuttonclass = _inheritclass("_uibuttonclass", _uiwidgetclass)

function _uibuttonclass:settext(val,...)
	c_uitext_settext(self._panel._uiname, self._widgetpath .. "/button_text", val, ...)
end

function _uibuttonclass:settextscale(val,...)
    local button_text = self._panel:getwidget(self._widgetpath .. "/button_text")
	button_text:settextscale(val, ...)
end

function _uibuttonclass:settextraw(val)
	c_uitext_settextraw(self._panel._uiname, self._widgetpath .. "/button_text", val)
end

function _uibuttonclass:settextrawscale(val)
    local button_text = self._panel:getwidget(self._widgetpath .. "/button_text")
	button_text:settextrawscale(val)
end

function _uibuttonclass:settextcolor(r, g, b, a)
    local button_text = self._panel:getwidget(self._widgetpath .. "/button_text")
	button_text:setcolor(r, g, b, a)
end

function _uibuttonclass:settexthexcolor(color)
    local button_text = self._panel:getwidget(self._widgetpath .. "/button_text")
	button_text:sethexcolor(color)
end

function _uibuttonclass:setbuttoncolor(r, g, b, a)
    c_uibutton_setcolor(self._panel._uiname, self._widgetpath, r, g, b, a)
end

function _uibuttonclass:getbuttoncolor()
    return c_uibutton_getcolor(self._panel._uiname, self._widgetpath)
end

function _uibuttonclass:setsprite(sprite)
    return c_uiimage_setsprite(self._panel._uiname, self._widgetpath, unity_spritepath(sprite))
end

function _uibuttonclass:setthreshold(threshold)
    c_uiimage_setthreshold(self._panel._uiname, self._widgetpath, threshold)
end

function _uibuttonclass:setenablenofade(enable)
    self:setfade(0.0)
    self:setenable(enable)
    self:setfade(0.1)
end

function _uibuttonclass:setfade(fade)
    c_uibutton_setfade(self._panel._uiname, self._widgetpath, fade)
end
