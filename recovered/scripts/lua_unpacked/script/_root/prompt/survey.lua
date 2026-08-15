
local m_survey_inst = {option = "prompt/inst_surveyoption", text = "prompt/inst_surveytext"}
local m_uisurvey = uipanel_createhandle("prompt/survey_main", uilayer.normal, bit.bor(uiflag.escapeclose, uiflag.placeright), AudioOpenUI, AudioCloseUI)

function survey_main_open()
	m_uisurvey:open()
end

function survey_main_onopen()
	m_uisurvey:setwidgetdelegate("button_submit", survey_main_delegate_submit)
	m_uisurvey:setwidgetdelegate("image_bg/button_close", survey_main_delegate_close)
	local text_desc = m_uisurvey:getwidget("text_desc")
	text_desc:settext(playerattr_survey.text)

	local list_option = m_uisurvey:getwidget("list_option")
    list_option:init(uilistflag.vertical)

	local option = string.split(playerattr_survey.option, ";")
	for i=1,#option do
        local line = list_option:add(m_survey_inst.option)
        local checkbox_option = line:getwidget("checkbox_option")
		checkbox_option.optionindex = i
		checkbox_option:setcheck(false)
		checkbox_option:setdelegate(survey_main_delegate_option)

		local checkbox_optiontext = line:getwidget("checkbox_option/text_label")
    	checkbox_optiontext:settext(option[i])
		if i == #option then
			line:addspace(100)
		end
    end

	local line = list_option:add(m_survey_inst.text)
    local text_desc = line:getwidget("text_desc")
	text_desc:settext("SURVEY_SELECTITEM")

	for i=1,#playerattr_survey.itemid do
		local config_item = csvitem_getfromid(playerattr_survey.itemid[i])
		if config_item ~= nil then
			line = list_option:add(m_survey_inst.option)
			local checkbox_option = line:getwidget("checkbox_option")
			checkbox_option.itemid = config_item.id
			checkbox_option:setcheck(false)
			checkbox_option:setdelegate(survey_main_delegate_item)

			local checkbox_optiontext = line:getwidget("checkbox_option/text_label")
			local itemname = string.format("%s(%d)", config_item.name, playerattr_survey.itemcount[i])
	    	checkbox_optiontext:settext(itemname)
			checkbox_optiontext:setcolor(csvitem_getfloatcolor(config_item))
		end
    end
end

function survey_main_delegate_submit()
	local option = 0
	local itemid = 0
	local list_option = m_uisurvey:getwidget("list_option")
	for i=1,list_option:getcount() do
		local line = list_option:getlinefromindex(i)
		local checkbox_option = line:getwidget("checkbox_option")
		if checkbox_option ~= nil and checkbox_option:getcheck() then
			if checkbox_option.optionindex ~= nil then
				option = checkbox_option.optionindex
			elseif checkbox_option.itemid ~= nil then
				itemid = checkbox_option.itemid
			end
		end
	end
	if option == 0 then
		chat_addsystemalert("SURVEY_NOTSELECTOPTION")
		return
	end
	if itemid == 0 then
		chat_addsystemalert("SURVEY_NOTSELECTITEM")
		return
	end
	local msg = {messageid="CS_Survey"}
	msg.id = playerattr_survey.id
	msg.option = option - 1
	msg.itemid = itemid
	c_send(msg)
	m_uisurvey:close()
end

function survey_main_delegate_option(sender, event)
	local list_option = m_uisurvey:getwidget("list_option")
	for i=1,list_option:getcount() do
		local line = list_option:getlinefromindex(i)
		local checkbox_option = line:getwidget("checkbox_option")
		if checkbox_option ~= nil and checkbox_option.optionindex ~= nil and checkbox_option.optionindex ~= sender.optionindex then
			checkbox_option:setcheck(false)
		end
	end
end

function survey_main_delegate_item(sender, event)
	local list_option = m_uisurvey:getwidget("list_option")
	for i=1,list_option:getcount() do
		local line = list_option:getlinefromindex(i)
		local checkbox_option = line:getwidget("checkbox_option")
		if checkbox_option ~= nil and checkbox_option.itemid ~= nil and checkbox_option.itemid ~= sender.itemid then
			checkbox_option:setcheck(false)
		end
	end
end

function survey_main_delegate_close()
	m_uisurvey:close()
end
