
local m_inputkeydown = nil
local m_inputkeyup = nil

local function inputkey_register(key, func)
    m_inputkeydown[key] = func
end

local function inputkey_registerkeyup(key, func)
    m_inputkeyup[key] = func
end

function inputkey_init()
    if not system_ispc() then
        return
    end
    m_inputkeydown = {}
    m_inputkeyup = {}

    inputkey_register("KEY_MOVEFORWARD", inputmove_forward)
    inputkey_register("KEY_MOVEBACKWARD", inputmove_backward)
    inputkey_register("KEY_MOVELEFT", inputmove_left)
    inputkey_register("KEY_MOVERIGHT", inputmove_right)
    inputkey_register("KEY_FLYUP", inputmove_flyup)
    inputkey_register("KEY_FLYDOWN", inputmove_flydown)
    inputkey_registerkeyup("KEY_MOVEFORWARD", inputmove_forwardstop)
    inputkey_registerkeyup("KEY_MOVEBACKWARD", inputmove_backwardstop)
    inputkey_registerkeyup("KEY_MOVELEFT", inputmove_leftstop)
    inputkey_registerkeyup("KEY_MOVERIGHT", inputmove_rightstop)
    inputkey_registerkeyup("KEY_FLYUP", inputmove_flyupstop)
    inputkey_registerkeyup("KEY_FLYDOWN", inputmove_flydownstop)
    inputkey_register("KEY_JUMP", inputkey_jump)
    inputkey_register("KEY_REST", inputkey_rest)
    inputkey_register("KEY_ATTACK", inputkey_attack)
    inputkey_register("KEY_SWITCHBATTLE", inputkey_switchbattle)
    inputkey_register("KEY_SWITCHEQUIP", inputkey_switchequip)
    inputkey_register("KEY_BATTERY", inputkey_battery)
    inputkey_register("KEY_SELECTENEMY", inputkey_selectenemy)
    inputkey_register("KEY_SELECTSIPID", inputkey_selectsipid)
    inputkey_register("KEY_SELECTPVPENEMY", inputkey_selectpvpenemy)
    inputkey_register("KEY_SELECTANY", inputkey_selectany)
    inputkey_register("KEY_SELECTSUBTARGET", inputkey_selecttarget)
    inputkey_register("KEY_SPIRITATTACK", inputkey_spiritattack)
    inputkey_register("KEY_SPIRITMOVE", inputkey_spiritmove)
    inputkey_register("KEY_SPIRITIDLE", inputkey_spiritidle)
    inputkey_register("KEY_SPIRITDISMISS", inputkey_spiritdismiss)
    inputkey_register("KEY_SELECTME", inputkey_selectme)
    inputkey_register("KEY_SELECTMATE1", inputkey_selectmate1)
    inputkey_register("KEY_SELECTMATE2", inputkey_selectmate2)
    inputkey_register("KEY_SELECTMATE3", inputkey_selectmate3)
    inputkey_register("KEY_SELECTMATE4", inputkey_selectmate4)
    inputkey_register("KEY_SELECTMATE5", inputkey_selectmate5)
    inputkey_register("KEY_CHATBOX", inputkey_chatbox)
    inputkey_register("KEY_ESCAPE", inputkey_escape)
    inputkey_register("KEY_UIOVERVIEW", inputkey_openoverview)
    inputkey_register("KEY_UIBAG", inputkey_openbag)
    inputkey_register("KEY_UIQUEST", inputkey_openquest)
    inputkey_register("KEY_UISKILL", inputkey_openskill)
    inputkey_register("KEY_UIMAP", inputkey_openmap)
    inputkey_register("KEY_UIMAPOPACITY", inputkey_openmapopacity)
    inputkey_register("KEY_UISTALL", inputkey_openstall)
    inputkey_register("KEY_UIPETLIST", inputkey_openpetlist)
    inputkey_register("KEY_UIPET", inputkey_openpet)
    inputkey_register("KEY_UIPAL", inputkey_openpal)
    inputkey_register("KEY_UITEAM", inputkey_openteam)
    inputkey_register("KEY_UIRAID", inputkey_openraid)
    inputkey_register("KEY_UIICC", inputkey_openicc)
    inputkey_register("KEY_UIRANK", inputkey_openrank)
    inputkey_register("KEY_UIDUNGEON", inputkey_opendungeon)
    for i=1,max_logo do
        inputkey_register("KEY_SETLOGO_" .. i, inputkey_setlogo)
        inputkey_register("KEY_SELECTELOGO_" .. i, inputkey_selectlogo)
    end

    for i=1,skill_skillbarslotmax do
        local keyname = string.format("KEY_SKILL_%d", i)
        inputkey_register(keyname, inputkey_skillbar)
	end
    for i=1,skill_actionbarslotmax do
        local lineindex = math.tointegerfloor((i - 1) / skill_actionbarlineslot) + 1
        local slotindex = math.fmod(i - 1, skill_actionbarlineslot) + 1
		local keyname = string.format("KEY_ACTION_%d_%d", lineindex, slotindex)
    	inputkey_register(keyname, inputkey_actionbar)
	end
