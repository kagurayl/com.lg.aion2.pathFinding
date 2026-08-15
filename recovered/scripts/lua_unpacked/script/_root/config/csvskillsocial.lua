
socialtarget =
{
    any = 0,
    enemy = 1,
    pet = 2,
}

function csvskillsocial_getall(id)
    return c_config_getmetaall(configid.skill_social)
end

function csvskillsocial_getfromid(id)
    return c_config_getmetaid(configid.skill_social, id)
end
