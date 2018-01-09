
util.AddNetworkString("propcollect")

AddCSLuaFile( "cl_init.lua")

module( "propfeed", package.seeall )

function notify( prop, ply )
	net.Start( "propcollect" )
	net.WriteString( prop:GetModel() )
	net.WriteUInt( prop:GetSkin(), 16 )
	net.WriteEntity( ply )
	net.Send( player.GetAll() )
end