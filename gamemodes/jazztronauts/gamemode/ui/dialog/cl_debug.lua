local function printNPCIDs()
    for k, v in pairs(missions.NPCList) do
        print(v.name .. " \t\t= " .. k .. " (" .. v.prettyname .. ")")
    end
end
concommand.Add("jazz_debug_printnpcs", function(ply, cmd, args)
    printNPCIDs()
end )

local function FindNPCByID(npcid)
    local npcs = ents.FindByClass("jazz_cat")
    for _, v in pairs(npcs) do
        if v.GetNPCID and v:GetNPCID() == npcid then 
            return v
        end
    end
end

concommand.Add("jazz_debug_runscript", function(ply, cmd, args)
	local script = args[1]
	if not dialog.IsScriptValid(script) then 
		print("Invalid script \"" .. script .. "\"!")
		return 
	end

	local npcid = tonumber(args[2])
	if not npcid then
		print("Please specify a target NPC ID to run the script on")
        printNPCIDs()
        return
    end

    local npc = FindNPCByID(npcid)
    if not IsValid(npc) then
        print("Failed to find NPC with ID " .. npcid)
        return
    end

    dialog.SetFocus(npc)
	dialog.StartGraph(script)
end )