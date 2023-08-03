-- Board that displays currently selected maps
AddCSLuaFile()
AddCSLuaFile("sh_honk.lua")
include("sh_honk.lua")

ENT.Type = "point"
ENT.TravelTime = 2.5
ENT.LeadUp = 2000
ENT.TravelDist = 4500

function ENT:Initialize()

	-- Hook into map change events
	if SERVER then
		hook.Add("JazzMapRandomized", self, function(self, newmap, wsid)
			if self.LastMap != newmap then
				self.LastMap = newmap

				if self.LastMap then
					self:OnMapChanged(newmap, wsid)
				end
			end
		end )
	end
end

function ENT:KeyValue(key, value)
	if key == "traveltime" then
		self.TravelTime = tonumber(value)
	elseif key == "leadup" then
		self.LeadUp = tonumber(value)
	elseif key == "traveldist" then
		self.TravelDist = tonumber(value)
	end
end

function ENT:OnMapChanged(newmap, wsid) 
	local bus = ents.Create( "jazz_bus_hub" )
		bus:SetPos(self:GetPos())
		bus:SetAngles(self:GetAngles())
		bus:SetMap(newmap, wsid or "")
		bus.TravelTime = self.TravelTime
		bus.LeadUp = self.LeadUp
		bus.TravelDist = self.TravelDist
		bus:Spawn()
end
