
-- XML_OpenShopBuy = "trade_buy" --npc商店购买
-- XML_OpenShopSell = "trade_sell" --npc商店出售
-- XML_OpenVendor = "open_vendor" --交易所
-- XML_OpenExchangeCoin = "exchange_coin" --换obs
-- XML_OpenExtendInventory = "extend_inventory" --扩大箱子
-- XML_OpenDepositCharWarehouse = "deposit_char_warehouse" --使用仓库
-- XML_OpenGuildWarehouse = "open_guild_warehouse" --军团仓库
-- XML_OpenAirlineService = "airline_service" --瞬间移动
-- XML_OpenRestoreXP = "restore_xp" --灵魂治愈
-- XML_OpenEnterPVP = "enter_pvp" --进入竞技场
-- XML_OpenLeavePVP = "leave_pvp" --离开竞技场
-- XML_OpenFactionJoin = "faction_join" --加入NPC组织
-- XML_OpenFactionSeparater = "faction_separate" --退出NPC组织
-- XML_OpenCompoundWeapon = "compound_weapon" --合成双手武器
-- XML_OpenDeCompoundWeapon = "decompound_weapon" --去除合成效果
-- XML_OpenStigmaOpen = "stigma_open" --装备/卸载烙印之石
-- XML_OpenGiveItemProc = "give_item_proc" --神石强化
-- XML_OpenRemoveItemOption = "remove_item_option" --去除魔石
-- XML_OpenChangeITemSkin = "change_item_skin" --变更装备外形
-- XML_OpenGatherSkillLevelup = "gather_skill_levelup" --升级采集技能
-- XML_OpenCombineSkillLevelup = "combine_skill_levelup" --升级制作技能
-- XML_OpenCombineTask = "combine_task" --委托制作
-- XML_OpenGuildChangeEmblem = "guild_change_emblem" --修改军团纹章
-- XML_OpenCreatePCGuild = "create_pcguild" --创建军团
-- XML_OpenDeletePCGuild = "delete_pcguild" --解散军团
-- XML_OpenRecreatePCGuild = "recreate_pcguild" --重建军团
-- XML_OpenGuildLevelUp = "guild_levelup" --升军团等级
-- XML_OpenChargeItem = "charge_item" --神圣力注入
-- XML_OpenChargeItemAuto = "charge_item_auto" --所有装备中的道具神圣力注入
-- XML_OpenMatchMaker = "match_maker" --渗透德雷得奇安
-- XML_OpenPetAdopt = "pet_adopt" --领养宠物
-- XML_OpenPetAbandon = "pet_abandon" --抛弃宠物
-- XML_OpenEditCharAll = "edit_char_all" --外貌变更
-- XML_OpenEditCharGender = "edit_char_gender" --性别变更
-- XML_OpenInstanceEntry = "instance_entry" --进入副本
-- XML_OpenTradeIn = "trade_in" --勋章奖励
-- XML_OpenInstancePartyMatch = instance_party_match 神庙3
-- XML_MAKE_MERCENARY = "MAKE_MERCENARY" --卡斯帕跟随NPC

function dialog_scriptoption_delegate_trade_buy(actorid)
    local msg = {messageid="CS_ShopOpen"}
    msg.actorid = actorid
    msg.buy = 1
    c_send(msg)
end

function dialog_scriptoption_delegate_trade_sell(actorid)
    local msg = {messageid="CS_ShopOpen"}
    msg.actorid = actorid
    msg.buy = 0
    c_send(msg)
end

function dialog_scriptoption_delegate_trade_in(actorid)
    local msg = {messageid="CS_ShopOpen"}
    msg.actorid = actorid
    msg.buy = 1
    c_send(msg)
end

function dialog_scriptoption_delegate_open_vendor(actorid)
    local msg = {messageid="CS_BusinessOpen"}
    msg.npcactorid = actorid
    c_send(msg)
end

