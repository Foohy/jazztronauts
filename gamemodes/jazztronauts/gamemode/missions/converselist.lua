module( "converse", package.seeall )
ResetConvos()

EVENT_PRIORITY = 4
SUPER_PRIORITY = 6

local function addMissionAuto(mid, npcid)
    local convoid = mid - npcid * 1000 -- Mission IDs are created as npcid * 1000 + mid

    local name = string.lower(missions.GetNPCName(npcid))
    local missionfile = name .. ".mission" .. convoid
    AddMission(mid, missionfile .. ".accept", MISSION_AVAILABLE)
    AddMission(mid, missionfile .. ".idle", MISSION_ACCEPTED)
    AddMission(mid, missionfile .. ".turnin", MISSION_COMPLETED)
    print("Add mission convo: ", mid, convoid, npcid, missionfile, name)
    
    -- Add mission event
    local eventscript = name .. ".event" .. convoid .. ".begin"
    AddNPC(eventscript, npcid, function(ply, talknpc)       
        local completed = missions.GetCompletedMissions(ply)
        return completed[mid]
    end,
    EVENT_PRIORITY )
end

-- Automatically add mission conversations
for k, v in pairs(missions.MissionList) do
    addMissionAuto(v.missionid, v.NPCId)
end

-- Add in manual, conditional conversations

-- Intro tutorial script
AddNPC("jazz_bar_intro.begin", missions.NPC_BAR,  function(ply, talknpc)  
    return true
end,
SUPER_PRIORITY )

-- Collected _A_ shard
AddNPC("jazz_bar_shardprogress.begin1", missions.NPC_BAR, function(ply, talknpc)
    local cur, total =mapgen.GetTotalCollectedShards(), mapgen.GetTotalRequiredShards()
    return cur > 0
        and cur < math.Round(total * 0.25)
end,
SUPER_PRIORITY - 1)

-- Collected 25% shards
AddNPC("jazz_bar_shardprogress.begin25", missions.NPC_BAR, function(ply, talknpc)
    local cur, total =mapgen.GetTotalCollectedShards(), mapgen.GetTotalRequiredShards()
    return cur >= math.Round(total * 0.25)
        and cur < math.Round(total * 0.50)
end,
SUPER_PRIORITY - 1)

-- Collected 50% shards
AddNPC("jazz_bar_shardprogress.begin50", missions.NPC_BAR, function(ply, talknpc)
    local cur, total =mapgen.GetTotalCollectedShards(), mapgen.GetTotalRequiredShards()
    return cur >= math.Round(total * 0.50)
        and cur < math.Round(total * 0.75)
end,
SUPER_PRIORITY - 1)

-- Collected 75% shards
AddNPC("jazz_bar_shardprogress.begin75", missions.NPC_BAR, function(ply, talknpc)
    local cur, total =mapgen.GetTotalCollectedShards(), mapgen.GetTotalRequiredShards()
    return cur >= math.Round(total * 0.75)
        and cur < math.Round(total * 1.00)
end,
SUPER_PRIORITY - 1)

-- Once they've gotten enough shards, do this one, it's even more important
AddNPC("jazz_bar_shardall.begin100", missions.NPC_BAR, function(ply, talknpc)
    return mapgen.GetTotalCollectedShards() >= mapgen.GetTotalRequiredShards()
        and not tobool(newgame.GetGlobal("ended"))
end,
SUPER_PRIORITY + 1)

-- Start epilogue script for good ending
AddNPC("normal_ending_epilogue.begin", missions.NPC_BAR, function(ply, talknpc)
    return tonumber(newgame.GetGlobal("ending")) == newgame.ENDING_ASH
        and tobool(newgame.GetGlobal("ended"))
end,
SUPER_PRIORITY + 1)



-- On map startup, manually invoke NPC_BAR scripts
if SERVER then

    hook.Add("OnClientInitialized", "JazzCheckPlayerIntroDialog", function(ply)
        if not mapcontrol.IsInHub() then return end
        
        -- See if we've got any intro scripts lined up to play
        local startScript = GetNextScript(ply, missions.NPC_BAR)
        if not dialog.IsScriptValid(startScript) then return end

        -- Set it off if we do
        dialog.Dispatch(startScript, ply)
    end )
end

concommand.Add("jazz_say_no", function(ply, cmd, arg)
    if not IsValid(ply) then return end

    unlocks.Unlock("scripts", ply, "said_no")
end )

if CLIENT then
    dialog.RegisterFunc("run", function(d, cmd, ...) 
        RunConsoleCommand(cmd, ...)
    end )
end