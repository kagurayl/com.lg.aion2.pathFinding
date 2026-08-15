
function table.cleararray(tbl)
    while #tbl > 0 do
        table.remove(tbl, #tbl)
    end
end

function table.valname(array, findval)
	for key, val in pairs(array) do
		if val == findval then
            return key
        end
	end
end

function table.valcount(array)
	local count = 0
	for key, val in pairs(array) do
		count = count + 1
	end
	return count
end

function table.clonearray(tbl)
    local t = {}
    for key, val in pairs(tbl) do
		t[key] = val
	end
    return t
end

function table.mergearray(a,b)
    if a == nil then
        a = {}
    end
    if b ~= nil then
        for i=1,#b do
            a[#a + 1] = b[i]
        end
    end
    return a
end

function table.containvalue(a,b)
	for key, val in pairs(a) do
		if val == b then
            return true
        end
	end
    return false
end

function table.arraycontain(a,b)
	for i=1,#a do
		if a[i] == b then
            return true
        end
	end
    return false
end
