
function minimapadditive_init()
    local text_zone = m_uiminimap:getwidget("text_zone")
    text_zone:settext("")

	minimapadditive_updatescalebutton()
	m_uiminimap:setwidgetdelegate("image_opacitymap", minimapadditive_delegate_opacitymap)
    m_uiminimap:setwidgetdelegate("button_scale", minimapadditive_delegate_scale)
    m_uiminimap:setwidgetdelegate("button_hideui", minimapadditive_delegate_hideui)
    m_uiminimap:setwidgetdelegate("button_mail", minimapadditive_delegate_mail)
    m_uiminimap:setwidgetdelegate("button_worldmap", minimapadditive_delegate_worldmap)
	m_uiminimap:setwidgetdelegate("button_quest", minimapadditive_delegate_quest)
	m_uiminimap:setwidgetdelegate("button_menu", minimapadditive_delegate_menu)
	m_uiminimap:setwidgetdelegate("button_bag", minimapadditive_delegate_bag)
	m_uiminimap.image_wifi = m_uiminimap:getwidget("image_wifi")
	m_uiminimap.image_carrierdata = m_uiminimap:getwidget("image_carrierdata")
	m_uiminimap.text_latency = m_uiminimap:getwidget("text_latency")
	m_uiminimap.text_fps = m_uiminimap:getwidget("text_fps")
	m_uiminimap.progress_powerfill = m_uiminimap:getwidget("progress_powerfill")
	m_uiminimap.image_powercharge = m_uiminimap:getwidget("image_powercharge")
	m_uiminimap.text_power = m_uiminimap:getwidget("text_power")

    minimapadditive_updatemail()
    minimapadditive_updateaudit()
end

function minimapadditive_update()
	local ping = ping_getping()
	if ping >= 0 then
		if ping < pingstate.green then
			m_uiminimap.text_latency:setcolorverify(0.0, 1.0, 0.0, 1.0)
		elseif ping < pingstate.yellow then
			m_uiminimap.text_latency:setcolorverify(1.0, 1.0, 0.0, 1.0)
		else
			m_uiminimap.text_latency:setcolorverify(1.0, 0.0, 0.0, 1.0)
		end
		m_uiminimap.text_latency:settextrawverify(c_textformat("MINIMAP_LATENCY", ping))
	else
		m_uiminimap.text_latency:setcolorverify(1.0, 0.0, 0.0, 1.0)
		m_uiminimap.text_latency:settextrawverify(c_textformat("MINIMAP_LATENCY", "----"))
	end

	local fps, power, charge, wifi = system_getinfo()
	if power < 0.0 then
		power = 1.0
	end
	m_uiminimap.text_fps:settextrawverify(c_textformat("MINIMAP_FPS", math.tointegerfloor(fps)))
	m_uiminimap.image_wifi:setvisiblenothit(wifi == networkreachability.reachablevialocalareanetwork)
	m_uiminimap.image_carrierdata:setvisiblenothit(wifi == networkreachability.reachableviacarrierdatanetwork)
	m_uiminimap.progress_powerfill:setpercentverify(power)
	if charge == batterystatus.charging or charge == batterystatus.notcharging or charge == batterystatus.full then
		m_uiminimap.image_powercharge:setvisiblenothit(true)
		m_uiminimap.progress_powerfill:setcolor(0.0, 0.62, 0.0, 1.0)
	else
		m_uiminimap.image_powercharge:setvisiblenothit(false)
		m_uiminimap.progress_powerfill:setcolor(1.0, 1.0, 1.0, 1.0)
	end
	m_uiminimap.text_power:settextrawverify(math.tointegerfloor(power * 100.0))
end

function minimapadditive_setname(zonename)
    if m_uiminimap:alive() then
        local text_zone = m_uiminimap:getwidget("text_zone")
        if zonename ~= nil then
            text_zone:settext(zonename)
        else
            text_zone:settext("")
        end
	end
end

function minimapadditive_updatescalebutton()
    local scale = gamesetting_getnumber("MINIMAPSCALE")
	if scale < 1.0 or scale > 2.0 then
		scale = math.clamp(scale, 1.0, 2.0)
		gamesetting_modify("MINIMAPSCALE", scale)
	end
	local button_scale = m_uiminimap:getwidget("button_scale")
	if scale > 1.0 then
		button_scale:setsprite("sp1/mapscaleup")
	else
		button_scale:setsprite("sp1/mapscaledown")
	end
end

function minimapadditive_updatemail()
	m_uiminimap:setwidgetvisible("button_mail", #playerattr_mail > 0)
end

function minimapadditive_updateaudit()
	m_uiminimap:setwidgetvisiblenothit("image_audit", playerattr_businessbill.billcoin > 0 or playerattr_businessbill.billcash > 0)
end

function minimapadditive_delegate_opacitymap()
	map_opacity_openui()
end

function minimapadditive_delegate_menu(sender)
	homemenu_create()
end

function minimapadditive_delegate_quest(sender)
	inputkey_openquest()
end

function minimapadditive_delegate_bag(sender)
	inputkey_openbag()
end

function minimapadditive_delegate_scale()
	local scale = gamesetting_getnumber("MINIMAPSCALE")
	if scale > 1.0 then
		gamesetting_modify("MINIMAPSCALE", 1.0)
	else
		gamesetting_modify("MINIMAPSCALE", 1.5)
	end
	minimapadditive_updatescalebutton()
end

function minimapadditive_delegate_hideui()
	uimanager_sethideui(true)
	hideui_show()
end

function minimapadditive_delegate_mail()
	m_uimail_main.npcactorid = 0
	m_uimail_main:open()
end

function minimapadditive_delegate_worldmap()
	if m_uimap_main:alive() then
		map_main_delegate_close()
	elseif csvmap_hasmap(scene_getmapconfig()) then
		m_uimap_main:open()
		mapview_setmap(scene_getmapconfig(), csvmap_getlayer(scene_getmapconfig(), playerattr_info.posy))
		maplabel_flickerme()
	else
		messagealert_addalert("WORLDMAP_NOMAP")
	end
end
