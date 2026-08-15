
local m_palblacklist_inst = {pal = "pal/inst_blacklist"}

function palblacklist_onopen()
    local list_blacklist = m_uipal_main:getwidget("tab_blacklist/list_blacklist")
    list_blacklist:init(uilistflag.vertical)
    list_blacklist:setclickdelegate(palblacklist_delegate_list_blacklist)
end

function palblacklist_updateui()
    if m_uipal_main:null() or m_uipal_tab ~= PalTab.blacklist then
        return
    end

    local text_title = m_uipal_main:getwidget("image_bg/text_title")
    text_title:settext("PAL_TITLEBLACKLIST")

    local list_blacklist = m_uipal_main:getwidget("tab_blacklist/list_blacklist")
    list_blacklist:clear()
    for i=1,#playerattr_black do
        local pal = playerattr_black[i]
        local line = list_blacklist:add(m_palblacklist_inst.pal, pal.playerid, {playerid = pal.playerid, playername = pal.name})

        local text_name = line:getwidget("text_name")
        text_name:settext(pal.name)

        local text_note = line:getwidget("text_note")
        text_note:settext(pal.note)
    end
end

function palblacklist_delegate_list_blacklist(line, event, data)
    itemmenu_reset(data)
    itemmenu_addbutton("PAL_BLACKLIST_NOTE", palblacklist_delegate_menu_setnote)
    itemmenu_addbutton("PAL_BLACKLIST_REMOVE", palblacklist_delegate_menu_delblacklist)
    itemmenu_open(event.mousex, event.mousey, m_uipal_main)
end

function palblacklist_setnote_confirm(text, playerid)
    local msg = {messageid="CS_PalNote"}
    msg.playerid = playerid
    msg.note = text
    c_send(msg)
end
function palblacklist_delegate_menu_setnote(data)
    inputline_show(uiedittype.default, "PAL_SETNOTETITLE", nil, palblacklist_setnote_confirm, data.playerid)
end

function palblacklist_deletepal_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PalDelBlackList"}
        msg.playerid = data
        c_send(msg)
    end
end
function palblacklist_delegate_menu_delblacklist(data)
    local confirmtext = c_textformat("PAL_BLACKLIST_DELTEXT", data.playername)
    messagebox_confirm(confirmtext, palblacklist_deletepal_confirm, data.playerid)
end
