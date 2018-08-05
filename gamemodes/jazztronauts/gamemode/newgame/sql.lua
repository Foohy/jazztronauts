jsql.Register("jazz_reset_info",
[[
	resetid INTEGER PRIMARY KEY AUTOINCREMENT,
	endtype INT NOT NULL DEFAULT 0,
	numplayers INT NOT NULL DEFAULT 1,
	time NUMERIC NOT NULL DEFAULT 0
]])

jsql.Register("jazz_global_state",
[[
	key TEXT PRIMARY KEY,
	value TEXT
]])

newgame.MarkPersistent("jazz_reset_info")

local newgame = {}

function newgame.AddResetInfo(endtype, playercount)

	local addQuery = "INSERT INTO jazz_reset_info (endtype, numplayers, time)"
		.. string.format("VALUES(%d, %d, %s)", endtype, playercount, os.time())

	return jsql.Query(addQuery) != false
end

local function fixResultType(res)
	res.resetid = tonumber(res.resetid)
	res.endtype = tonumber(res.endtype)
	res.numplayers = tonumber(res.numplayers)
	res.time = tonumber(res.time)
end

function newgame.GetResets()
	local sel = "SELECT * FROM jazz_reset_info ORDER BY time ASC"
	local res = jsql.Query(sel)
	if type(res) == "table" then
		for _, v in pairs(res) do
			fixResultType(v)
		end

		return res
	end

	return {}
end

function newgame.GetResetCount()
	local sel = "SELECT COUNT(*) as count FROM jazz_reset_info"
	local res = jsql.Query(sel)
	if type(res) == "table" then
		return tonumber(res[1].count) or 0
	end

	return 0
end

function newgame.SetGlobal(key, value)
	local add = "REPLACE INTO jazz_global_state (key, value) VALUES "
		.. string.format("(%s, %s)", SQLStr(key), SQLStr(value))

	return jsql.Query(add) != false
end

function newgame.GetGlobal(key)
		local query = "SELECT value FROM jazz_global_state "
			.. string.format("WHERE key=%s", SQLStr(key))
	local res = jsql.Query(query)
	if not type(res) == "table" then return nil end

	return res[1] and res[1].value
end

function newgame.GetGlobalState()
	local query = "SELECT * FROM jazz_global_state"
	local res = jsql.Query(query)

	if type(res) != "table" then return {} end
	local tbl = {}
	for _, v in pairs(res) do
		tbl[v.key] = v.value
	end
	return tbl
end

return newgame