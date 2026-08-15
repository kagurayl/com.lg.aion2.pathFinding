
_uiprogressclass = _inheritclass("_uiprogressclass", _uiwidgetclass)

function _uiprogressclass:setpercent(percent)
	c_uiprogress_setpercent(self._panel._uiname, self._widgetpath, percent)
end

function _uiprogressclass:setpercentverify(percent)
    if self._verifypercent ~= percent then
        self._verifypercent = percent
    	c_uiprogress_setpercent(self._panel._uiname, self._widgetpath, percent)
    end
end

function _uiprogressclass:getpercent()
	return c_uiprogress_getpercent(self._panel._uiname, self._widgetpath)
end

function _uiprogressclass:setsprite(sprite)
    return c_uiimage_setsprite(self._panel._uiname, self._widgetpath, unity_spritepath(sprite))
end

function _uiprogressclass:setmaterialsprite(texturename, texturefile)
    return c_uiimage_setmaterialsprite(self._panel._uiname, self._widgetpath, texturename, unity_spritepath(texturefile))
end
