-- Really basic module, just keeps track of players between changelevels so we know who's connected

jsql.Register("jazz_persist_players",
[[
	steamid BIGINT NOT NULL,
	name VARCHAR(256) NOT NULL,
	PRIMARY KEY(steamid)
]])

module( "playerwait", package.seeall )

function SetPlayers(players)
	ClearPlayers()
	if table.Count(players) == 0 then
		print("No players to set")
		return
	end

	local plyVals = {}
	for k, v in pairs(players) do
		table.insert(plyVals, "(" .. k .. ", " .. sql.SQLStr(v) .. ")")
	end
	local insrtply = "INSERT INTO jazz_persist_players (steamid, name) VALUES " ..
		table.concat(plyVals, ",")

	return jsql.Query(insrtply) != nil
end

function GetPlayers()
	local sel = "SELECT * FROM jazz_persist_players"
	local res = jsql.Query(sel)
	if type(res) == "table" then
		local plys = {}
		for _, v in pairs(res) do
			plys[v.steamid] = v.name or ""
		end

		return plys
	else
		return {}
	end
end

function ClearPlayers()
	jsql.Reset("jazz_persist_players")
end