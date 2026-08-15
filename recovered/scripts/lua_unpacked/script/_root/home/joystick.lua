
local m_uijoystick_movebackuidist = 200
local m_uijoystick_outeruidist = 500

m_uijoystick = uipanel_createhandle("home/joystick", uilayer.bottomtop, uiflag.scale)

function joystick_onopen()
	m_uijoystick.ismoving = false
	m_uijoystick.islockmoving = false
	m_uijoystick.controlbg = m_uijoystick:getwidget("image_bg")
	m_uijoystick.controlbg:setdelegate(joystick_delegate_bg)
	m_uijoystick.controlhandle = m_uijoystick:getwidget("image_handle")
	m_uijoystick.movelock = m_uijoystick:getwidget("image_lock")

	local x, y = m_uijoystick.controlhandle:getposition()
	m_uijoystick.controlhandle.initx = x
	m_uijoystick.controlhandle.inity = y
	event_register(eventtype.update, joystick_update, m_uijoystick)
end

function joystick_update()
	if m_uijoystick:null() then
		return
	end
	if m_uijoystick.ismoving then
		local x, y, w, h = m_uijoystick.controlbg:getabsolute()
		local cx = (x + w / 2)
		local cy = (y + h / 2)
		local axisx = m_uijoystick.controlhandle.touchx - cx
		local axisy = m_uijoystick.controlhandle.touchy - cy
		local axisdist = vector2_length(axisx, axisy)
		local angle = vector2_angle3d(vector2_normalize(axisx, -axisy))
		local forward_x, forward_y, forward_z = maincamera_getdir()
		if m_me.transform.onfloor then
			forward_x, forward_z = vector2_normalize(forward_x, forward_z)
			forward_y = 0.0
		end
		local right_x, right_y, right_z = vector3_cross(forward_x, forward_y, forward_z, 0.0, 1.0, 0.0)
		local up_x, up_y, up_z = vector3_cross(right_x, right_y, right_z, forward_x, forward_y, forward_z)
		local dirx, diry, dirz = vector3_rotateaxisangle(forward_x, forward_y, forward_z, up_x, up_y, up_z, -angle)
		local vx, vy, vz = vector3_normalize(m_me.move.inputmove_x + dirx, m_me.move.inputmove_y + diry, m_me.move.inputmove_z + dirz)
		m_me.move.inputmove_x = vx
		m_me.move.inputmove_y = vy
		m_me.move.inputmove_z = vz
		m_me.move.inputmove_outerui = axisdist > m_uijoystick_outeruidist
		m_me.move.inputrot = vector2_angle3d(vector2_normalize(vx, vz))
		m_me.move.inputdirection = movedirection.forward
		if gamesetting_getnumber("MOVEBACK") > 0 and axisy < 0 and axisdist < m_uijoystick_movebackuidist and angle > 135 and angle < 225 then
			m_me.move.inputrot = m_me.move.inputrot + 180
			m_me.move.inputdirection = movedirection.backward
		end

		local lock_x, lock_y, lock_w, lock_h = m_uijoystick.movelock:getabsolute()
		local lock_cx = (lock_x + lock_w / 2)
		local lock_cy = (lock_y + lock_h / 2)
		local dist = vector2_distance(m_uijoystick.controlhandle.touchx, m_uijoystick.controlhandle.touchy, lock_cx, lock_cy)
		m_uijoystick.islockmoving = dist < 180
		m_uijoystick.movelock:setvisiblenothit(axisdist > 512)
		m_uijoystick.movelock:setcolor(1, 1, 1, 1)
	elseif m_uijoystick.islockmoving then
		m_uijoystick.movelock:setvisiblenothit(true)
		m_uijoystick.movelock:setcolor(1, 1, 1, 0.5)
		local forward_x, forward_y, forward_z = maincamera_getdir()
		if m_me.transform.onfloor then
			forward_x, forward_z = vector2_normalize(forward_x, forward_z)
			forward_y = 0.0
		end
		m_me.move.inputmove_x = forward_x
		m_me.move.inputmove_y = forward_y
		m_me.move.inputmove_z = forward_z
		m_me.move.inputmove_outerui = false
		m_me.move.inputrot = vector2_angle3d(vector2_normalize(forward_x, forward_z))
		m_me.move.inputdirection = movedirection.forward
	else
		m_uijoystick.movelock:setvisiblenothit(false)
	end
end

local function joystick_updateposition(touchx, touchy)
	local uiscale = uimanager_getscale()
	m_uijoystick.controlhandle:setposition(touchx / uiscale, touchy / uiscale)
	m_uijoystick.controlhandle.touchx = touchx
	m_uijoystick.controlhandle.touchy = touchy
end

function joystick_stoplockmove()
	m_uijoystick.islockmoving = false
end

function joystick_delegate_bg(sender, event)
	if m_uijoystick:null() then
		return
	end
	if event.name == "mousedown" then
		m_uijoystick.ismoving = true
		m_uijoystick.islockmoving = false
		joystick_updateposition(event.mousex, event.mousey)
	elseif event.name == "mouseup" then
		m_uijoystick.controlhandle:setposition(m_uijoystick.controlhandle.initx, m_uijoystick.controlhandle.inity)
		m_uijoystick.ismoving = false
	elseif event.name == "drag" then
		if m_uijoystick.ismoving then
			joystick_updateposition(event.mousex, event.mousey)
		end
    end
end
