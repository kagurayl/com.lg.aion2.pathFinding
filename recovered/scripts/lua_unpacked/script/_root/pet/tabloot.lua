
function tabloot_updateui()
    if m_uipet_menu:null() then
        return
    end
    for i=csvitemquality.grey, csvitemquality.red do
        local checkbox_quality = m_uipet_menu:getwidget("tab_loot/checkbox_quality" .. i)
        checkbox_quality.quality = i
        checkbox_quality.checked = i == m_uipet_menu.pet.lootquality
        checkbox_quality:setdelegate(tabloot_delegate_quality)
        checkbox_quality:setcheck(checkbox_quality.checked)
    end
    local checkbox_questitem = m_uipet_menu:getwidget("tab_loot/checkbox_questitem")
    checkbox_questitem:setdelegate(tabloot_delegate_questitem)
    checkbox_questitem:setcheck(m_uipet_menu.pet.lootquestitem > 0)
    checkbox_questitem.checked = m_uipet_menu.pet.lootquestitem > 0
end

function tabloot_delegate_quality(sender, event)
    if sender:getcheck() then
        local msg = {messageid="CS_PetLoot"}
        msg.uuid = m_uipet_menu.pet.uuid
        msg.quality = sender.quality
        msg.questitem = -1
        c_send(msg)
    end
    sender:setcheck(sender.checked)
end

function tabloot_delegate_questitem(sender, event)
    local checkbox_questitem = m_uipet_menu:getwidget("tab_loot/checkbox_questitem")
    local questitem = checkbox_questitem:getcheck()
    checkbox_questitem:setcheck(checkbox_questitem.checked)

    local msg = {messageid="CS_PetLoot"}
    msg.uuid = m_uipet_menu.pet.uuid
    msg.quality = -1
    msg.questitem = math.ternary(questitem, 1, 0)
    c_send(msg)
end
