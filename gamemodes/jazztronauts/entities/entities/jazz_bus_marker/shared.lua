
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model       = "models/Combine_Helicopter/helicopter_bomb01.mdl"

ENT.SpawnDelay = 3

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "SpawnTime")
end

function ENT:CountdownStarted()
    return self:GetSpawnTime() != 0 
end

function ENT:GetSpawnPercent()
    if !self:CountdownStarted() then return 0 end

    return math.Clamp(1 - ( (self:GetSpawnTime() - CurTime()) / self.SpawnDelay), 0, 1)
end

