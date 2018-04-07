include("../lib/sh_sql.lua")

module( "progress", package.seeall )

-- Stores map generation information about a specific map
jsql.Register("jazz_mapgen", 
[[
	id INTEGER PRIMARY KEY,
	filename VARCHAR(128) UNIQUE NOT NULL,
	wsid INTEGER NOT NULL DEFAULT 0,
	seed INTEGER NOT NULL DEFAULT 0
]])

-- Store specific map session data
jsql.Register("jazz_maphistory", 
[[
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	mapid INTEGER NOT NULL,
	starttime NUMERIC NOT NULL DEFAULT 0,
	endtime NUMERIC NOT NULL DEFAULT 0,
	FOREIGN KEY(mapid) REFERENCES jazz_mapgen(id) ON DELETE CASCADE
]])

-- Keep track of every generated shard for each map
jsql.Register("jazz_mapshards", 
[[
	id INTEGER NOT NULL,
	mapid INTEGER NOT NULL,
	collected BOOL NOT NULL DEFAULT 0,
	collect_player BIGINT,
	PRIMARY KEY(id, mapid),
	FOREIGN KEY(mapid) REFERENCES jazz_mapgen(id) ON DELETE CASCADE
]])

-- Per-player data
jsql.Register("jazz_playerdata", 
[[
	steamid BIGINT NOT NULL PRIMARY KEY,
	notes INT UNSIGNED NOT NULL DEFAULT 0 CHECK (notes >= 0)
]])

-- Per-player prop stealing data
jsql.Register("jazz_propdata", 
[[
	steamid BIGINT NOT NULL,
	mapname VARCHAR(64) NOT NULL,
	propname VARCHAR(128) NOT NULL,
	total INT UNSIGNED NOT NULL DEFAULT 1,
	recent INT UNSIGNED NOT NULL DEFAULT 1,
	worth INT UNSIGNED NOT NULL DEFAULT 0,
	PRIMARY KEY(steamid, mapname, propname)
]])

-- Hub prop positions (deprecated)
jsql.Register("jazz_hubprops", 
[[
	id INTEGER PRIMARY KEY,
	model VARCHAR(128) NOT NULL,
	transform BLOB NOT NULL,
	toy BOOL NOT NULL DEFAULT 0
]])

function Reset()
	jsql.Reset()
end

function Query(cmd)
	return jsql.Query(cmd)
end

---------------------------------
------ MAP COMPLETION INFO ------
---------------------------------

function GetMap(mapname)
	local chkstr = "SELECT * FROM jazz_mapgen WHERE " ..
		string.format("filename='%s'", mapname)

	local res = Query(chkstr)

	if type(res) == "table" then return res[1] end
end

-- Get a list of maps that have been started or completed
function GetMapHistory()
	-- #TODO: Filter based on completion
	local chkstr = "SELECT * FROM jazz_mapgen"
	
	return Query(chkstr)
end

-- Store map information. (Mostly, the association of mapname -> workshopid)
-- Allows upserting
function StoreMap(mapname, wsid, seed)
	seed = seed or 0
	wsid = wsid or 0

	local insrt = "INSERT INTO jazz_mapgen (filename, wsid, seed)" ..
		string.format("VALUES ( '%s', %s, %s) ", mapname, wsid, seed)

	local update = "UPDATE jazz_mapgen " ..
		string.format("SET wsid=%s, seed=%s ", wsid, seed) ..
		string.format("WHERE filename='%s'", mapname)

	local map = GetMap(mapname)
	return Query(map != nil and update or insrt) != false
end

