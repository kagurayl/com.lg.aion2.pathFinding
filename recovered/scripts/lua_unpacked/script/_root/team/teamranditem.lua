
local m_uiteamranditem = uipanel_createhandle("team/team_randitem", uilayer.top, bit.bor(uiflag.escapeclose, uiflag.placeall))
local m_uiteamranditem_queue = {}

function team_randitem_onopen()
    m_uiteamranditem:setwidgetdelegate("button_rand", team_randitem_delegate_ok)
    m_uiteamranditem:setwidgetdelegate("button_close", team_randitem_delegate_close)
    event_register(eventtype.update, team_randitem_update, m_uiteamranditem)
end

function team_randitem_additem(itemid, itemcount, randid, timelength)
    local config_item = csvitem_getfromid(itemid)
    if config_item == nil then
        return
    end
    m_uiteamranditem:open()
    m_uiteamranditem.randid = 0
    local randitem = {}
    randitem.itemid = itemid
    randitem.itemcount = itemcount
    randitem.randid = randid
    randitem.timestart = time_game
    randitem.timelength = timelength
    randitem.timefinish = time_game + timelength
    m_uiteamranditem_queue[#m_uiteamranditem_queue + 1] = randitem

    team_randitem_update()
end

function team_randitem_update()
    for i=#m_uiteamranditem_queue,1,-1 do
        if m_uiteamranditem_queue[i].timefinish < time_game then
            table.remove(m_uiteamranditem_queue, i)
        end
    end
    if #m_uiteamranditem_queue == 0 then
        m_uiteamranditem:close()
        return
    end
    local randitem = m_uiteamranditem_queue[1]
    local progress = 1.0 - (time_game - randitem.timestart) / randitem.timelength
    local progress_time = m_uiteamranditem:getwidget("progress_time")
    progress_time:setpercent(math.clamp(progress, 0.0, 1.0))

    if m_uiteamranditem.randid ~= randitem.randid then
        m_uiteamranditem.randid = randitem.randid
        local config_item = csvitem_getfromid(randitem.itemid)
        if config_item ~= nil then
            local image_icon = m_uiteamranditem:getwidget("image_icon")
            image_icon:seticon(config_item.icon)
            image_icon:setdelegate(team_randitem_delegate_icon)
            image_icon.itemid = randitem.itemid
            image_icon.itemcount = randitem.itemcount

            local text_count = m_uiteamranditem:getwidget("text_count")
            if randitem.itemcount > 1 then
                text_count:settext(randitem.itemcount)
            else
                text_count:settext("")
            end
            
            local text_name = m_uiteamranditem:getwidget("text_name")
            text_name:settextscale(config_item.name)
            text_name:setcolor(csvitem_getfloatcolor(config_item))
        end
    end
end

local function team_randitem_removeid(randid)
    for i=#m_uiteamranditem_queue,1,-1 do
        if m_uiteamranditem_queue[i].randid == randid then
            table.remove(m_uiteamranditem_queue, i)
            break
        end
    end
    if #m_uiteamranditem_queue == 0 then
        m_uiteamranditem:close()
    end
end
function team_randitem_onrand(randid)
    team_randitem_removeid(randid)
end

function team_randitem_delegate_icon(sender, event)
    local image_batchbg = m_uiteamranditem:getwidget("image_batchbg")
    local x,y,w,h = image_batchbg:getabsolute()
    tips_item(sender.itemid, sender.itemcount, x + w, y + h, tipsflag.vright, nil, m_uiteamranditem)
end

function team_randitem_delegate_ok(sender, event)
    local msg = {messageid="CS_TeamRandPoint"}
    msg.randid = m_uiteamranditem.randid
    msg.pass = 0
    c_send(msg)
end

function team_randitem_delegate_close()
    local msg = {messageid="CS_TeamRandPoint"}
    msg.randid = m_uiteamranditem.randid
    msg.pass = 1
    c_send(msg)
    team_randitem_removeid(m_uiteamranditem.randid)
end
