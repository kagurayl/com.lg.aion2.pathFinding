
local textformat_bytebrackets1 = string.byte("[")
local textformat_bytebrackets2 = string.byte("]")
local textformat_bytekeystart = string.byte("%")
local textformat_bytenum0 = string.byte("0")
local textformat_bytenum9 = string.byte("9")
local textformat_bytecharA = string.byte("A")
local textformat_bytecharZ = string.byte("Z")

local textformat_key = {"num"}

local function textformat_iskey(strkey, strtext, textstart)
    local count = #strtext - textstart + 1
	if #strkey > count then
		return false
	end
    count = #strkey
    for i = 1, count do
        local b1 = string.byte(strkey, i)
        local b2 = string.byte(strtext, i + textstart - 1)
        if (b1 >= textformat_bytecharA and b1 <= textformat_bytecharZ) then
            b1 = b1 + 32
        end
        if (b2 >= textformat_bytecharA and b2 <= textformat_bytecharZ) then
            b2 = b2 + 32
        end
        if b1 ~= b2 then
            return false
        end
    end
    return true
end

local function textformat_addkey(srctext, start, delegate)
    local numindex = start + 1
    if numindex > #srctext then
        c_textappendbuffer("%")
        return numindex
    end
    local srcbyte = string.byte(srctext, numindex, numindex)
    if srcbyte >= textformat_bytenum0 and srcbyte <= textformat_bytenum9 then
        local substr = delegate(srcbyte - textformat_bytenum0)
        if substr ~= nil then
            c_textappendbuffer(substr)
        end
        local nextindex = numindex + 1
        if nextindex <= #srctext and string.byte(srctext, nextindex, nextindex) == textformat_bytekeystart then
            numindex = numindex + 1
        end
        return numindex
    elseif srcbyte == textformat_bytekeystart then
        c_textappendbuffer("%")
        return numindex
    end
    for i=1,#textformat_key do
        local key = textformat_key[i]
        if textformat_iskey(key, srctext, numindex) then
            local nextindex = numindex + #key
            if nextindex <= #srctext then
                local srcbyte = string.byte(srctext, nextindex, nextindex)
                if srcbyte >= textformat_bytenum0 and srcbyte <= textformat_bytenum9 then
                    key = string.sub(srctext, numindex, nextindex)
                    nextindex = nextindex + 1
                    if nextindex <= #srctext and string.byte(srctext, nextindex, nextindex) == textformat_bytekeystart then
                        nextindex = nextindex + 1
                    end
                elseif srcbyte == textformat_bytekeystart then
                    nextindex = nextindex + 1
                end
            end
            local substr = delegate(key)
            if substr ~= nil then
                c_textappendbuffer(substr)
            end
            return nextindex - 1
        end
    end
    c_textappendbuffer("%")
    return start
end

local function textformat_addbracket(srctext, start, delegate)
    local keystart = start + 1
    for i=keystart, #srctext do
        local srcbyte = string.byte(srctext, i, i)
        if srcbyte == textformat_bytekeystart then
            keystart = i + 1
        elseif srcbyte == textformat_bytebrackets1 then
            textformat_addbracket(srctext, i + 1, delegate)
        elseif srcbyte == textformat_bytebrackets2 then
            local substr = string.sub(srctext, keystart, i - 1)
            substr = delegate(substr)
            if substr ~= nil then
                c_textappendbuffer(substr)
            end
            return i
        end
    end
    return start
end

function textformat_gettext(srctext, delegate)
    local textstart = 1
    c_textclearbuffer()
    local pos = 1
    local length = #srctext
    while pos <= length do
        local srcbyte = string.byte(srctext, pos, pos)
        if srcbyte == textformat_bytebrackets1 then
            c_textappendsubbuffer(srctext, textstart - 1, pos - 1)
            pos = textformat_addbracket(srctext, pos, delegate)
            textstart = pos + 1
		elseif srcbyte == textformat_bytekeystart then
            c_textappendsubbuffer(srctext, textstart - 1, pos - 1)
            pos = textformat_addkey(srctext, pos, delegate)
            textstart = pos + 1
        elseif pos == length then
            c_textappendsubbuffer(srctext, textstart - 1, pos)
		end
        pos = pos + 1
    end
    return c_textgetbuffer()
end

function textformat_raw(text, arg1, arg2, arg3, arg4)
    local desc = textformat_gettext(text, function(key)
        if key == "num0" or key == 0 then
            return arg1
        elseif key == "num1" or key == 1 then
            return arg2
        elseif key == "num2" or key == 2 then
            return arg3
        elseif key == "num3" or key == 3 then
            return arg4
        end
    end)
    return desc
end

function textformat_args(textkey, arg1, arg2, arg3, arg4)
    if not c_textkey(textkey) then
        return textkey
    end
    return textformat_raw(c_textformat(textkey), arg1, arg2, arg3, arg4)
end

function textformat_emptydelegate(key)
    return nil
end
