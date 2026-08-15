
function unity_uipath(name)
	if name ~= nil then
		return string.lower(string.format("ui/%s.prefab", name))
	else
		return ""
	end
end

function unity_uitexturepath(name)
	if name ~= nil then
		return string.lower(string.format("textures/%s.png", name))
	else
		return ""
	end
end

function unity_spritepath(name)
	if name ~= nil then
		return string.lower(string.format("sprites/%s.png", name))
	else
		return ""
	end
end
