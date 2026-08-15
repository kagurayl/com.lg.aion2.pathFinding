
function csvplayertitle_getall()
    return c_config_getmetaall(configid.player_title)
end

function csvplayertitle_getfromid(id)
    return c_config_getmetaid(configid.player_title, id)
end
