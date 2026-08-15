
local pointalign =
{
	center = 0x00000000,
    left = 0x00000001,
    right = 0x00000002,
    up = 0x00000004,
    down = 0x00000008,
}

local m_link_panel = nil
local m_link_clone = nil
local m_link_arrowsize = 30
local m_link_segsize = 15

local function iconlink_addsegment(panel, segname, dush, posx, posy, pointalignflag, width, height)
    local imagename = nil
    if dush then
        imagename = string.format("image_dush_%s_", segname)
    else
        imagename = string.format("image_solid_%s_", segname)
    end
    if panel[imagename] == nil then
        panel[imagename] = 1
    else
        panel[imagename] = panel[imagename] + 1
    end
    local image_src = panel:getwidget("image_arrow/" .. imagename .. "1")
    if image_src.init_w == nil then
        image_src.init_w, image_src.init_h = image_src:getsize()
    end
    local image_seg = image_src
    if panel[imagename] > 1 then
        image_seg = panel:getwidget("image_arrow/" .. imagename .. panel[imagename])
        if image_seg == nil then
            image_seg = image_src:clone(imagename .. panel[imagename])
        end
    end
    width = width or image_src.init_w
    height = height or image_src.init_h
    image_seg:setsize(width, height)
    if bit.band(pointalignflag, pointalign.left) > 0 then
        posx = posx + width / 2
    elseif bit.band(pointalignflag, pointalign.right) > 0 then
        posx = posx - width / 2
    end
    if bit.band(pointalignflag, pointalign.up) > 0 then
        posy = posy - height / 2
    elseif bit.band(pointalignflag, pointalign.down) > 0 then
        posy = posy + height / 2
    end
    image_seg:setvisiblenothit(true)
    image_seg:setposition(posx, posy)
    return posx - width / 2, posy + height / 2, posx + width / 2, posy - height / 2
end

function iconlink_setclonedelegate(clonedelegate)
    m_link_clone = clonedelegate
end

function iconlink_single_to_array(startx, starty, linkarray, panel)
    local segx = startx
    local segy = starty
    local l,t,r,b
    if #linkarray == 1 then
        local link = linkarray[1]
        local dush = link.prob ~= nil and link.prob < 100
        l,t,segx,b = iconlink_addsegment(panel, "left", dush, segx, segy, pointalign.left)
        l,t,segx,b = iconlink_addsegment(panel, "h", dush, segx, segy, pointalign.left, link.left - segx - m_link_arrowsize, nil)
        l,t,segx,b = iconlink_addsegment(panel, "right", dush, segx, segy, pointalign.left)
    else
        l,t,segx,b = iconlink_addsegment(panel, "left", false, segx, segy, pointalign.left)
        l,t,segx,b = iconlink_addsegment(panel, "h", false, segx, segy, pointalign.left)
        local center_top, center_bottom
        if math.fmod(#linkarray, 2) == 1 then
            local index = math.floor((#linkarray + 1) / 2)
            local link = linkarray[index]
            local cl,ct,cr,cb = iconlink_addsegment(panel, "center", false, segx, segy, pointalign.left)
            center_top = ct
            center_bottom = cb
            cl,ct,cr,cb = iconlink_addsegment(panel, "h", dush, cr, segy, pointalign.left, link.left - cr - m_link_arrowsize, nil)
            cl,ct,cr,cb = iconlink_addsegment(panel, "right", dush, cr, segy, pointalign.left)
            table.remove(linkarray, index)
        else
            local cl,ct,cr,cb = iconlink_addsegment(panel, "cr", false, segx, segy, pointalign.left)
            center_top = ct
            center_bottom = cb
        end
        
        local linktop = linkarray[1]
        table.remove(linkarray, 1)
        local dushtop = linktop.prob ~= nil and linktop.prob < 100
        l,t,r,b = iconlink_addsegment(panel, "lt", dushtop, segx, linktop.centery, pointalign.left)
        segy = b
        l,t,r,b = iconlink_addsegment(panel, "h", dushtop, r, linktop.centery, pointalign.left, linktop.left - r - m_link_arrowsize, nil)
        iconlink_addsegment(panel, "right", dushtop, r, linktop.centery, pointalign.left)

        for linkindex=1,#linkarray do
            local link = linkarray[linkindex]
            local dush = link.prob ~= nil and link.prob < 100
            local linkbottom = link.centery + m_link_segsize
            if segy >= center_top and linkbottom <= center_bottom then
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, segy, bit.bor(pointalign.left, pointalign.up), nil, segy - center_top)
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, center_bottom, bit.bor(pointalign.left, pointalign.up), nil, center_bottom - linkbottom)
            else
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, segy, bit.bor(pointalign.left, pointalign.up), nil, segy - linkbottom)
            end

            if linkindex == #linkarray then
                l,t,r,segy = iconlink_addsegment(panel, "lb", dush, segx, segy, bit.bor(pointalign.left, pointalign.up))
            else
                l,t,r,segy = iconlink_addsegment(panel, "cl", dush, segx, segy, bit.bor(pointalign.left, pointalign.up))
            end
            local hy = (t + segy) / 2
            l,t,r,b = iconlink_addsegment(panel, "h", dush, r, hy, pointalign.left, link.left - r - m_link_arrowsize, nil)
            iconlink_addsegment(panel, "right", dush, r, hy, pointalign.left)
        end
    end
