
m_uiicc_main = uipanel_createhandle("icc/icc_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function icc_main_onopen()
    m_uiicc_main:setwidgetdelegate("image_bg/button_close", icc_main_delegate_close)
    m_uiicc_main:setwidgetdelegate("button_note", icc_main_delegate_note)
    m_uiicc_main:setwidgetdelegate("button_member", icc_main_delegate_member)
    m_uiicc_main:setwidgetdelegate("button_log", icc_main_delegate_log)
    m_uiicc_main:setwidgetvisible("tab_noteinput", false)
    iccmember_onopenui()
    icclog_onopenui()
    icc_main_updateui()
    icc_main_delegate_member()
end

function icc_main_updateui()
    if m_uiicc_main:null() then
        return
    end
    if playerattr_icc == nil then
        m_uiicc_main:close()
        return
    end

    local image_logo = m_uiicc_main:getwidget("image_logo")
    image_logo:setraw(icc_getlogofile(playerattr_info.icclogo))

    local text_name = m_uiicc_main:getwidget("text_name")
    text_name:settext(playerattr_icc.name)

    local text_level = m_uiicc_main:getwidget("text_level")
    text_level:settext("ICC_MAIN_LEVEL", playerattr_icc.level)

    local text_note = m_uiicc_main:getwidget("text_note")
    text_note:settext(playerattr_icc.note)

    local text_disband = m_uiicc_main:getwidget("text_disband")
    if playerattr_icc.disband > 0 then
        text_disband:settext(c_textformat("ICC_DISBAND_TIME", timerdesc_countdown(playerattr_icc.disband)))
    else
        text_disband:settext("")
    end

    local count = #playerattr_icc.member
    local onlinecount = 0
    for i=1,#playerattr_icc.member do
        if playerattr_icc.member[i].disconnect == 0 then
            onlinecount = onlinecount + 1
        end
    end
    local text_member = m_uiicc_main:getwidget("text_member")
    text_member:settext("ICC_MAIN_MEMBER", count, onlinecount)

    iccmember_updateui()
    icclog_updateui()
end

function icc_main_delegate_note()
    icc_noteinput_open()
end

function icc_main_delegate_member()
    m_uiicc_main:setwidgetvisible("tab_member", true)
    m_uiicc_main:setwidgetvisible("tab_log", false)
end

function icc_main_delegate_log()
    m_uiicc_main:setwidgetvisible("tab_member", false)
    m_uiicc_main:setwidgetvisible("tab_log", true)
end

function icc_main_delegate_close()
    m_uiicc_main:close()
end