function dialog_scriptoption_delegate_exchange_coin(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc == nil then
        return
    end
    local lambda = csvnpc_getscript(npc.config_npc, "exchangecoin")
    if lambda == nil then
        return
    end
    local questid = lambda.variable[1].integer
    if questid == 1833 or questid == 1834 or questid == 1835 or questid == 1836
    or questid == 2834 or questid == 2835 or questid == 2836 or questid == 2837
    or questid == 1849 or questid == 1850
    or questid == 11279 or questid == 11280 or questid == 11281 or questid == 11282 or questid == 11283 or questid == 11284 or questid == 11285 or questid == 11286
    or questid == 21281 or questid == 21282 or questid == 21283 or questid == 21284 or questid == 21285 or questid == 21286 or questid == 21287 or questid == 21288 then
        local msg = {messageid="CS_ObsExchangeOpen"}
        msg.actorid = actorid
        c_send(msg)
    else
        npc_sendtalk(actorid, npctalktype.talkstart, lambda.variable[1].integer, nil)
    end
end

function dialog_scriptoption_extend_inventory_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_ExtendInventory"}
        msg.actorid = data
        msg.level = playerattr_bagspacelevel
        c_send(msg)
    end
end
function dialog_scriptoption_delegate_extend_inventory(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc ~= nil then
        local lambda = csvnpc_getscript(npc.config_npc, "extendinventory")
        if lambda ~= nil then
            local maxlevel = lambda.variable[1].integer
            if playerattr_bagspacelevel < maxlevel then
                local price = { 1000, 10000, 50000, 150000, 300000 };
                local text = c_textformat("NPC_ASK_BAGEXTEND", price[playerattr_bagspacelevel + 1])
                messagebox_confirm(text, dialog_scriptoption_extend_inventory_confirm, actorid)
            else
                chat_addsystemalert("NPC_ASK_BAGEXTEND_FULL")
            end
        end
    end
end

function dialog_scriptoption_delegate_deposit_char_warehouse(actorid)
    local msg = {messageid="CS_StorageOpen"}
    msg.actorid = actorid
    c_send(msg)
end

function dialog_scriptoption_delegate_open_guild_warehouse(actorid)
    local msg = {messageid="CS_IccStorageOpen"}
    msg.actorid = actorid
    c_send(msg)
end

function dialog_scriptoption_delegate_airline_service(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc ~= nil then
        local lambda = csvnpc_getscript(npc.config_npc, "airport")
        if lambda ~= nil then
            map_teleport_create(lambda.variable[1].integer)
        end
    end
end

function dialog_scriptoption_restore_xp_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_RestoreExp"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_delegate_restore_xp(actorid)
    local costcoin = 0
    if playerattr_info.explost > 0 then
        costcoin = math.max(1, math.floor(playerattr_info.explost / 10))
    elseif playerattr_info.fatigue > 0 then
        costcoin = 1
    end
    if costcoin == 0 then
        chat_addsystemalert("NPC_ASK_EXPLOST_NONE")
        return
    end
    messagebox_confirm(c_textformat("NPC_ASK_EXPLOST_RESTORE", costcoin), dialog_scriptoption_restore_xp_confirm, actorid)
end

function dialog_scriptoption_delegate_enter_pvp(actorid)
    local msg = {messageid="CS_PvPZone"}
    msg.actorid = actorid
    c_send(msg)
end

function dialog_scriptoption_delegate_leave_pvp(actorid)
    dialog_scriptoption_delegate_enter_pvp(actorid)
end

function dialog_scriptoption_faction_join_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_FactionJoin"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_delegate_faction_join(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc ~= nil then
        local lambda = csvnpc_getscript(npc.config_npc, "faction")
        if lambda ~= nil then
            local config_faction = csvnpcfaction_getfromid(lambda.variable[1].integer)
            if config_faction ~= nil then
                if playerattr_info.faction == config_faction.id then
                    chat_addsystemalert(c_textformat("NPC_ASK_FACTION_JOINALREADY", config_faction.name))
                    return
                end
                if playerattr_info.level < config_faction.level then
                    chat_addsystemalert(c_textformat("NPC_ASK_FACTION_LEVELNOTENOUGH", config_faction.level, config_faction.name))
                    return
                end
                local text = c_textformat("NPC_ASK_FACTION_JOIN", config_faction.name)
                messagebox_confirm(text, dialog_scriptoption_faction_join_confirm, actorid)
            end
        end
    end
end

function dialog_scriptoption_faction_separate_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_FactionLeave"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_delegate_faction_separate(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc ~= nil then
        local lambda = csvnpc_getscript(npc.config_npc, "faction")
        if lambda ~= nil then
            local config_faction = csvnpcfaction_getfromid(lambda.variable[1].integer)
            if config_faction ~= nil then
                if playerattr_info.faction ~= config_faction.id then
                    chat_addsystemalert(c_textformat("NPC_ASK_FACTION_LEAVENONE", config_faction.name))
                    return
                end
                local text = c_textformat("NPC_ASK_FACTION_LEAVE", config_faction.name)
                messagebox_confirm(text, dialog_scriptoption_faction_separate_confirm, actorid)
            end
        end
    end
end

function dialog_scriptoption_delegate_compound_weapon(actorid)
    equiplab_show(0, equiplab_tabtype.compound, actorid)
end

function dialog_scriptoption_delegate_decompound_weapon(actorid)
    equiplab_show(0, equiplab_tabtype.decompound, actorid)
end

function dialog_scriptoption_delegate_stigma_open(actorid)
    local msg = {messageid="CS_SkillStigmaOpen"}
    msg.actorid = actorid
    c_send(msg)
end

function dialog_scriptoption_delegate_give_item_proc(actorid)
    equiplab_show(0, equiplab_tabtype.god, actorid)
end

function dialog_scriptoption_delegate_remove_item_option(actorid)
    equiplab_show(0, equiplab_tabtype.gemremove, actorid)
end

function dialog_scriptoption_delegate_change_item_skin(actorid)
    equiplab_show(0, equiplab_tabtype.skin, actorid)
end

function dialog_scriptoption_delegate_gather_skill_levelup(actorid)
    crafting_skilllevelup(actorid)
end

function dialog_scriptoption_delegate_combine_skill_levelup(actorid)
    crafting_skilllevelup(actorid)
end

function dialog_scriptoption_delegate_combine_task(actorid)
    local npc = actormanager_getfromactorid(actorid)
    if npc ~= nil then
        dialogtask_settaskmain(actorid, npc.config_npc)
    end
end

function dialog_scriptoption_delegate_guild_change_emblem(actorid)
    icc_selectlogo(actorid)
end

function dialog_scriptoption_delegate_create_pcguild(actorid)
    icc_create(actorid)
end

function dialog_scriptoption_delegate_delete_pcguild(actorid)
    icc_disband(actorid)
end

function dialog_scriptoption_delegate_recreate_pcguild(actorid)
    icc_disbandcancel(actorid)
end

function dialog_scriptoption_delegate_guild_levelup(actorid)
    icc_levelup(actorid)
end

function dialog_scriptoption_delegate_charge_item(actorid)
    equipcharge_single(actorid)
end

function dialog_scriptoption_delegate_charge_item_auto(actorid)
    equipcharge_all(actorid)
end

function dialog_scriptoption_delegate_match_maker(actorid)
    homemenu_delegate_dredgion()
end

function dialog_scriptoption_delegate_pet_adopt(actorid)
    pet_adopt_open(actorid)
end

function dialog_scriptoption_delegate_pet_abandon(actorid)
    pet_abandon_open(actorid)
end

function dialog_scriptoption_delegate_edit_char_all(actorid)
    local item = playeritem_getfrombagscript("resetroleskin")
    if item ~= nil then
        local msg = {messageid="CS_PlayerResetSkinStart"}
        msg.actorid = actorid
        msg.itemuuid = item.uuid
        c_send(msg)
    else
        chat_addsystemalert("PLAYER_RESETSKIN_NOITEM")
    end
end

function dialog_scriptoption_delegate_edit_char_gender(actorid)
    local item = playeritem_getfrombagscript("resetrolesex")
    if item ~= nil then
        local msg = {messageid="CS_PlayerResetSkinStart"}
        msg.actorid = actorid
        msg.itemuuid = item.uuid
        c_send(msg)
    else
        chat_addsystemalert("PLAYER_RESETSEX_NOITEM")
    end
end

function dialog_scriptoption_delegate_instance_entry(actorid)
    npc_sendtalk(actorid, npctalktype.talkselect, 0, XML_SelectNone)
end

function dialog_scriptoption_delegate_instance_party_match(actorid)
    if not arenaselect(actorid) then
        m_uiteam_recruit:open()
    end
end

function dialog_scriptoption_delegate_make_mercenary(actorid)
    local msg = {messageid="CS_Mercenary"}
    msg.actorid = actorid
    c_send(msg)
end

function dialog_scriptoption_execute(type, actorid)
    local func = _G["dialog_scriptoption_delegate_" .. type]
    if func ~= nil then
        func(actorid)
        return true
    end
    return false
end
