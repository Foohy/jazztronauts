
module( 'mapcontrol', package.seeall )

local localonly = CreateConVar("jazz_localmaps_only", 0, FCVAR_ARCHIVE, "Only use maps currently mounted on the server for map rolling.")

curSelected = curSelected or {}

//curSelected = curSelected or ""
--mapList = mapList or {}
--mapIDs = mapIDs or {} -- Store generated unique id lookups for a map
addonList = addonList or {}
function GetMap()
	return curSelected.map
end

function IsInHub()
	return game.GetMap() == GetHubMap()
end

function IsInGamemodeMap()
	local pref = string.Split(game.GetMap(), "_")[1]
	return pref == "jazz"
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
			net.WriteUInt(curSelected.wsid, 64)
			net.WriteUInt(#curSelected.maps, 8)
			for _, v in ipairs(curSelected.maps) do
				net.WriteString(v)
			end
		return IsValid(ply) and net.Send(ply) or net.Broadcast()
	end


	function Launch(mapname)	
		playerwait.SavePlayers()
		RunConsoleCommand("changelevel", mapname)
	end

	-- Given a workshop id, try to download and mount it 
	-- if it hasn't already been downloaded/mounted
	function InstallAddon(wsid, finishFunc, decompFunc)
		local cachepath = "jazztronauts"
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

	local function GetExternalMapAddons()
		local addons = {}
		local f = file.Open("data/jazztronauts/addons.txt", "r", "THIRDPARTY") -- TODO: Query external server?

		if not f then return addons end

		local line = f:ReadLine() 
		while line do
			table.insert(addons, tonumber(line))

			line = f:ReadLine()
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
				table.insert(valid, v)
			end
		end
	end

	-- Build a list of all addons that have maps installed
	-- This list will become our entire possible sample range -- so it's gonna be big
	function SetupMaps() 
		--mapList = {}
		--mapIDs = {}
		addonList = localonly:GetBool() and GetLocalMapAddons() or GetExternalMapAddons()

		/*
		local maps = file.Find("maps/*.bsp", "WORKSHOP") -- option: WORKSHOP

		for _, v in pairs(maps) do
			local map = string.StripExtension(v)
			
			table.insert(mapList, map)
			
			local mapid = GetMapID(map)
			if mapIDs[mapid] then 
				print("WARNING!!! THE FOLLOWING MAPS HAVE ID COLLISIONS: ")
				print(map)
				for _, v in pairs(mapIDs) do print(v) end
				print("-------------------------------")
				table.insert(mapIDs[mapid], map)
			else
				mapIDs[mapid] = { map }
			end
		end*/
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
		local wsid = net.ReadUInt(64)
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