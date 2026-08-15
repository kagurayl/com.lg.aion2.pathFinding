
_uiimageclass = _inheritclass("_uiimageclass", _uiwidgetclass)

function _uiimageclass:setraw(colortexture)
    return c_uiimage_setraw(self._panel._uiname, self._widgetpath, unity_uitexturepath(colortexture))
end

function _uiimageclass:setrawuv(u, v, w, h)
    return c_uiimage_setrawuv(self._panel._uiname, self._widgetpath, u, v, w, h)
end

function _uiimageclass:seticon(colortexture)
    return c_uiimage_setraw(self._panel._uiname, self._widgetpath, unity_uitexturepath(colortexture))
end

function _uiimageclass:setsprite(sprite)
    return c_uiimage_setsprite(self._panel._uiname, self._widgetpath, unity_spritepath(sprite))
end

function _uiimageclass:setspritesize(sprite, sizescale)
    local path = unity_spritepath(sprite)
    local width, height = c_uigetspritesize(path)
    self:setsize(width * sizescale, height * sizescale)
    return c_uiimage_setsprite(self._panel._uiname, self._widgetpath, path)
end

function _uiimageclass:setmaterialraw(texturename, texturefile)
    return c_uiimage_setmaterialraw(self._panel._uiname, self._widgetpath, texturename, unity_uitexturepath(texturefile))
end

function _uiimageclass:setmaterialicon(texturename, texturefile)
    return c_uiimage_setmaterialraw(self._panel._uiname, self._widgetpath, texturename, unity_uitexturepath(texturefile))
end

function _uiimageclass:setmaterialsprite(texturename, texturefile)
    return c_uiimage_setmaterialsprite(self._panel._uiname, self._widgetpath, texturename, unity_spritepath(texturefile))
end

function _uiimageclass:setmaterialfloat(name, val)
    c_uiimage_setmaterialfloat(self._panel._uiname, self._widgetpath, name, val)
end

function _uiimageclass:setmaterialvector(name, x, y, z, w)
    c_uiimage_setmaterialvector(self._panel._uiname, self._widgetpath, name, x, y, z, w)
end

function _uiimageclass:applyfogmask(startx, starty, width, height)
    c_uiimage_applypolymask(self._panel._uiname, self._widgetpath, startx, starty, width, height)
end

function _uiimageclass:setavailablecolor(enable)
    local grey = math.ternary(enable, 1.0, 1.0 / 255.0)
    self:setopacity(grey)
end

function _uiimageclass:setwarningcolor(warning)
    if warning then
        self:setcolor(1.0, 0.5, 0.5, 1.0)
    else
        self:setcolor(1.0, 1.0, 1.0, 1.0)
    end
end
