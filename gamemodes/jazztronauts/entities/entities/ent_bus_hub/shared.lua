ENT.Type = "anim"
ENT.Base = "base_entity"
 
ENT.PrintName		= "The Bus - Hub"
ENT.Author			= ""
ENT.Information 	= ""
ENT.Category 		= ""
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false

ENT.Model 			= Model( "models/sunabouzu/jazzbus.mdl" )


function ENT:SetupDataTables()
	self:NetworkVar("String", 0, "Destination")
end
