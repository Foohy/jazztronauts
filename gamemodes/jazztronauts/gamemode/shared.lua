include( "lib/shared.lua")

DeriveGamemode("sandbox")

GM.Name    = "Jazztronauts"
GM.Author  = "See Steam Workshop authors"
GM.Email   = "jazzsourcemod@gmail.com"
GM.Website = "https://steamcommunity.com/sharedfiles/filedetails/?id=1452613192"

team.SetUp( 1, "Jazztronauts", Color( 255, 128, 0, 255 ) )

-- Defined here for users to see, functionality is in init.lua
CreateConVar("jazz_player_pvp", "0", { FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY },
	"Allow players to damage each other. Default is 0. When enabled, also enables jazz_player_collide, as hitscan weapons won't function otherwise.")
cvars.AddChangeCallback("jazz_player_pvp", function(_, old, new)
	if tobool(new) == true then
		GetConVar("jazz_player_collide"):SetBool(true)
	end
end )

CreateConVar("jazz_override_noclip", "1", { FCVAR_REPLICATED, FCVAR_NOTIFY }, "Allow jazztronauts to override when players can noclip. If 0, it is determined by sandbox + whatever other mods you've got.")

local devMode = GetConVar("developer")

function GM:GetDevMode()
	return devMode:GetInt()
end

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

if SERVER then

	util.AddNetworkString("death_notice")

	function GM:DoPlayerDeath( ply, attacker, dmg )

		net.Start("death_notice")
		net.WriteEntity( ply )
		net.WriteEntity( attacker )
		net.WriteEntity( dmg:GetInflictor() )
		net.WriteUInt( dmg:GetDamageType(), 32 )
		net.Broadcast()

		GAMEMODE.BaseClass.DoPlayerDeath( self, ply, attacker, dmg )

	end

else

	function GM:DrawDeathNotice(x, y)
		return true
	end

	net.Receive( "shard_notify", function()

		local ply = net.ReadEntity()
		local ev = eventfeed.Create()

		local name = IsValid(ply) and ply:Nick() or "<Player>"

		ev:Title(jazzloc.Localize("jazz.message.shard","%name"),
			{ name = name }
		)

		ev:Body("%total",
			{ total = jazzloc.Localize("jazz.hud.money",jazzloc.AddSeperators(1000)) } --TODO: does this get affected by NG+ multiplier?
		)

		ev:SetHue("rainbow")
		ev:SetHighlighted( ply == LocalPlayer() )
		ev:Dispatch( 15, "top" )
		ev:SetIconModel( Model("models/sunabouzu/jazzshard.mdl") )

	end )

	net.Receive( "death_notice", function()

		print("DEATH NOTICE MESSAGE!")

		local ply = net.ReadEntity()
		local attacker = net.ReadEntity()
		local inflictor = net.ReadEntity()
		local dmg = net.ReadUInt(32)

		local name = IsValid(ply) and ply:Nick() or "<Player>"
		local ev = eventfeed.Create()

		if dmg == DMG_FALL then

			ev:Title(jazzloc.Localize("jazz.death.fall","%name"),
				{ name = name }
			)

		elseif attacker == ply then

			ev:Title(jazzloc.Localize("jazz.death.self","%name"),
				{ name = name }
			)

		elseif IsValid(attacker) then

			ev:Title(jazzloc.Localize("jazz.death.killer","%name","%killer"),
				{ name = name, killer = attacker:GetClass() },
				{ killer = "red_name" }
			)

		else

			ev:Title(jazzloc.Localize("jazz.death.generic","%name"),
				{ name = name }
			)

		end

		ev:SetHighlighted( ply == LocalPlayer() )
		ev:Dispatch( 10, "top" )

	end )

end
