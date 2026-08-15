
csvanimcardtype = 
{
    idle = 0,
    run = 1,
    jump = 2,
    rest = 3,
}

local m_csv_animcard = nil

function csvanimcard_load()
    m_csv_animcard = c_config_loadscripttable(csvconfig_filename("player_animcard"))
    for key, config_animcard in pairs(m_csv_animcard) do
        local animname = config_animcard.animname
		if config_animcard.type == csvanimcardtype.idle then
            animlist_add("nidle_" .. animname, "nidle_" .. animname, 0, "cidle_" .. animname, actoranimpart.weapon)
            config_animcard.animkey = animlist["nidle_" .. animname]
        elseif config_animcard.type == csvanimcardtype.run then
            animlist_add("nrun_" .. animname, "nrun_" .. animname, 0, "crun_" .. animname, actoranimpart.weapon)
            animlist_add("nrunl_" .. animname, "nrunl_" .. animname, 0, "crunl_" .. animname, actoranimpart.weapon)
            animlist_add("nrunr_" .. animname, "nrunr_" .. animname, 0, "crunr_" .. animname, actoranimpart.weapon)
            animlist_add("nrunb_" .. animname, "nrunb_" .. animname, 0, "crunb_" .. animname, actoranimpart.weapon)
            local key = {}
            config_animcard.animkey = key
            key.run = animlist["nrun_" .. animname]
            key.runl = animlist["nrunl_" .. animname]
            key.runr = animlist["nrunr_" .. animname]
            key.runb = animlist["nrunb_" .. animname]
        elseif config_animcard.type == csvanimcardtype.jump then
            animlist_add("jumpstart_" .. animname, "njump_start_" .. animname, 0, "cjump_start_" .. animname, actoranimpart.weapon)
            animlist_add("jumpair_" .. animname, "njump_air_" .. animname, 0, "cjump_air_" .. animname, actoranimpart.weapon)
            animlist_add("jumpend_" .. animname, "njump_end_" .. animname, 0, "cjump_end_" .. animname, actoranimpart.weapon)
            local key = {}
            config_animcard.animkey = key
            key.jumpstart = animlist["jumpstart_" .. animname]
            key.jumpair = animlist["jumpair_" .. animname]
            key.jumpend = animlist["jumpend_" .. animname]
        elseif config_animcard.type == csvanimcardtype.rest then
            animlist_addsimple("ridle_" .. animname, "ridle_" .. animname, 0)
            animlist_addsimple("rsit_" .. animname, "rsit_" .. animname, 0)
            animlist_addsimple("nstand_" .. animname, "nstand_" .. animname, 0)
            local key = {}
            config_animcard.animkey = key
            key.ridle = animlist["ridle_" .. animname]
            key.rsit = animlist["rsit_" .. animname]
            key.nstand = animlist["nstand_" .. animname]
        end
	end
end

function csvanimcard_getall(id)
    return m_csv_animcard
end

function csvanimcard_getfromid(id)
    return m_csv_animcard[id]
end

function csvanimcard_getkey(id)
    if id ~= 0 then
        local config_animcard = m_csv_animcard[id]
        if config_animcard ~= nil then
            return config_animcard.animkey
        end
    end
end
