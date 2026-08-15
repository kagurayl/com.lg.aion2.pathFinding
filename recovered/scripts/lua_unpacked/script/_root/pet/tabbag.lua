
function tabbag_onopen()
    local text_desc = m_uipet_menu:getwidget("tab_bag/text_desc")
    local lambda1 = m_uipet_menu.config_pet.skill1
    local lambda2 = m_uipet_menu.config_pet.skill2
    local lambda = nil
    if lambda1 ~= nil and c_isaction(lambda1[1], "bag") then
        lambda = lambda1
    elseif lambda2 ~= nil and c_isaction(lambda2[1], "bag") then
        lambda = lambda2
    end
    if lambda ~= nil then
        text_desc:settext("PETMENU_BAG_DESC", lambda[1].variable[1].integer)
    end
end
