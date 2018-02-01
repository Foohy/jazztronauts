include( "lib/shared.lua")
include( 'player.lua' )

DeriveGamemode("sandbox")

GM.Name     = "Jazztronauts"
GM.Author   = "Snakefuck Mountain"

team.SetUp( 1, "Jazztronauts", Color( 255, 128, 0, 255 ) )


function GM:PlayerNoClip(ply)
	return mapcontrol.IsInHub() //or true
end

function GM:PhysgunPickup(ply, ent)

    -- Don't let players touch anything spawned by the map
    if ent.CreatedByMap and ent:CreatedByMap() then
        return false
    end

    return self.BaseClass:PhysgunPickup(ply, ent)
end 

function GM:CanProperty(ply, prop, ent)
    if prop == "persist" then return false end

    return self.BaseClass:CanProperty(ply, prop, ent)
end

function GM:CanDrive(ply, ent)
    return mapcontrol.IsInHub()
end