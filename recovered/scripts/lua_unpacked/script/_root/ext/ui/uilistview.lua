
function _uilistclass:add(instpath, linename, linedata)
    local listline = _uilistlineclass.new()
    listline._list = self
    listline._scriptname = linename
    listline._scriptdata = linedata
    listline._hover = false
    listline._select = false
    listline._template = self:loadtemplate(instpath)
    if not self._addasync then
        if #listline._template.idle > 0 then
            listline._widgetpath = listline._template.idle[#listline._template.idle]
            table.remove(listline._template.idle, #listline._template.idle)
        else
            listline._widgetpath = self:addinst(listline._template.instpath)
            listline:setvisible(false)
        end
        listline:initwidget()
    end
    listline._linesize = math.ternary(self._horizontal, listline._template.width, listline._template.height)
    listline._sliderstart = self._contentsize
    listline._sliderend = listline._sliderstart + listline._linesize
    self._contentsize = self._contentsize + listline._linesize
    self._scrollmax = self._contentsize - self:getlistsize()
    if linename ~= nil then
        self._nameline[linename] = listline
    end
    self._listline[#self._listline + 1] = listline
    self._updateview = true
    return listline
end

function _uilistclass:remove(index)
    local listline = self._listline[index]
    if listline._widgetpath ~= nil then
        listline._template.idle[#listline._template.idle + 1] = listline._widgetpath
        listline:setvisible(false)
        listline._widgetpath = nil
    end
    if listline._scriptname ~= nil then
        self._nameline[listline._scriptname] = nil
    end
    self:updatesliderview(math.max(0.0, self._slider - listline._linesize))

    if self._addasync then
        if index < self._viewstart then
            self._viewstart = self._viewstart - 1
        elseif index < self._viewstart + self._viewcount then
            self._viewcount = self._viewcount - 1
        end
    end
    table.remove(self._listline, index)
end

function _uilistclass:addinst(instpath)
    local lineid = "line_" .. csvconfig_generatescriptid()
    local widgetpath = string.format("%s/list_content/%s", self._widgetpath, lineid)
    c_uilist_add(self._panel._uiname, self._widgetpath .. "/list_content", unity_uipath(instpath), lineid)
    c_uiwidget_setanchor(self._panel._uiname, widgetpath, 0, 1, 0, 1)
    c_uiwidget_setpivot(self._panel._uiname, widgetpath, 0, 1)
    return widgetpath
end

function _uilistclass:addspace(space)
    if #self._listline > 0 then
        local listline = self._listline[#self._listline]
        listline:addspace(space)
    end
end

function _uilistclass:updatesliderview(slider)
    self._sliderview = self._viewstart
    if slider < self._slider then
        for i=self._viewstart, 1, -1 do
            if i < #self._listline then
                self._sliderview = i
                if slider >= self._listline[i]._sliderstart then
                    break
                end 
            end
        end
    elseif slider > self._slider then
        for i=self._viewstart, #self._listline do
            self._sliderview = i
            if slider <= self._listline[i]._sliderend then
                break
            end
        end
    end
    self._slider = slider
end

function _uilistclass:applyslider(slider, overscroll)
    local listsize = self:getlistsize()
    local slidermin = 0.0
    local slidermax = self:getscrollmax()
    local overed = slider < slidermin or slider > slidermax
    if overscroll then
        slidermin = -listsize
        slidermax = slidermax + listsize
    end
    slidermin = math.min(slidermin, self._slider)
    slidermax = math.max(slidermax, self._slider)
    if slider < slidermin or slider > slidermax then
        slider = math.clamp(slider, slidermin, slidermax)
    end
    self:updatesliderview(slider)
    self:updatescrollbarexposition()
    self:updateview()
    return overed
end

function _uilistclass:getscrollrestore()
    if self._slider < 0.0 then
        return 0.0
    end
    local scrollmax = self:getscrollmax()
    if self._slider > scrollmax then
        return scrollmax
    end
    return nil
end

function _uilistclass:setscrollrestore(time)
    local slider = self:getscrollrestore()
    if slider ~= nil then
        self:setscroll(slider, time, uilistscrolltype.limit)
    end
end

function _uilistclass:setscroll(slider, time, scrolltype)
    if time ~= nil and time > 0.0 then
        if self._slideranim == nil then
            self._slideranim = {}
            wheel_reset(self._slideranim, 0.0, false)
        end
        wheel_set(self._slideranim, self._slider, slider, time, false)
        self._slideranim.scrolltype = scrolltype
        self._slideranim.scrollstate = uilistscrollstate.normal
    else
        if self._slideranim ~= nil then
            wheel_stop(self._slideranim)
        end
        local overed = self:applyslider(slider, scrolltype ~= uilistscrolltype.limit)
        if overed and scrolltype ~= uilistscrolltype.hold then
            self:setscrollrestore(0.5)
        end
    end
end

function _uilistclass:setscrolltop(time)
    self:setscroll(0.0, time, uilistscrolltype.limit)
end

function _uilistclass:setscrollbottom(time)
    self:setscroll(self._contentsize - self:getlistsize(), time, uilistscrolltype.limit)
end

function _uilistclass:isscrollbottom()
    if self._slideranim ~= nil and wheel_getwheeling(self._slideranim) then
        return wheel_getwheeltarget(self._slideranim) + 1.0 >= self._contentsize - self:getlistsize()
    else
        return self._slider + 1.0 >= self._contentsize - self:getlistsize()
    end
end

function _uilistclass:addscroll(offset, time)
    self:setscroll(self._slider + offset, time, uilistscrolltype.limit)
end

function _uilistclass:updateview()
    self._updateview = false
    local adjuststart = self._sliderview
    local listsize = self:getlistsize()
    local adjustcount = 0
    local adjustsize = 0
    if adjuststart <= #self._listline then
        adjustsize = self._listline[adjuststart]._linesize - (self._slider - self._listline[adjuststart]._sliderstart)
        adjustcount = 1
    end
    for i=adjuststart + 1, #self._listline do
        adjustsize = adjustsize + self._listline[i]._linesize
        adjustcount = adjustcount + 1
        if adjustsize > listsize then
            break
        end
    end
    local adjustend = adjuststart + adjustcount - 1
    local viewend = self._viewstart + self._viewcount - 1
    for i=self._viewstart, viewend do
        if i < adjuststart or i > adjustend then
            local listline = self._listline[i]
            if listline ~= nil and listline._widgetpath ~= nil then
                listline:unselectwidget()
		        listline:setvisible(false)
                if self._addasync then
                    listline._template.idle[#listline._template.idle + 1] = listline._widgetpath
                    listline._widgetpath = nil
                end
            end
        end
    end
    for i=adjuststart, adjustend do
        if i < self._viewstart or i > viewend then
            local listline = self._listline[i]
            if self._addasync then
                if #listline._template.idle > 0 then
                    listline._widgetpath = listline._template.idle[#listline._template.idle]
                    table.remove(listline._template.idle, #listline._template.idle)
                else
                    listline._widgetpath = self:addinst(listline._template.instpath)
                end
                listline:initwidget()
                self._delegateasync(self, listline, listline:getdata())
            end
            listline:setvisible(true)
            listline:updateselect()
        end
    end
    self._viewstart = adjuststart
    self._viewcount = adjustcount
    if adjuststart <= #self._listline then
        local pos = self._listline[adjuststart]._sliderstart - self._slider
        for i=adjuststart, adjustend do
            local listline = self._listline[i]
            if self._horizontal then
                listline:setposition(-pos, 0)
            else
                listline:setposition(0, -pos)
            end
            pos = pos + listline._linesize
        end
    end
end
