-- Fix loading screen not correctly getting reset when switching out of jazztronauts

local jazz_var = "sv_loadingurl"
local jazz_url = "host.foohy.net/"

hook.Add("Initialize", "jazz_disable_loadscreen", function()
    local convar = GetConVar(jazz_var)
    if convar and string.find(convar:GetString(), jazz_url, 1, true) then
        RunConsoleCommand(jazz_var, "")
    end
end)