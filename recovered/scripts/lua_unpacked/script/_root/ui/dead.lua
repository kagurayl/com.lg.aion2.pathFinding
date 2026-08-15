
local deadwaittype =
{
    selectbuff = 1,
    selectdungeonitem = 2,
    selectitem = 3,
    selectqsk = 4,
    waitbigqskconfirm = 5,
    bigqskconfirm = 6,
    waitautorevive = 7,
}

local deadrevivetype =
{
    bigqsk = 0,
    qsk = 1,
    item = 2,
    dungeonitem = 3,
    skill = 4,
    buff = 5,
}

local m_uidead_ui = uipanel_createhandle("root/dead", uilayer.cover, 0)
local m_uidead_waittype = deadwaittype.selectbuff
local m_uidead_autorevive = 0
local m_uidead_reviveselectable = true
local m_uidead_reviveactorname = nil
local m_uidead_reviveskillname = nil
local m_uidead_reviveskilltime = 0
local m_uidead_revivedungeonitemid = 0
local m_uidead_revivedungeonitemname = nil
local m_uidead_timeitem = 0
local m_uidead_timebuff = 0
local m_uidead_timeqsk = 0
local m_uidead_timebuffname = nil

function dead_onopen()
    m_uidead_ui:setwidgetdelegate("button_buff", dead_delegate_buff)
    m_uidead_ui:setwidgetdelegate("button_item", dead_delegate_item)
    m_uidead_ui:setwidgetdelegate("button_bindplace", dead_delegate_bindplace)
    m_uidead_ui:setwidgetdelegate("button_qsk", dead_delegate_qsk)
    m_uidead_ui:setwidgetdelegate("button_bigqsk", dead_delegate_bigqsk)
    m_uidead_ui:setwidgetdelegate("button_bigqskconfirm", dead_delegate_bigqskconfirm)
    m_uidead_ui:setwidgetdelegate("button_skillaccept", dead_delegate_skillaccept)
    m_uidead_ui:setwidgetdelegate("button_skillrefuse", dead_delegate_skillrefuse)
    if m_uidead_reviveselectable then
        m_uidead_waittype = deadwaittype.selectbuff
    else
        m_uidead_waittype = deadwaittype.waitautorevive        
    end
    dead_updatebuttontext()
    event_register(eventtype.update, dead_updateui, m_uidead_ui)
    dead_updateui()
end

function dead_openui()
    m_uidead_ui:open()
end

function dead_reset(msg)
    if msg.timeautorevive ~= 0 then
        m_uidead_autorevive = time_game + msg.timeautorevive
    else
        m_uidead_autorevive = 0
    end
    m_uidead_reviveselectable = msg.select > 0
    m_uidead_reviveactorname = nil
    m_uidead_reviveskillname = 0
    m_uidead_reviveskilltime = 0
    m_uidead_timeitem = time_game + msg.timeitem
    m_uidead_timebuff = time_game + msg.timebuff
    m_uidead_timeqsk = time_game + msg.timeqsk
    m_uidead_timebuffname = ""
    local config_skill = csvskill_getfromid(msg.buffid)
    if config_skill ~= nil then
        m_uidead_timebuffname = config_skill.name
    end
    m_uidead_revivedungeonitemname = ""
    m_uidead_revivedungeonitemid = 0
    local config_item = csvitem_getfromid(msg.dungeonitemid)
    if config_item ~= nil then
        m_uidead_revivedungeonitemid = msg.dungeonitemid
        m_uidead_revivedungeonitemname = config_item.name
    end
    dead_updatebuttontext()
end

function dead_setskill(attackerid, skillid, time)
    local actor = actormanager_getfromactorid(attackerid)
    if actor ~= nil then
        m_uidead_reviveactorname = actor.attr.name
    else
        m_uidead_reviveactorname = ""
    end
    local config_skill = csvskill_getfromid(skillid)
    if config_skill ~= nil then
        m_uidead_reviveskillname = config_skill.name
    else
        m_uidead_reviveskillname = ""
    end
    m_uidead_reviveskilltime = time_game + time
end

function dead_setreviveskilltime()
    m_uidead_ui:setwidgetvisible("button_buff", false)
    m_uidead_ui:setwidgetvisible("button_item", false)
    m_uidead_ui:setwidgetvisible("button_inplace", false)
    m_uidead_ui:setwidgetvisible("button_bindplace", false)
    m_uidead_ui:setwidgetvisible("button_qsk", false)
    m_uidead_ui:setwidgetvisible("button_bigqsk", false)
    m_uidead_ui:setwidgetvisible("button_bigqskconfirm", false)
    m_uidead_ui:setwidgetvisible("button_skillaccept", true)
    m_uidead_ui:setwidgetvisible("button_skillrefuse", true)

    local timedesc = timerdesc_getafter(m_uidead_reviveskilltime - time_game)
    timedesc = c_textformat("DEAD_TIPS_SKILL", m_uidead_reviveactorname, m_uidead_reviveskillname, timedesc)
    local text_tips = m_uidead_ui:getwidget("text_tips")
    text_tips:settext(timedesc)
end

function dead_updatebuttontext()
    if m_uidead_ui:alive() then
        local button_bigqskconfirm = m_uidead_ui:getwidget("button_bigqskconfirm")
        local config_map = scene_getmapconfig()
        if config_map ~= nil and config_map.inst == 2 then
            button_bigqskconfirm:settext("DEAD_TIPS_BINDPLACEDUNGEON")
        else
            button_bigqskconfirm:settext("DEAD_TIPS_BINDPLACE")
        end
    end
end

