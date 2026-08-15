
function createuiwidget(typename)
    if typename == "Button" or typename == "ScriptButton" then
        return _uibuttonclass.new()
    elseif typename == "Slider" then
        return _uisliderclass.new()
    elseif typename == "Image" or typename == "ScriptImage" then
        return _uiimageclass.new()
    elseif typename == "Text" then
        return _uitextclass.new()
    elseif typename == "EditableText" then
        return _uieditclass.new()
    elseif typename == "ListView" then
        return _uilistclass.new()
    elseif typename == "ProgressBar" then
        return _uiprogressclass.new()
    elseif typename == "CheckBox" then
        return _uicheckboxclass.new()
    else
        return _uiwidgetclass.new()
    end
end

_uiwidgetclass = _class("_uiwidgetclass")

function _uiwidgetclass:getname()
	return self._widgetname
end

function _uiwidgetclass:setdelegate(delegate)
    self._delegate = delegate
end

function _uiwidgetclass:setvisible(visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.visible, uivisibleadvance.collapsed)
    c_uiwidget_setvisible(self._panel._uiname, self._widgetpath, visibleadvance)
end

function _uiwidgetclass:setvisiblenothit(visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.selfhittestinvisible, uivisibleadvance.collapsed)
    c_uiwidget_setvisible(self._panel._uiname, self._widgetpath, visibleadvance)
end

function _uiwidgetclass:setvisibleadvance(visible)
    c_uiwidget_setvisible(self._panel._uiname, self._widgetpath, visible)
end

function _uiwidgetclass:getvisible()
    local visibleadvance = c_uiwidget_getvisible(self._panel._uiname, self._widgetpath)
    return visibleadvance ~= uivisibleadvance.collapsed and visibleadvance ~= uivisibleadvance.hidden
end

