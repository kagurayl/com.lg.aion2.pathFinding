
local m_uidictview = uipanel_createhandle("root/dictview", uilayer.message, uiflag.escapeclose)

function dictview_onopen()
    m_uidictview:setwidgetdelegate("button_trace", dictview_delegate_trace)
    m_uidictview:setwidgetdelegate("button_ok", dictview_delegate_ok)
end

function dictview_setview(dictkey)
    m_uidictview:open()
    local dicttext = c_textformat(dictkey)
    local dictsplit = string.byte(";")
    local splittitle = nil
    local splittext = dicttext
    for i=1,#dicttext do
        local dictbyte = string.byte(dicttext, i, i)
        if dictbyte == dictsplit then
            splittitle = string.sub(dicttext, 1, i - 1)
            splittext = string.sub(dicttext, i + 1, #dicttext)
            break
        end
    end
    local text_title = m_uidictview:getwidget("text_title")
    if splittitle ~= nil then
        text_title:settext(splittitle)
    else
        text_title:settext("")
    end
    m_uidictview.dictkey = dictkey
        
    local text_message = m_uidictview:getwidget("text_message")
    text_message:setrichtext(splittext)
    text_message:setdelegate(dictview_delegate_content)
end

function dictview_delegate_content(sender, event)
    if event.name == "click" and event.linkid ~= nil then
        local image_bg = m_uidictview:getwidget("image_bg")
        local x,y,w,h = image_bg:getabsolute()
        richtext_onclick(event, sender.tagarray, x, tipsflag.vleft)
    end
end

local function dictview_delegate_tracenpc()
    local npcid = csvnpc_getfromdict(m_uidictview.dictkey)
    if npcid == nil then
        return false
    end
    m_uidictview:close()
    minimap_settracenpc(npcid)
    maplabel_addnpclocation(npcid)
    return true
end

local function dictview_delegate_tracemap()
    local config_mapdict = c_config_getmetacol(configid.map_dict, "key", m_uidictview.dictkey)
    if config_mapdict == nil then
        return false
    end
    local config_zone = c_config_getmetaarray(configid.map_zone, "mapid", config_mapdict.mapid, "name", config_mapdict.name)
    if config_zone == nil then
        return false
    end
    config_zone = config_zone[1]
    m_uidictview:close()
    maplabel_setquestpoly(-1, 0, 0, config_mapdict.mapid, config_zone.poly, 0.5)
end

function dictview_delegate_trace()
    if m_uidictview.dictkey == nil then
        return
    end
    if dictview_delegate_tracenpc() then
        return
    end
    if dictview_delegate_tracemap() then
        return
    end
end

function dictview_delegate_ok()
    m_uidictview:close()
end
