include( "shared.lua" )
include( "ui/init.lua" )
include( "map/init.lua" )

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_scoreboard.lua" )
AddCSLuaFile( "player.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "workshop/workshop.lua" )

AddCSLuaFile( "cl_hud.lua" )

function GM:Initialize()
	self.BaseClass:Initialize()

	RunConsoleCommand("sv_loadingurl", "http://host.foohy.net/public/Documents/Jazz/index.html")

	mapcontrol.SetupMaps()
end

function GM:InitPostEntity()

	if !mapcontrol.IsInHub() then

		-- Add current map to list of 'started' maps
		local res = progress.StartMap(game.GetMap(), math.random(0, 100000))

		-- If we haven't beat the map yet, generate some shards
		if tonumber(res.completed) == 0 then 
			mapgen.GenerateShards(5, tonumber(res.seed))
		else mapgen.InitialShardCount = 5 end -- Gross, but we'll refine later
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

	ply:SetNotes(6969420)
	PrintMapHistory(ply)
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
