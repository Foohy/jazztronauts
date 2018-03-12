include( "shared.lua" )
include( "ui/init.lua" )
include( "map/init.lua" )
include( "missions/init.lua")
include( "store/init.lua" )
include( "snatch/init.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "workshop/workshop.lua" )
AddCSLuaFile( "missions/cl_init.lua" )

AddCSLuaFile( "cl_hud.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()

	RunConsoleCommand("sv_loadingurl", "host.foohy.net/public/Documents/Jazz/")
	RunConsoleCommand("mp_falldamage", "1")

	mapcontrol.SetupMaps()
end

function GM:InitPostEntity()

	if mapcontrol.IsInHub() then
		--mapgen.LoadHubProps()
	else
		-- Add current map to list of 'started' maps
		local res = progress.StartMap(game.GetMap(), math.random(0, 100000))

		-- If we haven't beat the map yet, generate some shards
		if tonumber(res.completed) == 0 then 
			mapgen.GenerateShards(5, tonumber(res.seed))
			mapgen.CalculatePropValues(10000)
		else mapgen.InitialShardCount = 5 end -- Gross, but we'll refine later
	end

end

function GM:ShutDown()
	if mapcontrol.IsInHub() then 
		--mapgen.SaveHubProps()
	end
end

-- If someone picks up a weapon nobody has, spread the love
local IsGiving = false
function GM:WeaponEquip(weapon, owner)
	if !IsValid(weapon) then return end

	-- This hook is called _immediately_ when giving. We don't want to infinitely give people weapons
	if IsGiving then return end 

	IsGiving = true
	for _, v in pairs(player.GetAll()) do
		if v == owner then continue end 
		if v:HasWeapon(weapon:GetClass()) then continue end

		v:Give(weapon:GetClass())
	end
	IsGiving = false
end

-- Called when somebody has collected a shard
function GM:CollectShard(shard, ply)
	local left, total = mapgen.CollectShard(shard)
	if not left then return false end

	-- Congrats
	ply:ChangeNotes(1000)
	
	-- THEY DID IT!!!! Everyone gets a piece of the pie
	-- TODO: Move this logic somewhere else.
	if left == 0 && total != 0 then 
		local res = progress.FinishMap(game.GetMap())
		if res then
			for _, v in pairs(player.GetAll()) do
				ply:ChangeNotes(2000)

				v:ChatPrint("You collected all " .. total .. " shards! It only took you " 
					.. string.NiceTime(res.endtime - res.starttime))
			end
		end
	end
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
		local newCount = progress.AddProp(ply, prop:GetModel(), worth)
		propfeed.notify( prop, ply, newCount, worth)
	end

	-- Also maybe collect the prop for player missions
	for _, v in pairs(player.GetAll()) do
		missions.AddMissionProp(v, prop:GetModel())
	end
end

-- TODO: Just for debugging for now
local function PrintMapHistory(ply)

	ply:ChatPrint("Waddup. Here's all the maps we've played (including unfinished):")
	local maps = progress.GetMapHistory()

	if maps then
		for _, v in pairs(maps) do 
			local mapstr = v.filename 

			if tonumber(v.completed) == 0 then 
				mapstr = mapstr .. " (Started)"
			else
				mapstr = mapstr .. " (Finished in " .. string.NiceTime(v.endtime - v.starttime) .. ")"
			end
			
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
	ply:SetNotes(progress.GetNotes(ply))
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
