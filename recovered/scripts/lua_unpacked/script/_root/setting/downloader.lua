
local m_uisetting_downloader = nil
local m_uisetting_downloader_inst = {file = "setting/inst_downloader"}

local function setting_downloader_getname(flag)
    local namekey = "DOWNLOADER_ID_" .. flag
    if c_textkey(namekey) then
        return namekey
    end
    local config_map = csvmap_getfromid(flag)
    if config_map ~= nil then
        namekey = "STR_ZONE_NAME_" .. string.upper(config_map.scene)
        if c_textkey(namekey) then
           return namekey
        end
    end
    return "DOWNLOADER_MAPNONE"
end

function setting_downloader_onopen(panel)
    m_uisetting_downloader = downloading_getlist()
    if m_uisetting_downloader == nil then
        return
    end
    table.sort(m_uisetting_downloader, function(p1, p2) return (p1.flag < p2.flag) end)
    local list_file = panel:getwidget("tab_downloader/list_file")
    list_file:init(uilistflag.vertical)
    for i=1,#m_uisetting_downloader do
        local info = m_uisetting_downloader[i]
        local line = list_file:add(m_uisetting_downloader_inst.file)
        line.info = info
        local name = setting_downloader_getname(info.flag)
        local text_name = line:getwidget("text_name")
        text_name:settext(name)
        line:setsize(200)
    end
    list_file:updatecontentsize()
end

function setting_downloader_update(panel)
    if m_uisetting_downloader == nil then
        return
    end
    local list_file = panel:getwidget("tab_downloader/list_file")
    for i=1,#m_uisetting_downloader do
        local line = list_file:getlinefromindex(i)
        local text_desc = line:getwidget("text_desc")
        local button_download = line:getwidget("button_download")
        if line.info.state == 1 then
            button_download:setvisible(false)
            local remainsize = downloading_queryflag(line.info.flag)
            if remainsize > 0 then
                text_desc:settext("DOWNLOADER_DOWNLOADING", downloading_getdesc(line.info.size - remainsize), downloading_getdesc(line.info.size))
            else
                text_desc:settext("DOWNLOADER_COMPLETE")
            end
        else
            button_download:setvisible(true)
            button_download:setdelegate(setting_downloader_start)
            button_download.info = line.info
            text_desc:settext("DOWNLOADER_SIZE", downloading_getdesc(line.info.size))
        end
    end
end

function setting_downloader_start(sender, event)
    sender.info.state = 1
    downloading_startflag(sender.info.flag)
end
