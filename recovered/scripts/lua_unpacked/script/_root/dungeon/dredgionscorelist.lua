
local m_uidredgion_scorelist = uipanel_createhandle("dungeon/dredgion_scorelist", uilayer.top, uiflag.placeall, AudioOpenUI, AudioCloseUI)
local m_uidredgion_inst = {inst = "dungeon/inst_dredgionscore"}

function dredgion_scorelist_onopen()
    local button_close = m_uidredgion_scorelist:getwidget("button_close")
    button_close:setdelegate(dungeon_scorelist_delegate_close)

    local list_score = m_uidredgion_scorelist:getwidget("list_score")
    list_score:init(uilistflag.vertical)

    local teamciv = playerciv.light
    for i=1,#m_uidredgion_scorelist.scorelist do
        local score = m_uidredgion_scorelist.scorelist[i]
        local color = math.ternary(score.civoverride == playerciv.light, 0x6bff00ff, 0x4fb2feff)
        local line = list_score:add(m_uidredgion_inst.inst, i, i)

        local image_career = line:getwidget("image_career")
        image_career:seticon(playercareericon[score.career])

        local text_name = line:getwidget("text_name")
        text_name:settext(score.name)
        text_name:sethexcolor(color)

        local text_pvptitle = line:getwidget("text_pvptitle")
        text_pvptitle:settext(c_textformat("PLAYER_PVPLEVEL_LIGHT" .. score.pvptitle))
        text_pvptitle:sethexcolor(color)

        local text_killplayer = line:getwidget("text_killplayer")
        text_killplayer:settext(score.killplayer)

        local text_killnpc = line:getwidget("text_killnpc")
        text_killnpc:settext(score.killnpc)
        
        local text_killbuilding = line:getwidget("text_killbuilding")
        text_killbuilding:settext(score.killbuilding)

        local text_score = line:getwidget("text_score")
        text_score:settext(score.score)

        local text_obs = line:getwidget("text_obs")
        text_obs:settext(score.obs + score.winobs)

        if score.actorid == playerattr_info.actorid then
            teamciv = score.civoverride
            local text_playerobs = m_uidredgion_scorelist:getwidget("text_playerobs")
            text_playerobs:settext(score.obs)

            local text_playerwinobs = m_uidredgion_scorelist:getwidget("text_playerwinobs")
            text_playerwinobs:settext(score.winobs)

            local text_playertotalobs = m_uidredgion_scorelist:getwidget("text_playertotalobs")
            text_playertotalobs:settext(score.obs + score.winobs)
        end
    end

    local image_bgcup = m_uidredgion_scorelist:getwidget("image_bgcup")
    local image_wincup = m_uidredgion_scorelist:getwidget("image_wincup")
    local image_winbgleft = m_uidredgion_scorelist:getwidget("image_winbgleft")
    local image_winbgright = m_uidredgion_scorelist:getwidget("image_winbgright")
    local text_civleft = m_uidredgion_scorelist:getwidget("text_civleft")
    local text_civright = m_uidredgion_scorelist:getwidget("text_civright")
    local text_scoreleft = m_uidredgion_scorelist:getwidget("text_scoreleft")
    local text_scoreright = m_uidredgion_scorelist:getwidget("text_scoreright")

    local finish = m_uidredgion_scorelist.winciv ~= nil
    image_bgcup:setvisible(not finish)
    image_wincup:setvisible(finish)
    if finish then
        local teamwin = m_uidredgion_scorelist.winciv == teamciv or m_uidredgion_scorelist.winciv == -1
        local enemywin = m_uidredgion_scorelist.winciv ~= teamciv
        image_winbgleft:setvisible(teamwin)
        image_winbgright:setvisible(enemywin)
        if teamwin then
            text_civleft:setfontsize(88)
        else
            text_civright:setfontsize(88)
        end
        if teamwin and enemywin then
            audiomanager_playaudioui(DungeonDredgionDraw)
        elseif teamwin then
            audiomanager_playaudioui(DungeonDredgionWin)
        else
            audiomanager_playaudioui(DungeonDredgionLose)
        end
    else
        image_winbgleft:setvisible(false)
        image_winbgright:setvisible(false)
    end

    if teamciv == playerciv.light then
        text_civleft:settext("UI_CIVNAME_ELF")
        text_civright:settext("UI_CIVNAME_DARK")
        text_scoreleft:settext(m_uidredgion_scorelist.scorelight)
        text_scoreright:settext(m_uidredgion_scorelist.scoredark)
    else
        text_civleft:settext("UI_CIVNAME_DARK")
        text_civright:settext("UI_CIVNAME_ELF")
        text_scoreleft:settext(m_uidredgion_scorelist.scoredark)
        text_scoreright:settext(m_uidredgion_scorelist.scorelight)
    end

    if finish then
        button_close:settext("UI_LEAVE")
    end
end

function dredgion_scorelist_open()
    m_uidredgion_scorelist:open()
end

function dredgion_scorelist_setscore(scorelight, scoredark)
    m_uidredgion_scorelist.scorelight = scorelight
    m_uidredgion_scorelist.scoredark = scoredark
    local teamciv = playerciv.light
    for i=1,#m_uidredgion_scorelist.scorelist do
        local score = m_uidredgion_scorelist.scorelist[i]
        if score.actorid == playerattr_info.actorid then
            teamciv = score.civoverride
            break
        end
    end
    if teamciv == playerciv.light then
        dungeon_score_settext(scorelight, 0xffffffff, scoredark, 0xff0000ff)
    else
        dungeon_score_settext(scoredark, 0xffffffff, scorelight, 0xff0000ff)
    end
end

function dredgion_scorelist_finish(winciv, scorelight, scoredark)
    m_uidredgion_scorelist.winciv = winciv
    m_uidredgion_scorelist.scorelight = scorelight
    m_uidredgion_scorelist.scoredark = scoredark
    m_uidredgion_scorelist:open()
end

function dredgion_scorelist_addplayer(msg)
    if msg.actorid == playerattr_info.actorid then
        m_uidredgion_scorelist.scorelist = {}
        m_uidredgion_scorelist.winciv = nil
        m_uidredgion_scorelist.scorelight = 0
        m_uidredgion_scorelist.scoredark = 0
    end
    local player = {}
    player.name = msg.name
    player.actorid = msg.actorid
    player.career = msg.career
    player.civoverride = msg.civ
    player.pvptitle = msg.pvptitle
    player.killplayer = msg.killplayer
    player.killnpc = msg.killnpc
    player.killbuilding = msg.killbuilding
    player.score = msg.score
    player.obs = 0
    player.winobs = 0
    m_uidredgion_scorelist.scorelist[#m_uidredgion_scorelist.scorelist + 1] = player
end

function dredgion_scorelist_removeplayer(actorid)
    for i=1,#m_uidredgion_scorelist.scorelist do
        if m_uidredgion_scorelist.scorelist[i].actorid == actorid then
            table.remove(m_uidredgion_scorelist.scorelist, i)
            break
        end
    end
end

function dredgion_scorelist_getplayer(actorid)
    for i=1,#m_uidredgion_scorelist.scorelist do
        if m_uidredgion_scorelist.scorelist[i].actorid == actorid then
            return m_uidredgion_scorelist.scorelist[i]
        end
    end
end

function dungeon_scorelist_delegate_close()
    m_uidredgion_scorelist:close()
    if m_uidredgion_scorelist.winciv ~= nil then
        local msg = {messageid="CS_DungeonLeave"}
        c_send(msg)
    end
end
