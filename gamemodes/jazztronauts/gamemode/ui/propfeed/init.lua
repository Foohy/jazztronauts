
util.AddNetworkString("propcollect")

AddCSLuaFile( "cl_init.lua")

module( "propfeed", package.seeall )

function notify( prop, ply, total )

	local worth = math.random(1,10) * 100

	net.Start( "propcollect" )
	net.WriteString( prop:GetModel() )
	net.WriteUInt( prop:GetSkin(), 16 )
	net.WriteUInt( total or 1, 16 )
	net.WriteUInt( worth, 32 )
	net.WriteEntity( ply )
	net.Send( player.GetAll() )
end
