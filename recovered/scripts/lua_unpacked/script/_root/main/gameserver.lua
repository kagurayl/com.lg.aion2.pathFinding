
networkstate =
{
    none = 0,
    connect = 1,
    connecting = 2,
    connected = 3,
    connectfailed = 4,
    disconnect = 5,
    disconnected = 6,
    destroy = 7,
}

gameserverstate = 
{
    none = 0,
    connect = 1,
    verify = 2,
    entered = 3,
}

local m_gameserverip = nil
local m_gameserververify = nil
local m_gameserverstate = gameserverstate.none

function gameserver_update()
    if m_gameserverstate == gameserverstate.none then
        return
    end

    local state = c_connectstate()
    if state == networkstate.connectfailed or state == networkstate.disconnected then
        if m_gameserverip.index ~= nil then
            m_gameserverip.index = m_gameserverip.index + 1
            if m_gameserverip.index > #m_gameserverip then
                m_gameserverip.index = 1
            end 
        else
            m_gameserverip.index = 1
        end
        c_connectserver(m_gameserverip[m_gameserverip.index])
        m_gameserverstate = gameserverstate.connect
        messagealert_showcenter("LOGINSTATE_SERVER_CONNECTGAME")
        return
    end

    if m_gameserverstate == gameserverstate.connect then
        if state == networkstate.connected then
            m_gameserverstate = gameserverstate.verify
        end
    end
end

function gameserver_request(accountid, uuid, serverid, ipv4, ipv6, port)
    m_gameserververify = {}
    m_gameserververify.serverid = serverid
    m_gameserververify.accountid = accountid
    m_gameserververify.uuid = uuid
    m_gameserverip = {}
    m_gameserverentered = false
    if ipv4 ~= nil and string.len(ipv4) > 0 then
        m_gameserverip[#m_gameserverip + 1] = string.format("%s:%d", ipv4, port)
    end
    if ipv6 ~= nil and string.len(ipv6) > 0 then
        m_gameserverip[#m_gameserverip + 1] = string.format("[%s]:%d", ipv6, port)
    end
    m_gameserverstate = gameserverstate.connect
    c_disconnect()
end

function gameserver_stop()
    m_gameserverstate = gameserverstate.none
    messagealert_closecenter()
    c_disconnect()
end

function gameserver_onenter()
    m_gameserverstate = gameserverstate.entered
    messagealert_closecenter()
end

function gameserver_entered()
    return m_gameserverstate == gameserverstate.entered
end

function gameserver_getverify()
    return m_gameserververify
end
