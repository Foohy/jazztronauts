module( "converse", package.seeall )
ResetConvos()

EVENT_PRIORITY = 4

local function addMissionAuto(mid, npcid)
    local name = string.lower(missions.GetNPCName(npcid))
    local missionfile = name .. ".mission" .. mid
    AddMission(mid, missionfile .. ".accept", MISSION_AVAILABLE)
    AddMission(mid, missionfile .. ".idle", MISSION_ACCEPTED)
    AddMission(mid, missionfile .. ".turnin", MISSION_COMPLETED)

    -- Add mission event
    local eventscript = name .. ".event" .. mid .. ".begin"
    Add(eventscript, function(ply)
        print("Unlocked: ", unlocks.IsUnlocked("scripts", ply, eventscript))
        if unlocks.IsUnlocked("scripts", ply, eventscript) then return false end

        local missioninfo = missions.GetMission(ply, mid) 
        return missioninfo and missioninfo.completed
    end,
    EVENT_PRIORITY )
end

-- Automatically add mission conversations
for k, v in pairs(missions.MissionList) do
    addMissionAuto(k, v.NPCId)
end

-- Add in manual, conditional conversations
-- Add(id, script, conditionFunc, isRepeat)