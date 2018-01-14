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
		Msg("Creating 'jazz_playerdata' table...\n")

		sql.Query([[CREATE TABLE jazz_playerdata (
			steamid BIGINT NOT NULL PRIMARY KEY,
			notes INT UNSIGNED NOT NULL DEFAULT 0 CHECK (notes >= 0)
		)]])
	end

	if !sql.TableExists("jazz_propdata") then
		Msg("Creating 'jazz_propdata' table...\n")

		sql.Query([[CREATE TABLE jazz_propdata (
			propname VARCHAR(128) NOT NULL PRIMARY KEY,
			collected INT UNSIGNED NOT NULL DEFAULT 1,
			recent INT UNSIGNED NOT NULL DEFAULT 1
		)]])
	end

	if !sql.TableExists("jazz_hubprops") then
		Msg("Creating 'jazz_hubprops' table...\n")

		sql.Query([[CREATE TABLE jazz_hubprops (
			id INTEGER PRIMARY KEY,
			model VARCHAR(128) NOT NULL,
			transform BLOB NOT NULL,
			toy BOOL NOT NULL DEFAULT 0
		)]])
	end
end

function Reset()
	sql.Query("DROP TABLE IF EXISTS jazz_maphistory")
	sql.Query("DROP TABLE IF EXISTS jazz_playerdata")
	sql.Query("DROP TABLE IF EXISTS jazz_propdata")
	sql.Query("DROP TABLE IF EXISTS jazz_hubprops")
end

function Query(cmd)

	ensureTables()

	if cmd then 
		return sql.Query(cmd)
	end
end

---------------------------------
------ MAP COMPLETION INFO ------
---------------------------------

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

-------------------------------
------ GLOBAL PROP COUNT ------
-------------------------------

-- Get the collected count of a specific model
function GetPropCount(model)
	local altr = "SELECT collected, recent FROM jazz_propdata "
		.. string.format("WHERE propname='%s'", model)

	local res = Query(altr)
	if type(res) == "table" then 
		return tonumber(res[1].collected), tonumber(res[1].recent)  
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
			res[i].collected = tonumber(res[i].collected)
			res[i].recent = tonumber(res[i].recent)

			-- Allow key lookup
			res[res[i].propname] = res[i]
			res[i] = nil
		end
		return res
	end

	return {}
end

-- Increment the global count of a specific prop
function AddProp(model)
	if not model or #model == 0 then return nil end

	local altr = "UPDATE jazz_propdata SET collected = collected + 1, "
		.. "recent = recent + 1 "
		.. string.format("WHERE propname='%s'", model)
	local insert = "INSERT OR IGNORE INTO jazz_propdata (propname) "
		.. string.format("VALUES ('%s')", model)

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