end

function iconlink_array_to_single(linkarray, endx, endy, panel)
    local segx = endx
    local segy = endy
    local l,t,r,b
    if #linkarray == 1 then
        local link = linkarray[1]
        local dush = link.prob ~= nil and link.prob < 100
        segx,t,r,b = iconlink_addsegment(panel, "right", dush, segx, segy, pointalign.right)
        segx,t,r,b = iconlink_addsegment(panel, "h", dush, segx, segy, pointalign.right, segx - link.right - m_link_arrowsize, nil)
        segx,t,r,b = iconlink_addsegment(panel, "left", dush, segx, segy, pointalign.right)
    else
        segx,t,r,b = iconlink_addsegment(panel, "right", false, segx, segy, pointalign.right)
        segx,t,r,b = iconlink_addsegment(panel, "h", false, segx, segy, pointalign.right)
        local center_top, center_bottom
        if math.fmod(#linkarray, 2) == 1 then
            local index = math.floor((#linkarray + 1) / 2)
            local linkcenter = linkarray[index]
            local cl,ct,cr,cb = iconlink_addsegment(panel, "center", false, segx, segy, pointalign.right)
            center_top = ct
            center_bottom = cb
            cl,ct,cr,cb = iconlink_addsegment(panel, "h", dush, cl, segy, pointalign.right, cl - link.right - m_link_arrowsize, nil)
            cl,ct,cr,cb = iconlink_addsegment(panel, "left", dush, cl, segy, pointalign.right)
            table.remove(linkarray, index)
        else
            local cl,ct,cr,cb = iconlink_addsegment(panel, "cl", false, segx, segy, pointalign.right)
            center_top = ct
            center_bottom = cb
        end
        
        local linktop = linkarray[1]
        table.remove(linkarray, 1)
        local dushtop = linktop.prob ~= nil and linktop.prob < 100
        l,t,r,b = iconlink_addsegment(panel, "rt", dushtop, segx, linktop.centery, pointalign.right)
        segy = b
        l,t,r,b = iconlink_addsegment(panel, "h", dushtop, l, linktop.centery, pointalign.right, l - linktop.right - m_link_arrowsize, nil)
        iconlink_addsegment(panel, "left", dushtop, l, linktop.centery, pointalign.right)

        for linkindex=1,#linkarray do
            local link = linkarray[linkindex]
            local dush = link.prob ~= nil and link.prob < 100
            local linkbottom = link.centery + m_link_segsize
            if segy >= center_top and linkbottom <= center_bottom then
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, segy, bit.bor(pointalign.right, pointalign.up), nil, segy - center_top)
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, center_bottom, bit.bor(pointalign.right, pointalign.up), nil, center_bottom - linkbottom)
            else
                l,t,r,segy = iconlink_addsegment(panel, "v", dush, segx, segy, bit.bor(pointalign.right, pointalign.up), nil, segy - linkbottom)
            end

            if linkindex == #linkarray then
                l,t,r,segy = iconlink_addsegment(panel, "rb", dush, segx, segy, bit.bor(pointalign.right, pointalign.up))
            else
                l,t,r,segy = iconlink_addsegment(panel, "cr", dush, segx, segy, bit.bor(pointalign.right, pointalign.up))
            end
            local hy = (t + segy) / 2
            l,t,r,b = iconlink_addsegment(panel, "h", dush, l, hy, pointalign.right, l - link.right - m_link_arrowsize, nil)
            iconlink_addsegment(panel, "left", dush, l, hy, pointalign.right)
        end
    end
end
