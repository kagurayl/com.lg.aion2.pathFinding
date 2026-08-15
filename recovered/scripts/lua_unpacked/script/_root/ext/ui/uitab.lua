
_uitabclass = _class("_uitabclass")

function uitabcreate(panel)
	local tab = _uitabclass.new()
	tab.panel = panel
	tab.widget = {}
	return tab
end

function _uitabclass:add(buttonname, tabwidgetname, delegate)
	local widget = {}
	widget.button = self.panel:getwidget(buttonname)
	if tabwidgetname ~= nil then
		widget.tabwidget = self.panel:getwidget(tabwidgetname)
	else
		widget.tabwidget = nil
	end
	widget.available = true
	widget.name = tabwidgetname
	widget.delegate = delegate
	widget.button.uitab = self
	widget.button.uitabindex = #self.widget + 1
	widget.button:setdelegate(uitabclass_buttondelegate)
	self.widget[#self.widget + 1] = widget
end

function _uitabclass:settab(index)
	for i=1,#self.widget do
		local widget = self.widget[i]
		local select = i == index
		if widget.tabwidget ~= nil then
			widget.tabwidget:setvisible(select)
		end
		widget.button:setenable(not select and widget.available)
	end
end

function _uitabclass:settabavailable(tabwidgetname, available)
	for i=1,#self.widget do
		local widget = self.widget[i]
		if widget.name == tabwidgetname then
			widget.available = available
			local button_text = widget.button:getwidget("button_text")
			button_text:setavailablecolor(available)
			if available then
				widget.button:setopacity(1.0)
			else
				widget.button:setopacity(0.25)
				widget.button:setenable(false)
			end
			break
		end
	end
end

function uitabclass_buttondelegate(sender, event)
	local tab = sender.uitab
	for i=1,#tab.widget do
		local widget = tab.widget[i]
		local select = sender.uitabindex == i
		if widget.tabwidget ~= nil then
			widget.tabwidget:setvisible(select)
		end
		widget.button:setenable(not select and widget.available)
	end
	local delegate = tab.widget[sender.uitabindex].delegate
	if delegate ~= nil then
		delegate(sender, event)
	end
end
