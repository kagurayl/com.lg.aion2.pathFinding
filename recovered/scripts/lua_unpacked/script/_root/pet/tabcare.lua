
local function tabcare_setskill(widgetname, socialid)
    local config_social = csvskillsocial_getfromid(socialid)
    if config_social == nil then
        return
    end
    local image_skill = m_uipet_menu:getwidget(widgetname)
    image_skill.socialid = socialid
    image_skill:setdelegate(tabcare_delegate_skill)

    local image_icon = m_uipet_menu:getwidget(widgetname .. "/image_icon")
    image_icon:seticon(config_social.icon)
    image_icon:setavailablecolor(playerattr_social[config_social.id] ~= nil)

    local text_name = m_uipet_menu:getwidget(widgetname .. "/text_name")
    text_name:settext(config_social.name)
end

local function tabcare_updatecd(widgetname, cdlength, cdremain)
    local text_cd = m_uipet_menu:getwidget(string.format("%s/text_cd", widgetname))
    local image_cd = m_uipet_menu:getwidget(string.format("%s/image_cd", widgetname))
    if cdlength > 0 and cdremain > 0 then
        image_cd:setvisible(true)
        image_cd:setpercent(cdremain / cdlength)
        if cdremain < 10 then
            text_cd:setvisible(true)
            text_cd:settext(string.format("%.1f", cdremain))
        else
            text_cd:setvisible(false)
        end
    else
        text_cd:setvisible(false)
        image_cd:setvisible(false)
    end
end

function tabcare_onopen()
    tabcare_setskill("tab_care/skill1", 121)
    tabcare_setskill("tab_care/skill2", 122)
    tabcare_setskill("tab_care/skill3", 123)
    tabcare_setskill("tab_care/skill4", 114)
    m_uipet_menu:setwidgetdelegate("tab_care/button_gift", tabcare_delegate_gift)
    tabcare_update()
end

function tabcare_update()
    local cdlength, cdremain = timer_getcdfromid(cdtype_motion, cdmotion_petplay)
    tabcare_updatecd("tab_care/skill1", cdlength, cdremain)
    tabcare_updatecd("tab_care/skill2", cdlength, cdremain)
    tabcare_updatecd("tab_care/skill3", cdlength, cdremain)
    tabcare_updatecd("tab_care/skill4", cdlength, cdremain)
end

function tabcare_updateui()
    if m_uipet_menu:null() then
        return
    end
    local percent = math.min(1.0, m_uipet_menu.pet.reward / 10000.0)
    local text_progress = m_uipet_menu:getwidget("tab_care/text_progress")
    text_progress:settext("PETMENU_CARE_PROGRESS", string.format("%.1f%%", percent * 100.0))

    local button_gift = m_uipet_menu:getwidget("tab_care/button_gift")
    button_gift:setenable(m_uipet_menu.pet.reward >= 10000)
end

function tabcare_delegate_gift()
    local msg = {messageid="CS_PetGetRewardGift"}
    msg.uuid = m_uipet_menu.pet.uuid
    c_send(msg)
end

function tabcare_delegate_skill(sender, event)
    local msg = {messageid="CS_PetPlay"}
    msg.socialid = sender.socialid
    c_send(msg)
end
