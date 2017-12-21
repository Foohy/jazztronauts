
module( 'mapcontrol', package.seeall )

curSelected = curSelected or "gm_construct"
mapList = mapList or {}
function GetMap()
	return curSelected
end

function IsInHub()
	return game.GetMap() == "jazz_bar"
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
		//idk man
	end

	-- Build the list of maps given what we've already played and what's installed
	function SetupMaps() 
		local maps = file.Find("maps/*.bsp", "WORKSHOP") -- option: WORKSHOP
		for _, v in pairs(maps) do
			-- filter
			table.insert(mapList, string.StripExtension(v))
		end
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