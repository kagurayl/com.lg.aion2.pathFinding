
local m_businessfilter_maxsearch = 100
local m_businessfilter_maxsearchlevel = 200
local m_businessfilter_subpanel = nil

function business_filter_open()
    m_businessfilter_subpanel = m_uibusiness_main:getwidget("tab_filter")
    m_businessfilter_subpanel:setvisible(true)

    local checkbox_filtercivtext = m_businessfilter_subpanel:getwidget("checkbox_filterciv/text_label")
    checkbox_filtercivtext:settext(getplayercivtext(playerattr_info.civ))

    m_businessfilter_subpanel:setwidgetdelegate("button_search", business_query_delegate_search)
    m_businessfilter_subpanel:setwidgetdelegate("button_reset", business_query_delegate_reset)
    m_businessfilter_subpanel:setwidgetdelegate("image_bg/button_close", business_query_delegate_close)
    business_query_delegate_reset()
end

function business_query_delegate_search()
    local edit_itemname = m_businessfilter_subpanel:getwidget("edit_itemname")
    local searchtext = edit_itemname:gettext()
    if searchtext == nil or string.len(searchtext) == 0 then
        messagealert_addalert("BUSINESS_INPUT_SEARCH_TOOMUCH")
        return
    end

    local searchquality = {}
    for i=csvitemquality.grey, csvitemquality.red do
        local checkbox_filterquality = m_businessfilter_subpanel:getwidget("checkbox_filterquality" .. i)
        searchquality[i] = checkbox_filterquality:getcheck()
    end

    local checkbox_filterciv = m_businessfilter_subpanel:getwidget("checkbox_filterciv")
    local searchciv = checkbox_filterciv:getcheck()

    local edit_levelmin = m_businessfilter_subpanel:getwidget("edit_levelmin")
    local searchlevelmin = tonumber(edit_levelmin:gettext())
    if searchlevelmin == nil or searchlevelmin < 1 then
        searchlevelmin = 1
    end
    searchlevelmin = math.min(searchlevelmin, m_businessfilter_maxsearchlevel)

    local edit_levelmax = m_businessfilter_subpanel:getwidget("edit_levelmax")
    local searchlevelmax = tonumber(edit_levelmax:gettext())
    if searchlevelmax == nil or searchlevelmax > m_businessfilter_maxsearchlevel then
        searchlevelmax = m_businessfilter_maxsearchlevel
    end
    searchlevelmax = math.max(searchlevelmax, searchlevelmin)

    local itemarray = csvitem_getallfromsubname(searchtext)
    local queryid = {}
    for i=1,#itemarray do
        local config_item = itemarray[i]
        local qualityenable = searchquality[config_item.quality] or false
        if qualityenable then
            if not searchciv or playercivavailable(config_item.civ, playerattr_info.civ) then
                if config_item.itemlevel >= searchlevelmin and config_item.itemlevel <= searchlevelmax then
                    queryid[#queryid + 1] = config_item.id
                end
            end
        end
    end
    if #queryid > m_businessfilter_maxsearch then
        messagealert_addalert("BUSINESS_INPUT_SEARCH_TOOMUCH")
        return
    end
    if #queryid > 0 then
        business_query_setqueryitem(queryid)
    else
        business_query_setqueryempty()
    end
    m_businessfilter_subpanel:setvisible(false)
end

function business_query_delegate_reset()
    for i=csvitemquality.grey, csvitemquality.red do
        local text_checkboxname = m_businessfilter_subpanel:getwidget("checkbox_filterquality" .. i .. "/text_label")
        local r,g,b,a = csvitem_getqualityfloatcolor(i)
        text_checkboxname:setcolor(r,g,b,a)

        local checkbox_filterquality = m_businessfilter_subpanel:getwidget("checkbox_filterquality" .. i)
        checkbox_filterquality:setcheck(true)
    end

    local checkbox_filterciv = m_businessfilter_subpanel:getwidget("checkbox_filterciv")
    checkbox_filterciv:setcheck(true)

    local edit_levelmin = m_businessfilter_subpanel:getwidget("edit_levelmin")
    edit_levelmin:settext("1")

    local edit_levelmax = m_businessfilter_subpanel:getwidget("edit_levelmax")
    edit_levelmax:settext(m_businessfilter_maxsearchlevel)

    local edit_itemname = m_businessfilter_subpanel:getwidget("edit_itemname")
    edit_itemname:settext("")
end

function business_query_delegate_close()
    m_businessfilter_subpanel:setvisible(false)
end