function _uiwidgetclass:getvisibleadvance()
    return c_uiwidget_getvisible(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setenable(enable)
	c_uiwidget_setenable(self._panel._uiname, self._widgetpath, enable)
end

function _uiwidgetclass:getenable()
	return c_uiwidget_getenable(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setoffset(left, top, right, bottom)
	c_uiwidget_setoffset(self._panel._uiname, self._widgetpath, left, top, right, bottom)
end

function _uiwidgetclass:getoffset()
	return c_uiwidget_getoffset(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setanchor(xmin, ymin, xmax, ymax)
	c_uiwidget_setanchor(self._panel._uiname, self._widgetpath, xmin, ymin, xmax, ymax)
end

function _uiwidgetclass:getanchor()
	return c_uiwidget_getanchor(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setpivot(x, y)
	c_uiwidget_setpivot(self._panel._uiname, self._widgetpath, x, y)
end

function _uiwidgetclass:getpivot()
	return c_uiwidget_getpivot(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setscale(x, y)
	c_uiwidget_setscale(self._panel._uiname, self._widgetpath, x, y)
end

function _uiwidgetclass:getscale()
	return c_uiwidget_getscale(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setrotation(x, y, z)
	c_uiwidget_setrotation(self._panel._uiname, self._widgetpath, x, y)
end

function _uiwidgetclass:getrotation()
	return c_uiwidget_getrotation(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setposition(x,y)
	c_uiwidget_setposition(self._panel._uiname, self._widgetpath, x, y)
end

function _uiwidgetclass:setposition3d(worldx, worldy, worldz, uioffsetx, uioffsety, opacity)
	c_uiwidget_setposition3d(self._panel._uiname, self._widgetpath, worldx, worldy, worldz, uioffsetx, uioffsety, opacity)
end

function _uiwidgetclass:getposition()
	return c_uiwidget_getposition(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setsize(w,h)
	c_uiwidget_setsize(self._panel._uiname, self._widgetpath, w, h)
end

function _uiwidgetclass:getsize()
	return c_uiwidget_getsize(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setrect(x,y,w,h)
	c_uiwidget_setrect(self._panel._uiname, self._widgetpath, x,y,w,h)
end

function _uiwidgetclass:getrect()
	return c_uiwidget_getrect(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:getabsolute()
	return c_uiwidget_getabsolute(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:mouseinrect(mousex, mousey)
    local x,y,w,h = self:getabsolute()
    return mousex >= x and mousex <= x + w and mousey >= y and mousey <= y + h
end

function _uiwidgetclass:settransform(pivot_x, pivot_y, trans_x, trans_y, scale_x, scale_y, shear_x, shear_y, angle)
	c_uiwidget_settransform(self._panel._uiname, self._widgetpath, pivot_x, pivot_y, trans_x, trans_y, scale_x, scale_y, shear_x, shear_y, angle)
end

function _uiwidgetclass:gettransform()
	return c_uiwidget_gettransform(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setrgb(r, g, b)
	c_uiwidget_setrgb(self._panel._uiname, self._widgetpath, r, g, b)
end

function _uiwidgetclass:setopacity(opacity)
	c_uiwidget_setopacity(self._panel._uiname, self._widgetpath, opacity)
end

function _uiwidgetclass:setcolor(r, g, b, a)
	c_uiwidget_setcolor(self._panel._uiname, self._widgetpath, r, g, b, a)
end

function _uiwidgetclass:setcolorverify(r, g, b, a)
    if self._verifycolor_r ~= r or self._verifycolor_g ~= g or self._verifycolor_b ~= b or self._verifycolor_a ~= a then
        self._verifycolor_r = r
        self._verifycolor_g = g
        self._verifycolor_b = b
        self._verifycolor_a = a
    	c_uiwidget_setcolor(self._panel._uiname, self._widgetpath, r, g, b, a)
    end
end

function _uiwidgetclass:sethexcolor(color)
	c_uiwidget_sethexcolor(self._panel._uiname, self._widgetpath, color)
end

function _uiwidgetclass:getcolor()
	return c_uiwidget_getcolor(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:getopacity()
	return c_uiwidget_getopacity(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:setfocus()
	c_uiwidget_setfocus(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:getfocus()
	return c_uiwidget_getfocus(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:playuianim(animname, speed)
	return c_uiwidget_playanim(self._panel._uiname, self._widgetpath, animname, speed)
end

function _uiwidgetclass:setuianimspeed(animname, speed)
	c_uiwidget_setanimspeed(self._panel._uiname, self._widgetpath, animname, speed)
end

function _uiwidgetclass:stopuianim(animname)
    if animname ~= nil then
        c_uiwidget_stopanim(self._panel._uiname, self._widgetpath, animname)
    else
        c_uiwidget_stopanim(self._panel._uiname, self._widgetpath, nil)
    end
end

function _uiwidgetclass:getwidget(widgetpath)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetpath)
    return self._panel:getwidget(fullpath)
end

function _uiwidgetclass:getwidgetlist(toplevel)
    return c_uigetwidgetlist(self._panel._uiname, self._widgetpath, toplevel)
end

function _uiwidgetclass:setwidgetvisible(widgetpath, visible)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetpath)
    self._panel:setwidgetvisible(fullpath, visible)
end

function _uiwidgetclass:setwidgetvisiblenothit(widgetpath, visible)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetpath)
    self._panel:setwidgetvisiblenothit(fullpath, visible)
end

function _uiwidgetclass:setwidgetdelegate(widgetpath, delegate)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetpath)
    self._panel:setwidgetdelegate(fullpath, delegate)
end

function _uiwidgetclass:clone(name)
	c_uiwidget_clone(self._panel._uiname, self._widgetpath, name)
    local directory, filetitle = string.getpathtitle(self._widgetpath)
    if directory ~= filetitle then
        return self._panel:getwidget(string.format("%s/%s", directory, name))
    else
        return self._panel:getwidget(name)
    end
end

function _uiwidgetclass:cache()
	return c_uiwidget_cache(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:loadsubui(filename, uiname)
	c_uiwidget_loadsubui(self._panel._uiname, self._widgetpath, unity_uipath(filename), uiname)
end

function _uiwidgetclass:unloadsubui()
	c_uiwidget_unloadsubui(self._panel._uiname, self._widgetpath)
end

function _uiwidgetclass:sethandlepress(enable)
    c_uiwidget_handlepress(self._panel._uiname, self._widgetpath, enable)
end

function _uiwidgetclass:sethandledrag(handle)
    c_uiwidget_handledrag(self._panel._uiname, self._widgetpath, handle)
end

function _uiwidgetclass:sethandleregion(handle)
    c_uiwidget_handleregion(self._panel._uiname, self._widgetpath, handle)
end

function _uiwidgetclass:sethandlewheel(handle)
    c_uiwidget_handlewheel(self._panel._uiname, self._widgetpath, handle)
end
