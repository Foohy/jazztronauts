ENT.Type = "brush"
ENT.Base = "base_brush"

local outputs =
{
	"OnInitialBrushStolen",
	"OnBrushStolen",
	"OnThresholdHit",
}

ENT.TriggerThreshold = 1.0
ENT.InitialStolen = false
ENT.ThresholdHit = false

function ENT:Initialize()

	self:SetSolid(SOLID_BBOX)

	-- Hook into when brushes are stolen
	hook.Add("JazzBrushStolen", self, function(self, brushid)
		self:OnBrushStolen(brushid)
	end)

	hook.Add("JazzDisplacementStolen", self, function(self, dispid)
		self:OnDisplacementStolen(dispid)
	end)

	-- Build a list of nearby brushes
	timer.Simple(0, function()
		self:WaitForMapInfo()
	end )
end

-- Wait for the map info to be ready, then grab all the nearby brushes
function ENT:WaitForMapInfo()
	if bsp2.GetCurrent().brushes then
		self:RefreshInsideBrushes()
	else
		hook.Add("JazzSnatchMapReady", self, function()
			self:RefreshInsideBrushes()
		end)
	end
end

function ENT:RefreshInsideBrushes()
	local map = bsp2.GetCurrent()
	if not map.brushes then return end

	self.NearBrushes = {}
	self.NearDisplacements = {}
	for k, v in pairs(map.brushes) do
		if self:ContainsPoint(v.center) then

			-- Skip if not solid
			if bit.band(v.contents, CONTENTS_SOLID) != CONTENTS_SOLID then continue end

			self.NearBrushes[k] = snatch.IsBrushStolen(k)
		end
	end

	-- TODO, calculate NearDisplacements?
end

function ENT:GetInsideBrushes()
	if table.Count(self.NearBrushes) == 0 then
		self:RefreshInsideBrushes()
	end

	return self.NearBrushes
end

function ENT:ContainsPoint(center)
	local min, max = self:WorldSpaceAABB()

	return center:WithinAABox(min, max)
end

function ENT:GetStolenAmount()
	local total, stolen = 0, 0
	for _, v in pairs(self.NearBrushes) do
		total = total + 1
		if v then
			stolen = stolen + 1
		end
	end

	return total, stolen
end

function ENT:OnBrushStolen(brushid)

	-- Check if one of our brushes or already stolen
	if self.NearBrushes[brushid] == nil or self.NearBrushes[brushid] then
		return
	end
	self.NearBrushes[brushid] = true

	self:TriggerOutput("OnBrushStolen")

	-- Check if first stolen
	if not self.InitialStolen then
		self.InitialStolen = true
		self:TriggerOutput("OnInitialBrushStolen")
	end

	-- Check if above threshold
	if not self.ThresholdHit then
		local total, stolen = self:GetStolenAmount()
		--print(total, stolen, stolen * 1.0 / total)
		if stolen * 1.0 / total > self.TriggerThreshold then
			self.ThresholdHit = true
			self:TriggerOutput("OnThresholdHit")
		end
	end
end

function ENT:OnDisplacementStolen(displacementid)

	-- Check if one of our brushes or already stolen
	/*
	if self.NearDisplacements[displacementid] == nil or self.NearDisplacements[displacementid] then
		return
	end
	self.NearDisplacements[displacementid] = true

	self:TriggerOutput("OnBrushStolen")

	-- Check if first stolen
	if not self.InitialStolen then
		self.InitialStolen = true
		self:TriggerOutput("OnInitialBrushStolen")
	end

	-- Check if above threshold
	if not self.ThresholdHit then
		local total, stolen = self:GetStolenAmount()
		--print(total, stolen, stolen * 1.0 / total)
		if stolen * 1.0 / total > self.TriggerThreshold then
			self.ThresholdHit = true
			self:TriggerOutput("OnThresholdHit")
		end
	end
	*/
end

function ENT:KeyValue(key, value)
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end

	if key == "StealThreshold" then
		self.TriggerThreshold = (tonumber(value) or 100) / 100
	end
end


