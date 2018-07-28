include("shared.lua")

ENT.RenderGroup 	= RENDERGROUP_TRANSLUCENT

local AttentionMarker = Material("materials/ui/jazztronauts/yes.png", "smooth")
surface.CreateFont("BlackShardDoorCount", {
	font = "Palatino Linotype",
    extended = false,
    size = 50,
    weight = 500,
    antialias = false,
    shadow = true,
})

function ENT:Initialize()
	self.MarkerName = "bad_boy" .. tostring(self)
	worldmarker.Register(self.MarkerName, AttentionMarker, 50)
	worldmarker.Update(self.MarkerName, self:GetPos() + Vector(0, 0, 50))

	-- Number counter
	self.CountMarkerName = "bad_boy_counter" .. tostring(self)
	worldmarker.Register(self.CountMarkerName, AttentionMarker, 50)
	worldmarker.Update(self.CountMarkerName, self:GetPos() + Vector(0, 0, 130))
	worldmarker.SetRenderFunction(self.CountMarkerName, function(scrpos, visible, pos)
		if IsValid(self) then self:RenderCountMarker(scrpos, visible, pos) end
	end)
end


function ENT:UpdateWorldMarker()
	local dest = self:GetDestination()
	worldmarker.SetEnabled(self.MarkerName, dest != nil)
	worldmarker.SetEnabled(self.CountMarkerName, self.ShardsCollected != nil and self.ShardsCollected > 0)
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
	visible = visible - dist2 * 0.0000005
	local text = self.ShardsCollected .. "/" .. self.ShardsRequired .. "◼"
	draw.SimpleText(text, "BlackShardDoorCount", scrpos.x, scrpos.y, Color(200, 50, 50, visible * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function ENT:Draw()
	self:DrawModel()
end