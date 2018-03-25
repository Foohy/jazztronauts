-- Board that displays currently selected maps
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "jazz_shard"
ENT.RenderGroup = RENDERGROUP_OPAQUE

sound.Add( {
	name = "jazz_blackshard_idle",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 80,
	sound = "jazztronauts/blackshard_hum_mono.wav"
} )
sound.Add( {
	name = "jazz_blackshard_idle_near",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 65,
	sound = "jazztronauts/blackshard_hum.wav"
} )


PrecacheParticleSystem( "jazzEclipseBG" )

//ENT.ParticleName = "jazzEclipseBG"

function ENT:Initialize()
    self.BrushMaxDestroyRadius = math.huge
    self.BrushDestroyInterval = 0.04 --0.04
    self.RemoveDelay = 5
    self.Models = 
    {
        "models/sunabouzu/jazzblackshard.mdl",
    }
    self.SnatchMode = 3 -- Suck towards shard

    self.ShardSound = "jazz_blackshard_idle"
    self.ShardNearSound = "jazz_blackshard_idle_near"

    self.BaseClass.Initialize( self )
end

function ENT:DrawDynLight()
    local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 40
		dlight.b = 20
		dlight.brightness = 5
		dlight.Decay = 0
		dlight.Size = math.abs(math.sin(CurTime()*2)) * 30 + 128
		dlight.DieTime = CurTime() + 1
    end
end

if CLIENT then
    function ENT:Think()
        if not self.IdleSound or not self.IdleSoundNear then return end
        local nextChange = math.Rand(0.1, 1)
        local rndPitch = math.random(95, 105)
        self.IdleSound:ChangePitch(rndPitch, nextChange)
        self.IdleSoundNear:ChangePitch(rndPitch, nextChange)

        self:SetNextClientThink(CurTime() + nextChange)
    end

end