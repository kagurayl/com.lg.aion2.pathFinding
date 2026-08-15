
function string.reversefind(str, find)
	find = string.byte(find)
    for i=#str, 1, -1 do
		if string.byte(str,i,i) == find then
			return i
		end
    end
end

function string.split(str, marker)
	local result = {}
	if str == nil or string.len(str) == 0 then
		return result
	end
	local split = string.byte(marker)
	local index = 1
	for i=1, #str do
        local find = string.byte(str,i,i)
		if find == split then
            result[#result + 1] = string.sub(str, index, i - 1)
            index = i + 1
		end
	end
	if index <= #str then
		result[#result + 1] =  string.sub(str, index, #str)
	end
	return result
end

function string.splitnumber(str, marker)
	local point = string.split(str, marker)
	for i=1,#point do
		point[i] = tonumber(point[i])
	end
	return point
end

function string.splitinterger(str, marker)
	local point = string.split(str, marker)
	for i=1,#point do
		point[i] = string.tointeger(point[i])
	end
	return point
end

function string.startwith(str, substr)
	local len_s = #str
    local len_p = #substr
    if len_p > len_s then
		return false
	end
    for i = 1, len_p do
        if string.byte(str, i) ~= string.byte(substr, i) then
            return false
        end
    end
    return true
end

function string.endwith(str, substr)
	local len_s = #str
    local len_suf = #substr
    if len_suf > len_s then
		return false
	end
    for i = 1, len_suf do
        if string.byte(str, len_s - len_suf + i) ~= string.byte(substr, i) then
            return false
        end
    end
    return true
end

function string.endwith2(str, substr)
	if str ~= nil then
		local splitstr = string.sub(str, -#substr)
		if splitstr == substr then
			return true, string.sub(str, 1, #str - #substr)
		end
	end
	return false
end

function string_removezero(str)
	local point = string.byte(".")
	local zero = string.byte("0")
    for i=#str, 1, -1 do
		local b = string.byte(str,i,i)
		if b == point then
			str = string.sub(str, 1, i - 1)
			break
		elseif b ~= zero then
			str = string.sub(str, 1, i)
			break
		end
    end
	return str
end

function string_getattr(val)
	return string_removezero(string.format("%.2f", val))
end

function string_getdesc(desc, arg)
	if arg ~= nil then
		local str = string.split(arg, ";")
		return c_textformat(desc, table.unpack(str))
	else
		return c_textformat(desc)
	end
end

function string.getpathtitle(fullpath)
    local directory = fullpath
    local filetitle = fullpath
	local index = string.reversefind(fullpath, "/")
	if index ~= nil then
		directory = string.sub(fullpath, 1, index - 1)
		filetitle = string.sub(fullpath, index + 1)
	end
	return directory, filetitle
end

function string.getpathtitlewithoutextname(fullpath)
    local directory = fullpath
    local filetitle = fullpath
	local index = string.reversefind(fullpath, "/")
	if index ~= nil then
		directory = string.sub(fullpath, 1, index - 1)
		filetitle = string.sub(fullpath, index + 1)
	end
	index = string.reversefind(filetitle, ".")
	filetitle = string.sub(filetitle, 1, index - 1)
	return directory, filetitle
end

function string.append(str, append, split)
	if str ~= nil and string.len(str) > 0 then
		if split ~= nil then
			return string.format("%s%s%s", str, split, append)
		else
			return string.format("%s%s", str, append)
		end
	else
		return append
	end
end

function string.tointeger(val)
	if val == nil then
		return nil
	end
	local number = tonumber(val)
	if number == nil then
		return nil
	end
	return math.floor(number)
end
