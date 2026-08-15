
uiedittype =
{
	default = 0,
 	integer = 1,
}

_uieditclass = _inheritclass("_uieditclass", _uiwidgetclass)

function _uieditclass:settext(text)
	c_uiedit_settext(self._panel._uiname, self._widgetpath, text)
end

function _uieditclass:settextraw(text)
	c_uiedit_settextraw(self._panel._uiname, self._widgetpath, text)
end

function _uieditclass:sethinttext(text)
	c_uiedit_sethinttext(self._panel._uiname, self._widgetpath, text)
end

function _uieditclass:sethinttextraw(text)
	c_uiedit_sethinttextraw(self._panel._uiname, self._widgetpath, text)
end

function _uieditclass:gettext()
	return c_uiedit_gettext(self._panel._uiname, self._widgetpath)
end

function _uieditclass:gethinttext()
	return c_uiedit_gethinttext(self._panel._uiname, self._widgetpath)
end

function _uieditclass:settype(type)
	return c_uiedit_settype(self._panel._uiname, self._widgetpath, type)
end

function _uieditclass:setlocation(line, offset)
	return c_uiedit_setlocation(self._panel._uiname, self._widgetpath, line, offset)
end

function _uieditclass:setverifyinteger(min, max)
	local text = self:gettext()
	if text ~= nil and #text > 0 then
		local count = string.tointeger(text)
		if count ~= nil then
			if min ~= nil and count < min then
				count = min
			elseif max ~= nil and count > max then
				count = max
			end
			self:settext(count)
			return true
		end
	end
	return false
end
