ENT.Type = "point"

function ENT:Initialize()

end

function ENT:AcceptInput( name, activator, caller, data )
	local prefix, inputName = unpack(string.Split(name, "_"))
	print(name, prefix, inputName)
	if caller.JazzIOEvents and prefix == "JazzForward" and inputName then
		local outputs = caller.JazzIOEvents[inputName]

		-- Check that we've actually have parsed output data to relay
		if not outputs or #outputs == 0 then 
			print("No output data for " .. tostring(caller) .. " (" .. name .. ")")
			return
		end

		-- This output can have multiple outputs, so iterate over each one
		for _, output in pairs(outputs) do
			local out = output.outdata
			if not out then continue end

			-- Go through every entity with a matching name and send an event for it
			for k,v in pairs( ents.FindByName( out[1] or "" ) ) do

				if IsValid(v) and IsValid(caller) then

					local name = v:GetName()
					local target_index = v:MapCreationID() - 1234
					local caller_index = caller:MapCreationID() - 1234 --really garry?


					net.Start( "input_fired" )
						net.WriteInt( target_index, 32 )
						net.WriteInt( caller_index, 32 )
						net.WriteString( out[2] )
						net.WriteFloat( tonumber(out[4]) or 0 )
					net.Send( player.GetAll() )

				end

			end
		end

		//PrintTable( out )

		//print("FORWARD: " .. tostring( activator ) .. " " .. tostring( caller ) .. " " .. tostring( data ))
		return true
	end

end