-- Start playing a new, previously unplayed map
function StartMap(mapname, seed, shardcount)
	mapname = string.lower(mapname)

	-- Check if we've already played (or attempted to play) this map
	local res = GetMap(mapname)

	-- If map has never been played before, insert gen info
	-- Note, a seed of 0 signifies the map hasn't been played (no shards generated)
	if (res == nil or res.seed == 0) and seed and shardcount then 

		-- Store the map + generation info down. Shards reference this
		local wsid = res and res.wsid or workshop.FindOwningAddon(mapname)
		if not StoreMap(mapname, wsid, seed) then return nil end

		-- Generate all the shards and insert into db as well
		local map = GetMap(mapname)
		local shardvals = {}
		for i=1, shardcount do
			table.insert(shardvals, "(" .. i .. ", " ..map.id .. ")")
		end
		local insrt_shard = "INSERT INTO jazz_mapshards (id, mapid) VALUES " ..
			table.concat(shardvals, ",")

		-- Create the table of shard values 
		if Query(insrt_shard) == false then
			ErrorNoHalt("WARNING: Failed to insert shards into database for map " .. mapname)
		end
	end

	-- Retry map query
	res = GetMap(mapname)

	-- Start a new map session
	local insrt = "INSERT INTO jazz_maphistory " ..
		"(mapid, starttime, endtime)" ..
		string.format("VALUES ( '%s', ", res.id) ..
		string.format("%s, ", os.time()) ..
		string.format("%s)", os.time())

	if Query(insrt) == false then
		ErrorNoHalt("WARNING: Failed to start a new play session for map " .. mapname)
	end

	return res
end

function GetMapSessions(lim)
	local queryStr = "SELECT h.id, h.mapid, h.starttime, h.endtime, g.filename, g.seed " ..
		"FROM jazz_maphistory h " ..
		"INNER JOIN jazz_mapgen g ON h.mapid = g.id " ..
		"ORDER BY h.id DESC " ..
		"LIMIT " .. (lim or 1)

	return Query(queryStr)
end

function GetLastMapSession()
	local res = GetMapSessions(1)
	return res and type(res) == "table" and res[1] or nil
end

function UpdateMapSession(mapname)
	local curSession = GetLastMapSession()

	-- Ensure the current session matches up with the current mapname
	if not curSession or curSession.filename != string.lower(mapname) then return false end
	print("Updating session for " .. curSession.filename .. " (sessionid: " .. curSession.id .. ")")

	local updateStr = "UPDATE jazz_maphistory " ..
		"SET endtime = " .. os.time() .. " " ..
		"WHERE id = " ..curSession.id

	return Query(updateStr) != false
end

-- Get a list of shards that were created for this map
function GetMapShards(mapname)
	mapname = string.lower(mapname)
	local chkstr = "SELECT * FROM jazz_mapgen " ..
		"INNER JOIN jazz_mapshards ON jazz_mapgen.id = jazz_mapshards.mapid " ..
		"WHERE " .. string.format("filename='%s' ", mapname) ..
		"ORDER BY jazz_mapshards.id ASC"

	return Query(chkstr) or {}
end

-- Get the amount of collected/possible shards
function GetMapShardCount(mapname)
	mapname = mapname and string.lower(mapname) or nil

	local chkstr = "SELECT SUM(collected) as collected, COUNT(*) as total FROM jazz_mapgen " ..
		"INNER JOIN jazz_mapshards ON jazz_mapgen.id = jazz_mapshards.mapid " ..
		(mapname and "WHERE " .. string.format("filename='%s' ", mapname) or "") ..
		"ORDER BY jazz_mapshards.id ASC"
	
	local res = Query(chkstr)
	if type(res) == "table" then
		return tonumber(res[1].collected) or 0, tonumber(res[1].total) or 0
	end
end

-- Mark a map as finished
-- If the map hasn't been started, or was already finished, this will do nothing
function CollectShard(mapname, shardid, ply)
	mapname = string.lower(mapname)
	local pid = IsValid(ply) and ply:SteamID64() or "0"

	-- Check to make sure the map exists and isn't finished
	local res = GetMap(mapname)
	if (res == nil) then print("You must have started \"" .. mapname .. "\" before you can collect shards from it.") return nil end

	-- Alter table with new finish info
	local altr = "UPDATE jazz_mapshards SET " ..
			string.format("collected='%d', ", 1) ..
			string.format("collect_player='%d' ", pid) ..
			string.format("WHERE mapid='%s' ", res.id) ..
			string.format("AND id='%d'", shardid)

	if Query(altr) != false then
		return GetMapShards(mapname)
	end
end

