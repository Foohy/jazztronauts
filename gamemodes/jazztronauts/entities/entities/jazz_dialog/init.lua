-- Dialog dispatch entity

ENT.Type = "point"
ENT.DisableDuplicator = true

local outputs =
{
	"OnPlayerFinished",
	"OnEveryoneFinished"
}

function ENT:Initialize()

	self.script = ""

	-- Handle if players disconnect mid-dialog so we aren't waiting on them
	hook.Add( "player_disconnect", self, function(self, data )
		self:PlayerEndDialog(data.userid and Player(data.userid))
	end )

	hook.Add("JazzDialogFinished", self, function(self, ply, script, markseen)
		self:PlayerEndDialog(ply, script, markseen)
	end )

end

function ENT:KeyValue( key, value )

	if key == "script" then self:SetScript( value ) end
	if key == "camera_reference" then self:SetCameraReference( value ) end
	if key == "spawnflags" then
		self.sendToAllPlayers = bit.band( tonumber(value), 1 ) ~= 0
	end

	-- Store outputs
	if table.HasValue(outputs, key) then
		self:StoreOutput(key, value)
	end

end

function ENT:SetScript( script )
	self.dialogscript = script
end

function ENT:GetScript()

	return string.lower(self.dialogscript)

end

function ENT:SetCameraReference( target )

	self.cameraReference = ents.FindByName( target )

end

function ENT:GetCameraReference()

	return self.cameraReference

end

function ENT:SetFinishedCallback(callback)
	self.FinishedCallback = callback
end

function ENT:IsDialogActive(target)
	return self.ActivePlayers and self.ActivePlayers[target:SteamID64() or "0"]
end

function ENT:StartDialog( activator, caller, data )

	local targets = { activator }

	if self.sendToAllPlayers then
		targets = player.GetHumans()
	end

	print("SV_Dispatch_Ent: " .. self:GetScript())

	self.ActivePlayers = self.ActivePlayers or {}
	for _, v in ipairs(targets) do
		if v:IsBot() then continue end
		if self:IsDialogActive(v) then continue end
		
		dialog.Dispatch( self:GetScript(), v, self:GetCameraReference() )
		self.ActivePlayers[v:SteamID64() or "0"] = true
	end
end

-- Called when a player is no longer in a dialog started from this entity
-- If dialog is null, they disconnected mid-dialog
function ENT:PlayerEndDialog(ply, dialogName, markseen)
	if not self.ActivePlayers then return end

	-- Ended dialog only if they ended _this_ dialog (or left the server)
	if dialogName and dialogName != self:GetScript() then return end

	local oldCount = table.Count(self.ActivePlayers)
	local ply64 = IsValid(ply) and (ply:SteamID64() or "0")
	if IsValid(ply) and self.ActivePlayers[ply64] then
		self.ActivePlayers[ply64] = nil
		self:TriggerOutput("OnPlayerFinished", ply)
	end

	-- Remove NULL players, just in case they slipped through
	for k, v in pairs(self.ActivePlayers) do
		local p = player.GetBySteamID64(k)
		if not IsValid(p) then self.ActivePlayers[k] = nil end
	end

	-- If we're not waiting on any more players, fire off event that everyone finished
	if oldCount > 0 and table.Count(self.ActivePlayers) == 0 then
		self:TriggerOutput("OnEveryoneFinished", self)
		if self.FinishedCallback then self.FinishedCallback() end
	end
end

function ENT:StopDialog( activator, caller, data )

end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Start" then self:StartDialog( activator, caller, data ) return true end
	if name == "Cancel" then self:StopDialog( activator, caller, data ) return true end

	return false

end

