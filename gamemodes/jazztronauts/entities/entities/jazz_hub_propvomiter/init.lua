ENT.Type = "point"

util.AddNetworkString("jazz_vomiter_gib")

local randomGibProps = 
{
	"models/props_interiors/Furniture_Vanity01a.mdl",
	"models/props_interiors/Furniture_Desk01a.mdl",
	"models/props_junk/wood_crate001a_damaged.mdl",
	"models/props_junk/wood_pallet001a.mdl",
	"models/props_c17/FurnitureTable001a.mdl"
}

-- How many props to spawn before just throwing broken prop gibs instead
local maxpropsconvar = CreateConVar("jazz_trash_max_props", "2", FCVAR_ARCHIVE, 
	"The maximum number of props per model to spawn from the trash chute before just spawning gibs" )

ENT.VomitVelocity = Vector(0, 0, -200)
function ENT:Initialize()
	//self:VomitNewProps()
end

function ENT:KeyValue( key, value )

	print( "KV: " .. key .. " => " .. tostring(value) .. " [" .. type(value) .. "]" )

end

function ENT:Think()
	for i=1, 1 do
		self:VomitProp()
	end
end

function ENT:VomitNewProps()
	self.SpawnQueue = progress.GetPropCounts()

	-- Store original use counts
	for _, v in pairs(self.SpawnQueue) do 
		v.total = v.collected
	end

	-- Ignore already-spawned props
	for _, v in pairs(ents.GetAll()) do
		local mdl = v:GetModel()
		if v.JazzHubSpawned then
			self:DecrementProp(mdl)
		end
	end
end

function ENT:DecrementProp(model)
	if not self.SpawnQueue or not self.SpawnQueue[model] then return end

	local newCount = self.SpawnQueue[model].collected - 1
	self.SpawnQueue[model].collected = newCount
	
	if newCount <= 0 then 
		self.SpawnQueue[model] = nil
	end
end

function ENT:SpawnRandomGibs(pos, ang)
	local e2 = mapgen.SpawnHubProp(table.Random(randomGibProps), 
		pos, ang)
	e2:GetPhysicsObject():SetVelocity(self.VomitVelocity)
	e2:PrecacheGibs()
	e2:GibBreakClient(self.VomitVelocity)
	e2:Remove()
end

function ENT:VomitProp()
	if not self.SpawnQueue then return end

	local prop = table.Random(self.SpawnQueue)
	if not prop then return end

	local ent = mapgen.SpawnHubProp(prop.propname, 
		self:GetPos() + self:GetAngles():Up() * 100, 
		self:GetAngles()
	)

	ent:GetPhysicsObject():SetVelocity(self.VomitVelocity)

	-- If certain amount of props already exist, spawn gibs instead
	if prop.total - prop.collected >= maxpropsconvar:GetInt() then

		if ent:Health() > 0 then
			ent:PrecacheGibs()
			ent:GibBreakClient(self.VomitVelocity)
		else 
			-- Spawn some placeholder gibs, this prop doesnt normally break
			self:SpawnRandomGibs(ent:GetPos(), ent:GetAngles())
		end

		ent:Remove()
	end

	-- Decrement
	self:DecrementProp(prop.propname)
end

function ENT:AcceptInput( name, activator, caller, data )

	print( "EV: " .. name )

	if name == "Vomit" then self:VomitNewProps( ) return true end

	return false

end
