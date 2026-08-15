
local m_uicolorpicker = uipanel_createhandle("root/colorpicker", uilayer.message, 0)

local function colorpicker_sethsv(h, s, v)
    m_uicolorpicker.hsv_h = h
    m_uicolorpicker.hsv_s = s
    m_uicolorpicker.hsv_v = v
    m_uicolorpicker.image_color:setmaterialfloat("_ColorS", s)
    m_uicolorpicker.image_color:setmaterialfloat("_ColorV", v)
    m_uicolorpicker.image_bright:setmaterialfloat("_ColorH", h)

    local radius = 0.4
    local angle = h * MATH_2PI
    local x = math.cos(angle) * radius
    local y = math.sin(angle) * radius
    local colorwidth, colorheight = m_uicolorpicker.image_color:getsize()
    m_uicolorpicker.image_colorthumb:setposition(x * colorwidth + colorwidth * 0.5, -(1.0 - y) * colorheight + colorheight * 0.5)

    local brightwidth, brightheight = m_uicolorpicker.image_bright:getsize()
    m_uicolorpicker.image_brightthumb:setposition(s * brightwidth, -(1.0 - v) * brightheight)

    local r, g, b = c_math_hsv2rgb(h, s, v)
    m_uicolorpicker.delegate(r, g, b, m_uicolorpicker.data)
end

function colorpicker_create(color, preset, delegate, data)
    m_uicolorpicker:open()
    m_uicolorpicker.initcolor = color
    m_uicolorpicker.delegate = delegate
    m_uicolorpicker.data = data

	m_uicolorpicker:setwidgetdelegate("button_ok", colorpicker_delegate_ok)
    m_uicolorpicker:setwidgetdelegate("button_cancel", colorpicker_delegate_close)
    m_uicolorpicker.image_color = m_uicolorpicker:getwidget("image_color")
    m_uicolorpicker.image_color:setdelegate(colorpicker_delegate_color)

    m_uicolorpicker.image_bright = m_uicolorpicker:getwidget("image_bright")
    m_uicolorpicker.image_bright:setdelegate(colorpicker_delegate_bright)

    m_uicolorpicker.image_colorthumb = m_uicolorpicker:getwidget("image_color/image_colorthumb")
    m_uicolorpicker.image_brightthumb = m_uicolorpicker:getwidget("image_bright/image_brightthumb")
    m_uicolorpicker.image_presetthumb = m_uicolorpicker:getwidget("image_presetthumb")
    m_uicolorpicker.image_presetthumb:setvisiblenothit(false)
    for i=1,10 do
        local r,g,b = HexRGB(preset[i])
        local image_fill = m_uicolorpicker:getwidget("image_fill_" .. i)
        image_fill.color = preset[i]
        image_fill:setrgb(r,g,b)
        image_fill:setdelegate(colorpicker_delegate_preset)
    end
    local h, s, v = c_math_rgb2hsv(HexRGB(color))
    colorpicker_sethsv(h, s, v)
    uimanager_setdragthreshold(0)
end

function colorpicker_close()
    m_uicolorpicker:close()
end

function colorpicker_onclose()
    uimanager_setdragthreshold(10)
end

function colorpicker_delegate_preset(sender)
    local h, s, v = c_math_rgb2hsv(HexRGB(sender.color))
    colorpicker_sethsv(h, s, v)
end

function colorpicker_delegate_color(sender, event)
    local x,y,w,h = m_uicolorpicker.image_color:getabsolute()
    local u = (event.mousex - x) / w
    local v = (event.mousey - y) / h
    local angle = vector2_angle(vector2_normalize(0.5 - u, 0.5 - v))
    local t = (angle + 180.0) / 360.0
    t = math.fmod(t + 0.25, 1)
    colorpicker_sethsv(t, m_uicolorpicker.hsv_s, m_uicolorpicker.hsv_v)
end

function colorpicker_delegate_bright(sender, event)
    local x,y,w,h = m_uicolorpicker.image_bright:getabsolute()
    local u = math.clamp((event.mousex - x) / w, 0.0, 1.0)
    local v = math.clamp((event.mousey - y) / h, 0.0, 1.0)
    colorpicker_sethsv(m_uicolorpicker.hsv_h, u, v)
end

function colorpicker_delegate_ok()
    m_uicolorpicker:close()
end

function colorpicker_delegate_close()
    m_uicolorpicker:close()
    local r, g, b = HexRGB(m_uicolorpicker.initcolor)
    m_uicolorpicker.delegate(r, g, b, m_uicolorpicker.data)
end
