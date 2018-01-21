include("sql.lua")
include("mapcontrol.lua")
include("mapgen.lua")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "mapgen.lua" )
AddCSLuaFile( "mapcontrol.lua" )

concommand.Add("jazz_rollmap", function(ply, cmd, args, argstr)
    if mapcontrol.IsInHub() then
        mapcontrol.RollMap()
    end
end )