-------------------------------
------ GLOBAL PROP COUNT ------
-------------------------------

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
/*
	steamid BIGINT NOT NULL
	mapname VARCHAR(64) NOT NULL
	propname VARCHAR(128) NOT NULL,
	total INT UNSIGNED NOT NULL DEFAULT 1,
	recent INT UNSIGNED NOT NULL DEFAULT 1,
	worth INT UNSIGNED NOT NULL DEFAULT 0,
*/
-- Increment the global count of a specific prop
function AddProp(ply, model, worth)
	if not model or #model == 0 or not IsValid(ply) then return nil end
	local id = ply:SteamID64() or "0"
	local map = game.GetMap()

	local altr = "UPDATE jazz_propdata SET total = total + 1, "
		.. "recent = recent + 1 "
		.. string.format("WHERE propname='%s' AND ", model)
		.. string.format("steamid='%s' AND ", id)
		.. string.format("mapname='%s'", map)
	local insert = "INSERT OR IGNORE INTO jazz_propdata (steamid, mapname, propname, worth) "
		.. string.format("VALUES ('%s', '%s', '%s', '%d')", id, map, model, worth)

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

function ClearPlayerRecentProps(ply)
	if not IsValid(ply) then return nil end

	local id = ply:SteamID64() or "0"
	local altr = "UPDATE jazz_propdata SET recent = 0 "
		.. string.format("WHERE steamid='%s'", id)
	return Query(altr) != false
end

-------------------------
------ PLAYER DATA ------
-------------------------

-- Change the player's note count, works for positive and negative values
-- Negative values that put the player under 0 will fail the constraint and return false
function ChangeNotes(ply, delta)
	if !IsValid(ply) then return false end
	local id = ply:SteamID64() or "0"
	local deltaStr = delta >= 0 and "+ " .. delta or tostring(delta)

	local update = "UPDATE jazz_playerdata "
		.. string.format("SET notes = notes %s ", deltaStr)
		.. string.format(" WHERE steamid='%s'", id)

	local insert = "INSERT OR IGNORE INTO jazz_playerdata(steamid) "
		.. string.format("VALUES ('%s')", id)

	-- Try an update first, then insert
	if Query(update) == false then return false end
	if Query(insert) == false then return false end

	return true
end

-- Retrieve the note count of a specific player
function GetNotes(ply)
	if !IsValid(ply) then return -1 end
	local id = ply:SteamID64() or "0"

	local sel = "SELECT notes FROM jazz_playerdata "
		.. string.format("WHERE steamid='%s'", id)

	local res = Query(sel)
	if type(res) == "table" then 
		return tonumber(res[1].notes) 
	end

	return 0
end

--------------------------------------
------ HUB PROP POSITION SAVING ------
--------------------------------------

local function loadTransform(blob)
	local vals = string.Split(blob, ":")
	return { pos = Vector(vals[1]), ang = Angle(vals[2]) }
end
local function saveTransform(ent)
	local pos, ang = ent:GetPos(), ent:GetAngles()
	return string.format("%f %f %f:%f %f %f", pos.x, pos.y, pos.z, ang.p, ang.y, ang.r)
end
local function getSQLSaveData(ent)
	local isToy = ent:GetClass() == "jazz_prop_sphere" and 1 or 0
	return string.format("('%s', '%s', %d)", ent:GetModel(), saveTransform(ent), isToy)
end
function SaveHubPropData(props)

	-- Delete existing prop data
	local del = "DELETE FROM jazz_hubprops"
	Query(del)

	-- Add new prop data
	local propvals = {}
	for _, v in pairs(props) do
		table.insert(propvals, getSQLSaveData(v))
	end

	local insert = "INSERT INTO jazz_hubprops (model, transform, toy)"
		.. string.format(" VALUES %s", table.concat(propvals, ", "))
	print(insert)
	-- Finally insert
	return Query(insert) != false
end

function LoadHubPropData()
	local query = "SELECT * FROM jazz_hubprops"
	local res = Query(query)
	if type(res) != "table" then return {} end

	-- Fixup transform to non-blob form
	for i=1, #res do
		res[i].transform = loadTransform(res[i].transform)
	end

	return res
end