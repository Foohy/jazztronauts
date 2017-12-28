if SERVER then AddCSLuaFile("sh_gc.lua") end

local meta = getmetatable( DamageInfo() )
local hijack = {}

function meta.__gc( self )
	if hijack[tostring(self)] then
		pcall( hijack[tostring(self)] )
		hijack[tostring(self)] = nil
	end
end

function GCHandler(func, ...)

	if type(func) ~= "function" then return end
	local data = DamageInfo()
	local params = {...}

	hijack[tostring(data)] = function() func( unpack(params) ) end
	return data

end