
function platform_command(str)
    local json = c_config_json2table(str)

end

function command_backtologin()
    clearall()
    gameserver_stop()
    login_onerrorback()
end

function message_command(str)
    local json = c_config_json2table(str)
    if json ~= nil then
        if json.command == "verify" then
            local verify = gameserver_getverify()
            local md5 = c_math_md5(json.rand .. verify.uuid)
            c_sendverify(verify.serverid, verify.accountid, c_system_cmdline("version"), md5)
            messagealert_showcenter("LOGINSTATE_SERVER_ENTERINGGAME")
        elseif json.command == "error" then
            command_backtologin()
            messagebox_ok(json.message)
        end
    end
end
