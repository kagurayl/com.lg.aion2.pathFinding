
local m_uiselectionbufflist = uipanel_createhandle("popup/selectionbufflist", uilayer.top, uiflag.escapeclose)
local m_uiselectionbufflist_inst = {buff = "popup/inst_buff"}

function selectionbufflist_create(actorid)
	m_uiselectionbufflist.actorid = actorid
	local actor = actormanager_getfromactorid(actorid)
	if actor ~= nil and actor.buff ~= nil then
		for i=1, #actor.buff do
			local buff = actor.buff[i]
			if buff.iconview then
				m_uiselectionbufflist:open()
				break
			end
		end
	end
end

function selectionbufflist_onopen()
    local list_buff = m_uiselectionbufflist:getwidget("list_buff")
    list_buff:init(uilistflag.vertical)
    m_uiselectionbufflist:setwidgetdelegate("button_close", selectionbufflist_delegate_close)
    event_register(eventtype.update, selectionbufflist_update, m_uiselectionbufflist)
end

function selectionbufflist_update()
	local actor = actormanager_getfromactorid(m_uiselectionbufflist.actorid)
	popup_updatebufflist(m_uiselectionbufflist, m_uiselectionbufflist_inst.buff, actor, updatebufflisttype.all, 800, 160, nil)
end

function selectionbufflist_delegate_close()
	m_uiselectionbufflist:close()
end
