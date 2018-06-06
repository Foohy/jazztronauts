
ENT.Type = "anim"
ENT.Base = "jazz_base_playermarker"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Model       = "models/props_trainstation/trainstation_clock001.mdl"

ENT.ActivateDelay = 3
ENT.CircleCone = 3

function ENT:IsLookingAt(pos, eyedir, pfov)
    if self:GetIsBeingDeleted() then return false end
    
	pfov = pfov or 90
	local ang = math.cos(math.rad(self.CircleCone))

    local dir = (self:GetPos() - pos)
	dir:Normalize()

	return eyedir:Dot(dir) >= ang 
end
