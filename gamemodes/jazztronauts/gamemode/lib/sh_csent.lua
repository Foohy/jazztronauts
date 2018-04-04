if SERVER then AddCSLuaFile("sh_csent.lua") end
if SERVER then return end

_ENTITY_POOL = _ENTITY_POOL or {}
_ENTITY_REF_COUNTERS = _ENTITY_REF_COUNTERS or {}

--[[for k,v in pairs(_ENTITY_POOL) do
	v:Remove()
end

_ENTITY_POOL = {}]]

local WrappedEntityMeta = {}
local AllocCSEntity = nil
local FreeCSEntity = nil

for k, v in pairs( FindMetaTable("Entity") ) do

	WrappedEntityMeta[k] = function(self, ...)
		return v( rawget(self, "Instance"), ...)
	end

end

function ManagedCSEnt( id, model, ragdoll )

	local ent = {}
	ent.Instance = AllocCSEntity( id, model, ragdoll )
	ent.GC = GCHandler( FreeCSEntity, rawget(ent, "Instance") )
	ent.Get = function( self )
		return rawget(self, "Instance")
	end
	ent.IsValid = function(self)
		return IsValid(self.Instance)
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

AllocCSEntity = function( id, model, ragdoll )

	local entry = tostring(id) .. tostring(model) .. tostring(ragdoll)
	if _ENTITY_POOL[entry] ~= nil then
		_ENTITY_REF_COUNTERS[entry] = _ENTITY_REF_COUNTERS[entry] + 1
		return _ENTITY_POOL[entry]
	end

	local CSEnt = nil
	if not ragdoll then
		CSEnt = ClientsideModel( model )
	else
		CSEnt = ClientsideRagdoll( model )
	end

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
				_ENTITY_POOL[k] = nil
			else
				_ENTITY_REF_COUNTERS[k] = _ENTITY_REF_COUNTERS[k] - 1
			end
			return
		end
	end

end