ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName		= "The Bus - World"
ENT.Author			= ""
ENT.Information	= ""
ENT.Category		= ""
ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Model			= Model( "models/matt/jazz_trolley.mdl" )
ENT.HalfLength		= 300
ENT.JazzSpeed		= 800 -- How fast to explore the jazz dimension

ENT.RadioMusicName = "jazztronauts/music/que_chevere_radio_loop.wav"
ENT.RadioModel = "models/props_lab/citizenradio.mdl"

ENT.VoidMusicName = "jazztronauts/music/que_chevere_travel_fade.mp3"
ENT.VoidMusicPreroll = 2.9 -- how many seconds it takes to get to the chorus
ENT.VoidMusicFadeStart = 12.0
ENT.VoidMusicFadeEnd   = 19.0

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "BreakTime")
end

function ENT:GetFront()
	return self:GetPos() + self:GetAngles():Right() * self.HalfLength
end

function ENT:GetRear()
	return self:GetPos() + self:GetAngles():Right() * -self.HalfLength
end

function ENT:CanProperty()
	return false
end