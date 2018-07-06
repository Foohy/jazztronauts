
-------------------------
------ PLAYER DATA ------
-------------------------

module( "progress", package.seeall )

-- Per-player data
jsql.Register("jazz_playerdata", 
[[
	steamid BIGINT NOT NULL PRIMARY KEY,
	notes INT UNSIGNED NOT NULL DEFAULT 0 CHECK (notes >= 0)
]])

jsql.Register("jazz_playerdata_persist", 
[[
	steamid BIGINT NOT NULL PRIMARY KEY,
	resets INT UNSIGNED NOT NULL DEFAULT 0
]])

newgame.MarkPersistent("jazz_playerdata_persist")


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

	-- Try an insert first to make sure they exist
	if Query(insert) == false then return false end
	if Query(update) == false then return false end

	return true
end

-- Add notes to EVERYBODY, even people not in the server
-- Takes in a list of players that are definitely in the server
function ChangeNotesList(delta)
	delta = math.max(delta, 0)

	-- Add 0 notes to every person, to make sure they have an entry in the db
	for k, v in pairs(player.GetAll()) do
		ChangeNotes(v, 0)
	end

	-- Blindly go through the database and increase the amount of everyone
	local update = "UPDATE jazz_playerdata "
		.. string.format("SET notes = notes + %s ", delta)

	local success = Query(update) != false

	-- Network updated note counts to players
	if success then
		for k, v in pairs(player.GetAll()) do
			v:RefreshNotes()
		end
	end

	return success
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

-- Get the total number of players that have played in this session
-- Money is reset every time the map resets
function GetTotalPlayers()
    local sel = "SELECT COUNT(*) as count FROM jazz_playerdata"
    local res = jsql.Query(sel)
	if type(res) == "table" then 
        return tonumber(res[1].count) or 0
    end 

    return 0
end