include( "lib/shared.lua")

DeriveGamemode("sandbox")

GM.Name    = "Jazztronauts"
GM.Author  = "See Steam Workshop authors"
GM.Email   = "jazzsourcemod@gmail.com"
GM.Website = "https://steamcommunity.com/sharedfiles/filedetails/?id=1452613192"

team.SetUp( 1, "Jazztronauts", Color( 255, 128, 0, 255 ) )


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
	return wepinfo.Category == "#jazz.weapon.category" or unlocks.IsUnlocked("store", ply, "spawnmenu")
end

if SERVER then

	util.AddNetworkString("death_notice")

	function GM:DoPlayerDeath( ply, attacker, dmg )
		local weapon = nil
		if attacker:IsNPC() then weapon = attacker:GetWeapons()[1] end
		net.Start("death_notice")
		net.WriteEntity( ply )
		net.WriteEntity( attacker )
		net.WriteString( attacker:GetClass()) --sending attacker class separately lets us still get it if it's a server-only entity
		net.WriteString( attacker:GetName()) --name is only available on server, so grab it now
		net.WriteEntity( dmg:GetInflictor() )
		net.WriteEntity( weapon )
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
			{ total = jazzloc.Localize("jazz.hud.money",jazzloc.AddSeperators(1000 * newgame.GetMultiplier())) }
		)

		ev:SetHue("rainbow")
		ev:SetHighlighted( ply == LocalPlayer() )
		ev:Dispatch( 15, "top" )
		ev:SetIconModel( Model("models/sunabouzu/jazzshard.mdl") )

	end )

	--get a table of all the damage types that made up this damage
	local function getDamageTypes(dmg)
		
		local damtab = {}
		if dmg == DMG_GENERIC then
			table.insert(damtab,"0")
		else
			--loop through our options. Damage types are stored bitwise, so we're going 2^loopcount to compare
			for var = 0, 31 do
				local dmgtype = math.pow(2,var)
				if bit.band(dmg,dmgtype) > 0 then
					table.insert(damtab,tostring(dmgtype))
				end
			end
		end

		return damtab
	end

	net.Receive( "death_notice", function()

		print("DEATH NOTICE MESSAGE!")

		local ply = net.ReadEntity()
		local attacker = net.ReadEntity()
		local attackclass = net.ReadString()
		if attackclass == "" and IsValid(attacker) then attackclass = attacker:GetClass() end
		local attackname = net.ReadString() or "" --namely for specific Jazztronauts entities
		local inflictor = net.ReadEntity()
		local weapon = net.ReadEntity()
		local dmg = net.ReadUInt(32)

		local name = IsValid(ply) and ply:Nick() or "<Player>"
		local ev = eventfeed.Create()

		--tripped on a cloud and fell eight miles high
		if dmg == DMG_FALL then

			ev:Title(jazzloc.Localize("jazz.death.fall","%name"), 
				{ name = name }
			)
		--not likely to show up unless HL2 suit is on
		elseif dmg == DMG_DROWN then

			ev:Title(jazzloc.Localize("jazz.death.drown","%name"), 
				{ name = name }
			)
		--trust no one, not even yourself
		elseif attacker == ply then

			ev:Title(jazzloc.Localize("jazz.death.self","%name"), 
				{ name = name }
			)
		--jazztronauts specific
		elseif attackname == "prop_killer" then

			ev:Title(jazzloc.Localize("jazz.death.propchute","%name"), 
				{ name = name }
			)

		elseif attackname == "lasermurder" then

			ev:Title(jazzloc.Localize("jazz.death.selector","%name"), 
				{ name = name }
			)

		--agh, you've killed me!
		elseif IsValid(attacker) or attackclass ~= "" then

			local damtab = getDamageTypes(dmg)
			local killedby = jazzloc.Localize(attackclass)

			--projectiles
			if IsValid(inflictor) and inflictor ~= attacker then
				killedby = jazzloc.Localize("jazz.death.weapon",jazzloc.Localize(attackclass),jazzloc.Localize(inflictor:GetClass()))
			--weapons
			elseif IsValid(weapon) then
				killedby = jazzloc.Localize("jazz.death.weapon",jazzloc.Localize(attackclass),jazzloc.Localize(weapon:GetClass()))
			end
			--put it all together, with picking a random damage type from the list
			ev:Title(jazzloc.Localize("jazz.death.killer","%name",jazzloc.Localize("dmg." .. damtab[ math.random( #damtab ) ] ),"%killer"), 
				{ name = name, killer = killedby },
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