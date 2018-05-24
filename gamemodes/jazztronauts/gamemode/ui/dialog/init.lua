include("shared.lua")

AddCSLuaFile( "shared.lua")
AddCSLuaFile( "cl_init.lua")
AddCSLuaFile( "cl_styling.lua")

local print = print
local util = util
local net = net
local IsValid = IsValid

module("dialog")

util.AddNetworkString( "dialog_dispatch" )

Init()

local function maybeWrite(ent)
	if IsValid(ent) then
		net.WriteBit( true )
		net.WriteEntity( ent )
	else
		net.WriteBit( false )
	end
end

function Dispatch( script, targets, focus, camera )
	local scriptid = util.NetworkStringToID( script )
	if scriptid == 0 then return false end

	print("SV_Dispatch: '" .. script .. "'")

	net.Start( "dialog_dispatch" )
	net.WriteUInt( scriptid, 16 )
	
	maybeWrite(focus)
	maybeWrite(camera)

	net.Send( targets )

	return true
end