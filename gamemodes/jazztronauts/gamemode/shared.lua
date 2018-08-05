include( "lib/shared.lua")

DeriveGamemode("sandbox")

GM.Name	 = "Jazztronauts"
GM.Author   = "Snakefuck Mountain"

team.SetUp( 1, "Jazztronauts", Color( 255, 128, 0, 255 ) )


CreateConVar("jazz_override_noclip", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY }, "Allow jazztronauts to override when players can noclip. If 0, it is determined by sandbox + whatever other mods you've got.")


function GM:PlayerNoClip(ply)
	if cvars.Bool("jazz_override_noclip", true) then
		return false
	else
		return self.BaseClass.PlayerNoClip(self, ply)
	end
end

local blacklisted = {
	["jazz_shard"]		= true,
	["jazz_shard_black"]  = true,
	["jazz_shard_podium"] = true,
	["jazz_bus_marker"]   = true,
}

function GM:PhysgunPickup(ply, ent)

	-- Don't let players touch anything spawned by the map
	if ent.CreatedByMap and ent:CreatedByMap() then
		return false
	end

	-- Don't let players pick up anything that's in the blacklist
	if blacklisted[ent:GetClass()] then
		return false
	end

	return self.BaseClass:PhysgunPickup(ply, ent)
end

function GM:CanProperty(ply, prop, ent)
	if mapcontrol.IsInGamemodeMap() then return false end
	if prop == "persist" then return false end

	if IsValid(ent) and IsValid(ent:GetParent()) and ent:GetParent():GetClass() == "jazz_bus_explore" then
		return false
	end

	return self.BaseClass:CanProperty(ply, prop, ent)
end

function GM:CanDrive(ply, ent)
	return false
end

-- Shared so we can query on the client too
function GM:JazzCanSpawnWeapon(ply, wep)

	-- Absolutely no spawning in hub
	if mapcontrol.IsInGamemodeMap() then
		return cvars.Bool("jazz_debug_allow_gmspawn")
	end

	-- Weapon must exist
	local wepinfo = list.Get("Weapon")[wep]
	if not wepinfo then return false end

	-- If the weapon is in the store, it must have been unlocked to spawn
	if jstore.GetItem(wep) then

		-- Final check, must have been purchased in the store
		return unlocks.IsUnlocked("store", ply, wep)
	end

	-- Weapon is not in the store, they must have unlocked spawnmenu
	-- OR it's a default jazz weapon
	return wepinfo.Category == "Jazztronauts" or unlocks.IsUnlocked("store", ply, "spawnmenu")
end