include("icc/icccreate")
include("icc/iccmain")
include("icc/iccmember")
include("icc/icclog")
include("icc/iccnoteinput")
include("icc/icclogo")

icc_create_cost = 1000000
icc_levelup_cost = { 1000000, 10000000 };
icc_levelup_member = { 10, 50, 100 };
icc_member_max = { 15, 100, 150 };

function icc_create(npcactorid)
    m_uiicc_create:open()
    m_uiicc_create.npcatorid = npcactorid
end

function icc_selectlogo(npcactorid)
    if playerattr_icc ~= nil then
        m_uiicc_logo:open()
        m_uiicc_logo.npcatorid = npcactorid
    else
        chat_addsystemalert("ICC_NONE")
    end
end

function icc_getlogofile(logo)
    if playerattr_info.civ == playerciv.light then
        return string.format("icclogo/predef_l_%d", logo)
    else
        return string.format("icclogo/predef_d_%d", logo)
    end
end

function icc_disband_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccDisband"}
        msg.npcactorid = data
        c_send(msg)
    end
end
function icc_disband(npcactorid)
    messagebox_confirm("ICC_DISBAND_REQUEST", icc_disband_confirm, npcactorid)
end

function icc_disbandcancel_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccDisbandCancel"}
        msg.npcactorid = data
        c_send(msg)
    end
end
function icc_disbandcancel(npcactorid)
    messagebox_confirm("ICC_DISBAND_CANCEL", icc_disbandcancel_confirm, npcactorid)
end

function icc_disbandlevelup_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_IccLevelUp"}
        msg.npcactorid = data
        c_send(msg)
    end
end
function icc_levelup(npcactorid)
    if playerattr_icc.level < #icc_levelup_cost then
        local text = c_textformat("ICC_LEVELUP_COST", icc_levelup_cost[playerattr_icc.level], icc_levelup_member[playerattr_icc.level])
        messagebox_confirm(text, icc_disbandlevelup_confirm, npcactorid)
    end
end
