module( "converse", package.seeall )
ResetConvos()

local function addMissionAuto(mid)
    local missionfile = "mission" .. mid
    AddMission(mid, missionfile .. ".accept", MISSION_AVAILABLE)
    AddMission(mid, missionfile .. ".idle", MISSION_ACCEPTED)
    AddMission(mid, missionfile .. ".turnin", MISSION_COMPLETED)
end

-- Automatically add mission conversations
for k, v in pairs(missions.MissionList) do
    addMissionAuto(k)
end

-- Add in manual, conditional conversations
-- Add(id, script, conditionFunc, isRepeat)