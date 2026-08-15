
local m_http_request = {}
local m_http_scriptid = 0

function http_request(url, content, delegate, userdata)
    m_http_scriptid = m_http_scriptid + 1
    local req = {}
    req.scriptid = m_http_scriptid
    req.url = url
    req.content = content
    req.delegate = delegate
    req.userdata = userdata
    m_http_request[req.scriptid] = req
    c_httprequest(req.scriptid, url, content)
    return req.scriptid
end

function http_cancel(scriptid)
    if scriptid ~= nil then
        local req = m_http_request[scriptid]
        m_http_request[scriptid] = nil
        if req ~= nil then
            c_httpcancel(scriptid)
        end
    end
end

function http_response(scriptid, response)
    if response ~= nil and string.len(response) > 0 then
        debuglog(response)
    end
    local req = m_http_request[scriptid]
    if req == nil then
        return
    end
    m_http_request[scriptid] = nil
    if req.delegate ~= nil then
        req.delegate(response, req.userdata)
    end
end
