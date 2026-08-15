
local function csvasset_preload_anim(aliasarray, animname)
    for i=1,#aliasarray do
        local aliasfile = aliasarray[i]
        local alias = aliasfile[animname]
        if alias ~= nil then
            local path = alias.file
            c_scene_loadasset(path)
        end
    end
end

function csvasset_preload(filename)
    c_scene_loadasset(filename)
    return filename
end

function csvasset_effectpath(name)
    local path = string.format("effects/prt/%s.prefab", name)
    c_scene_loadasset(path)
    return name
end

function csvasset_preload_vfx(name)
    local path = csvasset_effectpath(name)
    c_scene_loadasset(path)
    return name
end

function csvasset_preload_vfxbind(name, bone)
    local path = csvasset_effectpath(name)
    c_scene_loadasset(path)
    return string.format("%s,%s", name, bone)
end
