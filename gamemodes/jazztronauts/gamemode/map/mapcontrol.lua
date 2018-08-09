
module( 'mapcontrol', package.seeall )
local defaultMapHost = "http://host.foohy.net/public/Documents/Jazz/addons.txt"
local defaultAddonCache = "jazztronauts/addons.txt"
local overrideAddonCache = "jazztronauts/addons_override.txt"

local includeExternal = CreateConVar("jazz_include_external", 1, FCVAR_ARCHIVE, "Whether or not to include an external addon host. Used for searching all of workshop")
local includeLocalAddons = CreateConVar("jazz_include_localaddon", 0, FCVAR_ARCHIVE, "Whether or not to include maps from locally installed addons. ")
local includeLocalMaps = CreateConVar("jazz_include_localmap", 0, FCVAR_ARCHIVE, "Whether or not to include local loose maps in the maps folder.")

local includeExternalHost = CreateConVar("jazz_include_external_host", defaultMapHost, FCVAR_ARCHIVE,
	   "Override the source of what random maps to pull from.\n"
	.. "Can be either a URL to a text file, listing each workshop addon by id\n"
	.. "Or a workshop collection ID itself.")

concommand.Add("jazz_clear_cache", function()
	ClearCache()
end,
nil, "Clears the temporary cache of downloaded map files")


curSelected = curSelected or {}
addonList = addonList or {}

function GetMap()
	return curSelected.map
end

function IsInHub()
	return game.GetMap() == GetHubMap()
end

function IsInEncounter()
	return game.GetMap() == GetEncounterMap()
end

function IsInGamemodeMap()
	local pref = string.Split(game.GetMap(), "_")[1]
	return pref == "jazz"
end

function GetIntroMap()
	return "jazz_intro"
end

function GetEncounterMap()
	return "jazz_apartments"
end

function GetEndMaps()
	return { "jazz_outro", "jazz_outro2" }
end

function GetNextEncounter()
	local bshardCount, bshardReq = mapgen.GetTotalCollectedBlackShards(), mapgen.GetTotalRequiredBlackShards()
	local isngp = newgame.GetResetCount() > 0
	if not isngp then return nil end

	local seen1, seen2, seen3 = newgame.GetGlobal("encounter_1"), newgame.GetGlobal("encounter_2"), newgame.GetGlobal("encounter_3")
	local halfway = math.Round(bshardReq / 2)

	-- First encounter, show if ng+ (not required level change though)
	if bshardCount == 0 and not seen1 then
		return 1, false
	elseif bshardCount >= 1 and bshardCount < halfway and not seen2 then
		return 2, true
	elseif bshardCount > halfway and not seen3 then
		return 3, true
	end

	return nil
end

function GetHubMap()
	return "jazz_bar"
end

function GetMapID(mapname)
	local crc = tonumber(util.CRC(string.lower(mapname)))
	return crc % 90000000 + 10000000
end

