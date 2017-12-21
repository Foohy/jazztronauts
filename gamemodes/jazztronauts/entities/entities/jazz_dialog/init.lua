-- Dialog dispatch entity

ENT.Type = "point"
ENT.DisableDuplicator = true

function ENT:Initialize()

	self.script = ""

end

function ENT:KeyValue( key, value )

	print( "KV: " .. key .. " => " .. tostring(value) .. " [" .. type(value) .. "]" )
	if key == "script" then self:SetScript( value ) end
	if key == "camera_reference" then self:SetCameraReference( value ) end
	if key == "spawnflags" then
		self.sendToAllPlayers = bit.band( tonumber(value), 1 ) ~= 0
	end

end

function ENT:SetScript( script )

	print("SCRIPT SET TO: " .. tostring(script))
	self.dialogscript = script

end

function ENT:GetScript()

	return self.dialogscript

end

function ENT:SetCameraReference( target )

	self.cameraReference = ents.FindByName( target )

end

function ENT:GetCameraReference()

	return self.cameraReference

end

function ENT:StartDialog( activator, caller, data )

	local targets = activator

	if self.sendToAllPlayers then
		targets = player.GetAll()
	end

	print("SV_Dispatch_Ent: " .. self:GetScript())

	dialog.Dispatch( self:GetScript(), activator, self:GetCameraReference() )

end

function ENT:StopDialog( activator, caller, data )

end

function ENT:AcceptInput( name, activator, caller, data )

	print( "EV: " .. name )

	if name == "Start" then self:StartDialog( activator, caller, data ) return true end
	if name == "Cancel" then self:StopDialog( activator, caller, data ) return true end

	return false

end
