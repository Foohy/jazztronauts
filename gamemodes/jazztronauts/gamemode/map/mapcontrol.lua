
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

		hook.Call("JazzMapRandomized", GAMEMODE, curSelected)

		net.Start("jazz_rollmap")
			net.WriteString(curSelected)
		net.Broadcast()
	end

	-- Send the current map to this player (usually if they just joined)
	function Refresh(ply)
		net.Start("jazz_rollmap")
			net.WriteString(curSelected)
		net.Send(ply)
	end

	function Launch(mapname)
		//idk man
	end

	-- Build the list of maps given what we've already played and what's installed
	function SetupMaps() 
		mapList = file.Find("maps/*.bsp", "GAME") -- option: WORKSHOP
		for _, v in pairs(mapList) do
			-- filter
		end
	end

else //CLIENT

	net.Receive("jazz_rollmap", function(len, ply)
		curSelected = net.ReadString()

		print("New map received: " .. curSelected)

		-- Broadcast update
		hook.Call("JazzMapRandomized", GAMEMODE, curSelected)
	end )


end