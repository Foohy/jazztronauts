AddCSLuaFile()

module("factgen", package.seeall)

if SERVER then
	include("sv_factgen.lua")

	NamedFacts = NamedFacts or {}

	FactIDTable = FactIDTable or {}
	FactStringTable = FactStringTable or {}

	nettable.Create("browser_factscreens")
	nettable.Set("browser_factscreens", FactIDTable)

	nettable.Create("browser_factscreens_names")
	nettable.Set("browser_factscreens_names", FactStringTable)


	-- Set the string of a specific fact
	function SetFact(factName, str)
		local factTbl = NamedFacts[factName]
		if not factTbl then
			factTbl =
			{
				name = factName,
				id = table.Count(NamedFacts) + 1,
				fact = str or ""
			}

			NamedFacts[factName] = factTbl
		end

		factTbl.fact = str
		FactIDTable[factTbl.id] = factTbl.fact
		FactStringTable[factTbl.id] = factTbl.name

		return factTbl.id
	end

	function SetFacts(factTbl)
		ClearFacts()
		for k, v in pairs(factTbl) do
			SetFact(k, v)
		end
	end

	function SetFailure(errorStr)
		ClearFacts()
		SetFact("failure", errorStr)
	end

	function ClearFacts()
		for k, v in pairs(NamedFacts) do
			SetFact(k, "")
		end
	end

	function GetFactIDByName(name, createIfNotFound)
		local factID = name and NamedFacts[name] and NamedFacts[name].id or nil
		if createIfNotFound and not factID then
			factID = SetFact(name, "")
		end

		return factID
	end

	-- Deprecated
	function AssociateFacts()
		local screens = ents.FindByClass("jazz_factscreen")
		local factsLeft = table.Copy(NamedFacts)

		for k, v in pairs(screens) do
			v:SetFactID((k % table.Count(NamedFacts) + 1))
		end
	end
end

if CLIENT then
	Callbacks = Callbacks or {}
	CombinedFacts = CombinedFacts or {}
	ActiveFacts = ActiveFacts or {}

	function GetFacts()
		return CombinedFacts
	end

	function GetActiveFactIDs()
		return ActiveFacts
	end

	function GetFactByID(id)
		return CombinedFacts[(id % table.Count(CombinedFacts)) + 1]
	end

	local function CallHooks()
		for _, v in pairs(Callbacks) do
			v()
		end
	end

	function Hook(id, func)
		Callbacks[id] = func
	end

	local function updateAllFacts()
		local combinedFacts = {}
		local activeFacts = {}
		local factIds, factNames = nettable.Get("browser_factscreens"), nettable.Get("browser_factscreens_names")

		-- Must at least be same size
		if table.Count(factIds) != table.Count(factNames) then return nil end

		-- Recombine into single
		for k, v in pairs(factIds) do
			if not factNames[k] then return nil end

			combinedFacts[k] = {
				id = k,
				fact = jazzloc.Localize(string.Explode(",",v)), 
				name = factNames[k]
			}

			activeFacts[k] = #v > 0
		end

		return combinedFacts, activeFacts
	end

	nettable.Hook("browser_factscreens", "updateBrowserFactScreens", function(changed, removed)
		local combined, active = updateAllFacts()
		if combined then
			CombinedFacts = combined
			ActiveFacts = active
			CallHooks()
		end
	end )

	nettable.Hook("browser_factscreens_names", "updateBrowserFactScreens", function(changed, removed)
		local combined, active = updateAllFacts()
		if combined then
			CombinedFacts = combined
			ActiveFacts = active
			CallHooks()
		end
	end )
end