end

function inputkey_onkey(inputkey)
    if m_inputkeydown ~= nil and gameserver_entered() and not scene_isloading() then
        if setting_inputmapping_isinputactive() then
            setting_inputmapping_onkeyinput(inputkey)
            return
        end
        local name = gamesetting_getkeynamefromval(inputkey)
    	if name ~= nil then
            local func = m_inputkeydown[name]
            if func ~= nil then
                func(name)
            end
        end
    end
end

function inputkey_onkeyup(inputkey)
    if m_inputkeyup ~= nil and gameserver_entered() and not scene_isloading() then
        if setting_inputmapping_isinputactive() then
            return
        end
        local name = gamesetting_getkeynamefromval(inputkey)
    	if name ~= nil then
            local func = m_inputkeyup[name]
            if func ~= nil then
                func(name)
            end
        end
    end
end

function inputkey_openui(ui)
    if ui:alive() then
        ui:close()
    else
        ui:open()
    end
end

function inputkey_skillbar(name)
    skillbar_keydown(name)
end

function inputkey_actionbar(name)
    actionbar_keydown(name)
end

function inputkey_chatbox()
    chat_openinput()
end

function inputkey_escape()
    uimanager_escape()
end

function inputkey_jump()
    if m_me == nil then
        return
    end
    if playerattr_isvehicle() then
        for i=1, #m_me.buff do
            local buff = m_me.buff[i]
            if buff.config_buff.vehicle > 0 then
                local msg = {messageid="CS_RemoveBuff"}
                msg.buffinstid = buff.buffinstid
                c_send(msg)
                break
            end
        end
    elseif playerattr_info.movetype == playermovestate.move then
        if m_me.transform.onfloor then
            if m_me:movable() and not m_me.transform.sliding and m_me.actionmain.config_buffaction == nil then
                local movex = m_me.move.inputmove_x
                local movez = m_me.move.inputmove_z
                if movex == 0.0 and movez == 0.0 then
                    local actionid = actionmanager_getactionid(m_me)
                    if actionid ~= nil and actionid == actionname.glide then
                        movex, movez = m_me:getdirection2d(dir)
                    end
                end
                local msg = {messageid="CS_Jump"}
                msg.posx = playerattr_info.posx
                msg.posy = playerattr_info.posy
                msg.posz = playerattr_info.posz
                msg.rot = playerattr_info.rot
                msg.movex = movex
                msg.movez = movez
                c_send(msg)
                m_me:movesetjump(movex, movez)
            end
        else
            if m_me.attr.career >= playercareer.fighter then
                if m_me:getbufftypename("nofly") ~= nil then
                    chat_addsystem(c_textformat("STR_GLIDE_CANNOT_GLIDE_ABNORMAL_STATUS"))
                else
                    local msg = {messageid="CS_SwitchGlide"}
                    msg.glide = 1
                    c_send(msg)
                end
            else
                chat_addsystem(c_textformat("STR_GLIDE_ONLY_DEVA_CAN"))
            end
        end
    elseif playerattr_info.movetype == playermovestate.fly then
        local msg = {messageid="CS_SwitchGlide"}
        msg.glide = 1
        c_send(msg)
    elseif playerattr_info.movetype == playermovestate.glide then
        if playerattr_info.movewindpathid ~= nil then
            if time_game - playerattr_info.movewindentertime > 4 then
                local msg = {messageid="CS_LeaveWindPath"}
                msg.posx = playerattr_info.posx
                msg.posy = playerattr_info.posy
                msg.posz = playerattr_info.posz
                c_send(msg)
            end
        elseif not timer_getcdcoding(cdtype_motion, cdmotion_movestate) then
            local msg = {messageid="CS_SwitchGlide"}
            msg.glide = 0
            c_send(msg)
        end
    end
end

function inputkey_rest()
    systemskill_rest()
end

function inputkey_attack()
    if m_selectactor ~= nil then
        if m_selectactor:isnpc() then
            npc_startscript(m_selectactor.actorid)
       elseif m_selectactor:isplayer() then
            playerbattleauto_startnormalattack(actor.actorid)
        end
    end
