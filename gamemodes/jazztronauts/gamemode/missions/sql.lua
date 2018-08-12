jsql.Register("jazz_active_missions",
[[
	steamid BIGINT NOT NULL,
	missionid INT NOT NULL,
	progress INT NOT NULL DEFAULT 0,
	completed BOOL DEFAULT 0,
	PRIMARY KEY(steamid, missionid)
]])

newgame.MarkPersistent("jazz_active_missions")

module( "missions", package.seeall )

-- Retrieve a list of missions the player has started
function GetMissionHistory(ply)
	if !IsValid(ply) then return {} end
	local id = ply:SteamID64() or "0"

	local sel = "SELECT * FROM jazz_active_missions "
		.. string.format("WHERE steamid='%s'", id)

	local res = jsql.Query(sel)
	if type(res) == "table" then

		local resmap = {}

		-- Make the result slightly more useful (key is missionid)
		for _, v in pairs(res) do
			v.completed = tonumber(v.completed) != 0
			v.missionid = tonumber(v.missionid)
			v.progress = tonumber(v.progress)
			resmap[v.missionid] = v
		end

		return resmap
	end

	return {}
end

function GetMission(ply, missionid)
	if !IsValid(ply) then return nil end
	local id = ply:SteamID64() or "0"

	local sel = "SELECT * FROM jazz_active_missions "
		.. string.format("WHERE steamid='%s' and missionid=%d", id, missionid)

	local res = jsql.Query(sel)
	if type(res) == "table" then
		res[1].completed = tonumber(res[1].completed) != 0
		res[1].missionid = tonumber(res[1].missionid)
		res[1].progress = tonumber(res[1].progress)
		return res[1]
	end

	return nil
end

function _completeMission(ply, missionid)
	if !IsValid(ply) then return nil end
	local id = ply:SteamID64() or "0"

	local upd = "UPDATE jazz_active_missions "
		.. "SET completed=1 "
		.. string.format("WHERE steamid='%s' and missionid=%d", id, missionid)

	return jsql.Query(upd) != false
end

function _startMission(ply, missionid)
	if !IsValid(ply) then return nil end
	local id = ply:SteamID64() or "0"
	local mis = GetMission(ply, missionid)

	-- They must not have already started the mission
	if mis then return false end

	local insert = "INSERT INTO jazz_active_missions (steamid, missionid) "
		.. string.format("VALUES ('%s', %d)", id, missionid)

	return jsql.Query(insert) != false
end

function _addMissionProgress(ply, missionid, num)
	if !IsValid(ply) then return nil end
	num = math.max(num or 1, 1)
	local id = ply:SteamID64() or "0"
	local mis = GetMission(ply, missionid)

	-- They must have started the mission
	if not mis or mis.completed then return false end

	local upd = "UPDATE jazz_active_missions "
		.. string.format("SET progress = progress + %d ", num)
		.. string.format("WHERE steamid='%s' and missionid=%d", id, missionid)

	return jsql.Query(upd) != false
end