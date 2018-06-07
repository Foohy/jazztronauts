if true then return end

include("shared.lua")

AddCSLuaFile( "shared.lua")
AddCSLuaFile( "cl_init.lua")

util.AddNetworkString("teleportme")

net.Receive("teleportme", function(len, pl)
	local where = net.ReadVector()
	print("TELEPORT: " .. tostring(where))
	pl:SetPos( where )
end)