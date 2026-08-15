

skillfxccommand =
{
    root = 0,
    node = 1,
    particle = 2,
    shaketime = 3,
    rotateaxis = 4,
}

local m_csv_skillfxc = {}

function csvskillfxc_load()
    local config_array = c_config_loadsimplearray(csvconfig_filename("skillfxc"))
    local type = nil
    local config_val = {}
    local nodearray = nil
    local node = nil
    local index = 1
    while index < #config_array do
        type, index = csvconfig_loadsimple(config_array, config_val, index)
        if type == skillfxccommand.root then
            nodearray = {}
            m_csv_skillfxc[config_val[1]] = nodearray
        elseif type == skillfxccommand.node then
            node = {}
            node.delay = config_val[1]
            node.scale = config_val[2]
            nodearray[#nodearray + 1] = node
        elseif type == skillfxccommand.particle then
            node.particle = config_val[1]
            if config_val[2] ~= "0" then
                node.bind = config_val[2]
            end
        elseif type == skillfxccommand.shaketime then
            node.shaketime = config_val[1]
        elseif type == skillfxccommand.rotateaxis then
            node.rotateaxis1 = config_val[1]
            node.rotateaxis2 = config_val[2]
        end
    end
end

function csvskillfxc_getfromname(name)
    return m_csv_skillfxc[name]
end
