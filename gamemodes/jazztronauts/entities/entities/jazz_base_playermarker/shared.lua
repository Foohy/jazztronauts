AddCSLuaFile()


ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model	   = "models/weapons/bus_summoner_marker.mdl"

ENT.RemoveDelay = 0.5

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Progress")
	self:NetworkVar("Float", 1, "Speed")
	self:NetworkVar("Int", 0, "NumPlayers")
	self:NetworkVar("Bool", 0, "IsBeingDeleted")
end

function ENT:IsCountdownStarted()
	return self.GetSpeed and self:GetSpeed() > 0
end

function ENT:GetSpawnPercent()
	if !self:IsCountdownStarted() then return 0 end

	return math.Clamp(self:GetProgress(), 0, 1)
end

function ENT:ProgressThink()
	if not self.GetProgress or not self.GetSpeed then return end

	local prog = self:GetProgress() + self:GetSpeed() * FrameTime()
	self:SetProgress(math.Clamp(prog, 0, 1))
end

if CLIENT then
	function ENT:Think()
		self:ProgressThink()
	end
end

if SERVER then
	function ENT:Initialize()
		self:SetModel(self.Model)
		self:PhysicsInitSphere( 16 )
		self:SetMoveType(MOVETYPE_NONE)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)

		self:PhysWake()

		self.PlayerList = {}
	end

	function ENT:RegisterOnActivate(cb)
		self.Callbacks = self.Callbacks or {}
		table.insert(self.Callbacks, cb)
	end

	function ENT:UpdateTransmitState()
		return TRANSMIT_ALWAYS
	end

	function ENT:AddPlayer(ply)
		if table.HasValue(self.PlayerList, ply) then return end

		table.insert(self.PlayerList, ply)
		self:CheckPlayerCount()

		-- Do one iteration right on spawn
		if #self.PlayerList == 1 then
			self:Think()
		end
	end

	function ENT:RemovePlayer(ply)
		table.RemoveByValue(self.PlayerList, ply)
		self:CheckPlayerCount()
	end

	local function filterByPredicate(tbl, func)
		for i=#tbl, 1, -1 do
			if func(tbl[i]) then
				table.remove(tbl, i)
			end
		end
	end

	function ENT:RemoveInvalid()
		filterByPredicate(self.PlayerList, function(ply)
			return !self:ValidPlayer(ply)
		end )
	end


	function ENT:CheckPlayerCount()
		self:RemoveInvalid()

		self:SetNumPlayers(#self.PlayerList)

		if #self.PlayerList == 0 then
			self:StartRemove()
		end
	end

	function ENT:Think()
		if self:GetIsBeingDeleted() then return end

		self:CheckPlayerCount()
		self:UpdateSpeed()

		if self:GetSpeed() > 0 then
			self:ProgressThink()

			if self:GetProgress() >= 1 then
				self:ActivateMarker()
				self:StartRemove()
			end
		end

		self:NextThink(CurTime())
		return true
	end

	function ENT:StartRemove()
		if self:GetIsBeingDeleted() then return end

		self:SetIsBeingDeleted(true)
		SafeRemoveEntityDelayed(self, self.RemoveDelay)
	end

	-- Override these
	function ENT:ActivateMarker()
		if self.Callbacks then
			for _, v in pairs(self.Callbacks) do
				v()
			end
		end

		self.Callbacks = {}
	end

	function ENT:ValidPlayer(ply)
		return IsValid(ply) and ply:Alive()
	end

	function ENT:HasEnoughPlayers()
		return #self.PlayerList >= 1
	end

	function ENT:UpdateSpeed()
		self:SetSpeed(self:HasEnoughPlayers() and 1 or 0)
	end
end