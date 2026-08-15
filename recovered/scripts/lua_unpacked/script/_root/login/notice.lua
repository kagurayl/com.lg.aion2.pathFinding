
local m_notice_notelist = nil
local m_notice_selectid = nil
local m_uinotice = uipanel_createhandle("login/notice", uilayer.normal, uiflag.escapeclose, AudioOpenUI, AudioCloseUI)
local m_uinotice_inst = {name = "login/inst_noticename", text = "login/inst_noticetext"}

local function notice_updatenotetext()
	local list_text = m_uinotice:getwidget("list_text")
	local note = nil
	for i=1,#m_notice_notelist do
		if m_notice_notelist[i].noteid == m_notice_selectid then
			note = m_notice_notelist[i]
			break
		end
	end
	if note == nil then
		return
	end

	local line
	if list_text:getcount()==0 then
		line = list_text:add(m_uinotice_inst.text)
	else
		line = list_text:getlinefromindex(1)
	end
	local text_note = line:getwidget("text_note")
	text_note:settext(note.text)
	local width, renderheight = text_note:setheightfromrendersize()
	line:setsize(renderheight)
	list_text:updatecontentsize()
	list_text:setscrolltop()
end

function notice_onopen()
	m_uinotice:setwidgetdelegate("image_bg/button_close", notice_delegate_close)
	local notecount = #m_notice_notelist
	local list_name = m_uinotice:getwidget("list_name")
	list_name:init(uilistflag.vertical)

	local list_text = m_uinotice:getwidget("list_text")
	list_text:init(uilistflag.vertical)

	table.sort(m_notice_notelist, function(a, b) return (a.noteid < b.noteid) end)
	for i=notecount,1,-1 do
		local note = m_notice_notelist[i]
		local line = list_name:add(m_uinotice_inst.name, i, note.noteid)

		local text_name = line:getwidget("text_name")
		text_name:settext(note.title)

		local button_name = line:getwidget("button_name")
		button_name:setdelegate(notice_delegate_name)
		button_name:setenable(m_notice_selectid ~= note.noteid)
		button_name.noteid = note.noteid
	end
	list_name:setscrolltop()
	notice_updatenotetext()
end

function notice_delegate_name(sender)
	m_notice_selectid = sender.noteid
	local list_name = m_uinotice:getwidget("list_name")
	for i=1,list_name:getcount() do
		local line = list_name:getlinefromindex(i)
		local button_name = line:getwidget("button_name")
		button_name:setenable(m_notice_selectid ~= line:getdata())
	end
	notice_updatenotetext()
end

function notice_delegate_close()
	m_uinotice:close()
end

function notice_setnotelist(notelist)
	m_notice_notelist = notelist
	m_notice_selectid = 0
	if #m_notice_notelist > 0 then
		m_notice_selectid = m_notice_notelist[1].noteid
	end
end

function notice_show()
	m_uinotice:open()
end
