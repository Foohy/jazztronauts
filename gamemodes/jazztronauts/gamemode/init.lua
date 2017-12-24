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

	if mapcontrol.IsInHub() then
		physenv.SetGravity( Vector(0,0,0) )
	else
		-- Add current map to list of 'started' maps
		local res = progress.StartMap(game.GetMap(), math.random(0, 100000))
		
		-- Later the map gen code should call progress.GetMap() so it can generate
		-- based on the provided random seed 
		mapgen.GenerateShards(5, tonumber(res.seed))
	end

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
			print(type(v.completed))
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

	-- Update the new player with the current map selection state
	mapcontrol.Refresh(ply)
	mapgen.UpdateShardCount(ply)
	
end

function GM:PlayerSpawn( ply )

	self.BaseClass:PlayerSpawn(ply)

	ply:SetNoCollideWithTeammates(true)

	local col = ply:GetInfo( "cl_playercolor" )
	ply:SetPlayerColor( Vector( col ) )
	ply:SetNotes(6969420)

	PrintMapHistory(ply)
end


function GM:PlayerNoClip( ply )
	return true
end

function GM:BroadcastMessage( message )

	for _, ply in pairs(player.GetAll()) do
		ply:ChatPrint(message)
	end

end
