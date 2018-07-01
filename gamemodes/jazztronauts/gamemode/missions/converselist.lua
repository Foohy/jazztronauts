module( "converse", package.seeall )
ResetConvos()

EVENT_PRIORITY = 4
SUPER_PRIORITY = 6

local function hasSeen(ply, script)
    return unlocks.IsUnlocked("scripts", ply, script) 
end

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
    Add(eventscript, function(ply, talknpc)
        if talknpc != npcid then return false end
        if hasSeen(ply, eventscript) then return false end
        
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
-- Add(id, script, conditionFunc, isRepeat)


-- On map startup, manually invoke the intro script
if SERVER then
    local introTutScript = "jazz_bar_intro.begin"
    hook.Add("OnClientInitialized", "JazzCheckPlayerIntroDialog", function(ply)
        if not mapcontrol.IsInHub() then return end
        if hasSeen(ply, introTutScript) then return end
        
        dialog.Dispatch(introTutScript, ply)
    end )
end