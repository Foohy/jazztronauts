module( "snatch", package.seeall )

-- Per-player prop stealing data
jsql.Register("jazz_propdata",
[[
	steamid BIGINT NOT NULL,
	mapname VARCHAR(64) NOT NULL,
	propname VARCHAR(128) NOT NULL,
	type VARCHAR(16) NOT NULL,
	total INT UNSIGNED NOT NULL DEFAULT 1,
	recent INT UNSIGNED NOT NULL DEFAULT 1,
	worth INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(steamid, mapname, propname, type)
]])

local Query = jsql.Query

-- Get the collected count of a specific model
function GetPropCount(model)
	local altr = "SELECT SUM(total), SUM(recent) FROM jazz_propdata "
		.. string.format("WHERE propname='%s'", model)

	local res = Query(altr)
	if type(res) == "table" then
		return tonumber(res[1].total), tonumber(res[1].recent)
	end

	return 0, 0
end

-- Get the collected count of all props
function GetPropCounts()
	local altr = "SELECT * FROM jazz_propdata"

	local res = Query(altr)

	if type(res) == "table" then
		for i=1, #res do
			-- Convert to number
			res[i].total = tonumber(res[i].total)
			res[i].recent = tonumber(res[i].recent)
			res[i].worth = tonumber(res[i].worth)

			-- Allow key lookup
			--res[res[i].propname] = res[i]
			--res[i] = nil
		end
		return res
	end

	return {}
end

-- Get the collected count of all props collected by a specific player
function GetPlayerPropCounts(ply, recentonly)
	if not IsValid(ply) then return {} end
	local id = ply:SteamID64() or "0"
	local altr = "SELECT * FROM jazz_propdata "
		.. string.format("WHERE steamid='%s'", id)

	-- Only include entries with nonzero recents
	if recentonly then
		altr = altr .. string.format(" AND recent > 0")
	end

	local res = Query(altr)

	if type(res) == "table" then
		for i=1, #res do
			-- Convert to number
			res[i].total = tonumber(res[i].total)
			res[i].recent = tonumber(res[i].recent)
			res[i].worth = tonumber(res[i].worth)

			-- Allow key lookup
			--res[res[i].propname] = res[i]
			--res[i] = nil
		end
		return res
	end

	return {}
end

-- Increment the global count of a specific prop
function AddProp(ply, model, worth, type)
	if not model or #model == 0 or not IsValid(ply) then return nil end
	local id = ply:SteamID64() or "0"
	local map = game.GetMap()
	type = type or "prop"

	local altr = "UPDATE jazz_propdata SET total = total + 1, "
		.. "recent = recent + 1 "
		.. string.format("WHERE propname='%s' AND ", model)
		.. string.format("steamid='%s' AND ", id)
		.. string.format("mapname='%s' AND ", map)
		.. string.format("type='%s' ", type)
	local insert = "INSERT OR IGNORE INTO jazz_propdata (steamid, mapname, propname, type, worth) "
		.. string.format("VALUES ('%s', '%s', '%s', '%s', '%d')", id, map, model, type, worth)

	-- Try an update, then an insert
	if Query(altr) == false then return nil end
	if Query(insert) == false then return nil end

	return GetPropCount(model)
end

-- Reset the recently collected prop counts
-- Usually happens when they pulled the trash chute
function ClearRecentProps()
	local altr = "UPDATE jazz_propdata SET recent = 0"
	return Query(altr) != false
end

function ClearMapProps(mapname)
	local altr = "DELETE FROM jazz_propdata WHERE "
		.. string.format("mapname='%s' ", mapname)
	return Query(altr) != false
end

function ClearPlayerRecentProps(ply)
	if not IsValid(ply) then return nil end

	local id = ply:SteamID64() or "0"
	local altr = "UPDATE jazz_propdata SET recent = 0 "
		.. string.format("WHERE steamid='%s'", id)
	return Query(altr) != false
end
