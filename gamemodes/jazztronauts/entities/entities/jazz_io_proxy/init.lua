ENT.Type = "point"

function ENT:Initialize()

end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "JazzForward" then

		local event, num = tostring(data):match("([%w_]+)_(%d+)")

		if event and num then

			local graph = bsp2.GetCurrent().iograph
			hook.Call("IOEventTriggered", 
				GAMEMODE,
				graph:GetByIndex(tonumber(num)), 
				event )

		end

		return true

	end

end