end

function inputkey_selectenemy()
    actormanager_autoselectactor(bit.bor(actorautoselect.enemynpc, actorautoselect.enemyplayer))
end

function inputkey_selectsipid()
    actormanager_autoselectactor(bit.bor(actorautoselect.sipidnpc, actorautoselect.sipidplayer))
end

function inputkey_selectpvpenemy()
    actormanager_autoselectactor(actorautoselect.enemyplayer)
end

function inputkey_selectany()
    actormanager_autoselectactor(-1)
end

function inputkey_selecttarget()
    actormanager_picksubactor()
end

function inputkey_selectme()
    actormanager_selectactor(m_me)
end

function inputkey_selectmate1()
    if playerattr_team ~= nil and #playerattr_team.mate > 0 then
        actormanager_selectactorid(playerattr_team.mate[1].playerid)
    end
end

function inputkey_selectmate2()
    if playerattr_team ~= nil and #playerattr_team.mate > 1 then
        actormanager_selectactorid(playerattr_team.mate[2].playerid)
    end
end

function inputkey_selectmate3()
    if playerattr_team ~= nil and #playerattr_team.mate > 2 then
        actormanager_selectactorid(playerattr_team.mate[3].playerid)
    end
end

function inputkey_selectmate4()
    if playerattr_team ~= nil and #playerattr_team.mate > 3 then
        actormanager_selectactorid(playerattr_team.mate[4].playerid)
    end
end

function inputkey_selectmate5()
    if playerattr_team ~= nil and #playerattr_team.mate > 4 then
        actormanager_selectactorid(playerattr_team.mate[5].playerid)
    end
end

function inputkey_openoverview()
    inputkey_openui(m_uioverview_playermain)
end

function inputkey_openbag()
    inputkey_openui(m_uibag_bag)
end

function inputkey_openskill()
    inputkey_openui(m_uiskill_main)
end

function inputkey_openquest()
    if m_uiquest_questmain:null() then
        quest_main_showquest(0, true)
    else
        m_uiquest_questmain:close()
    end
end

function inputkey_openpal()
    inputkey_openui(m_uipal_main)
end

function inputkey_openicc()
    if playerattr_icc ~= nil then
        m_uiicc_create:close()
        inputkey_openui(m_uiicc_main)
    else
        chat_addsystemalert("ICC_NONE")
    end
end

function inputkey_openteam()
    inputkey_openui(m_uiteam_recruit)
end

function inputkey_openraid()
    if m_uiraidmain:alive() then
        m_uiraidmain:close()
    else
        raid_main_open()
    end
end

function inputkey_openrank()
    inputkey_openui(m_uirank_main)
end

function inputkey_openmap()
    minimapadditive_delegate_worldmap()
end

function inputkey_openmapopacity()
    map_opacity_openui()
end

function inputkey_openstall()
    inputkey_openui(m_uistall_mine)
end

function inputkey_openpetlist()
    inputkey_openui(m_uipetmain)
end

function inputkey_openpet()
    if m_uipet_menu:alive() then
        m_uipet_menu:close()
    elseif m_me ~= nil then
        if m_me.pet.config_pet ~= nil and playerattr_info.petuuid ~= 0 then
            pet_menu_open(playerattr_info.petuuid)
        end
    end
end

function inputkey_opendungeon()
    inputkey_openui(m_uidungeon)
end

function inputkey_setlogo(name)
    local logo = string.tointeger(string.sub(name, string.len("KEY_SETLOGO_") + 1))
    local msg = {messageid="CS_ActorLogo"}
    msg.logo = logo
    msg.actorid = m_selectactorid
    c_send(msg)
end

function inputkey_selectlogo(name)
    local logo = string.tointeger(string.sub(name, string.len("KEY_SELECTELOGO_") + 1))
    local actorid = playerattr_logo[logo]
	if actorid ~= nil then
		local actor = actormanager_getfromactorid(actorid)
		if actor ~= nil then
			actormanager_selectactor(actor)
		end
	end
end

function inputkey_battery()
    systemskill_battery()
end

function inputkey_switchbattle()
    systemskill_battle()
end

function inputkey_switchequip()
    systemskill_equip()
end

function inputkey_spiritattack()
    systemskill_spiritattack()
end

function inputkey_spiritmove()
    systemskill_spiritmove()
end

function inputkey_spiritidle()
    systemskill_spiritidle()
end

function inputkey_spiritdismiss()
    systemskill_spiritdismiss()
end
