
local m_overview_playerquery = uipanel_createhandle("overview/player_query", uilayer.normal, uiflag.escapeclose, AudioOpenUI, AudioCloseUI)

function player_query_onopen()
    m_overview_playerquery:setwidgetdelegate("image_bg/button_close", playerquery_delegate_close)
    local list_attr = m_overview_playerquery:getwidget("list_attr")
    list_attr:init(uilistflag.vertical)
end

function playerquery_setplayer(msg)
    m_overview_playerquery:open()
    local text_playername = m_overview_playerquery:getwidget("text_playername")
    text_playername:settext(msg.name)

    local text_playerevel = m_overview_playerquery:getwidget("text_playerevel")
    text_playerevel:settext("PLAYER_INFO_LEVEL", msg.level, c_textformat(playercareertext[msg.career]))

    for key, val in pairs(equipslot) do
        local equip = msg.equip[val]
        local icon_root = m_overview_playerquery:getwidget("icon_" .. key)
        icon_root:setdelegate(playerquery_delegate_equipicon)
        icon_root.equip = equip

        local icon_equip = m_overview_playerquery:getwidget("icon_" .. key .. "/image_icon")
        local text_count = m_overview_playerquery:getwidget("icon_" .. key .. "/text_count")
        local image_anim = m_overview_playerquery:getwidget("icon_" .. key .. "/image_anim")
        image_anim:setvisible(false)
        if equip.itemid ~= 0 then
            icon_equip:setopacity(1.0)
            local config_item = csvitem_getfromid(equip.itemid)
            if config_item ~= nil then
                icon_equip:seticon(config_item.icon)
            end
            if val == equipslot.battery1 or val == equipslot.battery2 then
                text_count:settext(equip.count)
                text_count:setvisiblenothit(true)
            else
                text_count:setvisible(false)
            end
        else
            icon_equip:setopacity(0.0)
            text_count:setvisible(false)
        end
	end

    local list_attr = m_overview_playerquery:getwidget("list_attr")
    playerattrview_setattr(list_attr, msg, msg.equip)
end

function playerquery_delegate_close()
    m_overview_playerquery:close()
end

function playerquery_delegate_equipicon(sender, event)
    local item = sender.equip
    if item.itemid == 0 then
        return
    end

    local image_bg = m_overview_playerquery:getwidget("image_bg")
    local x,y,w,h = image_bg:getabsolute()
    tips_item(item.itemid, item.count, x, -1, tipsflag.vleft, item, m_overview_playerquery)
end
