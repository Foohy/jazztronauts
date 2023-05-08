module("jazz", package.seeall)

GAME_VERSION = 2.0
MAIN_ADDON = "1452613192"

WORKSHOP_IDS = WORKSHOP_IDS or
{
	[MAIN_ADDON] = {},

-- deprecated content packs, no longer necessary to split it up
--	["1452627889"] = {},
--	["1455876201"] = {},
}

LOCAL_COPY = LOCAL_COPY or true

function CheckAddons()
	local addons = engine.GetAddons()
	local maybeWorkshopCopy = false

	for _, v in pairs(addons) do
		if WORKSHOP_IDS[v.wsid] then

			-- If the main addon is mounted, double check it's fully workshop
			if v.wsid == MAIN_ADDON then
				maybeWorkshopCopy = v.mounted
			end

			-- Store up to date info about jazz workshop addon
			WORKSHOP_IDS[v.wsid] = v
		end
	end

	-- Check if gamemode exists loosely in their gmod directory
	-- If it does, assume local copy
	if maybeWorkshopCopy then
		local f, d = file.Find("gamemodes/jazztronauts/*", "MOD")
		LOCAL_COPY = #f > 0 and #d > 0
	end
end

-- Ensure, if on workshop, the server has downloaded and mounted every jazztronauts content pack
function IsProperlyInstalled()
	if LOCAL_COPY then return true end

	for _, v in pairs(WORKSHOP_IDS) do
		if not v.mounted then return false end
	end

	return true
end

-- Get all the jazztronauts addons/content packs
function GetAddons()
	return WORKSHOP_IDS
end

-- Get the main addon that contains all of the code
function GetMainAddon()
	return WORKSHOP_IDS[MAIN_ADDON]
end

-- Whether or not we're currently running from workshop or from a local copy
function IsWorkshop()
	return not LOCAL_COPY
end

-- Retrieve the current version of the game
function GetVersion()
	return GAME_VERSION
end

-- Immediately check addons so everything can have the latest info
CheckAddons()