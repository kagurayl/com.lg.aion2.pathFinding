
local m_uiarena_scorelist = uipanel_createhandle("dungeon/arena_scorelist", uilayer.top, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)
local m_uidredgion_inst = {inst = "dungeon/inst_arenascore"}

function arena_scorelist_onopen()
    local button_close = m_uiarena_scorelist:getwidget("button_close")
    button_close:setdelegate(arena_scorelist_delegate_close)

    local list_score = m_uiarena_scorelist:getwidget("list_score")
    list_score:init(uilistflag.vertical)

    local win = false
    for i=1,#m_uiarena_scorelist.scorelist do
        local score = m_uiarena_scorelist.scorelist[i]
        local line = list_score:add(m_uidredgion_inst.inst, i, i)

        local text_rank = line:getwidget("text_rank")
        text_rank:settext(i)

        local image_career = line:getwidget("image_career")
        image_career:seticon(playercareericon[score.career])

        local text_name = line:getwidget("text_name")
        text_name:settext(score.name)

        local text_killplayer = line:getwidget("text_killplayer")
        text_killplayer:settext(score.killplayer)

        local text_pvpscore = line:getwidget("text_pvpscore")
        text_pvpscore:settext(score.pvpscore)
        
        local text_timescore = line:getwidget("text_timescore")
        text_timescore:settext(score.timescore)

        local text_rankscore = line:getwidget("text_rankscore")
        text_rankscore:settext(score.rankscore)

        local text_totalscore = line:getwidget("text_totalscore")
        text_totalscore:settext(score.pvpscore + score.timescore + score.rankscore)

        if score.actorid == playerattr_info.actorid then
            if i == 1 then
                win = true
            end
            local text_playerrank = m_uiarena_scorelist:getwidget("text_playerrank")
            text_playerrank:settext(i)

            local text_playerpoint = m_uiarena_scorelist:getwidget("text_playerpoint")
            text_playerpoint:settext(score.pvpscore + score.timescore + score.rankscore)

            local text_playerobs = m_uiarena_scorelist:getwidget("text_playerobs")
            text_playerobs:setvisible(score.obs > 0)
            if score.obs > 0 then
                text_playerobs:settext(score.obs)
            end

            local text_playeritemname1 = m_uiarena_scorelist:getwidget("text_playeritemname1")
            local text_playeritemcount1 = m_uiarena_scorelist:getwidget("text_playeritemcount1")
            local config_item = csvitem_getfromid(score.itemid1)
            text_playeritemname1:setvisible(config_item ~= nil)
            text_playeritemcount1:setvisible(config_item ~= nil)
            if config_item ~= nil then
                text_playeritemname1:settext(config_item.name)
                text_playeritemcount1:settext(score.itemcount1)
            end

            local text_playeritemname2 = m_uiarena_scorelist:getwidget("text_playeritemname2")
            local text_playeritemcount2 = m_uiarena_scorelist:getwidget("text_playeritemcount2")
            config_item = csvitem_getfromid(score.itemid2)
            text_playeritemname2:setvisible(config_item ~= nil)
            text_playeritemcount2:setvisible(config_item ~= nil)
            if config_item ~= nil then
                text_playeritemname2:settext(config_item.name)
                text_playeritemcount2:settext(score.itemcount2)
            end
        end
    end

    local image_bgwin = m_uiarena_scorelist:getwidget("image_bgwin")
    local image_bglose = m_uiarena_scorelist:getwidget("image_bglose")
    image_bgwin:setvisible(win)
    image_bglose:setvisible(not win)
    if m_uiarena_scorelist.finish then
        if win then
            audiomanager_playaudioui(DungeonArenaClear)
        else
            audiomanager_playaudioui(DungeonArenaEnd)
        end
        button_close:settext("UI_LEAVE")
    end
end

function arena_scorelist_open()
    if not m_uiarena_scorelist.finish then
        table.sort(m_uiarena_scorelist.scorelist, function(p1, p2) return (p1.pvpscore < p1.pvpscore) end)
    end
    m_uiarena_scorelist:open()
end

function arena_scorelist_getscore()
    for i=1,#m_uiarena_scorelist.scorelist do
        local score = m_uiarena_scorelist.scorelist[i]
        if score.actorid == playerattr_info.actorid then
            return score.pvpscore
        end
    end
    return 0
end

function arena_scorelist_checkrank()
    local prevrank = 1
    for i=1,#m_uiarena_scorelist.scorelist do
        local score = m_uiarena_scorelist.scorelist[i]
        if score.actorid == playerattr_info.actorid then
            prevrank = i
            break
        end
    end
    table.sort(m_uiarena_scorelist.scorelist, function(p1, p2) return (p1.pvpscore > p2.pvpscore) end)
    for i=1,#m_uiarena_scorelist.scorelist do
        local score = m_uiarena_scorelist.scorelist[i]
        if score.actorid == playerattr_info.actorid then
            if prevrank ~= i then
                if i <= 3 and prevrank > i then

                end
            end
            break
        end
    end
end

function arena_scorelist_finish()
    table.sort(m_uiarena_scorelist.scorelist, function(p1, p2) return (p1.rank < p2.rank) end)
    m_uiarena_scorelist.finish = true
    m_uiarena_scorelist:open()
end

function arena_scorelist_addplayer(msg)
    if msg.actorid == playerattr_info.actorid then
        m_uiarena_scorelist.scorelist = {}
        m_uiarena_scorelist.finish = false
    end
    local player = {}
    player.name = msg.name
    player.actorid = msg.actorid
    player.career = msg.career
    player.killplayer = msg.killplayer
    player.pvpscore = msg.score
    player.timescore = 0
    player.rankscore = 0
    player.obs = 0
    player.itemid1 = 0
    player.itemid2 = 0
    player.itemcount1 = 0
    player.itemcount2 = 0
    m_uiarena_scorelist.scorelist[#m_uiarena_scorelist.scorelist + 1] = player
end

function arena_scorelist_removeplayer(actorid)
    for i=1,#m_uiarena_scorelist.scorelist do
        if m_uiarena_scorelist.scorelist[i].actorid == actorid then
            table.remove(m_uiarena_scorelist.scorelist, i)
            break
        end
    end
end

function arena_scorelist_getplayer(actorid)
    for i=1,#m_uiarena_scorelist.scorelist do
        if m_uiarena_scorelist.scorelist[i].actorid == actorid then
            return m_uiarena_scorelist.scorelist[i]
        end
    end
end

function arena_scorelist_delegate_close()
    m_uiarena_scorelist:close()
    if m_uiarena_scorelist.finish then
        local msg = {messageid="CS_DungeonLeave"}
        c_send(msg)
    end
end
