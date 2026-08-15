
function csvrenderpreset_getfromname(name)
    local preset = c_config_getmetacol(configid.render_preset, "name", name)
    return preset
end

function csvrenderpreset_getloginfacepreset(civ, sex)
    local count = 0
    local title = nil
    if civ == playerciv.light then
        if sex == playersex.male then
            title = "lm"
            count = 54
        else
            title = "lf"
            count = 49
        end
    else
        if sex == playersex.male then
            title = "dm"
            count = 56
        else
            title = "df"
            count = 43
        end
    end
    local preset = {}
    for i=1,count do
        preset[i] = csvrenderpreset_getfromname(title .. i)
    end
    return preset
end

function csvrenderpreset_getloginbodypreset(civ, sex)
    local preset = {}
    local count = 0
    local title = nil
    if civ == playerciv.light then
        if sex == playersex.male then
            title = "lmbody"
            count = 11
        else
            title = "lfbody"
            count = 10
        end
    else
        if sex == playersex.male then
            title = "dmbody"
            count = 11
        else
            title = "dfbody"
            count = 10
        end
    end
    local preset = {}
    for i=1,count do
        preset[i] = csvrenderpreset_getfromname(title .. i)
    end
    return preset
end
