-- Runs concommands without the risk of currupting the vmf
ENT.Type = "point"
ENT.DisableDuplicator = true

function ENT:Initialize()

end

function ENT:KeyValue( key, value )
	if key == "level" then self.Level = value end
end


function ENT:ChangeLevel( activator, caller, data )
	mapcontrol.Launch(self.Level)
end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "ChangeLevel" then self:ChangeLevel( activator, caller, data ) return true end

	return false
end
