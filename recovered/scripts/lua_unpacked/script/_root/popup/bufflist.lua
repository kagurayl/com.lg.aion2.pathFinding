
local m_uibufflist = uipanel_createhandle("popup/bufflist", uilayer.top, uiflag.escapeclose)
local m_uibufflist_inst = {buff = "popup/inst_buffremove"}

function bufflist_create()
	if m_me ~= nil and m_me.buff ~= nil then
		for i=1, #m_me.buff do
			local buff = m_me.buff[i]
			if buff.config_buff ~= nil and csvskillbuff_isbuff(buff.config_buff) then
				m_uibufflist:open()
				break
			end
		end
	end
end

function bufflist_onopen()
    local list_buff = m_uibufflist:getwidget("list_buff")
    list_buff:init(uilistflag.vertical)
	list_buff:setclickdelegate(bufflist_delegate_list)
	m_uibufflist.selectbuffid = 0
    m_uibufflist:setwidgetdelegate("button_close", bufflist_delegate_close)
    event_register(eventtype.update, bufflist_update, m_uibufflist)
end

function bufflist_update()
	popup_updatebufflist(m_uibufflist, m_uibufflist_inst.buff, m_me, updatebufflisttype.buff, 950, 160, bufflist_delegate_remove)
end

function bufflist_delegate_list(line, event, data)
    m_uibufflist.selectbuffid = line.buffid
end

function bufflist_delegate_remove(sender, event)
    local msg = {messageid="CS_RemoveBuff"}
    msg.buffinstid = sender.buffinstid
    c_send(msg)
end

function bufflist_delegate_close()
	m_uibufflist:close()
end
