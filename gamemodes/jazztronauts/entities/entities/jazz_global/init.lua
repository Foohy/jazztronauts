ENT.Type = "point"

local outputs = { "OnMapSpawn" }

function ENT:Initialize()
	self:TriggerOutput("OnMapSpawn", self, mapcontrol.GetNextEncounter())
end

function ENT:KeyValue(key, value)
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end