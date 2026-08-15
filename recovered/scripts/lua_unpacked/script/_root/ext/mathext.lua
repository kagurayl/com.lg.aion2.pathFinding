
function isnan(x)
    return x ~= x or tostring(x) == "nan" or tostring(x) == "-nan"
end

function isinfinite(x)
    return x == math.huge or x == -math.huge
end

function math.randomfromseed(seed)
    return (1103515245 * seed + 12345)
end

function math.lerp(a,b,t)
    return (a + (b-a)*t)
end

function math.smoothstep(t1, t2, x)
    x = math.clamp((x - t1) / (t2 - t1), 0.0, 1.0)
    return x * x * (3 - 2 * x)
end
  
function math.ternary(cond,a,b)
    if cond then
        return a
    else
        return b
    end
end

function math.numberrepeat(t, length)
	return t - math.floor(t / length) * length
end

function math.distdegree(a,b)
    local delta = math.numberrepeat((b - a), 360)
    if delta > 180 then
        delta = delta - 360
    end
    return delta
end

function math.lerpdegree(a,b,t)
    local delta = math.numberrepeat((b - a), 360)
    if delta > 180 then
        delta = delta - 360
    end
    return a + delta * math.clamp(t, 0.0, 1.0)
end

function math.lerprgb(a,b,t)
    local r1,g1,b1 = HexRGB(a)
    local r2,g2,b2 = HexRGB(b)
    local r = math.lerp(r1, r2, t)
    local g = math.lerp(g1, g2, t)
    local b = math.lerp(b1, b2, t)
    return ToHex(r, g, b)
end

function math.minabs(a, b)
    if math.abs(a) < math.abs(b) then
        return a
    end
    return b
end

function vectorside(x1,y1,x2,y2)
    if (y2 - y1) * (-x1) - (x2 - x1) * (-y1) <= 0.0 then
        return true
    else
        return false
    end
end

function math.clamp(v, minValue, maxValue)
    if v < minValue then
        return minValue
    elseif v > maxValue then
        return maxValue
    else
        return v
    end
end

function math.roundoff(v)
    return math.floor(v + 0.5)
end

function math.sign(v)
    if v < 0 then
        return -1
    else
        return 1
    end
end

function math.intersectline(t1, t2, v1, v2)
    local delta = (t2.x - t1.x) * (v1.z - v2.z) - (v1.x - v2.x) * (t2.z - t1.z)
    if delta ~= 0.0 then
        local r = ((v1.x - t1.x) * (v1.z - v2.z) - (v1.x - v2.x) * (v1.z - t1.z)) / delta
        local u = ((t2.x - t1.x) * (v1.z - t1.z) - (v1.x - t1.x) * (t2.z - t1.z)) / delta
        return t1.x + r * (t2.x - t1.x), t1.z + u * (t2.z - t1.z)
    end
end

function math.lineside(t1, t2, px, pz)
    return (pz - t1.z) * (t2.x - t1.x) - (px - t1.x) * (t2.z - t1.z) >= 0.0
end

function math.pointinrect(px,py,x,y,r,b)
    return px > x and px < r and py > y and py < b
end

function math.boxintersect(l1,t1,r1,b1,l2,t2,r2,b2)
    return math.max(l1,l2) <= math.min(r1,r2) and math.max(t1,t2) <= math.min(b1,b2)
end

function math.tocolorbyte(flt)
    return math.tointegerfloor(math.clamp(flt*255.0,0,255))
end

function math.tointegerfloor(v)
    return math.floor(v)
end

function math.tocolorfloat(val)
    val = tonumber(val)
    if val == nil then
        return 0.0
    end
    return math.clamp(val/255.0,0.0,1.0)
end

function math.luminance(r, g, b)
    return vector3_dot(r, g, b, 0.272229, 0.674082, 0.053689)
end

