include("player/player_hub.lua")
include("player/player_explore.lua")


-- TODO: Move mechanism to own module
local itemprice = 100
local function SpawnItem(ply, model, type)
	if ply:GetNotes() < itemprice then
		return false
	end

	ply:SetNotes(ply:GetNotes() - itemprice)
	return true
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnRagdoll( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnRagdoll( ply, model )
	return SpawnItem(ply, model, "ragdolls")
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnProp( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnProp( ply, model )
	return SpawnItem(ply, model, "props")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnEffect( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnEffect( ply, model )
	return SpawnItem(ply, model, "effects")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnVehicle( ply, model, vname, vtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnVehicle( ply, model, vname, vtable )
	return SpawnItem(ply, model, "vehicles")
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnSWEP( ply, wname, wtable )
	return SpawnItem(ply, model, "sents")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSENT( ply, name )
   Desc: Return true if player is allowed to spawn the SENT
-----------------------------------------------------------]]
function GM:PlayerSpawnSENT( ply, name )
	return SpawnItem(ply, model, "sents")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnNPC( ply, npc_type )
   Desc: Return true if player is allowed to spawn the NPC
-----------------------------------------------------------]]
function GM:PlayerSpawnNPC( ply, npc_type, equipment )
	return SpawnItem(ply, model, "npcs")
end