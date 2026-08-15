
local function lambda_createvariable(strvariable)
	local subarray = string.split(strvariable, ",")
	local variablearray = {}
	for i=1, #subarray do
		local substr = subarray[i]
		local variable = {}
		variablearray[i] = variable
		variable.str = substr
		variable.integer = 0
		variable.count = 1
		variable.flt = 0.0
		variable.perc = -1.0
		if string.find(substr, "x") ~= nil then
			substr = string.split(substr, "x")
			variable.integer = string.tointeger(substr[1])
			variable.count = string.tointeger(substr[2])
		elseif string.find(substr, "%%") ~= nil then
			local ratioindex = string.find(substr, "%%")
			substr = string.sub(substr, 1, ratioindex - 1)
			variable.integer = string.tointeger(substr)
			variable.flt = tonumber(substr)
			variable.perc = variable.flt / 100.0
		else
			variable.integer = string.tointeger(substr)
			variable.flt = tonumber(substr)
		end
	end
	return variablearray
end

local function lambda_createstep(lambdaarray, strstep, brackets)
	if strstep == nil or string.len(strstep) == 0 then
		return
	end
	local step = {}
	step.action = strstep
	step.index = #lambdaarray + 1
	lambdaarray[#lambdaarray + 1] = step
	if brackets > 0 then
		local strinput
		if string.byte(strstep, #strstep, #strstep) == string.byte(")") then
			strinput = string.sub(strstep, brackets + 1, #strstep - 1)
		else
			strinput = string.sub(strstep, brackets + 1, #strstep)
		end
		step.variable = lambda_createvariable(strinput)
		step.action = string.sub(strstep, 1, brackets - 1)
	end
end

function lambda_parse(strlambda)
	return lambda_parseadvance(strlambda, string.byte("."))
end

function lambda_parsearray(strlambda)
    local substrlambda = string.split(strlambda, ";")
    local lambda = {}
    for i=1,#substrlambda do
        lambda[i] = lambda_parse(substrlambda[i])
    end
    return lambda
end

function lambda_parseadvance(strlambda, split)
	if strlambda == "0" then
		return nil
	end
	local lambdaarray = {}
	local prev = 1
	local brackets1 = 0
	local bytepoint = split
	local bytebrackets1 = string.byte("(")
	local bytebrackets2 = string.byte(")")
	for i = 1, #strlambda do
		local strbyte = string.byte(strlambda,i,i)
		if bytepoint > 0 and strbyte == bytepoint then
			if brackets1 == 0 then
				lambda_createstep(lambdaarray, string.sub(strlambda, prev, i - 1), brackets1)
				prev = i + 1
				brackets1 = 0
			end
		elseif strbyte == bytebrackets1 then
			brackets1 = i - prev + 1
		elseif strbyte == bytebrackets2 then
			lambda_createstep(lambdaarray, string.sub(strlambda, prev, i - 1), brackets1)
			prev = i + 1
			brackets1 = 0
		end
		if i == #strlambda then
			lambda_createstep(lambdaarray, string.sub(strlambda, prev, i), brackets1)
		end
	end
	return lambdaarray
end
