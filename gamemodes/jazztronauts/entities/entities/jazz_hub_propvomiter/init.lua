-- Dialog dispatch entity

ENT.Type = "point"
ENT.DisableDuplicator = true

function ENT:Initialize()
	self:VomitNewProps()
end

function ENT:KeyValue( key, value )

	print( "KV: " .. key .. " => " .. tostring(value) .. " [" .. type(value) .. "]" )

end

function ENT:Think()
	self:VomitProp()
end

function ENT:VomitNewProps()
	self.SpawnQueue = progress.GetPropCounts()

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

function ENT:VomitProp()
	if not self.SpawnQueue then return end

	local prop = table.Random(self.SpawnQueue)
	if not prop then return end

	mapgen.SpawnHubProp(prop.propname, 
		self:GetPos() + self:GetAngles():Up() * 200, 
		self:GetAngles()
	)

	-- Decrement
	self:DecrementProp(prop.propname)
end

function ENT:AcceptInput( name, activator, caller, data )

	print( "EV: " .. name )

	if name == "Vomit" then self:VomitNewProps( ) return true end

	return false

end
