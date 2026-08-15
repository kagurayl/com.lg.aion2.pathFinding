
local m_palreferralplayer_inst = {pal = "pal/inst_pal"}

function palreferralplayer_onopen()
    local list_player = m_uipal_main:getwidget("tab_referralplayer/list_player")
    list_player:init(uilistflag.vertical)
end

function palreferralplayer_updateui()
    if m_uipal_main:null() or m_uipal_tab ~= PalTab.referralplayer then
        return
    end

    local text_title = m_uipal_main:getwidget("image_bg/text_title")
    text_title:settext("PAL_TITLEREFERRALPLAYER")

    local text_invite = m_uipal_main:getwidget("tab_referralplayer/text_invite")
    if playerattr_referralplayername ~= nil then
        text_invite:setvisible(true)
        text_invite:settext("PAL_REFERRALPLAYER_INVITE", playerattr_referralplayername)
        text_invite:setdelegate(nil)
    elseif playerattr_info.level < 50 then
        text_invite:setvisible(true)
        text_invite:settext("PAL_REFERRALPLAYER_SETINVITE")
        text_invite:setdelegate(palreferralplayer_delegate_setinvite)
    else
        text_invite:setvisible(false)
    end

    local list_player = m_uipal_main:getwidget("tab_referralplayer/list_player")
    list_player:savestate()
    list_player:clear()
    for i=1,#playerattr_referrallist do
        local referral = playerattr_referrallist[i]
        local line = list_player:add(m_palreferralplayer_inst.pal)
        local text_name = line:getwidget("text_name")
        text_name:settext(referral.name)

        local text_level = line:getwidget("text_level")
        text_level:settext(referral.level)

        local text_career = line:getwidget("text_career")
        text_career:settext(playercareertext[referral.career])
    end
    list_player:restorestate()
end

function palreferralplayer_delegate_setinvite(sender, event)
    pal_main_delegate_search()
end
