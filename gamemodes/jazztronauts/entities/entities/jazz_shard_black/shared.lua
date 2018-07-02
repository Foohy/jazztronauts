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

sound.Add( {
	name = "jazz_blackshard_suck_near",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 95,
	sound = "jazztronauts/blackshard_suck_near.wav"
} )
sound.Add( {
	name = "jazz_blackshard_suck",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 140,
	sound = "jazztronauts/blackshard_suck_far.wav"
} )

ENT.StartDestroyDelay = 2.9


PrecacheParticleSystem( "jazzEclipseBG" )

//ENT.ParticleName = "jazzEclipseBG"

function ENT:Initialize()

    self.podiums = {}
    self.approached = false

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

    hook.Add("JazzPreDrawVoidSky", self, function() self:OnPreVoidSkyRendered() end)
    hook.Add("JazzPostDrawVoidSky", self, function() self:OnPostVoidSkyRendered() end)
    hook.Add("RenderScreenspaceEffects", self, function() self:OnRenderScreenspaceEffects() end)

    self.BaseClass.Initialize( self )

end

function ENT:MakePodium( ply, offset, angles )

    if not SERVER then return end
    if self.podiums[ply] then print( "ALREADY HAS: " .. tostring(ply) ) return end

    local ent = ents.Create("jazz_shard_podium")
    ent:SetPos( self:GetPos() + offset )
    ent:SetAngles( angles or Angle(0,0,0) )
    ent:SetFakeOwner( ply )
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

function ENT:OnApproached( ply )

    local ply_pos = ply:GetPos()
    local my_pos = self:GetPos()
    local radius = 50
    local add_angle = (2 * math.pi) / #player.GetAll()
    local base_angle = math.atan2( ply_pos.y - my_pos.y, ply_pos.x - my_pos.x )
    local angle = base_angle
    local delay = 0
    local add_delay = 1

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

end

function ENT:HandleApproach()

    local approach_dist = 500
    local approach_dist_sqr = approach_dist*approach_dist
    local min_dist = approach_dist_sqr
    local who = nil
    for _, ply in pairs( player.GetAll() ) do

        local dist = (ply:GetPos() - self:GetPos()):LengthSqr()
        if dist < min_dist then

            min_dist = approach_dist
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

function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "StartSuckTime")
end

function ENT:DestroyNearbyBrushesAndSelf(maxdist)
    self:EmitSound("jazztronauts/blackshard_begin.wav", 120)
    util.ScreenShake(self:GetPos(), 2, 5, self.StartDestroyDelay * 2, 4096)  
    self:SetStartSuckTime(CurTime())

    timer.Simple(self.StartDestroyDelay, function()
        self.BaseClass.DestroyNearbyBrushesAndSelf(self, maxdist)

        util.ScreenShake(self:GetPos(), 8, 8, 2, 4096)
        self:EmitSound("ambient/levels/citadel/portal_beam_shoot3.wav", 120)

        self.SuckSound = CreateSound(self, "jazz_blackshard_suck") 
        self.SuckSound:Play()

        self.SuckSoundNear = CreateSound(self, "jazz_blackshard_suck_near") 
        self.SuckSoundNear:Play()
    end )
end

function ENT:OnRemove()

    self.BaseClass.OnRemove(self)
    self:ClearPodiums()

    if self.SuckSound then self.SuckSound:Stop() end
    if self.SuckSoundNear then self.SuckSoundNear:Stop() end

    if CLIENT then
        local _, surfaceMat = jazzvoid.GetVoidOverlay()
        surfaceMat:SetFloat("$alpha", 1)
        surfaceMat:SetVector("$color", Vector(1, 1, 1))
    end

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

function ENT:Touch(ply)

end

if SERVER then

    function ENT:Think()
        self:ThinkPodiums()
    end

end

