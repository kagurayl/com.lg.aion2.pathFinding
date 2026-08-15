
include("gamemaster/teleport")

m_uigamemaster_main = uipanel_createhandle("gamemaster/gamemaster", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function gamemaster_open()
    if m_uigamemaster_main:alive() then
        return
    end
    m_uigamemaster_main:open()
    
    m_uigamemaster_main.tabmain = uitabcreate(m_equiplabmain)
    m_uigamemaster_main.tabmain:add("button_tabteleport", "tabteleport")
    m_uigamemaster_main.tabmain:add("button_tabitem", "tabitem")
    m_uigamemaster_main.tabmain:settab(1)

    m_uigamemaster_main:setwidgetdelegate("image_bg/button_close", gamemaster_delegate_close)

    tabteleport_onopen()
end

function gamemaster_delegate_close()
    m_uigamemaster_main:close()
end
