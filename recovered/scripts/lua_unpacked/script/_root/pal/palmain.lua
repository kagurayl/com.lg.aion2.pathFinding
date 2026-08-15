
include("pal/pallist")
include("pal/palsearch")
include("pal/palblacklist")
include("pal/palreferralplayer")

PalTab =
{
    pallist = 1,
    search = 2,
    blacklist = 3,
    referralplayer = 4,
}

m_uipal_main = uipanel_createhandle("pal/pal_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)
m_uipal_tab = PalTab.pallist

function pal_main_onopen()
    m_uipal_main:setwidgetdelegate("button_pallist", pal_main_delegate_pallist)
    m_uipal_main:setwidgetdelegate("button_search", pal_main_delegate_search)
    m_uipal_main:setwidgetdelegate("button_blacklist", pal_main_delegate_blacklist)
    m_uipal_main:setwidgetdelegate("button_referralplayer", pal_main_delegate_referralplayer)
    m_uipal_main:setwidgetdelegate("image_bg/button_close", pal_main_delegate_close)
    pallist_onopen()
    palsearch_onopen()
    palblacklist_onopen()
    palreferralplayer_onopen()
    pal_main_updateui()
end

function pal_main_updateui()
    m_uipal_main:setwidgetenable("button_pallist", m_uipal_tab ~= PalTab.pallist)
    m_uipal_main:setwidgetenable("button_search", m_uipal_tab ~= PalTab.search)
    m_uipal_main:setwidgetenable("button_blacklist", m_uipal_tab ~= PalTab.blacklist)
    m_uipal_main:setwidgetenable("button_referralplayer", m_uipal_tab ~= PalTab.referralplayer)

    m_uipal_main:setwidgetvisible("tab_pallist", m_uipal_tab == PalTab.pallist)
    m_uipal_main:setwidgetvisible("tab_search", m_uipal_tab == PalTab.search)
    m_uipal_main:setwidgetvisible("tab_blacklist", m_uipal_tab == PalTab.blacklist)
    m_uipal_main:setwidgetvisible("tab_referralplayer", m_uipal_tab == PalTab.referralplayer)

    pallist_updateui()
    palsearch_updateui()
    palblacklist_updateui()
    palreferralplayer_updateui()
end

function pal_main_delegate_pallist()
    m_uipal_tab = PalTab.pallist
    pal_main_updateui()
end

function pal_main_delegate_search()
    m_uipal_tab = PalTab.search
    pal_main_updateui()
end

function pal_main_delegate_blacklist()
    m_uipal_tab = PalTab.blacklist
    pal_main_updateui()
end

function pal_main_delegate_referralplayer()
    m_uipal_tab = PalTab.referralplayer
    pal_main_updateui()
end

function pal_main_delegate_close()
    m_uipal_main:close()
end
