AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "map/mapcontrol.lua")

AddCSLuaFile( "cl_hud.lua" )
include( "shared.lua" )
include("map/mapcontrol.lua")

function GM:Initialize()
	self.BaseClass:Initialize()

	RunConsoleCommand("sv_loadingurl", "http://host.foohy.net/public/Documents/Jazz/index.html")
end

function GM:InitPostEntity()

	physenv.SetGravity( Vector(0,0,0) )

end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn(ply)
end

function GM:PlayerSpawn( ply )

	self.BaseClass:PlayerSpawn(ply)

	ply:SetNoCollideWithTeammates(true)

	local col = ply:GetInfo( "cl_playercolor" )
	ply:SetPlayerColor( Vector( col ) )
	ply:SetNotes(6969)
end


function GM:PlayerNoClip( ply )
	return true
end

function GM:BroadcastMessage( message )

	for _, ply in pairs(player.GetAll()) do
		ply:ChatPrint(message)
	end

end
