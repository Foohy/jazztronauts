-- Fix loading screen not correctly getting reset when switching out of jazztronauts

local jazz_var = "sv_loadingurl"
local jazz_url = "host.foohy.net/"

local WORKSHOP_CACHE_PATH = "jazztronauts/cache"

local function ClearCache()
	local files = file.Find(WORKSHOP_CACHE_PATH .. "/*", "DATA")
	for _, v in pairs(files) do
		file.Delete(WORKSHOP_CACHE_PATH .. "/" .. v)
	end
end

hook.Add("Initialize", "jazz_disable_loadscreen", function()
    local convar = GetConVar(jazz_var)
    if convar and string.find(convar:GetString(), jazz_url, 1, true) then
        RunConsoleCommand(jazz_var, "")
    end

    -- Also clear the jazz cache of downloaded maps
    ClearCache()
end)
