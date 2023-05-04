-- Board that displays currently selected maps
AddCSLuaFile()

ENT.JazzWorth = 1000
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
	sound = "jazztronauts/shard_hum_mono.wav"
} )
sound.Add( {
	name = "jazz_shard_idle_near",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 65,
	sound = "jazztronauts/shard_hum.wav"
} )

game.AddParticles( "particles/jazztronauts_particles.pcf")
PrecacheParticleSystem( "shard_glow" )

ENT.ParticleName = "shard_glow"
ENT.TriggerRadius = 16
ENT.BrushMinDestroyRadius = 64
ENT.BrushMaxDestroyRadius = 300
ENT.BrushDestroyInterval = 0.1
ENT.SnatchMode = 2

ENT.DrawOffset = Vector(0, 0, 0)

ENT.ShardSound = "jazz_shard_idle"
ENT.ShardNearSound = "jazz_shard_idle_near"

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

		-- Build a list of nearby brushes
		timer.Simple(0, function()
			self:WaitForMapInfo()
		end )
	end

	if CLIENT then
		--self:SetMaterial("models/wireframe")
		self.DrawMatrix = Matrix()
		self.StartOffset = math.random(0, 20)

		self:EnsureSound()

		ParticleEffect( self.ParticleName, self:GetPos(), self:GetAngles(), self )
		hook.Add("JazzDrawVoid", self, function(self) self:OnPortalRendered() end )
	end
end

function ENT:CanProperty()
	return false
end

-- Shards should be always networked, even if they're out of the player's PVS
-- Will be necessary if they need help locating them
function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "IsFinished")
	self:NetworkVar("Bool", 0, "Collected")
end

-- Wait for the map info to be ready, then grab all the nearby brushes
function ENT:WaitForMapInfo()
	if bsp2.GetCurrent().brushes then
		self:GetNearbyBrushes()
	else
		hook.Add("JazzSnatchMapReady", self, function()
			self:GetNearbyBrushes()
		end)
	end
end

function ENT:GetTheftTrigger()
	for _, v in pairs(ents.FindByClass("jazz_trigger_theft")) do
		if v:ContainsPoint(self:GetPos()) then return v end
	end

	return nil
end

local function TestSphereAABBOverlap(mins, maxs, center, radius)
	local r2 = radius * radius
	local dmin = 0
	for i=1, 3 do
		if center[i] < mins[i] then dmin = dmin + math.pow(center[i] - mins[i], 2)
		elseif center[i] > maxs[i] then dmin = dmin + math.pow(center[i] - maxs[i], 2) end
	end
	return dmin <= radius * radius
end

