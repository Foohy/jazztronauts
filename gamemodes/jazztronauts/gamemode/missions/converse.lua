AddCSLuaFile("converselist.lua")

-- no these aren't a brand of shoes
ScriptsList = "scripts"
unlocks.Register(ScriptsList)

--if CLIENT then return end

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

MissionPriority = 2

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

local function hasSeen(ply, script)
	return unlocks.IsUnlocked(ScriptsList, ply, script)
end

-- Just add some additional conditions for NPC dialog
-- Namely, that it's to the correct NPC and it hasn't been seen before
function AddNPC(script, npcid, conditionFunc, priority)

	local extendedFunc = function(ply, talknpc)
		if talknpc != npcid then return false end
		if hasSeen(ply, script) then return false end

		return conditionFunc(ply, talknpc)
	end

	Add(script, extendedFunc, priority)
end

function Add(script, conditionFunc, priority)
	table.insert(Convos,
	{
		script = script,
		condition = conditionFunc,
		priority = priority
	})
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
			return m, k - 1
		end
	end

	return nil
end

-- Retrieves the current state of the player's missions
-- so we can check conditions all at once
function GetMissionScript(ply, npcid)
	local hist = SERVER and missions.GetMissionHistory(ply) or missions.ClientMissionHistory

	-- Choose which mission id is most important for us to talk about
	local ready = missions.GetReadyMissions(ply, npcid, hist)
	local avail = missions.GetAvailableMissions(ply, npcid, hist)
	local active = missions.GetActiveMissions(ply, npcid, hist)

	local mdata, cond = getFirst(ready, avail, active)

	local mid = type(mdata) == "table" and mdata.missionid or mdata
	if not mid or not MissionConvos[mid] or not MissionConvos[mid][cond] then
		return nil
	end

	return MissionConvos[mid][cond].script, cond
end

function GetAvailableConvos(ply, npcid)
	local convos = {}
	for _, v in pairs(Convos) do
		if v.condition(ply, npcid) then
			table.insert(convos, v)
		end
	end

	-- Add in current mission convo as well
	local curMisScript, cond = GetMissionScript(ply, npcid)
	if curMisScript != nil then
		table.insert(convos, {
			script = curMisScript,
			priority = MissionPriority
		})
	end

	table.SortByMember(convos, "priority")
	return convos
end

function GetNextScript(ply, npcid)
	local convos = GetAvailableConvos(ply, npcid)
	return #convos > 0 and convos[1].script or nil
end