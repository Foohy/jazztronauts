AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE

ENT.Model = "models/krio/jazzcat1.mdl"
ENT.NPCID = 0 -- TODO

function ENT:Initialize()

    if SERVER then 
        self:SetModel(self.Model)
        local mins, maxs = self:GetModelBounds()
        self:PhysicsInitBox(mins, maxs)
        self:SetMoveType(MOVETYPE_NONE)
    end

    if CLIENT then

    end
end


function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then 
        local script = converse.GetMissionScript(caller, self.NPCID)
        script = script or "idle.begin"
        dialog.Dispatch(script, caller)
    end
end

if SERVER then return end

function ENT:Draw()
    self:DrawModel()
end