if SERVER then
	util.AddNetworkString("jazz_rollmap")

	local launched = false

	-- Roll a new random map to select
	function RollMap()
		print("mapcontrol.RollMap() is disabled.")
		return
		/*
		local newMap = table.Random(mapList)
		SetSelectedMap(newMap)
		return newMap, mapIDs[newMap]
		*/
	end

	function GetRandomAddon()
		return table.Random(addonList)
	end

	function IsWorkshopAddon(name)
		return tonumber(name) != nil
	end

	-- Given a unique map id, roll to it
	function RollMapID(id)
		local newMap = mapIDs[id] and table.Random(mapIDs[id])
		if newMap then
			SetSelectedMap(newMap)
		end

		return newMap
	end

	-- Get a random valid unique map id
	function GetRandomMapID()
		local _, k = table.Random(mapIDs)
		return k
	end

	function GetMapsInAddon(wsid)
		local maps = {}
		local found = file.Find("maps/*.bsp", wsid)
		for _, v in pairs(found) do
			table.insert(maps, string.StripExtension(v))
		end

		return maps
	end

	function GetSelectedMap()
		return curSelected.map
	end

	-- Update the new selected map
	function SetSelectedMap(newMap)
		if newMap == curSelected.map then return end
		curSelected.map = newMap

		-- Update workshop info
		local wsid = workshop.FindOwningAddon(newMap) or 0
		curSelected.wsid = wsid

		-- If workshop info present, it might be a map pack, so store that too
		curSelected.maps = wsid != 0 and GetMapsInAddon(wsid) or {}

		hook.Call("JazzMapRandomized", GAMEMODE, curSelected.map, curSelected.wsid)

		mapcontrol.Refresh()
	end

	-- Send the current map to this player (usually if they just joined)
	function Refresh(ply)
		if not curSelected.map then return end

		net.Start("jazz_rollmap")
			net.WriteString(curSelected.map)
			net.WriteString(curSelected.wsid)
			net.WriteUInt(#curSelected.maps, 8)
			for _, v in ipairs(curSelected.maps) do
				net.WriteString(v)
			end
		return IsValid(ply) and net.Send(ply) or net.Broadcast()
	end


	function Launch(mapname)
		newgame.SetGlobal("last_map", game.GetMap())
		playerwait.SavePlayers()
		launched = true
		RunConsoleCommand("changelevel", mapname)
	end

	function IsLaunching()
		return launched
	end

	-- Given a workshop id, try to download and mount it
	-- if it hasn't already been downloaded/mounted
	local cachepath = "jazztronauts/cache"
	function InstallAddon(wsid, finishFunc, decompFunc)
		file.CreateDir(cachepath)
		local dlpath = cachepath .. "/" .. wsid .. ".dat"

		-- Check local cache first
		local s, files = game.MountGMA("data/" .. dlpath)
		if s and files then
			print("Mounted from cache file!")
			finishFunc(files)
			return
		end

		-- Download from internet and mount
		workshop.DownloadGMA(wsid, function(data, errmsg)

			-- Bad workshop ID or network failure
			if not data then
				print("Failed to download addon: " .. errmsg)
				finishFunc(nil)
				return
			end

			-- Optionally, delay before decompressing if the decompress function told us to
			local delay = decompFunc and decompFunc(wsid) or 0
			timer.Simple(delay, function()

				-- Decompress and save to cache folder
				local fileList = workshop.ExtractGMA(dlpath, data)

				-- Try mounting
				print("Addon downloaded, decompressing and mounting...")
				local time = SysTime()
				local s, files = game.MountGMA("data/" .. dlpath)
				print("Mounting: " .. (SysTime() - time) .. " seconds.")

				if s and files then
					print("CONTENT MOUNTED!!! SAY HELLO TO YOUR NEW FILES:")
					PrintTable(files)
				end

				finishFunc(files)
			end )
		end)
	end

	function ClearCache()
		local files = file.Find(cachepath, "DATA")
		for _, v in pairs(files) do
			file.Delete(cachepath .. "/" .. v)
		end
	end

	local function GetExternalMapAddons(contents)
		local addons = {}

		for line in string.gmatch(contents, "[^\r\n]+") do
			local num = tonumber(line)
			if not num then continue end
			table.insert(addons, num)
		end

		return addons
	end

	local function GetLocalMapAddons()
		local valid = {}
		local addons = engine.GetAddons()

		-- For each installed addon, search its contents for a map file
		for _, v in pairs(addons) do
			local found = file.Find("maps/*.bsp", v.title)
			if #found > 0 then
				table.insert(valid, v.wsid)
			end
		end

		return valid
	end

	local function GetLocalMaps()
		local maps = file.Find("maps/*.bsp", "GAME")
		for k, v in pairs(maps) do
			maps[k] = string.StripExtension(v)
		end

		return maps
	end

	-- Build a list of all addons that have maps installed
	-- This list will become our entire possible sample range -- so it's gonna be big
	local function setupMapTask()
		local addons = {}

		local function insertAddons(newaddons)
			for k, v in pairs(newaddons) do
				addons[v] = true
			end
		end

		if includeExternal:GetBool() then
			local addonTask = task.NewCallback(function(done)
				http.Fetch(includeExternalHost:GetString(), done, function(err) ErrorNoHalt(err .. "\n") done() end)
			end )
			local addonsStr = task.Await(addonTask)

			if addonsStr then
				-- Save this successful run
				file.CreateDir(string.GetPathFromFilename(overrideAddonCache))
				file.Write(overrideAddonCache, addonsStr)
			else
				-- Try loading from their last successful download cache
				addonsStr = file.Read(overrideAddonCache, "DATA")

				-- Built in cache that comes with the game
				addonsStr = addonsStr or file.Read(defaultAddonCache, "DATA")
			end

			insertAddons(GetExternalMapAddons(addonsStr or ""))
		end

		if includeLocalAddons:GetBool() then
			insertAddons(GetLocalMapAddons())
		end

		if includeLocalMaps:GetBool() then
			insertAddons(GetLocalMaps())
		end

		addonList = table.GetKeys(addons)
	end

	function SetupMaps()
		task.New(setupMapTask, 1) -- ehh it'll get to it eventually
	end

	-- Spawn the exit bus's enterance portal at the specified position/angle.
	-- Note this spawns three entities, the enterance, the bus, and the exit
	lastBusEnts = lastBusEnts or {}
	function SpawnExitBus(pos, ang)
		local spawnpos = pos
		local spawnang = Angle(ang)
		spawnang:RotateAroundAxis(spawnang:Up(), 90)
		spawnpos = spawnpos - spawnang:Up() * 184/2

		-- Do a trace forward to where the bus will exit
		local tr = util.TraceLine( {
			start = pos,
			endpos = pos + ang:Forward() * 100000,
			mask = MASK_SOLID_BRUSHONLY
		} )

		local pos2 = tr.HitPos
		local ang2 = tr.HitNormal:Angle(spawnang:Up())
		ang2:RotateAroundAxis(ang2:Up(), 90)
		pos2 = pos2 - ang2:Up() * 184/2

		local bus = ents.Create("jazz_bus_explore")
		bus:SetPos(spawnpos)
		bus:SetAngles(spawnang)
		bus:Spawn()
		bus:Activate()

		local ent = ents.Create("jazz_bus_portal")
		ent:SetPos(spawnpos)
		ent:SetAngles(spawnang)
		ent:SetBus(bus)
		ent:Spawn()
		ent:Activate()

		local exit = ents.Create("jazz_bus_portal")
		exit:SetPos(pos2)
		exit:SetAngles(ang2)
		exit:SetBus(bus)
		exit:SetIsExit(true)
		exit:Spawn()
		exit:Activate()

		bus.ExitPortal = exit -- So bus knows when to stop

		-- Remove last ones
		for _, v in pairs(lastBusEnts) do SafeRemoveEntityDelayed(v, 5) end

		table.insert(lastBusEnts, bus)
		table.insert(lastBusEnts, ent)
		table.insert(lastBusEnts, exit)
	end

else //CLIENT

	net.Receive("jazz_rollmap", function(len, ply)
		curSelected = net.ReadString()
		local wsid = tonumber(net.ReadString())
		local maps = { curSelected }

		-- Read list of maps that are a part of this map pack
		-- Can be zero
		local num = net.ReadUInt(8)
		maps = {}
		for i = 1, num do
			table.insert(maps, net.ReadString())
		end
		PrintTable(maps)

		print("New map received: " .. curSelected)

		-- Broadcast update
		hook.Call("JazzMapRandomized", GAMEMODE, curSelected, wsid)
	end )


end
