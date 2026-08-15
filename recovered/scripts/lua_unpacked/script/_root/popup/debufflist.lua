
local m_uidebufflist = uipanel_createhandle("popup/debufflist", uilayer.top, uiflag.escapeclose)
local m_uidebufflist_inst = {buff = "popup/inst_buff"}

function debufflist_create()
	if m_me ~= nil and m_me.buff ~= nil then
		for i=1, #m_me.buff do
			local buff = m_me.buff[i]
			if buff.config_buff ~= nil and csvskillbuff_isdebuff(buff.config_buff) then
				m_uidebufflist:open()
				break
			end
		end
	end
end

function debufflist_onopen()
    local list_buff = m_uidebufflist:getwidget("list_buff")
    list_buff:init(uilistflag.vertical)
	list_buff:setclickdelegate(debufflist_delegate_list)
	m_uidebufflist.selectbuffid = 0
    m_uidebufflist:setwidgetdelegate("button_close", debufflist_delegate_close)
    event_register(eventtype.update, debufflist_update, m_uidebufflist)
end

function debufflist_update()
	popup_updatebufflist(m_uidebufflist, m_uidebufflist_inst.buff, m_me, updatebufflisttype.debuff, 800, 160, nil)
end

function debufflist_delegate_list(line, event, data)
    m_uidebufflist.selectbuffid = line.buffid
end

function debufflist_delegate_close()
	m_uidebufflist:close()
end
