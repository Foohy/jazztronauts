include( "shared.lua" )
include( "ui/init.lua" )
include( "map/init.lua" )
include( "workshop/workshop.lua")
include( "missions/init.lua")
include( "store/init.lua" )
include( "snatch/init.lua" )

include( "lzma/lzma.lua")

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "cl_jazzphysgun.lua")
AddCSLuaFile( "player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "workshop/workshop.lua" )
AddCSLuaFile( "missions/cl_init.lua" )

AddCSLuaFile( "cl_hud.lua" )

concommand.Add( "jazz_test_lzma", function()

	print("RUNNING LZMA TEST")

	local test = lzma.Decompressor( lzma.FileReader("test.gma"), lzma.FileWriter("yourmom.dat") )
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

	SetIfDefault("sv_loadingurl", "host.foohy.net/public/Documents/Jazz/")
	SetIfDefault("sv_gravity", "800")
	SetIfDefault("sv_airaccelerate", "150")

	RunConsoleCommand("mp_falldamage", "1")

	mapcontrol.SetupMaps()

	-- Add the current map's workshop pack to download
	-- Usually this is automatic, but because we're doing some manualy mounting, it doesn't happen
	local wsid = workshop.FindOwningAddon(game.GetMap()) or 0
	if wsid != 0 then resource.AddWorkshop(wsid) end
end

function GM:InitPostEntity()

	if not mapcontrol.IsInHub() then
	
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

		-- Calculate worth of each map-spawned prop
		mapgen.CalculatePropValues(30000)
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

	-- Congrats to everyone
	progress.ChangeNotesList(shard.JazzWorth)
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
		local newCount = snatch.AddProp(ply, prop:GetModel(), worth)
		propfeed.notify( prop, ply, newCount, worth)
	end

	-- Also maybe collect the prop for player missions
	for _, v in pairs(player.GetAll()) do
		missions.AddMissionProp(v, prop:GetModel())
	end
end

function GM:CollectBrush(brush, players)

	-- Calculate which side material of the brush we'll store
	-- Brushes can have a different material for each face, so just take the
	-- largest non-tool surface area
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

	maxmaterial = string.lower(maxmaterial)
	print("COLLECTED BRUSH: " .. maxmaterial)
	local worth = math.max(1, math.Round(math.sqrt(maxarea) * 0.1))
	print(worth)

	-- Collect the prop to the poop chute
	if worth and worth > 0 then --TODO: Check if worth > 1 not 0
		for _, ply in pairs(players) do 
			if not IsValid(ply) then continue end

			local newCount = snatch.AddProp(ply, maxmaterial, worth, "brush")
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
	
end

function GM:PlayerSpawn( ply )
	local class = mapcontrol.IsInHub() and "player_hub" or "player_explore"
	player_manager.SetPlayerClass( ply, class)

	-- Stop observer mode
	ply:UnSpectate()
	ply:SetupHands()

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

-- Allow spawning on players if they're hovered over someone that's alive
function GM:PlayerSelectSpawn(ply)
	local obstarget = ply:GetObserverTarget()
	if IsValid(obstarget) and obstarget:Alive() then
		return obstarget
	end

	return self.BaseClass.PlayerSelectSpawn(self, ply)
end

local function getAlive()
	local players = player.GetAll()
	local alive = {}
	for _, v in pairs(players) do
		if IsValid(v) and v:Alive() then table.insert(alive, v) end
	end

	return alive
end

local function getNextPlayer(ply)
	local players = getAlive()
	if #players == 0 then return nil end

	local i = table.KeyFromValue(players, ply) or 1
	i = (i % #players) + 1

	return players[i]
end

function GM:PlayerDeathThink(ply)

	-- Switch observing player
	if ply:KeyPressed(IN_ATTACK2) then
		local nextply = getNextPlayer(ply:GetObserverTarget())
		if IsValid(nextply) then
			ply:Spectate(OBS_MODE_CHASE)
			ply:SpectateEntity(nextply)
		end

		return
	end

	if ply.NextSpawnTime && ply.NextSpawnTime > CurTime() then return end

	-- Respawn on time's up
	if ( ply:IsBot() || ply:KeyPressed( IN_ATTACK ) || ply:KeyPressed( IN_JUMP ) ) then
		ply:Spawn()
	end
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