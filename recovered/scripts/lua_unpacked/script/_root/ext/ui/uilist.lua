
uilistflag =
{
	horizontal = 0x1,
    vertical = 0x2,
    async = 0x4,
    scrolllimit = 0x8,
    scrolldisable = 0x10,
}

uilistscrolltype =
{
    limit = 1,
	restore = 2,
 	hold = 3,
}

uilistscrollstate =
{
    normal = 1,
    decel = 2,
    back = 3,
}

_uilistclass = _inheritclass("_uilistclass", _uiwidgetclass)

function _uilistclass:init(flag)
    self._horizontal = bit.band(flag, uilistflag.horizontal) > 0
    self._addasync = bit.band(flag, uilistflag.async) > 0
    self._scrolllimit = bit.band(flag, uilistflag.scrolllimit) > 0
    self._scrolldisable = bit.band(flag, uilistflag.scrolldisable) > 0
    self:setdelegate(uilistclass_mainevent_delegate)
    self:clear()
    self:createscrollbar()
    local list_event = self._panel:getwidget(self._widgetpath .. "/list_content")
    if list_event ~= nil then
        list_event.list = self
        list_event:setdelegate(uilistclass_mainevent_delegate)
    end
    event_register(eventtype.update, uilistclass_delegate_update, self._panel, self)
end

function _uilistclass:loadtemplate(instpath, width, height)
    if self._listtemplate == nil then
        self._listtemplate = {}
    end
    local template = self._listtemplate[instpath]
    if template == nil then
        template = {}
        template.instpath = instpath
        if width == nil or height == nil then
            template.width, template.height = c_uilist_loadtemplate(self._panel._uiname, unity_uipath(instpath))
        end
        template.idle = {}
        self._listtemplate[instpath] = template
    end
    if width ~= nil and height ~= nil then
        template.width = width
        template.height = height
    end
    return template
end

function _uilistclass:setasyncdelegate(asyncdelegate)
    self._delegateasync = asyncdelegate
end

function _uilistclass:setclickdelegate(clickdelegate)
    self._delegateclick = clickdelegate
end

function _uilistclass:savestate()
    if self._listline ~= nil and #self._listline > 0 then
        self._savestate = {}
        self._savestate._slider = self._slider
        self._savestate._selectline = {}
        for i=1, #self._listline do
            local listline = self._listline[i]
            if listline:getselect() then
                self._savestate._selectline[#self._savestate._selectline + 1] = listline:getname()
            end
        end
    end
end

function _uilistclass:restorestate()
    if self._savestate == nil then
        return
    end
    if self._listline ~= nil then
        for i=1, #self._listline do
            local listline = self._listline[i]
            local select = false
            for j=1, #self._savestate._selectline do
                local name = self._savestate._selectline[j]
                if listline:getname() == name then
                    select = true
                    break
                end
            end
            listline:setselect(select)
        end
    end
    self:applyslider(self._savestate._slider, false)
    self._savestate = nil
end

function _uilistclass:clearselect()
    if self._listline ~= nil then
        for i=1, #self._listline do
            self._listline[i]:setselect(false)
        end
    end
end

function _uilistclass:clear()
    if self._listline ~= nil then
        for i=1, #self._listline do
            local listline = self._listline[i]
            if listline._widgetpath ~= nil then
                listline._template.idle[#listline._template.idle + 1] = listline._widgetpath
                listline:setvisible(false)
                listline._widgetpath = nil
            end
        end
    end

    self._listline = {}
    self._nameline = {}
    self._updateline = {}
    self._listsize = 0.0
    self._contentsize = 0.0
    self._scrollmax = 0.0
    self._slider = 0.0
    self._sliderview = 1
    self._viewstart = 1
    self._viewcount = 0
    self._updateview = false
    local x, y, w, h = self:getrect()
    self._listsize = math.ternary(self._horizontal, w, h)
    self:updatescrollbarexvisible()
    self:updatescrollbarexposition()
    self:updateview()
end

function _uilistclass:getlistsize()
    return self._listsize
end

function _uilistclass:getscrollmax()
    return math.max(0.0, self._scrollmax)
end

function _uilistclass:getcontentsize()
    return self._contentsize
end

function _uilistclass:setlistsize(w, h)
    self:setsize(w, h)
    self._listsize = math.ternary(self._horizontal, w, h)
    self._scrollmax = self._contentsize - self:getlistsize()
    self:updateview()
end

function _uilistclass:updatecontentsize()
    self._contentsize = 0.0
    for i=1, #self._listline do
        local listline = self._listline[i]
        listline._sliderstart = self._contentsize
        listline._sliderend = listline._sliderstart + listline._linesize
        self._contentsize = self._contentsize + listline._linesize
    end
    self._scrollmax = self._contentsize - self:getlistsize()
    self:updatescrollbarexvisible()
    self:updatescrollbarexposition()
    self:updateview()
end

function _uilistclass:getcount()
    return #self._listline
end

function _uilistclass:getlinefromindex(index)
    return self._listline[index]
end

function _uilistclass:getlinefromname(scriptname)
    return self._nameline[scriptname]
end

function _uilistclass:selectline(selectlinename)
    for i=1,#self._listline do
        local listline = self._listline[i]
        if listline._scriptname == selectlinename then
            listline:setselect(true)
        else
            listline:setselect(false)
        end
    end
end

function _uilistclass:selectall()
    for i=1,#self._listline do
        self._listline[i]:setselect(true)
    end
end

function _uilistclass:getselectarray()
    local listline = {}
    for i=1,#self._listline do
        if self._listline[i]:getselect() then
            listline[#listline + 1] = self._listline[i]:getdata()
        end
    end
    return listline
end

function _uilistclass:getfirstselect()
    for i=1,#self._listline do
        if self._listline[i]:getselect() then
            return self._listline[i]:getdata()
        end
    end
end
