
local m_uimessagebox = uipanel_createhandle("root/messagebox", uilayer.message, 0, nil, AudioCloseUI)

function messagebox_onopen()
    m_uimessagebox:setwidgetdelegate("button_ok1", messagebox_delegate_ok)
    m_uimessagebox:setwidgetdelegate("button_ok2", messagebox_delegate_ok)
    m_uimessagebox:setwidgetdelegate("button_cancel", messagebox_delegate_cancel)
end

function messagebox_ok(message, ok, func)
    m_uimessagebox.delegatefunc = func
    m_uimessagebox.delegatearg = nil

    m_uimessagebox:open()
    local messagetext = m_uimessagebox:getwidget("text_message")
    messagetext:settext(message or "")

    local buttonok1 = m_uimessagebox:getwidget("button_ok1")
    local buttonok2 = m_uimessagebox:getwidget("button_ok2")
    local buttoncancel = m_uimessagebox:getwidget("button_cancel")
    buttonok1:settext(ok or "UI_OK")
    buttonok1:setvisible(true)
    buttonok2:setvisible(false)
    buttoncancel:setvisible(false)
end

function messagebox_confirm(message, func, arg, ok, cancel, audio)
    m_uimessagebox.delegatefunc = func
    m_uimessagebox.delegatearg = arg
    
    m_uimessagebox:open()

    if audio == nil then
        audio = AudioMessageBox
    end
    if #audio > 0 then
        audiomanager_playaudioui(audio)
    end

    local messagetext = m_uimessagebox:getwidget("text_message")
    messagetext:settext(message or "")

    local buttonok1 = m_uimessagebox:getwidget("button_ok1")
    local buttonok2 = m_uimessagebox:getwidget("button_ok2")
    local buttoncancel = m_uimessagebox:getwidget("button_cancel")
    buttonok2:settext(ok or "UI_OK")
    buttoncancel:settext(cancel or "UI_CANCEL")
    buttonok1:setvisible(false)
    buttonok2:setvisible(true)
    buttoncancel:setvisible(true)
end

function messagebox_closeui(ok)
    if m_uimessagebox:alive() then
        m_uimessagebox:close()
        if m_uimessagebox.delegatefunc ~= nil then
            m_uimessagebox.delegatefunc(ok, m_uimessagebox.delegatearg)
        end
    end
end

function messagebox_delegate_ok()
    messagebox_closeui(true)
end

function messagebox_delegate_cancel()
    messagebox_closeui(false)
end
