
local playertitle_linetype =
{
    category = 1,
    titlename = 2,
    titledesc = 3,
}

local m_playertitle_inst = {category = "overview/inst_titlecategory", name = "overview/inst_titlename", desc = "overview/inst_titledesc"}
local m_playertitle_selectcategory = nil
local m_playertitle_selecttitle = nil

function playertitle_onopen()
	local list_title = m_uioverview_playermain:getwidget("tab_title/list_title")
    list_title:init(uilistflag.vertical)
    list_title:setclickdelegate(playertitle_delegate_list_item)
end

local function playertitle_gettitleenable(titleid)
    for i=1,#playerattr_titlelist do
        if playerattr_titlelist[i].titleid == titleid then
            return true
        end
    end
    return false
end

local function playertitle_gettitlecolor(titleid)
    local r = 0.5
    local g = 0.5
    local b = 0.5
    if playerattr_info.title == titleid then
        r = 0.0
        g = 1.0
        b = 0.0
    elseif playertitle_gettitleenable(titleid) then
        r = 1.0
        g = 1.0
        b = 1.0
    end
    return r, g, b
end

function playertitle_delegate_list_item(line, event, data)
    local name = line:getname()
    if string.startwith(name, "category_") then
        m_playertitle_selectcategory = data
        m_playertitle_selecttitle = nil
    elseif string.startwith(name, "titlename_") then
        m_playertitle_selecttitle = data.id
    end
    playertitle_updateui()
end

local function playertitle_setdesc(line, config_title)
    local attr_title = nil
    for i=1,#playerattr_titlelist do
        if playerattr_titlelist[i].titleid == config_title.id then
            attr_title = playerattr_titlelist[i]
            break
        end
    end

    local desc = c_textformat(config_title.desc)
    local attrarray = equip_parseattr(config_title.attrtitle)
    if attrarray ~= nil then
        for i=1,#attrarray do
            local attr = attrarray[i]
            if attr.text ~= nil then
                local add = ""
                if not string.startwith(attr.val, "-") then
                    add = "+"
                end
                desc = desc .. string.format("\n%s%s%s", c_textformat(attr.text), add, attr.val)
            end
        end
    end
    if attr_title ~= nil then
        local date = timer_serverdate(attr_title.entitledate, true, true, false)
        desc = desc .. string.format("\n%s%s", c_textformat("PLAYER_TITLE_ENTITLE"), date)
        if attr_title.expiredate > 0 then
            local expiretext = timer_servercountdown(attr_title.expiredate, true, true, false)
            if expiretext ~= nil then
                desc = desc .. string.format("\n%s%s", c_textformat("PLAYER_TITLE_EXPIRE"), expiretext)
            else
                desc = desc .. string.format("\n%s", c_textformat("PLAYER_TITLE_EXPIRED"))
            end
        end
    end

    text_desc = line:getwidget("text_desc")
    text_desc:settext(desc)
    local w,h = text_desc:setheightfromrendersize()
    local x,y = text_desc:getposition()

    local button_active = line:getwidget("button_active")
    local button_x, button_y = button_active:getposition()
    local button_w, button_h = button_active:getsize()
    button_active:setposition(button_x, y - h - button_h / 2)
    button_active:setdelegate(playertitle_delegate_active)    
    if playerattr_info.title == config_title.id then
        button_active:settext("PLAYER_TITLE_DEACTIVE")
        button_active:setenable(true)
        button_active.config_title = nil
    else
        button_active:settext("PLAYER_TITLE_ACTIVE")
        button_active:setenable(attr_title ~= nil)
        button_active.config_title = config_title
    end
    line:setsize(-(y - h - button_h))
end

function playertitle_updateui()
    local list_title = m_uioverview_playermain:getwidget("tab_title/list_title")
    list_title:savestate()
    list_title:clear()
    local config_titleall = csvplayertitle_getall()
    local titlecategory = {}
    local titlecategorytable = {}
    local categoryother = {}
    categoryother.name = "PLAYER_TITLE_OTHER"
    categoryother.title = {}
    titlecategory[#titlecategory + 1] = categoryother
    
    for i=1,#config_titleall do
        local config_title = config_titleall[i]
        if config_title.category ~= "0" and playercivavailable(config_title.civ, playerattr_info.civ) then
            local category = nil
            if #config_title.category > 0 then
                category = titlecategorytable[config_title.category]
                if category == nil then
                    category = {}
                    category.name = config_title.category
                    category.title = {}
                    titlecategory[#titlecategory + 1] = category
                    titlecategorytable[config_title.category] = category
                end
            elseif playertitle_gettitleenable(config_title.id) then
                category = categoryother
            end
            if category ~= nil then
                category.title[#category.title + 1] = config_title
            end
        end
    end

    for categoryindex=1,#titlecategory do
        local category = titlecategory[categoryindex]
        local line = list_title:add(m_playertitle_inst.category, "category_" .. categoryindex, category.name)
        local text_name = line:getwidget("text_name")
        text_name:settext(category.name)
        if m_playertitle_selectcategory == category.name then
            text_name:setcolor(0,1,0,1)
            for titleindex=1,#category.title do
                local config_title = category.title[titleindex]
                line = list_title:add(m_playertitle_inst.name, "titlename_" .. titleindex, config_title)
                text_name = line:getwidget("text_name")
                text_name:settext(config_title.name)
                local r,g,b = playertitle_gettitlecolor(config_title.id)
                text_name:setcolor(r,g,b,1.0)
                if m_playertitle_selecttitle == config_title.id then
                    line = list_title:add(m_playertitle_inst.desc, "titledesc_" .. titleindex, config_title)
                    playertitle_setdesc(line, config_title)
                end
            end
        else
            text_name:setcolor(1,1,1,1)
        end
    end
    list_title:restorestate()
    list_title:updatecontentsize()
end

function playertitle_delegate_active(sender, event)
    local msg = {messageid="CS_TitleActive"}
    local config_title = sender.config_title
    if config_title ~= nil then
        msg.titleid = config_title.id
    else
        msg.titleid = 0
    end
    if msg.titleid == playerattr_info.title then
        msg.titleid = 0
    end
    c_send(msg)
end
