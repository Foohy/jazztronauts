include("player/player_hub.lua")
include("player/player_explore.lua")
include("player/sh_spectate.lua")
include("player/sh_money.lua")

if SERVER then include("player/sql.lua") end

local spawnConVar = CreateConVar("jazz_debug_allow_gmspawn", "0", { FCVAR_REPLICATED, FCVAR_NOTIFY }, "Allow unconditional spawning of props")

-- TODO: Move mechanism to own module
local itemprice = 100
local function SpawnItem(ply, type)
	if spawnConVar:GetBool() then return true end

	if mapcontrol.IsInGamemodeMap() then return false end

	-- Must have spawnmenu unlocked to spawn other items
	if type != 'props' and type != 'sweps' and 
		not unlocks.IsUnlocked("store", ply, "spawnmenu") then
		return false 
	end

	return ply:ChangeNotes(-itemprice)
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnRagdoll( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnRagdoll( ply, model )
	return SpawnItem(ply, "ragdolls")
end


--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnProp( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnProp( ply, model )
	return SpawnItem(ply, "props")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnEffect( ply, model )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnEffect( ply, model )
	return SpawnItem(ply, "effects")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnVehicle( ply, model, vname, vtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnVehicle( ply, model, vname, vtable )
	return SpawnItem(ply, "vehicles")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSWEP( ply, wname, wtable )
   Desc: Return true if it's allowed 
-----------------------------------------------------------]]
function GM:PlayerSpawnSWEP( ply, wname, wtable )
	if not self:JazzCanSpawnWeapon(ply, wname) then return false end

	return SpawnItem(ply, "sweps")
end

-- Disallow gm_giveswep from being usable
function GM:PlayerGiveSWEP( ply, wname, wtable )
	if not self:JazzCanSpawnWeapon(ply, wname) then return false end

	return SpawnItem(ply, "sweps")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnSENT( ply, name )
   Desc: Return true if player is allowed to spawn the SENT
-----------------------------------------------------------]]
function GM:PlayerSpawnSENT( ply, name )
	return SpawnItem(ply, "sents")
end

--[[---------------------------------------------------------
   Name: gamemode:PlayerSpawnNPC( ply, npc_type )
   Desc: Return true if player is allowed to spawn the NPC
-----------------------------------------------------------]]
function GM:PlayerSpawnNPC( ply, npc_type, equipment )
	return SpawnItem(ply, "npcs")
end


-- Hook into when a player spawns _something_ so we can mark it and have it be worthless
local function PlayerSpawnedSomething(ply, ent)
	ent.JazzWorth = 0
end

hook.Add("PlayerSpawnedEffect", "JazzMakeWorthless", function(ply, mdl, ent) PlayerSpawnedSomething(ply, ent) end )
hook.Add("PlayerSpawnedNPC", "JazzMakeWorthless", function(ply, ent) PlayerSpawnedSomething(ply, ent) end )
hook.Add("PlayerSpawnedProp", "JazzMakeWorthless", function(ply, mdl, ent) PlayerSpawnedSomething(ply, ent) end )
hook.Add("PlayerSpawnedRagdoll", "JazzMakeWorthless", function(ply, mdl, ent) PlayerSpawnedSomething(ply, ent) end )
hook.Add("PlayerSpawnedVehicle", "JazzMakeWorthless", function(ply, ent) PlayerSpawnedSomething(ply, ent) end )