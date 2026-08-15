
platform =
{
    unknown = 0,
    windows = 1,
    android = 2,
    ios = 3,
}

batterystatus =
{
    unknown = 0,
    charging = 1,
    discharging = 2,
    notcharging = 3,
    full = 4,
}

networkreachability =
{
    notreachable = 0,
    reachableviacarrierdatanetwork = 1,
    reachablevialocalareanetwork = 2,
}

system_cutwidth = 0.085

local system_platformtype = platform.unknown
local system_review = false
local system_fpstime = 0.0
local system_fpsframe = 0
local system_fpscurrent = 0.0
local system_power = 0.0
local system_powercharge = 0
local system_network = 0

function system_init()
    jit.off()
    --debuglog("luajit:" .. math.ternary(jit.status(), 1, 0))
    --c_system_waitdebugger()

    local platformname = c_system_platform()
    if platformname == "win" then
        system_platformtype = platform.windows
    elseif platformname == "android" then
        system_platformtype = platform.android
    elseif platformname == "ios" then
        system_platformtype = platform.ios
    end

    local installname = c_system_sdk("InstallerName")
    local installerversion = c_system_sdk("InstallerVersion")
    local version_online = c_system_cmdline("version_online")
    local reviewversion = c_system_cmdline(installname .. "_review")
    system_review = reviewversion == installerversion
    c_system_setcrashreport("resourceversion", version_online)
end

function system_ispc()
    return system_platformtype == platform.windows
end

function system_isreview()
    return system_review
end

function system_update()
    system_fpsframe = system_fpsframe + 1
    if time_game - system_fpstime > 1.0 then
        system_fpscurrent = system_fpsframe / (time_game - system_fpstime)
        system_fpsframe = 0
        system_fpstime = time_game
        system_power, system_powercharge, system_network = c_system_info()
    end
end

function system_getinfo()
    return system_fpscurrent, system_power, system_powercharge, system_network
end

function system_quit()
    c_system_quitgame()
end
