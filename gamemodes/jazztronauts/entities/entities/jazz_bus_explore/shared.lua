ENT.Type = "anim"
ENT.Base = "base_entity"
 
ENT.PrintName		= "The Bus - World"
ENT.Author			= ""
ENT.Information 	= ""
ENT.Category 		= ""
ENT.Spawnable 		= false
ENT.AdminSpawnable 	= false

ENT.Model 			= Model( "models/sunabouzu/jazzbus.mdl" )
ENT.HalfLength 		= 300
ENT.JazzSpeed		= 1250 -- How fast to explore the jazz dimension

function ENT:SetupDataTables()

end

function ENT:GetFront()
	return self:GetPos() + self:GetAngles():Right() * self.HalfLength
end

function ENT:GetRear()
	return self:GetPos() + self:GetAngles():Right() * -self.HalfLength
end