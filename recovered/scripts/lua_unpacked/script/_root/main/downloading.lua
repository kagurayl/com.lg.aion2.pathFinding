
assetlocation =
{
    asset = 0,
    localfile = 1,
    remote = 2,
	downloading = 3,
}

function downloading_getlist()
	return c_scene_downloadgetlist()
end

function downloading_startflag(flag)
	return c_scene_downloadflag(flag)
end

function downloading_startfile(filename)
	c_scene_downloadfile(filename)
end

function downloading_queryfile(filename)
	return c_scene_downloadqueryfile(filename)
end

function downloading_queryflag(flag)
	return c_scene_downloadqueryflag(flag)
end

function downloading_getdesc(size)
	if size > 1024 * 1024 then
		return string.format("%dMB", math.tointegerfloor(size / 1024 / 1024))
	elseif size > 1024 then
		return string.format("%dKB", math.tointegerfloor(size / 1024))
	else
		return "0"
	end
end