function dead_updateui()
    if playerattr_info.deadtime == nil then
        m_uidead_ui:close()
        return
    end
    if m_uidead_reviveskilltime > time_game then
        dead_setreviveskilltime()
        return
    end
    local autorevivetime = m_uidead_autorevive - time_game
    if m_uidead_waittype == deadwaittype.selectbuff then
        if m_uidead_timebuff < time_game then
            m_uidead_waittype = deadwaittype.selectdungeonitem
        end
    end
    if m_uidead_waittype == deadwaittype.selectdungeonitem then
        if m_uidead_revivedungeonitemid == 0 then
            m_uidead_waittype = deadwaittype.selectitem
        end
    end
    if m_uidead_waittype == deadwaittype.selectitem then
        if m_uidead_timeitem < time_game then
            m_uidead_waittype = deadwaittype.selectqsk
        end
    end
    if m_uidead_waittype == deadwaittype.selectqsk then
        if playerattr_info.qskremain == 0 or m_uidead_timeqsk < time_game then
            m_uidead_waittype = deadwaittype.waitbigqskconfirm
        end
    end
    if m_uidead_waittype == deadwaittype.waitbigqskconfirm then
        if autorevivetime <= 0 then
            m_uidead_waittype = deadwaittype.bigqskconfirm
            dead_delegate_bigqskconfirm()
        end
    end

    m_uidead_ui:setwidgetvisible("button_buff", m_uidead_waittype == deadwaittype.selectbuff)
    m_uidead_ui:setwidgetvisible("button_item", m_uidead_waittype == deadwaittype.selectitem or m_uidead_waittype == deadwaittype.selectdungeonitem)
    m_uidead_ui:setwidgetvisible("button_bindplace", m_uidead_waittype == deadwaittype.selectbuff or m_uidead_waittype == deadwaittype.selectitem or m_uidead_waittype == deadwaittype.selectdungeonitem)
    m_uidead_ui:setwidgetvisible("button_qsk", m_uidead_waittype == deadwaittype.selectqsk)
    m_uidead_ui:setwidgetvisible("button_bigqsk", m_uidead_waittype == deadwaittype.selectqsk)
    m_uidead_ui:setwidgetvisible("button_bigqskconfirm", m_uidead_waittype == deadwaittype.waitbigqskconfirm)
    m_uidead_ui:setwidgetvisible("button_skillaccept", false)
    m_uidead_ui:setwidgetvisible("button_skillrefuse", false)

    local timedesc = ""
    if m_uidead_waittype == deadwaittype.selectbuff then
        timedesc = timerdesc_getafter(math.max(0, m_uidead_timebuff - time_game))
        timedesc = c_textformat("DEAD_TIPS_SELECTBUFF", m_uidead_timebuffname, timedesc)
    elseif m_uidead_waittype == deadwaittype.selectdungeonitem then
         timedesc = timerdesc_getafter(math.max(0, autorevivetime))
         timedesc = c_textformat("DEAD_TIPS_DUNGEONITEM", timedesc, m_uidead_revivedungeonitemname)
    elseif m_uidead_waittype == deadwaittype.selectitem then
        timedesc = timerdesc_getafter(math.max(0, m_uidead_timeitem - time_game))
        timedesc = c_textformat("DEAD_TIPS_SELECT", timedesc)
    elseif m_uidead_waittype == deadwaittype.selectqsk then
        timedesc = timerdesc_getafter(math.max(0, m_uidead_timeqsk - time_game))
        timedesc = c_textformat("DEAD_TIPS_SELECT2", timedesc)
    elseif m_uidead_waittype == deadwaittype.waitbigqskconfirm then
        timedesc = timerdesc_getafter(math.max(0, autorevivetime))
        local config_map = scene_getmapconfig()
        if config_map ~= nil and config_map.inst == 2 then
            timedesc = c_textformat("DEAD_TIPS_CONFIRMDUNGEON", timedesc)
        else
            timedesc = c_textformat("DEAD_TIPS_CONFIRM", timedesc)
        end
    elseif m_uidead_waittype == deadwaittype.waitautorevive then
        timedesc = timerdesc_getafter(math.max(0, autorevivetime))
        timedesc = c_textformat("DEAD_TIPS_ARENA", timedesc)
    end
    local text_tips = m_uidead_ui:getwidget("text_tips")
    text_tips:settext(timedesc)
end

function dead_delegate_buff()
    local msg = {messageid="CS_Revive"}
    msg.itemid = 0
    msg.bindplace = deadrevivetype.buff
    c_send(msg)
end

function dead_delegate_item()
    local msg = {messageid="CS_Revive"}
    msg.itemid = 0
    if m_uidead_revivedungeonitemid ~= 0 then
        msg.itemid = m_uidead_revivedungeonitemid
        msg.bindplace = deadrevivetype.dungeonitem
    else
        msg.bindplace = deadrevivetype.item
    end
    c_send(msg)
end

function dead_delegate_bindplace()
    m_uidead_waittype = deadwaittype.selectqsk
end

function dead_delegate_qsk()
    local msg = {messageid="CS_Revive"}
    msg.itemid = 0
    msg.bindplace = deadrevivetype.qsk
    c_send(msg)
end

function dead_delegate_bigqsk()
    m_uidead_waittype = deadwaittype.waitbigqskconfirm
end

function dead_delegate_bigqskconfirm()
    local msg = {messageid="CS_Revive"}
    msg.itemid = 0
    msg.bindplace = deadrevivetype.bigqsk
    c_send(msg)
end

function dead_delegate_skillaccept()
    local msg = {messageid="CS_Revive"}
    msg.itemid = 0
    msg.bindplace = deadrevivetype.skill
    c_send(msg)
end

function dead_delegate_skillrefuse()
    m_uidead_reviveskilltime = 0
end
