module( 'mapgen', package.seeall )

SpawnedShards = SpawnedShards or {}
InitialShardCount = InitialShardCount or 0

local shardsNeededConVar = CreateConVar("jazz_total_shards", 100, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The total number of shards needed to finish the game. Cannot be changed in-game.")
local blackShardsNeededConVar = CreateConVar("jazz_total_black_shards", 10, { FCVAR_ARCHIVE, FCVAR_REPLICATED }, "The total number of shards needed to finish the game. Cannot be changed in-game.")

local shardTblName = "jazznetplyshards"
local propTblName = "jazznetplyprops"

if SERVER then
	nettable.Create(shardTblName, nettable.TRANSMIT_AUTO, 1.0)
	nettable.Create(propTblName, nettable.TRANSMIT_AUTO, 1.0)
end

-- No two shards can ever be closer than this
local MinShardDist = 500

function GetShardCount()
	return table.Count(SpawnedShards), InitialShardCount
end

function GetTotalCollectedShards()
	return (nettable.Get("jazz_shard_info") or {})["collected"] or 0
end

function GetTotalRequiredShards()
	return shardsNeededConVar:GetInt()
end

function GetTotalGeneratedShards()
	return (nettable.Get("jazz_shard_info") or {})["total"] or 0
end

function GetTotalCollectedBlackShards()
	return nettable.Get("jazz_shard_info")["corrupted_collected"] or 0
end

function GetTotalRequiredBlackShards()
	return blackShardsNeededConVar:GetInt()
end

function GetPlayerShards()
	return nettable.Get(shardTblName)
end

function GetPlayerProps()
	return nettable.Get(propTblName)
end

function GetShards()
	return SpawnedShards
end

local AcceptEntClass = {
	["npc_antlion_grub"] = true,
	["npc_grenade_frag"] = true,
	["prop_combine_ball"] = true,
	["jazz_static_proxy"] = true,
	["physics_cannister"] = true,
	["hunter_flechette"] = true,
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["prop_physics_respawnable"] = true,
	["prop_dynamic"] = true,
	["prop_dynamic_override"] = true,
	["prop_ragdoll"] = true,
	["prop_door_rotating"] = true,
	--let's get esoteric wee
	["gmod_tool"] = true,
	["gmod_camera"] = true,
	["simple_physics_prop"] = true, --created by phys_convert
	["helicopter_chunk"] = true,
	["grenade_helicopter"] = true,
	["gib"] = true,
	["rpg_missile"] = true,
	["apc_missile"] = true,
	["npc_grenade_bugbait"] = true;
	["phys_magnet"] = true,
	["prop_ragdoll_attached"] = true,
	["gmod_wire_hoverdrivecontroler"] = true,
	["weapon_striderbuster"] = true,
	["npc_satchel"] = true, --SLAM
	["npc_tripmine"] = true, --SLAM
	["grenade_ar2"] = true,
	["combine_mine"] = true,
	["env_headcrabcanister"] = true,
	["prop_thumper"] = true,
}

local IgnoreEntClass = {
	["weapon_propsnatcher"] = true
}

function CanSnatch(ent)

	--Accept only this kinda stuff
	if not IsValid(ent) or not ent:IsValid() then return false end

	local ent_class = ent:GetClass()

	-- Always return false for these class types.
	if IgnoreEntClass[ent_class] then return false end

	-- Assume this flag on this flag becomes a thing
	if ent.IgnoreForSnatch then return false end

	-- Weapons held by players
	if ent:IsWeapon() and IsValid(ent:GetParent()) and ent:GetParent():IsPlayer() then return false end

	-- Local player weapons
	if CLIENT and ent:IsWeapon() and ent:IsCarriedByLocalPlayer() then return false end

	-- Everything that's parented to the bus itself.
	if IsValid(ent:GetParent()) and string.find(ent:GetParent():GetClass(), "jazz_bus_") then return false end

	-- Vote podium
	if ent_class == "prop_dynamic" and IsValid(ent:GetParent()) and ent:GetParent():GetClass() == "jazz_shard_podium" then return false end

	-- Good bye Dr. Kleiner...
	if ent:IsNPC() then return true end

	-- Certain specific class names to be checked.
	if string.find(ent_class, "weapon_") ~= nil then return true end
	if string.find(ent_class, "prop_vehicle") ~= nil then return true end
	if string.find(ent_class, "item_") ~= nil then return true end

	--Weapons not using "weapon_" in their name
	if ent:IsWeapon() then return true end

	-- ???
	-- if string.find(ent_class, "jazz_bus_") ~= nil then return true end
	-- if ent:IsPlayer() and ent:Alive() then return true end -- you lost your privileges

	return AcceptEntClass[ent_class]

end

if SERVER then
	util.AddNetworkString("jazz_shardcollect")
	local function updatePlayerCollectedShards()
		local mapfilter = not mapcontrol.IsInGamemodeMap() and game.GetMap() or nil
		local allShards = progress.GetMapShards(mapfilter)
		local shardPlyTable = {}
		for _, v in pairs(allShards) do
			if tobool(v.collected) and v.collect_player then
				shardPlyTable[v.collect_player] = shardPlyTable[v.collect_player] or 0
				shardPlyTable[v.collect_player] = shardPlyTable[v.collect_player] + 1
			end
		end
		PrintTable(shardPlyTable)
		nettable.Set(shardTblName, shardPlyTable)
	end

	function CollectShard(ply, shardent)

		-- It's gotta be one of our shards ;)
		local res = table.RemoveByValue(SpawnedShards, shardent, ply)
		if not res then return nil, nil end

		progress.CollectShard(game.GetMap(), shardent.ShardID, ply)
		UpdateShardCount()

		return #SpawnedShards, InitialShardCount
	end

	function CollectProp(ply, ent)
		if !CanSnatch(ent) then return nil end

		local worth = ent.JazzWorth or 1
		return worth
	end

	function CollectBlackShard(ent)
		local mapinfo = progress.GetMap(game.GetMap())
		if not mapinfo or mapinfo.corrupt == progress.CORRUPT_NONE then return false end

		progress.SetCorrupted(game.GetMap(), progress.CORRUPT_STOLEN)
		return true
	end

	function UpdateShardCount(ply)
		updatePlayerCollectedShards()

		net.Start("jazz_shardcollect")
			net.WriteUInt(#SpawnedShards, 16)
			for _, v in pairs(SpawnedShards) do
				net.WriteEntity(v)
			end

			net.WriteUInt(InitialShardCount, 16)
		if IsValid(ply) then net.Send(ply) else net.Broadcast() end
	end

	local function checkAreaTrace(pos, ang)
		local mask = bit.bor(MASK_SOLID, CONTENTS_PLAYERCLIP, CONTENTS_SOLID, CONTENTS_GRATE)
		local traces = {}
		local tdist = 1000000
		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Up() * tdist,
			mask = mask
		}))

		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Up() * -tdist,
			mask = mask
		}))

		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Right() * tdist,
			mask = mask
		}))

		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Right() * -tdist,
			mask = mask
		}))

		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Forward() * tdist,
			mask = mask
		}))

		table.insert(traces, util.TraceLine( {
			start = pos,
			endpos = pos + ang:Forward() * -tdist,
			mask = mask
		}))

		local num = 0
		for _, v in pairs(traces) do num = num + (v.HitSky and 1 or 0) end

		-- If more than 3 cardinal directions are skybox
		-- this might be some utility entity the player can't reach
		if num >= 3 then return false end

		-- Ensure there's enough space for a player to grab this from different sides
		local minBounds = 32
		local areaUp = (traces[1].Fraction + traces[2].Fraction) * tdist
		local areaFwd = (traces[3].Fraction + traces[4].Fraction) * tdist
		local areaRight = (traces[5].Fraction + traces[6].Fraction) * tdist
		if (areaUp < minBounds or areaFwd < minBounds or areaRight < minBounds) then return false end

		return true
	end

	-- Return true if the value has any matching flags
	local function maskAny(val, ...)
		local args = {...}
		for k, v in pairs(args) do
			if bit.band(val, v) == v then return true end
		end

		return false
	end

	-- Return true if the entity will spawn within a trigger teleport
	-- This usually makes it impossible to get to
	local function isWithinTrigger(ent)
		local pos = ent:GetPos()
		local tps = ents.FindByClass("trigger_teleport*")
		for _, v in pairs(tps) do
			local min = v:LocalToWorld(v:OBBMins())
			local max = v:LocalToWorld(v:OBBMaxs())

			if pos:WithinAABox(min, max) then
				return true
			end
		end

		return false
	end

	local spawnpoints = {
		"info_player_start",
		"info_player_deathmatch",
		"info_player_rebel",

		"info_player_counterterrorist",
		"info_player_terrorist",

		"info_player_axis",
		"info_player_allies",

		"gmod_player_start",

		"info_player_teamspawn",
		"ins_spawnpoint",
		"aoc_spawnpoint",
		"dys_spawn_point",
		"info_player_pirate",
		"info_player_viking",
		"info_player_knight",
		"diprip_start_team_blue",
		"diprip_start_team_red",
		"info_player_red",
		"info_player_blue",
		"info_player_coop",
		"info_player_human",
		"info_player_zombie",
		"info_player_zombiemaster",
		"info_survivor_position",
	}

	-- Entities that facilitate transporting players
	local teleports = {
		["trigger_teleport"] = "target",
		["jazz_door"] = "TeleportName",
		["theater_door"] = "TeleportName",

		-- some maps use these for cutscenes, let them override?
		--["point_teleport"] = "", -- itself is the point
	}

	local function getPotentialPlayerPositions()
		local positions = {}

		-- Spawnpoints
		for _, pt in pairs(spawnpoints) do
			for _, v in pairs(ents.FindByClass(pt)) do
				positions[#positions + 1] = v:GetPos()
			end
		end

		-- Teleports
		for name, dest in pairs(teleports) do
			for _, ent in pairs(ents.FindByClass(name)) do
				-- No destination keyvalue, so itself is the destination
				if #dest == 0 then
					positions[#positions + 1] = ent:GetPos()
				else
					local destName = ent:GetKeyValues()[dest] or ent[dest]
					if not destName or #destName == 0 then continue end

					-- Add in all destination ents with matching name
					for _, v in pairs(ents.FindByName(destName)) do
						positions[#positions + 1] = v:GetPos()
					end
				end
			end
		end

		return positions
	end

	local function getPositionLeafs(map)
		local positions = getPotentialPlayerPositions()
		local leaves = {}

		for _, v in pairs(positions) do
			local leaf = map:GetLeaf( v )
			if not leaf or leaves[leaf] then continue end
			leaves[leaf] = true
		end

		return table.GetKeys(leaves)
	end

	-- Check if this shard is actually reachable by the player at all
	-- There must be some sort of connecting leaf between the player and shard
	local function isPlayerReachable(ent, map, leafs)
		local function checkLeaf(l)
			return bit.band(l.contents, CONTENTS_SOLID + CONTENTS_GRATE + CONTENTS_WINDOW + CONTENTS_DETAIL + CONTENTS_PLAYERCLIP) == 0
		end

		local shard_leaf = map:GetLeaf( ent:GetPos() )
		for _, v in pairs(leafs) do
			if map:AreLeafsConnected(shard_leaf, v, checkLeaf) then
				return true
			end
		end

		return false
	end

	local function findValidSpawn(ent, map, leafs)
		local pos = ent:GetPos() + Vector(0, 0, 16)

		-- If moving the entity that small amount up puts it out of the world -- nah
		if not util.IsInWorld(pos) then return nil end

		-- If the point is inside something solid -- also nah
		if maskAny(util.PointContents(pos), CONTENTS_PLAYERCLIP, CONTENTS_SOLID, CONTENTS_GRATE) then return end

		-- Don't spawn inside a trigger_teleport either
		if isWithinTrigger(ent) then return end

		-- Check if they're near a suspicious amount of sky
		if not checkAreaTrace(pos, ent:GetAngles()) then return end

		-- Goal spot must be reachable from the players
		-- disabled for now, seems to a little fucky on certain maps but it does work 99% of the time
		--if not isPlayerReachable(ent, map, leafs) then return end

		return { pos = pos, ang = ent:GetAngles() }
	end

	local function isInSkyBox(ent)
		if ent:GetClass() == "sky_camera" then return true end

		local skycam = ents.FindByClass("sky_camera")
		if #skycam == 0 then return false end -- Map has no skybox

		return skycam[1]:TestPVS(ent)
	end

	local function spawnShard(transform, id)
		if transform == nil then return nil end

		local shard = ents.Create( "jazz_shard" )
		shard:SetPos(transform.pos)
		shard:SetAngles(transform.ang)

		shard.ShardID = id
		shard:Spawn()
		shard:Activate()

		return shard
	end

	-- Calculate the size of this map and how many shards it's worth
	function CalculateShardCount()
		local curmap = bsp2.GetCurrent()
		if not curmap then return 8 end -- ??

		local winfo = curmap.entities and curmap.entities[1]
		if not winfo then return 8 end

		local maxs, mins = Vector(winfo.world_maxs), Vector(winfo.world_mins)

		-- Calculate only length across the area, ignoring Z because people make bigass fucking skyboxes
		local length = math.sqrt(math.pow(maxs.x - mins.x,2) + math.pow(maxs.y - mins.y,2))
		print(length)
		-- Shard count dependent on map size
		local shardcount = math.Remap(length, 8000, 100000, 4, 24)
		return math.ceil(shardcount)
	end

	function CalculatePropValues(mapWorth)
		local props = ents.GetAll()
		local counts = {}
		local function getKey(ent) return ent:GetClass() .. "_" .. (ent:GetModel() or "") end

		for _, v in pairs(props) do
			if not CanSnatch(v) then continue end

			local k = getKey(v)
			counts[k] = counts[k] or 0
			counts[k] = counts[k] + 1
		end

		PrintTable(counts)

		for _, v in pairs(props) do
			local count = counts[getKey(v)]
			if not count then continue end

			local worth = (mapWorth / table.Count(counts)) / count
			v.JazzWorth = math.max(1, worth)
		end

	end

	function GetSpawnPoint(ent, map, leafs)
		if !IsValid(ent) or !ent:CreatedByMap() then return nil end
		if isInSkyBox(ent) then return nil end -- god wouldn't that suck

		return findValidSpawn(ent, map, leafs)
	end


	local hullMin = Vector(-20, -20, 0)
	local hullMax = Vector(20, 20, 50)


	-- Just do a shitload of traces in an attempt to find a plausible center to the room
	local function tryBlackShard(pos)

		-- Dumb drop to floor check
		local trDrop = util.TraceHull({
			start = pos,
			endpos = pos + Vector(0, 0, -1) * 1000000,
			mins = hullMin,
			maxs = hullMax
		})

		-- Check height?

		if trDrop.StartSolid then return nil end
		if trDrop.HitNonWorld then return nil end

		return trDrop.HitPos
	end

	-- Depending on the map, there might be certain entities that automatically
	-- Make for great shard spawn locations. These will take preference over
	-- the default shard generation algorithm
	function GetPreferredSpawns(seed)
		local prefix = string.Split(game.GetMap(), "_")[1]
		return hook.Call("JazzGetShardSpawnOverrides", GAMEMODE, prefix, seed)
	end

	local function minDistance2(posang, postbl)
		local mindist = math.huge
		for _, v in pairs(postbl) do
			if v == posang then continue end
			mindist = math.min(mindist, (posang.pos - v.pos):LengthSqr())
		end

		return mindist
	end

	local function sharditer(seed, preferredSpawns)
		local validSpawns = {}
		preferredSpawns = preferredSpawns or {}
		local entIter = nil
		local c = 0

		-- Set up generator seed + ent random pairs iter
		math.randomseed(seed)
		entIter, entState = RandomPairs(ents.GetAll())
		prefIter, prefState = RandomPairs(preferredSpawns)

		-- Build a list of possible bsp leaves the player might start in
		local map = bsp2.GetCurrent()
		local leafs = getPositionLeafs(map)

		return function()
			local posang = nil

			-- Try spawning a 'preferred' shard first
			local _, pref = prefIter(prefState)
			if pref then
				c = c + 1
				posang = pref
			end

			-- For normal shards, go randomly through map ents to find random spawns
			-- Not all entities have a valid spawn, so go until we find one (or run out)
			while not posang do

				-- Grab a random entity
				local _, ent = entIter(entState)
				if not ent then break end
				if not IsValid(ent) then continue end

				-- Find it's corresponding spawn point
				local newposang = GetSpawnPoint(ent, map, leafs)
				if not newposang then continue end

				-- Ensure it's not next to a previously spawned shard
				local mindist2 = MinShardDist^2
				if minDistance2(newposang, preferredSpawns) > mindist2 and
				   minDistance2(newposang, validSpawns) > mindist2
				then
					posang = newposang
					c = c + 1
					break
				end
			end

			-- Store as valid spawn
			table.insert(validSpawns, posang)

			-- Give them the next-found shard position
			if posang then return c, posang end
		end
	end

	-- Spawn black shards. Maybe. If no good places, or if it isn't feeling good today, will not make anything
	function GenerateBlackShard(seed)
		seed = seed or math.random(1, 1000)
		math.randomseed(seed)

		-- Try to find a good spot
		for count, posang in sharditer(seed + 1231, preferredSpawns) do
			local pos = tryBlackShard(posang.pos)
			if pos then
				local shard = ents.Create("jazz_shard_black")
				shard:SetPos(pos)
				shard:Spawn()
				shard:Activate()

				return true
			end
		end

		return false
	end

	function GenerateShards(count, seed, shardtbl)
		for _, v in pairs(SpawnedShards) do
			if IsValid(v) then v:Remove() end
		end
		seed = seed or math.random(1, 1000)
		math.randomseed(seed)
		SpawnedShards = {}

		-- Get preferred spawns, if there are any
		local preferredSpawns = GetPreferredSpawns(seed) or {}

		-- Select count random spawns and go
		local n = 0
		local function registerShard(posang)
			count = count - 1
			if count < 0 then return false end
			n = n + 1

			-- Create a new shard only if it hasn't been collected
			local shard = nil
			if not shardtbl or not tobool(shardtbl[n].collected) then
				shard = spawnShard(posang, n)
			end

			table.insert(SpawnedShards, shard)
			return true
		end

		for count, posang in sharditer(seed, preferredSpawns) do
			print(count, posang)
			if not registerShard(posang) then break end
		end

		InitialShardCount = n
		UpdateShardCount()

		print("Generated " .. InitialShardCount .. " shards. Happy hunting!")
		return InitialShardCount
	end

	function LoadHubProps()
		local hubdata = progress.LoadHubPropData()
		for _, v in pairs(hubdata) do
			mapgen.SpawnHubProp(v.model, v.transform.pos, v.transform.ang, v.toy == "1")
		end
	end

	function SaveHubProps()
		local props = {}
		for _, v in pairs(ents.GetAll()) do
			if v.JazzHubSpawned then table.insert(props, v) end
		end

		progress.SaveHubPropData(props)
	end

	function SpawnHubProp(model, pos, ang, inSphere)
		local etype = inSphere and "jazz_prop_sphere" or "prop_physics"
		local ent = ents.Create(etype)
		ent:SetModel(model)
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		ent:Activate()
		ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ent.JazzHubSpawned = true

		return ent
	end

else //CLIENT
	net.Receive("jazz_shardcollect", function(len, ply)
		SpawnedShards = {}
		local left = net.ReadUInt(16)
		for i=1, left do
			table.insert(SpawnedShards, net.ReadEntity())
		end
		local total = net.ReadUInt(16)

		surface.PlaySound("ambient/alarms/warningbell1.wav")
		InitialShardCount = total

		-- Broadcast update
		--hook.Call("JazzShardCollected", GAMEMODE, left, total)
	end )


end