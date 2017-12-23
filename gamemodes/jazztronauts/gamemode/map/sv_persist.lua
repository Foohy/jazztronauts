module( "progress", package.seeall )

MAPPROGRESS_STARTED = 0
MAPPROGRESS_FINISHED = 1
MAPPROGRESS_PRESTIGED = 2

-- Make sure the corresponding tables exist
local function ensureTables()
	if !sql.TableExists("jazz_maphistory") then
		Msg("Creating 'jazz_maphistory' table...\n")

		sql.Query([[CREATE TABLE jazz_maphistory (
			id INTEGER PRIMARY KEY,
			filename VARCHAR(128) UNIQUE NOT NULL,
			seed INTEGER NOT NULL DEFAULT 0,
			completed BOOL NOT NULL DEFAULT 0,
			starttime NUMERIC NOT NULL DEFAULT 0,
			endtime NUMERIC NOT NULL DEFAULT 0
		)]])
	end

	if !sql.TableExists("jazz_playerdata") then
		-- Msg("Creating 'jazz_playerdata' table...\n")

		-- store:
		-- steamid (pk)
		-- # notes
		-- ????
	end
end

function Reset()
	sql.Query("DROP TABLE IF EXISTS jazz_maphistory")
	sql.Query("DROP TABLE IF EXISTS jazz_playerdata")
end

function Query(cmd)

	ensureTables()

	if cmd then 
		return sql.Query(cmd)
	end
end

function GetMap(mapname)
	local chkstr = "SELECT * FROM jazz_maphistory WHERE " ..
		string.format("filename='%s'", mapname)

	local res = Query(chkstr)

	if type(res) == "table" then return res[1] end
end

function GetMapHistory(finishlvl)
	finishlvl = finishlvl or MAPPROGRESS_STARTED

	local chkstr = "SELECT * FROM jazz_maphistory WHERE " ..
		string.format("completed>=%d", finishlvl)

	return Query(chkstr)
end

-- Start playing a new, previously unplayed map
function StartMap(mapname, seed)
	mapname = string.lower(mapname)

	-- Check if we've already played (or attempted to play) this map
	local res = GetMap(mapname)

	-- Map has already been started
	-- Return existing info, don't alter
	if res != nil then 
		return res
	else
		local insrt = "INSERT INTO jazz_maphistory " ..
			"(filename, seed, starttime)" ..
			string.format("VALUES ( '%s', ", mapname) ..
			string.format("%s, ", seed) ..
			string.format("%s)", os.time())

		-- Returns false on failure, and nil on success
		if Query(insrt) != false then
			return GetMap(mapname)
		end
	end
end

-- Mark a map as finished
-- If the map hasn't been started, or was already finished, this will do nothing
function FinishMap(mapname)

	-- Check to make sure the map exists and isn't finished
	local res = GetMap(mapname)
	if (res == nil) then print("You must have started \"" .. mapname .. "\" before you can finish it.") return nil end
	if (tobool(res.completed)) then return res end -- Do nothing, but still return latest map data

	-- Alter table with new finish info
	local altr = "UPDATE jazz_maphistory SET " ..
			string.format("completed='%s', ", MAPPROGRESS_FINISHED) ..
			string.format("endtime='%s' WHERE ", os.time()) ..
			string.format("id=%d AND ", res.id) ..
			string.format("filename='%s'", mapname)

	if Query(altr) != false then
		return GetMap(mapname)
	end
end