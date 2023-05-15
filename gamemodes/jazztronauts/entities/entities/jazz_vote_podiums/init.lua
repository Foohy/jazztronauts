ENT.Type = "point"
ENT.Base = "base_anim"

local outputs =
{
	"OnActivated", -- Called when all players have voted and the podiums sink into the ground
	"OnApproached" -- When a player enters the activation range, showing our podiums
}

ENT.ApproachRadius = 500
ENT.PodiumRadius = 50
ENT.PodiumSemiCircle = 2 * math.pi -- Which semicircle angle to spawn podiums in (2pi means all the way around)
ENT.PodiumSemiAngle = nil -- Which angle represents the 'center' of the semicircle to spawn around. If nil, use approach angle

function ENT:Initialize()
	self.podiums = {}
	self:Reset()

	hook.Add("PlayerInitialSpawn", self, function(self, ply)
		self:NewPlayerSpawned(ply)
	end)
end

function ENT:Reset()
	self:ClearPodiums()

	self.podiums = {}
	self.approached = false
end

function ENT:KeyValue(key, value)

	-- Store outputs
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end

	-- Setup data
	if key == "ApproachRadius" then
		self.ApproachRadius = tonumber(value)
	end

	if key == "PodiumRadius" then
		self.PodiumRadius = tonumber(value)
	end

	if key == "Friendly" then
		self.FriendlyPodiums = tobool(value)
	end

end

function ENT:AcceptInput(name, activator, caller, data)
	if name == "Reset" then
		self:Reset()
	end
end

function ENT:OnRemove()
	self:ClearPodiums()

	hook.Remove("PlayerInitialSpawn", self)
end

function ENT:Think()
	self:ThinkPodiums()
	self:NextThink( CurTime() + 1 )

	return true
end

function ENT:StoreActivatedCallback(func)
	self.Callbacks = self.Callbacks or {}
	table.insert(self.Callbacks, func)
end

function ENT:RunActivatedCallbacks()
	if not self.Callbacks then return end

	for _, v in pairs(self.Callbacks) do
		v(self.who_found)
	end

	self.Callbacks = {}
end


function ENT:MakePodium( ply, offset, angles )

	if not SERVER then return end
	if self.podiums[ply] then print( "ALREADY HAS: " .. tostring(ply) ) return end

	local ent = ents.Create("jazz_shard_podium")
	ent:SetPos( self:GetPos() + offset )
	ent:SetAngles( angles or Angle(0,0,0) )
	ent:SetFakeOwner( ply )
	ent:SetFriendly(self.FriendlyPodiums)
	ent:Spawn()

	print("MAKE PODIUM: " .. tostring(ply) .. " : " .. tostring(offset))

	ent.parent = self
	ent.Use = function( self, ply )

		if ply ~= self:GetFakeOwner() then
			self:EmitSound( Sound("buttons/button10.wav") )
			return
		end

		self:Close()
		self.used = true

		self.parent:OnPodiumUsed( self )

	end

	self.podiums[ply] = ent

end

function ENT:OnAllPodiumsUsed()

	for _, ent in pairs( self.podiums ) do

		ent:Lower()

	end

	timer.Simple( 1, function()

		self.BaseClass.Touch( self, self.who_found )
		self:RunActivatedCallbacks()
		self:TriggerOutput("OnActivated", self.who_found)

	end )

	timer.Simple(5, function()
		if not IsValid(self) then return end

		self:ClearPodiums()
		self:Remove()
	end )
end

function ENT:OnPodiumUsed( ent )

	local all_used = true
	for _, ent in pairs( self.podiums ) do

		if not ent.used then all_used = false break end

	end

	if all_used then

		if not IsValid( self.who_found ) then

			local players = player.GetAll()
			self.who_found = players[math.random(1,#players)]

		end

		self:OnAllPodiumsUsed()

	end

end

function ENT:ClearPodiums()

	for _, ent in pairs( self.podiums ) do

		ent:Remove()

	end
	self.podiums = {}

end

function ENT:NewPlayerSpawned(ply)
	if not self.approached then return end

	local function offset(radius, angle)
		return Vector( math.cos(angle) * radius, math.sin(angle) * radius, 0 )
	end

	-- TODO: Eerily move podiums into place?
	local angle = math.Rand(0, 2 * math.pi * (self.PodiumSemiCircle / (math.pi * 2))) + (self.PodiumSemiAngle or 0) - self.PodiumSemiCircle/2
	local ang = Angle( 0, angle * RAD_2_DEG , 0 )
	local off = offset(self.PodiumRadius, angle)

	self:MakePodium(ply, off, ang)
end

function ENT:OnApproached( ply )

	local ply_pos = ply:GetPos()
	local my_pos = self:GetPos()
	local radius = self.PodiumRadius

	self.PodiumSemiAngle = self.PodiumSemiAngle or (math.atan2( ply_pos.y - my_pos.y, ply_pos.x - my_pos.x ) + self.PodiumSemiCircle / 2)

	local base_angle = self.PodiumSemiAngle - self.PodiumSemiCircle / 2
	local angle = base_angle
	local add_angle = (2 * math.pi * (self.PodiumSemiCircle / (math.pi * 2))) / #player.GetAll()
	local delay = 0
	local add_delay = 0.8

	local function get_offset()
		return Vector( math.cos(angle) * radius, math.sin(angle) * radius, 0 )
	end

	self:MakePodium( ply, get_offset(), Angle( 0, angle * RAD_2_DEG, 0 ) )

	for k,v in pairs( player.GetAll() ) do
		if v == ply then continue end

		angle = angle + add_angle
		delay = delay + add_delay

		local offset = get_offset()
		local ang = Angle( 0, angle * RAD_2_DEG, 0 )
		timer.Simple(delay, function()
			self:MakePodium( v, offset, ang )
		end)

	end

	self.who_found = ply

	self:TriggerOutput("OnApproached", self.who_found)
end

function ENT:HandleApproach()

	local approach_dist_sqr = math.pow(self.ApproachRadius, 2)
	local min_dist = approach_dist_sqr
	local who = nil
	for _, ply in pairs( player.GetAll() ) do

		local dist = (ply:GetPos() - self:GetPos()):LengthSqr()
		if dist < min_dist then

			min_dist = dist
			who = ply

		end

	end

	if who ~= nil then

		self:OnApproached( who )
		self.approached = true

	end

end

function ENT:CheckPodiums()

	for k,v in pairs( self.podiums ) do

		if not IsValid(k) then

			if not v.checked then

				v:Close()
				v.used = true
				v.checked = true
				self:OnPodiumUsed( v )

			end

		end

	end

end

function ENT:ThinkPodiums()

	if not self.approached then

		self:HandleApproach()

	else

		self:CheckPodiums()

	end

end
