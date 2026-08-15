
include("config/csvconfig")
include("ext/ext")

include("input/input")

include("main/gameserver")
include("main/command")
include("main/overlay")
include("main/event")
include("main/scene")
include("main/sceneentity")
include("main/ping")
include("main/loading")
include("main/loadingblack")
include("main/downloading")
include("main/http")

include("message/message_aoi")
include("message/message_abyss")
include("message/message_dungeon")
include("message/message_attr")
include("message/message_chat")
include("message/message_login")
include("message/message_player")
include("message/message_pvp")
include("message/message_motion")
include("message/message_item")
include("message/message_equip")
include("message/message_mail")
include("message/message_match")
include("message/message_skill")
include("message/message_skillpreset")
include("message/message_social")
include("message/message_inst")
include("message/message_title")
include("message/message_pet")
include("message/message_costume")
include("message/message_spirit")
include("message/message_npc")
include("message/message_quest")
include("message/message_crafting")
include("message/message_shop")
include("message/message_deal")
include("message/message_icc")
include("message/message_pal")
include("message/message_team")
include("message/message_raid")

include("ui/dead")
include("ui/messagebox")
include("ui/messagealert")
include("ui/dictview")
include("ui/inputline")
include("ui/inputcount")
include("ui/sellinput")
include("ui/cgmask")
include("ui/cgvideo")
include("ui/colorpicker")
include("ui/tutorial")
include("ui/tutorialtips")
include("ui/hideui")

include("module/module")
include("playerattr/playerattr")
include("playerattr/serverattr")
include("actor/actormanager")
include("action/actionmanager")
include("tips/tips")
include("popup/popup")
include("prompt/prompt")
include("home/homemain")
include("skill/skillmain")
include("bag/bag")
include("costume/costume")
include("equiplab/equiplab")
include("pet/pet")
include("map/mapmain")
include("dungeon/dungeon")
include("overview/playermain")
include("chat/chat")
include("npc/npc")
include("rank/rank")
include("setting/setting")
include("mail/mail")
include("quest/quest")
include("shop/shop")
include("store/store")
include("business/businessmain")
include("crafting/crafting")
include("icc/icc")
include("pal/palmain")
include("team/team")
include("sidebar/sidebar")
include("appearance/appearance")
include("login/login")
include("gamemaster/gamemaster")

time_game = 0
time_frame = 0
time_framecount = 0
game_focus = true

--function\s+\w+\s*\([^)]*\)\s*\n*\s*end

function initialize()
    math.randomseed(c_time_datesecond())
    system_init()
    time_game = 0.016
    time_frame = 0.016
    uimanager_setdragthreshold(10)
    gamesetting_loadlocal()
    actionmanager_init()
    --timer_performancereset(false)
    csvconfig_load()
    --timer_performancereset(true)
    battletext_init()
    audiomanager_init()
    systemskill_init()
    input_init()
    inputkey_init()
    login_create()
end

function clearall()
    playerattr_clear()
    playeritem_clear()
    playerskill_clear()
    playerpal_clear()
    playerquest_clear()
    playerapproach_clear()
    serverattr_clear()

    actormanager_clear()
    vfxmanager_clear()
    uimanager_clear()
    home_main_clear()
    sceneentity_reset()
    c_camera_setposteffect(nil)
end

function update(time, flag)
    time_frame = time - time_game
    time_game = time
    time_framecount = time_framecount + 1
    
    system_update()
    timer_update()
    updategameflag(flag)

    ping_update()
    gameserver_update()
    maincamera_update()
    input_update()
    event_active(eventtype.update)

    actormanager_update()
    entitymanager_update()
    scene_update()
    selection_update()
    skillqte_update()
    vfxmanager_update()
    audiomanager_update()
    overlay_update()
    input_reset()
    event_active(eventtype.update2)
end

function lateupdate()
    audiomanager_updatelistener()
end

function unity_actorelevator(scriptid, x, y, z)
    local actor = actormanager_getfromscriptid(scriptid)
    if actor ~= nil then
        if actor.petactor ~= nil then
            local offsetx = x - actor.transform.px
            local offsety = y - actor.transform.py
            local offsetz = z - actor.transform.pz
            local pt = actor.petactor.transform
            actor.petactor:setposition(pt.px + offsetx, pt.py + offsety, pt.pz + offsetz)
        end
        actor.attr.posx = x
        actor.attr.posy = y
        actor.attr.posz = z
        actor.transform.px = x
        actor.transform.py = y
        actor.transform.pz = z
        if actor:isme() then
            maincamera_lookat(x, y + m_me.actordata.cameraheight * m_me:getscale(), z, true)
        end
    end
end

function unity_entitycreate(entityid, flag, meshfile, px, py, pz, rx, ry, rz, sx, sy, sz)
    entitymanager_create(entityid, flag,  meshfile, px, py, pz, rx, ry, rz, sx, sy, sz)
end

function unity_entitydestroy(entityid)
    entitymanager_destroy(entityid)
end

function unity_screenresize(width, height)
end

function unity_timelineevent(actorid, str)
    cgmask_event(actorid, str)
end

function unity_sdkmessage(str)
    debugerror(str)
end

function updategameflag(flag)
    local focus = flag > 0
    if game_focus ~= focus then
        game_focus = focus
        inputdevice_keyclear()
    end
    if focus and m_me ~= nil then
        if m_me.actordata.sequencetimestart ~= nil and not m_me.actordata.sequencecg then
            c_actor_flightadjust(m_me.id, time_game - m_me.actordata.sequencetimestart)
        end
    end
end

function errorhandle(msg)
    debugerror(msg)
end
