include("sql.lua")
include("missions.lua")
include("converse.lua")

AddCSLuaFile("missions.lua")
AddCSLuaFile("converse.lua")

-- Utility mission functions so we don't go insane
-- Remove these
concommand.Add("jazz_missions_add", function(ply, cmd, args, argstr)
	local m = missions.GetActiveMissions(ply)
	for k, v in pairs(m) do
		missions.AddMissionProgress(ply, k, tonumber(args[1]))
	end
end, nil, nil, { FCVAR_CHEAT }  )

concommand.Add("jazz_missions_reset_all", function(ply, cmd, args, argstr)
	if not IsValid(ply) or ply:IsAdmin() then
		jsql.Reset("jazz_active_missions")

		for _, v in pairs(player.GetAll()) do
			missions.UpdatePlayerMissionInfo(v)
		end
	end
end, nil, nil, { FCVAR_CHEAT }  )