if CLIENT then
    function ENT:GetExplodeTime()
        local t = self:GetStartSuckTime() 
        if t <= 0 then return 0 end

        return CurTime() - t
    end

    function ENT:ChangePitchThink()
        if not self.IdleSound or not self.IdleSoundNear then return end
        if self.NextPitchChange and CurTime() < self.NextPitchChange then return end

        local nextChange = math.Rand(0.1, 1)
        local rndPitch = math.random(95, 105)
        self.IdleSound:ChangePitch(rndPitch, nextChange)
        self.IdleSoundNear:ChangePitch(rndPitch, nextChange)

        self.NextPitchChange = CurTime() + nextChange
    end

    function ENT:Think()
        self:ChangePitchThink()

        -- Ramp up screen shake until it hits
        local t = self:GetExplodeTime()
        if t > 0 and t < self.StartDestroyDelay then
            util.ScreenShake(self:GetPos(), t, 5, 0.1, 4096)  
        end
    end

    local eclipseMat = Material("sprites/jazzEclipse")
    function ENT:OnPortalRendered()
        local t = self:GetExplodeTime() - self.StartDestroyDelay
        if t > 0 then
            t = CurTime() - t

            if not self.HasExploded then
                self.HasExploded = true 

                LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 200), 1.45, 0)
                jazzvoid.void_prop_count = 0
            end

            local p = math.EaseInOut(math.min(1, t / 5), 0, 0.9)
            local size = p * 32000
            local pos = self:GetPos()
            pos.z = LocalPlayer():GetPos().z + 10000
            render.SetMaterial(eclipseMat)
            render.DrawSprite(pos, size, size, color_white)

            local core2 = ManagedCSEnt("supercoolcore2", "models/props_combine/combine_citadelcloud001a.mdl")
            core2:SetPos(self:GetPos())
            local ang = (LocalPlayer():EyePos() - self:GetPos()):Angle()
            ang:RotateAroundAxis(ang:Right(), 90)
            ang:RotateAroundAxis(ang:Up(), CurTime() * -400)
            core2:SetAngles(ang)
            core2:SetModelScale(p * 0.05)
            core2:DrawModel()

            ang:RotateAroundAxis(ang:Up(), CurTime() * 300)
            core2:SetAngles(ang)
            core2:SetModelScale(p * 0.10)
            core2:SetupBones()
            core2:DrawModel()

            -- Begin changing the overlay tint sprite to be more delightfully devilish
            local _, surfaceMat = jazzvoid.GetVoidOverlay()
            local col = LerpVector(t, Vector(1,1,1), Vector(1.0, 0.60, 0.1))
            local alpha = Lerp(t * 0.1, 1, 0.2)
            surfaceMat:SetFloat("$alpha", alpha)
	        surfaceMat:SetVector("$color", col)
        end
    end

    function ENT:OnPreVoidSkyRendered()
        local t = self:GetExplodeTime() - self.StartDestroyDelay
        if t > 0 then 
            t = CurTime() - t

            local tunnel = ManagedCSEnt("jazz_snatchvoid_tunnel2", "models/props/jazz_dome.mdl")
			tunnel:SetNoDraw(true)
			tunnel:SetPos(Vector())
			tunnel:SetupBones()
            
            local fade = math.min(1, t * 0.25)
            render.SetBlend(Lerp(fade, 0, 1))
            render.SetColorModulation(1, 0, 0)
			tunnel:SetMaterial("sunabouzu/JazzLake02")
			tunnel:SetAngles(Angle(0, 0, 90))
			tunnel:DrawModel()
            render.SetColorModulation(1, 1, 1)

            -- Fade out the default skybox too
            render.SetBlend(Lerp(fade, 1, 0)) 
        end
    end

    function ENT:OnPostVoidSkyRendered()
        render.SetBlend(1.0)
    end

    function ENT:OnRenderScreenspaceEffects()
        local t = self:GetExplodeTime()
        //t = CurTime() % self.StartDestroyDelay
        local p = 0.96
        local distScale = t <= 0 and 0.001 or 0.0005
        //p = p * math.Clamp(EyePos():Distance(self:GetPos()) * distScale, 0, 1)

        -- Blinding fade in for explosion
        if t < self.StartDestroyDelay then
            p = p - (t/self.StartDestroyDelay) * 0.5
        else 
            p = 0.78
        end

        cam.Start3D()
        local pos = self:GetPos():ToScreen()
        cam.End3D()

        local x = math.Clamp(pos.x / ScrW(), 0, 1)
        local y = math.Clamp(pos.y / ScrH(), 0, 1)
        
        DrawSunbeams( p, 1.3 - p, 0.5, x, y )

        if t < self.StartDestroyDelay then      
            DrawBloom( 0.85, (t/self.StartDestroyDelay) * 4, 9, 9, 1, 1, 1, 0.14, 0.14)
        end
    end

    function ENT:Draw()
        self.BaseClass.Draw(self)
    end
end