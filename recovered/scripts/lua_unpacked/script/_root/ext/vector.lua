
MATH_PI = 3.141592654
MATH_2PI = 6.283185307
MATH_1DIVPI = 0.318309886
MATH_1DIV2PI = 0.159154943
MATH_PIDIV2 = 1.570796327
MATH_PIDIV4 = 0.785398163
MATH_RAD2DEG = (180.0 / MATH_PI)
MATH_DEG2RAD = (MATH_PI / 180.0)

function vector2_normalize(x,y)
    local l = math.sqrt(x * x + y * y)
    if l > 0 then
        l = 1/l
    end
    return x * l,y * l
end

function vector2_length(x,y)
    return math.sqrt(x * x + y * y)
end

function vector2_normalizelength(x,y)
    local l = math.sqrt(x * x + y * y)
    local len = l
    if l > 0 then
        l = 1/l
    end
    return x * l,y * l,len
end

function vector2_sign(v1x, v1y, v2x, v2y)
    if (v2y - v1y) * (-v1x) - (v2x - v1x) * (-v1y) <= 0.0 then
        return 1.0
    else
        return -1.0
    end
end

function vector2_distance(x1,y1,x2,y2)
    local x = x2 - x1
    local y = y2 - y1
    return math.sqrt(x * x + y * y)
end

function vector2_distance_sq(x1,y1,x2,y2)
    local x = x2 - x1
    local y = y2 - y1
    return x * x + y * y
end

function vector2_dot(x1,y1,x2,y2)
    return x1 * x2 + y1 * y2
end

function vector2_cross(x1,y1,x2,y2)
    return x1 * y2 - y1 * x2
end

function vector2_angle(x, y)
    local radian = math.acos(y)
    if x > 0.0 then
        radian = -radian
    end
    return radian * MATH_RAD2DEG
end

function vector2_anglesign(x1,y1,x2,y2)
    local radian = math.acos(math.clamp(vector2_dot(x1, y1, x2, y2),-1,1))
    if vector2_cross(x1, y1, x2, y2) < 0.0 then
        radian = -radian
    end
    return radian * MATH_RAD2DEG
end

function vector2_anglesign2(x1,y1,x2,y2)
    local radian = math.acos(math.clamp(vector2_dot(x1, y1, x2, y2),-1,1))
    local sign = 1.0
    if vector2_cross(x1, y1, x2, y2) < 0.0 then
        sign = -1.0
    end
    return radian * MATH_RAD2DEG, sign
end

function vector2_rotate(x, y, degree)
	local sin = math.sin(degree * MATH_DEG2RAD)
	local cos = math.cos(degree * MATH_DEG2RAD)
	return vector2_normalize(cos * x - sin * y, sin * x + cos * y)
end

function vector2_rotatestandard(degree)
    return vector2_rotate(0, 1, degree)
end

function vector2_rotatepoint(px,py,cx,cy,degree)
    local sin = math.sin(degree * MATH_DEG2RAD)
	local cos = math.cos(degree * MATH_DEG2RAD)
    local x = cos * (px - cx) - sin * (py - cy) + cx
    local y = sin * (px - cx) + cos * (py - cy) + cy
    return x,y
end

function vector2_angle3d(x, y)
    return 180.0 - vector2_angle(x, y)
end

function vector2_rotate3d(x, y, degree)
	return vector2_rotate(x, y, -degree)
end

function vector2_rotatestandard3d(degree)
    return vector2_rotate(0, -1, -degree)
end

function vector3_normalize(x,y,z)
	local l = math.sqrt(x * x + y * y + z * z)
    if l > 0 then
        l = 1.0 / l
    end
	return x * l, y* l, z*l
end

function vector3_length(x,y,z)
	return math.sqrt(x * x  + y * y + z * z)
end

function vector3_normalizelength(x,y,z)
	local l = math.sqrt(x * x + y * y + z * z)
    if l > 0 then
        l = 1.0 / l
    end
	return x * l, y* l, z*l, l
end

function vector3_distance(x1,y1,z1,x2,y2,z2)
    local x = x2 - x1
    local y = y2 - y1
    local z = z2 - z1
    return math.sqrt(x * x + y * y + z * z)
end

function vector3_distance_sq(x1,y1,z1,x2,y2,z2)
    local x = x2 - x1
    local y = y2 - y1
    local z = z2 - z1
    return x * x + y * y + z * z
end

function vector3_dot(x1,y1,z1,x2,y2,z2)
    return x1 * x2 + y1 * y2 + z1 * z2
end

function vector3_cross(x1,y1,z1,x2,y2,z2)
    local x = y1 * z2 - z1 * y2
    local y = z1 * x2 - x1 * z2
    local z = x1 * y2 - y1 * x2
    return vector3_normalize(x, y, z)
end

function vector3_anglebetween(x1, y1, z1, x2, y2, z2)
	local dot = vector3_dot(x1, y1, z1, x2, y2, z2)
    return math.acos(dot) * MATH_RAD2DEG
end

function vector3_fromtovector(x1, y1, z1, x2, y2, z2)
    return c_math_fromtovector(x1, y1, z1, x2, y2, z2)
end

function vector3_angletovector(rx, ry, rz)
    return c_math_angletovector(rx, ry, rz)
end

function vector3_rotatevector(x, y, z, rx, ry, rz)
    return c_math_rotatevector(x, y, z, rx, ry, rz)
end

function vector3_rotateaxisangle(x, y, z, rx, ry, rz, angle)
    return c_math_rotateaxisangle(x, y, z, rx, ry, rz, angle)
end

function vector3_vectorlerp(x1, y1, z1, x2, y2, z2, t)
    return c_math_vectorlerp(x1, y1, z1, x2, y2, z2, t)
end

function vector3_scale(x1, y1, z1, scale)
    return x1 * scale, y1 * scale, z1 * scale
end

function vector3_fromstring(str)
    local split = string.split(str, ";")
    if #split ~= 3 then
        return 0,0,0
    end
    return tonumber(split[1]), tonumber(split[2]), tonumber(split[3])
end
