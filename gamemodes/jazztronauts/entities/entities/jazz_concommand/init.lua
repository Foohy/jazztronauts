-- Runs concommands without the risk of currupting the vmf
ENT.Type = "point"
ENT.DisableDuplicator = true

function ENT:Initialize()

	self.script = ""

end

function ENT:KeyValue( key, value )

	if key == "Concommand" then self.Concommand = value end

end



function ENT:RunCommand( activator, caller, data )

	RunConsoleCommand(unpack(string.Split(self.Concommand, " ")))

end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "RunCommand" then self:RunCommand( activator, caller, data ) return true end

	return false
end
