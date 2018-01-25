-- no these aren't a brand of shoes
include("missions.lua")
module( "converse", package.seeall )

MissionConvos = {}
Convos = {}

-- Priorities:
-- 1. Mission complete conversations
-- 2. Mission accept conversations
-- 3. Conditional conversations
-- 4. Repeat conditional conversations (never expire)

MISSION_COMPLETED = 0 -- Mission is completed and ready to turn in
MISSION_AVAILABLE = 1 -- Mission is available and the player can talk to accept it
MISSION_ACCEPTED = 2 -- Mission is currently active but not quite completed


-- Add a conversation for a specific mission state
-- For example, this can be used to specify the dialog script to accept a specific unlocked mission
function AddMission(mid, script, mcond)
    MissionConvos[mid] = MissionConvos[mid] or {}
    MissionConvos[mid][mcond] = {
        script = script,
        missionid = mid,
        cond = mcond
    }
end

function Add(id, script, conditionFunc, isRepeat)

end

function ResetConvos()
    MissionConvos = {}
    Convos = {}
end

include("converselist.lua")

local function first(tbl, cond)
    local func, tbl = SortedPairs(tbl)
    return func(tbl), cond
end

local function firstData(tbl, cond)
    local v = first(tbl)
    return v and v.missionid or nil, cond
end

local function getFirst(...)
    local args = {...}
    for k, v in ipairs(args) do
        for _, m in SortedPairs(v) do 
            PrintTable(v)
            print(m)
            return m, k - 1 
        end
    end
    print("nothin'")
    return nil
end


function GetMissionScript(ply, npcid)
    local hist = missions.GetMissionHistory(ply)

    -- Choose which mission id is most important for us to talk about
    local ready = missions.GetReadyMissions(ply, npcid, hist)
    local avail = missions.GetAvailableMissions(ply, npcid, hist)
    local active = missions.GetActiveMissions(ply, hist)

    local mdata, cond = getFirst(ready, avail, active)


    local mid = type(mdata) == "table" and mdata.missionid or mdata
    if not mid or not MissionConvos[mid] or not MissionConvos[mid][cond] then
        return nil
    end

    return MissionConvos[mid][cond].script
end