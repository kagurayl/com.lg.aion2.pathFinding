
function math.loadspline(strspline)
    local substr = string.split(strspline, ",")
    local pointcount = math.tointegerfloor((#substr - 1) / 9)
    if pointcount < 2 then
        return
    end
    local spline = {}
    spline.ring = substr[1] == "1"
    spline.totallength = 0.0
    spline.point = {}
    for i=1,pointcount do
        local point = {}
        local n = (i - 1) * 10 + 2
        spline.totallength = spline.totallength + string.tointeger(substr[n])
        point.length = spline.totallength
        point.posx = string.tointeger(substr[n + 1])
        point.posy = string.tointeger(substr[n + 2])
        point.posz = string.tointeger(substr[n + 3])
        point.intangentx = string.tointeger(substr[n + 4])
        point.intangenty = string.tointeger(substr[n + 5])
        point.intangentz = string.tointeger(substr[n + 6])
        point.outtangentx = string.tointeger(substr[n + 7])
        point.outtangenty = string.tointeger(substr[n + 8])
        point.outtangentz = string.tointeger(substr[n + 9])
        spline.point[#spline.point + 1] = point
    end
    if spline.ring then
        local point = {}
        local ptfirst = spline.point[1]
        point.length = ptfirst.length
        point.posx = ptfirst.posx
        point.posy = ptfirst.posy
        point.posz = ptfirst.posz
        point.intangentx = ptfirst.intangentx
        point.intangenty = ptfirst.intangenty
        point.intangentz = ptfirst.intangentz
        point.outtangentx = ptfirst.outtangentx
        point.outtangenty = ptfirst.outtangenty
        point.outtangentz = ptfirst.outtangentz
        spline.point[#spline.point + 1] = point
    end
    for i=#spline.point, 2, -1 do
        spline.point[i].length = spline.point[i - 1].length
    end
    spline.point[1].length = 0.0
    spline.val = 0.0
    spline.reverse = false
    return spline
end

function math.spline(pt1, pt2, t)
    local t2 = t * t
    local t3 = t2 * t
    local s0 = (2 * t3) - (3 * t2) + 1.0
    local s1 = t3 - (2 * t2) + t
    local s2 = (t3 - t2)
    local s3 = (-2.0 * t3) + (3.0 * t2)
    local x = pt1.posx * s0 + pt1.outtangentx * s1 + pt2.intangentx * s2 + pt2.posx * s3
    local y = pt1.posy * s0 + pt1.outtangenty * s1 + pt2.intangenty * s2 + pt2.posy * s3
    local z = pt1.posz * s0 + pt1.outtangentz * s1 + pt2.intangentz * s2 + pt2.posz * s3
    return x, y, z
end

function math.setsmooth(smooth, startval, starttime, targetval, timelength, accel)
    smooth.startval = startval
    smooth.starttime = starttime
    smooth.targetval = targetval
    smooth.timelength = timelength
    smooth.accel = accel
end

function math.getsmooth(smooth, time)
    local t = (time - smooth.starttime) / smooth.timelength
    if t > 1.0 then
        return true, smooth.targetval
    end
    if smooth.accel then
        t = t * t * (3 - 2 * t)
        --t = t * t * t * (t * (t * 6 - 15) + 10)
    else
        local t2 = (1.0 - t)
        t = 1.0 - t2 ^ 3
    end
    return false, math.lerp(smooth.startval, smooth.targetval, t)
end
