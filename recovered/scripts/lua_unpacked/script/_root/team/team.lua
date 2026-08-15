
include("team/teamadvert")
include("team/teamrecruit")
include("team/teamrequest")
include("team/teamsummon")
include("team/teamsetpickitem")
include("team/teamranditem")
include("team/raidmain")


teampickitem =
{
    round = 0,
    free = 1,
}
team_raid_groupcount = 6
team_raid_groupmate = 6
team_raid_maxmate = 36

m_uiteam_recruit = uipanel_createhandle("team/team_recruit", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function teamrequest_updateteam()
	teamrequest_updateui()
end

function teamraid_getgroup(index)
    return math.tointegerfloor((index - 1) / team_raid_groupmate) + 1
end