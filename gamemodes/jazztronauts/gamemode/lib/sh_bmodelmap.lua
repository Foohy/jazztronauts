-- Manage the mapping of spawned entities to their
-- corresponding indices/bmodels within the map file itself

AddCSLuaFile()

module( "bmodelmap", package.seeall )

-- Contains a mapping of bmodelindex => entities with that bmodel
local modelMapping = {}

local function getBModelIdx(ent)
	if not IsValid(ent) then return end

	local model = ent:GetModel()
	if not model then return end

	local split = string.Split(model, "*")
	if #split != 2 then return end
	local num = split and tonumber(split[2]) or nil

	return num
end

-- Retrieve the bmodel index of the specified entity
-- Returns nil if it does not have a bmodel
function GetBModel(ent)
	return getBModelIdx(ent)
end

-- Returns a list of entities with the given bmodel
function GetEntity(bmodelidx)
	return modelMapping[bmodelidx]
end

local function mapEntity(ent)
	local idx = getBModelIdx(ent)
	if idx then
		modelMapping[idx] = modelMapping[idx] or {}
		modelMapping[idx][ent:EntIndex()] = ent
	end
end

local function unmapEntity(ent)
	local idx = getBModelIdx(ent)
	if idx and modelMapping[idx] then
		modelMapping[idx][ent:EntIndex()] = nil

		-- Remove table entry entirely if empty
		if table.Count(modelMapping[idx]) == 0 then
			modelMapping[idx] = nil
		end
	end
end

local function mapAll()
	modelMapping = {}
	for _, v in pairs(ents.GetAll()) do
		mapEntity(v)
	end

end

-- On startup, create a mapping of all spawned props
hook.Add("InitPostEntity", "JazzBModelMapInit", function()
	mapAll()
end )

hook.Add("OnReloaded", "JazzBModelMapInit", function()
	mapAll()
end )


-- Hook into when entities are created and destroyed to maintain the association
-- with dynamically spawned ents with bmodels
-- Additionally, for clients these are created as the entities come into our PVS and are networked
hook.Add("OnEntityCreated", "JazzBModelMapper", function(ent)
	mapEntity(ent)
end )
hook.Add("OnEntityRemoved", "JazzBModelUnmapper", function(ent)
	unmapEntity(ent)
end )
