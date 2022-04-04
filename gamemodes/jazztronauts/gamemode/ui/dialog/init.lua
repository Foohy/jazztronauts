include("shared.lua")
include("sh_dialogcmds.lua")

AddCSLuaFile( "shared.lua")
AddCSLuaFile( "cl_init.lua")
AddCSLuaFile( "cl_dialog.lua")
AddCSLuaFile( "cl_styling.lua")
AddCSLuaFile( "cl_styling_horror.lua")
AddCSLuaFile( "sh_dialogcmds.lua")
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

local function maybeWrite(ent)
	if IsValid(ent) then
		net.WriteBit( true )
		net.WriteEntity( ent )
	else
		net.WriteBit( false )
	end
end

function Dispatch( script, targets, focus, camera )
	local scriptid = ScriptIDFromName( script )
	if not scriptid or scriptid == 0 then
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
	local script = NameFromScriptID(scriptid)

	hook.Call("JazzDialogFinished", GAMEMODE, ply, script, markseen)
end )

hook.Add("Initialize", "JazzDialogInitiailize", function()
	-- To reduce network usage on exploration maps (where there is no dialog), don't bother running dialog system
	-- TODO: Implement a caching system so scripts aren't redownloaded every map change
	if mapcontrol.IsInGamemodeMap() then
		Init()
	end
end )