include("actor/morph")
include("actor/actor")
include("actor/actorrender")
include("actor/actorsubrender")
include("actor/actorpet")
include("actor/actorvfx")
include("actor/actorgame")
include("actor/actormove")
include("actor/actormoveme")
include("actor/actormoveplayer")
include("actor/actormovenpc")
include("actor/actormovesync")
include("actor/actornameplate")
include("actor/actorrelation")
include("actor/actoraction")
include("actor/aliasmanager")
include("actor/entitymanager")

actorautoselect =
{
	enemynpc = 0x1,
	enemyplayer = 0x2,
 	sipidnpc = 0x4,
    sipidplayer = 0x8,
	enemynpcdead = 0x10,
	sipidplayerdead = 0x20,
	harvest = 0x40,
}

local m_actorlist = {}
local m_actordisappearlist = {}
local m_actorentity = {}
local m_attackmeactorid = 0
local m_attackmetime = 0
local m_autoselectdist = -1
local m_autoselectdisttime = 0

m_me = nil
m_selectactorid = 0
m_selectactor = nil
m_mepetid = 0

function actormanager_createactor(renderlayer, actorid)
	local actor = _actorclass.new()
	actor.actorid = actorid
	actor:initactor(renderlayer)
	for logo, logoactorid in pairs(playerattr_logo) do
		if logoactorid == actorid then
			actor.actordata.logo = logo
		end
	end
	m_actorlist[actorid] = actor
	return actor
end

function actormanager_reload()
	if m_me ~= nil then
		m_me:setposition(playerattr_info.posx, playerattr_info.posy, playerattr_info.posz)
	end
	for i=#m_actordisappearlist, 1, -1 do
		local actor = m_actordisappearlist[i]
		actormanager_destroy(actor)
		m_actorlist[actor.actorid] = nil
		table.remove(m_actordisappearlist, i)
	end
	for key, actor in pairs(m_actorlist) do
		actor:setreloadasset(false)
		actor:unloadpetasset()
		actor:clearanimmesh()
		actor:destroysubactor()
		actor:destroyadditive()
		actor:destroyallplate()
		actor:createplayeractor()
		actor:updateasset()
		actionmanager_reload(actor)
	end
end

function actormanager_clearentity()
	m_actorentity = {}
end

function actormanager_ispet(scriptid)
	return scriptid == m_mepetid
end

function actormanager_addentity(entityid, actorid)
	m_actorentity[entityid] = actorid
end

function actormanager_removeentity(entityid)
	m_actorentity[entityid] = nil
end

function actormanager_getentityactorid(entityid)
	return m_actorentity[entityid]
end

function actormanager_getactorlist()
	return m_actorlist
end

function actormanager_getfromactorid(actorid)
	return m_actorlist[actorid]
end

function actormanager_getfromscriptid(scriptid)
	for key, actor in pairs(m_actorlist) do
		if actor.id == scriptid then
			return actor
		end
	end
end

function actormanager_getactoridfromscriptid(scriptid)
	for key, actor in pairs(m_actorlist) do
		if actor.id == scriptid then
			return actor.actorid
		end
	end
end

function actormanager_destroy(actor)
	actor:destroyactor()
	actor:destroyallplate()
	if actor.actorid == m_selectactorid then
		m_selectactorid = 0
		m_selectactor = nil
	end
	if actor.actorid == playerattr_info.spiritid then
		playerattr_info.spiritid = 0
		sidebar_updateteam()
	end
end

function actormanager_destroyfromactorid(actorid)
	local actor = actormanager_getfromactorid(actorid)
	if actor ~= nil then
		m_actorlist[actorid] = nil
		actormanager_destroy(actor)
	end
end

function actormanager_clear()
	for key, value in pairs(m_actorlist) do
		actormanager_destroy(value)
	end
	m_actorlist = {}
	m_me = nil
	m_selectactor = nil
	m_selectactorid = 0
end

