
local m_uimanager_handle = {}
local m_uimanager_cgmode = false
local m_uimanager_hideui = false
local m_uimanager_scale = 1.0

function uimanager_addhandle(handle)
    local zlayer = handle._zlayer
    uimanager_closecover(handle._flag, zlayer)

    local layerpanel = {}
    for key, val in pairs(m_uimanager_handle) do
        if val._zlayer == zlayer then
            layerpanel[#layerpanel + 1] = val
        end
	end
    table.sort(layerpanel, function(p1, p2) return (p1._zorder < p2._zorder) end)
    local layerzorder = zlayer * 1000
    for i=1,#layerpanel do
        local zorder = layerzorder + 1
        if layerpanel[i]._zorder ~= zorder then
            layerpanel[i]._zorder = layerzorder + i
            c_uisetzorder(layerpanel[i]._uiname, layerpanel[i]._zorder)
        end
    end
    handle._zorder = layerzorder + #layerpanel + 1
    c_uisetzorder(handle._uiname, handle._zorder)
    m_uimanager_handle[handle._uiname] = handle
end

function uimanager_removehandle(handle)
    m_uimanager_handle[handle._uiname] = nil
end

function uimanager_setscale(scale)
    m_uimanager_scale = scale
    for key, val in pairs(m_uimanager_handle) do
        if bit.band(val._flag, uiflag.scale) > 0 then
            val:setscale(scale)
        end
	end
end

function uimanager_getscale(scale)
    return m_uimanager_scale
end

function uimanager_setdragthreshold(val)
    c_uidragthreshold(val)
end

function uimanager_setcgmode(cgmode)
    m_uimanager_cgmode = cgmode
    for key, val in pairs(m_uimanager_handle) do
        val:updatevisible()
	end
end

function uimanager_sethideui(hideui)
    m_uimanager_hideui = hideui
    for key, val in pairs(m_uimanager_handle) do
        val:updatevisible()
	end
end

function uimanager_getcgmode()
    return m_uimanager_cgmode
end

function uimanager_gethideui()
    return m_uimanager_hideui
end

function uimanager_getpanel(panelname)
    return m_uimanager_handle[panelname]
end

function uimanager_escape()
    local panel = nil
    for key, val in pairs(m_uimanager_handle) do
        if val._escape then
            if panel == nil or panel._zorder < val._zorder then
                panel = val
            end
        end
	end
    if panel ~= nil then
        local func = _G[panel._delegatetitle .. "_onescape"]
        if func ~= nil then
            func(panel)
        else
            panel:close()
        end
        return true
    end
    return false
end

function uimanager_clear()
    local uiarray = {}
    for key, val in pairs(m_uimanager_handle) do
        if bit.band(val._flag, uiflag.holdonclear) == 0 then
            uiarray[#uiarray + 1] = val
        end
	end
    for i=1,#uiarray do
        uiarray[i]:close()
    end
end

function uimanager_covered(panel)
    local checkleft = true
    local checkright = true
    if bit.band(panel._flag, uiflag.placeleft) > 0 then
        checkright = false
    end
    if bit.band(panel._flag, uiflag.placeright) > 0 then
        checkleft = false
    end
    for key, val in pairs(m_uimanager_handle) do
        if val._zorder > panel._zorder then
            if checkleft and bit.band(val._flag, uiflag.placeleft) > 0 then
                return true
            end
            if checkright and bit.band(val._flag, uiflag.placeright) > 0 then
                return true
            end
        end
    end
    return false
end

function uimanager_closecover(flag, zlayer)
    if bit.band(flag, uiflag.placeleft) > 0 then
        for key, val in pairs(m_uimanager_handle) do
            if (zlayer == -1 or val._zlayer == zlayer) and bit.band(val._flag, uiflag.placeleft) > 0 then
                val:close()
                break
            end
        end
    end
    if bit.band(flag, uiflag.placeright) > 0 then
        for key, val in pairs(m_uimanager_handle) do
            if (zlayer == -1 or val._zlayer == zlayer) and bit.band(val._flag, uiflag.placeright) > 0 then
                val:close()
                break
            end
        end
    end
end

function uimanager_widgetevent(panelname, widgetpath, event)
    local panel = uimanager_getpanel(panelname)
    if panel ~= nil then
        local uiwidget = panel:getwidget(widgetpath)
        if uiwidget ~= nil then
            if uiwidget._delegate ~= nil then
                uiwidget._delegate(uiwidget, event)
            end
        end
    end
end
