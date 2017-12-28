if SERVER then AddCSLuaFile("sh_csent.lua") end
if SERVER then return end

_ENTITY_POOL = _ENTITY_POOL or {}
_ENTITY_REF_COUNTERS = {}

for k,v in pairs(_ENTITY_POOL) do
	v:Remove()
end

_ENTITY_POOL = {}

local WrappedEntityMeta = {}
local AllocCSEntity = nil
local FreeCSEntity = nil

for k, v in pairs( FindMetaTable("Entity") ) do

	WrappedEntityMeta[k] = function(self, ...)
		return v( rawget(self, "Instance"), ...)
	end

end

function ManagedCSEnt( id, model )

	local ent = {}
	ent.Instance = AllocCSEntity( id, model )
	ent.GC = GCHandler( FreeCSEntity, rawget(ent, "Instance") )
	ent.Get = function( self )
		return rawget(self, "Instance")
	end

	local meta = {}
	meta.__index = function( t, k )
		if k == "Get" then return rawget(t, "Get") end
		if k == "ent" then return rawget(t, "Instance") end
		return WrappedEntityMeta[k]
	end

	meta.__newindex = function( t, k, v )
		rawget(t, "Instance")[k] = v
	end

	return setmetatable( ent, meta )

end

AllocCSEntity = function( id, model )

	local entry = tostring(id) .. tostring(model)
	if _ENTITY_POOL[entry] ~= nil then
		_ENTITY_REF_COUNTERS[entry] = _ENTITY_REF_COUNTERS[entry] + 1
		return _ENTITY_POOL[entry]
	end

	local CSEnt = ClientsideModel( model )

	_ENTITY_POOL[entry] = CSEnt
	_ENTITY_REF_COUNTERS[entry] = 1

	return CSEnt

end

FreeCSEntity = function( csent )

	for k,v in pairs( _ENTITY_POOL ) do
		if v == csent then
			if _ENTITY_REF_COUNTERS[k] == 1 then
				print("***FREED CLIENTSIDE ENTITY: " .. tostring(v:GetModel()) .. "***")
				v:Remove()
				table.remove( _ENTITY_POOL, k )
			else
				_ENTITY_REF_COUNTERS[k] = _ENTITY_REF_COUNTERS[k] - 1
			end
			return
		end
	end

end