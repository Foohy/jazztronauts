jit.opt.start( 3 )
jit.opt.start( "hotloop=36", "hotexit=60", "tryside=4" )

include("sv_jazztronauts.lua")
include("sv_resource.lua")

include( "shared.lua" )
include( "newgame/init.lua")
include( "ui/init.lua" )
include( "map/init.lua" )
include( "missions/init.lua")
include( "store/init.lua" )
include( "snatch/init.lua" )
include( "playerwait/init.lua")
include( "lzma/lzma.lua")

include( "player.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_jazzphysgun.lua")
AddCSLuaFile( "player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "missions/cl_init.lua" )
AddCSLuaFile( "playerwait/cl_init.lua")
AddCSLuaFile( "newgame/cl_init.lua")

AddCSLuaFile( "cl_hud.lua" )

concommand.Add( "jazz_test_lzma", function()

	print("RUNNING LZMA TEST")

	local test = lzma.Decompressor( lzma.FileReader("test2.gma"), lzma.FileWriter("yourmom.dat") )
	local decoded_header = false

	test:SetProgressCallback( function( decompressed, total, percent )

		if decoded_header == false and decompressed > 0x40000 then
			decoded_header = true

			local b, e = pcall( gmad.ReadFileEntries, test:GetWindowReader() )
			PrintTable( b and e or { e } )
		end

		print( ("decompressing: %0.2f%%"):format( percent ) )

	end )

	test:Start()

end)

local function SetIfDefault(convarstr, ...)
	local convar = GetConVar(convarstr)
	if not convar or convar:GetDefault() == convar:GetString() then
		print("Setting " .. convarstr)
		RunConsoleCommand(convarstr, ...)
	end
end

function GM:Initialize()
	self.BaseClass:Initialize()

	game.SetGlobalState( "gordon_invulnerable", GLOBAL_DEAD )

	SetIfDefault("sv_loadingurl", "host.foohy.net/public/Documents/Jazz/")
	SetIfDefault("sv_gravity", "800")
	SetIfDefault("sv_airaccelerate", "150")

	RunConsoleCommand("mp_falldamage", "1")

	mapcontrol.SetupMaps()

	-- Add the current map's workshop pack to download
	-- Usually this is automatic, but because we're doing some manual mounting, it doesn't happen
	local wsid = workshop.FindOwningAddon(game.GetMap()) or 0
	if wsid != 0 then resource.AddWorkshop(wsid) end
end

function GM:InitPostEntity()
	self.BaseClass:InitPostEntity()

	-- Check if the current map makes sense for where we are in the story
	-- If not (and returns false), we're changing level to the correct one
	local redirect = self:CheckGamemodeMap()
	if redirect then print("=========== REDIRECT: " .. redirect) end
	if redirect and false then
		mapcontrol.Launch(redirect)
	end
end

-- Given a certain global state, we want to 100% force whether or not we should be on a map
-- For example, on a fresh restart, always start at the tutorial
function GM:CheckGamemodeMap()
	local curMap = game.GetMap()
	local lastMap = newgame.GetGlobal("last_map")
	local unlocked = tobool(newgame.GetGlobal("unlocked_encounter"))
	newgame.SetGlobal("unlocked_encounter", false)

	-- Haven't finished intro yet, changelevel to intro
	if not tobool(newgame.GetGlobal("finished_intro")) then
		if curMap != mapcontrol.GetIntroMap() then
			return mapcontrol.GetIntroMap()
		end

	-- Changelevel'd back to intro? WHy?
	elseif curmap == mapcontrol.GetIntroMap() then
		return mapcontrol.GetHubMap()
	end

	-- Don't let them changelevel to the Ending Level until they've got enough shards
	-- OR if they've already seen the ending
	local hasEnded = tobool(newgame.GetGlobal("ended"))
	local endType = tonumber(newgame.GetGlobal("ending"))

	--local collected, required = mapgen.GetTotalCollectedShards(), mapgen.GetTotalRequiredShards()
	--local bcollected, brequired = mapgen.GetTotalCollectedBlackShards(), mapgen.GetTotalRequiredBlackShards()

	local endmaps = mapcontrol.GetEndMaps()

	-- If they're on the normal ending map, they must have enabled the ending
	if curMap == endmaps[newgame.ENDING_ASH] and endType != newgame.ENDING_ASH then
		return mapcontrol.GetHubMap()
	end

	-- Same with the true ending, must have set the correct ending type
	if curMap == endmaps[newgame.ENDING_ECLIPSE] and endType != newgame.ENDING_ECLIPSE then
		return mapcontrol.GetHubMap()
	end

	-- No map change occurring
	return nil
end

function GM:JazzMapStarted()
	print("MAP STARTED!!!!!!!")
	local isIntro = game.GetMap() == mapcontrol.GetIntroMap() 
	if not mapcontrol.IsInGamemodeMap() or isIntro then
		game.CleanUpMap()
		self:GenerateJazzEntities(isIntro)
	end

	-- Unlock and respawn everyone
	for _, v in pairs(player.GetAll()) do
		v:UnLock()
		v:KillSilent()
		v:Spawn()
	end

	-- If intro map, mark as played
	if game.GetMap() == mapcontrol.GetIntroMap() then
		newgame.SetGlobal("finished_intro", true)
	end
end

function GM:GenerateJazzEntities(noshards)

	if not mapcontrol.IsInHub() then
		if not noshards then
			-- Add current map to list of 'started' maps
			local map = progress.GetMap(game.GetMap())

			-- If the map doesn't exist, try to generate as many shards as we can
			-- Then store that as the map's worth
			if not map or tonumber(map.seed) == 0 then	
				print("Brand new map")
				local shardworth = mapgen.CalculateShardCount()
				local seed = math.random(0, 100000)
				shardworth = mapgen.GenerateShards(shardworth, seed) -- Not guaranteed to make all shards

				map = progress.StartMap(game.GetMap(), seed, shardworth)
			-- Else, spawn shards, but only the ones that haven't been collected
			else
				map = progress.StartMap(game.GetMap()) -- Start a new session, but keep existin mapgen info
				local shards = progress.GetMapShards(game.GetMap())
				local generated = mapgen.GenerateShards(#shards, tonumber(map.seed), shards)

				if #shards > generated then
					print("WARNING: Generated less shards than we have data for. Did the map change?")
					-- Probably mark those extra shards as collected I guess?
				end
			end

			-- Also, generate black shards if we're at that point
			if tobool(newgame.GetGlobal("black_shards")) or map.corrupt > progress.CORRUPT_NONE then
				local spawned = mapgen.GenerateBlackShard(map.seed)

				-- If we generated a black shard but this map was corrupted, it sure is now
				if map.corrupt <= progress.CORRUPT_NONE then
					progress.SetCorrupted(game.GetMap(), progress.CORRUPT_SPAWNED)
				end
			end
		end

		-- Spawn static prop proxy entities
		snatch.SpawnProxies()

		-- Calculate worth of each map-spawned prop
		-- Mo' players = mo' money
		mapgen.CalculatePropValues(15000)
	end

end

function GM:ShutDown()
	if not mapcontrol.IsInHub() then 
		progress.UpdateMapSession(game.GetMap())
	end
end

-- Save progress every little bit or so
function GM:Think()
	if not self.JazzNextSave or CurTime() > self.JazzNextSave then
		progress.UpdateMapSession(game.GetMap())
		self.JazzNextSave = CurTime() + 30
	end
end

-- Called when somebody has collected a shard
function GM:CollectShard(shard, ply)
	local left, total = mapgen.CollectShard(ply, shard)
	if not left then return false end

	-- Go you
	ply:ChangeNotes(shard.JazzWorth * newgame.GetMultiplier())
end

-- Called when somebody has collected a bad boy shard
function GM:CollectBlackShard(shard, ply)	
	local corr = mapgen.CollectBlackShard(shard)
	print("Collecting black shard. Map corrupted now? ", corr)
end

-- Called when prop is snatched from the level
function GM:CollectProp(prop, ply)
	print("COLLECTED: " .. tostring(prop and prop:GetModel() or "<entity>"))
	local worth = mapgen.CollectProp(ply, prop)
	if worth and IsValid(ply) then
        --ply:ChangeNotes(worth)
		-- Moved to prop vomiter
    end

	-- Collect the prop to the poop chute
	if worth and worth > 0 then --TODO: Check if worth > 1 not 0
		worth = worth * newgame.GetMultiplier()
		local newCount = snatch.AddProp(ply, prop:GetModel(), worth)
		propfeed.notify( prop, ply, newCount, worth)
	end

	-- Also maybe collect the prop for player missions
	for _, v in pairs(player.GetAll()) do
		missions.AddMissionProp(v, prop:GetModel())
	end
end

-- Calculate which side material of the brush we'll store
-- Brushes can have a different material for each face, so just take the
-- largest non-tool surface area
function GM:GetPrimaryBrushMaterial(brush)

	local maxmaterial = nil
	local maxarea = -1
	for _, v in pairs(brush.sides) do
		if not v.winding then continue end
		local texinfo = v.texinfo
		local texdata = texinfo.texdata
		local mat = texdata.material

		local area = string.find(mat, "TOOLS/TOOLSNODRAW") and 0 or v.winding:Area()
		if area > maxarea then
			maxarea = area
			maxmaterial = mat
		end
	end

	if not maxmaterial then 
		print("Collected brush with no valid surface materials! (brushid: " .. brush.id .. ")")
		return
	end

	maxmaterial = string.lower(maxmaterial):gsub("_[+-]?%d+_[+-]?%d+_[+-]?%d+$",""):gsub("^maps/[%w_]+/","")
	return maxmaterial, maxarea
end

function GM:CollectBrush(brush, players)

	local material, area = self:GetPrimaryBrushMaterial(brush)
	local worth = math.max(1, math.Round(math.sqrt(area) * 0.1))

	-- Collect the prop to the poop chute
	if worth and worth > 0 then --TODO: Check if worth > 1 not 0
		worth = worth * newgame.GetMultiplier()
		for _, ply in pairs(players) do 
			if not IsValid(ply) then continue end

			local newCount = snatch.AddProp(ply, material, worth, "brush")
			--propfeed.notify( prop, ply, newCount, worth)
		end
	end

	-- Also maybe collect the prop for player missions
	/*
	for _, v in pairs(player.GetAll()) do
		missions.AddMissionProp(v, prop:GetModel())
	end
	*/
end

function GM:JazzDialogFinished(ply, script, markseen)

	-- Mark this as 'seen', so other systems know to continue
	if script and markseen then
		unlocks.Unlock(converse.ScriptsList, ply, script)
	end
end

-- TODO: Just for debugging for now
local function PrintMapHistory(ply)

	ply:ChatPrint("Waddup. Here's all the maps we've played (including unfinished):")
	local maps = progress.GetMapHistory()

	if maps then
		for _, v in pairs(maps) do 
			local mapstr = v.filename 
			mapstr = mapstr //.. " (Started " .. string.NiceTime(os.time() - v.starttime) .. " ago)"
			
			ply:ChatPrint(mapstr)
		end
	end
end

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn(ply)

	ply:SetTeam(1) -- We're all on the same team fellas

	-- Update the new player with the current map selection state
	mapcontrol.Refresh(ply)
	mapgen.UpdateShardCount(ply)

	-- Update them with their active missions
	missions.UpdatePlayerMissionInfo(ply)

	-- Freeze them if map hasn't started yet
	if self:IsWaitingForPlayers() then
		timer.Simple(0, function() 
			if self:IsWaitingForPlayers() then
				ply:Lock()
			end
		end )
	end
end

function GM:PlayerSpawn( ply )
	local class = mapcontrol.IsInGamemodeMap() and "player_hub" or "player_explore"
	player_manager.SetPlayerClass( ply, class)

	-- Stop observer mode
	ply:UnSpectate()
	ply:SetupHands()

	local ang = ply:EyeAngles()
	ang.r = 0
	ply:SetEyeAngles(ang)

	player_manager.OnPlayerSpawn( ply )
	player_manager.RunClass( ply, "Spawn" )

	hook.Call( "PlayerLoadout", GAMEMODE, ply )
	hook.Call( "PlayerSetModel", GAMEMODE, ply )

	PrintMapHistory(ply)
		
	-- Setup note count
	ply:RefreshNotes()
end

-- Stop killing the player, they don't collide 
function GM:IsSpawnpointSuitable(ply, spawnent, makesuitable)
	return true
end


function GM:PlayerShouldTakeDamage(ply, attacker)
	-- Don't allow pvp damage
	return not (attacker:IsValid() and attacker:IsPlayer())
end


function GM:BroadcastMessage( message )

	for _, ply in pairs(player.GetAll()) do
		ply:ChatPrint(message)
	end

end

local acknowledge = "yep, dump it"
concommand.Add("jazz_reset_progress", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	local phrase = table.concat(args, " ")
	if phrase != acknowledge then
		local failInfo = "Are you sure you want to reset progress? This command cannot be undone." 
		.. "\nRe-run this command with the argument \"" .. acknowledge .. "\" to acknowledge."
		if IsValid(ply) then 
			ply:ChatPrint(failInfo) 
		else
			print(failInfo)
		end
		return
	end

	jsql.Reset()
	unlocks.ClearAll()

	print("Dump'd. Changelevel to reflect all changes.")
	
end, nil, "Reset all jazztronauts progress entirely. This wipes all player progress, map history, purchases, unlocks, and previous game data.")