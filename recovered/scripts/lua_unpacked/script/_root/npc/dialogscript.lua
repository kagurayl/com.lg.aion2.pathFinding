
function dialog_scriptoption_mail(actorid)
    m_uimail_main.npcactorid = actorid
    m_uimail_main:open()
end

function dialog_scriptoption_resurrect_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_BindResurrect"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_resurrect(npcactorid)
    messagebox_confirm("NPC_QSK_RESURRECT", dialog_scriptoption_resurrect_confirm, npcactorid)
end

function dialog_scriptoption_qsk_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_BindQsk"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_qsk(npcactorid)
    if playerattr_info.qskactorid == npcactorid then
        chat_addsystemalert("NPC_QSK_QSKSAME")
        return 
    end
    local npc = actormanager_getfromactorid(npcactorid)
    if npc == nil then
        return
    end
    local lambda = csvnpc_getscript(npc.config_npc, "qsk")
    if lambda == nil then
        return
    end
    if npc.attr.qskmember >= lambda.variable[2].integer then
        chat_addsystemalert("NPC_QSK_QSKFULL")
        return
    end
    messagebox_confirm("NPC_QSK_CONFIRM", dialog_scriptoption_qsk_confirm, npcactorid)
end

function dialog_scriptoption_summongate_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_GroupGate"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_summongate(npcactorid)
    if playerattr_info.civ == playerciv.light then
        messagebox_confirm("NPC_ASK_GROUPGATE_LIGHT", dialog_scriptoption_summongate_confirm, npcactorid)
    else
        messagebox_confirm("NPC_ASK_GROUPGATE_DARK", dialog_scriptoption_summongate_confirm, npcactorid)
    end
end

function dialog_scriptoption_abyssdoor_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_AbyssDoor"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_abyssdoor(npcactorid)
    messagebox_confirm("NPC_ASK_ABYSSDOOR", dialog_scriptoption_abyssdoor_confirm, npcactorid)
end

function dialog_scriptoption_abyssartifact(npcactorid)
    local msg = {messageid="CS_AbyssArtifactQuery"}
    msg.actorid = npcactorid
    c_send(msg)
end

function dialog_scriptoption_abyssdoorrepair(npcactorid)
    local msg = {messageid="CS_AbyssDoorRepairQuery"}
    msg.actorid = npcactorid
    c_send(msg)
end

function dialog_scriptoption_directportal_confirm(ok, data)
    if ok then
        local msg = {messageid="CS_DirectPortal"}
        msg.actorid = data
        c_send(msg)
    end
end
function dialog_scriptoption_directportal(npcactorid)
    messagebox_confirm("NPC_ASK_DIRECTPORTAL", dialog_scriptoption_directportal_confirm, npcactorid)
end

dialogscript_action =
{
    {action = "shop", text = "NPC_SCRIPT_SHOP", delegate = dialog_scriptoption_delegate_trade_buy},
    {action = "mail", text = "NPC_SCRIPT_MAIL", delegate = dialog_scriptoption_mail},
    {action = "resurrect", text = "NPC_SCRIPT_RESURRECT", delegate = dialog_scriptoption_resurrect},
    {action = "qsk", text = "NPC_SCRIPT_QSK", delegate = dialog_scriptoption_qsk},
    {action = "airport", text = "NPC_SCRIPT_AIRPORT", delegate = dialog_scriptoption_delegate_airline_service},
    {action = "recovery", text = "NPC_SCRIPT_RECOVERY", delegate = dialog_scriptoption_delegate_restore_xp},
    {action = "stigmaequip", text = "NPC_SCRIPT_STIGMA", delegate = dialog_scriptoption_delegate_stigma_open},
    {action = "vendor", text = "NPC_SCRIPT_VENDOR", delegate = dialog_scriptoption_delegate_open_vendor},
    {action = "summongate", text = "", delegate = dialog_scriptoption_summongate},
    {action = "abyssdoor", text = "", delegate = dialog_scriptoption_abyssdoor},
    {action = "abyssartifact", text = "", delegate = dialog_scriptoption_abyssartifact},
    {action = "abyssdoorrepair", text = "", delegate = dialog_scriptoption_abyssdoorrepair},
    {action = "directportal", text = "", delegate = dialog_scriptoption_directportal},
}

function dialog_scriptoption_openscriptdialog(npcactorid, config_npc)
	local npcscript = config_npc.script
    if npcscript == nil then
		return
    end
    local actioncount = npcscript.actioncount
    for i=1,actioncount do
		local sublambda = npcscript[i]
        for j=1,#dialogscript_action do
            if c_isaction(sublambda, dialogscript_action[j].action) then
                dialogscript_action[j].delegate(npcactorid)
                return
            end
        end
    end
end

function dialog_scriptoption_scripttext(config_npc)
	local npcscript = config_npc.script
    if npcscript == nil then
		return
    end
    local actioncount = npcscript.actioncount
    for i=1,actioncount do
		local sublambda = npcscript[i]
        for j=1,#dialogscript_action do
            if c_isaction(sublambda, dialogscript_action[j].action) then
                return dialogscript_action[j].text
            end
        end
    end
end
