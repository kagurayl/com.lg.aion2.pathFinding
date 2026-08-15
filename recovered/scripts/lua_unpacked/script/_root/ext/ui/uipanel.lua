
uivisibleadvance = 
{
    visible = 0,
    collapsed = 1,
    hidden = 2,
    hittestinvisible = 3,
    selfhittestinvisible = 4,
}

uilayer =
{
    nameui = 0,
    overlay = 1,
    bottom = 2,
    score = 3,
    bottomtop = 4,
    normal = 5,
    top = 6,
    tips = 7,
    message = 8,
    cover = 9,
    menu = 10,
    tutorial = 11,
    loadingbg = 12,
    loading = 13,
}

uialign =
{
	left = 0x00000000,
    leftcenter = 0x00000001,
 	center = 0x00000002,
    rightcenter = 0x00000004,
    right = 0x00000008,
    top = 0x00000000,
    topcenter = 0x00000010,
    vcenter = 0x00000020,
    bottomcenter = 0x00000040,
    bottom = 0x00000080,
}

uiflag =
{
	escapeclose = 0x1,
 	holdonclear = 0x2,
    cgmodevisible = 0x4,
    hidemodevisible = 0x8,
    fullscreen = 0x10,
    placeleft = 0x20,
    placeright = 0x40,
    placeall = 0x60,
    scale = 0x80,
}

_uipanelclass = _class("_uipanelclass")

function uipanel_createsimplehandle(zlayer, flag)
    local handle = _uipanelclass.new()
    handle._zlayer = zlayer
    handle._flag = flag
    handle._visible = uivisibleadvance.visible
    handle._widget = {}
	return handle
end

function uipanel_createhandle(fullpath, zlayer, flag, audioopen, audioclose)
    local handle = uipanel_createsimplehandle(zlayer, flag)
    handle:setfilename(fullpath)
    handle._audioopen = audioopen
    handle._audioclose = audioclose
	return handle
end

function uipanel_createnamehandle(fullpath, uiname, zlayer, flag)
    local handle = uipanel_createsimplehandle(zlayer, flag)
    handle:setfilename(fullpath, uiname)
	return handle
end

function _uipanelclass:setfilename(fullpath, uiname)
    local directory, filetitle = string.getpathtitle(fullpath)
    if uiname == nil then
        uiname = string.gsub(fullpath, "/", "_")
    end
    self._filename = unity_uipath(fullpath) 
    self._delegatetitle = string.lower(filetitle)
    self._uiname = uiname
end

function _uipanelclass:open(...)
	if not self._alive then
        self._alive = true
        self._escape = bit.band(self._flag, uiflag.escapeclose) > 0
        uimanager_addhandle(self)
		c_uiopen(self._filename, self._uiname, self._zorder)
        self._widget = {}
        self._visible = uivisibleadvance.visible
        if bit.band(self._flag, uiflag.scale) > 0 then
            local scale = uimanager_getscale()
            if scale ~= 1.0 then
                self:setscale(scale)
            end
        end
        local func = _G[self._delegatetitle .. "_onopen"]
        if func ~= nil then
            func(...)
        end
        if self._audioopen ~= nil then
            audiomanager_playaudioui(self._audioopen)
        end
        tutorial_check()
        self:updatevisible()
	end
end

function _uipanelclass:close()
    if self._alive then
        uimanager_removehandle(self)
        self._alive = false
        event_onpanelclose(self:getname())
        local func = _G[self._delegatetitle .. "_onclose"]
        if func ~= nil then
            func()
        end
		c_uiclose(self._uiname)
        self._widget = nil
        self._visible = uivisibleadvance.collapsed
        if self._parent ~= nil then
            self._parent:removechild(self)
            self._parent = nil
        end
        if self._child ~= nil then
            for i=#self._child,1, -1 do
                self._child[i].parent = nil
                self._child[i]:close()
                table.remove(self._child, i)
            end
        end
        if self._audioclose ~= nil then
            audiomanager_playaudioui(self._audioclose)
        end
        tutorial_check()
	end
end

function _uipanelclass:removechild(child)
    if self._child ~= nil then
        for i=#self._child,1, -1 do
            if self._child[i] == child then
                table.remove(self._child, i)
            end
        end
    end
end

