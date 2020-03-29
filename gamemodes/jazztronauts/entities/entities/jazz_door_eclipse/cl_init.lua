include("shared.lua")

ENT.RenderGroup	= RENDERGROUP_TRANSLUCENT

local AttentionMarker = Material("materials/ui/jazztronauts/wtf.png", "smooth")
surface.CreateFont("BlackShardDoorCount", {
	font = "Palatino Linotype",
	extended = false,
	size = 50,
	weight = 500,
	antialias = false,
	shadow = true,
})

sound.Add( {
	name = "jazz_blackshard_door",
	channel = CHAN_STATIC,
	volume = 0.95,
	level = 65,
	pitch = 30,
	sound = "jazztronauts/blackshard_hum.wav"
} )
ENT.HumSoundPath = "jazz_blackshard_door"
ENT.CandleModel = Model("models/sunabouzu/gameplay_candle.mdl")
ENT.CandleRadiusX = 75
ENT.CandleRadiusY = 50

function ENT:Initialize()
	self.MarkerName = "bad_boy" .. tostring(self)
	worldmarker.Register(self.MarkerName, AttentionMarker, 150)
	worldmarker.Update(self.MarkerName, self:GetPos() + Vector(0, 0, 50))

	-- Number counter
	self.CountMarkerName = "bad_boy_counter" .. tostring(self)
	worldmarker.Register(self.CountMarkerName, AttentionMarker, 150)
	worldmarker.Update(self.CountMarkerName, self:GetPos() + Vector(0, 0, 50))
	worldmarker.SetRenderFunction(self.CountMarkerName, function(scrpos, visible, pos)
		if IsValid(self) then self:RenderCountMarker(scrpos, visible, pos) end
	end)

	-- Spawn candles around as an additional progress indicator
	self:SpawnShardCount()

	self:EmitSound(self.HumSoundPath, 75, 25, 1)
end

function ENT:OnRemove()
	self:StopSound(self.HumSoundPath)
end

function ENT:SpawnShardCount()
	local shardcount = mapgen.GetTotalCollectedBlackShards()
	local required = mapgen.GetTotalRequiredBlackShards()

	if not tobool(newgame.GetGlobal("encounter_1")) then return end
	self.CandleEnts = self.CandleEnts or {}

	for i=1, required do
		local p = i * 1.0 / required
		local ang = 2 * math.pi * p
		local candle = ManagedCSEnt("badboy_candle_" .. i, self.CandleModel)
		candle:SetNoDraw(false)
		candle:SetPos(self:GetPos() + Vector(math.cos(ang) * self.CandleRadiusX, math.sin(ang) * self.CandleRadiusY, -9))

		table.insert(self.CandleEnts, candle)
		
		if shardcount > 0 then
			shardcount = shardcount - 1
			ParticleEffect("jazzCandle", candle:GetPos() + Vector(0, 0, 12), candle:GetAngles(), candle:Get() )
		end
	end
end

function ENT:UpdateWorldMarker()
	local dest = self:GetDestination()
	worldmarker.SetEnabled(self.MarkerName, dest != nil)
	worldmarker.SetEnabled(self.CountMarkerName, self.ShardsCollected and self.ShardsCollected > 0)
end

function ENT:Think()
	self:UpdateWorldMarker()

	self.ShardsCollected = mapgen.GetTotalCollectedBlackShards()
	self.ShardsRequired =  mapgen.GetTotalRequiredBlackShards()

	self:SetNextClientThink(CurTime() + 2)
	return true
end

function ENT:RenderCountMarker(scrpos, visible, pos)
	local dist2 = (EyePos() - pos):LengthSqr()
	local left = self.ShardsRequired - self.ShardsCollected
	visible = visible - dist2 * 0.00000005
	local text = left .. " ◼ Remain" .. (left == 1 and "s" or "")
	draw.SimpleText(text, "BlackShardDoorCount", scrpos.x, scrpos.y, Color(200, 50, 50, visible * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:Draw()
	self:DrawModel()
end