
local base52_alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

local base52_charmap = {}
for i = 1, #base52_alphabet do
    local char = base52_alphabet:sub(i, i)
    base52_charmap[char] = i - 1
end

function base52_encode(number)
    if number <= 0 then
        return base52_alphabet:sub(1, 1)
    end
    local result = {}
    while number > 0 do
        local remainder = number % 52
        table.insert(result, 1, base52_alphabet:sub(remainder + 1, remainder + 1))
        number = math.floor(number / 52)
    end
    return table.concat(result)
end

function base52_decode(str)
    local number = 0
    for i = 1, #str do
        local char = str:sub(i, i)
        local val = base52_charmap[char]
        if not val then
            return 0
        end        
        number = number * 52 + val
    end
    return number
end

function base52_encodesign(num)
    local number = math.tointegerfloor(num)
	local base52 = base52_encode(math.abs(number))
	if num < 0 then
		base52 = "-" .. base52
	end
	return base52
end

function base52_decodesign(str)
    local sign = false
    if string.startwith(str, "-") then
        sign = true
        str = string.sub(str, 2)
    end
	local number = base52_decode(str)
    if sign then
        number = -number
    end
    return number
end
