

ENT.Type = "point"

function ENT:Initialize()
	self.TeleportRadius = self.TeleportRadius or 0
end

function ENT:MovePlayers()
	local players = player.GetAll()
	for k, v in pairs(players) do
		local p = k * 1.0 / #players
		local offset = self:GetAngles():Forward()
		offset:Rotate(Angle(0, p * 360, 0))
		v:SetPos(self:GetPos() + offset * self.TeleportRadius)
		v:SetEyeAngles(self:GetAngles())
	end
end

function ENT:KeyValue( key, value )
	if key == "TeleportRadius" then
		self.TeleportRadius = tonumber(value) or 0
	end
end

function ENT:AcceptInput( name, activator, caller, data )
	if name == "MovePlayers" then
		self:MovePlayers()
		return true
	end

	return false
end