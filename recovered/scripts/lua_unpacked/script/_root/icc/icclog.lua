
local m_icclog_inst = {log = "icc/inst_log"}

function icclog_onopenui()
    local list_log = m_uiicc_main:getwidget("tab_log/list_log")
    list_log:init(uilistflag.vertical)
end

function icclog_updateui()
    if m_uiicc_main:null() then
        return
    end
    local list_log = m_uiicc_main:getwidget("tab_log/list_log")
    list_log:clear()
    for i=1,#playerattr_icc.log do
        local log = playerattr_icc.log[i]
        local line = list_log:add(m_icclog_inst.log)
        local logjson = c_config_json2table(log)

        local text_date = line:getwidget("text_date")
        text_date:settext(logjson.date)

        local text_log = line:getwidget("text_log")
        text_log:settext(logjson.evt, logjson.arg1, logjson.arg2)
    end
end
