ENT.Type = "brush"
ENT.Base = "base_brush"

local outputs =
{
	"OnEveryoneInside",
	"OnEveryoneNotInside",
	"OnInsideEmpty",
	"OnInsideNotEmpty",
	"OnPlayerEnter",
	"OnPlayerLeave"
}

function ENT:Initialize()

	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)

	self.TouchingEntities = {}

	hook.Add("PlayerInitialSpawn", self, function(ply)
		self:CheckAllIn()
	end )
end

function ENT:KeyValue(key, value)
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end
end

function ENT:CheckAllIn()
	local allIn = player.GetCount() == table.Count(self.TouchingEntities)

	-- Filled vs. not quite-filled
	if allIn and not self.WasAllIn then
		self:TriggerOutput("OnEveryoneInside", ent)
		self.WasAllIn = true
	elseif not allIn and self.WasAllIn then
		self:TriggerOutput("OnEveryoneNotInside", ent)
		self.WasAllIn = false
	end

	-- Exact thing but for the other case, empty/not quite empty
	local allout = table.Count(self.TouchingEntities) == 0
	if allout and not self.WasAllOut then
		self:TriggerOutput("OnInsideEmpty")
		self.WasAllOut = true
	elseif not allout and self.WasAllOut then
		self:TriggerOutput("OnInsideNotEmpty")
		self.WasAllOut = false
	end
end

function ENT:StartTouch(ent)
	if not ent:IsPlayer() then return end
	local idx = ent:EntIndex()

	self.TouchingEntities[idx] = ent
	self:TriggerOutput("OnPlayerEnter", ent)
	self:CheckAllIn()
end

function ENT:EndTouch(ent)
	if not ent:IsPlayer() then return end
	local idx = ent:EntIndex()

	-- if "ent" was a player that just disconnected... that object's table is gone already
	-- so we just use the ent index for now
	self.TouchingEntities[idx] = nil
	self:TriggerOutput("OnPlayerLeave", ent)
	self:CheckAllIn()
end

