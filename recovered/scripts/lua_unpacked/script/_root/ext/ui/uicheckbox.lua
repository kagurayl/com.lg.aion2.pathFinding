
checkboxstate = 
{
    unchecked = 0,
    checked = 1,
    undetermined = 2,
}

_uicheckboxclass = _inheritclass("_uicheckboxclass", _uiwidgetclass)

function _uicheckboxclass:setcheck(check)
    c_uicheckbox_setcheck(self._panel._uiname, self._widgetpath, math.ternary(check, checkboxstate.checked, checkboxstate.unchecked))
end

function _uicheckboxclass:setadvancecheck(check)
    c_uicheckbox_setcheck(self._panel._uiname, self._widgetpath, check)
end

function _uicheckboxclass:getcheck()
    return c_uicheckbox_getcheck(self._panel._uiname, self._widgetpath) == checkboxstate.checked
end

function _uicheckboxclass:getadvancecheck()
    return c_uicheckbox_getcheck(self._panel._uiname, self._widgetpath)
end
