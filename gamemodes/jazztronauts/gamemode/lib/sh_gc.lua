if SERVER then AddCSLuaFile("sh_gc.lua") end

local function install_gc(tbl, func)
	local prx = newproxy(true)
	local meta = getmetatable(prx)
	local metacopy = table.Copy(meta)

	metacopy[prx] = true -- Keep a ref to this
	function meta.__gc( self )
		pcall( func )
	end

	return setmetatable(tbl, metacopy)

end

function GCHandler(func, ...)
	if type(func) ~= "function" then return end
	local params = {...}
	local cbfunc = function() func( unpack(params) ) end

	return install_gc({}, cbfunc)

end
