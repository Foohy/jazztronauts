-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.Models			= 
{
    "models/sunabouzu/jazzshard.mdl",
}

sound.Add( {
	name = "jazz_shard_idle",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 80,
	pitch = { 95, 110 },
	sound = "jazztronauts/shard_hum_mono.wav"
} )
sound.Add( {
	name = "jazz_shard_idle_near",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 65,
	pitch = { 95, 110 },
	sound = "jazztronauts/shard_hum.wav"
} )

game.AddParticles( "particles/jazztronauts_particles.pcf") 
PrecacheParticleSystem( "shard_glow" )

ENT.TriggerRadius = 16

function ENT:Initialize()

    if SERVER then 
        local maxs = Vector(1,1,1) * self.TriggerRadius

        self:SetModel( table.Random(self.Models))
        self:PhysicsInitSphere( self.TriggerRadius )
        self:SetMoveType(MOVETYPE_NONE)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        self:SetCollisionBounds(-maxs, maxs)

        self:SetTrigger(true)
        self:PhysWake()
    end

    

    if CLIENT then
        --self:SetMaterial("models/wireframe")
        self.DrawMatrix = Matrix()
        self.StartOffset = math.random(0, 20)

        self.IdleSound = CreateSound(self, "jazz_shard_idle") 
        self.IdleSound:Play()

        self.IdleSoundNear = CreateSound(self, "jazz_shard_idle_near") 
        self.IdleSoundNear:Play()

        ParticleEffect( "shard_glow", self:GetPos(), self:GetAngles(), self )
        hook.Add("JazzDrawVoid", self, self.OnPortalRendered)
    end
end

-- Shards should be always networked, even if they're out of the player's PVS
-- Will be necessary if they need help locating them
function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end


function ENT:Touch(ply)
    if CLIENT or self.Collected or !IsValid(ply) or !ply:IsPlayer() then return end

    self.Collected = true
    GAMEMODE:CollectShard( self, ply )

    local expl = ents.Create( "env_explosion" )
	expl:SetPos(self:GetPos())
	expl:Fire("Explode", 0, 0)

    self:Remove()
end

function ENT:OnRemove()
    if self.IdleSound then
        self.IdleSound:Stop()
        self.IdleSound = nil 
    end

    if self.IdleSoundNear then
        self.IdleSoundNear:Stop()
        self.IdleSoundNear = nil
    end
end

if SERVER then return end

function ENT:GetWavyTranslation(t)
    return self:GetAngles():Up() * math.sin(t) * 4
end

function ENT:Think()
    local origin = self:GetWavyTranslation(CurTime() + self.StartOffset) + self:GetPos()
    origin = LocalPlayer():GetPos()
    local ed = EffectData()
    ed:SetScale(1)
    ed:SetMagnitude(3)
	ed:SetEntity( self)
    util.Effect( "TeslaHitboxes", ed, true, true )

    self:SetNextClientThink(CurTime() + math.random(0.1, 0.2))
end

function ENT:OnPortalRendered()
    self:DrawModel()
end

function ENT:Draw()
    self.DrawMatrix:Identity()

    local t = CurTime() + self.StartOffset
    self.DrawMatrix:Translate(self:GetWavyTranslation(t))
    self.DrawMatrix:Rotate( Angle(t, math.sin(t/2) * 360, math.cos(t/3) * 360))
    self.DrawMatrix:Scale(Vector(1, 1, 1) + 
    Vector(math.sin(t*2.5) * 0.1, math.cos(t*3) * 0.1, math.cos(t*4 + math.pi/2) * 0.1))

    self:EnableMatrix("RenderMultiply", self.DrawMatrix)
    self:DrawModel()

    local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 1000
		dlight.Size = 256
		dlight.DieTime = CurTime() + 1
    end
end
