ENT.Type = "point"

local outputs = {}

function ENT:Initialize()

end

function ENT:SetGlobalState(enabled)
	if not self.GlobalState then return end

	newgame.SetGlobal(self.GlobalState, enabled)
end

function ENT:KeyValue(key, value)
	if key == "globalstate" then
		self.GlobalState = value
	end
end

function ENT:AcceptInput( name, activator, caller, data )
	if name == "TurnOn" then
		self:SetGlobalState(true)
	end

	if name == "TurnOff" then
		self:SetGlobalState(false)
	end

end
