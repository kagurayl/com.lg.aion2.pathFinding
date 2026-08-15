
function uilistclass_delegate_update(list)
    for i=#list._updateline,1,-1 do
        if not list._updateline[i]:update() then
            table.remove(list._updateline, i)
        end
    end
    list:updateslider()
    if list._updateview then
        list:updateview()
        list:updatescrollbarexvisible()
        list:updatescrollbarexposition()
    end
end

function uilistclass_mainevent_delegate(sender, event)
    local list = sender.list
    if list:getscrollmax() <= 0.0 and list._scrolllimit then
        return
    end
    if list._scrolldisable then
        return
    end
    if event.name == "dragstart" then
        list._movestart_slider = list._slider
        list._movestart_x = event.mousex
        list._movestart_y = event.mousey
        for i=1,#list._listline do
            list._listline[i]:sethover(false)
        end
    elseif event.name == "drag" then
        if list._movestart_y == nil then
            list._movestart_y = event.mousey
        end 
        local offset = event.mousey - list._movestart_y
        if list._movestart_slider ~= nil then
            offset = offset + list._movestart_slider
        end
        list:setscroll(offset, 0.1, uilistscrolltype.hold)
    elseif event.name == "dragend" then
        if list._slideranim ~= nil and wheel_getwheeling(list._slideranim) then
            local target = wheel_getwheeltarget(list._slideranim)
            local current = wheel_getsmooth(list._slideranim)
            local inertiascale = math.max(1.0, list._contentsize / list:getlistsize())
            local inertia = (target - current) * inertiascale * 5.0
            list:setscroll(current + inertia, 1.0, uilistscrolltype.restore)
        else
            list:setscrollrestore(0.5)
        end
        list._movestart_slider = nil
    elseif event.name == "mousewheel" then
        local slider = list._slider
        if list._slideranim ~= nil and wheel_getwheeling(list._slideranim) then
            slider = wheel_getwheeltarget(list._slideranim)
        end
        list:setscroll(slider - list._contentsize / 100.0 * event.wheely * mousewheelscale, 1.0, uilistscrolltype.limit)
    end
end

function uilistclass_lineevent_delegate(sender, event)
    local listline = sender._listline
    if not listline:getselectable() then
        return
    end
    if event.name == "mousedown" then
        listline:sethover(true)
    elseif event.name == "mouseup" then
        listline:sethover(false)
    elseif event.name == "click" then
        for i=1,#listline._list._listline do
            if listline._list._listline[i]._scriptname ~= scriptname then
                listline._list._listline[i]:setselect(false)
            end
        end
        listline:setselect(true)
        if listline._list._delegateclick ~= nil then
            listline._list._delegateclick(listline, event, listline:getdata())
        end
    end
end
