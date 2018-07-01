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

-- Once they've gotten enough shards, do this one, it's even more important
AddNPC("jazz_bar_shardall.begin", missions.NPC_BAR, function(ply, talknpc)
    return mapgen.GetTotalCollectedShards() >= mapgen.GetTotalRequiredShards()
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