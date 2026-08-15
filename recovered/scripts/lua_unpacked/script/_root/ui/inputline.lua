
local m_uiinputline = uipanel_createhandle("root/inputline", uilayer.top, uiflag.escapeclose)

function inputline_onopen()
    m_uiinputline:setwidgetdelegate("button_ok", inputline_delegate_ok)
    m_uiinputline:setwidgetdelegate("image_bg/button_close", inputline_delegate_close)
end

function inputline_show(type,title,text,func,arg)
    m_uiinputline.delegatefunc = func
    m_uiinputline.delegatearg = arg
    m_uiinputline:open()

    local titletext = m_uiinputline:getwidget("image_bg/text_title")
    titletext:settext(title or "")

    local edit_input = m_uiinputline:getwidget("edit_input")
    edit_input:settype(type)
    edit_input:settextraw(text or "")
end

function inputline_delegate_ok()
    if m_uiinputline:alive() then
        local edit_input = m_uiinputline:getwidget("edit_input")
        local text = edit_input:gettext()
        m_uiinputline:close()
        if m_uiinputline.delegatefunc ~= nil then
            m_uiinputline.delegatefunc(text, m_uiinputline.delegatearg)
        end
    end
end

function inputline_delegate_close()
    m_uiinputline:close()
end
