
local function playerenter_create(msg)
	local actor = actormanager_createactor(RenderLayerPlayer, msg.actorid)
	actor.actortype = actorgametype.player
	actor.attr = {}
	actor.attr.name = msg.name
	actor.attr.iccname = msg.iccname
	actor.attr.icclogo = msg.icclogo
	actor.attr.moverun = msg.moverun
	actor.attr.movetype = msg.movetype
	actor.attr.movespeed = msg.movespeed
	actor.attr.flyspeed = msg.flyspeed
	actor.attr.attackspeed = msg.attackspeed
	actor.attr.civ = msg.civ
	actor.attr.tribe = csvnpctribe_getfromid(msg.tribe)
	actor.attr.sex = msg.sex
	actor.attr.voice = msg.voice
	actor.attr.career = msg.career
	actor.attr.areapvp = msg.areapvp
	csvrender_skintoattr(actor.attr, msg.skin)
	
	actor.attr.stalladvert = msg.stall
	actor.attr.title = msg.title
	actor.attr.pvptitle = msg.pvptitle
	actor.attr.petid = msg.petid
	actor.attr.animidle = msg.animidle
	actor.attr.animrun = msg.animrun
	actor.attr.animjump = msg.animjump
	actor.attr.animrest = msg.animrest
	actor.attr.animidlekey = csvanimcard_getkey(actor.attr.animidle)
	actor.attr.animrunkey = csvanimcard_getkey(actor.attr.animrun)
	actor.attr.animjumpkey = csvanimcard_getkey(actor.attr.animjump)
	actor.attr.animrestkey = csvanimcard_getkey(actor.attr.animrest)
	actor.attr.renderhelmet = msg.renderhelmet
	actor.attr.renderemblem = msg.renderemblem

	actor.attr.level = msg.level
	actor.attr.hp = msg.hp
	actor.attr.mp = msg.mp
	actor.attr.dp = msg.dp
	actor.attr.fp = msg.fp
	actor.attr.hpmax = msg.hpmax
	actor.attr.mpmax = msg.mpmax
	actor.attr.dpmax = msg.dpmax
	actor.attr.fpmax = msg.fpmax
	actor.attr.posx = msg.posx
	actor.attr.posy = msg.posy
	actor.attr.posz = msg.posz
	actor.attr.rot = msg.rot
	actor.attr.godstonemain = msg.godstonemain
	actor.attr.godstonesub = msg.godstonesub
	actor.attr.equipview = msg.equip
	actor.attr.equipdye = {}
	for i=1,#msg.dye do
		actor.attr.equipdye[i] = csvitem_getdyecolor(msg.dye[i])
	end
	if msg.dead > 0 then
		actor.attr.deadtime = 0
	end
	actor:initpet()
	actor:initattr(msg.buff)
end

function SC_PlayerEnter(msg)
	playerenter_create(msg.info)
end

function SC_PlayerEnterArray(msg)
	for i=1,#msg.info do
		playerenter_create(msg.info[i])
	end
end

