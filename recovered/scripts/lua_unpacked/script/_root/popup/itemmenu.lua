
local m_uiitemmenu_buttonwidth = 400
local m_uiitemmenu_buttonheight = 150
local m_uiitemmenu_buttonspace = 50
local m_uiitemmenu = uipanel_createhandle("popup/itemmenu", uilayer.top, 0)
local m_uiitemmenudata = nil

function itemmenu_reset(data)
    m_uiitemmenudata = {}
    m_uiitemmenudata.data = data
    m_uiitemmenudata.button = {}

    m_uiitemmenu:open()
    m_uiitemmenu.data = data
end

function itemmenu_close()
    m_uiitemmenu:close()
    tips_close()
end

function itemmenu_getpanel()
    return m_uiitemmenu
end

function itemmenu_addbutton(text, delegate)
    local button = {}
    button.text = text
    button.delegate = delegate
    m_uiitemmenudata.button[#m_uiitemmenudata.button + 1] = button
end

function itemmenu_getcount()
    return #m_uiitemmenudata.button
end

function itemmenu_getwidth()
    return m_uiitemmenu_buttonwidth
end

function itemmenu_getheight()
    return (#m_uiitemmenudata.button + 1) * m_uiitemmenu_buttonheight + #m_uiitemmenudata.button * m_uiitemmenu_buttonspace
end

function itemmenu_open(x, y, parent)
    if #m_uiitemmenudata.button == 0 then
        m_uiitemmenu:close()
        return
    end
    itemmenu_addbutton("UI_CANCEL", itemmenu_delegate_close)
    for i=1,#m_uiitemmenudata.button do
        local button = m_uiitemmenudata.button[i]

        local button_menu = m_uiitemmenu:getwidget("button_menu_" .. i)
        if button_menu == nil then
            local source = m_uiitemmenu:getwidget("button_menu_1")
            button_menu = source:clone("button_menu_" .. i)
        end
        button_menu.itemdelgate = button.delegate
        button_menu:setvisible(true)
        button_menu:setenablenofade(button_menu.itemdelgate ~= nil)
        button_menu:settext(button.text)
        button_menu:setdelegate(itemmenu_delegatebutton)

        button_menu:setposition(x, y)
        y = y - m_uiitemmenu_buttonheight - m_uiitemmenu_buttonspace
    end
    m_uiitemmenu:hideunused("button_menu_", #m_uiitemmenudata.button + 1)
    m_uiitemmenu:setparent(parent)
end

function itemmenu_delegatebutton(sender)
    if sender.itemdelgate ~= nil then
        sender.itemdelgate(m_uiitemmenu.data)
        m_uiitemmenu:close()
        tips_close()
    end
end

function itemmenu_delegate_close()
    itemmenu_close()
end
