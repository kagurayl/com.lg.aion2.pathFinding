
local playeranim_linetype =
{
    category = 1,
    animname = 2,
}

local m_playeranim_inst = {category = "overview/inst_animcategory", name = "overview/inst_animname", active = "overview/inst_animactive" }
local m_playeranim_selectanimtype = nil
local m_playeranim_selectanimid = nil

function playeranim_onopen()
	local list_anim = m_uioverview_playermain:getwidget("tab_anim/list_anim")
    list_anim:init(uilistflag.vertical)
    list_anim:setclickdelegate(playeranim_delegate_list_item)
end

function playeranim_delegate_list_item(line, event, data)
    m_playeranim_selectanimtype = line.cardtype
    m_playeranim_selectanimid = line.cardid
    playeranim_updateui()
end

local function playeranim_animactived(type, id)
    if (type == csvanimcardtype.idle and playerattr_info.animidle == id)
    or (type == csvanimcardtype.run and playerattr_info.animrun == id)
    or (type == csvanimcardtype.jump and playerattr_info.animjump == id)
    or (type == csvanimcardtype.rest and playerattr_info.animrest == id) then
        return true
    end
    return false
end

local function playeranim_addcategory(list_anim, type, str)
    local line = list_anim:add(m_playeranim_inst.category)
    local text_category= line:getwidget("text_name")
    text_category:settext(str)

    line = list_anim:add(m_playeranim_inst.name, type .. "0", 0)
    line.cardtype = type
    line.cardid = 0
    local text_namenone = line:getwidget("text_name")
    text_namenone:settext("PLAYER_ANIM_NONE")
    if playeranim_animactived(type, 0) then
        text_namenone:setcolor(0,1,0,1)
    else
        text_namenone:setcolor(1,1,1,1)
        if m_playeranim_selectanimtype == type and m_playeranim_selectanimid == 0 then
            line = list_anim:add(m_playeranim_inst.active)
            local button_activenone = line:getwidget("button_active")
            button_activenone:setdelegate(playeranim_delegate_active)
            button_activenone.animtype = type
            button_activenone.animid = 0
            button_activenone:setvisible(m_playeranim_selectanimtype == type and m_playeranim_selectanimid == 0)
        end
    end

    local config_animcall = csvanimcard_getall()
    for i=1,#config_animcall do
        local config_animcard = config_animcall[i]
        if config_animcard.type == type then
            line = list_anim:add(m_playeranim_inst.name, type .. config_animcard.id, 0)
            line.cardtype = type
            line.cardid = config_animcard.id

            local expiredate = playerattr_animcard[config_animcard.id]
            local text_name = line:getwidget("text_name")
            local animtext = config_animcard.name
            local r = 1
            local g = 1
            local b = 1
            local activeable = true
            if expiredate == nil then
                r = 0.5
                g = 0.5
                b = 0.5
                activeable = false
                animtext = c_textformat("PLAYER_ANIM_NOTGET", config_animcard.name)
            elseif expiredate > 0 then
                local expiretext = timer_servercountdown(expiredate, true, true, false)
                if expiretext ~= nil then
                    animtext = c_textformat("PLAYER_ANIM_EXPIRE", config_animcard.name, expiretext)
                else
                    r = 0.5
                    g = 0.5
                    b = 0.5
                    activeable = false
                    animtext = c_textformat("PLAYER_ANIM_EXPIRED", config_animcard.name)
                end
            end
            if playeranim_animactived(type, config_animcard.id) then
                r = 0
                g = 1
                b = 0
                activeable = false
            end
            text_name:settext(animtext)
            text_name:setcolor(r,g,b,1)
            if activeable and m_playeranim_selectanimtype == type and m_playeranim_selectanimid == config_animcard.id then
                line = list_anim:add(m_playeranim_inst.active)
                local button_active = line:getwidget("button_active")
                button_active:setdelegate(playeranim_delegate_active)
                button_active.animtype = type
                button_active.animid = config_animcard.id
            end
        end
    end
end
function playeranim_updateui()
    local list_anim = m_uioverview_playermain:getwidget("tab_anim/list_anim")
    list_anim:savestate()
    list_anim:clear()
    playeranim_addcategory(list_anim, csvanimcardtype.idle, "PLAYER_ANIM_CATEGORYIDLE")
    playeranim_addcategory(list_anim, csvanimcardtype.run, "PLAYER_ANIM_CATEGORYRUN")
    playeranim_addcategory(list_anim, csvanimcardtype.jump, "PLAYER_ANIM_CATEGORYJUMP")
    playeranim_addcategory(list_anim, csvanimcardtype.rest, "PLAYER_ANIM_CATEGORYREST")
    list_anim:restorestate()
end

function playeranim_delegate_active(sender, event)
    local msg = {messageid="CS_AnimCard"}
    msg.type = sender.animtype
    msg.cardid = sender.animid
    c_send(msg)
end
