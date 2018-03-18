
module( 'mapcontrol', package.seeall )

curSelected = curSelected or "gm_construct"
mapList = mapList or {}
function GetMap()
	return curSelected
end

function IsInHub()
	return game.GetMap() == GetHubMap()
end

function GetHubMap()
	return "jazz_bar"
end

if SERVER then
	util.AddNetworkString("jazz_rollmap")

	-- Roll a new map to select
	function RollMap()
		local newMap = table.Random(mapList)
		SetSelectedMap(newMap)
		return newMap
	end

	-- Update the new selected map
	function SetSelectedMap(newMap)
		if newMap == curSelected then return end
		curSelected = newMap

		local addon = FindOwningAddon(newMap)
		local wsid = addon and addon.wsid or 0

		hook.Call("JazzMapRandomized", GAMEMODE, curSelected, wsid)

		net.Start("jazz_rollmap")
			net.WriteString(curSelected)
			net.WriteUInt(wsid, 64)
		net.Broadcast()
	end

	-- Send the current map to this player (usually if they just joined)
	function Refresh(ply)
		net.Start("jazz_rollmap")
			net.WriteString(curSelected)
		net.Send(ply)
	end

	-- Attempt to find the addon that 'owns' this map
	-- May be nil if the map is just loose in their folder
	function FindOwningAddon(mapname)
		local addons = engine.GetAddons()

		-- For each installed addon, search its contents for the given map file
		-- This is very slow so make ideally we only ever do this once on startup
		for _, v in pairs(addons) do
			local found = file.Find("maps/" .. mapname .. ".bsp", v.title)
			if #found > 0 then return v end
		end

		return nil
	end

	function Launch(mapname)
		RunConsoleCommand("changelevel", mapname)
	end

	-- Build the list of maps given what we've already played and what's installed
	function SetupMaps() 
		local maps = file.Find("maps/*.bsp", "WORKSHOP") -- option: WORKSHOP
		local finished = progress.GetMapHistory()
		for _, v in pairs(maps) do
			local map = string.StripExtension(v)
			if finished and table.HasValue(finished, map) then continue end
			
			table.insert(mapList, map)
		end
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

		print("New map received: " .. curSelected)

		-- Broadcast update
		hook.Call("JazzMapRandomized", GAMEMODE, curSelected, wsid)
	end )


end