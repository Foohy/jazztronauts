-- Dialog dispatch entity

ENT.Type = "point"
ENT.DisableDuplicator = true

function ENT:Initialize()
	//self:VomitNewProps()
end

function ENT:KeyValue( key, value )

	print( "KV: " .. key .. " => " .. tostring(value) .. " [" .. type(value) .. "]" )

end

function ENT:Think()
	for i=1, 2 do
		self:VomitProp()
	end
end

function ENT:VomitNewProps()
	self.SpawnQueue = progress.GetPropCounts()

	-- Ignore already-spawned props
	for _, v in pairs(ents.GetAll()) do
		local mdl = v:GetModel()
		if v.JazzHubSpawned then
			self:DecrementProp(mdl)

			-- Immediately indicate we want to gib this prop
			if self.SpawnQueue[mdl] then
				self.SpawnQueue[mdl].inWorld = true
			end
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

	local ent = mapgen.SpawnHubProp(prop.propname, 
		self:GetPos() + self:GetAngles():Up() * 200, 
		self:GetAngles()
	)
	-- If prop already exists, spawn gibs instead
	if prop.inWorld then
		ent:PrecacheGibs()
		ent:GibBreakServer(Vector(0))
		ent:Remove()
	else
		-- Indicate we should only spawn gibs from now on
		self.SpawnQueue[prop.propname].inWorld = true
	end

	-- Decrement
	self:DecrementProp(prop.propname)
end

function ENT:AcceptInput( name, activator, caller, data )

	print( "EV: " .. name )

	if name == "Vomit" then self:VomitNewProps( ) return true end

	return false

end
