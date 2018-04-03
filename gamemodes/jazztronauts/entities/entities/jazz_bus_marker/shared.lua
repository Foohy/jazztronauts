
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model       = "models/props_trainstation/trainstation_clock001.mdl"

ENT.SpawnDelay = 3
ENT.CircleCone = 3

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "SpawnTime")
    self:NetworkVar("Bool", 0, "IsBeingDeleted")
end

function ENT:CountdownStarted()
    return self:GetSpawnTime() != 0 
end

function ENT:IsLookingAt(pos, eyedir, pfov)
    if self:GetIsBeingDeleted() then return false end
    
	pfov = pfov or 90
	local ang = math.cos(math.rad(self.CircleCone))

    local dir = (self:GetPos() - pos)
	dir:Normalize()

	return eyedir:Dot(dir) >= ang 
end

function ENT:GetSpawnPercent()
    if !self:CountdownStarted() then return 0 end

    return math.Clamp(1 - ( (self:GetSpawnTime() - CurTime()) / self.SpawnDelay), 0, 1)
end

