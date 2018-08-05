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

	self.BrushMaxDestroyRadius = math.huge
	self.BrushDestroyInterval = 0.04 --0.04
	self.DrawOffset = Vector(0, 0, 50)
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

	-- Vote podium entity
	self.VotePodium = self:CreateVotePodium()

	self.BaseClass.Initialize( self )

	if SERVER then
		self:SetTrigger(false)
	end
end

function ENT:CreateVotePodium()
	if not SERVER then return end

	local votium = ents.Create("jazz_vote_podiums")
	votium:SetPos(self:GetPos())
	votium:SetAngles(self:GetAngles())
	votium:Spawn()
	votium:Activate()
	votium:SetParent(self)
	votium:StoreActivatedCallback(function(who_found)
		self:Touch(who_found)
	end )

	return votium
end

if SERVER then
	function ENT:OnFinished()
		if self.SuckSound then self.SuckSound:Stop() end
		if self.SuckSoundNear then self.SuckSoundNear:Stop() end
	end
end

function ENT:SetupDataTables()
	self.BaseClass.SetupDataTables(self)
	self:NetworkVar("Float", 0, "StartSuckTime")
end

local function StealQuick()
	local map = bsp2.GetCurrent()
	for k, v in pairs(map.brushes) do
		local yoink = snatch.New()
		yoink:SetMode(0)
		yoink:StartWorld( v.center, self, k )
		task.YieldPer(1)
	end
end

function ENT:GetNearbyBrushes()
	local mapinfo = progress.GetMap(game.GetMap())
	if mapinfo and mapinfo.corrupt == progress.CORRUPT_STOLEN then
		task.New(StealQuick, 1)
		self:SetStartSuckTime(CurTime())
		self:SetIsFinished(true)
		self.VotePodium:Remove()
	else
		self.BaseClass.GetNearbyBrushes(self)
	end
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

	if self.SuckSound then self.SuckSound:Stop() end
	if self.SuckSoundNear then self.SuckSoundNear:Stop() end

	if CLIENT then
		jazzvoid.SetOverlayColor(Color(255, 255, 255))
	end

	if IsValid(self.VotePodium) then
		self.VotePodium:Remove()
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
	self.BaseClass.Touch(self, ply)

	-- Player collected black shard, this map is now corrupted
	hook.Run("CollectBlackShard", self, ply)
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
		self:EnsureSound()
		self:ChangePitchThink()

		-- Ramp up screen shake until it hits
		local t = self:GetExplodeTime()
		if t > 0 and t < self.StartDestroyDelay then
			util.ScreenShake(self:GetPos(), t, 5, 0.1, 4096)
		end

		-- Check for when finished so we can ease off effects too
		if not self.StealFinished and self:GetIsFinished() then
			self.StealFinished = true
			self:OnFinished()
		end
	end

	function ENT:OnFinished()
		self.FinishTime = CurTime()
		self.IsFinished = true

		self:StopIdleSounds()

		self:EmitSound("ambient/levels/citadel/portal_beam_shoot3.wav", 120)
		self:EmitSound("npc/scanner/scanner_explode_crash2.wav", 120)
	end

	local eclipseMat = Material("sprites/jazzeclipse")
	function ENT:OnPortalRendered()
		local t = self:GetExplodeTime() - self.StartDestroyDelay
		local ft = self.FinishTime and self.FinishTime - CurTime() or math.huge

		if t > 0 then
			t = CurTime() - t

			if not self.HasExploded then
				self.HasExploded = true

				LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 200), 1.45, 0)
				jazzvoid.void_prop_count = 0
			end

			if self.IsFinished and not self.FinishExploded then
				self.FinishExploded = true
				LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 200), 1.45, 0)
			end

			if not self.IsFinished then

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
			end

			-- Begin changing the overlay tint sprite to be more delightfully devilish
			local _, surfaceMat = jazzvoid.GetVoidOverlay()
			local col = LerpVector(t, Vector(1,1,1), Vector(1.0, 0.60, 0.1))
			col.a = Lerp(t * 0.1, 1, 0.4)
			jazzvoid.SetOverlayColor(col)
		end

		self:DrawModel()
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
			tunnel:SetMaterial("sunabouzu/Jazzlake02")
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

	function ENT:EnsureSound()
		if not self.IsFinished then
			self.BaseClass.EnsureSound(self)
		end
	end

	function ENT:Draw()
		if not self.IsFinished then
			self.BaseClass.Draw(self)
		else
			-- Just make sure the void stays spooky
			local col = Vector(1.0, 0.60, 0.1, 0.4)
			jazzvoid.SetOverlayColor(col)
		end
	end
end