function _uipanelclass:setparent(parent)
	if self._parent ~= nil then
        self._parent:removechild(self)
    end
    self._parent = parent
    if parent ~= nil then
        if parent._child == nil then
            parent._child = {}
        end
        parent._child[#parent._child + 1] = self
    end
end

function _uipanelclass:alive()
	return self._alive
end

function _uipanelclass:null()
	return not self._alive
end

function _uipanelclass:getname()
	return self._uiname
end

function _uipanelclass:getwidget(widgetpath)
    local obj = self._widget[widgetpath]
    if obj ~= nil then
        return obj
    end

    local typename = c_uiwidget_gettypename(self._uiname, widgetpath)
    if typename == nil or string.len(typename) == 0 then
        return nil
    end

    local uiwidget = createuiwidget(typename)
    if uiwidget == nil then
        return nil
    end
    uiwidget._panel = self
    uiwidget._widgettypename = typename
    uiwidget._widgetpath = widgetpath
    local split = string.find(widgetpath, "/")
    if split ~= nil then
        uiwidget._widgetname = string.sub(widgetpath, split + 1)
    else
        uiwidget._widgetname = widgetpath
    end
    self._widget[widgetpath] = uiwidget
    return uiwidget
end

function _uipanelclass:getwidgetlist(toplevel)
    return c_uigetwidgetlist(self._uiname, nil, toplevel)
end

function _uipanelclass:setscale(scale)
    c_uisetscale(self._uiname, scale)
end

function _uipanelclass:setopacity(opacity)
	return c_uisetopacity(self._uiname, opacity)
end

function _uipanelclass:setanchor(xmin, ymin, xmax, ymax)
	c_uisetanchor(self._uiname, xmin, ymin, xmax, ymax)
end

function _uipanelclass:setpivot(x, y)
	c_uisetpivot(self._uiname, x, y)
end

function _uipanelclass:setposition(x, y)
	c_uisetposition(self._uiname, x, y)
end

function _uipanelclass:getposition()
	return c_uigetposition(self._uiname)
end

function _uipanelclass:getsize()
	return c_uigetsize(self._uiname)
end

function _uipanelclass:getabsolute()
	return c_uigetabsolute(self._uiname)
end

function _uipanelclass:setvisible(visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.visible, uivisibleadvance.collapsed)
    self._visible = visibleadvance
    self:updatevisible()
end

function _uipanelclass:setvisibleadvance(visible)
    self._visible = visible
	updatevisible()
end

function _uipanelclass:getvisible(visible)
    return self._visible == nil or self._visible == uivisibleadvance.visible or self._visible == uivisibleadvance.hittestinvisible or self._visible == uivisibleadvance.selfhittestinvisible
end

function _uipanelclass:updatevisible()
    local visible = self._visible
    if uimanager_getcgmode() then
        if bit.band(self._flag, uiflag.cgmodevisible) == 0 then
            visible = uivisibleadvance.collapsed
        end
    elseif uimanager_gethideui() then
        if bit.band(self._flag, uiflag.hidemodevisible) == 0 then
            visible = uivisibleadvance.collapsed
        end
    end
    c_uisetvisible(self._uiname, visible)
end

function _uipanelclass:setwidgetvisible(widgetpath, visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.visible, uivisibleadvance.collapsed)
    c_uiwidget_setvisible(self._uiname, widgetpath, visibleadvance)
end

function _uipanelclass:setwidgetvisiblenothit(widgetpath, visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.selfhittestinvisible, uivisibleadvance.collapsed)
    c_uiwidget_setvisible(self._uiname, widgetpath, visibleadvance)
end

function _uipanelclass:setwidgetenable(widgetpath, enable)
    c_uiwidget_setenable(self._uiname, widgetpath, enable)
end

function _uipanelclass:setwidgetpositon(widgetpath, x, y)
    c_uiwidget_setposition(self._uiname, widgetpath, x, y)
end

function _uipanelclass:setwidgetsize(widgetpath, w, h)
    c_uiwidget_setsize(self._uiname, widgetpath, w, h)
end

function _uipanelclass:setwidgetdelegate(widgetpath, delegate)
    local widget = self:getwidget(widgetpath)
    if widget ~= nil then
        widget._delegate = delegate
    else
        debugerror("failed setwidgetdelegate:" .. self._uiname .. "/" .. widgetpath)
    end
end

function _uipanelclass:batch(id, data)
	c_uiwidget_batch(self._uiname, id, data)
end

function _uipanelclass:hideunused(title, index)
	while true do
		local widget = self:getwidget(string.format("%s%d", title, index))
		if widget == nil then
			return
		end
		widget:setvisible(false)
		index = index + 1
	end
end

function _uipanelclass:getfocus(x, y)
	return c_uigetfocus(self.id, x, y)
end
