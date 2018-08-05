AddCSLuaFile()

module("dialog", package.seeall)

reverseLookup = reverseLookup or {}

if SERVER then
	scriptids = scriptids or {}
	nettable.Create("dialog_script_ids")
	nettable.Set("dialog_script_ids", scriptids)

	function ClearScriptIDs()
		table.Empty(scriptids)
		table.Empty(reverseLookup)
		nextID = nil
	end

	function AddScriptID(name)
		if ScriptIDFromName(name) then
			ErrorNoHalt("Failed to add duplicate dialog name " .. name .. "!\n")
			return
		end

		nextID = (nextID and nextID + 1) or 1
		scriptids[nextID] = name
		reverseLookup[name] = nextID
	end
end

function ScriptIDFromName(name)
	return reverseLookup[name]
end

function NameFromScriptID(id)
	return nettable.Get("dialog_script_ids")[id]
end

if CLIENT then

	local function buildReverseLookup(tbl)
		local rev = {}
		for k, v in pairs(tbl) do
			if rev[v] then
				ErrorNoHalt("DUPLICATE SCRIPT NAME: " .. k .. " " .. v .. "\n")
				return nil
			end -- duplicate values

			rev[v] = k
		end

		return rev
	end

	nettable.Hook("dialog_script_ids", "dialogBuildReverseScriptLookup", function(changed, removed)
		reverseLookup = buildReverseLookup(nettable.Get("dialog_script_ids"))
	end )

end