ENT.Type = "point"

function ENT:Initialize()

end

local function ParseOutput( str )

	if type( str ) ~= "string" then return end

	local args = {}
	for w in string.gmatch(str .. ",","(.-),") do
		table.insert( args, w )
	end

	return args

end

function ENT:AcceptInput( name, activator, caller, data )

	if name == "Forward" then

		data = string.Replace( tostring(data), "FWDCMA", "," )

		local out = ParseOutput( data )

		for k,v in pairs( ents.FindByName( out[1] or "" ) ) do

			timer.Simple( tonumber( out[4] or "0" ), function()

				v:Input( out[2], activator, caller, out[3] )

			end)

			if IsValid(v) and IsValid(caller) then

				local name = v:GetName()
				local target_index = v:MapCreationID() - 1234
				local caller_index = caller:MapCreationID() - 1234 --really garry?

				--print(tostring(caller))

				--[[for k, v in pairs( ents.GetAll() ) do
					if v == caller then
						print( tostring(caller), " ", k, tostring(caller:GetPos()), caller:MapCreationID() - 1234 )
					end
				end]]

				net.Start( "input_fired" )
				net.WriteInt( target_index, 32 )
				net.WriteInt( caller_index, 32 )
				net.WriteString( out[2] )
				net.WriteFloat( tonumber( out[4] or "0" ) )
				net.Send( player.GetAll() )

			end

		end

		PrintTable( out )

		print("FORWARD: " .. tostring( activator ) .. " " .. tostring( caller ) .. " " .. tostring( data ))

	end

end
