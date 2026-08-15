
include("sidebar/teammate")
include("sidebar/raidmate")
include("sidebar/questtrace")

sidebartab = 
{
    none = 0,
    quest = 1,
    team = 2,
}

m_uisidebar_main = uipanel_createhandle("sidebar/sidebar_main", uilayer.bottom, 0)

function sidebar_main_onopen()
	local button_quest = m_uisidebar_main:getwidget("button_quest")
	button_quest:settext("SIDEBAR_QUEST")
	button_quest:setdelegate(sidebar_main_delegate_quest)

	local button_team = m_uisidebar_main:getwidget("button_team")
	button_team:settext("SIDEBAR_TEAM")
	button_team:setdelegate(sidebar_main_delegate_team)

	local list_mate = m_uisidebar_main:getwidget("tab_team/list_mate")
    list_mate:init(uilistflag.vertical)
    m_uisidebar_main.list_mate = list_mate

	questtrace_onopen()

	event_register(eventtype.update2, sidebar_main_update2, m_uisidebar_main)
end

function sidebar_main_update2()
	if m_uisidebar_main.tab == sidebartab.team then
		if playerattr_raid ~= nil then
			raid_mate_updatevalue()
		else
			team_mate_updatevalue()
		end
	end
end

function sidebar_main_updatebuttoncolor()
	local button_quest = m_uisidebar_main:getwidget("button_quest")
	if m_uisidebar_main.tab == sidebartab.quest then
		button_quest:settexthexcolor(0x6bff00ff)
	else
		button_quest:settexthexcolor(0xededddff)
	end

	local button_team = m_uisidebar_main:getwidget("button_team")
	if m_uisidebar_main.tab == sidebartab.team then
		button_team:settexthexcolor(0x6bff00ff)
	else
		button_team:settexthexcolor(0xededddff)
	end
end

function sidebar_main_delegate_quest()
	if m_uisidebar_main.tab ~= sidebartab.quest then
		sidebar_openquest()
	else
		sidebar_opennone()
	end
end

function sidebar_main_delegate_team()
	if m_uisidebar_main.tab ~= sidebartab.team then
		sidebar_openteam()
	else
		sidebar_opennone()
	end
end

function sidebar_open()
	m_uisidebar_main:open()
	sidebar_openquest()
end

function sidebar_opennone()
	m_uisidebar_main.tab = sidebartab.none
	questtrace_close()
	team_mate_close()
	raid_mate_close()
	sidebar_main_updatebuttoncolor()
end

function sidebar_openteam()
	if m_uisidebar_main:alive() then
		m_uisidebar_main.tab = sidebartab.team
		if playerattr_raid ~= nil then
			raid_mate_open()
			raid_mate_updateui()
		else
			team_mate_open()
			team_mate_updateui()
		end
		questtrace_close()
		sidebar_main_updatebuttoncolor()
	end
end

function sidebar_updateteam()
	if m_uisidebar_main:alive() and m_uisidebar_main.tab == sidebartab.team then
		if playerattr_raid ~= nil then
			raid_mate_updateui()
		else
			team_mate_updateui()
		end
	end
	raid_main_updateui()
end

function sidebar_openquest()
	if m_uisidebar_main:alive() then
		m_uisidebar_main.tab = sidebartab.quest
		questtrace_open()
		questtrace_updateui()
		team_mate_close()
		raid_mate_close()
		sidebar_main_updatebuttoncolor()
	end
end

function sidebar_updatequest()
	if m_uisidebar_main:alive() and m_uisidebar_main.tab == sidebartab.quest then
		questtrace_updateui()
	end
end

function sidebar_activequest(questid)
	if m_uisidebar_main:alive() then
		questtrace_open()
		questtrace_activequestid(questid)
		team_mate_close()
		raid_mate_close()
		sidebar_main_updatebuttoncolor()
	end
end
