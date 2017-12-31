if SERVER then AddCSLuaFile("sh_gc.lua") end

local meta = getmetatable( DamageInfo() )
_GC_HANDLER_HIJACK = _GC_HANDLER_HIJACK or {}

function meta.__gc( self )
	if _GC_HANDLER_HIJACK[tostring(self)] then
		pcall( _GC_HANDLER_HIJACK[tostring(self)] )
		_GC_HANDLER_HIJACK[tostring(self)] = nil
	end
end

function GCHandler(func, ...)

	if type(func) ~= "function" then return end
	local data = DamageInfo()
	local params = {...}

	_GC_HANDLER_HIJACK[tostring(data)] = function() func( unpack(params) ) end
	return data

end