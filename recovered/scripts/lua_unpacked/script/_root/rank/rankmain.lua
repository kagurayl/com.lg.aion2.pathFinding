
local ranktab =
{
    desc = 1,
	light = 2,
    dark = 3,
	lighticc = 4,
	darkicc = 5,
}

local m_rank_inst = {desc = "rank/inst_desc", player = "rank/inst_player", icc = "rank/inst_icc"}
local m_uirank_ranktab = ranktab.desc
local m_uirank_data_lightplayer = nil
local m_uirank_data_darkplayer = nil
local m_uirank_data_lighticc = nil
local m_uirank_data_darkicc = nil
m_uirank_main = uipanel_createhandle("rank/rank_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeall), AudioOpenUI, AudioCloseUI)

function rank_setplayerdata(msg)
    if msg.civ == playerciv.light then
        m_uirank_data_lightplayer = msg.player
    else
        m_uirank_data_darkplayer = msg.player
    end
end

function rank_seticcdata(msg)
    if msg.civ == playerciv.light then
        m_uirank_data_lighticc = msg.icc
    else
        m_uirank_data_darkicc = msg.icc
    end
end

function rank_openplayerrank()
	if m_uirank_main:null() then
		m_uirank_main:open()
	else
		if playerattr_info.civ == playerciv.light then
			m_uirank_ranktab = ranktab.light
		else
			m_uirank_ranktab = ranktab.dark
		end
		rank_main_updateui()
	end
end

local function rank_setdesc()
    local list_desc = m_uirank_main:getwidget("tab_desc/list_desc")
    list_desc:savestate()
    list_desc:clear()
    local config_pvpscore = c_config_getmetaall(configid.player_pvpscore)
    for i=#config_pvpscore, 1, -1 do
        local config_score = config_pvpscore[i]
        local line = list_desc:add(m_rank_inst.desc, i)

        local text_no = line:getwidget("text_no")
        if config_score.rank > 0 then
            text_no:settext(config_score.rank)
        else
            text_no:settext("-")
        end

        local text_score = line:getwidget("text_score")
        text_score:settext(config_score.require)

        local text_name = line:getwidget("text_name")
        if playerattr_info.civ == playerciv.light then
            text_name:settext("PLAYER_PVPLEVEL_LIGHT" .. i)
        else
            text_name:settext("PLAYER_PVPLEVEL_DARK" .. i)
        end
    end
    list_desc:restorestate()
end

local function rank_setplayer(rankdata)
    local list_player = m_uirank_main:getwidget("tab_player/list_player")
    list_player:savestate()
    list_player:clear()
    if rankdata == nil then
        return
    end
    for i=1, #rankdata do
        local linedata = rankdata[i]
        list_player:add(m_rank_inst.player, i, {data = rankdata, index = i})
    end
    list_player:restorestate()
end

function rank_delegate_setplayer(sender, line, data)
    local rankdata = data.data
    local linedata = rankdata[data.index]

    local text_no = line:getwidget("text_no")
    text_no:settext(data.index)

    local text_name = line:getwidget("text_name")
    text_name:settext(linedata.name)

    local text_icc = line:getwidget("text_icc")
    text_icc:settext(linedata.icc)

    local text_level = line:getwidget("text_level")
    text_level:settext(linedata.level)

    local text_career = line:getwidget("text_career")
    text_career:settext(playercareertext[linedata.career])

    local text_title = line:getwidget("text_title")
    local titlenameindex = math.max(1, linedata.scoretitle)
    if m_uirank_ranktab == ranktab.light then
        text_title:settext("PLAYER_PVPLEVEL_LIGHT" .. titlenameindex)
    else
        text_title:settext("PLAYER_PVPLEVEL_DARK" .. titlenameindex)
    end
    
    local text_score = line:getwidget("text_score")
    text_score:settext(linedata.score)

    local text_dod = line:getwidget("text_dod")
    text_dod:settext(linedata.dod)
end

local function rank_seticc(rankdata)
    local list_icc = m_uirank_main:getwidget("tab_icc/list_icc")
    list_icc:savestate()
    list_icc:clear()
    if rankdata == nil then
        return
    end
    for i=1, #rankdata do
        local linedata = rankdata[i]
        list_icc:add(m_rank_inst.icc, i, {data = rankdata, index = i})
    end
    list_icc:restorestate()
end

function rank_delegate_seticc(sender, line, data)
    local rankdata = data.data
    local linedata = rankdata[data.index]

    local text_no = line:getwidget("text_no")
    text_no:settext(data.index)

    local text_name = line:getwidget("text_name")
    text_name:settext(linedata.name)

    local text_member = line:getwidget("text_member")
    text_member:settext(linedata.member)
    
    local text_score = line:getwidget("text_score")
    text_score:settext(linedata.score)

    local text_dod = line:getwidget("text_dod")
    text_dod:settext(linedata.dod)
end

function rank_main_updateui()
    if m_uirank_main:null() then
        return
    end
    m_uirank_main:setwidgetvisible("tab_desc", m_uirank_ranktab == ranktab.desc)
    m_uirank_main:setwidgetvisible("tab_player", m_uirank_ranktab == ranktab.light or m_uirank_ranktab == ranktab.dark)
    m_uirank_main:setwidgetvisible("tab_icc", m_uirank_ranktab == ranktab.lighticc or m_uirank_ranktab == ranktab.darkicc)
    m_uirank_main:setwidgetenable("button_desc", m_uirank_ranktab ~= ranktab.desc)
    m_uirank_main:setwidgetenable("button_light", m_uirank_ranktab ~= ranktab.light)
    m_uirank_main:setwidgetenable("button_dark", m_uirank_ranktab ~= ranktab.dark)
    m_uirank_main:setwidgetenable("button_lighticc", m_uirank_ranktab ~= ranktab.lighticc)
    m_uirank_main:setwidgetenable("button_darkicc", m_uirank_ranktab ~= ranktab.darkicc)
    if m_uirank_ranktab == ranktab.desc then
        rank_setdesc()
    elseif m_uirank_ranktab == ranktab.light then
        rank_setplayer(m_uirank_data_lightplayer)
    elseif m_uirank_ranktab == ranktab.dark then
        rank_setplayer(m_uirank_data_darkplayer)
    elseif m_uirank_ranktab == ranktab.lighticc then
        rank_seticc(m_uirank_data_lighticc)
    elseif m_uirank_ranktab == ranktab.darkicc then
        rank_seticc(m_uirank_data_darkicc)
    end
end

function rank_main_onopen()
    m_uirank_main:setwidgetdelegate("button_desc", rank_main_delegate_desc)
    m_uirank_main:setwidgetdelegate("button_light", rank_main_delegate_light)
    m_uirank_main:setwidgetdelegate("button_dark", rank_main_delegate_dark)
    m_uirank_main:setwidgetdelegate("button_lighticc", rank_main_delegate_lighticc)
    m_uirank_main:setwidgetdelegate("button_darkicc", rank_main_delegate_darkicc)
    m_uirank_main:setwidgetdelegate("image_bg/button_close", rank_main_delegate_close)
    local list_desc = m_uirank_main:getwidget("tab_desc/list_desc")
    list_desc:init(uilistflag.vertical)

    local list_player = m_uirank_main:getwidget("tab_player/list_player")
    list_player:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_player:setasyncdelegate(rank_delegate_setplayer)

    local list_icc = m_uirank_main:getwidget("tab_icc/list_icc")
    list_icc:init(bit.bor(uilistflag.vertical, uilistflag.async))
    list_icc:setasyncdelegate(rank_delegate_seticc)

    if playerattr_info.civ == playerciv.light then
		m_uirank_ranktab = ranktab.light
	else
		m_uirank_ranktab = ranktab.dark
	end
    rank_main_updateui()
    local msg = {messageid="CS_Rank"}
	c_send(msg)
end

function rank_main_delegate_desc()
    m_uirank_ranktab = ranktab.desc
    rank_main_updateui()
end

function rank_main_delegate_light()
    m_uirank_ranktab = ranktab.light
    rank_main_updateui()
end

function rank_main_delegate_dark()
    m_uirank_ranktab = ranktab.dark
    rank_main_updateui()
end

function rank_main_delegate_lighticc()
    m_uirank_ranktab = ranktab.lighticc
    rank_main_updateui()
end

function rank_main_delegate_darkicc()
    m_uirank_ranktab = ranktab.darkicc
    rank_main_updateui()
end

function rank_main_delegate_close()
    m_uirank_main:close()
end
