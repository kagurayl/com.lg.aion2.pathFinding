local m_quest_doc_inst = { text = "quest/inst_doc" }

m_uiquest_questdoc = uipanel_createhandle("quest/quest_doc", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)

function quest_doc_onopen()
    m_uiquest_questdoc:setwidgetdelegate("text_pageprev", quest_doc_delegate_pageprev)
    m_uiquest_questdoc:setwidgetdelegate("text_pagenext", quest_doc_delegate_pagenext)
    m_uiquest_questdoc:setwidgetdelegate("image_bg/button_close", quest_doc_delegate_close)
end

function quest_doc_setdoc(itemid)
    local xmlfilename = nil
    local config_item = csvitem_getfromid(itemid)
    if config_item ~= nil then
        local itemlambda = csvitem_getscript(config_item, "document")
        if itemlambda ~= nil then
            xmlfilename = string.format("streamconfig/dialog/doc_item/%s.html", itemlambda.variable[2].str)
        end
    end
    if xmlfilename == nil then
        return
    end
    quest_doc_setxml(config_item.name, c_config_loadxml(xmlfilename))
end

function quest_doc_setxml(title, xmlcontent)
    if xmlcontent == nil then
        return
    end
    m_uiquest_questdoc.xmlcontent = xmlcontent
    m_uiquest_questdoc:open()
    m_uiquest_questdoc.xmlpage = 1
    m_uiquest_questdoc.xmlpagemax = 1
    while true do
        local nextnode = "page_" .. (m_uiquest_questdoc.xmlpagemax + 1)
        if csvxml_containnode(m_uiquest_questdoc.xmlcontent, nextnode) then
            m_uiquest_questdoc.xmlpagemax = m_uiquest_questdoc.xmlpagemax + 1
        else
            break
        end
    end
    local text_title = m_uiquest_questdoc:getwidget("image_bg/text_title")
    text_title:settext(title)

    local list_doc = m_uiquest_questdoc:getwidget("list_doc")
    list_doc:init(uilistflag.vertical)

    quest_doc_updateui()
end

function quest_doc_updateui()
    local nodename = "page_" .. m_uiquest_questdoc.xmlpage
    local text = csvxml_gettext(m_uiquest_questdoc.xmlcontent, nodename)

	local list_doc = m_uiquest_questdoc:getwidget("list_doc")
    list_doc:clear()

    local line = list_doc:add(m_quest_doc_inst.text)
    local text_content = line:getwidget("text_content")
    text_content:setrichtext(text)

    local text_w,text_h = text_content:setheightfromrendersize()
    line:setsize(text_h)

    local text_page = m_uiquest_questdoc:getwidget("text_page")
    text_page:settext("QUEST_DOC_PAGE", m_uiquest_questdoc.xmlpage)

    local text_pageprev = m_uiquest_questdoc:getwidget("text_pageprev")
    text_pageprev:setavailablecolor(m_uiquest_questdoc.xmlpage > 1)

    local text_pagenext = m_uiquest_questdoc:getwidget("text_pagenext")
    text_pagenext:setavailablecolor(m_uiquest_questdoc.xmlpage < m_uiquest_questdoc.xmlpagemax)

    list_doc:updatecontentsize()
end

function quest_doc_delegate_pageprev()
    if m_uiquest_questdoc.xmlpage > 1 then
        m_uiquest_questdoc.xmlpage = m_uiquest_questdoc.xmlpage - 1
        quest_doc_updateui()
    end
end

function quest_doc_delegate_pagenext()
    if m_uiquest_questdoc.xmlpage < m_uiquest_questdoc.xmlpagemax then
        m_uiquest_questdoc.xmlpage = m_uiquest_questdoc.xmlpage + 1
        quest_doc_updateui()
    end
end

function quest_doc_delegate_close()
    m_uiquest_questdoc:close()
end
