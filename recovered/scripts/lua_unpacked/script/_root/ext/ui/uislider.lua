
_uisliderclass = _inheritclass("_uisliderclass", _uiwidgetclass)

function _uisliderclass:setminmax(min, max)
	c_uislider_setminmax(self._panel._uiname, self._widgetpath, min, max)
end

function _uisliderclass:setslider(value)
	c_uislider_setvalue(self._panel._uiname, self._widgetpath, value)
end

function _uisliderclass:getvalue()
	return c_uislider_getvalue(self._panel._uiname, self._widgetpath)
end
