
local m_palsearch_inst = {pal = "pal/inst_search"}
local m_palsearch_result = nil

function palsearch_onopen()
    m_uipal_main:setwidgetdelegate("tab_search/button_search", palsearch_delegate_search)
    local edit_levelmin = m_uipal_main:getwidget("tab_search/edit_levelmin")
    edit_levelmin:settext("1")

    local edit_levelmax = m_uipal_main:getwidget("tab_search/edit_levelmax")
    edit_levelmax:settext(playerlevel_max)

    local list_search = m_uipal_main:getwidget("tab_search/list_search")
    list_search:init(uilistflag.vertical)
    list_search:setclickdelegate(palsearch_delegate_list_search)
end

function onpalsearchresult(msg)
    m_palsearch_result = msg.info
    palsearch_updateui()
end

function palsearch_updateui()
    if m_uipal_main:null() or m_uipal_tab ~= PalTab.search then
        return
    end

    local text_title = m_uipal_main:getwidget("image_bg/text_title")
    text_title:settext("PAL_TITLESEARCH")

    local list_search = m_uipal_main:getwidget("tab_search/list_search")
    list_search:clear()
    if m_palsearch_result == nil then
        return
    end
    
    for i=1,#m_palsearch_result do
        local pal = m_palsearch_result[i]
        local line = list_search:add(m_palsearch_inst.pal, pal.playerid, {playerid = pal.playerid, playername = pal.name})

        local text_name = line:getwidget("text_name")
        text_name:settext(pal.name)

        local text_level = line:getwidget("text_level")
        text_level:settext(pal.level)

        local text_career = line:getwidget("text_career")
        text_career:settext(playercareertext[pal.career])
    end
end

function palsearch_delegate_search()
    local edit_name = m_uipal_main:getwidget("tab_search/edit_name")
    local edit_levelmin = m_uipal_main:getwidget("tab_search/edit_levelmin")
    local edit_levelmax = m_uipal_main:getwidget("tab_search/edit_levelmax")

    local msg = {messageid="CS_PalSearch"}
    msg.name = edit_name:gettext()
    msg.levelmin = edit_levelmin:gettext()
    msg.levelmax = edit_levelmax:gettext()
    c_send(msg)
end

function palsearch_delegate_list_search(line, event, data)
    itemmenu_reset(data)
    itemmenu_addbutton("PAL_SEARCH_ADDPAL", palsearch_menu_delegate_addpal)
    itemmenu_addbutton("PAL_SEARCH_WHISPER", palsearch_menu_delegate_whisper)
    itemmenu_addbutton("PAL_SEARCH_BLACKLIST", palsearch_menu_delegate_addblacklist)
    if playerattr_info.level < 50 and playerattr_referralplayername == nil then
        itemmenu_addbutton("PAL_SEARCH_SETREFERRALPLAYER", palsearch_menu_delegate_setreferralplayer)
    end
    itemmenu_open(event.mousex, event.mousey, m_uipal_main)
end

function palsearch_addpal_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PalRequestSend"}
        msg.playerid = data
        c_send(msg)
    end
end
function palsearch_menu_delegate_addpal(data)
    local confirmtext = c_textformat("PAL_LIST_ADDTEXT", data.playername)
    messagebox_confirm(confirmtext, palsearch_addpal_confirm, data.playerid)
end

function palsearch_menu_delegate_whisper(data)
    chat_whisperto(data.playerid, data.playername)
end

function palsearch_blacklist_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_PalAddBlackList"}
        msg.playerid = data
        c_send(msg)
    end
end
function palsearch_menu_delegate_addblacklist(data)
    local confirmtext = c_textformat("PAL_BLACKLIST_TEXT", data.playername)
    messagebox_confirm(confirmtext, palsearch_blacklist_confirm, data.playerid)
end

function palsearch_setreferralplayer_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_ReferralSetPlayer"}
        msg.playerid = data
        c_send(msg)
    end
end
function palsearch_menu_delegate_setreferralplayer(data)
    local confirmtext = c_textformat("PAL_REFERRALPLAYER_SETINVITECONFIRM", data.playername)
    messagebox_confirm(confirmtext, palsearch_setreferralplayer_confirm, data.playerid)
end
