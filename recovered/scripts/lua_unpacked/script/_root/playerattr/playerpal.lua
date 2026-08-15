
playerattr_mail = nil
playerattr_survey = nil
playerattr_pal = nil
playerattr_black = nil
playerattr_icc = nil
playerattr_team = nil
playerattr_teamselect = 0
playerattr_raid = nil
playerattr_referrallist = nil
playerattr_referralplayername = nil

function playerpal_clear()
    playerattr_mail = {}
    playerattr_survey = nil
    playerattr_pal = {}
    playerattr_black = {}
    playerattr_icc = nil
    playerattr_team = nil
    playerattr_teamselect = 0
    playerattr_raid = nil
    playerattr_referrallist = {}
    playerattr_referralplayername = nil
end

function playerpal_getmatefromplayerid(playerid)
    if playerattr_team ~= nil then
        for i=1,#playerattr_team.mate do
            if playerattr_team.mate[i].playerid == playerid then
                return playerattr_team.mate[i]
            end
        end
    end
end

function playerpal_getraidmatefromplayerid(playerid)
    if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            if playerattr_raid.mate[i].playerid == playerid then
                return playerattr_raid.mate[i]
            end
        end
    end
end

function playerpal_getraidmatefromindex(index)
    if playerattr_raid ~= nil then
        for i=1,#playerattr_raid.mate do
            if playerattr_raid.mate[i].index == index - 1 then
                return playerattr_raid.mate[i]
            end
        end
    end
end

function playerpal_inblacklist(playerid)
    if playerattr_black ~= nil then
        for i=1,#playerattr_black do
            if playerattr_black[i].playerid == playerid then
                return true
            end
        end
    end
    return false
end