function SC_PlayerSelectable(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if msg.time > 0 then
			actor.timeselectable = time_game + msg.time
		else
			actor.timeselectable = nil
		end
	end
end

function SC_ActorTribe(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.tribe = csvnpctribe_getfromid(msg.tribeid)
		if actor:isme() then
			actormanager_updatenameplate()
		else
			actor:updatenameuilayout()
		end
	end
end

function SC_SetMapPrepare(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if msg.type == 1 then
			actor.actionmain.talknpctype = npcmotiontype.teleportout
			actor.actionmain.talknpcteleport = msg.type
		else
			actor:createvfx(EffectSetMapPrepare, nil, true)
			actor.actionmain.talknpcteleport = nil
		end
		if actor:isme() then
			npc_closedialog()
		end
	end
end

function SC_SetMap(msg)
	scene_setloading()
	playerattr_info.mapid = msg.mapid
	playerattr_info.posx = msg.posx
	playerattr_info.posy = msg.posy
	playerattr_info.posz = msg.posz
	playerattr_info.rot = msg.rot
	if m_me ~= nil then
		npc_closedialog()
		local scale = m_me:getscale()
		m_me:settransform(m_me.attr.posx, m_me.attr.posy, m_me.attr.posz, 0.0, m_me.attr.rot, 0.0, scale, scale, scale)	
	end
	scene_setmap(playerattr_info.mapid)
end

function SC_NPCTeleport(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.npcstate = npcsyncstate.teleport
	end
end

function SC_Teleport(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			local dist = vector3_distance(msg.posx, msg.posy, msg.posz, actor.attr.posx, actor.attr.posy, actor.attr.posz)
			if dist > 256 then
				loadingblack_open(loadingblacktype.teleport)
			end
		end
		if actor.actionmain.talknpcteleport ~= nil then
			actor.actionmain.talknpctype = npcmotiontype.teleportin
			actor.actionmain.talknpcteleport = nil
		end
		if actor:isplayer() and actor.attr.movetype == playermovestate.move then
			msg.posy = scene_getfloorheight(msg.posx, msg.posy, msg.posz, 0)
		end
		actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
		actor:stopmove()
		if actor:isme() then
			npc_closedialog()
		end
	end
end

function SC_MoveReset(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:moveplayerclearmovequeue()
		actor.attr.movewindpathid = nil
		if actor.actordata.sequencetimestart ~= nil then
			actor.actordata.sequencetimestart = nil
			c_actor_flightstop(actor.id, 2)
		end
	end
end

function SC_Move(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		local dx, dy = vector2_rotatestandard3d(msg.rot)
		msg.dirx, msg.diry, msg.dirz = vector3_normalize(dx, 0.0, dy)
		msg.direction = movedirection.forward
		actor:moveplayeraddmove(msg)
	end
end

function SC_MoveEx(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		msg.dirx, msg.diry, msg.dirz = vector3_normalize(msg.movex, msg.movey, msg.movez)
		actor:moveplayeraddmove(msg)
	end
end

function SC_MoveNPC(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.npcstate = msg.state
		actor.attr.posx = msg.posx
		actor.attr.posy = msg.posy
		actor.attr.posz = msg.posz
		actor:movesetnpcmovesync(msg.destx, msg.desty, msg.destz, msg.speed, msg.anim)
	end
end

function SC_MovePlayer(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.posx = msg.posx
		actor.attr.posy = msg.posy
		actor.attr.posz = msg.posz
		local time = 0.0
		if msg.speed > 0.0 then
			local distance = vector3_distance(actor.attr.posx, actor.attr.posy, actor.attr.posz, msg.destx, msg.desty, msg.destz)
			time = distance / msg.speed
		end
		actor:moveplayersetmovedest(msg.destx, msg.desty, msg.destz, time)
	end
end

function SC_MoveState(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			if actor.attr.movetype ~= playermovestate.fly and msg.state == playermovestate.fly then
				audiomanager_playaudioui(AudioFlyStart)
				if actor.attr.fp <= 5 then
					audiomanager_playaudioui(AudioFly5)
				elseif actor.attr.fp <= 15 then
					audiomanager_playaudioui(AudioFly15)
				end
				tutorialtips_open(tutorialid.tipsfly)
			end
			timer_setcd(cdtype_motion + cdmotion_movestate, 0.5, 0.5)
		end
		actor.attr.movetype = msg.state
		actor.actionmain.jumpdirx = 0
		actor.actionmain.jumpdirz = 0
		actor.move.velocity = 0.0
		if actor.attr.movetype == playermovestate.rest then
			actor:setbattle(0, true)
		end
		if actor.attr.movetype ~= playermovestate.fly then
			actor:setrotation(0.0, actor.transform.ry, 0.0)
		end
	end
end

function SC_Rotate(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:moveplayeraddrotate(msg.rot)
	end
end

function SC_SetPosition(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil and actor:isplayer() then
		actor:moveplayerclearmovequeue()
		if actor.attr.movetype == playermovestate.move then
			local posy = actor.attr.posy
			if math.abs(msg.posy - actor.attr.posy) > 1 then
				posy = msg.posy
			end
			actor:setactorpositionskipfloor(msg.posx, posy, msg.posz, msg.rot)
		elseif actor.attr.movetype == playermovestate.glide then
			local dist = vector3_distance(actor.attr.posx, actor.attr.posy, actor.attr.posz, msg.posx, msg.posy, msg.posz)
			if dist > 1 then
				actor:setactorpositionskipfloor(msg.posx, msg.posy, msg.posz, msg.rot)
			else
				actor:setactorrotation(msg.rot)
			end
		elseif actor.attr.movetype == playermovestate.fly then
			actor:setactorpositionskipfloor(msg.posx, msg.posy, msg.posz, msg.rot)
		end
	end
end

function SC_Falling(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil and actor:isplayer() then
		actor:moveplayerclearmovequeue()
		local posy = actor.attr.posy
		if math.abs(msg.posy - actor.attr.posy) > 1 then
			posy = msg.posy
		end
		actor:setactorpositionskipfloor(msg.posx, posy, msg.posz, msg.rot)
		actor.actionmain.jumpdirx = msg.movex
		actor.actionmain.jumpdirz = msg.movez
		actor.move.velocity = msg.velocity
	end
end

function SC_Stop(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
		actor:stopmove()
	end
end

function SC_RevealSync(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:moveplayerclearmovequeue()
		actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
	end
end

function SC_MoveAdjust(msg)
	if m_me ~= nil then
		m_me.move.windboxmax = nil
		m_me:setactorpositionskipfloor(msg.posx, msg.posy, msg.posz, msg.rot)
	end
end

function SC_MoveAdjustFly(msg)
	if m_me ~= nil then
		m_me.move.adjustflytimestart = time_game
		m_me.move.adjustflyposxstart = playerattr_info.posx
		m_me.move.adjustflyposystart = playerattr_info.posy
		m_me.move.adjustflyposzstart = playerattr_info.posz
		m_me.move.adjustflyrotstart = playerattr_info.rot
		m_me.move.adjustflyposx = msg.posx
		m_me.move.adjustflyposy = msg.posy
		m_me.move.adjustflyposz = msg.posz
		m_me.move.adjustflyrot = msg.rot
		m_me:createvfx(EffectFlyLimit, vfx_bind_center, true)
	end
end

function SC_MoveAirFlow(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.move.airflowtime = time_game
		actor.move.velocity = 8
	end
end

function SC_Jump(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:movesetjump(msg.movex, msg.movez)
	end
end

function SC_ActorLeave(msg)
	actormanager_destroyfromactorid(msg.actorid)
end

function SC_ActorLeaveArray(msg)
	for i=1,#msg.actorid do
		actormanager_destroyfromactorid(msg.actorid[i])
	end
end

function SC_ActorLeaveAll(msg)
	local actorlist = actormanager_getactorlist()
	local removeactor = {}
	for key, value in pairs(actorlist) do
		if not value:isme() then
			removeactor[#removeactor + 1] = value
		end
	end
	for i=1,#removeactor do
		actormanager_destroyfromactorid(removeactor[i].actorid)
	end
end

function SC_ActorSelect(msg)
	if playerattr_info.actorid ~= msg.actorid then
		local actor = actormanager_getfromactorid(msg.actorid)
		if actor ~= nil then
			actor.attr.selection = msg.selection
			if actor:isnpc() then
				actor:setbattle(math.ternary(msg.selection ~= 0, 1, 0), true)
			end	
		end
	end
end

function SC_FlightStart(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if msg.name ~= nil then
			local moviepath = string.lower(string.format("sequences/flightpath/%s.prefab", msg.name))
			if scene_isloading() then
				if actor:isme() then
					scene_getloadingattr().flightpath = moviepath
					scene_getloadingattr().flighttimestart = msg.timestart
				end
			else
				actor:clearsequence()
				actor.actordata.sequencetimestart = time_game - msg.timestart
				actor.actordata.sequencecg = false
				c_actor_flightstart(moviepath, actor.id, actor:getcgvoice(), msg.timestart)
			end
		end
	end
end

function SC_FlightStop(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor.actordata.sequencetimestart ~= nil then
			actor.actordata.sequencetimestart = nil
			c_actor_flightstop(actor.id, 2)
		end
		actor.attr.rot = actor.transform.ry
		actor:setactorposition(msg.posx, msg.posy, msg.posz, actor.attr.rot)
		actor:setscale(actor.transform.sx, actor.transform.sy, actor.transform.sz)
	end
end

function SC_WindBoxJump(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.move.velocity = 50
	end
end

function SC_WindBoxGlide(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.move.windboxmax = msg.maxy
	end	
end

function SC_EnterWindPath(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.movewindpathid = msg.id
		actor.attr.movewindpoint = msg.pointindex
		actor.attr.movewindspeed = msg.speed
		actor.attr.movewinddashspeed = msg.speed
		actor.attr.movewinddashtime = 0.0
		actor.attr.movewindentertime = time_game
		if actor:isme() then
			joystick_stoplockmove()
			actor:createvfx(EffectWindPathDrag, vfx_bind_center, true)
		end
	end
end

function SC_DashWindPath(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor.attr.movewinddashspeed = msg.speed
		actor.attr.movewinddashtime = time_game + msg.time
	end
end

function SC_LeaveWindPath(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		if actor:isme() then
			if vector3_distance(msg.posx, msg.posy, msg.posz, actor.attr.posx, actor.attr.posy, actor.attr.posz) > 1.0 then
				actor:setactorposition(msg.posx, msg.posy, msg.posz, actor.attr.rot)
			end
		else
			actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
		end
		actor.attr.movewindleavetime = time_game
		actor.attr.movewindleaveid = actor.attr.movewindpathid
		actor.attr.movewindpathid = nil
	end
end

function SC_ActorDespawn(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil then
		actor:setactorposition(msg.posx, msg.posy, msg.posz, msg.rot)
		actor:stopmove()
		actor.attr.clientstate = npcclientstate.despawn
		actormanager_disappear(actor, 2.0)
	end
end

function SC_PlayerOnline(msg)
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.actorid then
			playerattr_pal[i].online = 1
			pallist_updateui()
			break
		end
	end
	if playerattr_icc ~= nil then
		for i=1,#playerattr_icc.member do
			if playerattr_icc.member[i].playerid == msg.actorid then
				playerattr_icc.member[i].disconnect = 0
				icc_updateui()
				break
			end
		end
	end
	if playerattr_team ~= nil then
		for i=1,#playerattr_team.mate do
			local mate = playerattr_team.mate[i]
			if mate.playerid == msg.actorid then
				mate.online = 1
				sidebar_updateteam()
				break
			end
		end
	end
	if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            local mate = playerattr_raid.mate[i]
            if mate.playerid == msg.actorid then
				mate.online = 1
				sidebar_updateteam()
				break
			end
        end
	end
end

function SC_PlayerOffline(msg)
	for i=1,#playerattr_pal do
		if playerattr_pal[i].playerid == msg.actorid then
			playerattr_pal[i].online = 0
			pallist_updateui()
			break
		end
	end
	if playerattr_icc ~= nil then
		for i=1,#playerattr_icc.member do
			if playerattr_icc.member[i].playerid == msg.actorid then
				playerattr_icc.member[i].disconnect = timer_gettimesecond()
				icc_updateui()
				break
			end
		end
	end
	if playerattr_team ~= nil then
		for i=1,#playerattr_team.mate do
			local mate = playerattr_team.mate[i]
			if mate.playerid == msg.actorid then
				mate.online = 0
				sidebar_updateteam()
				break
			end
		end
	end
	if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            local mate = playerattr_raid.mate[i]
            if mate.playerid == msg.actorid then
				mate.online = 0
				sidebar_updateteam()
				break
			end
        end
	end
end

function SC_Weather(msg)

end

function SC_Talk(msg)
	local actor = actormanager_getfromactorid(msg.actorid)
	if actor ~= nil and actor:nameplatevisible() then
		local text = c_textformat(msg.key)
		--actor:createchatbubble(msg.text)
		messagealert_addalert(text)
	end
end

function SC_Message(msg)
	if c_textkey(msg.key) then
		local text = c_textformat(msg.key)
		chat_addsystemalert(text)
	end
end

function SC_MessageRaw(msg)
	chat_addsystemalert(msg.text)
end

function SC_GMMessage(msg)
	messagealert_showgmmessage(msg.msg)
	local sender = c_textformat("CHAT_SENDER_SYSTEM")
	chat_addchat(0, sender, 0, nil, chatchanneltype.systemwarning, msg.msg, nil)
end

function SC_DebugMessage(msg)
	debugerror(msg.msg)
end

function SC_SetEntityArray(msg)
	for i=1,#msg.entityid do
		sceneentity_setstate(msg.entityid[i], msg.state[i], false)
	end
end

function SC_SetEntity(msg)
	sceneentity_setstate(msg.entityid, msg.state, true)
end

function SC_SetWindPath(msg)
	sceneentity_setwindpath(msg.id, msg.mesh, msg.visible)
end
