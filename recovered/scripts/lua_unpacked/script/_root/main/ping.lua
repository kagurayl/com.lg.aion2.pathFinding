
pingstate = 
{
    connect = -2,
    timeout = -1,
    green = 100,
    yellow = 500,
}

local m_ping_nexttime = 0
local m_ping_sendtime = 0
local m_ping_delay = 0
local m_ping_id = 0
local m_ping_recvid = 0

function ping_update()
    if not gameserver_entered() then
        m_ping_delay = pingstate.connect
        return
    end
    if m_ping_delay == pingstate.connect or m_ping_nexttime < time_game then
        if c_messageid("CS_Ping") >= 0 then
            if m_ping_recvid ~= m_ping_id then
                m_ping_delay = pingstate.timeout
            end
            m_ping_id = m_ping_id + 1
            m_ping_sendtime = time_game
            m_ping_nexttime = time_game + 2
            local msg = {messageid="CS_Ping"}
            msg.id = m_ping_id
            c_send(msg)
        end
    end
end

function ping_getping()
    return m_ping_delay
end

function SC_Ping(msg)
    if msg.id == m_ping_id then
        m_ping_recvid = msg.id
	    m_ping_delay = string.tointeger((time_game - m_ping_sendtime) * 1000)
    end
end
