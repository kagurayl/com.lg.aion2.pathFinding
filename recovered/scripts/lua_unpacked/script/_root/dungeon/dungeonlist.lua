
local m_dungeonlist_inst = {dungeon = "dungeon/inst_dungeon", mate = "dungeon/inst_mate"}
m_uidungeon = uipanel_createhandle("dungeon/dungeon_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)

function dungeon_main_onopen()
    m_uidungeon:setwidgetdelegate("image_bg/button_close", dungeon_main_delegate_close)
	local list_dungeon = m_uidungeon:getwidget("list_dungeon")
	list_dungeon:init(uilistflag.vertical)
    list_dungeon:setclickdelegate(dungeon_main_delegate_select)

    local list_mate = m_uidungeon:getwidget("list_mate")
    list_mate:init(uilistflag.vertical)

    m_uidungeon.selectdungeon = 0
	dungeonlist_updateui()
end

function dungeonlist_setteaminfo(msg)
    if m_uidungeon:null() then
        return
    end
    if m_uidungeon.selectdungeon ~= msg.id then
        return
    end
    local list_mate = m_uidungeon:getwidget("list_mate")
    list_mate:clear()
    for i=1,#msg.state do
        local state = msg.state[i]
        local mate = playerpal_getmatefromplayerid(state.playerid)
        if mate ~= nil then
            local line = list_mate:add(m_dungeonlist_inst.mate)

            local text_name = line:getwidget("text_name")
            text_name:settext(mate.name)

            local text_level = line:getwidget("text_level")
            text_level:settext(mate.level)

            local text_cd = line:getwidget("text_cd")
            if state.cd > 0 then
                text_cd:settext(timerdesc_getafter(state.cd))
            else
                text_cd:settext("")
            end
        end
    end
end

local function dungeonlist_add(list_dungeon, config_dungeon, cdinfo)
    local line = list_dungeon:add(m_dungeonlist_inst.dungeon, config_dungeon.id, config_dungeon)

    local text_name = line:getwidget("text_name")
    text_name:settext(config_dungeon.name)

    local text_count = line:getwidget("text_count")
    text_count:settext(config_dungeon.playercount)

    local text_level = line:getwidget("text_level")
    if playerattr_info.civ == playerciv.light then
        text_level:settext(config_dungeon.lightlevel)
    else
        text_level:settext(config_dungeon.darklevel)
    end

    local text_cd = line:getwidget("text_cd")
    if cdinfo ~= nil and cdinfo > time_game then
        text_cd:settext(timerdesc_getafter(cdinfo - time_game))
    else
        text_cd:settext("")
    end
end

function dungeonlist_updateui()
    if m_uidungeon:null() then
        return
    end

    local list_dungeon = m_uidungeon:getwidget("list_dungeon")
    list_dungeon:savestate()
    list_dungeon:clear()

    local dungeonarray = csvmapdungeon_getarray()
    for i=1,#dungeonarray do
        local config_dungeon = dungeonarray[i]
        local info = playerattr_dungeon[config_dungeon.id]
        if info ~= nil then
            dungeonlist_add(list_dungeon, config_dungeon, info)
        end
    end
    for i=1,#dungeonarray do
        local config_dungeon = dungeonarray[i]
        local info = playerattr_dungeon[config_dungeon.id]
        if info == nil then
            dungeonlist_add(list_dungeon, config_dungeon, info)
        end
    end

    list_dungeon:restorestate()
end

function dungeon_main_delegate_select(line, event, data)
    if m_uidungeon.selectdungeon ~= data.id then
        m_uidungeon.selectdungeon = data.id
        local list_mate = m_uidungeon:getwidget("list_mate")
        list_mate:clear()
        local msg = {messageid="CS_DungeonMateState"}
        msg.id = data.id
        c_send(msg)
    end
end

function dungeon_main_delegate_close()
	m_uidungeon:close()
end
