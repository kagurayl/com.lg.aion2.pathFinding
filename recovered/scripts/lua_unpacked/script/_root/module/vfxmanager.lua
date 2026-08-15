
vfxflag =
{
	free = 0x1,
    bindposition = 0x2,
    followposition = 0x4,
    followscale = 0x8,
    followrotation = 0x10,
    spawnposition = 0x20,
    followposscale = (0x4 + 0x8),
    hidewithbuff = 0x40,
    vampiric = 0x80,
    linktarget = 0x100,
}

local m_vfxupdate = {}
local m_fxclist = {}

function vfxmanager_createvfx(file)
    local vfx = vfxcreatefromfile(file)
    return vfx
end

function vfxmanager_createfxc(fxname, actor, fxbind, flag, attackerid, targetid)
    local fxc = _fxcclass.new()
    fxc.id = csvconfig_generatescriptid()
    fxc:initfxc(fxname, actor, fxbind, flag, attackerid, targetid)
    m_fxclist[#m_fxclist + 1] = fxc
    return fxc
end

function vfxmanager_addvfxupdate(vfx)
    m_vfxupdate[#m_vfxupdate + 1] = vfx
end

function vfxmanager_clear()
    for i=1, #m_vfxupdate do
        m_vfxupdate[i]:destroy()
	end
    m_vfxupdate = {}
    for i=1, #m_fxclist do
        m_fxclist[i]:destroy()
	end
    m_fxclist = {}
    selection_clearvfx()
end

function vfxmanager_update()
    for i=#m_fxclist, 1, -1 do
        local fxc = m_fxclist[i]
        if not fxc:update() then
            table.remove(m_fxclist, i)
        end
    end
    for i=#m_vfxupdate, 1, -1 do
        local vfx = m_vfxupdate[i]
        if not vfx:update() then
            table.remove(m_vfxupdate, i)
        end
    end
end
