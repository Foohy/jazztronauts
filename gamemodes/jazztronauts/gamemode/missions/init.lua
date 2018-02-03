include("sql.lua")
include("missions.lua")
include("converse.lua")

AddCSLuaFile("missions.lua")

-- Utility mission functions so we don't go insane
-- Remove these
concommand.Add("jazz_missions_add", function(ply, cmd, args, argstr)
    local m = missions.GetActiveMissions(ply)
    for k, v in pairs(m) do
        missions.AddMissionProgress(ply, k)
    end
end )

concommand.Add("jazz_missions_reset_all", function(ply, cmd, args, argstr)
    if not IsValid(ply) or ply:IsAdmin() then
        jsql.Reset("jazz_active_missions")

        for _, v in pairs(player.GetAll()) do
            missions.UpdatePlayerMissionInfo(v)
        end
    end
end )


