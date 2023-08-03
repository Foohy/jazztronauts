AddCSLuaFile()

-- Small leaderboards module. Doesn't do anything on its own,
-- just uses existing data for generating sorted lists of players
module( 'jazzboards', package.seeall )

BOARD_TOTALPROPS		= 1 -- Most props collected of all time
BOARD_SESSIONPROPS	  = 2 -- Most props pulled from the poop chute in the current map (temporary)
BOARD_RECENTS		   = 3 -- Most props not claimed yet (recently collected props)
BOARD_TOTALPROPS_SINGLE = 4 -- Most props of a single type collected of all time

-- How many top entries we should care about
BoardEntryCount = 10

Boards = Boards or {}

function AddLeaderboard(id, title, func, flipoffset)
	Boards[id] = {
		id = id,
		valuefunc = func,
		negate = flipoffset,
		title = title
	}
end

if SERVER then
	util.AddNetworkString("jazz_leaderboards_update")

	concommand.Add("jazz_update_leaderboards", function(ply, cmd, args, argstr)
		UpdateLeaderboards()
	end )

	hook.Add("OnClientInitialized", "JazzInitializeLeaderboards", function(ply)
		UpdateLeaderboards()
	end )

	SessionProps = SessionProps or {}

	function UpdateLeaderboard(id, ply, offset)

		if not Boards[id] then return false end
		local pid = IsValid(ply) and ply:SteamID64() or nil

		local counts = snatch.GetPropCounts()
		local tallied = Boards[id].valuefunc(counts)

		-- If the leaderboard supports a temporary offset, apply it here
		if id and offset and tallied[pid] then
			if Boards[id].negate then offset = offset * -1 end
			tallied[pid].count = tallied[pid].count + offset
		end

		-- Send the top players down the wire
		local num = math.min(table.Count(tallied), BoardEntryCount)
		net.Start("jazz_leaderboards_update")
			net.WriteUInt(id, 4)
			net.WriteUInt(num, 4)

			for k, v in SortedPairsByMemberValue(tallied, "count", true) do
				net.WriteString(v.steamid)
				net.WriteUInt(v.count, 32)

				num = num - 1
				if num == 0 then break end
			end
		net.Broadcast()
	end

	function UpdateLeaderboards(ply, offset)
		for k, v in pairs(Boards) do
			UpdateLeaderboard(k, ply, offset)
		end
	end

	function AddSessionProps(steamid, count)
		SessionProps[steamid] = (SessionProps[steamid] or 0) + count
	end
end

if CLIENT then
	Leaderboards = Leaderboards or {}

	net.Receive("jazz_leaderboards_update", function(len, ply)
		local id = net.ReadUInt(4)
		local num = net.ReadUInt(4)
		--print(jazzboards.Boards[id].title .. " received " .. num .. " entries")
		Leaderboards[id] = {}

		for i=1, num do
			local plyID = net.ReadString()
			local num = net.ReadUInt(32)
			--print("- entry " .. plyID .. " with value " .. num)
			local entry = {
				steamid = plyID,
				count = num,
				name = plyID
			}

			-- Update the name later on (probably should wait to call the hook until)
			-- these are all returned
			local idx = table.insert(Leaderboards[id], entry)
			steamworks.RequestPlayerInfo(plyID, function(name)
				if Leaderboards[id][idx] and Leaderboards[id][idx].steamid == plyID then
					Leaderboards[id][idx].name = name
				end
			end )
		end

		hook.Call("JazzLeaderboardsUpdated", GAMEMODE, id)
	end )

end


AddLeaderboard(BOARD_TOTALPROPS, "jazz.leaderboard.totals", function(counts)
	local all = {}

	for _, v in pairs(counts) do
		all[v.steamid] = all[v.steamid] or { count = 0 }
		all[v.steamid].count = all[v.steamid].count + v.total - v.recent
		all[v.steamid].steamid = v.steamid
	end

	return all
end )

AddLeaderboard(BOARD_SESSIONPROPS, "jazz.leaderboard.session", function(counts)
	local all = {}

	for k, v in pairs(SessionProps) do
		all[k] = { count = v, steamid = k }
	end

	return all
end )

AddLeaderboard(BOARD_RECENTS,  "jazz.leaderboard.patient", function(counts)
	local all = {}

	for _, v in pairs(counts) do
		all[v.steamid] = all[v.steamid] or { count = 0 }
		all[v.steamid].count = all[v.steamid].count + v.recent
		all[v.steamid].steamid = v.steamid
	end

	return all
end, true )
/*
//I'll do it later I'm lazy
//also #TODO: Should we have one entry per player, or allow multiple
//(if a single player has collected a shitload of different types of props)
AddLeaderboard(BOARD_TOTALPROPS_SINGLE, function(counts)
	local all = {}
	return all
end )*/
