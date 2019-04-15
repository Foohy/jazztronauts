if SERVER then AddCSLuaFile("sh_mesh.lua") end
if SERVER then return end

_MESH_POOL = _MESH_POOL or {}
_MESH_REF_COUNTERS = _MESH_REF_COUNTERS or {}

_MESH_UNIQUE_IDX = _MESH_UNIQUE_IDX or 1

--[[for k,v in pairs(_MESH_POOL) do
	v:Destroy()
end

_MESH_POOL = {}]]

local WrappedMeshMeta = {}
local AllocMesh = nil
local FreeMesh = nil

for k, v in pairs( FindMetaTable("IMesh") ) do

	WrappedMeshMeta[k] = function(self, ...)
		return v( rawget(self, "Instance"), ...)
	end

end

function ManagedMesh( material, id )

	local mesh = {}
	mesh.Instance = AllocMesh( material, id )
	mesh.GC = GCHandler( FreeMesh, rawget(mesh, "Instance") )
	mesh.Get = function( self )
		return rawget(self, "Instance")
	end

	local meta = {}
	meta.__index = function( t, k )
		if k == "Get" then return rawget(t, "Get") end
		if k == "mesh" then return rawget(t, "Instance") end
		return WrappedMeshMeta[k]
	end

	meta.__newindex = function( t, k, v )
		rawget(t, "Instance")[k] = v
	end

	return setmetatable( mesh, meta )

end

function GenerateUniqueID()
	local id = "ManagedMesh_UniqueIDX_" .. _MESH_UNIQUE_IDX .. FrameNumber()
	_MESH_UNIQUE_IDX =_MESH_UNIQUE_IDX + 1
	return id
end

local default_mesh_material = Material( "editor/wireframe" )
AllocMesh = function( material, id )
	if not id then
		id = GenerateUniqueID()
	end
	material = material or default_mesh_material
	local entry = tostring(id) .. tostring(material)
	if _MESH_POOL[entry] ~= nil then
		_MESH_REF_COUNTERS[entry] = _MESH_REF_COUNTERS[entry] + 1
		return _MESH_POOL[entry]
	end

	local mesh = Mesh( material )

	_MESH_POOL[entry] = mesh
	_MESH_REF_COUNTERS[entry] = 1

	return mesh

end

FreeMesh = function( mesh )

	for k,v in pairs( _MESH_POOL ) do
		if v == mesh then
			if _MESH_REF_COUNTERS[k] == 1 then
				--print("***FREED CLIENTSIDE MESH: " .. tostring(v) .. "***")
				v:Destroy()
				_MESH_POOL[k] = nil
			else
				_MESH_REF_COUNTERS[k] = _MESH_REF_COUNTERS[k] - 1
			end
			return
		end
	end

end