function ENT:GetNearbyBrushes()
	local map = bsp2.GetCurrent()
	if !map or !map.brushes then print("SHARDS DIDN'T GRAB BRUSHES - MAP STILL LOADING") return end

	-- Maybe only grab within shard theft trigger
	local trigger = self:GetTheftTrigger()
	limitbrushes = nil
	if IsValid(trigger) then
		limitbrushes = trigger:GetInsideBrushes()
	end

	self.NearBrushes = {}
	local NearbyWorld = {}
	for k, v in pairs(map.brushes) do

		-- Optionally hard limit which brushes we touch
		if limitbrushes and limitbrushes[k] == nil then continue end

		-- Check if our danger sphere encompasses that brush
		if not snatch.removed_brushes[v.id] and v:IntersectsSphere(self:GetPos(), self.BrushMaxDestroyRadius) then
			v:CreateWindings()

			-- Skip if not solid
			if bit.band(v.contents, CONTENTS_SOLID + CONTENTS_OPAQUE + CONTENTS_GRATE) == 0 then continue end

			local info = {
				id = k,
				dist = self:GetPos():Distance((v.min + v.max) / 2),
				type = "brush"
			}

			table.insert(NearbyWorld, info)
		end
	end

	-- Also grab displacements
	for _, v in pairs(map.displacements) do
		if snatch.removed_displacements[v.id] then continue end
		if TestSphereAABBOverlap(v.mins, v.maxs, self:GetPos(), self.BrushMaxDestroyRadius) then
			local info = {
				id = v.id,
				dist = self:GetPos():Distance((v.mins + v.maxs) / 2),
				type = "displacement"
			}

			table.insert(NearbyWorld, info)
		end
	end

	table.SortByMember(NearbyWorld, "dist", true)
	self.NearbyWorld = NearbyWorld
	print("Found ", #self.NearbyWorld .. " nearby brushes/displacements")
end

function ENT:DestroyNearbyBrushesAndSelf(maxdist)
	print("Begin destruction, ", maxdist)
	if not self.NearbyWorld then
		self:GetNearbyBrushes()

		-- If still not valid then exit early
		if not self.NearbyWorld then return end
	end
	

	local pos = self:GetPos()
	local actual = 0
	for k, v in ipairs(self.NearbyWorld) do
		-- Don't continue if we hit the specified max range
		if v.dist > maxdist then break end

		-- Ignore meshes that have already been taken
		local theft_check = v.type == "displacement" and snatch.removed_displacements or snatch.removed_brushes
		if theft_check[v.id] then continue end

		-- Random delay
		timer.Simple(actual * self.BrushDestroyInterval, function()
			local yoink = snatch.New()
			yoink:SetMode(self.SnatchMode)
			if v.type == "displacement" then
				yoink:StartDisplacement( pos, self, v.id )
			else
				yoink:StartWorld( pos, self, v.id )
			end
		end )

		actual = actual + 1
	end

	print("Actually yoinked: " .. actual .. " (" .. (actual * self.BrushDestroyInterval) .. " seconds)")

	-- Call when finished stealing everything
	timer.Simple(actual * self.BrushDestroyInterval, function()
		self:SetIsFinished(true)
		self:OnFinished()
	end )

	self.NearbyWorld = nil
end

function ENT:OnFinished()
	self:Remove()
end

function ENT:Touch(ply)
	if CLIENT or self:GetCollected() or !IsValid(ply) or !ply:IsPlayer() then return end

	self:SetCollected(true)
	GAMEMODE:CollectShard( self, ply )

	local expl = ents.Create( "env_explosion" )
	expl:SetPos(self:GetPos())
	expl:Fire("Explode", 0, 0)

	if SERVER then
		-- Vary the range as they collect shards - bigger by the end
		local numleft, total = mapgen.GetShardCount()
		local maxdist = Lerp(numleft * 1.0 / total, self.BrushMaxDestroyRadius, self.BrushMinDestroyRadius)

		self:DestroyNearbyBrushesAndSelf(maxdist)
	end

	//self:Remove()
end

function ENT:StopIdleSounds()
	if self.IdleSound then
		self.IdleSound:Stop()
		self.IdleSound = nil
	end

	if self.IdleSoundNear then
		self.IdleSoundNear:Stop()
		self.IdleSoundNear = nil
	end
end

function ENT:OnRemove()
	self:StopIdleSounds()
end

if SERVER then return end

function ENT:GetWavyTranslation(t)
	return self:GetAngles():Up() * math.sin(t) * 4
end

-- Make sure the sound plays
function ENT:EnsureSound()
	if not self.IdleSound then
		self.IdleSound = CreateSound(self, self.ShardSound)
		self.IdleSound:Play()
	end

	if not self.IdleSoundNear then
		self.IdleSoundNear = CreateSound(self, self.ShardNearSound)
		self.IdleSoundNear:Play()
	end
end

function ENT:Think()
	self:EnsureSound()

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

function ENT:DrawDynLight()
	local dlight = DynamicLight( self:EntIndex() )
	if dlight then
		dlight.pos = self:GetPos()
		dlight.r = 255
		dlight.g = 255
		dlight.b = 255
		dlight.brightness = 2
		dlight.Decay = 100
		dlight.Size = 256
		dlight.DieTime = CurTime() + 1
	end
end

function ENT:Draw()
	self.DrawMatrix:Identity()

	local t = CurTime() + self.StartOffset
	self.DrawMatrix:Translate(self:GetWavyTranslation(t) + self.DrawOffset)
	self.DrawMatrix:Rotate( Angle(t, math.sin(t/2) * 360, math.cos(t/3) * 360))
	self.DrawMatrix:Scale(Vector(1, 1, 1) +
	Vector(math.sin(t*2.5) * 0.1, math.cos(t*3) * 0.1, math.cos(t*4 + math.pi/2) * 0.1))

	self:EnableMatrix("RenderMultiply", self.DrawMatrix)
	self:DrawModel()

	self:DrawDynLight()
end
