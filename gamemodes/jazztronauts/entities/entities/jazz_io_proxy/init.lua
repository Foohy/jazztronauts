ENT.Type = "point"

function ENT:Initialize()

end

function ENT:AcceptInput( name, activator, caller, data )
	local dataidx = tonumber(data)
	local prefix, inputName = unpack(string.Split(name, "_"))

	if dataidx and caller.JazzIOEvents and prefix == "JazzForward" and inputName then
		local outputs = caller.JazzIOEvents[inputName]

		-- Check that we've actually have parsed output data to relay
		if not outputs or #outputs == 0 or not outputs[dataidx] then
			print("No output data for " .. tostring(caller) .. " (" .. name .. ")")
			return
		end

		-- We're provided the index into our stored output data table
		-- Lookup the data based on which specific output linkage we are (multiple outputs can be associated with an output)
		local out = outputs[dataidx].outdata
		if not out then return end

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

		//PrintTable( out )

		//print("FORWARD: " .. tostring( activator ) .. " " .. tostring( caller ) .. " " .. tostring( data ))
		return true
	end

end
