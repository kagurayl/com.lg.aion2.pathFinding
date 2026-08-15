

function _class(name)
	local cls = {}
	cls.__cname = name
    cls.__index = cls

	function cls.new(...)
		local instance = {}
		setmetatable(instance, cls)
		return instance
	end
	
	function cls.renew(instance)
		setmetatable(instance, cls)
	end

	return cls
end


function _inheritclass(name, parent)
	local cls = {}
	cls.__cname = name
	cls.__index = cls
    setmetatable(cls, {__index=parent})

	function cls.new(...)
        local instance = {}        
		setmetatable(instance, cls)
		return instance
	end
	
	function cls.renew(instance)
		setmetatable(instance, cls)
	end

	return cls
end
