include("shared.lua")

AddCSLuaFile( "shared.lua")
AddCSLuaFile( "cl_init.lua")
AddCSLuaFile( "cl_dialog.lua")
AddCSLuaFile( "cl_styling.lua")
AddCSLuaFile( "cl_styling_horror.lua")
AddCSLuaFile( "cl_dialogcmds.lua")
AddCSLuaFile( "cl_debug.lua")

local print = print
local util = util
local net = net
local IsValid = IsValid
local tostring = tostring
local ErrorNoHalt = ErrorNoHalt
local hook = hook
local GAMEMODE = GM

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
	if scriptid == 0 then 
		ErrorNoHalt("Invalid script \"" .. script .. "\"!")
		return false 
	end

	print("SV_Dispatch: '" .. script .. "'")

	net.Start( "dialog_dispatch" )
	net.WriteUInt( scriptid, 16 )
	
	maybeWrite(focus)
	maybeWrite(camera)

	net.Send( targets )

	return true
end

-- Received when a client tells us they've finished a script
net.Receive("dialog_dispatch", function(len, ply)
	local scriptid = net.ReadUInt(16)
	local markseen = net.ReadBit() == 1

	--TODO: Broadcast on dialog finished event?
	local script = util.NetworkIDToString(scriptid)

	hook.Call("JazzDialogFinished", GAMEMODE, ply, script, markseen)
end )