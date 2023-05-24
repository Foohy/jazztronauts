-- Board that displays currently selected maps
AddCSLuaFile()
AddCSLuaFile("sh_honk.lua")
include("sh_honk.lua")

ENT.Type = "point"

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

function ENT:OnMapChanged(newmap, wsid) 
	local bus = ents.Create( "jazz_bus_hub" )
		bus:SetPos(self:GetPos())
		bus:SetAngles(self:GetAngles())
		bus:SetMap(newmap, wsid or "")
		bus:Spawn()
end
