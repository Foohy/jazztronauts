include("shared.lua")

AddCSLuaFile( "shared.lua")
AddCSLuaFile( "cl_init.lua")

local print = print
local util = util
local net = net

module("dialog")

util.AddNetworkString( "dialog_dispatch" )

Init()

function Dispatch( script, targets, camera )


	print("SV_Dispatch: '" .. script .. "'")

	net.Start( "dialog_dispatch" )
	net.WriteUInt( util.NetworkStringToID( script ), 16 )

	if camera ~= nil then
		net.WriteBit( true )
		net.WriteEntity( camera )
	else
		net.WriteBit( false )
	end

	net.Send( targets )

end