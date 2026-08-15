
function _uilistclass:updateslider()
    local wheeling = false
    if self._slideranim ~= nil then
        if wheel_getwheeling(self._slideranim) then
            wheeling = true
            local val = wheel_getsmooth(self._slideranim)
            local overed = self:applyslider(val, self._slideranim.scrolltype ~= uilistscrolltype.limit)
            if overed then
                if self._slideranim.scrolltype == uilistscrolltype.restore then
                    if self._slideranim.scrollstate == uilistscrollstate.normal then
                        local decelslider = wheel_getwheeltarget(self._slideranim)
                        local listsize = self:getlistsize()
                        if decelslider < 0.0 then
                            local limit = -listsize
                            decelslider = math.max(decelslider, limit)
                        else
                            local limit = self:getscrollmax() + listsize
                            decelslider = math.min(decelslider, limit)
                        end
                        wheel_set(self._slideranim, self._slider, decelslider, 0.3, false)
                        self._slideranim.scrollstate = uilistscrollstate.decel
                    end
                elseif self._slideranim.scrolltype == uilistscrolltype.limit then
                    if self._slideranim.scrollstate == uilistscrollstate.normal then
                        local decelslider = self:getscrollrestore()
                        if decelslider ~= nil then
                            wheel_set(self._slideranim, self._slider, decelslider, 0.3, false)
                            self._slideranim.scrollstate = uilistscrollstate.back
                        else
                            wheeling = false
                            wheel_stop(self._slideranim)
                        end
                    end
                end
            end
        elseif self._slideranim.scrollstate == uilistscrollstate.decel then
            local backslider = self:getscrollrestore()
            if backslider ~= nil then
                wheeling = true
                self._slideranim.scrollstate = uilistscrollstate.back
                wheel_set(self._slideranim, self._slider, backslider, 0.3, true)
            end
        end
    end
end

function uilistclassscrollbarex_delegate_top(sender, event)
    sender.list:setscrolltop(0.2)
end

function uilistclassscrollbarex_delegate_up_update(list)
    list:addscroll(-list:getscrollmax() * time_frame)
end

function uilistclassscrollbarex_delegate_up(sender, event)
    local list = sender.list
    if event.name == "mousedown" then
        event_register(eventtype.update, uilistclassscrollbarex_delegate_up_update, list._panel, list)
    elseif event.name == "mouseup" then
        event_deregister(eventtype.update, uilistclassscrollbarex_delegate_up_update, list)
    end
end

function uilistclassscrollbarex_delegate_down_update(list)
    list:addscroll(list:getscrollmax() * time_frame)
end

function uilistclassscrollbarex_delegate_down(sender, event)
    local list = sender.list
    if event.name == "mousedown" then
        event_register(eventtype.update, uilistclassscrollbarex_delegate_down_update, list._panel, list)
    elseif event.name == "mouseup" then
        event_deregister(eventtype.update, uilistclassscrollbarex_delegate_down_update, list)
    end
end

function uilistclassscrollbarex_delegate_bottom(sender, event)
    sender.list:setscrollbottom(0.2)
end

function uilistclassscrollbarex_delegate_thumb(sender, event)
    local list = sender.list
    if event.name == "dragstart" then
        local x, y, w, h = sender:getabsolute()
        sender.offset_x = event.mousex - (x + w / 2)
        sender.offset_y = event.mousey - (y + h / 2)
    elseif event.name == "drag" then
        local x = event.mousex - sender.offset_x
        local y = event.mousey - sender.offset_y
        local slider = list:positiontoslider(x, y)
        list:setscroll(slider, 0.0, uilistscrolltype.limit)
    end
end

function _uilistclass:positiontoslider(mousex, mousey)
    local x1, y1, w1, h1 = self.scrollbarex.button_up:getabsolute()
    local x2, y2, w2, h2 = self.scrollbarex.button_down:getabsolute()
    local w, h = self.scrollbarex.button_thumb:getsize()
    local top = y1 - h / 2
    local bottom = y2 + h2 + h / 2
    local slider = math.clamp((top - mousey) / (top - bottom), 0.0, 1.0)
    return slider * self:getscrollmax()
end

function _uilistclass:createscrollbar()
    local panel = self._panel
    local directory = self._widgetpath
    local image_scrollexbg = panel:getwidget(directory .. "/image_scrollbg")
    if image_scrollexbg == nil then
        return
    end

    self.scrollbarex = {}
    self.scrollbarex.alwaysvisible = false
    self.scrollbarex.leftside = false
    self.scrollbarex.image_scrollexbg = image_scrollexbg

    self.scrollbarex.button_thumb = panel:getwidget(directory .. "/button_thumb")
    self.scrollbarex.button_thumb:setdelegate(uilistclassscrollbarex_delegate_thumb)
    self.scrollbarex.button_thumb.list = self

    self.scrollbarex.button_top = panel:getwidget(directory .. "/button_top")
    self.scrollbarex.button_top:setdelegate(uilistclassscrollbarex_delegate_top)
    self.scrollbarex.button_top.list = self

    self.scrollbarex.button_up = panel:getwidget(directory .. "/button_up")
    self.scrollbarex.button_up:setdelegate(uilistclassscrollbarex_delegate_up)
    self.scrollbarex.button_up.list = self

    self.scrollbarex.button_down = panel:getwidget(directory .. "/button_down")
    self.scrollbarex.button_down:setdelegate(uilistclassscrollbarex_delegate_down)
    self.scrollbarex.button_down.list = self

    self.scrollbarex.button_bottom = panel:getwidget(directory .. "/button_bottom")
    self.scrollbarex.button_bottom:setdelegate(uilistclassscrollbarex_delegate_bottom)
    self.scrollbarex.button_bottom.list = self
end

function _uilistclass:setscrollbarexalwaysvisible(visible)
    if self.scrollbarex ~= nil then
        self.scrollbarex.alwaysvisible = visible
        self:updatescrollbarexvisible()
        self:updatescrollbarexposition()
    end
end

function _uilistclass:updatescrollbarexvisible()
    if self.scrollbarex ~= nil then
        local visible = self.scrollbarex.alwaysvisible or self._contentsize > self:getlistsize()
        self.scrollbarex.image_scrollexbg:setvisible(visible)
        self.scrollbarex.button_thumb:setvisible(visible)
        self.scrollbarex.button_top:setvisible(visible)
        self.scrollbarex.button_up:setvisible(visible)
        self.scrollbarex.button_down:setvisible(visible)
        self.scrollbarex.button_bottom:setvisible(visible)
    end
end

function _uilistclass:updatescrollbarexposition()
    if self.scrollbarex ~= nil then
        local visible = self.scrollbarex.alwaysvisible or self._contentsize > self:getlistsize()
        if visible then
            local x1, y1, w1, h1 = self.scrollbarex.button_up:getabsolute()
            local x2, y2, w2, h2 = self.scrollbarex.button_down:getabsolute()
            local local_x1, local_y1 = self.scrollbarex.button_up:getposition()
            local w, h = self.scrollbarex.button_thumb:getsize()
            local top = y1 - h / 2
            local bottom = y2 + h2 + h / 2
            local pos = self._slider / self:getscrollmax()
            pos = math.clamp(pos, 0.0, 1.0)
            pos = pos * (top - bottom)
            local x = local_x1 + w1 / 2 - w / 2
            local y = local_y1 - pos - h
            self.scrollbarex.button_thumb:setposition(x, y)
        end
    end
end
