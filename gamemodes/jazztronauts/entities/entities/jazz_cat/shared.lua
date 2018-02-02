AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Model = "models/krio/jazzcat1.mdl"
ENT.NPCID = 0 -- TODO
ENT.IdleAnim = "standerino"
ENT.AutomaticFrameAdvance = true

function ENT:Initialize()

    if SERVER then 
        self:SetModel(self.Model)
        local mins, maxs = self:GetModelBounds()
        self:PhysicsInitBox(mins, maxs)
        self:SetCollisionBounds(mins, maxs)
        self:SetMoveType(MOVETYPE_NONE)

        self:SetUseType(SIMPLE_USE)

        self:SetIdleAnim(self.IdleAnim)
    end

    if CLIENT then

    end
end

function ENT:Think()

end

function ENT:KeyValue( key, value )
	if key == "idleanim" then
		self:StoreOutput(key, value)
	end
end

function ENT:SetIdleAnim(anim)
    self.IdleAnim = anim 

    self:ResetSequence(self:LookupSequence(self.IdleAnim))
    self:SetPlaybackRate(1.0)
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then 
        local script = converse.GetMissionScript(caller, self.NPCID)
        script = dialog.IsValid(script) and script or "idle.begin"
        dialog.Dispatch(script, caller)
    end
end

if SERVER then return end


function ENT:Draw()
    self:DrawModel()
end
