local m_uihomemenu_level_dredgion = 45

local m_uihomemenu = uipanel_createhandle("home/homemenu", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall, uiflag.scale))

function homemenu_create()
    if m_uihomemenu:alive() then
        m_uihomemenu:close()
    else
        m_uihomemenu:open()
    end
end

local function homemenu_setbutton(name, delegate, enable)
    local button_menu = m_uihomemenu:getwidget(name .. "/button_menu")
    button_menu:setdelegate(delegate)

    local image_icon = m_uihomemenu:getwidget(name .. "/image_icon")
    if enable then
        image_icon:setcolor(1, 1, 1, 1)
    else
        image_icon:setcolor(0.5, 0.5, 0.5, 1)
    end
end
function homemenu_onopen()
    m_uihomemenu.text_time = m_uihomemenu:getwidget("text_time")
    m_uihomemenu:setwidgetdelegate("button_close", homemenu_delegate_close)
    m_uihomemenu.timeicon_sprite = nil

    homemenu_setbutton("button_role", homemenu_delegate_role, true)
    homemenu_setbutton("button_bag", homemenu_delegate_bag, true)
    homemenu_setbutton("button_skill", homemenu_delegate_skill, true)
    homemenu_setbutton("button_setting", homemenu_delegate_setting, true)
    homemenu_setbutton("button_quest", homemenu_delegate_quest, true)
    homemenu_setbutton("button_dungeon", homemenu_delegate_dungeon, true)
    homemenu_setbutton("button_rank", homemenu_delegate_rank, true)
    homemenu_setbutton("button_notice", homemenu_delegate_notice, true)
    homemenu_setbutton("button_pal", homemenu_delegate_pal, true)
    homemenu_setbutton("button_team", homemenu_delegate_team, true)
    homemenu_setbutton("button_icc", homemenu_delegate_icc, true)
    homemenu_setbutton("button_stall", homemenu_delegate_stall, true)
    homemenu_setbutton("button_dailyquest", homemenu_delegate_dailyquest, playerattr_info.dailyquest ~= 0 and playerquest_getquest(playerattr_info.dailyquest) == nil)
    homemenu_setbutton("button_dredgion", homemenu_delegate_dredgion, playerattr_info.level >= m_uihomemenu_level_dredgion)
    homemenu_setbutton("button_abysscastle", homemenu_delegate_abysscastle, true)
    homemenu_setbutton("button_bugreport", homemenu_delegate_bugreport, true)
    homemenu_setbutton("button_store", homemenu_delegate_store, true)
    homemenu_setbutton("button_roulette", homemenu_delegate_roulette, true)
    homemenu_setbutton("button_pet", homemenu_delegate_pet, true)
    homemenu_setbutton("button_avatar", homemenu_delegate_avatar, true)
    
    homemenu_updatetime()
    event_register(eventtype.update, homemenu_updatetime, m_uihomemenu)
end

function homemenu_updatetime()
    local localtime = timer_daytime(timer_gettimesecond())
    local dayhour, dayminute = csvmaptimeenv_getgametime()
    local gametime = c_textformat("TIME_DAYTIME_MINUTE", string.format("%02d", dayhour), string.format("%02d", dayminute))
    local text = c_textformat("HOME_MENU_TIME", localtime, gametime)
    if playerattr_info.qskremain > 0 then
        local time = playerattr_info.qsktime - time_game
        if time > 0 then
            text = c_textformat("HOME_MENU_TIMEQSK", playerattr_info.qskmember, timerdesc_getafter(time), playerattr_info.qskremain, localtime, gametime)
        end
    end
    
    m_uihomemenu.text_time:settext(text)

    local timeicon = nil
    if dayhour < 4 then
        timeicon = "sp1/timenight"
    elseif dayhour < 9 then
        timeicon = "sp1/timedawn"
    elseif dayhour < 17 then
        timeicon = "sp1/timenoon"
    elseif dayhour < 22 then
        timeicon = "sp1/timesunset"
    else
        timeicon = "sp1/timenight"
    end
    if m_uihomemenu.timeicon_sprite ~= timeicon then
        m_uihomemenu.timeicon_sprite = timeicon
        local image_timeicon = m_uihomemenu:getwidget("image_timeicon")
        image_timeicon:setsprite(timeicon)
    end
end

function homemenu_delegate_close()
    m_uihomemenu:close()
end

function homemenu_delegate_role()
    m_uihomemenu:close()
    inputkey_openoverview()
end

function homemenu_delegate_bag()
    m_uihomemenu:close()
    inputkey_openbag()
end

function homemenu_delegate_skill()
    m_uihomemenu:close()
    inputkey_openskill()
end

function homemenu_delegate_setting()
    m_uihomemenu:close()
    inputkey_openui(m_uisetting_settingmain)
end

function homemenu_delegate_quest()
    m_uihomemenu:close()
    inputkey_openquest()
end

function homemenu_delegate_dungeon()
    m_uihomemenu:close()
    inputkey_opendungeon()
end

function homemenu_delegate_rank()
    m_uihomemenu:close()
    inputkey_openrank()
end

function homemenu_delegate_notice()
    m_uihomemenu:close()
    notice_show()
end

function homemenu_delegate_pal()
    m_uihomemenu:close()
    inputkey_openpal()
end

function homemenu_delegate_team()
    m_uihomemenu:close()
    inputkey_openteam()
end

function homemenu_delegate_icc()
    m_uihomemenu:close()
    inputkey_openicc()
end

function homemenu_delegate_stall()
    m_uihomemenu:close()
    inputkey_openstall()
end

function homemenu_delegate_dailyquest()
    if playerattr_info.dailyquest ~= 0 and playerquest_getquest(playerattr_info.dailyquest) == nil then
        m_uihomemenu:close()
        dialog_main_setdialogaccept(playerattr_info.dailyquest, 0)
    end
end

function homemenu_delegate_dredgion()
    if playerattr_info.level >= m_uihomemenu_level_dredgion then
        dredgionselect_open()
        m_uihomemenu:close()
    else
        chat_addsystemalert(c_textformat("HOME_MENUTIPS_DREDGION", m_uihomemenu_level_dredgion))
    end
end

function homemenu_delegate_bugreport()
    m_uihomemenu:close()
    bugreport_open()
end

function homemenu_delegate_abysscastle()
    m_uihomemenu:close()
    abysscastle_open()
end

function homemenu_delegate_store()
    store_open()
end

function homemenu_delegate_roulette()
    local msg = {messageid="CS_RouletteOpen"}
    c_send(msg)
end

function homemenu_delegate_pet()
    pet_main_open()
end

function homemenu_delegate_avatar()
    costume_open()
end
