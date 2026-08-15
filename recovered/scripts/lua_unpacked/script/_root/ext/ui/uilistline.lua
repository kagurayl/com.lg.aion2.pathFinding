
_uilistlineclass = _class("_uilistlineclass")

function _uilistlineclass:initwidget()
    local eventwidget = self:getwidget("image_event")
    if eventwidget ~= nil then
        eventwidget:setdelegate(uilistclass_lineevent_delegate)
    end
    self._selectwidget = self:getwidget("image_select")
    if self._selectwidget ~= nil and not self._select and not self._hover then
        self._selectwidget:setopacity(0.0)
    end
end

function _uilistlineclass:unselectwidget()
    self._selectwidget = nil
end

function _uilistlineclass:update()
    if self._selectwidget == nil or self._hoverstatetimestart == nil or self._select then
        return false
    end
    local opacity = (time_game - self._hoverstatetimestart) / self._hoverstatetimelength
    if opacity > 1.0 then
        opacity = 1.0
    end
    if self._hover then
        self._selectwidget:setopacity(opacity)
    else
        self._selectwidget:setopacity(1.0 - opacity)
    end
    return opacity < 1.0
end

function _uilistlineclass:getwidget(widgetpath)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetpath)
    local uiobject = self._list._panel:getwidget(fullpath)
    if uiobject ~= nil then
        uiobject._list = self._list
        uiobject._listline = self
    end
    return uiobject
end

function _uilistlineclass:hidewidget()
    for key, val in pairs(self._list._panel._widget) do
		if string.startwith(val._widgetpath, self._widgetpath) then
            val:setvisible(false)
        end
	end
end

function _uilistlineclass:getasyncvisible()
    return self._widgetpath ~= nil
end

function _uilistlineclass:setvisible(visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.visible, uivisibleadvance.collapsed)
    c_uiwidget_setvisible(self._list._panel._uiname, self._widgetpath, visibleadvance)
end

function _uilistlineclass:setanchor(xmin, ymin, xmax, ymax)
	c_uiwidget_setanchor(self._panel._uiname, self._widgetpath, xmin, ymin, xmax, ymax)
end

function _uilistlineclass:setpivot(x, y)
	c_uiwidget_setpivot(self._panel._uiname, self._widgetpath, x, y)
end

function _uilistlineclass:setposition(x, y)
    c_uiwidget_setposition(self._list._panel._uiname, self._widgetpath, x, y)
end

function _uilistlineclass:setwidgetvisible(widgetname, visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.visible, uivisibleadvance.collapsed)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetname)
    c_uiwidget_setvisible(self._list._panel._uiname, fullpath, visibleadvance)
end

function _uilistlineclass:setwidgetvisiblenothit(widgetname,visible)
    local visibleadvance = math.ternary(visible, uivisibleadvance.selfhittestinvisible, uivisibleadvance.collapsed)
    local fullpath = string.format("%s/%s", self._widgetpath, widgetname)
    c_uiwidget_setvisible(self._list._panel._uiname, fullpath, visibleadvance)
end

function _uilistlineclass:setwidgetdelegate(widgetpath, delegate)
    local widget = self:getwidget(widgetpath)
    if widget ~= nil then
        widget._delegate = delegate
    else
        debugerror("failed setwidgetdelegate:" .. self._list._panel._uiname .. "/" .. self._list._widgetpath .. "/" .. widgetpath)
    end
end

function _uilistlineclass:setsize(size)
    self._linesize = size
end

function _uilistlineclass:getsize()
    return self._linesize
end

function _uilistlineclass:addspace(space)
    self._linesize = self._linesize + space
    self._list._contentsize = self._list._contentsize + space
end

function _uilistlineclass:gettemplatesize()
    return self._template.width, self._template.height
end

function _uilistlineclass:sethoverfade()
    self._hoverstatetimestart = time_game
    self._hoverstatetimelength = 0.1
    local exist = false
    for i=1,#self._list._updateline do
        if self._list._updateline[i]._scriptname == self._scriptname then
            exist = true
            break
        end
    end
    if not exist then
        self._list._updateline[#self._list._updateline + 1] = self
    end
end

function _uilistlineclass:sethover(hover)
    if not self:getselectable() then
        hover = false
    end
    if hover ~= self._hover then
        self._hover = hover
        self:sethoverfade()
    end
end

function _uilistlineclass:setselect(select)
    if not self:getselectable() then
        select = false
    end
    if select ~= self._select then
        self._select = select
        if self._selectwidget ~= nil then
            if self._select then
                self._selectwidget:setopacity(1.0)
            elseif self._hover then
                self._selectwidget:setopacity(1.0)
            else
                self:sethoverfade()
            end
        end
    end
end

function _uilistlineclass:updateselect()
    self._selectwidget = self:getwidget("image_select")
    if self._selectwidget ~= nil then
        if self._select or self._hover then
            self._selectwidget:setopacity(1.0)
        else
            self._selectwidget:setopacity(0.0)
        end
    end
end

function _uilistlineclass:getselect()
    return self._select
end

function _uilistlineclass:setselectable(selectable)
    self._selectable = selectable
    if not selectable then
        self:setselect(false)
    end
end

function _uilistlineclass:scrolltoview()
    self._list:setscroll(self._sliderstart, 0.0, uilistscrolltype.limit)
end

function _uilistlineclass:getselectable()
    return self._scriptname ~= nil and (self._selectable or self._selectable == nil)
end

function _uilistlineclass:setdata(data)
    self._scriptdata = data
end

function _uilistlineclass:getdata()
    return self._scriptdata
end

function _uilistlineclass:getname()
    return self._scriptname
end
