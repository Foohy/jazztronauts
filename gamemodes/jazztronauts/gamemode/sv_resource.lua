local function AddDirectory(dir, path)
	path = path or "GAME"
	print("AddDirectory(" .. dir .. ", " .. path .. ")")
	local files, folders = file.Find(dir .. "/*", path)
	for _, f in pairs(files) do
		local filepath = string.lower(dir .. "/" .. f)

		-- Remove extra path junk
		filepath = string.gsub(filepath, "gamemodes/(.-)/content/", "", 1)

		resource.AddFile(filepath)
		print(filepath)
	end
end

-- Just fonts because workshop is weird with mounting fonts
local mainAdd = jazz.GetMainAddon()
local path = jazz.IsWorkshop() and mainAdd.mounted and mainAdd.title or "MOD"
local filepath = "resource/fonts"

AddDirectory(filepath, path)

-- Add all jazztronauts addon IDs
if jazz.IsWorkshop() then
	for id, _ in pairs(jazz.GetAddons()) do
		resource.AddWorkshop(id)
	end
end