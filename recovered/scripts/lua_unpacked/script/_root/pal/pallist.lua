
local m_pallist_inst = {pal = "pal/inst_pal"}

function pallist_onopen()
    local list_pal = m_uipal_main:getwidget("tab_pallist/list_pal")
    list_pal:init(uilistflag.vertical)
    list_pal:setclickdelegate(pallist_delegate_list_pal)

    local checkbox_offline = m_uipal_main:getwidget("tab_pallist/checkbox_offline")
    checkbox_offline:setcheck(true)
    checkbox_offline:setdelegate(pallist_delegate_offline)
end

function pallist_updateui()
    if m_uipal_main:null() or m_uipal_tab ~= PalTab.pallist then
        return
    end

    local text_title = m_uipal_main:getwidget("image_bg/text_title")
    text_title:settext("PAL_TITLEPAL")

    local checkbox_offline = m_uipal_main:getwidget("tab_pallist/checkbox_offline")
    local showoffline = checkbox_offline:getcheck()

    local list_pal = m_uipal_main:getwidget("tab_pallist/list_pal")
    list_pal:savestate()
    list_pal:clear()
    for i=1,#playerattr_pal do
        local pal = playerattr_pal[i]
        if pal.online == 1 or showoffline then
            local line = list_pal:add(m_pallist_inst.pal, pal.playerid, {playerid = pal.playerid, playername = pal.name})
            local r = 1
            local g = 1
            local b = 1
            if pal.online == 0 then
                r = 0.5
                g = 0.5
                b = 0.5
            end
            local text_name = line:getwidget("text_name")
            text_name:settext(pal.name)
            text_name:setcolor(r, g, b, 1)

            local text_level = line:getwidget("text_level")
            text_level:settext(pal.level)
            text_level:setcolor(r, g, b, 1)

            local text_career = line:getwidget("text_career")
            text_career:settext(playercareertext[pal.career])
            text_career:setcolor(r, g, b, 1)
        end
    end
    list_pal:restorestate()
end

function pallist_delegate_list_pal(line, event, data)
    itemmenu_reset(data)
    itemmenu_addbutton("PAL_LIST_TEAM", pallist_delegate_menu_team)
    itemmenu_addbutton("PAL_LIST_WHISPER", pallist_delegate_menu_whisper)
    itemmenu_addbutton("PAL_LIST_DELETE", pallist_delegate_menu_delete)
    itemmenu_open(event.mousex, event.mousey, m_uipal_main)
end

function pallist_delegate_offline(sender, event)
    pallist_updateui()
end

function pallist_delegate_menu_team(data)
    local msg = {messageid="CS_TeamInviteSend"}
    msg.playerid = data.playerid
    c_send(msg)
end

function pallist_delegate_menu_whisper(data)
    chat_whisperto(data.playerid, data.playername)
end

function pallist_deletepal_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PalDelete"}
        msg.playerid = data
        c_send(msg)
    end
end
function pallist_delegate_menu_delete(data)
    local confirmtext = c_textformat("PAL_DELETE_TEXT", data.playername)
    messagebox_confirm(confirmtext, pallist_deletepal_confirm, data.playerid)
end