function actormanager_disappear(actor, timewait)
	actor.actordata.timedisappear = time_game + timewait
	m_actordisappearlist[#m_actordisappearlist + 1] = actor
end

function actormanager_update()
	if m_me ~= nil then
		m_me:updateanim()
		m_me:updatepet()
		m_me:updatevfx()
		m_me:updateattr()
		m_me:updateasset()
		m_me:updatebuff()
		m_me:moveupdatevelocity()
		playerbattle_update()
		actionmanager_update(m_me)
		m_me:updatesubanim()
		m_me:movemegravity()
		m_me:movesendsync(false)
		playerpetattr_updatedop()
		maincamera_lookat(m_me.transform.px, m_me.transform.py + m_me.actordata.cameraheight * m_me:getscale(), m_me.transform.pz, false)
	end
	for key, actor in pairs(m_actorlist) do
		if not actor:isme() then
			actor:updateanim()
			actor:moveupdatevelocity()
			if actor:isplayer() then
				actor:updatepet()
				actor:moveplayerupdate()
			elseif actor:isdynamicnpc() then
				actor:movenpcmove()
			end
			actor:updatevfx()
			actor:updateattr()
			actor:updateasset()
			actor:updatebuff()
			actionmanager_update(actor)
			actor:updatesubanim()
		end
	end
	for i=#m_actordisappearlist, 1, -1 do
		local actor = m_actordisappearlist[i]
		if not actor:updatdisappear() then
			actormanager_destroy(actor)
			m_actorlist[actor.actorid] = nil
			table.remove(m_actordisappearlist, i)
		end
	end

	if playerattr_info ~= nil and playerattr_info.qsktime > time_game then
		local time = playerattr_info.qsktime - time_game
		if time < 1800 and time + time_frame > 1800 then
			chat_addsystemalert(c_textformat("NPC_QSK_QSKTIME", timerdesc_getafter(1800)))
		end
		if time < 300 and time + time_frame > 300 then
			chat_addsystemalert(c_textformat("NPC_QSK_QSKTIME", timerdesc_getafter(300)))
		end
		if time < 60 and time + time_frame > 60 then
			chat_addsystemalert(c_textformat("NPC_QSK_QSKTIME", timerdesc_getafter(60)))
		end
	end
end

function actormanager_removedisappearentity(staticid)
	for i=#m_actordisappearlist, 1, -1 do
		local actor = m_actordisappearlist[i]
		if actor:isstaticnpc() and actor.config_npcstatic.staticid == staticid then
			actormanager_destroy(actor)
			m_actorlist[actor.actorid] = nil
			table.remove(m_actordisappearlist, i)
			break
		end
	end
end

function actormanager_setattackme(actor)
	if not actor:isme() then
		if m_selectactorid == 0 then
			actormanager_selectactor(actor)
		elseif actor:isplayer() then
			m_attackmeactorid = actor.actorid
			m_attackmetime = time_game
		end
	end
end

function actormanager_selectactorid(actorid)
	local actor = actormanager_getfromactorid(actorid)
	if actor ~= nil then
		actormanager_selectactor(actor)
	end
end

function actormanager_selectactor(actor)
	if actor ~= nil then
		if actor.timeselectable == nil then
			if m_selectactorid ~= actor.actorid then
				m_selectactorid = actor.actorid
				if m_selectactor ~= nil then
					m_selectactor:updatenameuilayout()
				end
				actor:updatenameuilayout()
				local msg = {messageid="CS_ActorSelect"}
				msg.actorid = actor.actorid
				c_send(msg)
			end
			m_selectactor = actor
		end
	else
		if m_selectactorid ~= 0 then
			m_selectactorid = 0
			if m_selectactor ~= nil then
				m_selectactor:updatenameuilayout()
			end
			local msg = {messageid="CS_ActorSelect"}
			msg.actorid = 0
			c_send(msg)
		end
		m_selectactor = nil
	end
end

function actormanager_sortselectactor(p1, p2)
	local p1_selected = p1.attr.selection == playerattr_info.actorid
    local p2_selected = p2.attr.selection == playerattr_info.actorid
    if p1_selected ~= p2_selected then
        return p1_selected
    end
    return p1.sortdist < p2.sortdist
end
function actormanager_autoselectactor(flag)
	if m_me == nil then
		return
	end
	local px = m_me.transform.px
	local py = m_me.transform.py
	local pz = m_me.transform.pz
	local selectactor = nil
	if m_attackmeactorid ~= 0 and time_game - m_attackmetime < 3.0 then
		selectactor = actormanager_getfromactorid(m_attackmeactorid)
		m_attackmeactorid = 0
	end
	if selectactor == nil then
		local sortactor = {}
		local sortactordistmaxsq = 35 * 35
		local screenwidth, screenheight = c_system_screensize()
		for key, actor in pairs(m_actorlist) do
			if actor:autoselectable(flag) then
				local sortdist = vector3_distance_sq(px, py, pz, actor.transform.px, actor.transform.py, actor.transform.pz)
				if sortdist < sortactordistmaxsq then
					local screenx, screeny, screenz = c_scene_worldtoscreen(actor.transform.px, actor.transform.py, actor.transform.pz)
					if screenx > 0 and screenx < screenwidth and screeny > 0 and screeny < screenheight and screenz > 0 then
						actor.sortdist = sortdist
						sortactor[#sortactor + 1] = actor
					end
				end
			end
		end
		if #sortactor > 0 then
			if m_selectactor == nil or time_game - m_autoselectdisttime > 3 then
				m_autoselectdist = -1
			end
			m_autoselectdisttime = time_game
			table.sort(sortactor, actormanager_sortselectactor)
			for i=1,#sortactor do
				local actor = sortactor[i]
				if actor.sortdist > m_autoselectdist then
					m_autoselectdist = actor.sortdist
					selectactor = actor
					break
				end
				if i > 4 then
					break
				end
			end
			if selectactor == nil then
				selectactor = sortactor[1]
				m_autoselectdist = sortactor[1].sortdist
			end
		end
	end
	if selectactor ~= nil then
		actormanager_selectactor(selectactor)
	end
end

function actormanager_picksubactor()
	if m_selectactor ~= nil and m_selectactor.attr.selection ~= nil then
		local actor = actormanager_getfromactorid(m_selectactor.attr.selection)
		if actor ~= nil then
			actormanager_selectactor(actor)
		end
	end
end

local function actormanager_pickcompare(current, pick)
	if current == nil then
		return true
	end
	if current.maxx >= pick.minx and current.minx <= pick.maxx and current.maxy >= pick.miny
		and current.miny <= pick.maxy and current.maxz >= pick.minz and current.minz <= pick.maxz then
		return current.distcenter > pick.distcenter
	end
	return current.distview > pick.distview
end
function actormanager_getfocusactor(mousex, mousey)
	local sx,sy,sz,ex,ey,ez = c_input_screenray(mousex, mousey)
	local focusarray = c_actor_pickray(maskpickactor, sx,sy,sz,ex,ey,ez)
	if #focusarray == 0 then
		return nil
	end
	local visibledist = 0
	for i=1,#focusarray do
		local actor = focusarray[i]
		if actor.scriptid == 0 and actor.entityid == 0 then
			local blockray = true
			if actor.material ~= 0 then
				local config_physicmaterial = c_config_getmetaid(configid.render_physicmaterial, actor.material)
				if config_physicmaterial ~= nil and config_physicmaterial.blockray == 0 then
					blockray = false
				end
			end
			if blockray then
				local dist = vector3_distance(actor.px, actor.py, actor.pz, sx, sy, sz)
				if visibledist == 0 or visibledist > dist then
					visibledist = dist
				end
			end
		end
	end
	local pickactor = nil
	local pickpet = nil
	local pickentity = nil
	for i=1,#focusarray do
		local actor = focusarray[i]
		if (actor.scriptid ~= 0 or actor.entityid ~= 0) then
			actor.distcenter = vector3_distance(actor.cx, actor.cy, actor.cz, actor.px, actor.py, actor.pz)
			actor.distview = vector3_distance(actor.px, actor.py, actor.pz, sx, sy, sz)
			if visibledist == 0 or actor.distview <= visibledist then
				if actor.scriptid ~= 0 then
					if actormanager_ispet(actor.scriptid) then
						pickpet = actor
					elseif actormanager_pickcompare(pickactor, actor) then
						pickactor = actor
					end
				else
					if actormanager_getentityactorid(actor.entityid) ~= nil or npc_staticclickable(actor.entityid) then
						if actormanager_pickcompare(pickentity, actor) then
							pickentity = actor
						end
					end		
				end
			end
		end
	end
	if pickactor ~= nil and pickentity ~= nil then
		if pickactor.distview - 2.0 < pickentity.distview  then
			return pickactor
		else
			return pickentity
		end
	elseif pickactor ~= nil then
		return pickactor
	elseif pickpet ~= nil then
		return pickpet
	else
		return pickentity
	end
end

function actormanager_updatehead()
	if not scene_isloading() then
		for key, actor in pairs(m_actorlist) do
			if actor:isnpc() then
				actor:updatequestvfx()
				actor:updateicon()
				actor:updatenameuilayout()
			end
		end	
	end
end

function actormanager_updatenameplate()
	for key, actor in pairs(m_actorlist) do
		actor:updatenameuilayout()
	end
end

function actormanager_updatenameplatevisible()
	for key, actor in pairs(m_actorlist) do
		if actor:nameplateisvisible() then
			if not actor:nameplatevisible() then
				actor:destroynameplate()
			end
		else
			if actor:nameplatevisible() then
				actor:createnameplate()
			end
		end
	end
end

function actormanager_updateharvesticon()
	for key, actor in pairs(m_actorlist) do
		if actor:isharvest() then
			actor:updateharvesticon()
		end
	end
end
