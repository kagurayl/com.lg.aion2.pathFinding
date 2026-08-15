
function csvitemset_getfromid(id)
    return c_config_getmetaid(configid.item_set, id)
end

function csvitemset_getfromitemid(itemid)
    return c_config_getmetasubstring(configid.item_set, "item", itemid, string.byte(","))
end
