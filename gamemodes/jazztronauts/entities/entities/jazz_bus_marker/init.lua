AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function ENT:Initialize()
	self.BaseClass.Initialize(self)
end

function ENT:ValidPlayer(ply)
	if !IsValid(ply) then return false end

	local w = ply:GetWeapon("weapon_buscaller")
	return IsValid(w) and w:GetBusMarker() == self
end

function ENT:HasEnoughPlayers()
	return #self.PlayerList > player.GetCount() / 2
end

function ENT:ActivateMarker()
	mapcontrol.SpawnExitBus(self:GetPos(), self:GetAngles())
end

function ENT:UpdateSpeed()
	self:SetSpeed(self:HasEnoughPlayers() and 1/3 or 0)
end
